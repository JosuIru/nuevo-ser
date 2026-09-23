import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/minas.dart';

bool _esPrimo(int x) {
  if (x < 2) return false;
  for (var d = 2; d * d <= x; d++) {
    if (x % d == 0) return false;
  }
  return true;
}

void main() {
  for (final id in ['DIV.01', 'DIV.03', 'DIV.04', 'DIV.05']) {
    for (final dificultad in [1, 2, 3]) {
      test('$id d$dificultad: tamaño, 35 % de minas y bien marcadas', () {
        for (var semilla = 0; semilla < 25; semilla++) {
          final tablero = TableroMinas.generar(
              idHabilidad: id, dificultad: dificultad, azar: math.Random(semilla));
          expect(tablero.casillas.length, tablero.filas * tablero.columnas);
          final minas = tablero.casillas.where((c) => c.esMina).length;
          expect(minas, (tablero.casillas.length * 0.35).ceil());
          expect(tablero.casillas.map((c) => c.etiqueta).toSet().length,
              tablero.casillas.length);
          for (final casilla in tablero.casillas) {
            final x = int.parse(casilla.etiqueta);
            final esMina = id == 'DIV.05'
                ? _esPrimo(x)
                : x % tablero.regla.parametro! == 0;
            expect(casilla.esMina, esMina, reason: '${casilla.etiqueta} $id');
          }
          expect(textosReglaMinas.containsKey(id), isTrue);
        }
      });
    }
  }

  test('vecinas en esquina, borde y centro', () {
    final tablero = TableroMinas.generar(
        idHabilidad: 'DIV.01', dificultad: 1, azar: math.Random(1));
    expect(tablero.vecinas(0).length, 3);
    expect(tablero.vecinas(1).length, 5);
    expect(tablero.vecinas(tablero.columnas + 1).length, 8);
  });

  test('abrir y marcar: aciertos, fallos y la verdad a la vista', () {
    final tablero = TableroMinas.generar(
        idHabilidad: 'DIV.05', dificultad: 1, azar: math.Random(2));
    final mina = tablero.casillas.indexWhere((c) => c.esMina);
    final segura = tablero.casillas.indexWhere((c) => !c.esMina);
    final otraSegura = tablero.casillas.lastIndexWhere((c) => !c.esMina);

    expect(tablero.marcar(mina), ResultadoJugada.bien);
    expect(tablero.casillas[mina].estado, EstadoCasilla.marcada);
    expect(tablero.abrir(segura), ResultadoJugada.bien);
    expect(tablero.fallos, 0);

    expect(tablero.marcar(otraSegura), ResultadoJugada.fallo);
    expect(tablero.casillas[otraSegura].estado, EstadoCasilla.abierta);
    final otraMina = tablero.casillas.lastIndexWhere((c) => c.esMina);
    expect(tablero.abrir(otraMina), ResultadoJugada.fallo);
    expect(tablero.casillas[otraMina].estado, EstadoCasilla.desactivada);
    expect(tablero.fallos, 2);
    expect(tablero.acierto, isTrue);
    expect(tablero.abrir(otraMina), ResultadoJugada.ninguno);
  });

  test('se completa al resolver todas', () {
    final tablero = TableroMinas.generar(
        idHabilidad: 'DIV.01', dificultad: 1, azar: math.Random(3));
    for (var i = 0; i < tablero.casillas.length; i++) {
      tablero.casillas[i].esMina ? tablero.marcar(i) : tablero.abrir(i);
    }
    expect(tablero.completo, isTrue);
    expect(tablero.fallos, 0);
  });
}
