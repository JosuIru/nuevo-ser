import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/telar.dart';

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: la respuesta es la cuenta y es la única que vale eso', () {
      final generador = GeneradorTelar(azar: math.Random(dificultad));
      for (final tipo in TipoTelar.values) {
        for (var i = 0; i < 100; i++) {
          final reto = generador.generar(tipo, dificultad: dificultad);
          final d = reto.datos;
          final esperado = switch (tipo) {
            TipoTelar.porNatural => d[0] / d[1] * d[2],
            TipoTelar.porFraccion => d[0] / d[1] * d[2] / d[3],
            TipoTelar.dividirNatural => d[0] / d[1] / d[2],
            TipoTelar.dividirFraccion => d[0] / d[1] * d[2],
          };
          expect(valorEscrito(reto.respuesta), closeTo(esperado, 1e-9), reason: '$tipo $d');
          expect(reto.opciones.length, 4);
          final iguales = reto.opciones.where((o) => (valorEscrito(o) - esperado).abs() < 1e-9);
          expect(iguales, [reto.respuesta], reason: '${reto.opciones}');
        }
      }
    });
  }
}
