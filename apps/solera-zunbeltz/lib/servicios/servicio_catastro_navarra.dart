import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../utiles/importar_contornos.dart';

/// Parcelas del Catastro de Navarra por el WFS público de IDENA (capas
/// `CATAST_Pol_ParcelaRusti` y `CATAST_Pol_SubparRusti`, rústica). Sin
/// clave y con CORS abierto: vale también en la versión web.
///
/// Navarra lleva su propio catastro (no el de la Dirección General del
/// Catastro), así que fuera de Navarra esto no encuentra nada.
class ParcelaCatastral {
  const ParcelaCatastral({
    required this.municipio,
    required this.poligono,
    required this.parcela,
    this.subparcela = '',
    this.paraje = '',
    this.superficieM2 = 0,
    required this.contornos,
  });

  final String municipio;
  final int poligono;
  final int parcela;

  /// '' para la parcela entera.
  final String subparcela;
  final String paraje;
  final double superficieM2;

  /// Anillos exteriores (una parcela puede tener varios trozos).
  final List<List<LatLng>> contornos;

  /// «Valle de Yerri / Deierri 24-2», «… 24-2 B».
  String get referencia =>
      '${_capitalizar(municipio)} $poligono-$parcela${subparcela.isEmpty ? '' : ' $subparcela'}';

  /// Nombre propuesto para la zona: el paraje si lo hay, si no la
  /// referencia.
  String get nombrePropuesto =>
      paraje.isEmpty ? referencia : _capitalizar(paraje);
}

String _capitalizar(String texto) => texto
    .toLowerCase()
    .split(' ')
    .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
    .join(' ');

class ErrorCatastro implements Exception {
  const ErrorCatastro(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class ServicioCatastroNavarra {
  ServicioCatastroNavarra({http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  static const _base = 'https://idena.navarra.es/ogc/wfs';
  static const _capaParcelas = 'IDENA:CATAST_Pol_ParcelaRusti';
  static const _capaSubparcelas = 'IDENA:CATAST_Pol_SubparRusti';

  final http.Client _cliente;

  /// La parcela y las subparcelas que hay bajo [punto].
  Future<List<ParcelaCatastral>> enPunto(LatLng punto) async {
    final filtro =
        'INTERSECTS(the_geom,SRID=4326;POINT(${punto.longitude} ${punto.latitude}))';
    return [
      ...await _consultar(_capaParcelas, filtro),
      ...await _consultar(_capaSubparcelas, filtro),
    ];
  }

  /// Por referencia: municipio (nombre o parte de él, sin distinguir
  /// mayúsculas), polígono y parcela. Con [conSubparcelas], también sus
  /// subparcelas.
  Future<List<ParcelaCatastral>> porReferencia({
    required String municipio,
    required int poligono,
    required int parcela,
    bool conSubparcelas = true,
  }) async {
    final nombre = municipio.trim().toLowerCase().replaceAll("'", "''");
    final filtro = "strToLowerCase(MUNICIPIO) LIKE '%$nombre%' "
        'AND POLIGONO=$poligono AND PARCELA=$parcela';
    return [
      ...await _consultar(_capaParcelas, filtro),
      if (conSubparcelas) ...await _consultar(_capaSubparcelas, filtro),
    ];
  }

  Future<List<ParcelaCatastral>> _consultar(String capa, String filtro) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'service': 'WFS',
      'version': '2.0.0',
      'request': 'GetFeature',
      'typeNames': capa,
      'outputFormat': 'application/json',
      'srsName': 'EPSG:4326',
      'count': '60',
      'CQL_FILTER': filtro,
    });
    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(uri).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ErrorCatastro('sin_conexion');
    }
    if (respuesta.statusCode != 200) {
      throw ErrorCatastro('http_${respuesta.statusCode}');
    }
    return parcelasDesdeGeoJson(utf8.decode(respuesta.bodyBytes));
  }
}

/// Lee la respuesta GeoJSON del WFS. Pura.
List<ParcelaCatastral> parcelasDesdeGeoJson(String texto) {
  final datos = jsonDecode(texto);
  if (datos is! Map || datos['features'] is! List) return const [];
  final salida = <ParcelaCatastral>[];
  for (final rasgo in datos['features'] as List) {
    if (rasgo is! Map) continue;
    final propiedades = (rasgo['properties'] as Map?) ?? const {};
    final contornos = leerGeoJson(jsonEncode({
      'type': 'Feature',
      'geometry': rasgo['geometry'],
      'properties': const {},
    })).map((p) => p.vertices).toList();
    if (contornos.isEmpty) continue;
    salida.add(ParcelaCatastral(
      municipio: '${propiedades['MUNICIPIO'] ?? ''}',
      poligono: (propiedades['POLIGONO'] as num?)?.toInt() ?? 0,
      parcela: (propiedades['PARCELA'] as num?)?.toInt() ?? 0,
      subparcela: '${propiedades['SUBPARCELA'] ?? ''}'.trim(),
      paraje: '${propiedades['PARAJE'] ?? ''}'.trim(),
      superficieM2: (propiedades['GEOM_AREA'] as num?)?.toDouble() ?? 0,
      contornos: contornos,
    ));
  }
  return salida;
}
