import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/porciones_tarta.dart';

void main() {
  group('porcionesServidas', () {
    test('redondea al trozo más cercano', () {
      // 5 trozos: cada uno son 72°.
      expect(porcionesServidas(0, 5), 0);
      expect(porcionesServidas(math.pi * 2 * 0.58, 5), 3); // 2,9 trozos
      expect(porcionesServidas(math.pi * 2 * 0.64, 5), 3); // 3,2 trozos
      expect(porcionesServidas(math.pi * 2, 5), 5);
    });

    test('no se sale de 0..denominador', () {
      expect(porcionesServidas(-1, 4), 0);
      expect(porcionesServidas(100, 4), 4);
      expect(porcionesServidas(1, 0), 0);
    });
  });

  group('anguloDesdeLasDoce', () {
    test('arriba 0, derecha π/2, abajo π, izquierda 3π/2', () {
      expect(anguloDesdeLasDoce(0, -1), closeTo(0, 1e-9));
      expect(anguloDesdeLasDoce(1, 0), closeTo(math.pi / 2, 1e-9));
      expect(anguloDesdeLasDoce(0, 1), closeTo(math.pi, 1e-9));
      expect(anguloDesdeLasDoce(-1, 0), closeTo(3 * math.pi / 2, 1e-9));
    });
  });

  group('RecorridoTarta', () {
    test('lo servido sigue al dedo, también hacia atrás', () {
      final recorrido = RecorridoTarta()..empezar(0);
      for (var paso = 1; paso <= 10; paso++) {
        recorrido.mover(math.pi * paso / 10);
      }
      expect(recorrido.anguloAcumulado, closeTo(math.pi, 1e-9));
      recorrido.mover(math.pi / 2);
      expect(recorrido.anguloAcumulado, closeTo(math.pi / 2, 1e-9));
    });

    test('un gesto nuevo no suma: va a donde está el dedo', () {
      final recorrido = RecorridoTarta()..fijarPorciones(2, 5);
      recorrido.empezar(0.05); // vuelve a empezar desde arriba
      final destino = 2 * math.pi * 3 / 5;
      for (var paso = 1; paso <= 12; paso++) {
        recorrido.mover(0.05 + (destino - 0.05) * paso / 12);
      }
      expect(porcionesServidas(recorrido.anguloAcumulado, 5), 3);
    });

    test('cruzar las 12 hacia delante la deja llena', () {
      final recorrido = RecorridoTarta()..empezar(5.9);
      recorrido.mover(6.2);
      recorrido.mover(0.1); // cruza las 12
      expect(recorrido.anguloAcumulado, 2 * math.pi);
      recorrido.mover(0.4); // sigue pasado las 12: continúa llena
      expect(recorrido.anguloAcumulado, 2 * math.pi);
      recorrido.mover(6.0); // vuelve a su lado: sigue al dedo
      expect(recorrido.anguloAcumulado, closeTo(6.0, 1e-9));
    });

    test('cruzar las 12 hacia atrás la deja vacía', () {
      final recorrido = RecorridoTarta()..empezar(0.4);
      recorrido.mover(0.1);
      recorrido.mover(6.2); // retrocede más allá de las 12
      expect(recorrido.anguloAcumulado, 0);
      recorrido.mover(5.9);
      expect(recorrido.anguloAcumulado, 0);
    });
  });
}
