/// Copia de seguridad común de la Suite Larrea: empaqueta la base de
/// datos SQLite de la app, sus carpetas de ficheros (fotos) y, si se
/// pide, parte de sus preferencias en un ZIP; y restaura ese ZIP sin
/// arriesgar los datos que ya hay en el dispositivo.
///
/// Prioridad absoluta: **no perder datos**. Por eso la restauración:
///
/// 1. Extrae y valida la copia entera en una carpeta de preparación
///    (ZIP legible, CRC de cada entrada, es de esta app, la BD es
///    SQLite, el esquema no es más nuevo que el de la app, integridad
///    opcional) **antes de tocar nada**.
/// 2. Hace una copia automática del estado actual (y la relee para
///    comprobar que vale) en `<datos>/copias_automaticas/`.
/// 3. Cierra la BD, aparta los ficheros actuales (no los borra) y
///    coloca los nuevos, anotando en un diario en disco lo que hace.
/// 4. Reabre la BD y aplica las preferencias. Si cualquier paso falla,
///    deshace lo hecho con lo apartado. Si la app muere a mitad, el
///    diario permite deshacerlo al arrancar
///    ([ServicioCopiaSeguridad.recuperarRestauracionInterrumpida]).
///
/// Lee también los ZIP que generaban las apps antes de este servicio
/// (`<nombre>.db` en la raíz + `fotos/...`, sin manifiesto).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nombre de la entrada del manifiesto dentro del ZIP.
const String nombreEntradaManifiestoCopia = 'copia_seguridad.json';

/// Nombre de la entrada con las preferencias copiadas.
const String nombreEntradaPreferenciasCopia = 'preferencias.json';

/// Marca del manifiesto que identifica una copia de este servicio.
const String identificadorFormatoCopia = 'solera-copia-seguridad';

/// Versión del formato que escribe este servicio. Una copia con una
/// versión mayor se rechaza (la hizo una app más nueva).
const int versionFormatoCopiaSeguridad = 1;

/// Primeros 16 bytes de todo fichero SQLite 3.
const List<int> cabeceraSqlite = [
  0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // «SQLite f»
  0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // «ormat 3\0»
];

/// Por qué se rechaza una copia o falla una operación.
enum MotivoErrorCopiaSeguridad {
  /// El fichero elegido no existe.
  ficheroNoExiste,

  /// No es un ZIP legible, o alguna entrada está dañada (CRC).
  noEsZip,

  /// El manifiesto está, pero no se entiende.
  manifiestoNoValido,

  /// La copia la hizo una versión más nueva del formato.
  formatoMasNuevo,

  /// La copia es de otra app (manifiesto de otra app o BD de otra).
  deOtraApp,

  /// No hay BD con el nombre esperado dentro del ZIP.
  sinBaseDatos,

  /// La BD de la copia no es un fichero SQLite válido.
  baseDatosNoValida,

  /// La BD de la copia tiene un esquema más nuevo que el de la app.
  esquemaMasNuevo,

  /// La comprobación de integridad de la app ha fallado.
  integridadFallida,

  /// Alguna entrada intenta escribir fuera de la carpeta de datos.
  rutaPeligrosa,

  /// No se pudo hacer la copia automática previa: no se ha tocado nada.
  respaldoPrevioFallido,

  /// No hay BD que copiar (app recién instalada).
  sinDatosQueCopiar,

  /// La restauración falló a mitad y se ha vuelto al estado anterior.
  restauracionRevertida,

  /// La restauración falló y tampoco se pudo volver atrás del todo.
  /// El estado anterior sigue en la copia automática y en la carpeta de
  /// trabajo que indica el mensaje.
  reversionFallida,
}

/// Error de copia de seguridad, con un [motivo] que la pantalla puede
/// traducir y un [mensaje] en castellano para registros.
class ErrorCopiaSeguridad implements Exception {
  const ErrorCopiaSeguridad(this.motivo, this.mensaje, {this.respaldoPrevio, this.causa});

  final MotivoErrorCopiaSeguridad motivo;
  final String mensaje;

  /// Copia automática del estado anterior, si se llegó a hacer.
  final File? respaldoPrevio;

  /// Error original, si lo hay.
  final Object? causa;

  /// True si los datos del dispositivo están igual que antes de
  /// intentarlo (todo menos [MotivoErrorCopiaSeguridad.reversionFallida]).
  bool get datosIntactos => motivo != MotivoErrorCopiaSeguridad.reversionFallida;

  @override
  String toString() => 'ErrorCopiaSeguridad(${motivo.name}): $mensaje';
}

/// Qué app usa el servicio y dónde guarda sus cosas.
class ConfiguracionCopiaSeguridad {
  const ConfiguracionCopiaSeguridad({
    required this.identificadorApp,
    required this.nombreApp,
    required this.nombreFicheroBaseDatos,
    required this.cerrarBaseDatos,
    required this.reabrirBaseDatos,
    this.prefijoNombreCopia,
    this.carpetasExtra = const ['fotos'],
    this.prefijosPreferencias = const [],
    this.clavesPreferencias = const [],
    this.clavePreferenciaUltimaCopia,
    this.versionEsquemaActual,
    this.comprobarIntegridad,
    this.obtenerDirectorioDatos,
    this.obtenerDirectorioCopias,
    this.respaldosAutomaticosAConservar = 3,
  });

  /// Identificador estable de la app en el manifiesto, p. ej.
  /// `solera_apicola`. No cambiarlo nunca: las copias hechas dejarían de
  /// reconocerse como de esta app.
  final String identificadorApp;

  /// Nombre para personas, p. ej. «Larrea Apícola» (mensajes de error).
  final String nombreApp;

  /// Nombre del fichero de BD dentro de la carpeta de datos, p. ej.
  /// `solera_apicola.db`. Es también el nombre de la entrada en el ZIP.
  final String nombreFicheroBaseDatos;

  /// Cierra la BD (el singleton debe quedar listo para reabrirse).
  final Future<void> Function() cerrarBaseDatos;

  /// Abre la BD de nuevo (y con ello aplica migraciones). Si lanza tras
  /// colocar una copia, la restauración se deshace.
  final Future<void> Function() reabrirBaseDatos;

