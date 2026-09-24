import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/balanza.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart' show Celda, Direccion;
import 'package:uno_roto/dominio/minijuegos/flota.dart';
import 'package:uno_roto/dominio/minijuegos/retos_calculo.dart';
import 'package:uno_roto/dominio/minijuegos/serpiente.dart';

/// Evalúa los enunciados del generador de forma independiente.
int _evaluar(String enunciado) {
  final e = enunciado.replaceAll(' ', '');
  final porcentaje = RegExp(r'^(\d+)%de(\d+)$').firstMatch(e);
  if (porcentaje != null) {
    return int.parse(porcentaje[1]!) * int.parse(porcentaje[2]!) ~/ 100;
  }
  final fraccion = RegExp(r'^(\d+)/(\d+)de(\d+)$').firstMatch(e);
  if (fraccion != null) {
    return int.parse(fraccion[1]!) * int.parse(fraccion[3]!) ~/ int.parse(fraccion[2]!);
  }
  final potencia = RegExp(r'^(\d+)([²³])$').firstMatch(e);
  if (potencia != null) {
    return math.pow(int.parse(potencia[1]!), potencia[2] == '²' ? 2 : 3).toInt();
  }
  final parentesis = RegExp(r'^\((\d+)\+(\d+)\)×(\d+)$').firstMatch(e);
  if (parentesis != null) {
    return (int.parse(parentesis[1]!) + int.parse(parentesis[2]!)) * int.parse(parentesis[3]!);
  }
  final jerarquia = RegExp(r'^(\d+)\+(\d+)×(\d+)$').firstMatch(e);
  if (jerarquia != null) {
    return int.parse(jerarquia[1]!) + int.parse(jerarquia[2]!) * int.parse(jerarquia[3]!);
  }
  // Jerarquía con una fracción o un decimal: se evalúa con doubles.
  double valor(String x) => x.contains('/')
      ? int.parse(x.split('/')[0]) / int.parse(x.split('/')[1])
      : double.parse(x.replaceAll(',', '.'));
  final mixta = RegExp(r'^([\d/,]+)([+−×])([\d/,]+)([+−×])([\d/,]+)$').firstMatch(e);
  if (mixta != null && (e.contains('/') || e.contains(','))) {
    final [x, y, z] = [valor(mixta[1]!), valor(mixta[3]!), valor(mixta[5]!)];
    final resultado = mixta[2] == '×'
        ? (mixta[4] == '+' ? x * y + z : x * y - z)
        : (mixta[2] == '+' ? x + y * z : x - y * z);
    return resultado.round();
  }
  final conSigno = RegExp(r'^(−?\d+)([+−])(\d+)$').firstMatch(e);
  if (conSigno != null && e.contains('−')) {
    final primero = int.parse(conSigno[1]!.replaceAll('−', '-'));
    final segundo = int.parse(conSigno[3]!);
    return conSigno[2] == '+' ? primero + segundo : primero - segundo;
  }
  final suma = RegExp(r'^(\d+)\+(\d+)$').firstMatch(e);
  return int.parse(suma![1]!) + int.parse(suma[2]!);
}

