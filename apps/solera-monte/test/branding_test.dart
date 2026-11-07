import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_monte/branding.dart';

void main() {
  test('el logo placeholder existe y está declarado', () {
    expect(File(rutaLogoMonte).existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(), contains(rutaLogoMonte));
  });

  test('permisos de ubicación e Internet en el manifiesto de release', () {
    final manifiesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifiesto, contains('android.permission.INTERNET'));
    expect(manifiesto, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifiesto, contains('android:label="Larrea Monte"'));
  });

  test('colores de la marca: verde pino y crema', () {
    expect(colorPrimarioMonte.toARGB32(), 0xFF2F4F3A);
    expect(colorCremaMonte.toARGB32(), 0xFFF5EFE2);
    expect(
        File('android/app/src/main/res/values/colors.xml').readAsStringSync(),
        contains('#F5EFE2'));
  });
}
