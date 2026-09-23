import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/ejemplos_resueltos.dart';

void main() {
  test('cada habilidad con ejemplo da pasos completos, sin huecos', () {
    final azar = math.Random(1);
    for (final id in habilidadesConEjemplo) {
      for (final dificultad in [1, 2, 3]) {
        for (var i = 0; i < 40; i++) {
          final ejemplo = ejemploParecido(id,
              dificultad: dificultad, parametro: id.startsWith('DIV.0') && id != 'DIV.05' ? 4 : null, azar: azar);
          expect(ejemplo, isNotNull, reason: id);
          expect(ejemplo!.pasos, isNotEmpty);
          for (final paso in ejemplo.pasos) {
            final texto = paso.rellenar(paso.plantilla);
            expect(texto.contains('{'), isFalse, reason: '$id: $texto');
          }
        }
      }
    }
  });

  test('los cálculos del ejemplo llegan al resultado correcto', () {
    final azar = math.Random(2);
    int evaluar(String enunciado) {
      final numeros = RegExp(r'\d+').allMatches(enunciado).map((m) => int.parse(m[0]!)).toList();
      if (enunciado.contains('%')) return numeros[0] * numeros[1] ~/ 100;
      if (enunciado.contains(' de ')) return numeros[2] * numeros[0] ~/ numeros[1];
      if (enunciado.endsWith('²')) return numeros[0] * numeros[0];
      if (enunciado.endsWith('³')) return numeros[0] * numeros[0] * numeros[0];
      if (enunciado.startsWith('(')) return (numeros[0] + numeros[1]) * numeros[2];
      if (enunciado.contains('×')) return numeros[0] + numeros[1] * numeros[2];
      return numeros[0] + numeros[1];
    }

    for (final id in ['ARI.01', 'OP.01', 'ARI.02', 'FR.22', 'PROP.04']) {
      for (var i = 0; i < 100; i++) {
        final ejemplo = ejemploParecido(id, dificultad: 1 + i % 3, azar: azar)!;
        final ultimo = ejemplo.pasos.last;
        final texto = ultimo.rellenar(ultimo.plantilla);
        expect(texto, contains('${evaluar(ejemplo.enunciado)}'),
            reason: '${ejemplo.enunciado}: $texto');
      }
    }
  });

  test('el ejemplo nunca es el problema del niño', () {
    final azar = math.Random(3);
    for (var i = 0; i < 200; i++) {
      final ejemplo = ejemploParecido('ARI.02', dificultad: 1, evitar: '3²', azar: azar);
      expect(ejemplo?.enunciado, isNot('3²'));
    }
  });

  test('sin ejemplo para las habilidades de la balanza', () {
    expect(ejemploParecido('ALG.01'), isNull);
  });
}
