import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/salto.dart';

/// Obstáculos que se saltan (el trampolín, no: salta él solo, y el foso
/// que va tras un trampolín lo cruza el trampolín).
bool _hayQueSaltar(PartidaSalto partida) {
  final trampolines = partida.obstaculos
      .where((o) => o.tipo == TipoObstaculo.trampolin)
      .map((o) => o.x)
      .toList();
  return partida.obstaculos.any((o) {
    if (o.tipo == TipoObstaculo.trampolin) return false;
    if (o.tipo == TipoObstaculo.foso &&
        trampolines.any((xTrampolin) => (o.x - xTrampolin - 1.2).abs() < 1e-9)) {
      return false;
    }
    final distancia = o.x - partida.x;
    return distancia > 0.3 && distancia < 1.6;
  });
}

/// Simula la partida a 60 fps con un "piloto" que salta los obstáculos y
/// elige carril según [elegirArriba]. [alPasarPuerta] permite cambiar de
/// nivel como hace la pantalla.
({int pasadas, int choques}) _jugar(
  PartidaSalto partida, {
  required bool Function(PuertaDoble) elegirArriba,
  double segundos = 30,
  void Function(PartidaSalto)? alPasarPuerta,
}) {
  var choques = 0;
  const dt = 1 / 60;
  for (var paso = 0; paso < segundos * 60; paso++) {
    final puerta = partida.puertaSiguiente;
    final distanciaPlataforma = puerta.inicioPlataforma - partida.x;
    if (_hayQueSaltar(partida)) partida.saltar();
    if (elegirArriba(puerta) && distanciaPlataforma > 0 && distanciaPlataforma < 2.5) {
      partida.saltar();
    }
    final evento = partida.avanzar(dt);
    if (evento == EventoSalto.choquePincho || evento == EventoSalto.choquePuerta) {
      choques++;
      partida.reaparecer();
    }
    if (evento == EventoSalto.pasaPuerta) alPasarPuerta?.call(partida);
  }
  return (pasadas: partida.puertasPasadas, choques: choques);
}

