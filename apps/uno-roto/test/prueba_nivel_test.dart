import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/nivel_escolar.dart';
import 'package:uno_roto/dominio/prueba_nivel.dart';

/// Juega la prueba contestando bien hasta el curso [sabeHasta] (incluido)
/// y mal a partir de ahí.
NivelEscolar _jugar(NivelEscolar? sabeHasta, {int semilla = 0}) {
  final prueba = PruebaNivel(azar: math.Random(semilla));
  while (!prueba.terminada) {
    final pregunta = prueba.preguntaActual;
    final sabe = sabeHasta != null && pregunta.curso.index <= sabeHasta.index;
    prueba.responder(sabe ? pregunta.respuesta : pregunta.opciones.firstWhere((o) => o != pregunta.respuesta));
  }
  expect(prueba.preguntasHechas, lessThanOrEqualTo(PruebaNivel.maximoPreguntas));
  return prueba.resultado;
}

void main() {
  test('las preguntas tienen cuatro opciones distintas y una es la buena', () {
    final generador = GeneradorPreguntasNivel(azar: math.Random(1));
    for (final curso in NivelEscolar.values) {
      for (var i = 0; i < 200; i++) {
        final pregunta = generador.pregunta(curso);
        expect(pregunta.opciones.toSet().length, 4, reason: '${pregunta.enunciado} ${pregunta.opciones}');
        expect(pregunta.opciones, contains(pregunta.respuesta));
        expect(pregunta.curso, curso);
      }
    }
  });

  test('el resultado es el curso siguiente al último que sabe', () {
    for (var semilla = 0; semilla < 20; semilla++) {
      expect(_jugar(null, semilla: semilla), NivelEscolar.cuartoPrimaria);
      expect(_jugar(NivelEscolar.cuartoPrimaria, semilla: semilla), NivelEscolar.quintoPrimaria);
      expect(_jugar(NivelEscolar.quintoPrimaria, semilla: semilla), NivelEscolar.sextoPrimaria);
      expect(_jugar(NivelEscolar.sextoPrimaria, semilla: semilla), NivelEscolar.primeroEso);
      expect(_jugar(NivelEscolar.primeroEso, semilla: semilla), NivelEscolar.segundoEso);
      expect(_jugar(NivelEscolar.segundoEso, semilla: semilla), NivelEscolar.segundoEso);
    }
  });

  test('un fallo suelto no la baja: con tres preguntas en el curso, dos aciertos bastan', () {
    final prueba = PruebaNivel(azar: math.Random(3));
    // Falla la primera de 5.º y acierta las dos siguientes.
    prueba.responder(prueba.preguntaActual.opciones.firstWhere((o) => o != prueba.preguntaActual.respuesta));
    prueba.responder(prueba.preguntaActual.respuesta);
    prueba.responder(prueba.preguntaActual.respuesta);
    expect(prueba.superado, NivelEscolar.quintoPrimaria);
    expect(prueba.cursoActual, NivelEscolar.sextoPrimaria);
  });
}
