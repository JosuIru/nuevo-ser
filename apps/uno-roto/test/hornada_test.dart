import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/hornada.dart';

double _valor(String escrito) {
  if (escrito.contains(' y ')) {
    final [enteros, fraccion] = escrito.split(' y ');
    return int.parse(enteros) + _valor(fraccion);
  }
  final [n, d] = escrito.split('/').map(int.parse).toList();
  return n / d;
}

void main() {
  for (final dificultad in [1, 2, 3]) {
    test('dificultad $dificultad: los trozos que se piden valen lo escrito', () {
      final generador = GeneradorHornada(azar: math.Random(dificultad));
      for (final tipo in TipoPedido.values) {
        for (var i = 0; i < 100; i++) {
          final pedido = generador.generar(tipo, dificultad: dificultad);
          expect(pedido.trozos / pedido.cortes, closeTo(_valor(pedido.escrito), 1e-9),
              reason: '$tipo ${pedido.escrito} ${pedido.trozos}/${pedido.cortes}');
          expect(pedido.trozos, lessThanOrEqualTo(pedido.panes * pedido.cortes));
          if (tipo == TipoPedido.leer) {
            expect(pedido.opciones.toSet().length, 4);
            expect(pedido.opciones.where((o) => (_valor(o) - pedido.trozos / pedido.cortes).abs() < 1e-9), [pedido.escrito]);
          }
          if (tipo == TipoPedido.amplificar) {
            expect(int.parse(pedido.escrito.split('/')[1]), lessThan(pedido.cortes));
          }
          if (tipo == TipoPedido.simplificar) {
            expect(int.parse(pedido.escrito.split('/')[1]), greaterThan(pedido.cortes));
          }
        }
      }
    });
  }
}