void main() {
  group('Retos de cálculo', () {
    for (final id in habilidadesConRetoCalculo) {
      for (final dificultad in [1, 2, 3]) {
        test('$id d$dificultad: respuesta correcta y 3 distractores distintos', () {
          for (var semilla = 0; semilla < 80; semilla++) {
            final reto = GeneradorRetosCalculo(azar: math.Random(semilla))
                .generar(id, dificultad: dificultad);
            expect(reto.idHabilidad, id);
            expect(_evaluar(reto.enunciado), reto.respuesta, reason: reto.enunciado);
            expect(reto.distractores, hasLength(3));
            expect(reto.distractores.toSet(), hasLength(3));
            expect(reto.distractores, isNot(contains(reto.respuesta)));
            if (id != 'ARI.04') expect(reto.distractores.every((d) => d > 0), isTrue);
          }
        });
      }
    }

    test('los distractores de jerarquía incluyen el error típico', () {
      final reto = GeneradorRetosCalculo(azar: math.Random(1)).generar('OP.01');
      final m = RegExp(r'^(\d+) \+ (\d+) × (\d+)$').firstMatch(reto.enunciado)!;
      final izquierdaADerecha =
          (int.parse(m[1]!) + int.parse(m[2]!)) * int.parse(m[3]!);
      expect(reto.distractores, contains(izquierdaADerecha));
    });
  });

  group('Serpiente', () {
    PartidaSerpiente nueva() => PartidaSerpiente(
        habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(4));

    test('reparte la respuesta y tres distractores lejos de la cabeza', () {
      final partida = nueva();
      expect(partida.numeros.values, contains(partida.reto.respuesta));
      expect(partida.numeros.length, 4);
    });

    test('comer el bueno crece y cambia de reto; el malo cuenta fallo', () {
      final partida = nueva();
      final delante = Celda(partida.cabeza.fila, partida.cabeza.columna + 1);
      partida.numeros
        ..clear()
        ..[delante] = partida.reto.respuesta;
      final largo = partida.cuerpo.length;
      expect(partida.avanzar(), EventoSerpiente.correcto);
      expect(partida.cuerpo.length, largo + 1);

      final siguiente = Celda(partida.cabeza.fila, partida.cabeza.columna + 1);
      partida.numeros
        ..clear()
        ..[siguiente] = partida.reto.respuesta + 1;
      expect(partida.avanzar(), EventoSerpiente.incorrecto);
      expect(partida.cuerpo.length, largo + 1); // no se castiga encogiendo
      expect(partida.cerrarRonda(), {'ARI.01': true});
    });

    test('atraviesa los bordes y no puede dar media vuelta', () {
      final partida = nueva();
      partida.girar(Direccion.izquierda); // media vuelta: se ignora
      for (var i = 0; i < PartidaSerpiente.columnas; i++) {
        partida.numeros.clear();
        partida.avanzar();
      }
      expect(partida.direccion, Direccion.derecha);
      expect(partida.cabeza.columna, 3); // dio la vuelta entera
    });
  });

  group('Balanza', () {
    for (final id in ['ALG.01', 'ALG.02']) {
      for (final dificultad in [1, 2, 3]) {
        test('$id d$dificultad: equilibra sólo en la solución', () {
          for (var semilla = 0; semilla < 60; semilla++) {
            final ecuacion = GeneradorBalanza(azar: math.Random(semilla))
                .generar(id, dificultad: dificultad);
            expect(ecuacion.inclinacion(ecuacion.solucion), 0);
            expect(ecuacion.solucion, greaterThan(0));
            expect(ecuacion.inclinacion(ecuacion.solucion - 1), isNot(0));
            expect(ecuacion.inclinacion(ecuacion.solucion + 1), isNot(0));
            if (id == 'ALG.02') expect(ecuacion.bolsasDerecha, greaterThan(0));
          }
        });
      }
    }

    test('texto de la ecuación', () {
      const ecuacion = EcuacionBalanza(idHabilidad: 'ALG.02', bolsasIzquierda: 3,
          pesasIzquierda: 2, bolsasDerecha: 1, pesasDerecha: 10, solucion: 4);
      expect(ecuacion.texto, '3x + 2 = x + 10');
      expect(ecuacion.inclinacion(1), greaterThan(0)); // pesa más la derecha
    });
  });

  group('La flota', () {
    test('flota sin solapes y coordenadas cantadas que valen lo que dicen', () {
      for (var semilla = 0; semilla < 40; semilla++) {
        final partida = PartidaFlota(
            habilidades: ['PROP.04', 'FR.22'], dificultad: 2, azar: math.Random(semilla));
        final todas = partida.barcos.expand((b) => b.casillas).toList();
        expect(todas.toSet().length, 7);
        for (var disparo = 0; disparo < 20; disparo++) {
          for (final coordenada in [partida.columna, partida.fila]) {
            expect(_evaluar(coordenada.expresion), coordenada.valor,
                reason: coordenada.expresion);
            expect(coordenada.valor, inInclusiveRange(1, PartidaFlota.lado));
          }
          partida.tocar(partida.objetivo);
          if (partida.flotaHundida) break;
          partida.nuevoObjetivo();
        }
      }
    });

    test('equivocarse cuenta fallo pero dispara al objetivo verdadero', () {
      final partida = PartidaFlota(habilidades: ['PROP.04'], dificultad: 1, azar: math.Random(2));
      final objetivo = partida.objetivo;
      final otra = Celda((objetivo.fila + 1) % 8, objetivo.columna);
      final (acierta, _) = partida.tocar(otra);
      expect(acierta, isFalse);
      expect(partida.fallos, 1);
      expect(partida.disparos.containsKey(objetivo), isTrue);
      expect(partida.disparos.containsKey(otra), isFalse);
    });

    test('se hunde la flota disparando siempre bien', () {
      final partida = PartidaFlota(habilidades: ['FR.22'], dificultad: 1, azar: math.Random(5));
      var disparos = 0;
      while (!partida.flotaHundida && disparos < 64) {
        partida.tocar(partida.objetivo);
        disparos++;
        if (!partida.flotaHundida) partida.nuevoObjetivo();
      }
      expect(partida.flotaHundida, isTrue);
      expect(partida.aciertoPorHabilidad, {'FR.22': true});
    });
  });
}
