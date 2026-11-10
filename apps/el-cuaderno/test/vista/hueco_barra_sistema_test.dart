import 'package:el_cuaderno/infraestructura/memoria/repositorio_memoria.dart';
import 'package:el_cuaderno/nucleo/i18n/generado/textos_app.dart';
import 'package:el_cuaderno/vista/pantalla_pregunta/pantalla_formular_pregunta.dart';
import 'package:el_cuaderno/vista/tema/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge,
/// Android 15+, targetSdk ≥ 35): el último botón tiene que quedar por
/// encima, también en la hoja inferior de ideas.
const double alturaBarraSistema = 48;

/// Móvil de 412 × 915 px lógicos con escala 3 y barra de 48 px abajo.
void simularBarraSistema(WidgetTester tester) {
  const escala = 3.0;
  tester.view.devicePixelRatio = escala;
  tester.view.physicalSize = const Size(412 * escala, 915 * escala);
  tester.view.viewPadding =
      FakeViewPadding(bottom: alturaBarraSistema * escala);
  tester.view.padding = FakeViewPadding(bottom: alturaBarraSistema * escala);
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

Future<void> abrirFormularPregunta(WidgetTester tester) async {
  simularBarraSistema(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCuaderno.claro(),
      localizationsDelegates: TextosApp.localizationsDelegates,
      supportedLocales: TextosApp.supportedLocales,
      locale: const Locale('es'),
      home: PantallaFormularPregunta(repositorio: RepositorioMemoria()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el botón Guardar queda sobre la barra del sistema',
      (tester) async {
    await abrirFormularPregunta(tester);
    final abajoGuardar = tester
        .getRect(find.widgetWithText(FilledButton, 'Guardar mi pregunta'))
        .bottom;
    expect(abajoGuardar,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema));
  });

  testWidgets('la última idea de la hoja queda sobre la barra del sistema',
      (tester) async {
    await abrirFormularPregunta(tester);
    final textos = TextosApp.of(
      tester.element(find.byType(PantallaFormularPregunta)),
    );
    await tester.tap(find.byIcon(Icons.lightbulb_outline));
    await tester.pumpAndSettle();

    final abajoUltimaIdea =
        tester.getRect(find.text(textos.preguntaIdea5)).bottom;
    expect(abajoUltimaIdea,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema));
  });
}
