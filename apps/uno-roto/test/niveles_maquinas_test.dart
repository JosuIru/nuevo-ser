import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart';
import 'package:uno_roto/dominio/minijuegos/encaje.dart';
import 'package:uno_roto/dominio/minijuegos/serpiente.dart';

/// Casillas alcanzables desde [origen] sin pisar muros (el tablero de la
/// serpiente se atraviesa por los bordes).
Set<Celda> _alcanzables(PartidaSerpiente partida, Celda origen) {
  final vistos = <Celda>{origen};
  final cola = Queue<Celda>()..add(origen);
  while (cola.isNotEmpty) {
    final actual = cola.removeFirst();
    for (final hacia in Direccion.values) {
      final vecina = Celda((actual.fila + hacia.dFila) % PartidaSerpiente.filas,
          (actual.columna + hacia.dColumna) % PartidaSerpiente.columnas);
      if (!partida.muros.contains(vecina) && vistos.add(vecina)) cola.add(vecina);
    }
  }
  return vistos;
}

void main() {
  group('Serpiente por niveles', () {
    test('nivel 2: muros separados, nada encerrado y ningún número debajo', () {
      for (var semilla = 0; semilla < 30; semilla++) {
        final partida = PartidaSerpiente(
            habilidades: ['ARI.01'], dificultad: 2, azar: math.Random(semilla));
        expect(partida.muros, isEmpty);
        partida.cambiarNivel(2);
        expect(partida.muros.length, greaterThanOrEqualTo(9), reason: 'semilla $semilla');
        expect(partida.numeros.keys.where(partida.muros.contains), isEmpty);
        expect(partida.muros.intersection(partida.cuerpo.toSet()), isEmpty);
        final libres = PartidaSerpiente.filas * PartidaSerpiente.columnas - partida.muros.length;
        expect(_alcanzables(partida, partida.cabeza).length, libres,
            reason: 'semilla $semilla: zona encerrada');
        expect(partida.numeros.length, 4);
      }
    });

    test('chocar con un muro la frena sin castigo; girando sigue', () {
      final partida = PartidaSerpiente(
          habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(1));
      partida.muros.add(Celda(partida.cabeza.fila, partida.cabeza.columna + 1));
      partida.numeros.clear();
      final cabezaAntes = partida.cabeza;
      expect(partida.avanzar(), EventoSerpiente.muro);
      expect(partida.cabeza, cabezaAntes);
      expect(partida.fallosPorHabilidad, isEmpty);
      partida.girar(Direccion.arriba);
      expect(partida.avanzar(), EventoSerpiente.nada);
      expect(partida.cabeza, isNot(cabezaAntes));
    });

    test('nivel 3: los números se mueven sin pisarse ni meterse en muros', () {
      final partida = PartidaSerpiente(
          habilidades: ['ARI.01'], dificultad: 2, azar: math.Random(7));
      partida.cambiarNivel(3);
      final antes = Map.of(partida.numeros);
      var cambiaron = false;
      for (var paso = 0; paso < 40; paso++) {
        // Gira a menudo para no comerse nada por casualidad.
        partida.girar(paso % 8 < 4 ? Direccion.arriba : Direccion.derecha);
        partida.avanzar();
        expect(partida.numeros.keys.where(partida.muros.contains), isEmpty);
        expect(partida.numeros.values.toSet().length, partida.numeros.length);
        if (!partida.numeros.keys.toSet().containsAll(antes.keys)) cambiaron = true;
      }
      expect(cambiaron, isTrue);
    });
  });

  group('Canales por niveles', () {
    PartidaCanales partida(int nivel, int semilla) => PartidaCanales(
          laberinto: LaberintoCanales(laberintosCanales[0]),
          regla: ReglaCanales.para('DIV.01', 1, math.Random(semilla))!,
          dificultad: 1,
          nivel: nivel,
          azar: math.Random(semilla),
        );

    test('dos sombras, luego tres; en el nivel 3 hay más trampas', () {
      expect(partida(1, 1).sombras.length, 2);
      expect(partida(2, 1).sombras.length, 3);
      final tercera = partida(3, 1);
      expect(tercera.sombras.length, 3);
      final trampas = tercera.numeros.values.where((n) => !n.cumple).length;
      expect(trampas, greaterThan(tercera.numeros.length ~/ 2));
    });

    test('la cazadora del nivel 3 se acerca siempre al niño', () {
      final juego = partida(3, 2);
      juego.direccionDeseada = null;
      int distancia() {
        var pasos = 0;
        var celda = juego.sombras[0];
        while (celda != juego.jugador && pasos < 200) {
          celda = juego.laberinto.primerPasoHacia(celda, juego.jugador)!;
          pasos++;
        }
        return pasos;
      }

      final inicial = distancia();
      // Un movimiento (cada dos ticks en dificultad 1); con más, otra
      // sombra podría pillar al niño y devolverlo todo a la salida.
      juego.avanzar();
      juego.avanzar();
      expect(distancia(), inicial - 1);
      expect(juego.esCazadora(0), isTrue);
      expect(juego.esCazadora(1), isFalse);
    });
  });

  group('Encaje por niveles', () {
    test('nivel 2 disfraza piezas también en dificultad 1', () {
      final generador = GeneradorEncaje(dificultad: 1, semilla: 3);
      final tablero = TableroEncaje();
      bool hayDisfraz() => List.generate(60, (_) => generador.siguiente(tablero))
          .any((pieza) => pieza.etiqueta.denominador != pieza.valor.denominador);
      expect(hayDisfraz(), isFalse);
      generador.nivel = 2;
      expect(hayDisfraz(), isTrue);
    });

    test('nivel 3 trae anchuras de la dificultad siguiente', () {
      final generador = GeneradorEncaje(dificultad: 1, semilla: 4);
      final tablero = TableroEncaje();
      Set<int> anchuras() =>
          {for (var i = 0; i < 80; i++) generador.siguiente(tablero).celdas};
      expect(anchuras(), {3, 6, 9});
      generador.nivel = 3;
      expect(anchuras().difference({3, 6, 9}), isNotEmpty);
    });
  });
}
