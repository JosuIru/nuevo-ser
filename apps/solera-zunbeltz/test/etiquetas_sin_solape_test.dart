import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/etiquetas_sin_solape.dart';

RotuloMapa<String> rotulo(String clave, double x, double y, num prioridad) =>
    RotuloMapa(
        clave: clave,
        centro: Offset(x, y),
        tamano: const Size(100, 30),
        prioridad: prioridad);

void main() {
  test('los que no se tocan salen todos', () {
    expect(rotulosSinSolape([rotulo('a', 0, 0, 1), rotulo('b', 200, 0, 1)]),
        {'a', 'b'});
  });

  test('si chocan, gana el de más prioridad aunque venga después', () {
    expect(
        rotulosSinSolape(
            [rotulo('grande', 0, 0, 5), rotulo('pequena', 50, 10, 1)]),
        {'pequena'});
  });

  test('a igual prioridad gana el primero; el margen cuenta', () {
    expect(
        rotulosSinSolape([rotulo('a', 0, 0, 1), rotulo('b', 102, 0, 1)]), {'a'},
        reason: 'a 2 px no se tocan, pero con 4 px de aire sí');
    expect(
        rotulosSinSolape([rotulo('a', 0, 0, 1), rotulo('b', 102, 0, 1)],
            margen: 0),
        {'a', 'b'});
  });

  test('uno oculto no tapa a los demás', () {
    // b choca con a y queda fuera; c solo chocaría con b: sale.
    expect(
        rotulosSinSolape([
          rotulo('a', 0, 0, 1),
          rotulo('b', 80, 0, 2),
          rotulo('c', 160, 0, 3),
        ]),
        {'a', 'c'});
  });

  test('un obstáculo (un marcador, un botón) deja fuera lo que pisa', () {
    expect(
        rotulosSinSolape([rotulo('a', 0, 0, 1), rotulo('b', 300, 0, 1)],
            obstaculos: [Rect.fromCircle(center: Offset.zero, radius: 20)]),
        {'b'});
  });
}
