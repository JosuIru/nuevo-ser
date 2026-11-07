import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:solera_aromaticas/pantallas/pantalla_mapa.dart';

void main() {
  test('el mapa se centra en los puntos con ubicación', () {
    final centro = centroDePuntos([const LatLng(42, -2), const LatLng(44, -4)]);
    expect((centro.latitude, centro.longitude), (43, -3));
    expect(centroDePuntos([]).latitude, 40.4);
  });

  test('el logo placeholder existe y está declarado', () {
    expect(File('assets/icono-logo-aromaticas.png').existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('assets/icono-logo-aromaticas.png'));
  });

  test('permisos de ubicación e Internet en el manifiesto de release', () {
    final manifiesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifiesto, contains('android.permission.INTERNET'));
    expect(manifiesto, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifiesto, contains('android:label="Larrea Aromáticas"'));
  });
}
