import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/nivelar.dart';

void main() {
  test('medios', () {
    expect(enMedios(11), '5,5');
    expect(enMedios(10), '5');
  });

  for (final tipo in TipoPregunta.values) {
    for (final dificultad in [1, 2, 3]) {
      test('$tipo en dificultad $dificultad: la respuesta es la de verdad', () {
        final generador = GeneradorNivelar(azar: math.Random(tipo.index * 10 + dificultad));
        for (var i = 0; i < 150; i++) {
          final reto = generador.generar(tipo, dificultad: dificultad);
          final pilas = reto.pilas;
          final ordenadas = [...pilas]..sort();
          final esperada = switch (tipo) {
            TipoPregunta.leerPila => pilas[reto.senaladas.single] * 2,
            TipoPregunta.diferencia => (pilas[reto.senaladas[0]] - pilas[reto.senaladas[1]]) * 2,
            TipoPregunta.media => (reto.media * 2).round(),
            TipoPregunta.mediana => pilas.length.isOdd
                ? ordenadas[pilas.length ~/ 2] * 2
                : ordenadas[pilas.length ~/ 2 - 1] + ordenadas[pilas.length ~/ 2],
            TipoPregunta.moda => () {
                final cuentas = <int, int>{};
                for (final p in pilas) {
                  cuentas[p] = (cuentas[p] ?? 0) + 1;
                }
                final maximo = cuentas.values.reduce(math.max);
                return cuentas.entries.firstWhere((e) => e.value == maximo).key * 2;
              }(),
          };
          expect(reto.respuestaEnMedios, esperada, reason: '$pilas');
          if (tipo == TipoPregunta.media) {
            expect(reto.media * 2, closeTo(reto.respuestaEnMedios, 1e-9));
            if (dificultad < 3) expect(reto.respuestaEnMedios.isEven, isTrue);
          }
          expect(reto.opcionesEnMedios.toSet().length, 4);
          expect(reto.opcionesEnMedios, contains(reto.respuestaEnMedios));
          expect(reto.opcionesEnMedios.every((o) => o > 0), isTrue);
          expect(pilas.every((p) => p >= 1 && p <= 9), isTrue);
        }
      });
    }
  }

  test('nivelado, el barco va derecho', () {
    expect(desequilibrio([5, 5, 5, 5]), 0);
    expect(desequilibrio([1, 9, 1, 9]), greaterThan(3));
  });
}
