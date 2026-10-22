import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Buscador de lugares para el mapa con el geocodificador de CartoCiudad
/// (Instituto Geográfico Nacional): topónimos y parajes, municipios,
/// poblaciones, calles y referencias catastrales de toda España. Gratuito,
/// sin clave y con CORS abierto.
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
  final http.Client _cliente;

  Future<List<LugarEncontrado>> buscar(String texto, {int limite = 10}) async {
    final consulta = texto.trim();
    if (consulta.length < 2) return const [];
    final respuesta = await _cliente
        .get(Uri.parse('$_base/candidates')
            .replace(queryParameters: {'q': consulta, 'limit': '$limite'}))
        .timeout(const Duration(seconds: 20));
    if (respuesta.statusCode != 200) return const [];
    return lugaresDesdeCandidatos(utf8.decode(respuesta.bodyBytes));
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
