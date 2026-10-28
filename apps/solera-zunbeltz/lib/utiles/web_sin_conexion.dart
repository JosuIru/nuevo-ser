// Lista de ficheros que la versión web guarda en el navegador para abrirse
// sin cobertura (service worker `web/sw_zunbeltz.js`). Puro: lo usa
// `tool/preparar_web_sin_conexion.dart` tras `flutter build web`.
//
// No entra todo el build (43 MB): CanvasKit trae varios motores y cada
// navegador usa uno. Se guarda siempre el general (Safari, Firefox: es el
// del iPhone); el de Chrome (`canvaskit/chromium/`) lo guarda el service
// worker cuando la página le dice que lo ha cargado.

import 'dart:convert' show utf8;

import 'package:crypto/crypto.dart' show sha256;

/// Marcas del service worker que se rellenan al preparar el build.
const marcaVersionSinConexion = '__VERSION_SIN_CONEXION__';
const marcaFicherosSinConexion = '/*FICHEROS_SIN_CONEXION*/[]';

/// ¿Se guarda [rutaRelativa] (relativa a la carpeta del build, con `/`)
/// al instalar el service worker?
bool ficheroEntraEnPrecache(String rutaRelativa) {
  final ruta = rutaRelativa.replaceAll('\\', '/');
  if (ruta.startsWith('canvaskit/')) {
    return ruta == 'canvaskit/canvaskit.js' ||
        ruta == 'canvaskit/canvaskit.wasm';
  }
  if (ruta.endsWith('.symbols') || ruta.endsWith('.map')) return false;
  const fuera = {
    'sw_zunbeltz.js',
    // El de Flutter está obsoleto y se borra a sí mismo; no se registra.
    'flutter_service_worker.js',
    'version.json',
    '.last_build_id',
  };
  return !fuera.contains(ruta);
}

/// Ficheros a guardar, ordenados.
List<String> ficherosPrecache(Iterable<String> rutasRelativas) =>
    (rutasRelativas.where(ficheroEntraEnPrecache).toList()..sort());

/// Versión del caché: cambia si cambia cualquier fichero guardado o el
/// motor (CanvasKit), así cada build nuevo instala un caché nuevo.
/// [contenidos] es ruta → bytes de todo el build.
String versionSinConexion(Map<String, List<int>> contenidos) {
  final rutas = contenidos.keys
      .where((ruta) =>
          ficheroEntraEnPrecache(ruta) || ruta.startsWith('canvaskit/'))
      .where((ruta) => !ruta.endsWith('.symbols'))
      .toList()
    ..sort();
  final resumen = StringBuffer();
  for (final ruta in rutas) {
    resumen
      ..write(ruta)
      ..write(':')
      ..write(sha256.convert(contenidos[ruta]!))
      ..write('\n');
  }
  return sha256
      .convert(utf8.encode(resumen.toString()))
      .toString()
      .substring(0, 16);
}

/// El service worker con la versión y la lista puestas. Falla si la
/// plantilla no trae las dos marcas (para no publicar uno a medias).
String rellenarServiceWorker(
    String plantilla, String version, List<String> ficheros) {
  if (!plantilla.contains(marcaVersionSinConexion) ||
      !plantilla.contains(marcaFicherosSinConexion)) {
    throw StateError('La plantilla del service worker no trae sus marcas');
  }
  final lista =
      '[\n${ficheros.map((f) => "  '${f.replaceAll("'", "\\'")}',").join('\n')}\n]';
  return plantilla
      .replaceAll(marcaVersionSinConexion, version)
      .replaceAll(marcaFicherosSinConexion, lista);
}
