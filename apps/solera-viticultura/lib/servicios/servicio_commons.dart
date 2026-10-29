import 'dart:convert';

import 'package:http/http.dart' as http;

/// Imagen de Wikimedia Commons con metadatos de licencia y atribución.
/// Larrea la mostrará SIEMPRE con su pie de atribución visible
/// (autor + licencia) — esa es la condición que las licencias CC y
/// equivalentes exigen para uso comercial.
class ImagenCommons {
  /// URL de la versión thumb (típicamente 600 px).
  final String urlThumb;

  /// URL de la página de descripción del archivo en Commons (para que
  /// el usuario pueda ver detalles, otras versiones, autor extendido).
  final String urlPaginaDescripcion;

  /// Nombre del autor declarado en `extmetadata.Artist` (puede contener
  /// HTML — por eso `autorTexto` lo viene ya plano).
  final String autorTexto;

  /// Nombre corto de la licencia ('CC BY-SA 4.0', 'CC0', 'public domain').
  final String licenciaCorta;

  /// URL canónica de la licencia (Creative Commons publica una para
  /// cada variante; algunas dominio-público no tienen URL).
  final String? urlLicencia;

  ImagenCommons({
    required this.urlThumb,
    required this.urlPaginaDescripcion,
    required this.autorTexto,
    required this.licenciaCorta,
    this.urlLicencia,
  });
}

/// Licencias permitidas en producción comercial.
///
/// La regla: **solo licencias CC con atribución soportada** (CC BY,
/// CC BY-SA, CC0, dominio público). Excluimos:
/// - Non-Free / fair-use (no permite redistribución).
/// - GFDL-only sin variante CC (pesado de cumplir, mejor evitar).
/// - Cualquier *NonCommercial* (incompatible con producto comercial).
///
/// La verificación es por **prefijo** del campo `LicenseShortName` que
/// devuelve la API de Commons.
const Set<String> _licenciasPrefijosPermitidos = {
  'CC0',
  'PD', // Public Domain
  'Public domain',
  'CC BY',
  'CC-BY',
  'cc by',
  'cc-by',
};

const Set<String> _licenciasPrefijosBloqueados = {
  'CC BY-NC',
  'CC-BY-NC',
  'cc by-nc',
  'cc-by-nc',
  'CC BY-ND',
  'CC-BY-ND',
  'GFDL',
  'Non-free',
  'Fair use',
  'fair use',
  'Copyrighted',
};

bool _licenciaPermitida(String? licenciaCorta) {
  if (licenciaCorta == null || licenciaCorta.isEmpty) return false;
  for (final bloqueada in _licenciasPrefijosBloqueados) {
    if (licenciaCorta.startsWith(bloqueada)) return false;
  }
  for (final permitida in _licenciasPrefijosPermitidos) {
    if (licenciaCorta.startsWith(permitida)) return true;
  }
  return false;
}

/// Caché en memoria por término de búsqueda. La caché en disco la lleva
/// `cached_network_image` cuando la URL se renderiza en una imagen.
final Map<String, Future<ImagenCommons?>> _cache = {};

const _cabeceras = {
  'User-Agent': 'solera-agro/1.0 (https://github.com/josu/solera-agro)',
};

/// Busca una imagen libre en Commons cuya licencia sea compatible con
/// uso comercial. Estrategia:
///
/// 1) Pide a la Wikipedia (es/en) la imagen principal del artículo
///    `tituloWikipedia`. El artículo de un cultivo (Olea europaea,
///    Tuber melanosporum, Pistacia vera) suele tener una foto
///    representativa como lead image.
/// 2) Comprueba la licencia consultando `imageinfo+extmetadata` del
///    archivo concreto. Si no es compatible (ej. lead vía fair-use),
///    cae al siguiente candidato.
/// 3) Si Wikipedia falla o devuelve mapa de distribución, hace búsqueda
///    libre en Commons por el término científico.
///
/// Devuelve `null` si no encuentra ninguna imagen con licencia
/// compatible — la app cae al placeholder genérico (icono del cultivo).
Future<ImagenCommons?> buscarImagenLibreParaCultivo(String tituloWikipedia, {String? termino}) {
  final clave = 'cultivo|$tituloWikipedia|${termino ?? ''}';
  return _cache.putIfAbsent(clave, () => _buscarImagenInterno(tituloWikipedia, termino));
}

Future<ImagenCommons?> _buscarImagenInterno(String tituloWikipedia, String? termino) async {
  // 1) Lead image del artículo, en es y luego en.
  for (final idioma in const ['es', 'en']) {
    final foto = await _leadImageDeArticulo(idioma, tituloWikipedia);
    if (foto != null) return foto;
  }
  // 2) Búsqueda libre en Commons por término científico (más fiable
  //    que el nombre común para taxones).
  if (termino != null && termino.isNotEmpty) {
    final foto = await _busquedaCommons(termino);
    if (foto != null) return foto;
  }
  return null;
}