  /// Prefijo del nombre del ZIP; por defecto `<identificador>-copia`.
  final String? prefijoNombreCopia;

  /// Carpetas (relativas a la de datos) que van en la copia. Al
  /// restaurar, sus ficheros se añaden sobre los actuales (no se borra
  /// nada que la copia no traiga).
  final List<String> carpetasExtra;

  /// Las preferencias cuya clave empieza por alguno de estos prefijos
  /// van en la copia y se restauran.
  final List<String> prefijosPreferencias;

  /// Claves de preferencias concretas que van en la copia.
  final List<String> clavesPreferencias;

  /// Clave donde se guarda la fecha de la última copia (nunca se copia
  /// ni se restaura). Por defecto `<identificador>.backup.ultimo_ms`,
  /// la que usaban ya las apps.
  final String? clavePreferenciaUltimaCopia;

  /// Versión del esquema que abre la app (`version:` de openDatabase).
  /// Si se da, se rechaza una copia con un esquema mayor.
  final int? versionEsquemaActual;

  /// Comprobación opcional de la BD extraída antes de restaurar (p. ej.
  /// abrirla en solo lectura y `PRAGMA integrity_check`). Recibe la ruta
  /// del fichero ya extraído en la carpeta de preparación.
  final Future<bool> Function(String rutaBaseDatos)? comprobarIntegridad;

  /// Carpeta donde vive la BD; por defecto la de documentos.
  final Future<Directory> Function()? obtenerDirectorioDatos;

  /// Carpeta donde se dejan las copias para compartir; por defecto la
  /// temporal (share_plus las adjunta sin permisos extra).
  final Future<Directory> Function()? obtenerDirectorioCopias;

  /// Cuántas copias automáticas previas a restaurar se conservan.
  final int respaldosAutomaticosAConservar;

  String get _prefijoNombreCopia => prefijoNombreCopia ?? '${identificadorApp.replaceAll('_', '-')}-copia';

  String get _claveUltimaCopia => clavePreferenciaUltimaCopia ?? '$identificadorApp.backup.ultimo_ms';

  /// La BD y los ficheros que la acompañan (WAL, memoria compartida,
  /// diario de rollback).
  List<String> get _ficherosBaseDatos => [
        nombreFicheroBaseDatos,
        '$nombreFicheroBaseDatos-wal',
        '$nombreFicheroBaseDatos-shm',
        '$nombreFicheroBaseDatos-journal',
      ];
}

/// Lo que se sabe de una copia tras validarla.
class InformeCopiaSeguridad {
  const InformeCopiaSeguridad({
    required this.fichero,
    required this.esFormatoAntiguo,
    required this.identificadorApp,
    required this.fechaCreacion,
    required this.versionEsquema,
    required this.numeroFicherosExtra,
    required this.numeroPreferencias,
  });

  final File fichero;

  /// True si es un ZIP de antes de este servicio (sin manifiesto).
  final bool esFormatoAntiguo;

  /// App según el manifiesto (null en el formato antiguo).
  final String? identificadorApp;

  /// Fecha del manifiesto (null en el formato antiguo).
  final DateTime? fechaCreacion;

  /// `user_version` de la BD de la copia (lo que sqflite llama versión).
  final int versionEsquema;

  /// Ficheros de las carpetas extra (fotos) que trae.
  final int numeroFicherosExtra;

  /// Preferencias que trae y que esta configuración restauraría.
  final int numeroPreferencias;
}

/// Resultado de una restauración correcta.
class ResultadoRestauracionCopia {
  const ResultadoRestauracionCopia({required this.informe, required this.respaldoPrevio});

  final InformeCopiaSeguridad informe;

  /// Copia automática del estado anterior (null si no había BD).
  final File? respaldoPrevio;
}

/// Servicio de copia de seguridad. Cada app crea **una** instancia (las
/// operaciones de una instancia no se solapan).
class ServicioCopiaSeguridad {
  ServicioCopiaSeguridad(this.configuracion, {@visibleForTesting this.puntoDeControlParaPruebas});

  final ConfiguracionCopiaSeguridad configuracion;

  /// Solo pruebas: se llama en cada paso de la restauración con el
  /// nombre del paso; si lanza, simula un fallo a mitad.
  final Future<void> Function(String paso)? puntoDeControlParaPruebas;

  static const String _nombreCarpetaTrabajo = '.copia_seguridad_en_curso';
  static const String _nombreCarpetaPreparada = 'preparada';
  static const String _nombreCarpetaApartada = 'anterior';
  static const String _nombreDiario = 'diario.json';
  static const String _nombreCarpetaRespaldos = 'copias_automaticas';
  static const String _prefijoRespaldoAutomatico = 'antes-de-restaurar';

  Future<void> _ultimaOperacion = Future<void>.value();

  // ─── API pública ──────────────────────────────────────────────

  /// Crea una copia (BD + carpetas extra + preferencias elegidas) y la
  /// devuelve. Se relee antes de darla por buena. Por defecto la deja en
  /// la carpeta de copias (temporal) y apunta la fecha como última copia.
  Future<File> crearCopia({Directory? directorioDestino, bool registrarComoUltimaCopia = true}) {
    return _enExclusiva(() async {
      final destino = directorioDestino ?? await _directorioCopias();
      final copia = await _crearCopiaSinBloqueo(destino, configuracion._prefijoNombreCopia);
      if (registrarComoUltimaCopia) {
        final preferencias = await SharedPreferences.getInstance();
        await preferencias.setInt(configuracion._claveUltimaCopia, DateTime.now().millisecondsSinceEpoch);
      }
      return copia;
    });
  }

  /// Comprueba una copia sin tocar nada: que es un ZIP sano, de esta
  /// app, con una BD SQLite válida y un esquema que la app sabe abrir.
  /// Lanza [ErrorCopiaSeguridad] si no vale.
  Future<InformeCopiaSeguridad> validarCopia(File copia) {
    return _enExclusiva(() async {
      final preparacion = await _carpetaNuevaEn(await _directorioCopias(), '.validacion-copia');
      try {
        final copiaPreparada = await _prepararCopia(copia, preparacion, soloBaseDatos: true);
        return copiaPreparada.informe;
      } finally {
        await _borrarSiExiste(preparacion);
      }
    });
  }

