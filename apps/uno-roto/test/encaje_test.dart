import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/encaje.dart';
import 'package:uno_roto/dominio/problema_espejo.dart' show Fraccion;

PiezaEncaje _pieza(int numerador, int denominador) => PiezaEncaje(
      valor: Fraccion(numerador, denominador),
      etiqueta: Fraccion(numerador, denominador),
    );

void main() {
  test('fraccionDeCeldas simplifica sobre 12', () {
    expect(fraccionDeCeldas(4).etiqueta, '1/3');
    expect(fraccionDeCeldas(6).etiqueta, '1/2');
    expect(fraccionDeCeldas(5).etiqueta, '5/12');
    expect(_pieza(3, 4).celdas, 9);
  });

  test('una pieza cae hasta el fondo y la fila dice lo que falta', () {
    final tablero = TableroEncaje();
    tablero.entrar(_pieza(1, 2));
    tablero.moverA(0);
    expect(tablero.soltar(), ResultadoCaida.encajada);
    expect(tablero.celdasOcupadas(0), 6);
    expect(tablero.faltaEnFila(0)!.etiqueta, '1/2');
    expect(tablero.faltaEnFila(1), isNull);
  });

  test('1/2 + 1/3 + 1/6 completan una unidad y la fila se vacía', () {
    final tablero = TableroEncaje();
    for (final (pieza, columna) in [
      (_pieza(1, 2), 0),
      (_pieza(1, 3), 6),
      (_pieza(1, 6), 10),
    ]) {
      tablero.entrar(pieza);
      tablero.moverA(columna);
      tablero.soltar();
    }
    expect(tablero.unidades, 1);
    expect(tablero.celdasOcupadas(0), 0);
  });

  test('lo que queda encima baja al vaciarse una fila', () {
    final tablero = TableroEncaje();
    tablero.entrar(_pieza(1, 2));
    tablero.moverA(0);
    tablero.soltar(); // fila 0: [0,6)
    tablero.entrar(_pieza(1, 4));
    tablero.moverA(0);
    tablero.soltar(); // fila 1: [0,3), sobre la anterior
    expect(tablero.celdasOcupadas(1), 3);
    tablero.entrar(_pieza(1, 2));
    tablero.moverA(6);
    tablero.soltar(); // completa la fila 0
    expect(tablero.unidades, 1);
    expect(tablero.celdasOcupadas(0), 3);
  });

  test('moverA no atraviesa trozos ni se sale', () {
    final tablero = TableroEncaje();
    tablero.entrar(_pieza(3, 4));
    tablero.moverA(100);
    expect(tablero.columna, 3); // 12 - 9
    tablero.moverA(-5);
    expect(tablero.columna, 0);
  });

  test('si la pila llega arriba, Rexán vacía el tablero sin castigo', () {
    final tablero = TableroEncaje();
    for (var i = 0; i < filasEncaje; i++) {
      tablero.entrar(_pieza(1, 2));
      tablero.moverA(3);
      tablero.soltar();
    }
    expect(tablero.entrar(_pieza(1, 2)), ResultadoCaida.tableroVaciado);
    expect(tablero.vaciados, 1);
    expect(tablero.celdasOcupadas(0), 0);
    expect(tablero.piezaActual, isNotNull);
  });

  test('el generador respeta las anchuras y las etiquetas son equivalentes', () {
    for (final dificultad in [1, 2, 3]) {
      final generador = GeneradorEncaje(dificultad: dificultad, semilla: 1);
      final tablero = TableroEncaje();
      for (var i = 0; i < 200; i++) {
        final pieza = generador.siguiente(tablero);
        expect(pieza.celdas, inInclusiveRange(1, 11));
        expect(pieza.valor.esEquivalenteA(pieza.etiqueta), isTrue);
        if (dificultad == 1) {
          expect([3, 6, 9], contains(pieza.celdas));
          expect(pieza.etiqueta.etiqueta, pieza.valor.etiqueta);
        }
      }
    }
  });

  test('a veces trae justo la pieza que cierra la fila más baja', () {
    final tablero = TableroEncaje();
    tablero.entrar(_pieza(1, 4));
    tablero.moverA(0);
    tablero.soltar(); // falta 3/4 = 9 celdas
    final generador = GeneradorEncaje(dificultad: 1, semilla: 2);
    final anchuras = [for (var i = 0; i < 40; i++) generador.siguiente(tablero).celdas];
    expect(anchuras.where((celdas) => celdas == 9).length, greaterThan(15));
  });
}
