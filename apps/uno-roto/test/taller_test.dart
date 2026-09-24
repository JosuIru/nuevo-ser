import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/taller.dart';

int _valorEscrito(String texto) {
  // "1,75 kg", "1 kg 750 g", "850 g", "1,35 m", "135 cm", "1 m 35 cm", "2,3 l"…
  const factores = {'m': 100, 'cm': 1, 'kg': 1000, 'g': 1, 'l': 1000, 'ml': 1, 'dm': 10, 'dl': 100};
  final partes = texto.split(' ');
  var total = 0.0;
  for (var i = 0; i + 1 < partes.length; i += 2) {
    total += double.parse(partes[i].replaceAll(',', '.')) * factores[partes[i + 1]]!;
  }
  return total.round();
}

void main() {
  test('formatos', () {
    expect(enUnidadesMixtas(Banco.bascula, 1750), '1 kg 750 g');
    expect(enUnidadesMixtas(Banco.regla, 135), '1 m 35 cm');
    expect(enUnidadesMixtas(Banco.probetas, 500), '500 ml');
    expect(horaDe(23 * 60 + 50 + 25), '00:15');
  });

  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: lo escrito vale lo que dice y las piezas también', () {
      final generador = GeneradorTaller(azar: math.Random(dificultad));
      for (var i = 0; i < 150; i++) {
        for (final banco in [Banco.regla, Banco.bascula, Banco.probetas]) {
          final reto = generador.generar(banco, dificultad: dificultad);
          expect(_valorEscrito(reto.objetivo), reto.objetivoBase, reason: reto.objetivo);
          for (final pieza in reto.piezas) {
            expect(_valorEscrito(pieza.etiqueta), pieza.valor, reason: pieza.etiqueta);
          }
          // Siempre se puede llegar (la pieza más pequeña divide al objetivo).
          final menor = reto.piezas.map((p) => p.valor).reduce(math.min);
          expect(reto.objetivoBase % menor, 0);
          expect(reto.idHabilidad, banco == Banco.regla ? 'MED.01' : 'MED.02');
        }
        final reloj = generador.generar(Banco.reloj, dificultad: dificultad);
        expect(reloj.opcionBuena, horaDe(reloj.inicio + reloj.suma));
        expect(reloj.opciones.toSet().length, 4);
        expect(reloj.opciones, contains(reloj.opcionBuena));
        expect(reloj.idHabilidad, 'MED.03');
      }
    });
  }
}
