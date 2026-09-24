import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/pozo.dart';

void main() {
  test('el recorrido aplica los Signos', () {
    expect(recorrido(2, const [Orden(TipoOrden.mover, -7)]), [2, -5]);
    expect(recorrido(0, const [Orden(TipoOrden.dobleNegacion, 5)]), [0, 5]);
    expect(recorrido(0, const [Orden(TipoOrden.mover, 3), Orden(TipoOrden.eco)]), [0, 3, 6]);
    expect(
        recorrido(0, const [
          Orden(TipoOrden.mover, 4),
          Orden(TipoOrden.invertido),
          Orden(TipoOrden.mover, 6),
        ]),
        [0, 4, -2]);
    expect(const Orden(TipoOrden.mover, -7).etiqueta, '−7');
    expect(const Orden(TipoOrden.dobleNegacion, 5).etiqueta, '−(−5)');
  });

  for (final dificultad in [1, 2, 3]) {
    test('viajes en dificultad $dificultad: cruzan el suelo y no se salen', () {
      final generador = GeneradorPozo(azar: math.Random(dificultad));
      for (final nivel in [1, 2]) {
        for (var i = 0; i < 150; i++) {
          final reto = generador.generar(TipoPozo.viaje, nivel: nivel, dificultad: dificultad);
          final paradas = recorrido(reto.inicio, reto.ordenes);
          expect(reto.respuesta, paradas.last);
          expect(paradas.any((p) => p < 0) && paradas.any((p) => p > 0), isTrue);
          expect(paradas.every((p) => p.abs() <= (dificultad == 1 ? 10 : 15)), isTrue);
          if (nivel == 1) {
            expect(reto.ordenes.every((o) => o.tipo == TipoOrden.mover), isTrue);
          }
          expect(reto.idHabilidad, 'ARI.04');
        }
      }
    });
  }

  test('valor absoluto: espejo y distancia', () {
    final generador = GeneradorPozo(azar: math.Random(7));
    for (var i = 0; i < 100; i++) {
      final espejo = generador.generar(TipoPozo.espejo, nivel: 3, dificultad: 2);
      expect(espejo.respuesta, -espejo.plantas.single);
      expect(espejo.respuesta.abs(), espejo.plantas.single.abs());
      final distancia = generador.generar(TipoPozo.distancia, nivel: 3, dificultad: 2);
      final [a, b] = distancia.plantas;
      expect(distancia.respuesta, (a - b).abs());
      expect(distancia.opciones.toSet().length, 4);
      expect(distancia.opciones, contains(distancia.respuesta));
      expect(distancia.idHabilidad, 'ARI.05');
    }
  });
}
