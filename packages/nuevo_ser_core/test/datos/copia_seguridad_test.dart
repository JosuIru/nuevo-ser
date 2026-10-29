import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/src/datos/copia_seguridad.dart';
import 'package:path/path.dart' as path_lib;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Imita el singleton de BD de una app Larrea, sobre un fichero SQLite
/// real en una carpeta temporal.
class _AppDePrueba {
  _AppDePrueba(this.directorioDatos, this.nombreFicheroBaseDatos, {this.versionEsquema = 2});

  final Directory directorioDatos;
  final String nombreFicheroBaseDatos;
  final int versionEsquema;
  Database? _baseDatos;
  int fallosPendientesAlReabrir = 0;

  String get rutaBaseDatos => path_lib.join(directorioDatos.path, nombreFicheroBaseDatos);

  Future<Database> abrir() async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await databaseFactoryFfi.openDatabase(
      rutaBaseDatos,
      options: OpenDatabaseOptions(
        version: versionEsquema,
        singleInstance: false,
        onCreate: (baseDatos, version) async {
          await baseDatos.execute('CREATE TABLE registros (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL)');
        },
      ),
    );
    return _baseDatos!;
  }

  Future<void> cerrar() async {
    await _baseDatos?.close();
    _baseDatos = null;
  }

  Future<void> reabrir() async {
    if (fallosPendientesAlReabrir > 0) {
      fallosPendientesAlReabrir--;
      throw StateError('migración rota (simulada)');
    }
    await abrir();
  }

  Future<void> insertar(String nombre) async => (await abrir()).insert('registros', {'nombre': nombre});

  Future<void> borrarTodo() async => (await abrir()).delete('registros');

  Future<List<String>> nombres() async =>
      (await (await abrir()).query('registros', orderBy: 'id')).map((fila) => fila['nombre'] as String).toList();

  Future<void> escribirFoto(String rutaRelativa, String contenido) async {
    final foto = File(path_lib.join(directorioDatos.path, rutaRelativa));
    await foto.parent.create(recursive: true);
    await foto.writeAsString(contenido);
  }

  Future<String?> leerFoto(String rutaRelativa) async {
    final foto = File(path_lib.join(directorioDatos.path, rutaRelativa));
    return await foto.exists() ? foto.readAsString() : null;
  }
}

/// Imita, línea a línea, el `crearZip` que tenían agro y las verticales
/// (BD + -wal/-shm si existen en la raíz, y `fotos/` con su nombre).
Future<File> _crearZipFormatoAntiguo(_AppDePrueba app, String rutaZip) async {
  await app.cerrar();
  final codificador = ZipFileEncoder();
  codificador.create(rutaZip);
  try {
    final nombreBd = app.nombreFicheroBaseDatos;
    for (final nombre in [nombreBd, '$nombreBd-wal', '$nombreBd-shm']) {
      final fichero = File(path_lib.join(app.directorioDatos.path, nombre));
      if (await fichero.exists()) {
        await codificador.addFile(fichero, nombre);
      }
    }
    final carpetaFotos = Directory(path_lib.join(app.directorioDatos.path, 'fotos'));
    if (await carpetaFotos.exists()) {
      await codificador.addDirectory(carpetaFotos, includeDirName: true);
    }
  } finally {
    codificador.closeSync();
  }
  return File(rutaZip);
}

File _zipEnMemoria(String ruta, Map<String, List<int>> entradas) {
  final archivo = Archive();
  for (final par in entradas.entries) {
    archivo.addFile(ArchiveFile(par.key, par.value.length, par.value));
  }
  return File(ruta)..writeAsBytesSync(ZipEncoder().encode(archivo)!);
}

/// Todos los ficheros de una carpeta con su contenido.
Future<Map<String, List<int>>> _instantanea(Directory carpeta) async {
  final resultado = <String, List<int>>{};
  if (!await carpeta.exists()) return resultado;
  await for (final entidad in carpeta.list(recursive: true)) {
    if (entidad is File) {
      resultado[path_lib.relative(entidad.path, from: carpeta.path)] = await entidad.readAsBytes();
    }
  }
  return resultado;
}

Future<bool> _integridadConFfi(String ruta) async {
  final baseDatos = await databaseFactoryFfi.openDatabase(
    ruta,
    options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
  );
  try {
    final filas = await baseDatos.rawQuery('PRAGMA integrity_check');
    return filas.length == 1 && filas.first.values.first == 'ok';
  } finally {
    await baseDatos.close();
  }
}

