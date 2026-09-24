import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

const _catalogo = <ElementoQuiz>[
  ElementoQuiz(id: 'a', nombreVisible: 'Opción A', explicacion: 'Era la A.'),
  ElementoQuiz(id: 'b', nombreVisible: 'Opción B', explicacion: 'Era la B.'),
  ElementoQuiz(id: 'c', nombreVisible: 'Opción C', explicacion: 'Era la C.'),
];

SesionQuiz _sesion({bool pideConfianza = false}) => SesionQuiz(
      generador: GeneradorPreguntasQuiz(
          catalogo: _catalogo, enunciado: (_) => '¿Cuál es?', semilla: 3),
      numeroPreguntas: 1,
      pideConfianza: pideConfianza,
    );

Widget _envolver(Widget hijo) => MaterialApp(home: Scaffold(body: hijo));

void main() {
  testWidgets('responder enseña la explicación y el botón de terminar',
      (tester) async {
    final sesion = _sesion();
    SesionQuiz? terminada;
    await tester.pumpWidget(_envolver(VistaQuiz(
      sesion: sesion,
      textos: const TextosQuiz(siguiente: 'Siguiente', terminar: 'Volver'),
      alTerminar: (s) => terminada = s,
    )));

    expect(find.text('Volver'), findsNothing);
    expect(find.textContaining('/'), findsNothing, reason: 'sin marcador');
    final correcta = sesion.preguntaActual.opciones
        .firstWhere((o) => o.idElemento == sesion.preguntaActual.idOpcionCorrecta);
    await tester.tap(find.text(correcta.texto));
    await tester.pump();

    expect(find.text(sesion.preguntaActual.explicacion!), findsOneWidget);
    await tester.tap(find.text('Volver'));
    expect(terminada, same(sesion));
  });

  testWidgets('con confianza, no revela nada hasta declararla',
      (tester) async {
    final sesion = _sesion(pideConfianza: true);
    await tester.pumpWidget(_envolver(VistaQuiz(
      sesion: sesion,
      textos: const TextosQuiz(siguiente: 'Siguiente', terminar: 'Volver'),
      alTerminar: (_) {},
    )));

    await tester.tap(find.text(sesion.preguntaActual.opciones.first.texto));
    await tester.pump();
    expect(sesion.respuestaActual, isNull);
    expect(find.text('Volver'), findsNothing);

    await tester.tap(find.text('Creo que sí'));
    await tester.pump();
    expect(sesion.respuestaActual!.confianza, ConfianzaRespuesta.media);
    expect(find.text('Volver'), findsOneWidget);
  });
}
