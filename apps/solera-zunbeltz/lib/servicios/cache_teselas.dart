/// Caché en disco de las teselas del mapa, para que en el monte, sin
/// cobertura, se vea lo que ya se vio (y lo que se bajó a propósito).
///
/// **Por qué una caché propia y no un paquete.** Se miraron los dos que hay
/// para flutter_map 7:
/// - `flutter_map_tile_caching` hace todo (también la descarga por zonas),
///   pero es GPL-3 (o licencia de pago) y arrastra ObjectBox nativo: no
///   encaja en una app que se entrega a terceros.
/// - `flutter_map_cache` + `dio_cache_interceptor` mete Dio solo para esto,
///   sus almacenes en fichero no tienen tope de tamaño ni una parte que no
///   se expulse, y sin red sirve de caché solo después de que la petición
///   falle (esperando a cada tesela), que es justo lo que hay que evitar.
/// Lo que hace falta cabe en poco: ficheros `z/x/y` en dos carpetas
/// («vista», con tope y expulsión de lo más antiguo, y «descargadas», que
/// nunca se expulsa), caducidad larga que sin red no impide servir, y un
/// cortocircuito cuando la red no está. Usa `http`, que ya estaba.
///
/// Sin Flutter (se prueba con un cliente HTTP falso); el `TileProvider` que
/// lo enchufa al mapa está en `proveedor_teselas_cacheadas.dart`. En web no
/// se usa: allí el mapa va con la caché del navegador.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path_lib;

import '../utiles/cola_descarga_teselas.dart';
import '../utiles/teselas_mapa.dart';

/// Tope de lo guardado «según se ve». Lo descargado a propósito no cuenta.
const int topeBytesCacheVista = 200 * 1024 * 1024;

/// Pasado este tiempo, una tesela guardada se vuelve a pedir si hay red
/// (las ortofotos se renuevan cada pocos años). Sin red se sirve igual.
const Duration caducidadTeselas = Duration(days: 90);

/// Una tesela leída del disco.
class TeselaGuardada {
  const TeselaGuardada({
    required this.bytes,
    required this.guardadaEn,
    required this.descargada,
  });

  final Uint8List bytes;
  final DateTime guardadaEn;

  /// Está en la carpeta de lo descargado a propósito (no se expulsa).
  final bool descargada;
}

/// Lo que ocupa la caché.
class TamanoCacheTeselas {
  const TamanoCacheTeselas({
    this.bytesVista = 0,
    this.teselasVista = 0,
    this.bytesDescargadas = 0,
    this.teselasDescargadas = 0,
  });

  final int bytesVista;
  final int teselasVista;
  final int bytesDescargadas;
  final int teselasDescargadas;
}

/// Ficheros de teselas: `<raíz>/vista/<capa>/<z>/<x>/<y>` y
/// `<raíz>/descargadas/<capa>/<z>/<x>/<y>`.
class AlmacenTeselas {
  AlmacenTeselas(
    Future<Directory> Function() raiz, {
    this.topeBytesVista = topeBytesCacheVista,
    this.caducidad = caducidadTeselas,
    DateTime Function()? reloj,
  })  : _obtenerRaiz = raiz,
        reloj = reloj ?? DateTime.now;

  final Future<Directory> Function() _obtenerRaiz;
  final int topeBytesVista;
  final Duration caducidad;
  final DateTime Function() reloj;

  Future<Directory>? _raiz;
  Future<int>? _bytesVistaMedidos;
  int _bytesVista = 0;
  Future<void>? _expulsando;
  int _escrituras = 0;

  Future<Directory> get raiz => _raiz ??= _obtenerRaiz();

  Future<String> _ruta(String carpeta, String capa, TeselaXYZ tesela) async =>
      path_lib.join((await raiz).path, carpeta, capa, '${tesela.z}',
          '${tesela.x}', '${tesela.y}');

  bool caducada(TeselaGuardada tesela) =>
      reloj().difference(tesela.guardadaEn) > caducidad;

