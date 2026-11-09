import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Cálculos geodésicos para las zonas dibujadas sobre el mapa.
///
/// Las áreas NO se pueden medir como un polígono plano: un grado de longitud
/// vale menos cuanto más al norte, así que a la latitud de Navarra (~42,7°)
/// tratar lat/long como coordenadas planas infla el resultado. Aquí se usa la
/// fórmula del exceso esférico, que es la que emplean PostGIS y turf.js para
/// esferas, con el radio medio de la Tierra.
///
/// Precisión: sobre una esfera (no elipsoide). En parcelas de unas pocas
/// hectáreas el error frente al cálculo elipsoidal está muy por debajo del
/// que introduce el propio trazado a dedo sobre el mapa, así que basta. Aun
/// así, la superficie oficial de un recinto es la de SIGPAC: la que calcula
/// la app es orientativa (ver el aviso de la ficha de zona).
const double radioTierraMetros = 6371008.8;

/// Superficie de un polígono en hectáreas por exceso esférico.
///
/// Devuelve 0 con menos de tres vértices. El anillo se cierra solo (no hace
/// falta repetir el primer vértice al final) y el sentido de giro da igual:
/// el resultado es siempre positivo.
double superficieHectareas(List<LatLng> vertices) {
  final metrosCuadrados = superficieMetrosCuadrados(vertices);
  return metrosCuadrados / 10000.0;
}

/// Superficie de un polígono en metros cuadrados por exceso esférico.
double superficieMetrosCuadrados(List<LatLng> vertices) {
  if (vertices.length < 3) return 0;

  var acumulado = 0.0;
  for (var indice = 0; indice < vertices.length; indice++) {
    final actual = vertices[indice];
    final siguiente = vertices[(indice + 1) % vertices.length];

    final longitudActual = _aRadianes(actual.longitude);
    final longitudSiguiente = _aRadianes(siguiente.longitude);
    final latitudActual = _aRadianes(actual.latitude);
    final latitudSiguiente = _aRadianes(siguiente.latitude);

    acumulado += (longitudSiguiente - longitudActual) *
        (2 + math.sin(latitudActual) + math.sin(latitudSiguiente));
  }

  return (acumulado * radioTierraMetros * radioTierraMetros / 2.0).abs();
}

/// Perímetro del polígono en metros (suma de lados por haversine, cerrando
/// el anillo). Útil para presupuestar alambrada.
double perimetroMetros(List<LatLng> vertices) {
  if (vertices.length < 2) return 0;

  var total = 0.0;
  for (var indice = 0; indice < vertices.length; indice++) {
    final actual = vertices[indice];
    final siguiente = vertices[(indice + 1) % vertices.length];
    // Con dos vértices el anillo se recorrería ida y vuelta: solo el lado.
    if (vertices.length == 2 && indice == 1) break;
    total += distanciaMetros(actual, siguiente);
  }
  return total;
}

/// Distancia entre dos puntos en metros (haversine).
double distanciaMetros(LatLng desde, LatLng hasta) {
  final diferenciaLatitud = _aRadianes(hasta.latitude - desde.latitude);
  final diferenciaLongitud = _aRadianes(hasta.longitude - desde.longitude);
  final latitudDesde = _aRadianes(desde.latitude);
  final latitudHasta = _aRadianes(hasta.latitude);

  final termino = math.pow(math.sin(diferenciaLatitud / 2), 2) +
      math.cos(latitudDesde) *
          math.cos(latitudHasta) *
          math.pow(math.sin(diferenciaLongitud / 2), 2);

  return 2 * radioTierraMetros * math.asin(math.sqrt(termino));
}

/// ¿Cae [punto] dentro del polígono [vertices]? Algoritmo del rayo (cuenta
/// cuántos lados cruza una semirrecta horizontal). A la escala de una finca
/// se puede trabajar con lat/long como plano sin error apreciable.
///
/// Sirve para abrir la ficha de la zona al tocar dentro de ella en el mapa.
/// Con menos de tres vértices devuelve false.
bool puntoDentroDePoligono(LatLng punto, List<LatLng> vertices) {
  if (vertices.length < 3) return false;

  var dentro = false;
  for (var indice = 0; indice < vertices.length; indice++) {
    final actual = vertices[indice];
    final anterior = vertices[(indice + vertices.length - 1) % vertices.length];

    final cruzaEnLatitud = (actual.latitude > punto.latitude) !=
        (anterior.latitude > punto.latitude);
    if (!cruzaEnLatitud) continue;

    final longitudDelCorte = actual.longitude +
        (punto.latitude - actual.latitude) /
            (anterior.latitude - actual.latitude) *
            (anterior.longitude - actual.longitude);

    if (punto.longitude < longitudDelCorte) dentro = !dentro;
  }
  return dentro;
}

/// Centroide simple (media de los vértices). Para colocar la etiqueta de la
/// zona; no es el centro de masas exacto de un polígono irregular, pero en
/// parcelas convexas cae donde se espera. `null` si no hay vértices.
LatLng? centroide(List<LatLng> vertices) {
  if (vertices.isEmpty) return null;

  var sumaLatitud = 0.0;
  var sumaLongitud = 0.0;
  for (final vertice in vertices) {
    sumaLatitud += vertice.latitude;
    sumaLongitud += vertice.longitude;
  }
  return LatLng(sumaLatitud / vertices.length, sumaLongitud / vertices.length);
}

double _aRadianes(double grados) => grados * math.pi / 180.0;
