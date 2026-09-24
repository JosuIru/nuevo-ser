import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/redes.dart';

double _valor(String texto) {
  if (texto.endsWith(' %')) return int.parse(texto.replaceAll(' %', '')) / 100;
  if (texto.contains('/')) {
    final [a, b] = texto.split('/').map(int.parse).toList();
    return a / b;
  }
  return double.parse(texto.replaceAll(',', '.'));
}

void main() {
  test('escrituras de la misma probabilidad', () {
    expect(comoFraccion(6, 20), '3/10');
    expect(comoDecimal(6, 20), '0,3');
    expect(comoPorcentaje(6, 20), '30 %');
    expect(comoDecimal(1, 4), '0,25');
  });

  for (final dificultad in [1, 2, 3]) {
    test('elegir red en dificultad $dificultad: una sola mejor, sin empates', () {
      final generador = GeneradorRedes(azar: math.Random(dificultad));
      for (final nivel in [1, 2]) {
        for (var i = 0; i < 150; i++) {
          final reto = generador.generar(nivel, dificultad: dificultad);
          expect(reto.redes.length, dificultad >= 3 ? 3 : 2);
          final mejor = reto.redes[reto.mejor!].probabilidad;
          for (var j = 0; j < reto.redes.length; j++) {
            if (j != reto.mejor) expect(reto.redes[j].probabilidad, lessThan(mejor));
            expect(reto.redes[j].ambar, inInclusiveRange(1, reto.redes[j].total - 1));
          }
          if (nivel == 1) expect(reto.redes.map((r) => r.total).toSet().length, 1);
          expect(reto.idHabilidad, 'EST.05');
        }
      }
    });
  }

  test('en el nivel 2, casi siempre la red con más ámbar no es la mejor', () {
    final generador = GeneradorRedes(azar: math.Random(4));
    var trampas = 0;
    for (var i = 0; i < 200; i++) {
      final reto = generador.generar(2, dificultad: 2);
      final masAmbar = reto.redes.indexWhere(
          (r) => r.ambar == reto.redes.map((r) => r.ambar).reduce(math.max));
      if (masAmbar != reto.mejor) trampas++;
    }
    expect(trampas, greaterThan(100));
  });

  test('notación: una sola opción vale lo que la probabilidad', () {
    final generador = GeneradorRedes(azar: math.Random(5));
    for (var i = 0; i < 200; i++) {
      final reto = generador.generar(3, dificultad: 1 + i % 3);
      final red = reto.redes.single;
      expect(reto.opciones.length, 4);
      final buenas = reto.opciones.where((o) => (_valor(o) - red.probabilidad).abs() < 1e-9).toList();
      expect(buenas, [reto.respuesta]);
      expect(reto.idHabilidad, 'EST.06');
    }
  });

  test('los lances salen con la frecuencia esperada a la larga', () {
    final lances = lanzar(const Red(3, 10), 10000, math.Random(1));
    final ambar = lances.where((l) => l).length / lances.length;
    expect(ambar, closeTo(0.3, 0.02));
  });
}
