// Tests del cálculo geodésico de las zonas dibujadas (FZ-3b).
//
// El punto delicado es la superficie: a la latitud de Navarra (~42,7°) un
// grado de longitud mide unos 818 m frente a los 1.111 m de un grado de
// latitud, así que tratar lat/long como plano infla el área en torno a un
// 36 %. Estos tests fijan el resultado contra cuadrados de tamaño conocido.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:solera_zunbeltz/utiles/geodesia.dart';

void main() {
  // Centro aproximado de la finca de Zunbeltz.
  const latitudBase = 42.7;
  const longitudBase = -2.05;

  /// Cuadrado de [ladoMetros] con esquina suroeste en la base, usando los
  /// metros por grado a esa latitud.
  List<LatLng> cuadradoDe(double ladoMetros) {
    const metrosPorGradoLatitud = 111132.0;
    final metrosPorGradoLongitud = 111320.0 * cos(latitudBase);
    final deltaLatitud = ladoMetros / metrosPorGradoLatitud;
    final deltaLongitud = ladoMetros / metrosPorGradoLongitud;
    return [
      LatLng(latitudBase, longitudBase),
      LatLng(latitudBase, longitudBase + deltaLongitud),
      LatLng(latitudBase + deltaLatitud, longitudBase + deltaLongitud),
      LatLng(latitudBase + deltaLatitud, longitudBase),
    ];
  }

  group('superficie', () {
    test('cuadrado de 100 m = 1 ha', () {
      final hectareas = superficieHectareas(cuadradoDe(100));
      // 1 % de tolerancia: esfera frente a elipsoide y redondeo del cuadrado.
      expect(hectareas, closeTo(1.0, 0.01));
    });

    test('cuadrado de 1 km = 100 ha', () {
      expect(superficieHectareas(cuadradoDe(1000)), closeTo(100.0, 1.0));
    });

    test('no confunde grados de latitud con grados de longitud', () {
      // Un "cuadrado" de 0,01° × 0,01° NO es cuadrado en el terreno: a esta
      // latitud el lado este-oeste es más corto, así que el área real queda
      // por debajo de la que saldría tratándolo como plano (1,234 ha).
      final rectanguloEnGrados = [
        LatLng(latitudBase, longitudBase),
        LatLng(latitudBase, longitudBase + 0.01),
        LatLng(latitudBase + 0.01, longitudBase + 0.01),
        LatLng(latitudBase + 0.01, longitudBase),
      ];
      final hectareas = superficieHectareas(rectanguloEnGrados);
      expect(hectareas, closeTo(91.0, 1.5));
    });

    test('el sentido de giro no cambia el resultado', () {
      final enSentido = cuadradoDe(300);
      final invertido = enSentido.reversed.toList();
      expect(superficieHectareas(invertido),
          closeTo(superficieHectareas(enSentido), 0.0001));
    });

    test('un trazado sin cerrar (menos de 3 vértices) mide 0', () {
      expect(superficieHectareas(const []), 0);
      expect(superficieHectareas([cuadradoDe(100).first]), 0);
      expect(superficieHectareas(cuadradoDe(100).take(2).toList()), 0);
    });
  });

  group('perímetro', () {
    test('cuadrado de 100 m mide 400 m de alambrada', () {
      expect(perimetroMetros(cuadradoDe(100)), closeTo(400.0, 2.0));
    });

    test('con dos vértices mide el lado, no la ida y vuelta', () {
      final lado = cuadradoDe(100).take(2).toList();
      expect(perimetroMetros(lado), closeTo(100.0, 1.0));
    });
  });

  group('punto dentro del polígono', () {
    final parcela = cuadradoDe(500);

    test('el centro cae dentro', () {
      final centro = centroide(parcela)!;
      expect(puntoDentroDePoligono(centro, parcela), isTrue);
    });

    test('un punto claramente fuera queda fuera', () {
      expect(
          puntoDentroDePoligono(
              LatLng(latitudBase - 0.05, longitudBase), parcela),
          isFalse);
    });

    test('con un trazado incompleto no hay dentro', () {
      expect(
          puntoDentroDePoligono(LatLng(latitudBase, longitudBase),
              parcela.take(2).toList()),
          isFalse);
    });

    test('un polígono en L: el hueco de la L queda fuera', () {
      // L con el hueco en la esquina noreste.
      final ele = [
        LatLng(42.700, -2.050),
        LatLng(42.700, -2.040),
        LatLng(42.705, -2.040),
        LatLng(42.705, -2.045),
        LatLng(42.710, -2.045),
        LatLng(42.710, -2.050),
      ];
      expect(puntoDentroDePoligono(LatLng(42.702, -2.046), ele), isTrue);
      expect(puntoDentroDePoligono(LatLng(42.708, -2.042), ele), isFalse);
    });
  });

  test('centroide de lista vacía es null', () {
    expect(centroide(const []), isNull);
  });
}

/// Coseno de un ángulo en grados (para montar los cuadrados de prueba).
double cos(double grados) => math.cos(grados * math.pi / 180.0);
