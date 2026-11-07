import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// Contorno o traza: vértices (latitud, longitud) guardados como JSON
/// `[[lat, lon], …]`, igual que la pieza de pasto de Ganadera.
String codificarContorno(List<(double, double)> vertices) => jsonEncode([
      for (final (latitud, longitud) in vertices) [latitud, longitud]
    ]);

/// Lee el contorno guardado; uno roto o vacío da una lista vacía.
List<(double, double)> leerContorno(String? texto) {
  if (texto == null || texto.isEmpty) return const [];
  try {
    final lista = jsonDecode(texto);
    if (lista is! List) return const [];
    return [
      for (final punto in lista)
        if (punto is List &&
            punto.length == 2 &&
            punto[0] is num &&
            punto[1] is num)
          ((punto[0] as num).toDouble(), (punto[1] as num).toDouble()),
    ];
  } on FormatException {
    return const [];
  }
}

List<LatLng> aLatLng(List<(double, double)> vertices) =>
    [for (final (latitud, longitud) in vertices) LatLng(latitud, longitud)];
