import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/rebote.dart';

void main() {
  test('clasificar ángulos', () {
    expect(clasificarAngulo(30), TipoAngulo.agudo);
    expect(clasificarAngulo(90), TipoAngulo.recto);
    expect(clasificarAngulo(120), TipoAngulo.obtuso);
    expect(clasificarAngulo(180), TipoAngulo.llano);
  });

  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: medir, clasificar, láser y reflexión cuadran', () {
      final generador = GeneradorRebote(azar: math.Random(dificultad));
      for (var i = 0; i < 150; i++) {
        final medir = generador.generar(TipoRebote.medir, dificultad: dificultad);
        expect(medir.respuesta, medir.grados);
        expect(medir.opciones.toSet().length, 4);
        expect(medir.opciones, contains(medir.respuesta));

        final clasificar = generador.generar(TipoRebote.clasificar, dificultad: dificultad);
        expect(TipoAngulo.values[clasificar.respuesta], clasificarAngulo(clasificar.grados));

        final laser = generador.generar(TipoRebote.laser, dificultad: dificultad);
        final l = laser.laser!;
        expect(l.alturaDeLlegada(laser.respuesta), closeTo(l.alturaDiana, 1e-9));
        // Sólo el ángulo bueno llega a la diana.
        final llegan = laser.opciones.where((a) => (l.alturaDeLlegada(a) - l.alturaDiana).abs() < 0.3);
        expect(llegan, [laser.respuesta]);

        final reflexion = generador.generar(TipoRebote.reflexion, dificultad: dificultad);
        expect(reflexion.respuesta, reflexion.grados);
        expect(reflexion.opciones.toSet().length, 4);
        expect(reflexion.opciones, contains(reflexion.respuesta));
      }
    });
  }

  test('simetría: figura a la izquierda, reflejo a la derecha', () {
    final generador = GeneradorRebote(azar: math.Random(3));
    for (var i = 0; i < 100; i++) {
      final reto = generador.generar(TipoRebote.simetria, dificultad: 1 + i % 3);
      expect(reto.figura.every((c) => c.columna < reto.columnas ~/ 2), isTrue);
      expect(reto.reflejo.every((c) => c.columna >= reto.columnas ~/ 2), isTrue);
      expect(reto.reflejo.length, reto.figura.length);
    }
  });
}