  /// Restaura una copia. Si la copia no vale, lanza sin haber tocado
  /// nada. Si falla a mitad, deja todo como estaba y lanza
  /// [MotivoErrorCopiaSeguridad.restauracionRevertida].
  Future<ResultadoRestauracionCopia> restaurarCopia(File copia) {
    return _enExclusiva(() => _restaurarSinBloqueo(copia));
  }

  /// Deshace una restauración que se quedó a medias (la app murió
  /// mientras sustituía ficheros). Llamarla al arrancar, **antes de abrir
  /// la BD**. Devuelve true si ha tenido que deshacer algo.
  Future<bool> recuperarRestauracionInterrumpida() {
    return _enExclusiva(() async {
      final carpetaTrabajo = Directory(path_lib.join((await _directorioDatos()).path, _nombreCarpetaTrabajo));
      return _recuperarSiHaceFalta(carpetaTrabajo);
    });
  }

  /// Fecha de la última copia creada con [crearCopia], o null.
  Future<DateTime?> ultimaCopia() async {
    final preferencias = await SharedPreferences.getInstance();
    final milisegundos = preferencias.getInt(configuracion._claveUltimaCopia);
    return milisegundos == null ? null : DateTime.fromMillisecondsSinceEpoch(milisegundos);
  }

  /// True si nunca se ha hecho copia o hace más de [intervaloAviso].
  /// Para sugerirla, nunca para hacerla sola.
  Future<bool> tocaSugerirCopia({Duration intervaloAviso = const Duration(days: 7)}) async {
    final ultima = await ultimaCopia();
    return ultima == null || DateTime.now().difference(ultima) > intervaloAviso;
  }

  /// Copias automáticas hechas antes de restaurar, de la más nueva a la
  /// más vieja.
  Future<List<File>> respaldosAutomaticos() async {
    final carpeta = Directory(path_lib.join((await _directorioDatos()).path, _nombreCarpetaRespaldos));
    if (!await carpeta.exists()) return [];
    final respaldos = await carpeta
        .list()
        .where((entidad) => entidad is File && path_lib.basename(entidad.path).endsWith('.zip'))
        .cast<File>()
        .toList();
    respaldos.sort((a, b) => path_lib.basename(b.path).compareTo(path_lib.basename(a.path)));
    return respaldos;
  }

  // ─── Exclusión mutua ─────────────────────────────────────────

  Future<T> _enExclusiva<T>(Future<T> Function() operacion) {
    final anterior = _ultimaOperacion;
    final terminada = Completer<void>();
    _ultimaOperacion = terminada.future;
    return anterior.then((_) => operacion()).whenComplete(terminada.complete);
  }

  // ─── Directorios ─────────────────────────────────────────────

  Future<Directory> _directorioDatos() async => configuracion.obtenerDirectorioDatos != null
      ? await configuracion.obtenerDirectorioDatos!()
      : await getApplicationDocumentsDirectory();

  Future<Directory> _directorioCopias() async => configuracion.obtenerDirectorioCopias != null
      ? await configuracion.obtenerDirectorioCopias!()
      : await getTemporaryDirectory();

  // ─── Crear ───────────────────────────────────────────────────

  Future<File> _crearCopiaSinBloqueo(
    Directory directorioDestino,
    String prefijoNombre, {
    bool reabrirAlTerminar = true,
  }) async {
    final directorioDatos = await _directorioDatos();
    final ficheroBaseDatos = File(path_lib.join(directorioDatos.path, configuracion.nombreFicheroBaseDatos));
    await directorioDestino.create(recursive: true);
    final ahora = DateTime.now();
    final nombreCopia = '$prefijoNombre-${_marcaTemporal(ahora)}.zip';
    final copiaFinal = File(await _rutaLibre(path_lib.join(directorioDestino.path, nombreCopia)));
    final copiaParcial = File('${copiaFinal.path}.parcial');

    // Cerrada, la BD tiene todo en el fichero principal (SQLite vuelca
    // el WAL al cerrar la última conexión) y nadie escribe mientras tanto.
    await configuracion.cerrarBaseDatos();
    try {
      if (!await ficheroBaseDatos.exists()) {
        throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.sinDatosQueCopiar,
          'No hay base de datos de ${configuracion.nombreApp} que copiar.',
        );
      }
      final preferencias = await _leerPreferenciasIncluidas();
      final manifiesto = {
        'formato': identificadorFormatoCopia,
        'versionFormato': versionFormatoCopiaSeguridad,
        'app': configuracion.identificadorApp,
        'nombreApp': configuracion.nombreApp,
        'fecha': ahora.toUtc().toIso8601String(),
        'ficheroBaseDatos': configuracion.nombreFicheroBaseDatos,
        'versionEsquema': await _leerVersionEsquema(ficheroBaseDatos),
        'carpetasExtra': configuracion.carpetasExtra,
        'incluyePreferencias': preferencias.isNotEmpty,
      };

      final codificador = ZipFileEncoder();
      codificador.create(copiaParcial.path);
      try {
        _anadirTexto(codificador, nombreEntradaManifiestoCopia, const JsonEncoder.withIndent('  ').convert(manifiesto));
        if (preferencias.isNotEmpty) {
          _anadirTexto(
              codificador, nombreEntradaPreferenciasCopia, const JsonEncoder.withIndent('  ').convert(preferencias));
        }
        await codificador.addFile(ficheroBaseDatos, configuracion.nombreFicheroBaseDatos);
        // Si aun cerrada quedara un WAL, va con la BD (lleva datos).
        final ficheroWal = File('${ficheroBaseDatos.path}-wal');
        if (await ficheroWal.exists() && await ficheroWal.length() > 0) {
          await codificador.addFile(ficheroWal, '${configuracion.nombreFicheroBaseDatos}-wal');
        }
        for (final carpetaExtra in configuracion.carpetasExtra) {
          final carpeta = Directory(path_lib.join(directorioDatos.path, carpetaExtra));
          if (!await carpeta.exists()) continue;
          final ficheros = await carpeta
              .list(recursive: true, followLinks: false)
              .where((entidad) => entidad is File)
              .cast<File>()
              .toList();
          ficheros.sort((a, b) => a.path.compareTo(b.path));
          for (final fichero in ficheros) {
            final rutaRelativa = path_lib.relative(fichero.path, from: directorioDatos.path).replaceAll(r'\', '/');
            await codificador.addFile(fichero, rutaRelativa);
          }
        }
      } finally {
        await codificador.close();
      }

      // Se relee lo escrito: si no se puede validar, no hay copia.
      final comprobacion = await _carpetaNuevaEn(directorioDestino, '.comprobacion-copia');
      try {
        await _prepararCopia(copiaParcial, comprobacion, soloBaseDatos: true);
      } finally {
        await _borrarSiExiste(comprobacion);
      }
      await copiaParcial.rename(copiaFinal.path);
      return copiaFinal;
    } catch (_) {
      await _borrarSiExiste(copiaParcial);
      rethrow;
    } finally {
      if (reabrirAlTerminar) await configuracion.reabrirBaseDatos();
    }
  }

