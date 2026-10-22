import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Buscador de lugares para el mapa con el geocodificador de CartoCiudad
/// (Instituto Geográfico Nacional): topónimos y parajes, municipios,
/// poblaciones, calles y referencias catastrales de toda España. Gratuito,
/// sin clave y con CORS abierto. Si CartoCiudad no responde (se cae a
/// ratos: corta la conexión), se pregunta a Nominatim (OpenStreetMap).
class LugarEncontrado {
  const LugarEncontrado({
    required this.texto,
    required this.tipo,
    required this.id,
    this.municipio = '',
    this.posicion,
  });

  final String texto;

  /// Tipo de CartoCiudad (`ngbe` paraje, `Municipio`, `poblacion`,
  /// `callejero`, `portal`, `refcatastral`…).
  final String tipo;
  final String id;
  final String municipio;

  /// Null si la lista de candidatos no la trae: hay que pedirla con
  /// [ServicioBuscadorMapa.posicionDe].
  final LatLng? posicion;
}

class ServicioBuscadorMapa {
  ServicioBuscadorMapa({http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  static const _base = 'https://www.cartociudad.es/geocoder/api/geocoder';
  static const _baseNominatim = 'https://nominatim.openstreetmap.org/search';
  final http.Client _cliente;

  /// Busca en CartoCiudad y, si falla o no contesta bien, en Nominatim.
  /// Solo lanza si fallan los dos.
  Future<List<LugarEncontrado>> buscar(String texto, {int limite = 10}) async {
    final consulta = texto.trim();
    if (consulta.length < 2) return const [];
    try {
      final respuesta = await _cliente
          .get(Uri.parse('$_base/candidates')
              .replace(queryParameters: {'q': consulta, 'limit': '$limite'}))
          .timeout(const Duration(seconds: 8));
      if (respuesta.statusCode == 200) {
        return lugaresDesdeCandidatos(utf8.decode(respuesta.bodyBytes));
      }
    } catch (_) {
      // CartoCiudad caído: se prueba con Nominatim.
    }
    return _buscarEnNominatim(consulta, limite);
  }

  Future<List<LugarEncontrado>> _buscarEnNominatim(
      String consulta, int limite) async {
    final respuesta = await _cliente.get(
      Uri.parse(_baseNominatim).replace(queryParameters: {
        'q': consulta,
        'format': 'jsonv2',
        'limit': '$limite',
        'countrycodes': 'es,fr',
        'accept-language': 'es',
      }),
      // Nominatim pide identificarse; el navegador no deja tocar el
      // User-Agent y allí basta el Referer que pone él.
      headers: kIsWeb
          ? null
          : const {'user-agent': 'LarreaZunbeltz (app.zunbeltz.com)'},
    ).timeout(const Duration(seconds: 15));
    if (respuesta.statusCode != 200) {
      throw http.ClientException('Nominatim ${respuesta.statusCode}');
    }
    return lugaresDesdeNominatim(utf8.decode(respuesta.bodyBytes));
  }

  /// Dónde está un candidato que vino sin coordenadas.
  Future<LatLng?> posicionDe(LugarEncontrado lugar) async {
    if (lugar.posicion != null) return lugar.posicion;
    final respuesta = await _cliente
        .get(Uri.parse('$_base/find').replace(queryParameters: {
          'q': lugar.texto,
          'type': lugar.tipo,
          'id': lugar.id,
        }))
        .timeout(const Duration(seconds: 20));
    if (respuesta.statusCode != 200) return null;
    return posicionDesdeFind(utf8.decode(respuesta.bodyBytes));
  }
}

LatLng? _posicion(Object? lat, Object? lng) {
  if (lat is! num || lng is! num || (lat == 0 && lng == 0)) return null;
  return LatLng(lat.toDouble(), lng.toDouble());
}

/// Lee la lista de candidatos. Pura.
List<LugarEncontrado> lugaresDesdeCandidatos(String texto) {
  final datos = jsonDecode(texto);
  if (datos is! List) return const [];
  return [
    for (final candidato in datos)
      if (candidato is Map && candidato['address'] is String)
        LugarEncontrado(
          texto: candidato['address'] as String,
          tipo: '${candidato['type'] ?? ''}',
          id: '${candidato['id'] ?? ''}',
          municipio: '${candidato['muni'] ?? ''}',
          posicion: _posicion(candidato['lat'], candidato['lng']),
        ),
  ];
}

/// Lee la respuesta de `find`. Pura.
LatLng? posicionDesdeFind(String texto) {
  final datos = jsonDecode(texto);
  return datos is Map ? _posicion(datos['lat'], datos['lng']) : null;
}

/// Lee la respuesta de Nominatim (`format=jsonv2`). Siempre trae la
/// posición. Pura.
List<LugarEncontrado> lugaresDesdeNominatim(String texto) {
  final datos = jsonDecode(texto);
  if (datos is! List) return const [];
  return [
    for (final lugar in datos)
      if (lugar is Map && lugar['display_name'] is String)
        LugarEncontrado(
          texto: lugar['display_name'] as String,
          tipo: 'osm:${lugar['addresstype'] ?? lugar['type'] ?? ''}',
          id: '${lugar['osm_type'] ?? ''}${lugar['osm_id'] ?? ''}',
          posicion: _posicion(
              double.tryParse('${lugar['lat']}'),
              double.tryParse('${lugar['lon']}')),
        ),
  ];
}
