// Cómo se guarda un contorno (área) en la BD de las apps Larrea: TEXT con
// JSON `[[lat,lng],…]`, latitud primero (al revés que GeoJSON), sin repetir
// el primer vértice y con un solo anillo. Es el formato de Larrea Zunbeltz
// (`zonas_finca.vertices_json`), Ganadera (`piezas_pasto.contorno`) y Monte
// (`rodales.contorno`): no cambiarlo, hay datos guardados.

import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// Contorno vacío, valor por defecto de la columna.
const String contornoVacio = '[]';

/// Codifica los vértices a JSON `[[lat,lng],…]`.
String codificarContorno(List<LatLng> vertices) => jsonEncode([
      for (final vertice in vertices) [vertice.latitude, vertice.longitude]
    ]);

/// Lee el JSON de un contorno. Tolera basura: descarta los pares mal
/// formados y devuelve vacío si el texto no es una lista.
List<LatLng> leerContorno(String? json) {
  if (json == null || json.trim().isEmpty) return const [];
  try {
    final crudo = jsonDecode(json);
    if (crudo is! List) return const [];
    return [
      for (final par in crudo)
        if (par is List && par.length >= 2 && par[0] is num && par[1] is num)
          LatLng((par[0] as num).toDouble(), (par[1] as num).toDouble()),
    ];
  } catch (_) {
    return const [];
  }
}

/// ¿Hay un área de verdad (tres vértices o más)?
bool tieneArea(List<LatLng> vertices) => vertices.length >= 3;
