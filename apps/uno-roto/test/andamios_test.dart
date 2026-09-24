import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/andamios.dart';

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: medidas exactas y cuatro opciones distintas', () {
      final generador = GeneradorAndamios(azar: math.Random(dificultad));
      for (final tipo in TipoAndamio.values) {
        for (var i = 0; i < 200; i++) {
          final reto = generador.generar(tipo, dificultad: dificultad);
          final d = reto.datos;
          switch (tipo) {
            case TipoAndamio.plataforma:
              expect(reto.respuesta * reto.respuesta, d[0]);
            case TipoAndamio.escalera:
              expect(reto.respuesta * reto.respuesta, d[0] * d[0] + d[1] * d[1]);
            case TipoAndamio.apoyar:
              expect(reto.respuesta * reto.respuesta + d[1] * d[1], d[0] * d[0]);
          }
          expect(reto.opciones.toSet().length, 4, reason: '$tipo ${reto.opciones}');
          expect(reto.opciones, contains(reto.respuesta));
          expect(reto.opciones.every((o) => o > 0), isTrue);
        }
      }
    });
  }

  test('la suma de los catetos casi siempre tienta', () {
    final generador = GeneradorAndamios(azar: math.Random(9));
    var conSuma = 0;
    for (var i = 0; i < 100; i++) {
      final reto = generador.generar(TipoAndamio.escalera, dificultad: 2);
      if (reto.opciones.contains(reto.datos[0] + reto.datos[1])) conSuma++;
    }
    expect(conSuma, 100);
  });
}