  void _anadirTexto(ZipFileEncoder codificador, String nombre, String texto) {
    final bytes = utf8.encode(texto);
    codificador.addArchiveFile(ArchiveFile(nombre, bytes.length, bytes));
  }

  // ─── Preparar (extraer y validar) ───────────────────────────

  /// Extrae a [carpetaPreparacion] lo que se va a restaurar y lo valida.
  /// No toca la carpeta de datos.
  Future<_CopiaPreparada> _prepararCopia(File copia, Directory carpetaPreparacion,
      {required bool soloBaseDatos}) async {
    if (!await copia.exists()) {
      throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.ficheroNoExiste, 'El fichero de copia no existe: ${copia.path}');
    }
    final entrada = InputFileStream(copia.path);
    try {
      final Archive archivo;
      try {
        archivo = ZipDecoder().decodeBuffer(entrada);
      } catch (error) {
        throw ErrorCopiaSeguridad(MotivoErrorCopiaSeguridad.noEsZip, 'El fichero no es un ZIP legible.', causa: error);
      }

      final entradasPorNombre = <String, ArchiveFile>{};
      for (final entradaZip in archivo.files) {
        if (!entradaZip.isFile || entradaZip.isSymbolicLink) continue;
        final nombre = entradaZip.name.replaceAll(r'\', '/');
        if (!_esRutaRelativaSegura(nombre)) {
          throw ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.rutaPeligrosa,
            'La copia contiene una ruta no permitida: «${entradaZip.name}».',
          );
        }
        entradasPorNombre[nombre] = entradaZip;
      }

      // Manifiesto (formato nuevo) o formato antiguo.
      final entradaManifiesto = entradasPorNombre[nombreEntradaManifiestoCopia];
      Map<String, dynamic>? manifiesto;
      if (entradaManifiesto != null) {
        try {
          final decodificado = jsonDecode(utf8.decode(_contenidoVerificado(entradaManifiesto)));
          if (decodificado is! Map<String, dynamic>) throw const FormatException('no es un objeto');
          manifiesto = decodificado;
        } on ErrorCopiaSeguridad {
          rethrow;
        } catch (error) {
          throw ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.manifiestoNoValido,
            'El manifiesto de la copia no se entiende.',
            causa: error,
          );
        }
        if (manifiesto['formato'] != identificadorFormatoCopia) {
          throw const ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.manifiestoNoValido,
            'El ZIP no es una copia de seguridad de Solera.',
          );
        }
        final versionFormato = manifiesto['versionFormato'];
        if (versionFormato is! int) {
          throw const ErrorCopiaSeguridad(
              MotivoErrorCopiaSeguridad.manifiestoNoValido, 'El manifiesto no indica su versión.');
        }
        if (versionFormato > versionFormatoCopiaSeguridad) {
          throw const ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.formatoMasNuevo,
            'La copia la hizo una versión más nueva de la app. Actualiza la app para restaurarla.',
          );
        }
        if (manifiesto['app'] != configuracion.identificadorApp) {
          throw ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.deOtraApp,
            'La copia es de «${manifiesto['nombreApp'] ?? manifiesto['app']}», no de ${configuracion.nombreApp}.',
          );
        }
      }

      final entradaBaseDatos = entradasPorNombre[configuracion.nombreFicheroBaseDatos];
      if (entradaBaseDatos == null) {
        final otraBaseDatos =
            entradasPorNombre.keys.where((nombre) => !nombre.contains('/') && nombre.endsWith('.db')).firstOrNull;
        if (manifiesto == null && otraBaseDatos != null) {
          throw ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.deOtraApp,
            'La copia trae «$otraBaseDatos»: es de otra app, no de ${configuracion.nombreApp}.',
          );
        }
        throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.sinBaseDatos,
          'La copia no contiene ${configuracion.nombreFicheroBaseDatos}: no parece una copia de ${configuracion.nombreApp}.',
        );
      }

      // Qué se extrae: BD (+ WAL si lo trae; nunca el -shm, que se
      // regenera) y, salvo en la validación rápida, las carpetas extra.
      final rutasExtra = <String>[];
      await carpetaPreparacion.create(recursive: true);
      await _extraerEntrada(entradaBaseDatos, carpetaPreparacion, configuracion.nombreFicheroBaseDatos);
      final entradaWal = entradasPorNombre['${configuracion.nombreFicheroBaseDatos}-wal'];
      if (entradaWal != null) {
        await _extraerEntrada(entradaWal, carpetaPreparacion, '${configuracion.nombreFicheroBaseDatos}-wal');
      }
      var numeroFicherosExtra = 0;
      for (final nombre in entradasPorNombre.keys) {
        final primerSegmento = nombre.split('/').first;
        if (!nombre.contains('/') || !configuracion.carpetasExtra.contains(primerSegmento)) continue;
        numeroFicherosExtra++;
        if (soloBaseDatos) continue;
        await _extraerEntrada(entradasPorNombre[nombre]!, carpetaPreparacion, nombre);
        rutasExtra.add(nombre);
      }

      // Preferencias: solo las que esta configuración restaura.
      final preferencias = <String, Map<String, dynamic>>{};
      final entradaPreferencias = entradasPorNombre[nombreEntradaPreferenciasCopia];
      if (entradaPreferencias != null) {
        try {
          final decodificadas = jsonDecode(utf8.decode(_contenidoVerificado(entradaPreferencias)));
          if (decodificadas is! Map<String, dynamic>) throw const FormatException('no es un objeto');
          for (final par in decodificadas.entries) {
            if (!_clavePreferenciaIncluida(par.key)) continue;
            final valor = par.value;
            if (valor is! Map<String, dynamic> || _deserializarPreferencia(valor) == null) {
              throw FormatException('preferencia «${par.key}» no válida');
            }
            preferencias[par.key] = valor;
          }
        } on ErrorCopiaSeguridad {
          rethrow;
        } catch (error) {
          throw ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.manifiestoNoValido,
            'Las preferencias de la copia no se entienden.',
            causa: error,
          );
        }
      }

      // La BD extraída: SQLite de verdad y con un esquema que sabemos abrir.
      final rutaBaseDatosPreparada = path_lib.join(carpetaPreparacion.path, configuracion.nombreFicheroBaseDatos);
      final versionEsquema = await _validarFicheroSqlite(File(rutaBaseDatosPreparada));
      final versionActual = configuracion.versionEsquemaActual;
      if (versionActual != null && versionEsquema > versionActual) {
        throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.esquemaMasNuevo,
          'La copia es de una versión más nueva de ${configuracion.nombreApp} '
          '(esquema $versionEsquema; esta app abre hasta el $versionActual). Actualiza la app para restaurarla.',
        );
      }
      final comprobarIntegridad = configuracion.comprobarIntegridad;
      if (comprobarIntegridad != null) {
        bool integra;
        try {
          integra = await comprobarIntegridad(rutaBaseDatosPreparada);
        } catch (_) {
          integra = false;
        }
        if (!integra) {
          throw const ErrorCopiaSeguridad(
            MotivoErrorCopiaSeguridad.integridadFallida,
            'La base de datos de la copia está dañada.',
          );
        }
      }

      final fechaTexto = manifiesto?['fecha'];
      return _CopiaPreparada(
        carpeta: carpetaPreparacion,
        rutasExtra: rutasExtra,
        preferencias: preferencias,
        informe: InformeCopiaSeguridad(
          fichero: copia,
          esFormatoAntiguo: manifiesto == null,
          identificadorApp: manifiesto?['app'] as String?,
          fechaCreacion: fechaTexto is String ? DateTime.tryParse(fechaTexto)?.toLocal() : null,
          versionEsquema: versionEsquema,
          numeroFicherosExtra: numeroFicherosExtra,
          numeroPreferencias: preferencias.length,
        ),
      );
    } finally {
      await entrada.close();
    }
  }

  /// Contenido descomprimido de una entrada, comprobando su CRC.
  List<int> _contenidoVerificado(ArchiveFile entradaZip) {
    final List<int> contenido;
    try {
      contenido = entradaZip.content as List<int>;
    } catch (error) {
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.noEsZip,
        'La entrada «${entradaZip.name}» de la copia está dañada.',
        causa: error,
      );
    }
    final crcEsperado = entradaZip.crc32;
    if (contenido.length != entradaZip.size || (crcEsperado != null && getCrc32(contenido) != crcEsperado)) {
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.noEsZip,
        'La entrada «${entradaZip.name}» de la copia está dañada.',
      );
    }
    return contenido;
  }

  Future<void> _extraerEntrada(ArchiveFile entradaZip, Directory carpeta, String rutaRelativa) async {
    final contenido = _contenidoVerificado(entradaZip);
    final destino = File(path_lib.join(carpeta.path, rutaRelativa));
    await destino.parent.create(recursive: true);
    await destino.writeAsBytes(contenido, flush: true);
    entradaZip.clear(); // libera la memoria de lo ya escrito
  }

  /// Comprueba la cabecera SQLite y devuelve el `user_version`.
  Future<int> _validarFicheroSqlite(File fichero) async {
    final longitud = await fichero.length();
    List<int> cabecera = const [];
    if (longitud >= 100) {
      final lector = await fichero.open();
      try {
        cabecera = await lector.read(100);
      } finally {
        await lector.close();
      }
    }
    if (cabecera.length < 100 || !listEquals(cabecera.sublist(0, 16), cabeceraSqlite)) {
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.baseDatosNoValida,
        'El fichero ${configuracion.nombreFicheroBaseDatos} de la copia no es una base de datos SQLite.',
      );
    }
    final valorTamanoPagina = (cabecera[16] << 8) | cabecera[17];
    final tamanoPagina = valorTamanoPagina == 1 ? 65536 : valorTamanoPagina;
    final esPotenciaDeDos = tamanoPagina > 0 && (tamanoPagina & (tamanoPagina - 1)) == 0;
    if (!esPotenciaDeDos || tamanoPagina < 512 || tamanoPagina > 65536 || longitud % tamanoPagina != 0) {
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.baseDatosNoValida,
        'La base de datos de la copia está incompleta o dañada.',
      );
    }
    return _enteroBigEndian(cabecera, 60);
  }

  Future<int?> _leerVersionEsquema(File ficheroBaseDatos) async {
    try {
      final lector = await ficheroBaseDatos.open();
      try {
        final cabecera = await lector.read(100);
        if (cabecera.length < 100) return null;
        return _enteroBigEndian(cabecera, 60);
      } finally {
        await lector.close();
      }
    } catch (_) {
      return null;
    }
  }

  static int _enteroBigEndian(List<int> bytes, int desde) =>
      (bytes[desde] << 24) | (bytes[desde + 1] << 16) | (bytes[desde + 2] << 8) | bytes[desde + 3];

  /// Ruta relativa, sin `..`, sin raíz, sin unidad de Windows.
  static bool _esRutaRelativaSegura(String nombre) {
    if (nombre.isEmpty || nombre.startsWith('/') || nombre.contains(':') || nombre.contains('\u0000')) return false;
    final segmentos = nombre.split('/');
    return segmentos.every((segmento) => segmento.isNotEmpty && segmento != '.' && segmento != '..');
  }

  // ─── Restaurar ───────────────────────────────────────────────

  Future<ResultadoRestauracionCopia> _restaurarSinBloqueo(File copia) async {
    final directorioDatos = await _directorioDatos();
    final carpetaTrabajo = Directory(path_lib.join(directorioDatos.path, _nombreCarpetaTrabajo));

    // Si una restauración anterior se quedó a medias, primero se deshace.
    await _recuperarSiHaceFalta(carpetaTrabajo);
    await _borrarSiExiste(carpetaTrabajo);
    await carpetaTrabajo.create(recursive: true);

    // 1. Preparar y validar. La carpeta de trabajo está dentro de la de
    //    datos: así mover ficheros es un rename en el mismo disco.
    final carpetaPreparada = Directory(path_lib.join(carpetaTrabajo.path, _nombreCarpetaPreparada));
    final _CopiaPreparada copiaPreparada;
    try {
      copiaPreparada = await _prepararCopia(copia, carpetaPreparada, soloBaseDatos: false);
      await _puntoDeControl('preparada');
    } catch (_) {
      await _borrarSiExiste(carpetaTrabajo);
      rethrow;
    }

    // 2. Copia automática del estado actual, releída antes de seguir.
    File? respaldoPrevio;
    final ficheroBaseDatosActual = File(path_lib.join(directorioDatos.path, configuracion.nombreFicheroBaseDatos));
    if (await ficheroBaseDatosActual.exists()) {
      try {
        respaldoPrevio = await _crearCopiaSinBloqueo(
          Directory(path_lib.join(directorioDatos.path, _nombreCarpetaRespaldos)),
          _prefijoRespaldoAutomatico,
          // Cerrada hasta sustituir: nada escrito después de la copia
          // automática puede quedarse fuera de ella.
          reabrirAlTerminar: false,
        );
        await _puntoDeControl('respaldo');
      } catch (error) {
        await _borrarSiExiste(carpetaTrabajo);
        try {
          await configuracion.reabrirBaseDatos();
        } catch (_) {
          // Se informa del fallo de la copia, que es el que importa.
        }
        throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.respaldoPrevioFallido,
          'No se pudo hacer la copia del estado actual; no se ha restaurado nada.',
          causa: error,
        );
      }
    }

    // 3. Sustituir, con diario en disco para poder deshacer.
    final carpetaApartada = Directory(path_lib.join(carpetaTrabajo.path, _nombreCarpetaApartada));
    await carpetaApartada.create(recursive: true);
    final preferencias = await SharedPreferences.getInstance();
    final preferenciasAnteriores = <String, Map<String, dynamic>?>{
      for (final clave in copiaPreparada.preferencias.keys) clave: _serializarPreferencia(preferencias.get(clave)),
    };
    // La BD se cierra antes de mirar qué ficheros tiene: al cerrar,
    // SQLite puede volcar y borrar su -wal.
    try {
      await configuracion.cerrarBaseDatos();
    } catch (error) {
      await _borrarSiExiste(carpetaTrabajo);
      try {
        await configuracion.reabrirBaseDatos();
      } catch (_) {
        // Se informa del error de cierre, que es el que importa.
      }
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.restauracionRevertida,
        'No se pudo cerrar la base de datos; no se ha restaurado nada. Causa: $error',
        respaldoPrevio: respaldoPrevio,
        causa: error,
      );
    }
    final ficherosBaseDatosAnteriores = <String>[
      for (final nombre in configuracion._ficherosBaseDatos)
        if (await File(path_lib.join(directorioDatos.path, nombre)).exists()) nombre,
    ];
    final extrasNuevos = <String>[];
    final extrasConAnterior = <String>[];
    for (final rutaRelativa in copiaPreparada.rutasExtra) {
      final existe =
          await FileSystemEntity.type(path_lib.join(directorioDatos.path, rutaRelativa), followLinks: false) !=
              FileSystemEntityType.notFound;
      (existe ? extrasConAnterior : extrasNuevos).add(rutaRelativa);
    }
    final diario = _DiarioRestauracion(
      fase: _DiarioRestauracion.faseSustituyendo,
      ficherosBaseDatosAnteriores: ficherosBaseDatosAnteriores,
      extrasNuevos: extrasNuevos,
      extrasConAnterior: extrasConAnterior,
      preferenciasAnteriores: preferenciasAnteriores,
      respaldoPrevio: respaldoPrevio?.path,
    );

    try {
      await _escribirDiario(carpetaTrabajo, diario);
      await _puntoDeControl('cerrada');

      // BD: se apartan todos sus ficheros (también -wal y -shm viejos,
      // que no deben mezclarse con la BD nueva) y se coloca la nueva.
      for (final nombre in ficherosBaseDatosAnteriores) {
        await _mover(path_lib.join(directorioDatos.path, nombre), path_lib.join(carpetaApartada.path, nombre));
      }
      await _puntoDeControl('apartada');
      for (final nombre in [configuracion.nombreFicheroBaseDatos, '${configuracion.nombreFicheroBaseDatos}-wal']) {
        final preparado = path_lib.join(carpetaPreparada.path, nombre);
        if (await File(preparado).exists()) {
          await _mover(preparado, path_lib.join(directorioDatos.path, nombre));
        }
      }
      await _puntoDeControl('base_datos_colocada');

      // Carpetas extra: se añaden; lo que se pisaría se aparta antes.
      for (final rutaRelativa in copiaPreparada.rutasExtra) {
        final destino = path_lib.join(directorioDatos.path, rutaRelativa);
        if (extrasConAnterior.contains(rutaRelativa)) {
          await _mover(destino, path_lib.join(carpetaApartada.path, rutaRelativa));
        }
        await _mover(path_lib.join(carpetaPreparada.path, rutaRelativa), destino);
        await _puntoDeControl('extra:$rutaRelativa');
      }
      await _puntoDeControl('extras_colocados');

      // 4. Reabrir (migraciones incluidas) y preferencias.
      await configuracion.reabrirBaseDatos();
      await _puntoDeControl('reabierta');
      for (final par in copiaPreparada.preferencias.entries) {
        await _escribirPreferencia(preferencias, par.key, par.value);
      }
      await _puntoDeControl('preferencias');

      await _escribirDiario(carpetaTrabajo, diario.conFase(_DiarioRestauracion.faseCompletada));
    } catch (errorRestauracion) {
      try {
        await _revertir(carpetaTrabajo, diario);
        await configuracion.reabrirBaseDatos();
        await _borrarSiExiste(carpetaTrabajo);
      } catch (errorReversion) {
        throw ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.reversionFallida,
          'La restauración falló y no se pudo volver atrás del todo. Tu estado anterior está en '
          '${respaldoPrevio?.path ?? 'la carpeta'} y en ${carpetaTrabajo.path}. '
          'Causa: $errorRestauracion. Al deshacer: $errorReversion',
          respaldoPrevio: respaldoPrevio,
          causa: errorRestauracion,
        );
      }
      throw ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.restauracionRevertida,
        'La restauración falló y se ha vuelto al estado anterior. Causa: $errorRestauracion',
        respaldoPrevio: respaldoPrevio,
        causa: errorRestauracion,
      );
    }

    await _borrarSiExiste(carpetaTrabajo);
    await _podarRespaldosAutomaticos();
    return ResultadoRestauracionCopia(informe: copiaPreparada.informe, respaldoPrevio: respaldoPrevio);
  }

  /// Deshace lo hecho según el diario y lo apartado. Idempotente: se
  /// puede repetir tras una caída a mitad de deshacer.
  Future<void> _revertir(Directory carpetaTrabajo, _DiarioRestauracion diario) async {
    final directorioDatos = await _directorioDatos();
    final carpetaApartada = Directory(path_lib.join(carpetaTrabajo.path, _nombreCarpetaApartada));
    try {
      await configuracion.cerrarBaseDatos();
    } catch (_) {
      // Si no estaba abierta o no se puede cerrar, se sigue: hay que
      // devolver los ficheros a su sitio igualmente.
    }

    for (final nombre in configuracion._ficherosBaseDatos) {
      final enSuSitio = path_lib.join(directorioDatos.path, nombre);
      final apartado = path_lib.join(carpetaApartada.path, nombre);
      if (await File(apartado).exists()) {
        await _borrarFicheroSiExiste(enSuSitio);
        await _mover(apartado, enSuSitio);
      } else if (!diario.ficherosBaseDatosAnteriores.contains(nombre)) {
        // No existía antes: lo que haya ahora es de la restauración.
        await _borrarFicheroSiExiste(enSuSitio);
      }
      // Si existía y no está apartado, no se llegó a mover: intacto.
    }

    for (final rutaRelativa in diario.extrasNuevos) {
      await _borrarFicheroSiExiste(path_lib.join(directorioDatos.path, rutaRelativa));
    }
    for (final rutaRelativa in diario.extrasConAnterior) {
      final apartado = path_lib.join(carpetaApartada.path, rutaRelativa);
      if (await File(apartado).exists()) {
        final enSuSitio = path_lib.join(directorioDatos.path, rutaRelativa);
        await _borrarFicheroSiExiste(enSuSitio);
        await _mover(apartado, enSuSitio);
      }
    }

    final preferencias = await SharedPreferences.getInstance();
    for (final par in diario.preferenciasAnteriores.entries) {
      final valorAnterior = par.value;
      if (valorAnterior == null) {
        await preferencias.remove(par.key);
      } else {
        await _escribirPreferencia(preferencias, par.key, valorAnterior);
      }
    }
  }

  Future<bool> _recuperarSiHaceFalta(Directory carpetaTrabajo) async {
    if (!await carpetaTrabajo.exists()) return false;
    final ficheroDiario = File(path_lib.join(carpetaTrabajo.path, _nombreDiario));
    if (!await ficheroDiario.exists()) {
      // No se llegó a tocar nada (aún se preparaba): basura.
      await _borrarSiExiste(carpetaTrabajo);
      return false;
    }
    final diario =
        _DiarioRestauracion.desdeJson(jsonDecode(await ficheroDiario.readAsString()) as Map<String, dynamic>);
    if (diario.fase == _DiarioRestauracion.faseCompletada) {
      await _borrarSiExiste(carpetaTrabajo);
      return false;
    }
    await _revertir(carpetaTrabajo, diario);
    await _borrarSiExiste(carpetaTrabajo);
    return true;
  }

  Future<void> _escribirDiario(Directory carpetaTrabajo, _DiarioRestauracion diario) async {
    final definitivo = File(path_lib.join(carpetaTrabajo.path, _nombreDiario));
    final provisional = File('${definitivo.path}.nuevo');
    await provisional.writeAsString(jsonEncode(diario.aJson()), flush: true);
    await provisional.rename(definitivo.path);
  }

  Future<void> _podarRespaldosAutomaticos() async {
    try {
      final respaldos = await respaldosAutomaticos();
      for (final sobrante in respaldos.skip(configuracion.respaldosAutomaticosAConservar)) {
        await sobrante.delete();
      }
    } catch (_) {
      // Podar es limpieza: si falla, sobran copias, no faltan datos.
    }
  }

  Future<void> _puntoDeControl(String paso) async {
    final punto = puntoDeControlParaPruebas;
    if (punto != null) await punto(paso);
  }

  // ─── Preferencias ────────────────────────────────────────────

  bool _clavePreferenciaIncluida(String clave) {
    if (clave == configuracion._claveUltimaCopia) return false;
    return configuracion.clavesPreferencias.contains(clave) ||
        configuracion.prefijosPreferencias.any((prefijo) => clave.startsWith(prefijo));
  }

  Future<Map<String, Map<String, dynamic>>> _leerPreferenciasIncluidas() async {
    if (configuracion.prefijosPreferencias.isEmpty && configuracion.clavesPreferencias.isEmpty) return {};
    final preferencias = await SharedPreferences.getInstance();
    final claves = preferencias.getKeys().where(_clavePreferenciaIncluida).toList()..sort();
    return {
      for (final clave in claves)
        if (_serializarPreferencia(preferencias.get(clave)) != null)
          clave: _serializarPreferencia(preferencias.get(clave))!,
    };
  }

  static Map<String, dynamic>? _serializarPreferencia(Object? valor) {
    if (valor is bool) return {'tipo': 'bool', 'valor': valor};
    if (valor is int) return {'tipo': 'int', 'valor': valor};
    if (valor is double) return {'tipo': 'double', 'valor': valor};
    if (valor is String) return {'tipo': 'texto', 'valor': valor};
    if (valor is List) return {'tipo': 'lista', 'valor': valor.map((elemento) => '$elemento').toList()};
    return null;
  }

  static Object? _deserializarPreferencia(Map<String, dynamic> serializada) {
    final valor = serializada['valor'];
    switch (serializada['tipo']) {
      case 'bool':
        return valor is bool ? valor : null;
      case 'int':
        return valor is int ? valor : null;
      case 'double':
        return valor is num ? valor.toDouble() : null;
      case 'texto':
        return valor is String ? valor : null;
      case 'lista':
        return valor is List && valor.every((elemento) => elemento is String) ? valor.cast<String>() : null;
    }
    return null;
  }

  static Future<void> _escribirPreferencia(
      SharedPreferences preferencias, String clave, Map<String, dynamic> serializada) async {
    final valor = _deserializarPreferencia(serializada);
    if (valor is bool) {
      await preferencias.setBool(clave, valor);
    } else if (valor is int) {
      await preferencias.setInt(clave, valor);
    } else if (valor is double) {
      await preferencias.setDouble(clave, valor);
    } else if (valor is String) {
      await preferencias.setString(clave, valor);
    } else if (valor is List<String>) {
      await preferencias.setStringList(clave, valor);
    }
  }

  // ─── Ficheros ────────────────────────────────────────────────

  static Future<void> _mover(String origen, String destino) async {
    await Directory(path_lib.dirname(destino)).create(recursive: true);
    await File(origen).rename(destino);
  }

  static Future<void> _borrarFicheroSiExiste(String ruta) async {
    final fichero = File(ruta);
    if (await fichero.exists()) await fichero.delete();
  }

  static Future<void> _borrarSiExiste(FileSystemEntity entidad) async {
    if (await entidad.exists()) await entidad.delete(recursive: true);
  }

  static Future<Directory> _carpetaNuevaEn(Directory padre, String prefijo) async {
    await padre.create(recursive: true);
    return padre.createTemp(prefijo);
  }

  static Future<String> _rutaLibre(String rutaDeseada) async {
    if (!await File(rutaDeseada).exists()) return rutaDeseada;
    final sinExtension = path_lib.withoutExtension(rutaDeseada);
    final extension = path_lib.extension(rutaDeseada);
    for (var numero = 2;; numero++) {
      final candidata = '$sinExtension-$numero$extension';
      if (!await File(candidata).exists()) return candidata;
    }
  }

  static String _marcaTemporal(DateTime momento) {
    String dosCifras(int numero) => numero.toString().padLeft(2, '0');
    return '${momento.year}${dosCifras(momento.month)}${dosCifras(momento.day)}-'
        '${dosCifras(momento.hour)}${dosCifras(momento.minute)}${dosCifras(momento.second)}';
  }
}

