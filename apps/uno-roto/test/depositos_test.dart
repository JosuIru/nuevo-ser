import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/depositos.dart';

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: la respuesta es la cuenta y hay cuatro opciones distintas', () {
      final generador = GeneradorDepositos(azar: math.Random(dificultad));
      for (final tipo in TipoDeposito.values) {
        for (var i = 0; i < 200; i++) {
          final reto = generador.generar(tipo, dificultad: dificultad);
          final d = reto.datos;
          final esperado = switch (tipo) {
            TipoDeposito.cubos => d[0] * d[1] * d[2],
            TipoDeposito.litros => d[0] * d[1] * d[2] ~/ 1000,
            TipoDeposito.vallaCirculo => 2 * 314 * d[0],
            TipoDeposito.areaCirculo => 314 * d[0] * d[0],
          };
          expect(reto.respuesta, esperado, reason: '$tipo $d');
          expect(reto.opciones.toSet().length, 4);
          expect(reto.opciones, contains(reto.respuesta));
          expect(reto.opciones.every((o) => o > 0), isTrue);
        }
      }
    });
  }

  test('los litros salen enteros: las medidas en cm son decenas', () {
    final generador = GeneradorDepositos(azar: math.Random(7));
    for (var i = 0; i < 200; i++) {
      final reto = generador.generar(TipoDeposito.litros, dificultad: 3);
      expect(reto.datos[0] * reto.datos[1] * reto.datos[2] % 1000, 0);
    }
  });

  test('las trampas de siempre están entre las opciones', () {
    final generador = GeneradorDepositos(azar: math.Random(3));
    var conSuma = 0;
    var conLaOtraFormula = 0;
    for (var i = 0; i < 100; i++) {
      final cubos = generador.generar(TipoDeposito.cubos);
      if (cubos.opciones.contains(cubos.datos.reduce((a, b) => a + b))) conSuma++;
      final area = generador.generar(TipoDeposito.areaCirculo);
      if (area.opciones.contains(628 * area.datos[0])) conLaOtraFormula++;
    }
    expect(conSuma, greaterThan(80));
    expect(conLaOtraFormula, 100);
  });
}
