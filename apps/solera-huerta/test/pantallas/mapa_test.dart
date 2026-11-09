import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/pantallas/pantalla_mapa.dart';

void main() {
  test('el mapa se centra en las parcelas con ubicación', () {
    final centro = centroDeParcelas([
      Parcela(nombre: 'A', latitud: 42, longitud: -2),
      Parcela(nombre: 'B', latitud: 44, longitud: -4),
      Parcela(nombre: 'Sin'),
    ]);
    expect((centro.latitude, centro.longitude), (43, -3));
    expect(centroDeParcelas([]).latitude, 40.4);
  });

  test('una parcela con área y sin punto sale en el centro del área', () {
    final parcela = Parcela(
        nombre: 'Área',
        contorno: codificarContorno(const [
          LatLng(42, -2),
          LatLng(42, -1.998),
          LatLng(42.002, -1.998),
          LatLng(42.002, -2),
        ]));
    final punto = puntoDeParcela(parcela)!;
    expect(punto.latitude, closeTo(42.001, 1e-6));
    expect(punto.longitude, closeTo(-1.999, 1e-6));
    expect(puntoDeParcela(Parcela(nombre: 'Sin')), isNull);
  });

  test('el logo placeholder existe y está declarado', () {
    expect(File('assets/icono-logo-huerta.png').existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('assets/icono-logo-huerta.png'));
  });

  test('el manifiesto declara INTERNET, ubicación y el nombre visible', () {
    final manifiesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifiesto, contains('android.permission.INTERNET'));
    expect(manifiesto, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifiesto, contains('android:label="Larrea Huerta"'));
  });
}
