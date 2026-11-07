// El test de traducciones del core no recorre esta app: este hace lo mismo
// con lib/ (toda clave usada existe en los cuatro idiomas).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_sidra/utiles/textos_sidra.dart';

void main() {
  final llamada = RegExp(r"SoleraL10n\.tf?\(\s*'([^']*)'");
  final suelta = RegExp(r"'(sidr\.[a-z0-9_]+)'");
  final usadas = <String, String>{};
  for (final fichero in Directory('lib').listSync(recursive: true)) {
    if (fichero is! File || !fichero.path.endsWith('.dart')) continue;
    final lineas = fichero.readAsLinesSync();
    for (var numero = 0; numero < lineas.length; numero++) {
      for (final coincidencia in [
        ...llamada.allMatches(lineas[numero]),
        ...suelta.allMatches(lineas[numero]),
      ]) {
        usadas.putIfAbsent(
            coincidencia.group(1)!, () => '${fichero.path}:${numero + 1}');
      }
    }
  }

  test('hay claves que comprobar',
      () => expect(usadas.length, greaterThan(100)));

  test('ninguna clave lleva «\$»', () {
    expect(usadas.keys.where((clave) => clave.contains(r'$')), isEmpty);
  });

  test('todas las claves usadas existen', () {
    final disponibles = SoleraL10n.clavesDisponibles.toSet();
    final faltan = {
      for (final MapEntry(key: clave, value: donde) in usadas.entries)
        if (!disponibles.contains(clave)) clave: donde,
      for (final clave in clavesValores)
        if (!disponibles.contains(clave)) clave: 'clavesValores',
    };
    expect(faltan, isEmpty);
  });

  test('las claves de la app tienen texto en euskera', () {
    for (final clave
        in usadas.keys.where((clave) => clave.startsWith('sidr.'))) {
      expect(SoleraL10n.t(clave, idioma: 'eu'), isNot(clave), reason: clave);
    }
  });
}
