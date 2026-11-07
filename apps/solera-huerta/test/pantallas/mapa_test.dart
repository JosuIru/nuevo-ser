import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