Future<ImagenCommons?> _leadImageDeArticulo(String idioma, String titulo) async {
  try {
    final uri = Uri.parse(
      'https://$idioma.wikipedia.org/w/api.php'
      '?action=query&format=json&titles=${Uri.encodeComponent(titulo)}'
      '&prop=pageimages|pageprops&pithumbsize=600&redirects=1',
    );
    final respuesta = await http.get(uri, headers: _cabeceras).timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    final pages = ((json['query'] as Map?)?['pages'] as Map?)?.values ?? const [];
    for (final pagina in pages) {
      if (pagina is! Map) continue;
      final fileTitle = pagina['pageimage'] as String?;
      if (fileTitle == null) continue;
      // Pedimos los metadatos de licencia del archivo concreto.
      final foto = await _imagenInfoDeArchivo('File:$fileTitle');
      if (foto != null) return foto;
    }
  } catch (_) {}
  return null;
}

Future<ImagenCommons?> _busquedaCommons(String termino) async {
  try {
    final uri = Uri.parse(
      'https://commons.wikimedia.org/w/api.php'
      '?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=8'
      '&prop=imageinfo&iiprop=url|extmetadata&iiurlwidth=600'
      '&gsrsearch=${Uri.encodeComponent(termino)}',
    );
    final respuesta = await http.get(uri, headers: _cabeceras).timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    final pages = ((json['query'] as Map?)?['pages'] as Map?)?.values ?? const [];
    for (final pagina in pages) {
      if (pagina is! Map) continue;
      final infos = (pagina['imageinfo'] as List?) ?? const [];
      for (final info in infos) {
        if (info is! Map) continue;
        final foto = _construirDesdeImagenInfo(info, pagina['title']?.toString() ?? '');
        if (foto != null) return foto;
      }
    }
  } catch (_) {}
  return null;
}

Future<ImagenCommons?> _imagenInfoDeArchivo(String tituloArchivo) async {
  try {
    final uri = Uri.parse(
      'https://commons.wikimedia.org/w/api.php'
      '?action=query&format=json&titles=${Uri.encodeComponent(tituloArchivo)}'
      '&prop=imageinfo&iiprop=url|extmetadata&iiurlwidth=600&redirects=1',
    );
    final respuesta = await http.get(uri, headers: _cabeceras).timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    final pages = ((json['query'] as Map?)?['pages'] as Map?)?.values ?? const [];
    for (final pagina in pages) {
      if (pagina is! Map) continue;
      final infos = (pagina['imageinfo'] as List?) ?? const [];
      for (final info in infos) {
        if (info is! Map) continue;
        final foto = _construirDesdeImagenInfo(info, pagina['title']?.toString() ?? tituloArchivo);
        if (foto != null) return foto;
      }
    }
  } catch (_) {}
  return null;
}

ImagenCommons? _construirDesdeImagenInfo(Map info, String tituloArchivo) {
  final extmetadata = info['extmetadata'];
  if (extmetadata is! Map) return null;
  final licenciaCorta = (extmetadata['LicenseShortName'] as Map?)?['value']?.toString();
  if (!_licenciaPermitida(licenciaCorta)) return null;
  final urlThumb = (info['thumburl'] ?? info['url'])?.toString();
  if (urlThumb == null || urlThumb.isEmpty) return null;
  if (_pareceMapaDistribucion(urlThumb)) return null;
  if (_pareceLogo(urlThumb)) return null;
  final autor = _extraerTextoPlano(extmetadata['Artist']) ?? 'Autor desconocido';
  final urlLicencia = (extmetadata['LicenseUrl'] as Map?)?['value']?.toString();
  return ImagenCommons(
    urlThumb: urlThumb,
    urlPaginaDescripcion: 'https://commons.wikimedia.org/wiki/${Uri.encodeComponent(tituloArchivo)}',
    autorTexto: autor.trim(),
    licenciaCorta: licenciaCorta!,
    urlLicencia: urlLicencia,
  );
}

/// `Artist` viene como HTML (con `<a>` y `<span>`). Quitamos tags y
/// devolvemos sólo texto plano. Si el HTML está vacío después,
/// devolvemos null.
String? _extraerTextoPlano(dynamic campo) {
  if (campo is! Map) return null;
  final valor = campo['value']?.toString();
  if (valor == null) return null;
  final plano = valor.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (plano.isEmpty) return null;
  return plano;
}

/// Patrones que marcan que la imagen es un mapa de distribución del
/// taxón en lugar de una foto. Para guías visuales no nos interesan.
bool _pareceMapaDistribucion(String url) {
  final lower = url.toLowerCase();
  for (final indicio in const [
    'range_map',
    'rangemap',
    'distribution_map',
    'distribution.png',
    'distribución',
    'distribucion',
    'mapa_de_distribuc',
    '_range_',
    '_range.',
    '_map_',
    '_map.',
    'leefgebied',
  ]) {
    if (lower.contains(indicio)) return true;
  }
  return false;
}

bool _pareceLogo(String url) {
  final lower = url.toLowerCase();
  return lower.contains('commons-logo') || lower.contains('wikispecies-logo') || lower.contains('wiktionary');
}