void main() {
  sqfliteFfiInit();

  late Directory raiz;
  late Directory directorioCopias;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    raiz = await Directory.systemTemp.createTemp('copia_seguridad_test');
    directorioCopias = Directory(path_lib.join(raiz.path, 'copias'))..createSync();
  });

  tearDown(() async {
    if (await raiz.exists()) await raiz.delete(recursive: true);
  });

  Directory carpetaDatos(String nombre) => Directory(path_lib.join(raiz.path, nombre))..createSync(recursive: true);

  ServicioCopiaSeguridad servicioPara(
    _AppDePrueba app, {
    String identificadorApp = 'solera_apicola',
    List<String> prefijosPreferencias = const [],
    List<String> clavesPreferencias = const [],
    int? versionEsquemaActual,
    Future<bool> Function(String)? comprobarIntegridad,
    Future<void> Function(String)? puntoDeControl,
  }) {
    return ServicioCopiaSeguridad(
      ConfiguracionCopiaSeguridad(
        identificadorApp: identificadorApp,
        nombreApp: 'App $identificadorApp',
        nombreFicheroBaseDatos: app.nombreFicheroBaseDatos,
        cerrarBaseDatos: app.cerrar,
        reabrirBaseDatos: app.reabrir,
        prefijosPreferencias: prefijosPreferencias,
        clavesPreferencias: clavesPreferencias,
        versionEsquemaActual: versionEsquemaActual,
        comprobarIntegridad: comprobarIntegridad,
        obtenerDirectorioDatos: () async => app.directorioDatos,
        obtenerDirectorioCopias: () async => directorioCopias,
      ),
      puntoDeControlParaPruebas: puntoDeControl,
    );
  }

  Future<void> esperarRechazo(Future<Object?> operacion, MotivoErrorCopiaSeguridad motivo) async {
    await expectLater(
      operacion,
      throwsA(isA<ErrorCopiaSeguridad>().having((error) => error.motivo, 'motivo', motivo)),
    );
  }

  group('crear y restaurar', () {
    test('crear → cambiar → restaurar devuelve los mismos datos y fotos', () async {
      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('Colmena 1');
      await app.insertar('Colmena 2');
      await app.escribirFoto('fotos/2026-10/1.jpg', 'foto uno');
      final servicio = servicioPara(app, versionEsquemaActual: 2, comprobarIntegridad: _integridadConFfi);

      final copia = await servicio.crearCopia();
      expect(path_lib.basename(copia.path), startsWith('solera-apicola-copia-'));
      expect(await servicio.ultimaCopia(), isNotNull);

      // El manifiesto dice de qué app y qué esquema es.
      final archivo = ZipDecoder().decodeBytes(await copia.readAsBytes());
      final manifiesto = jsonDecode(utf8.decode(archivo.findFile(nombreEntradaManifiestoCopia)!.content as List<int>));
      expect(manifiesto['app'], 'solera_apicola');
      expect(manifiesto['versionFormato'], versionFormatoCopiaSeguridad);
      expect(manifiesto['versionEsquema'], 2);
      expect(archivo.findFile('fotos/2026-10/1.jpg'), isNotNull);

      final informe = await servicio.validarCopia(copia);
      expect(informe.esFormatoAntiguo, isFalse);
      expect(informe.versionEsquema, 2);
      expect(informe.numeroFicherosExtra, 1);

      // Cambios después de la copia.
      await app.borrarTodo();
      await app.insertar('Otra cosa');
      await app.escribirFoto('fotos/2026-10/1.jpg', 'foto cambiada');
      await app.escribirFoto('fotos/2026-10/2.jpg', 'foto nueva');

      final resultado = await servicio.restaurarCopia(copia);
      expect(await app.nombres(), ['Colmena 1', 'Colmena 2']);
      expect(await app.leerFoto('fotos/2026-10/1.jpg'), 'foto uno');
      // Lo que la copia no trae no se borra.
      expect(await app.leerFoto('fotos/2026-10/2.jpg'), 'foto nueva');

      // La copia automática guarda el estado de justo antes.
      final respaldo = resultado.respaldoPrevio!;
      expect(await respaldo.exists(), isTrue);
      expect(await servicio.respaldosAutomaticos(), [isA<File>()]);
      await servicio.restaurarCopia(respaldo);
      expect(await app.nombres(), ['Otra cosa']);
      expect(await app.leerFoto('fotos/2026-10/1.jpg'), 'foto cambiada');

      // No queda la carpeta de trabajo.
      expect(await Directory(path_lib.join(app.directorioDatos.path, '.copia_seguridad_en_curso')).exists(), isFalse);
    });

    test('quita los -wal y -shm viejos al colocar la BD restaurada', () async {
      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('Bueno');
      final servicio = servicioPara(app);
      final copia = await servicio.crearCopia();
      await app.cerrar();
      File('${app.rutaBaseDatos}-wal').writeAsStringSync('basura wal');
      File('${app.rutaBaseDatos}-shm').writeAsStringSync('basura shm');

      await servicio.restaurarCopia(copia);
      await app.cerrar();
      expect(File('${app.rutaBaseDatos}-wal').existsSync(), isFalse);
      expect(File('${app.rutaBaseDatos}-shm').existsSync(), isFalse);
      expect(await app.nombres(), ['Bueno']);
    });

    test('rechaza una copia de un esquema más nuevo sin tocar nada', () async {
      final appNueva = _AppDePrueba(carpetaDatos('nueva'), 'solera_apicola.db', versionEsquema: 3);
      await appNueva.insertar('De la versión 3');
      final copia = await servicioPara(appNueva).crearCopia();

      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('Actual');
      await app.cerrar();
      final antes = await _instantanea(app.directorioDatos);
      await esperarRechazo(
        servicioPara(app, versionEsquemaActual: 2).restaurarCopia(copia),
        MotivoErrorCopiaSeguridad.esquemaMasNuevo,
      );
      expect(await _instantanea(app.directorioDatos), antes);
    });
  });

  group('copias antiguas (sin manifiesto)', () {
    test('restaura un ZIP antiguo de agro', () async {
      final origen = _AppDePrueba(carpetaDatos('movil_viejo'), 'agro.db', versionEsquema: 7);
      await origen.insertar('Olivo del ribazo');
      await origen.escribirFoto('fotos/2025-04/1714000000000.jpg', 'foto agro');
      final zip = await _crearZipFormatoAntiguo(origen, path_lib.join(raiz.path, 'solera-backup-20250401-1200.zip'));

      final destino = _AppDePrueba(carpetaDatos('movil_nuevo'), 'agro.db', versionEsquema: 7);
      await destino.insertar('Otra finca');
      final servicio = servicioPara(destino,
          identificadorApp: 'agro', versionEsquemaActual: 7, comprobarIntegridad: _integridadConFfi);

      final informe = await servicio.validarCopia(zip);
      expect(informe.esFormatoAntiguo, isTrue);
      expect(informe.versionEsquema, 7);

      final resultado = await servicio.restaurarCopia(zip);
      expect(resultado.informe.esFormatoAntiguo, isTrue);
      expect(await destino.nombres(), ['Olivo del ribazo']);
      expect(await destino.leerFoto('fotos/2025-04/1714000000000.jpg'), 'foto agro');
    });

    test('restaura un ZIP antiguo de apícola, también con -wal dentro', () async {
      final origen = _AppDePrueba(carpetaDatos('movil_viejo'), 'solera_apicola.db');
      await origen.insertar('Colmena del castaño');
      await origen.escribirFoto('fotos/2025-06/1.jpg', 'foto apícola');
      final zip =
          await _crearZipFormatoAntiguo(origen, path_lib.join(raiz.path, 'solera-apicola-backup-20250601-0900.zip'));

      final destino = _AppDePrueba(carpetaDatos('movil_nuevo'), 'solera_apicola.db');
      await destino.insertar('Nada que ver');
      final resultado = await servicioPara(destino, versionEsquemaActual: 2).restaurarCopia(zip);
      expect(resultado.informe.esFormatoAntiguo, isTrue);
      expect(await destino.nombres(), ['Colmena del castaño']);
      expect(await destino.leerFoto('fotos/2025-06/1.jpg'), 'foto apícola');
    });
  });

  group('copias rechazadas sin tocar nada', () {
    late _AppDePrueba app;
    late Map<String, List<int>> estadoInicial;

    setUp(() async {
      app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('Lo que hay');
      await app.escribirFoto('fotos/a.jpg', 'foto actual');
      await app.cerrar();
      estadoInicial = await _instantanea(app.directorioDatos);
    });

    Future<void> comprobarIntacto() async {
      await app.cerrar();
      expect(await _instantanea(app.directorioDatos), estadoInicial);
      expect(await app.nombres(), ['Lo que hay']);
    }

    test('ZIP antiguo de otra app (agro en apícola)', () async {
      final otra = _AppDePrueba(carpetaDatos('agro'), 'agro.db');
      await otra.insertar('De agro');
      final zip = await _crearZipFormatoAntiguo(otra, path_lib.join(raiz.path, 'agro.zip'));
      await esperarRechazo(servicioPara(app).restaurarCopia(zip), MotivoErrorCopiaSeguridad.deOtraApp);
      await esperarRechazo(servicioPara(app).validarCopia(zip), MotivoErrorCopiaSeguridad.deOtraApp);
      await comprobarIntacto();
    });

    test('copia nueva de otra app aunque la BD se llame igual', () async {
      final otra = _AppDePrueba(carpetaDatos('otra'), 'solera_apicola.db');
      await otra.insertar('De viticultura');
      final copia = await servicioPara(otra, identificadorApp: 'solera_viticultura').crearCopia();
      await esperarRechazo(servicioPara(app).restaurarCopia(copia), MotivoErrorCopiaSeguridad.deOtraApp);
      await comprobarIntacto();
    });

    test('fichero que no es un ZIP', () async {
      final basura = File(path_lib.join(raiz.path, 'basura.zip'))
        ..writeAsBytesSync(List.generate(5000, (i) => i * 7 % 256));
      await esperarRechazo(servicioPara(app).restaurarCopia(basura), MotivoErrorCopiaSeguridad.noEsZip);
      await comprobarIntacto();
    });

    test('ZIP cortado a la mitad', () async {
      final buena = await servicioPara(app).crearCopia();
      await app.cerrar();
      final bytes = await buena.readAsBytes();
      final cortada = File(path_lib.join(raiz.path, 'cortada.zip'))
        ..writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 2));
      await expectLater(servicioPara(app).restaurarCopia(cortada), throwsA(isA<ErrorCopiaSeguridad>()));
      await comprobarIntacto();
    });

    test('BD dentro del ZIP que no es SQLite', () async {
      final zip = _zipEnMemoria(path_lib.join(raiz.path, 'falsa.zip'), {
        'solera_apicola.db': utf8.encode('esto no es una base de datos'),
        'fotos/a.jpg': utf8.encode('foto que no debe llegar'),
      });
      await esperarRechazo(servicioPara(app).restaurarCopia(zip), MotivoErrorCopiaSeguridad.baseDatosNoValida);
      await comprobarIntacto();
    });

    test('BD con cabecera buena pero dañada (comprobación de integridad)', () async {
      final otra = _AppDePrueba(carpetaDatos('otra'), 'solera_apicola.db');
      for (var numero = 0; numero < 400; numero++) {
        await otra.insertar('Registro $numero ${'x' * 50}');
      }
      await otra.cerrar();
      final bytes = File(otra.rutaBaseDatos).readAsBytesSync();
      for (var posicion = 4096; posicion < bytes.length; posicion++) {
        bytes[posicion] = 0xA5;
      }
      final zip = _zipEnMemoria(path_lib.join(raiz.path, 'danada.zip'), {'solera_apicola.db': bytes});
      await esperarRechazo(
        servicioPara(app, comprobarIntegridad: _integridadConFfi).restaurarCopia(zip),
        MotivoErrorCopiaSeguridad.integridadFallida,
      );
      await comprobarIntacto();
    });

    test('entrada con ruta que se sale de la carpeta', () async {
      final otra = _AppDePrueba(carpetaDatos('otra'), 'solera_apicola.db');
      await otra.insertar('X');
      await otra.cerrar();
      final zip = _zipEnMemoria(path_lib.join(raiz.path, 'trampa.zip'), {
        'solera_apicola.db': File(otra.rutaBaseDatos).readAsBytesSync(),
        'fotos/../../fuera.txt': utf8.encode('fuera'),
      });
      await esperarRechazo(servicioPara(app).restaurarCopia(zip), MotivoErrorCopiaSeguridad.rutaPeligrosa);
      expect(File(path_lib.join(raiz.path, 'fuera.txt')).existsSync(), isFalse);
      await comprobarIntacto();
    });

    test('ZIP sin la BD', () async {
      final zip = _zipEnMemoria(path_lib.join(raiz.path, 'sin_bd.zip'), {'fotos/a.jpg': utf8.encode('x')});
      await esperarRechazo(servicioPara(app).restaurarCopia(zip), MotivoErrorCopiaSeguridad.sinBaseDatos);
      await comprobarIntacto();
    });
  });

  group('fallos a mitad', () {
    late _AppDePrueba app;
    late File copia;

    setUp(() async {
      // La copia trae «Copia» y dos fotos: una que pisará a una actual y
      // otra nueva.
      app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('Copia');
      await app.escribirFoto('fotos/comun.jpg', 'comun de la copia');
      await app.escribirFoto('fotos/solo_copia.jpg', 'solo en la copia');
      copia = await servicioPara(app).crearCopia();
      await File(path_lib.join(app.directorioDatos.path, 'fotos/solo_copia.jpg')).delete();
      await app.borrarTodo();
      await app.insertar('Estado actual');
      await app.escribirFoto('fotos/comun.jpg', 'comun actual');
      await app.cerrar();
    });

    Future<void> comprobarEstadoActual() async {
      expect(await app.nombres(), ['Estado actual']);
      expect(await app.leerFoto('fotos/comun.jpg'), 'comun actual');
      expect(await app.leerFoto('fotos/solo_copia.jpg'), isNull);
      expect(await Directory(path_lib.join(app.directorioDatos.path, '.copia_seguridad_en_curso')).exists(), isFalse);
    }

    for (final pasoQueFalla in [
      'cerrada',
      'apartada',
      'base_datos_colocada',
      'extra:fotos/comun.jpg',
      'extras_colocados',
      'preferencias'
    ]) {
      test('falla en «$pasoQueFalla» → vuelve al estado anterior', () async {
        final servicio = servicioPara(app, puntoDeControl: (paso) async {
          if (paso == pasoQueFalla) throw StateError('fallo simulado en $paso');
        });
        await expectLater(
          servicio.restaurarCopia(copia),
          throwsA(isA<ErrorCopiaSeguridad>()
              .having((error) => error.motivo, 'motivo', MotivoErrorCopiaSeguridad.restauracionRevertida)
              .having((error) => error.datosIntactos, 'datosIntactos', isTrue)
              .having((error) => error.respaldoPrevio, 'respaldoPrevio', isNotNull)),
        );
        await comprobarEstadoActual();
      });
    }

    test('falla la copia automática previa → no se toca nada', () async {
      final antes = await _instantanea(app.directorioDatos);
      final servicio = servicioPara(app, puntoDeControl: (paso) async {
        if (paso == 'respaldo') throw StateError('disco lleno (simulado)');
      });
      await esperarRechazo(servicio.restaurarCopia(copia), MotivoErrorCopiaSeguridad.respaldoPrevioFallido);
      await app.cerrar();
      final despues = await _instantanea(app.directorioDatos)
        ..removeWhere((ruta, _) => ruta.startsWith('copias_automaticas'));
      expect(despues, antes);
      await comprobarEstadoActual();
    });

    test('la BD restaurada no abre (migración rota) → vuelve al estado anterior', () async {
      final servicio = servicioPara(app, puntoDeControl: (paso) async {
        if (paso == 'extras_colocados') app.fallosPendientesAlReabrir = 1;
      });
      await esperarRechazo(servicio.restaurarCopia(copia), MotivoErrorCopiaSeguridad.restauracionRevertida);
      await comprobarEstadoActual();
    });

    test('la app muere a mitad → al arrancar se deshace', () async {
      final colocada = Completer<void>();
      final servicioQueSeCuelga = servicioPara(app, puntoDeControl: (paso) async {
        if (paso == 'extra:fotos/comun.jpg') {
          colocada.complete();
          await Completer<void>().future; // nunca sigue: «muere» aquí
        }
      });
      unawaited(servicioQueSeCuelga.restaurarCopia(copia));
      await colocada.future;
      await app.cerrar();
      // A medio camino: BD y foto común ya son las de la copia.
      expect(await app.nombres(), ['Copia']);
      await app.cerrar();

      // «Siguiente arranque»: otra instancia, antes de abrir la BD.
      final servicioAlArrancar = servicioPara(app);
      expect(await servicioAlArrancar.recuperarRestauracionInterrumpida(), isTrue);
      await comprobarEstadoActual();
      expect(await servicioAlArrancar.recuperarRestauracionInterrumpida(), isFalse);
    });
  });

  group('preferencias', () {
    test('se copian y restauran solo las configuradas', () async {
      SharedPreferences.setMockInitialValues({
        'solera_apicola.finca_activa': 3,
        'solera_apicola.modo_oscuro': true,
        'solera_apicola.apiarios_fijados': ['a', 'b'],
        'idioma_app': 'eu',
        'otra_app.algo': 'no va',
        'solera_apicola.backup.ultimo_ms': 1,
      });
      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('X');
      final servicio = servicioPara(app, prefijosPreferencias: ['solera_apicola.'], clavesPreferencias: ['idioma_app']);
      final copia = await servicio.crearCopia();

      final archivo = ZipDecoder().decodeBytes(await copia.readAsBytes());
      final copiadas =
          jsonDecode(utf8.decode(archivo.findFile(nombreEntradaPreferenciasCopia)!.content as List<int>)) as Map;
      expect(copiadas.keys.toSet(), {
        'solera_apicola.finca_activa',
        'solera_apicola.modo_oscuro',
        'solera_apicola.apiarios_fijados',
        'idioma_app',
      });

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setInt('solera_apicola.finca_activa', 9);
      await preferencias.remove('solera_apicola.modo_oscuro');
      await preferencias.setString('idioma_app', 'es');
      await preferencias.setString('otra_app.algo', 'cambiado');
      final ultimaAntes = preferencias.getInt('solera_apicola.backup.ultimo_ms');

      final resultado = await servicio.restaurarCopia(copia);
      expect(resultado.informe.numeroPreferencias, 4);
      expect(preferencias.getInt('solera_apicola.finca_activa'), 3);
      expect(preferencias.getBool('solera_apicola.modo_oscuro'), isTrue);
      expect(preferencias.getStringList('solera_apicola.apiarios_fijados'), ['a', 'b']);
      expect(preferencias.getString('idioma_app'), 'eu');
      expect(preferencias.getString('otra_app.algo'), 'cambiado');
      expect(preferencias.getInt('solera_apicola.backup.ultimo_ms'), ultimaAntes);
    });

    test('sin configurar no se copian ni se tocan al restaurar', () async {
      SharedPreferences.setMockInitialValues({'solera_apicola.finca_activa': 3});
      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('X');

      // Copia con preferencias hecha por una configuración que sí las incluye.
      final conPreferencias = await servicioPara(app, prefijosPreferencias: ['solera_apicola.']).crearCopia();
      final servicioSin = servicioPara(app);
      final sinPreferencias = await servicioSin.crearCopia();
      final archivo = ZipDecoder().decodeBytes(await sinPreferencias.readAsBytes());
      expect(archivo.findFile(nombreEntradaPreferenciasCopia), isNull);

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setInt('solera_apicola.finca_activa', 9);
      final resultado = await servicioSin.restaurarCopia(conPreferencias);
      expect(resultado.informe.numeroPreferencias, 0);
      expect(preferencias.getInt('solera_apicola.finca_activa'), 9);
    });

    test('si falla tras escribir preferencias, vuelven las de antes', () async {
      SharedPreferences.setMockInitialValues({'solera_apicola.finca_activa': 3});
      final app = _AppDePrueba(carpetaDatos('datos'), 'solera_apicola.db');
      await app.insertar('X');
      final copia = await servicioPara(app, prefijosPreferencias: ['solera_apicola.']).crearCopia();
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.remove('solera_apicola.finca_activa');
      await preferencias.setInt('solera_apicola.finca_activa', 9);

      final servicio = servicioPara(app, prefijosPreferencias: ['solera_apicola.'], puntoDeControl: (paso) async {
        if (paso == 'preferencias') throw StateError('fallo simulado');
      });
      await esperarRechazo(servicio.restaurarCopia(copia), MotivoErrorCopiaSeguridad.restauracionRevertida);
      expect(preferencias.getInt('solera_apicola.finca_activa'), 9);
    });
  });
}
