import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

const _catalogoFosiles = <ElementoQuiz>[
  ElementoQuiz(
      id: 'ammonites',
      nombreVisible: 'Ammonites',
      grupo: 'jurasico',
      idsConfundibles: ['nautilus'],
      idHabilidad: 'TAX.01'),
  ElementoQuiz(id: 'nautilus', nombreVisible: 'Nautilus', grupo: 'actual'),
  ElementoQuiz(id: 'belemnites', nombreVisible: 'Belemnites', grupo: 'jurasico'),
  ElementoQuiz(id: 'trilobites', nombreVisible: 'Trilobites', grupo: 'cambrico'),
  ElementoQuiz(id: 'braquiopodo', nombreVisible: 'Braquiópodo', grupo: 'cambrico'),
  ElementoQuiz(id: 'erizo', nombreVisible: 'Erizo fósil', grupo: 'cretacico'),
];

GeneradorPreguntasQuiz _generador({int semilla = 1, int opciones = 4}) =>
    GeneradorPreguntasQuiz(
      catalogo: _catalogoFosiles,
      enunciado: (elemento) => '¿Qué fósil es este?',
      numeroOpciones: opciones,
      semilla: semilla,
    );

ElementoQuiz _elemento(String id) =>
    _catalogoFosiles.firstWhere((elemento) => elemento.id == id);