  /// La tesela guardada (primero lo descargado, luego lo visto), o null.
  Future<TeselaGuardada?> leer(String capa, TeselaXYZ tesela) async {
    for (final descargada in [true, false]) {
      final fichero =
          File(await _ruta(descargada ? 'descargadas' : 'vista', capa, tesela));
      try {
        final bytes = await fichero.readAsBytes();
        if (bytes.isEmpty) continue;
        return TeselaGuardada(
          bytes: bytes,
          guardadaEn: await fichero.lastModified(),
          descargada: descargada,
        );
      } on FileSystemException {
        continue;
      }
    }
    return null;
  }

  /// ¿Está ya descargada a propósito y sin caducar? (para reanudar una
  /// descarga sin volver a bajar lo que ya está).
  Future<bool> tieneDescargadaVigente(String capa, TeselaXYZ tesela) async {
    final fichero = File(await _ruta('descargadas', capa, tesela));
    try {
      final modificada = await fichero.lastModified();
      return reloj().difference(modificada) <= caducidad &&
          await fichero.length() > 0;
    } on FileSystemException {
      return false;
    }
  }

  /// Guarda una tesela. Con [descargada], en la carpeta que no se expulsa
  /// (y se quita la copia de «vista», si la había).
  Future<void> guardar(String capa, TeselaXYZ tesela, Uint8List bytes,
      {bool descargada = false}) async {
    final ruta =
        await _ruta(descargada ? 'descargadas' : 'vista', capa, tesela);
    final fichero = File(ruta);
    await fichero.parent.create(recursive: true);
    if (!descargada) await _medirVista();
    final anterior = await _longitudSiExiste(fichero);
    // Escribir aparte y renombrar: si la app se cierra a medias no queda
    // una tesela rota que luego se sirva como buena.
    final temporal = File('$ruta.${_escrituras++}.tmp');
    await temporal.writeAsBytes(bytes, flush: true);
    await temporal.rename(ruta);
    if (descargada) {
      final copiaVista = File(await _ruta('vista', capa, tesela));
      final longitudVista = await _longitudSiExiste(copiaVista);
      if (longitudVista > 0) {
        await _medirVista();
        try {
          await copiaVista.delete();
          _bytesVista -= longitudVista;
        } on FileSystemException {
          // Si no se puede borrar, se quedará hasta que la expulsen.
        }
      }
      return;
    }
    _bytesVista += bytes.length - anterior;
    if (_bytesVista > topeBytesVista) await _expulsarLoMasAntiguo();
  }

  Future<int> _longitudSiExiste(File fichero) async {
    try {
      return await fichero.length();
    } on FileSystemException {
      return 0;
    }
  }

  Future<void> _medirVista() async {
    _bytesVistaMedidos ??= () async {
      var total = 0;
      await for (final fichero in _ficheros('vista')) {
        total += fichero.$2.size;
      }
      _bytesVista = total;
      return total;
    }();
    await _bytesVistaMedidos;
  }

  Stream<(File, FileStat)> _ficheros(String carpeta) async* {
    final directorio = Directory(path_lib.join((await raiz).path, carpeta));
    if (!await directorio.exists()) return;
    await for (final entrada
        in directorio.list(recursive: true, followLinks: false)) {
      if (entrada is! File || entrada.path.endsWith('.tmp')) continue;
      final estado = await entrada.stat();
      yield (entrada, estado);
    }
  }

  /// Borra lo más antiguo de «vista» hasta dejarla en el 90 % del tope
  /// (para no tener que recorrerla en cada tesela nueva).
  Future<void> _expulsarLoMasAntiguo() {
    return _expulsando ??= () async {
      try {
        final ficheros = await _ficheros('vista').toList();
        ficheros.sort((a, b) => a.$2.modified.compareTo(b.$2.modified));
        var total = ficheros.fold<int>(0, (suma, f) => suma + f.$2.size);
        final objetivo = (topeBytesVista * 0.9).floor();
        for (final (fichero, estado) in ficheros) {
          if (total <= objetivo) break;
          try {
            await fichero.delete();
            total -= estado.size;
          } on FileSystemException {
            continue;
          }
        }
        _bytesVista = total;
      } finally {
        _expulsando = null;
      }
    }();
  }

