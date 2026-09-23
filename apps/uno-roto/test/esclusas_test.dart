import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/esclusas.dart';

double _valorDe(String etiqueta) {
  if (etiqueta.contains('/')) {
    final [n, d] = etiqueta.split('/').map(int.parse).toList();
    return n / d;
  }
  return double.parse(etiqueta.replaceAll(',', '.'));
}

/// Juega una ronda entera sin fallar.
void _jugarBien(PartidaEsclusas partida) {
  var vueltas = 0;
  while (!partida.terminada && vueltas++ < 100) {
    final carga = partida.carga;
    if (carga.tipo == TipoCarga.suelta) {
      partida.abrir(carga.esclusaBuena!);
    } else {
      for (final indice in carga.ordenBueno.take(carga.tipo == TipoCarga.pareja ? 1 : 3)) {
        partida.tocar(indice);
      }
    }
  }
}

void main() {
  test('las etiquetas dicen la verdad (también las disfrazadas)', () {
    for (final nivel in [1, 2, 3]) {
      for (final dificultad in [1, 2, 3]) {
        final partida = PartidaEsclusas(nivel: nivel, dificultad: dificultad, azar: math.Random(nivel * 10 + dificultad));
        for (var i = 0; i < 40; i++) {
          for (final barca in partida.carga.barcas) {
            expect(_valorDe(barca.etiqueta), closeTo(barca.valor, 1e-9), reason: barca.etiqueta);
          }
          // Avanza a otra carga resolviéndola.
          final carga = partida.carga;
          if (carga.tipo == TipoCarga.suelta) {
            partida.abrir(carga.esclusaBuena!);
          } else {
            for (final indice in carga.ordenBueno.take(carga.tipo == TipoCarga.pareja ? 1 : 3)) {
              partida.tocar(indice);
            }
          }
          if (partida.terminada) break;
        }
      }
    }
  });

  test('sueltas: la esclusa buena es la de su rango, nunca en el borde', () {
    final partida = PartidaEsclusas(nivel: 1, dificultad: 2, azar: math.Random(3));
    for (var i = 0; i < 6 && !partida.terminada; i++) {
      final barca = partida.carga.barcas.first;
      expect(barca.valor, isNot(closeTo(partida.esclusas.umbral, 1e-9)));
      expect(barca.valor, isNot(closeTo(1, 1e-9)));
      final esperada = barca.valor < partida.esclusas.umbral ? 0 : (barca.valor < 1 ? 1 : 2);
      expect(partida.carga.esclusaBuena, esperada);
      expect(partida.carga.idHabilidad, barca.valor > 1 ? 'FR.04' : 'FR.05');
      partida.abrir(esperada);
    }
  });

  test('parejas y tríos: valores distintos y el orden bueno', () {
    for (final nivel in [2, 3]) {
      final partida = PartidaEsclusas(nivel: nivel, dificultad: 3, azar: math.Random(nivel));
      for (var i = 0; i < 6 && !partida.terminada; i++) {
        final carga = partida.carga;
        final valores = carga.barcas.map((b) => b.valor).toList();
        expect(valores.toSet().length, valores.length);
        final orden = carga.ordenBueno.map((i) => valores[i]).toList();
        if (carga.tipo == TipoCarga.pareja) {
          expect(orden.first, valores.reduce(math.max));
          expect(carga.idHabilidad, anyOf('FR.06', 'FR.07'));
        } else {
          expect(orden, [...valores]..sort());
          expect(carga.idHabilidad, anyOf('FR.08', 'DEC.03'));
        }
        partida.tocar(carga.ordenBueno.first);
        if (carga.tipo == TipoCarga.trio) {
          partida.tocar(carga.ordenBueno[1]);
          partida.tocar(carga.ordenBueno[2]);
        }
      }
    }
  });

  test('una ronda sin fallos: todo acierto', () {
    for (final nivel in [1, 2, 3]) {
      final partida = PartidaEsclusas(nivel: nivel, dificultad: 2, azar: math.Random(7));
      _jugarBien(partida);
      expect(partida.terminada, isTrue);
      expect(partida.resultadoRonda().values.every((acierto) => acierto), isTrue);
      expect(partida.fallosPorHabilidad, isEmpty);
    }
  });

  test('un fallo cuenta una vez por grupo; el trío vuelve a empezar', () {
    final partida = PartidaEsclusas(nivel: 3, dificultad: 1, azar: math.Random(2));
    final carga = partida.carga;
    final orden = carga.ordenBueno;
    expect(partida.tocar(orden[0]), EventoEsclusas.acierto);
    expect(partida.yaPasada(orden[0]), isTrue);
    expect(partida.tocar(orden[2]), EventoEsclusas.fallo);
    expect(partida.yaPasada(orden[0]), isFalse); // vuelve a empezar
    expect(partida.tocar(orden[1]), EventoEsclusas.fallo); // segundo fallo, mismo grupo
    expect(partida.fallosPorHabilidad[carga.idHabilidad], 1);
    for (final indice in orden) {
      partida.tocar(indice);
    }
    expect(partida.cargasHechas, 1);
    expect(partida.aciertosPorHabilidad, isEmpty); // ese grupo no fue a la primera
  });

  test('llegar abajo sin decidir devuelve arriba y no cuenta', () {
    final partida = PartidaEsclusas(nivel: 1, dificultad: 1, azar: math.Random(1));
    var devuelta = false;
    for (var i = 0; i < 60 * 20 && !devuelta; i++) {
      devuelta = partida.avanzar(1 / 60) == EventoEsclusas.devuelta;
    }
    expect(devuelta, isTrue);
    expect(partida.posicion, 0);
    expect(partida.fallosPorHabilidad, isEmpty);
    expect(partida.cargasHechas, 0);
  });
}
