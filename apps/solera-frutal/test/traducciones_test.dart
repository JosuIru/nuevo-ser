// Guardarraíl propio: el test del core (test/i18n) todavía no recorre
// apps/solera-frutal/lib, así que aquí se comprueba que cada clave `frut.*`
// usada en el código existe y tiene texto en los cuatro idiomas.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

final _llamada = RegExp(r"SoleraL10n\.tf?\(\s*'([^']*)'");
final _suelta = RegExp(r"'(frut\.[a-z0-9_]+)'");

Map<String, String> _clavesUsadas() {
  final usadas = <String, String>{};
  for (final entidad in Directory('lib').listSync(recursive: true)) {
    if (entidad is! File || !entidad.path.endsWith('.dart')) continue;
    final lineas = entidad.readAsLinesSync();
    for (var numero = 0; numero < lineas.length; numero++) {
      for (final coincidencia in [
        ..._llamada.allMatches(lineas[numero]),
        ..._suelta.allMatches(lineas[numero]),
      ]) {
        usadas.putIfAbsent(
            coincidencia.group(1)!, () => '${entidad.path}:${numero + 1}');
      }
    }
  }
  return usadas;
}

void main() {
  final usadas = _clavesUsadas();

  test('se encuentran claves en el código', () {
    expect(usadas.length, greaterThan(10));
  });

  test('todas las claves usadas existen', () {
    expect({
      for (final entrada in usadas.entries)
        if (!SoleraL10n.clavesDisponibles.contains(entrada.key))
          entrada.key: entrada.value,
    }, isEmpty, reason: 'Añádelas a content/solera/traducciones/frutal.csv');
  });

  for (final idioma in ['eu', 'ca', 'gl']) {
    test('todas las claves usadas tienen texto en $idioma', () {
      final traducidas = SoleraL10n.clavesTraducidas(idioma);
      expect({
        for (final entrada in usadas.entries)
          if (!traducidas.contains(entrada.key)) entrada.key: entrada.value,
      }, isEmpty);
    });
  }
}