  Future<TamanoCacheTeselas> tamano() async {
    var bytesVista = 0, teselasVista = 0;
    var bytesDescargadas = 0, teselasDescargadas = 0;
    await for (final f in _ficheros('vista')) {
      bytesVista += f.$2.size;
      teselasVista++;
    }
    await for (final f in _ficheros('descargadas')) {
      bytesDescargadas += f.$2.size;
      teselasDescargadas++;
    }
    return TamanoCacheTeselas(
      bytesVista: bytesVista,
      teselasVista: teselasVista,
      bytesDescargadas: bytesDescargadas,
      teselasDescargadas: teselasDescargadas,
    );
  }

  Future<void> borrarVista() => _borrarCarpeta('vista').then((_) {
        _bytesVista = 0;
        _bytesVistaMedidos = Future.value(0);
      });

  Future<void> borrarDescargadas() => _borrarCarpeta('descargadas');

  Future<void> _borrarCarpeta(String carpeta) async {
    final directorio = Directory(path_lib.join((await raiz).path, carpeta));
    if (await directorio.exists()) await directorio.delete(recursive: true);
  }
}

/// Una tesela que pide el mapa: de qué capa, cuál, de dónde se baja y, si
/// la capa tiene respaldo (la ortofoto de Esri cuando el IGN falla), de
/// dónde se baja el respaldo.
class PeticionTesela {
  const PeticionTesela({
    required this.capa,
    required this.tesela,
    required this.url,
    this.cabeceras = const {},
    this.capaRespaldo,
    this.urlRespaldo,
  });

  final String capa;
  final TeselaXYZ tesela;
  final String url;
  final Map<String, String> cabeceras;
  final String? capaRespaldo;
  final String? urlRespaldo;
}

/// No hay tesela que enseñar: ni guardada ni la red la da. El mapa deja
/// ese hueco y la vuelve a pedir cuando sale de la pantalla y vuelve.
class TeselaNoDisponible implements Exception {
  const TeselaNoDisponible(this.tesela);
  final TeselaXYZ tesela;
  @override
  String toString() => 'TeselaNoDisponible($tesela)';
}

/// Resultado de una petición a la red: o los bytes de una imagen, o por
/// qué no.
class _Respuesta {
  const _Respuesta.imagen(Uint8List this.bytes)
      : estado = 200,
        corteDeRed = false;
  const _Respuesta.fallo({this.estado, this.corteDeRed = false}) : bytes = null;

  final Uint8List? bytes;
  final int? estado;

  /// No se llegó al servidor (sin red, tiempo agotado, DNS…).
  final bool corteDeRed;
}

/// ¿Son estos bytes una imagen que el mapa sepa pintar? (JPEG, PNG, WebP).
/// Así no se guarda una página de error servida con un 200.
bool pareceImagenDeTesela(Uint8List bytes) {
  if (bytes.length < 8) return false;
  final esJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
  final esPng = bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E;
  final esWebp = bytes.length >= 12 &&
      bytes[0] == 0x52 && // R
      bytes[1] == 0x49 && // I
      bytes[8] == 0x57 && // W
      bytes[9] == 0x45; // E
  return esJpeg || esPng || esWebp;
}

