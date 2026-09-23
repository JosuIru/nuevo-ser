import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/engranajes.dart';

void main() {
  test('mcm y mcd de siempre', () {
    expect(mcm(4, 6), 12);
    expect(mcm(6, 8), 24);
    expect(mcd(24, 36), 12);
    expect(mcd(7, 9), 1);
    expect(mcmDeTodos([2, 3, 4]), 12);
  });

  for (final dificultad in [1, 2, 3]) {
    test('MCM en dificultad $dificultad: respuesta correcta y cuatro opciones', () {
      final generador = GeneradorEngranajes(azar: math.Random(dificultad));
      for (var i = 0; i < 200; i++) {
        final reto = generador.generar(TipoEngranaje.mcm, dificultad: dificultad);
        final [a, b] = reto.numeros;
        expect(reto.respuesta, mcm(a, b));
        expect(reto.respuesta % a, 0);
        expect(reto.respuesta % b, 0);
        expect(reto.opciones.toSet().length, 4);
        expect(reto.opciones, contains(reto.respuesta));
        expect(reto.opciones.every((o) => o > 0), isTrue);
        expect(reto.idHabilidad, 'DIV.07');
      }
    });

    test('MCD en dificultad $dificultad: el trozo más largo que vale para los dos', () {
      final generador = GeneradorEngranajes(azar: math.Random(10 + dificultad));
      for (var i = 0; i < 200; i++) {
        final reto = generador.generar(TipoEngranaje.mcd, dificultad: dificultad);
        final [a, b] = reto.numeros;
        expect(reto.respuesta, mcd(a, b));
        expect(reto.respuesta, greaterThan(1));
        expect(reto.opciones.toSet().length, 4);
        expect(reto.opciones, contains(reto.respuesta));
        expect(reto.idHabilidad, 'DIV.06');
      }
    });

    test('Oxidado en dificultad $dificultad: una sola rueda de las cuatro hace coincidir', () {
      final generador = GeneradorEngranajes(azar: math.Random(20 + dificultad));
      for (var i = 0; i < 200; i++) {
        final reto = generador.generar(TipoEngranaje.oxidado, dificultad: dificultad);
        final a = reto.numeros.first;
        final validas = reto.opciones.where((o) => mcm(a, o) == reto.coincidencia).toList();
        expect(validas, [reto.respuesta]);
        expect(reto.opciones.toSet().length, 4);
      }
    });
  }

  test('tres ruedas: el mcm de las tres', () {
    final generador = GeneradorEngranajes(azar: math.Random(5));
    for (var i = 0; i < 100; i++) {
      final reto = generador.tresRuedas(dificultad: 2);
      expect(reto.numeros.length, 3);
      expect(reto.respuesta, mcmDeTodos(reto.numeros));
      expect(reto.opciones.toSet().length, 4);
      expect(reto.opciones, contains(reto.respuesta));
    }
  });
}
