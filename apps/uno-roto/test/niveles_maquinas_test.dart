import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart';
import 'package:uno_roto/dominio/minijuegos/balanza.dart';
import 'package:uno_roto/dominio/minijuegos/encaje.dart';
import 'package:uno_roto/dominio/minijuegos/flota.dart';
import 'package:uno_roto/dominio/minijuegos/minas.dart';
import 'package:uno_roto/dominio/minijuegos/niveles_maquinas.dart';
import 'package:uno_roto/dominio/minijuegos/parejas.dart';
import 'package:uno_roto/dominio/minijuegos/puentes.dart';
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

  group('Máquinas de pensar por niveles', () {
    test('las rondas se reparten en tres tramos', () {
      expect([for (var r = 1; r <= 5; r++) nivelDeRonda(r, 5)], [1, 1, 2, 2, 3]);
      expect([for (var r = 1; r <= 6; r++) nivelDeRonda(r, 6)], [1, 1, 2, 2, 3, 3]);
      expect([for (var r = 1; r <= 3; r++) nivelDeRonda(r, 3)], [1, 2, 3]);
      expect([for (var r = 1; r <= 2; r++) nivelDeRonda(r, 2)], [1, 2]);
      expect(dificultadEnNivel(1, 3), (dificultad: 3, extra: 0));
      expect(dificultadEnNivel(2, 3), (dificultad: 3, extra: 1));
      expect(dificultadEnNivel(3, 1), (dificultad: 3, extra: 0));
    });

    test('Puentes: el extra trae más tablones y sigue habiendo solución', () {
      for (var semilla = 0; semilla < 20; semilla++) {
        final normal = GeneradorPuentes(semilla: semilla)
            .generar(ModoPuente.distintoDenominador, dificultad: 3);
        final conExtra = GeneradorPuentes(semilla: semilla)
            .generar(ModoPuente.distintoDenominador, dificultad: 3, extra: 2);
        expect(conExtra.tablones.length, normal.tablones.length + 2);
        expect(probarPuente(conExtra.hueco, conExtra.solucion), ResultadoPuente.exacto);
      }
    });

    test('Balanza: en dificultad 3 y con extra, la solución cuadra y cabe en el selector', () {
      final generador = GeneradorBalanza(azar: math.Random(5));
      for (var i = 0; i < 200; i++) {
        for (final id in ['ALG.01', 'ALG.02']) {
          final ecuacion = generador.generar(id, dificultad: 3, extra: i % 3);
          expect(ecuacion.inclinacion(ecuacion.solucion), 0);
          expect(ecuacion.solucion, inInclusiveRange(1, 20));
        }
      }
    });

    test('Minas: el extra pone más minas', () {
      int minas(int extra) => TableroMinas.generar(
              idHabilidad: 'DIV.01', dificultad: 3, extra: extra, azar: math.Random(2))
          .casillas
          .where((c) => c.esMina)
          .length;
      expect(minas(2), greaterThan(minas(0)));
    });

    test('Flota: en dificultad 3 las coordenadas cantadas siguen valiendo 1..8', () {
      final partida = PartidaFlota(
          habilidades: ['FR.22', 'PROP.04'], dificultad: 3, azar: math.Random(9));
      final vistas = <String>{};
      for (var valor = 1; valor <= 8; valor++) {
        for (var i = 0; i < 20; i++) {
          final cantada = partida.cantar(valor);
          vistas.add(cantada.expresion);
          final partes = cantada.expresion.split(' ');
          final cantidad = int.parse(partes.last);
          final calculado = partes[1] == '%'
              ? int.parse(partes[0]) * cantidad / 100
              : int.parse(partes[0].split('/')[0]) *
                  cantidad /
                  int.parse(partes[0].split('/')[1]);
          expect(calculado, valor.toDouble(), reason: cantada.expresion);
        }
      }
      expect(vistas.any((e) => e.contains('/5') || e.contains('/8') || e.startsWith('75 ') || e.startsWith('5 ')),
          isTrue);
    });

    test('Parejas: la carta trampa no tiene pareja ni vale lo que otra', () {
      var conTrampa = 0;
      for (var semilla = 0; semilla < 30; semilla++) {
        for (final habilidades in [['FR.09'], ['DEC.08'], ['PROP.05']]) {
          final tablero = GeneradorParejas(semilla: semilla)
              .generar(habilidades, dificultad: 3, conTrampa: true);
          if (tablero.trampas.isEmpty) continue;
          conTrampa++;
          expect(tablero.trampas.length, 1);
          final indiceTrampa = tablero.trampas.first;
          // No se puede emparejar con nada.
          for (var i = 0; i < tablero.cartas.length; i++) {
            if (i == indiceTrampa) continue;
            expect(tablero.cartas[i].idPareja, isNot(GeneradorParejas.idTrampa));
          }
          // Se completa sin ella.
          final porPareja = <int, List<int>>{};
          for (var i = 0; i < tablero.cartas.length; i++) {
            if (i != indiceTrampa) {
              porPareja.putIfAbsent(tablero.cartas[i].idPareja, () => []).add(i);
            }
          }
          for (final par in porPareja.values) {
            expect(tablero.emparejar(par[0], par[1]), isTrue);
          }
          expect(tablero.completo, isTrue);
        }
      }
      expect(conTrampa, greaterThan(60));
      expect(GeneradorParejas(semilla: 1).generar(['FR.09']).trampas, isEmpty);
    });
  });
}
