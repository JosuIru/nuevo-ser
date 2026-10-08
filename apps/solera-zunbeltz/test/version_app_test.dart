import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/pantallas/pantalla_ajustes.dart';

void main() {
  test('la versión que enseña Ajustes es la del pubspec', () {
    final linea = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((linea) => linea.startsWith('version:'));
    final version = linea.split(':')[1].trim().split('+').first;
    expect(versionAppZunbeltz, version,
        reason: 'al subir la versión hay que cambiar también versionAppZunbeltz');
  });
}