void main() {
  test('la física del salto: sube, cae y vuelve al suelo', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(1));
    partida.obstaculos.clear();
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
    for (final nivel in [1, 3]) {
      final partida = PartidaSalto(
          habilidades: ['OP.01'], dificultad: 2, nivel: nivel, azar: math.Random(2));
      _jugar(partida, elegirArriba: (p) => p.correctaArriba, segundos: 40);
      for (final puerta in partida.puertas) {
        final valores = {puerta.valorArriba, puerta.valorAbajo};
        expect(valores, contains(puerta.reto.respuesta));
        expect(valores.length, 2);
      }
    }
  });

  test('cada nivel trae sus obstáculos', () {
    Set<TipoObstaculo> tipos(int nivel, int dificultad) {
      final encontrados = <TipoObstaculo>{};
      for (var semilla = 0; semilla < 10; semilla++) {
        final partida = PartidaSalto(
            habilidades: ['ARI.01'], dificultad: dificultad, nivel: nivel, azar: math.Random(semilla));
        encontrados.addAll(partida.obstaculos.map((o) => o.tipo));
      }
      return encontrados;
    }

    expect(tipos(1, 1), {TipoObstaculo.pinchos});
    expect(tipos(2, 1), {TipoObstaculo.pinchos, TipoObstaculo.caja, TipoObstaculo.foso});
    expect(tipos(3, 1), contains(TipoObstaculo.trampolin));

    bool hayTriples(int dificultad) => [
          for (var semilla = 0; semilla < 10; semilla++)
            ...PartidaSalto(
                    habilidades: ['ARI.01'], dificultad: dificultad, nivel: 3, azar: math.Random(semilla))
                .obstaculos
        ].any((o) => o.tipo == TipoObstaculo.pinchos && o.ancho == 3);
    expect(hayTriples(3), isTrue);
    expect(hayTriples(1), isFalse);
  });

  test('un piloto que siempre acierta pasa todos los niveles sin chocar', () {
    for (final dificultad in [1, 2, 3]) {
      for (final nivel in [1, 2, 3]) {
        for (var semilla = 0; semilla < 6; semilla++) {
          final partida = PartidaSalto(
              habilidades: ['ARI.01', 'FR.22'],
              dificultad: dificultad,
              nivel: nivel,
              azar: math.Random(semilla));
          final resultado = _jugar(partida, elegirArriba: (p) => p.correctaArriba);
          final contexto = 'dificultad $dificultad, nivel $nivel, semilla $semilla';
          expect(resultado.choques, 0, reason: contexto);
          expect(resultado.pasadas, greaterThanOrEqualTo(4), reason: contexto);
          expect(partida.cerrarRonda().values.every((acierto) => acierto), isTrue);
        }
      }
    }
  });

  test('subir de nivel a mitad de partida rehace lo que no se ve y sigue siendo pasable', () {
    for (final dificultad in [1, 2, 3]) {
      final partida = PartidaSalto(
          habilidades: ['ARI.01'], dificultad: dificultad, azar: math.Random(dificultad + 10));
      final resultado = _jugar(
        partida,
        elegirArriba: (p) => p.correctaArriba,
        segundos: 90,
        alPasarPuerta: (partida) {
          if (partida.puertasPasadas % 5 == 0) {
            partida.cambiarNivel(math.min(3, partida.puertasPasadas ~/ 5 + 1));
          }
        },
      );
      expect(resultado.choques, 0, reason: 'dificultad $dificultad');
      expect(resultado.pasadas, greaterThanOrEqualTo(12));
      expect(partida.nivel, 3);
      expect(partida.puertas.any((p) => p.encadenada), isTrue);
    }
  });

  test('una puerta encadenada parte de la respuesta de la anterior y no puntúa', () {
    var comprobadas = 0;
    for (var semilla = 0; semilla < 20; semilla++) {
      final partida = PartidaSalto(
          habilidades: ['ARI.01'], dificultad: 2, nivel: 3, azar: math.Random(semilla));
      _jugar(partida, elegirArriba: (p) => p.correctaArriba, segundos: 20);
      for (var i = 1; i < partida.puertas.length; i++) {
        final puerta = partida.puertas[i];
        if (!puerta.encadenada) continue;
        final antes = partida.puertas[i - 1].reto.respuesta;
        final partes = puerta.reto.enunciado.split(' ');
        expect(partes.first, '{antes}');
        final operando = int.parse(partes.last);
        final esperada = switch (partes[1]) {
          '+' => antes + operando,
          '−' => antes - operando,
          '×' => antes * operando,
          _ => antes ~/ operando,
        };
        expect(puerta.reto.respuesta, esperada, reason: puerta.reto.enunciado);
        expect(puerta.reto.distractores, isNot(contains(esperada)));
        expect(puerta.reto.distractores.every((d) => d > 0), isTrue);
        comprobadas++;
      }
    }
    expect(comprobadas, greaterThan(5));

    // Fallar una encadenada no cuenta como fallo de habilidad.
    final partida = PartidaSalto(
        habilidades: ['ARI.01'], dificultad: 1, nivel: 3, azar: math.Random(4));
    _jugar(partida,
        elegirArriba: (p) => p.encadenada ? !p.correctaArriba : p.correctaArriba,
        segundos: 12);
    expect(partida.puertaSiguiente.encadenada, isTrue); // atascado en una encadenada
    expect(partida.fallosPorHabilidad, isEmpty);
  });

  test('la puerta equivocada no deja pasar y cuenta un solo fallo', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(3));
    final primera = partida.puertas.first;
    var intentos = 0;
    const dt = 1 / 60;
    for (var paso = 0; paso < 60 * 20 && partida.puertasPasadas == 0; paso++) {
      final d = primera.inicioPlataforma - partida.x;
      if (!primera.correctaArriba && d > 0 && d < 2.5) partida.saltar();
      if (_hayQueSaltar(partida)) partida.saltar();
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

  test('caer en un foso devuelve a la marca; sobre una caja se puede aterrizar', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(5));
    partida.obstaculos
      ..clear()
      ..add(const Obstaculo(TipoObstaculo.foso, 3, 2));
    var evento = EventoSalto.nada;
    for (var paso = 0; paso < 120 && evento == EventoSalto.nada; paso++) {
      evento = partida.avanzar(1 / 60);
    }
    expect(evento, EventoSalto.choquePincho);
    expect(partida.y, lessThan(-1.5));

    final conCaja = PartidaSalto(habilidades: ['ARI.01'], dificultad: 1, azar: math.Random(5));
    conCaja.obstaculos
      ..clear()
      ..add(const Obstaculo(TipoObstaculo.caja, 2.8, 1));
    conCaja.saltar();
    var enCaja = false;
    for (var paso = 0; paso < 40; paso++) {
      conCaja.avanzar(1 / 60);
      if (conCaja.enSuelo && conCaja.y == PartidaSalto.altoCaja) enCaja = true;
    }
    expect(enCaja, isTrue);
  });
}
