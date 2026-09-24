import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/tranvia.dart';

void main() {
  test('decimales en centésimas', () {
    expect(enDecimal(125), '1,25');
    expect(enDecimal(250), '2,5');
    expect(enDecimal(300), '3');
    expect(enDecimal(5), '0,05');
  });

  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: cada tipo con su respuesta', () {
      final generador = GeneradorTranvia(azar: math.Random(dificultad));
      for (var i = 0; i < 150; i++) {
        final situar = generador.generar(TipoTranvia.situar, dificultad: dificultad);
        expect(situar.respuesta, situar.valor);
        expect((situar.valor - situar.desde) % situar.paso, 0);
        expect(situar.valor, inInclusiveRange(situar.desde, situar.hasta));

        final redondear = generador.generar(TipoTranvia.redondear, dificultad: dificultad);
        final mitad = redondear.paso / 2;
        expect((redondear.valor - redondear.respuesta).abs(), lessThan(mitad));
        expect(redondear.respuesta % redondear.paso, 0);
        expect(redondear.respuesta, inInclusiveRange(redondear.desde, redondear.hasta));

        final m = generador.generar(TipoTranvia.multiplicar, dificultad: dificultad);
        expect(m.respuesta, m.datos[0] * m.datos[1]);
        final md = generador.generar(TipoTranvia.multiplicarDecimales, dificultad: dificultad);
        expect(md.respuesta * 100, md.datos[0] * md.datos[1]);
        final d = generador.generar(TipoTranvia.dividir, dificultad: dificultad);
        expect(d.respuesta * d.datos[1], d.datos[0]);
        for (final reto in [m, md, d]) {
          expect(reto.opciones.toSet().length, 4);
          expect(reto.opciones, contains(reto.respuesta));
        }
      }
    });
  }
}
