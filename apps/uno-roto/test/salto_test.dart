import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/salto.dart';

/// Simula la partida a 60 fps con un "piloto" que salta los pinchos y
/// elige carril según [elegirArriba].
({int pasadas, int choques}) _jugar(
  PartidaSalto partida, {
  required bool Function(PuertaDoble) elegirArriba,
  double segundos = 30,
}) {
  var choques = 0;
  const dt = 1 / 60;
  for (var paso = 0; paso < segundos * 60; paso++) {
    final puerta = partida.puertaSiguiente;
    final distanciaPlataforma = puerta.inicioPlataforma - partida.x;
    final hayPincho = partida.pinchos.any((p) {
      final d = p.x - partida.x;
      return d > 0.3 && d < 1.6;
    });
    if (hayPincho) partida.saltar();
    if (elegirArriba(puerta) && distanciaPlataforma > 0 && distanciaPlataforma < 2.5) {
      partida.saltar();
    }
    final evento = partida.avanzar(dt);
    if (evento == EventoSalto.choquePincho || evento == EventoSalto.choquePuerta) {
      choques++;
      partida.reaparecer();
    }
  }
  return (pasadas: partida.puertasPasadas, choques: choques);
}

void main() {
  test('la física del salto: sube, cae y vuelve al suelo', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(1));
    partida.pinchos.clear();
    partida.saltar();
    var alturaMaxima = 0.0;
    for (var i = 0; i < 60; i++) {
      partida.avanzar(1 / 60);
      alturaMaxima = math.max(alturaMaxima, partida.y);
    }
    expect(alturaMaxima, greaterThan(PartidaSalto.alturaPlataforma));
    expect(partida.y, 0);
    expect(partida.enSuelo, isTrue);
  });

  test('las puertas enseñan la respuesta en una hoja y un distractor en la otra', () {
    final partida = PartidaSalto(habilidades: ['OP.01'], dificultad: 2, azar: math.Random(2));
    for (final puerta in partida.puertas) {
      final valores = {puerta.valorArriba, puerta.valorAbajo};
      expect(valores, contains(puerta.reto.respuesta));
      expect(valores.length, 2);
    }
  });

  test('un piloto que siempre acierta pasa las puertas sin chocar', () {
    for (final dificultad in [1, 2, 3]) {
      final partida = PartidaSalto(
          habilidades: ['ARI.01', 'FR.22'], dificultad: dificultad, azar: math.Random(dificultad));
      final resultado = _jugar(partida, elegirArriba: (p) => p.correctaArriba);
      expect(resultado.choques, 0, reason: 'dificultad $dificultad');
      expect(resultado.pasadas, greaterThanOrEqualTo(4));
      expect(partida.cerrarRonda().values.every((acierto) => acierto), isTrue);
    }
  });

  test('la puerta equivocada no deja pasar y cuenta un solo fallo', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(3));
    // Siempre por el carril contrario a la primera puerta.
    final primera = partida.puertas.first;
    var intentos = 0;
    const dt = 1 / 60;
    for (var paso = 0; paso < 60 * 20 && partida.puertasPasadas == 0; paso++) {
      final d = primera.inicioPlataforma - partida.x;
      if (!primera.correctaArriba && d > 0 && d < 2.5) partida.saltar();
      final hayPincho = partida.pinchos.any((p) => p.x - partida.x > 0.3 && p.x - partida.x < 1.6);
      if (hayPincho) partida.saltar();
      if (partida.avanzar(dt) == EventoSalto.choquePuerta) {
        intentos++;
        partida.reaparecer();
        if (intentos >= 3) break;
      }
    }
    expect(intentos, 3);
    expect(partida.puertasPasadas, 0);
    expect(partida.fallosPorHabilidad, {'ARI.01': 1}); // sólo el primer intento
  });

  test('chocar con un pincho devuelve a la marca y no cuenta como fallo', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(4));
    var choques = 0;
    for (var paso = 0; paso < 60 * 4 && choques == 0; paso++) {
      if (partida.avanzar(1 / 60) == EventoSalto.choquePincho) {
        choques++;
        partida.reaparecer();
      }
    }
    expect(choques, 1);
    expect(partida.x, partida.marca);
    expect(partida.fallosPorHabilidad, isEmpty);
  });
}