class _CopiaPreparada {
  const _CopiaPreparada(
      {required this.carpeta, required this.rutasExtra, required this.preferencias, required this.informe});

  final Directory carpeta;
  final List<String> rutasExtra;
  final Map<String, Map<String, dynamic>> preferencias;
  final InformeCopiaSeguridad informe;
}

/// Lo que hace falta para deshacer una restauración, también tras una
/// caída de la app.
class _DiarioRestauracion {
  const _DiarioRestauracion({
    required this.fase,
    required this.ficherosBaseDatosAnteriores,
    required this.extrasNuevos,
    required this.extrasConAnterior,
    required this.preferenciasAnteriores,
    required this.respaldoPrevio,
  });

  static const String faseSustituyendo = 'sustituyendo';
  static const String faseCompletada = 'completada';

  final String fase;
  final List<String> ficherosBaseDatosAnteriores;
  final List<String> extrasNuevos;
  final List<String> extrasConAnterior;
  final Map<String, Map<String, dynamic>?> preferenciasAnteriores;
  final String? respaldoPrevio;

  _DiarioRestauracion conFase(String nuevaFase) => _DiarioRestauracion(
        fase: nuevaFase,
        ficherosBaseDatosAnteriores: ficherosBaseDatosAnteriores,
        extrasNuevos: extrasNuevos,
        extrasConAnterior: extrasConAnterior,
        preferenciasAnteriores: preferenciasAnteriores,
        respaldoPrevio: respaldoPrevio,
      );

  Map<String, dynamic> aJson() => {
        'fase': fase,
        'ficherosBaseDatosAnteriores': ficherosBaseDatosAnteriores,
        'extrasNuevos': extrasNuevos,
        'extrasConAnterior': extrasConAnterior,
        'preferenciasAnteriores': preferenciasAnteriores,
        'respaldoPrevio': respaldoPrevio,
      };

  factory _DiarioRestauracion.desdeJson(Map<String, dynamic> json) => _DiarioRestauracion(
        fase: json['fase'] as String,
        ficherosBaseDatosAnteriores: (json['ficherosBaseDatosAnteriores'] as List).cast<String>(),
        extrasNuevos: (json['extrasNuevos'] as List).cast<String>(),
        extrasConAnterior: (json['extrasConAnterior'] as List).cast<String>(),
        preferenciasAnteriores: (json['preferenciasAnteriores'] as Map<String, dynamic>)
            .map((clave, valor) => MapEntry(clave, valor == null ? null : Map<String, dynamic>.from(valor as Map))),
        respaldoPrevio: json['respaldoPrevio'] as String?,
      );
}
