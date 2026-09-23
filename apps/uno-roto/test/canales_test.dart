import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart';

bool _esPrimo(int x) {
  if (x < 2) return false;
  for (var d = 2; d * d <= x; d++) {
    if (x % d == 0) return false;
  }
  return true;
}

double _valor(String etiqueta) {
  if (etiqueta.contains('/')) {
    final partes = etiqueta.split('/');
    return int.parse(partes[0]) / int.parse(partes[1]);
  }
  return double.parse(etiqueta.replaceAll(',', '.'));
}

void main() {
  group('Laberintos', () {
    for (var i = 0; i < laberintosCanales.length; i++) {
      test('laberinto $i: rectangular, con S y G, sin zonas aisladas', () {
        final laberinto = LaberintoCanales(laberintosCanales[i]);
        expect(laberintosCanales[i].every((f) => f.length == laberinto.ancho),
            isTrue);
        final alcanzables = laberinto.alcanzables(laberinto.salida);
        expect(alcanzables, contains(laberinto.guarida));
        expect(alcanzables.length, laberinto.canales.length);
        // Hay sitio para los números de la dificultad más alta.
        expect(laberinto.canales.length, greaterThan(30));
      });
    }

    test('primerPasoHacia da un vecino más cerca', () {
      final laberinto = LaberintoCanales(laberintosCanales.first);
      final paso =
          laberinto.primerPasoHacia(laberinto.guarida, laberinto.salida)!;
      expect(laberinto.vecinos(laberinto.guarida), contains(paso));
    });
  });

  group('Reglas', () {
    final comprobaciones = <String, bool Function(String, int?)>{
      'DIV.01': (e, n) => int.parse(e) % n! == 0,
      'DIV.03': (e, n) => int.parse(e) % n! == 0,
      'DIV.04': (e, n) => int.parse(e) % n! == 0,
      'DIV.05': (e, _) => _esPrimo(int.parse(e)),
      'DEC.02': (e, _) => _valor(e) > 0.5,
      'FR.03': (e, _) => _valor(e) > 0.5,
    };
    comprobaciones.forEach((idHabilidad, cumpleDeVerdad) {
      for (final dificultad in [1, 2, 3]) {
        test('$idHabilidad d$dificultad: marca bien, mitad y mitad, sin repetir',
            () {
          for (var semilla = 0; semilla < 30; semilla++) {
            final azar = math.Random(semilla);
            final regla = ReglaCanales.para(idHabilidad, dificultad, azar)!;
            // Los mismos que reparte la partida: 8 + 2 × dificultad.
            final cuantos = 8 + 2 * dificultad;
            final numeros = regla.generar(azar, cuantos);
            expect(numeros.length, cuantos);
            expect(numeros.map((n) => n.etiqueta).toSet().length, cuantos);
            expect(numeros.where((n) => n.cumple).length, cuantos ~/ 2);
            for (final numero in numeros) {
              expect(numero.cumple, cumpleDeVerdad(numero.etiqueta, regla.parametro),
                  reason: '${numero.etiqueta} con ${regla.texto} ${regla.parametro}');
            }
          }
        });
      }
    });

    test('habilidad sin regla', () {
      expect(ReglaCanales.para('GEO.01', 1, math.Random(1)), isNull);
    });
  });

  group('Partida', () {
    PartidaCanales nueva({int dificultad = 1}) => PartidaCanales(
          laberinto: LaberintoCanales(laberintosCanales.first),
          regla: ReglaCanales.para('DIV.05', 1, math.Random(3))!,
          dificultad: dificultad,
          azar: math.Random(3),
        );

    test('reparte números fuera de la salida y la guarida', () {
      final partida = nueva();
      expect(partida.numeros.length, 10);
      expect(partida.numeros.containsKey(partida.laberinto.salida), isFalse);
      expect(partida.numeros.containsKey(partida.laberinto.guarida), isFalse);
      expect(partida.pendientes, 5);
    });

    test('comer un número: recoger si cumple, fallo si no', () {
      final partida = nueva();
      final salida = partida.laberinto.salida;
      final destino = salida.mas(Direccion.derecha);
      partida.sombras = [const Celda(1, 1), const Celda(1, 1)];
      partida.numeros[destino] = const NumeroCanal('7', cumple: true);
      partida.direccionDeseada = Direccion.derecha;
      expect(partida.avanzar(), EventoCanales.recogido);
      expect(partida.recogidos, 1);

      final siguiente = destino.mas(Direccion.derecha);
      partida.numeros[siguiente] = const NumeroCanal('8', cumple: false);
      expect(partida.avanzar(), EventoCanales.noCumplia);
      expect(partida.noCumplian, 1);
      expect(partida.ultimoFallo!.etiqueta, '8');
      expect(partida.acierto, isTrue); // un fallo aún es acierto
    });

    test('si una sombra lo pilla vuelve a la salida, sin perder nada', () {
      final partida = nueva();
      final salida = partida.laberinto.salida;
      final destino = salida.mas(Direccion.derecha);
      partida.numeros.remove(destino);
      partida.sombras = [destino, destino];
      partida.direccionDeseada = Direccion.derecha;
      expect(partida.avanzar(), EventoCanales.pillado);
      expect(partida.jugador, salida);
      expect(partida.pillado, 1);
      expect(partida.recogidos, 0);
    });

    test('recoger el último que cumple termina el laberinto', () {
      final partida = nueva();
      partida.numeros.removeWhere((_, n) => n.cumple);
      final destino = partida.laberinto.salida.mas(Direccion.derecha);
      partida.numeros[destino] = const NumeroCanal('11', cumple: true);
      partida.sombras = [const Celda(1, 1), const Celda(1, 1)];
      partida.direccionDeseada = Direccion.derecha;
      expect(partida.avanzar(), EventoCanales.laberintoTerminado);
      expect(partida.terminado, isTrue);
    });

    test('no atraviesa muros', () {
      final partida = nueva();
      partida.sombras = [const Celda(11, 9), const Celda(11, 9)];
      // En la esquina (1,1) arriba es muro.
      partida.jugador = const Celda(1, 1);
      partida.direccionDeseada = Direccion.arriba;
      partida.avanzar();
      expect(partida.jugador, const Celda(1, 1));
    });
  });
}
