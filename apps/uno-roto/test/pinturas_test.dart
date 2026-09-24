import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/pinturas.dart';

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: cada tipo con su respuesta correcta', () {
      final generador = GeneradorPinturas(azar: math.Random(dificultad));
      for (var i = 0; i < 150; i++) {
        final reconocer = generador.generar(TipoPintura.reconocer, dificultad: dificultad);
        final buenos = [
          for (var k = 0; k < reconocer.cubos.length; k++)
            if (reconocer.receta.mismoColor(reconocer.cubos[k].$1, reconocer.cubos[k].$2)) k,
        ];
        expect(buenos, [reconocer.respuesta]);
        expect(reconocer.cubos.length, 4);

        final total = generador.generar(TipoPintura.escalarTotal, dificultad: dificultad);
        final amarilloDeTotal = total.dato - total.respuesta;
        expect(total.receta.mismoColor(total.respuesta, amarilloDeTotal), isTrue);

        final parte = generador.generar(TipoPintura.escalarParte, dificultad: dificultad);
        expect(parte.receta.mismoColor(parte.dato, parte.respuesta), isTrue);

        final escala = generador.generar(TipoPintura.escala, dificultad: dificultad);
        expect(escala.respuesta, escala.dato * escala.dato2);
        expect(escala.opciones.toSet().length, 4);
        expect(escala.opciones, contains(escala.respuesta));

        final rebaja = generador.generar(TipoPintura.rebaja, dificultad: dificultad);
        expect(rebaja.respuesta * 100, rebaja.dato * (100 - rebaja.dato2));
        expect(rebaja.opciones.toSet().length, 4);
        expect(rebaja.opciones, contains(rebaja.respuesta));
      }
    });
  }

  test('habilidades por tipo', () {
    final generador = GeneradorPinturas(azar: math.Random(1));
    expect(generador.generar(TipoPintura.reconocer).idHabilidad, 'PROP.01');
    expect(generador.generar(TipoPintura.escalarTotal).idHabilidad, 'PROP.02');
    expect(generador.generar(TipoPintura.escalarParte).idHabilidad, 'PROP.03');
    expect(generador.generar(TipoPintura.escala).idHabilidad, 'PROP.07');
    expect(generador.generar(TipoPintura.rebaja).idHabilidad, 'PROP.06');
  });
}
