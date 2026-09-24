import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';
import 'package:uno_roto/dominio/minijuegos/engranajes.dart';
import 'package:uno_roto/dominio/minijuegos/esclusas.dart';
import 'package:uno_roto/dominio/minijuegos/planos.dart';
import 'package:uno_roto/dominio/minijuegos/pozo.dart';
import 'package:uno_roto/dominio/minijuegos/rebote.dart';
import 'package:uno_roto/dominio/minijuegos/reto_semanal.dart';

void main() {
  final todas = {
    for (final especial in especialesSemanales) especial.maquina: especial.habilidades,
  };

  test('el reto es el mismo de lunes a domingo y cambia el lunes', () {
    final lunes = DateTime(2026, 9, 21);
    final reto = retoDeLaSemana(lunes, todas);
    for (var dia = 1; dia < 7; dia++) {
      expect(retoDeLaSemana(lunes.add(Duration(days: dia)), todas), same(reto));
    }
    expect(retoDeLaSemana(lunes.add(const Duration(days: 7)), todas), isNot(same(reto)));
  });

  test('en tantas semanas como especiales salen todos', () {
    final vistos = {
      for (var semana = 0; semana < especialesSemanales.length; semana++)
        retoDeLaSemana(DateTime(2026, 1, 5).add(Duration(days: 7 * semana)), todas)!.especial,
    };
    expect(vistos, EspecialSemanal.values.toSet());
  });

  test('sólo sale un reto de lo ya practicado; si no hay nada, ninguno', () {
    expect(retoDeLaSemana(DateTime(2026, 9, 21), const {}), isNull);
    final soloMinas = {IdMinijuego.minas: ['DIV.01', 'DIV.02']};
    for (var semana = 0; semana < 10; semana++) {
      final reto = retoDeLaSemana(DateTime(2026, 1, 5).add(Duration(days: 7 * semana)), soloMinas)!;
      expect(reto.especial, EspecialSemanal.soloDivisores);
      expect(habilidadesDelReto(reto, soloMinas[IdMinijuego.minas]!), ['DIV.02']);
    }
    // Minas encendida pero sin divisores practicados: no hay reto.
    expect(retoDeLaSemana(DateTime(2026, 9, 21), {IdMinijuego.minas: ['DIV.01']}), isNull);
  });

  test('cada especial es de una máquina con esas habilidades', () {
    for (final especial in especialesSemanales) {
      final definicion = CatalogoMinijuegos.de(especial.maquina);
      for (final id in especial.habilidades) {
        expect(definicion.habilidades, contains(id), reason: '${especial.nombre}: $id');
      }
    }
  });

  test('la rueda loca: una rueda prima y el MCM es el producto', () {
    final generador = GeneradorEngranajes(azar: math.Random(3));
    for (final dificultad in [1, 2, 3]) {
      for (var i = 0; i < 50; i++) {
        final reto = generador.ruedaLoca(dificultad: dificultad);
        final [a, b] = reto.numeros;
        expect([5, 7, 11, 13].contains(a) || [5, 7, 11, 13].contains(b), isTrue);
        expect(reto.respuesta, mcm(a, b));
        expect(reto.respuesta, a * b);
        expect(reto.opciones.toSet().length, 4);
        expect(reto.opciones, contains(reto.respuesta));
      }
    }
  });

  test('el atasco: las barcas no se mueven', () {
    final partida = PartidaEsclusas(nivel: 3, dificultad: 3, quietas: true, azar: math.Random(1));
    for (var i = 0; i < 100; i++) {
      expect(partida.avanzar(0.5), EventoEsclusas.nada);
    }
    expect(partida.posicion, 0);
  });

  test('sin transportador: opciones separadas al menos 20°', () {
    final generador = GeneradorRebote(azar: math.Random(8));
    for (var i = 0; i < 200; i++) {
      final reto = generador.estimar();
      expect(reto.opciones.toSet().length, 4);
      expect(reto.opciones, contains(reto.respuesta));
      for (final a in reto.opciones) {
        expect(a, inInclusiveRange(1, 179));
        for (final b in reto.opciones) {
          if (a != b) expect((a - b).abs(), greaterThanOrEqualTo(20));
        }
      }
    }
  });

  test('la doble negación: todos los viajes llevan −(−n) y cruzan el suelo', () {
    final generador = GeneradorPozo(azar: math.Random(9));
    for (final nivel in [1, 2, 3]) {
      for (var i = 0; i < 100; i++) {
        final reto = generador.generar(TipoPozo.viaje, nivel: nivel, dobleNegacion: true);
        expect(reto.ordenes.any((o) => o.tipo == TipoOrden.dobleNegacion), isTrue);
        expect(reto.respuesta, recorrido(reto.inicio, reto.ordenes).last);
      }
    }
  });

  test('casa completa: la solución cabe, suma el total y no pisa maleza', () {
    for (final dificultad in [1, 2, 3]) {
      for (var semilla = 0; semilla < 50; semilla++) {
        final casa = CasaCompleta.generar(dificultad: dificultad, azar: math.Random(semilla));
        expect(casa.solucion, hasLength(CasaCompleta.habitaciones));
        expect(CasaCompleta.suma(casa.solucion), casa.total);
        for (var i = 0; i < casa.solucion.length; i++) {
          final habitacion = casa.solucion[i];
          expect(habitacion.celdas.any(casa.maleza.contains), isFalse);
          expect(CasaCompleta.solapa(habitacion, casa.solucion.sublist(0, i)), isFalse);
          expect(habitacion.columna + habitacion.ancho, lessThanOrEqualTo(PartidaPlanos.columnas));
          expect(habitacion.fila + habitacion.alto, lessThanOrEqualTo(PartidaPlanos.filas));
        }
      }
    }
  });
}