void main() {
  group('GeneradorPreguntasQuiz', () {
    test('las opciones incluyen la correcta y no se repiten', () {
      final pregunta = _generador().preguntaSobre(_elemento('ammonites'));
      final ids = pregunta.opciones.map((o) => o.idElemento).toList();
      expect(ids, hasLength(4));
      expect(ids.toSet(), hasLength(4));
      expect(ids, contains('ammonites'));
      expect(pregunta.esCorrecta('ammonites'), isTrue);
      expect(pregunta.idHabilidad, 'TAX.01');
    });

    test('prefiere confundibles y mismo grupo antes que el resto', () {
      for (var semilla = 0; semilla < 20; semilla++) {
        final pregunta = _generador(semilla: semilla, opciones: 3)
            .preguntaSobre(_elemento('ammonites'));
        final ids = pregunta.opciones.map((o) => o.idElemento).toSet();
        expect(ids, {'ammonites', 'nautilus', 'belemnites'},
            reason: 'semilla $semilla');
      }
    });

    test('la dificultad sube con distractores cercanos', () {
      final cercana = _generador(opciones: 3)
          .preguntaSobre(_elemento('ammonites'));
      expect(cercana.dificultad, 3.0);
      final lejana =
          _generador(opciones: 6).preguntaSobre(_elemento('erizo'));
      expect(lejana.dificultad, 1.0);
    });

    test('baraja sin reposición: no repite hasta agotar el catálogo', () {
      final generador = _generador();
      final correctas = [
        for (var i = 0; i < _catalogoFosiles.length; i++)
          generador.siguiente().idOpcionCorrecta
      ];
      expect(correctas.toSet(), hasLength(_catalogoFosiles.length));
    });

    test('misma semilla, mismas preguntas', () {
      List<String> huella(GeneradorPreguntasQuiz generador) => [
            for (var i = 0; i < 5; i++)
              generador.siguiente().opciones.map((o) => o.idElemento).join(',')
          ];
      expect(huella(_generador(semilla: 7)), huella(_generador(semilla: 7)));
    });

    test('con un catálogo pequeño pone menos opciones', () {
      final generador = GeneradorPreguntasQuiz(
        catalogo: _catalogoFosiles.take(2).toList(),
        enunciado: (_) => '?',
      );
      expect(generador.siguiente().opciones, hasLength(2));
    });

    test('rechaza catálogos sin distractores posibles', () {
      expect(
        () => GeneradorPreguntasQuiz(
            catalogo: _catalogoFosiles.take(1).toList(),
            enunciado: (_) => '?'),
        throwsArgumentError,
      );
    });
  });

  group('SesionQuiz', () {
    test('una sola respuesta por pregunta y aviso al juego', () {
      final avisos = <ResultadoRespuestaQuiz>[];
      final sesion = SesionQuiz(
        generador: _generador(),
        numeroPreguntas: 3,
        alResponder: avisos.add,
      );
      final correcta = sesion.preguntaActual.idOpcionCorrecta;
      final primera = sesion.responder(correcta, duracion: Duration.zero);
      expect(primera!.acierto, isTrue);
      expect(sesion.responder(correcta, duracion: Duration.zero), isNull);
      expect(avisos, hasLength(1));
    });

    test('no avanza sin responder y termina tras N preguntas', () {
      final sesion = SesionQuiz(generador: _generador(), numeroPreguntas: 2);
      expect(sesion.avanzar(), isFalse);
      expect(sesion.numeroPreguntaActual, 1);

      sesion.responder(sesion.preguntaActual.opciones.first.idElemento,
          duracion: Duration.zero);
      expect(sesion.terminada, isFalse);
      expect(sesion.avanzar(), isTrue);
      expect(sesion.numeroPreguntaActual, 2);

      sesion.responder(sesion.preguntaActual.opciones.first.idElemento,
          duracion: Duration.zero);
      expect(sesion.terminada, isTrue);
      expect(sesion.avanzar(), isFalse);
      expect(sesion.respuestas, hasLength(2));
    });

    test('si pide confianza, exige declararla', () {
      final sesion = SesionQuiz(
          generador: _generador(), numeroPreguntas: 1, pideConfianza: true);
      final opcion = sesion.preguntaActual.opciones.first.idElemento;
      expect(() => sesion.responder(opcion, duracion: Duration.zero),
          throwsArgumentError);
      sesion.responder(opcion,
          duracion: Duration.zero, confianza: ConfianzaRespuesta.media);
      expect(sesion.resumenCalibracion().numeroRespuestas, 1);
    });

    test('rechaza una opción que no está en la pregunta', () {
      final sesion = SesionQuiz(generador: _generador(), numeroPreguntas: 1);
      expect(() => sesion.responder('inventado', duracion: Duration.zero),
          throwsArgumentError);
    });
  });

  group('ResumenCalibracionQuiz', () {
    RespuestaCalibrada respuesta(ConfianzaRespuesta confianza, bool acierto) =>
        RespuestaCalibrada(
            confianza: confianza, acierto: acierto, numeroOpciones: 4);

    test('vacío es equilibrado y sin score', () {
      final resumen = ResumenCalibracionQuiz.calcular(const []);
      expect(resumen.numeroRespuestas, 0);
      expect(resumen.tendencia, TendenciaCalibracion.equilibrada);
    });

    test('muy seguro y fallando es sobreconfianza', () {
      final resumen = ResumenCalibracionQuiz.calcular([
        respuesta(ConfianzaRespuesta.alta, false),
        respuesta(ConfianzaRespuesta.alta, false),
        respuesta(ConfianzaRespuesta.alta, true),
      ]);
      expect(resumen.tendencia, TendenciaCalibracion.sobreconfianza);
      expect(resumen.desviacion, closeTo(0.9 - 1 / 3, 1e-9));
    });

    test('dudando y acertando es timidez', () {
      final resumen = ResumenCalibracionQuiz.calcular([
        respuesta(ConfianzaRespuesta.baja, true),
        respuesta(ConfianzaRespuesta.baja, true),
      ]);
      expect(resumen.tendencia, TendenciaCalibracion.timidez);
    });

    test('Brier binario: alta y acierta = 1 − 0,01', () {
      final resumen = ResumenCalibracionQuiz.calcular(
          [respuesta(ConfianzaRespuesta.alta, true)]);
      expect(resumen.scoreMedio, closeTo(0.99, 1e-9));
    });

    test('la confianza baja vale el azar de la pregunta', () {
      const escala = EscalaConfianza();
      expect(escala.probabilidad(ConfianzaRespuesta.baja, 4), 0.25);
      expect(escala.probabilidad(ConfianzaRespuesta.baja, 3), closeTo(1 / 3, 1e-9));
    });
  });
}