/// Decide de dónde sale cada tesela: del disco, de la red o del respaldo.
///
/// - Guardada y sin caducar: del disco, sin tocar la red.
/// - Sin red ([hayConexion] dice que no, o la red se cortó hace poco): del
///   disco aunque esté caducada, o la del respaldo si es lo que hay; sin
///   esperar a ningún tiempo agotado y sin probar el respaldo por la red.
/// - Con red: se pide; si falla, mejor la guardada caducada que otra
///   imagen; si no hay, el respaldo (una vez). Si una capa falla
///   [fallosParaDarCapaPorCaida] veces seguidas, se salta durante
///   [pausaCapaCaida] y se va directo al respaldo.
class ObtenedorTeselas {
  ObtenedorTeselas({
    required this.almacen,
    required this.cliente,
    required this.hayConexion,
    this.tiempoMaximo = const Duration(seconds: 12),
    this.pausaTrasCorte = const Duration(seconds: 30),
    this.pausaCapaCaida = const Duration(minutes: 2),
    this.fallosParaDarCapaPorCaida = 3,
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;

  final AlmacenTeselas almacen;
  final http.Client cliente;
  final Future<bool> Function() hayConexion;
  final Duration tiempoMaximo;
  final Duration pausaTrasCorte;
  final Duration pausaCapaCaida;
  final int fallosParaDarCapaPorCaida;
  final DateTime Function() reloj;

  DateTime? _redCortadaHasta;
  final Map<String, int> _fallosSeguidosPorCapa = {};
  final Map<String, DateTime> _capaCaidaHasta = {};
  final Map<String, Future<Uint8List>> _enCurso = {};

  /// La red ha cambiado (p. ej. ha vuelto la cobertura): se olvidan los
  /// cortes anotados para volver a intentarlo ya.
  void olvidarCortes() {
    _redCortadaHasta = null;
    _capaCaidaHasta.clear();
    _fallosSeguidosPorCapa.clear();
  }

  /// ¿Se considera ahora mismo que no hay red?
  bool get redCortada {
    final hasta = _redCortadaHasta;
    return hasta != null && reloj().isBefore(hasta);
  }

  Future<bool> _redDisponible() async {
    if (redCortada) return false;
    try {
      return await hayConexion();
    } catch (_) {
      return true; // ante la duda, se intenta (con su tiempo máximo)
    }
  }

  Future<Uint8List> obtener(PeticionTesela peticion) {
    final clave = '${peticion.capa}/${peticion.tesela}';
    // Ojo: el callback no puede devolver lo que quita del mapa (el propio
    // future): whenComplete lo esperaría y se esperaría a sí mismo.
    return _enCurso[clave] ??= _obtener(peticion).whenComplete(() {
      _enCurso.remove(clave);
    });
  }

  Future<Uint8List> _obtener(PeticionTesela peticion) async {
    final guardada = await almacen.leer(peticion.capa, peticion.tesela);
    if (guardada != null && !almacen.caducada(guardada)) {
      return guardada.bytes;
    }
    final capaRespaldo = peticion.capaRespaldo;
    final urlRespaldo = peticion.urlRespaldo;
    final hayRespaldo = capaRespaldo != null && urlRespaldo != null;

    if (!await _redDisponible()) {
      if (guardada != null) return guardada.bytes;
      if (hayRespaldo) {
        final delRespaldo = await almacen.leer(capaRespaldo, peticion.tesela);
        if (delRespaldo != null) return delRespaldo.bytes;
      }
      throw TeselaNoDisponible(peticion.tesela);
    }

    var corteEnPrincipal = false;
    if (!_capaCaida(peticion.capa)) {
      final respuesta = await _pedir(peticion.url, peticion.cabeceras);
      final bytes = respuesta.bytes;
      if (bytes != null) {
        _fallosSeguidosPorCapa.remove(peticion.capa);
        await _guardarSinFallar(peticion.capa, peticion.tesela, bytes,
            descargada: guardada?.descargada ?? false);
        return bytes;
      }
      corteEnPrincipal = respuesta.corteDeRed;
      if (corteEnPrincipal && !hayRespaldo) _anotarCorteDeRed();
      _anotarFalloDeCapa(peticion.capa);
    }
    if (guardada != null) return guardada.bytes;
    if (!hayRespaldo || redCortada) throw TeselaNoDisponible(peticion.tesela);

    final delRespaldo = await almacen.leer(capaRespaldo, peticion.tesela);
    if (delRespaldo != null && !almacen.caducada(delRespaldo)) {
      return delRespaldo.bytes;
    }
    final respuesta = await _pedir(urlRespaldo, peticion.cabeceras);
    final bytes = respuesta.bytes;
    if (bytes != null) {
      await _guardarSinFallar(capaRespaldo, peticion.tesela, bytes);
      return bytes;
    }
    // Ni la principal ni el respaldo llegan al servidor: es la red.
    if (respuesta.corteDeRed && corteEnPrincipal) _anotarCorteDeRed();
    if (delRespaldo != null) return delRespaldo.bytes;
    throw TeselaNoDisponible(peticion.tesela);
  }

  /// Baja una tesela para guardarla a propósito (la descarga de las
  /// fincas). No mira la caché ni el respaldo: eso lo decide quien llama.
  Future<ResultadoIntentoTesela> bajarYGuardar(
      String capa, TeselaXYZ tesela, String url,
      {Map<String, String> cabeceras = const {}}) async {
    final respuesta = await _pedir(url, cabeceras);
    final bytes = respuesta.bytes;
    if (bytes != null) {
      await almacen.guardar(capa, tesela, bytes, descargada: true);
      return ResultadoIntentoTesela.hecha;
    }
    final estado = respuesta.estado;
    if (respuesta.corteDeRed ||
        estado == null ||
        estado == 408 ||
        estado == 429 ||
        estado >= 500) {
      return ResultadoIntentoTesela.reintentable;
    }
    return ResultadoIntentoTesela.definitivo;
  }

  bool _capaCaida(String capa) {
    final hasta = _capaCaidaHasta[capa];
    return hasta != null && reloj().isBefore(hasta);
  }

  void _anotarFalloDeCapa(String capa) {
    final fallos = (_fallosSeguidosPorCapa[capa] ?? 0) + 1;
    _fallosSeguidosPorCapa[capa] = fallos;
    if (fallos >= fallosParaDarCapaPorCaida) {
      _capaCaidaHasta[capa] = reloj().add(pausaCapaCaida);
      _fallosSeguidosPorCapa.remove(capa);
    }
  }

  void _anotarCorteDeRed() => _redCortadaHasta = reloj().add(pausaTrasCorte);

  Future<void> _guardarSinFallar(String capa, TeselaXYZ tesela, Uint8List bytes,
      {bool descargada = false}) async {
    try {
      await almacen.guardar(capa, tesela, bytes, descargada: descargada);
    } catch (_) {
      // Disco lleno o sin permiso: la tesela se enseña igual.
    }
  }

  Future<_Respuesta> _pedir(String url, Map<String, String> cabeceras) async {
    try {
      final respuesta = await cliente
          .get(Uri.parse(url), headers: cabeceras)
          .timeout(tiempoMaximo);
      if (respuesta.statusCode == 200 &&
          pareceImagenDeTesela(respuesta.bodyBytes)) {
        return _Respuesta.imagen(respuesta.bodyBytes);
      }
      return _Respuesta.fallo(estado: respuesta.statusCode);
    } on TimeoutException {
      return const _Respuesta.fallo(corteDeRed: true);
    } on SocketException {
      return const _Respuesta.fallo(corteDeRed: true);
    } on HandshakeException {
      return const _Respuesta.fallo(corteDeRed: true);
    } on http.ClientException {
      return const _Respuesta.fallo(corteDeRed: true);
    } catch (_) {
      return const _Respuesta.fallo();
    }
  }
}

/// Recuerda la respuesta de [comprobar] durante [vigencia], para no
/// preguntar al sistema por la red en cada una de las decenas de teselas
/// que pide el mapa a la vez.
class RespuestaConVigencia<T> {
  RespuestaConVigencia(this.comprobar,
      {this.vigencia = const Duration(seconds: 3), DateTime Function()? reloj})
      : reloj = reloj ?? DateTime.now;

  final Future<T> Function() comprobar;
  final Duration vigencia;
  final DateTime Function() reloj;

  Future<T>? _ultima;
  DateTime _cuando = DateTime.fromMillisecondsSinceEpoch(0);

  Future<T> call() {
    final ahora = reloj();
    if (_ultima == null || ahora.difference(_cuando) > vigencia) {
      _cuando = ahora;
      _ultima = comprobar();
    }
    return _ultima!;
  }

  void olvidar() => _ultima = null;
}

/// Tamaño legible: «850 KB», «12,4 MB».
String tamanoLegible(int bytes, {String separadorDecimal = ','}) {
  if (bytes < 1024 * 1024) {
    return '${math.max(0, (bytes / 1024).round())} KB';
  }
  final megas = bytes / (1024 * 1024);
  final texto = megas >= 100
      ? megas.round().toString()
      : megas.toStringAsFixed(1).replaceAll('.', separadorDecimal);
  return '$texto MB';
}
