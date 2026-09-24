import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/caja_negra.dart';

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('directa en dificultad $dificultad: la pregunta no se puede probar', () {
      final generador = GeneradorCaja(azar: math.Random(dificultad));
      for (final nivel in [1, 2]) {
        for (var i = 0; i < 150; i++) {
          final reto = generador.generar(TipoCaja.directa, nivel: nivel, dificultad: dificultad);
          expect(reto.probables, isNot(contains(reto.dato)));
          expect(reto.respuesta, reto.regla.aplicar(reto.dato));
          expect(reto.opciones.toSet().length, 4);
          expect(reto.opciones, contains(reto.respuesta));
          // Todas las salidas visibles son positivas (nada raro en la tabla).
          for (final x in reto.probables) {
            expect(reto.regla.aplicar(x), greaterThan(0), reason: '${reto.regla.a}x+${reto.regla.b}, x=$x');
          }
          if (dificultad >= 2) {
            expect(reto.mudo, isNotNull);
            expect(reto.filasIniciales, isNot(contains(reto.mudo)));
          }
          expect(reto.idHabilidad, 'FUN.01');
        }
      }
    });
  }

  test('inversa: la buena es la que entró', () {
    final generador = GeneradorCaja(azar: math.Random(8));
    for (var i = 0; i < 200; i++) {
      final reto = generador.generar(TipoCaja.inversa, nivel: 3, dificultad: 1 + i % 3);
      expect(reto.regla.aplicar(reto.respuesta), reto.dato);
      expect(reto.opciones.where((o) => reto.regla.aplicar(o) == reto.dato), [reto.respuesta]);
    }
  });

  test('gemelas: rojo y azul cuadran con las dos balanzas', () {
    final generador = GeneradorCaja(azar: math.Random(9));
    for (var i = 0; i < 200; i++) {
      final reto = generador.generar(TipoCaja.gemelas, nivel: 3, dificultad: 1 + i % 3);
      final rojo = reto.respuesta;
      final azul = rojo - reto.dato2!;
      expect(azul, greaterThan(0));
      expect(reto.regla.a * rojo + azul, reto.dato);
      expect(reto.opciones.toSet().length, 4);
      expect(reto.opciones, contains(rojo));
      expect(reto.idHabilidad, 'ALG.03');
    }
  });
}
