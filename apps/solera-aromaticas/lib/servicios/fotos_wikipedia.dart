// Fotos de la guía de especies, de Wikipedia / Wikimedia Commons (adaptado
// de la guía de Fósiles, cuadernos-de-campo).
//
// HARD LIMIT: solo se piden y se muestran IMÁGENES. Nunca el texto del
// artículo: muchos artículos de plantas aromáticas hablan de usos de salud
// y la app no puede mostrarlos (test/hard_limits_test.dart no ve lo que
// llega de la red).
//
// Las URL se guardan en un JSON en el directorio de la app para que la
// lista vuelva a salir sin conexión; las imágenes las cachea
// cached_network_image.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as ruta;
import 'package:path_provider/path_provider.dart';

/// Wikimedia pide identificar al cliente; sin User-Agent responde 403.
const Map<String, String> cabecerasWikimedia = {
  'User-Agent':
      'larrea-aromaticas/0.1 (https://coleccion-nuevo-ser.com; guía de especies)',
};

/// Busca las fotos de un artículo de Wikipedia. Se inyecta en la pantalla
/// para que los tests no salgan a la red.
typedef BuscadorFotos = Future<List<String>> Function(String tituloWikipedia);

/// Buscador que usa la guía cuando no se le pasa otro. Los tests lo
/// cambian para no salir a la red.
BuscadorFotos buscadorFotosGuia = buscarFotosWikipedia;

final Map<String, Future<List<String>>> _fotosEnMemoria = {};
Map<String, dynamic>? _fotosEnDisco;

Future<File> _ficheroCache() async {
  final directorio = await getApplicationDocumentsDirectory();
  return File(ruta.join(directorio.path, 'guia_fotos_wikipedia.json'));
}

Future<Map<String, dynamic>> _leerDisco() async {
  if (_fotosEnDisco != null) return _fotosEnDisco!;
  try {
    final fichero = await _ficheroCache();
    if (await fichero.exists()) {
      _fotosEnDisco =
          jsonDecode(await fichero.readAsString()) as Map<String, dynamic>;
      return _fotosEnDisco!;
    }
  } catch (_) {}
  return _fotosEnDisco = {};
}

Future<void> _guardarDisco() async {
  try {
    await (await _ficheroCache()).writeAsString(jsonEncode(_fotosEnDisco));
  } catch (_) {}
}

/// Fotos del artículo [tituloWikipedia] (primero en español, luego en
/// inglés). Lista vacía si no hay conexión ni copia guardada.
Future<List<String>> buscarFotosWikipedia(String tituloWikipedia) {
  final enMemoria = _fotosEnMemoria[tituloWikipedia];
  if (enMemoria != null) return enMemoria;
  final futuro = _buscarConCache(tituloWikipedia);
  _fotosEnMemoria[tituloWikipedia] = futuro;
  // Si sale vacía, se puede volver a intentar (reintentar en la ficha).
  futuro.then((fotos) {
    if (fotos.isEmpty) _fotosEnMemoria.remove(tituloWikipedia);
  });
  return futuro;
}

Future<List<String>> _buscarConCache(String tituloWikipedia) async {
  final disco = await _leerDisco();
  final guardadas = (disco[tituloWikipedia] as List?)?.cast<String>() ?? [];
  if (guardadas.isNotEmpty) return guardadas;
  final descargadas = await _descargarFotos(tituloWikipedia);
  if (descargadas.isNotEmpty) {
    disco[tituloWikipedia] = descargadas;
    await _guardarDisco();
  }
  return descargadas;
}

/// Peticiones a Wikipedia en curso como mucho a la vez: al abrir la guía
/// se piden las miniaturas de todas las especies y, en ráfaga, Wikimedia
/// responde 429.
const int _maximoPeticionesSimultaneas = 2;
int _peticionesEnCurso = 0;
final List<Completer<void>> _peticionesEnEspera = [];

Future<T> _conTurno<T>(Future<T> Function() tarea) async {
  if (_peticionesEnCurso >= _maximoPeticionesSimultaneas) {
    final turno = Completer<void>();
    _peticionesEnEspera.add(turno);
    await turno.future;
  }
  _peticionesEnCurso++;
  try {
    return await tarea();
  } finally {
    _peticionesEnCurso--;
    if (_peticionesEnEspera.isNotEmpty) {
      _peticionesEnEspera.removeAt(0).complete();
    }
  }
}

Future<Map<String, dynamic>?> _pedirJson(Uri direccion) async {
  try {
    final respuesta = await _conTurno(() => http
        .get(direccion, headers: cabecerasWikimedia)
        .timeout(const Duration(seconds: 10)));
    if (respuesta.statusCode != 200) return null;
    return jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

/// Descarta logos, mapas y dibujos vectoriales: en la guía interesan fotos.
bool esFotoUtil(String direccion) {
  final minusculas = direccion.toLowerCase();
  const descartes = [
    '.svg',
    '.pdf',
    '.djvu',
    '.tif',
    'commons-logo',
    'wiktionary',
    'wikispecies',
    'distribution',
    'map_',
    '_map',
  ];
  return !descartes.any(minusculas.contains);
}

Future<List<String>> _descargarFotos(String tituloWikipedia) async {
  final titulo = Uri.encodeComponent(tituloWikipedia.replaceAll(' ', '_'));
  for (final idioma in const ['es', 'en']) {
    final json = await _pedirJson(Uri.parse(
        'https://$idioma.wikipedia.org/api/rest_v1/page/media-list/$titulo'));
    if (json == null) continue;
    final fotos = <String>{};
    for (final elemento in (json['items'] as List?) ?? const []) {
      if (elemento is! Map || elemento['type'] != 'image') continue;
      if (elemento['showInGallery'] == false) continue;
      final tamanos = (elemento['srcset'] as List?) ?? const [];
      if (tamanos.isEmpty) continue;
      final origen = (tamanos.first as Map?)?['src']?.toString() ?? '';
      if (origen.isEmpty || !esFotoUtil(origen)) continue;
      fotos.add(origen.startsWith('//') ? 'https:$origen' : origen);
      if (fotos.length >= 8) break;
    }
    if (fotos.isNotEmpty) return fotos.toList();
  }
  return const [];
}
