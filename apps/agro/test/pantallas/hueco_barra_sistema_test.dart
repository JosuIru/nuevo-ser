import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agro/pantallas/pantalla_onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge,
/// Android 15+): el último botón tiene que quedar por encima.
const double alturaBarraSistema = 48;

void simularBarraSistema(WidgetTester tester, {double teclado = 0}) {
  final escala = tester.view.devicePixelRatio;
  tester.view.viewPadding = FakeViewPadding(
    bottom: alturaBarraSistema * escala,
  );
  // Con el teclado abierto Android pone el padding a 0 (el teclado tapa la
  // barra) y deja el viewPadding.
  tester.view.padding = FakeViewPadding(
    bottom: teclado > 0 ? 0 : alturaBarraSistema * escala,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: teclado * escala);
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

void main() {
  testWidgets('el botón Siguiente del onboarding queda sobre la barra', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    simularBarraSistema(tester);
    await tester.pumpWidget(const MaterialApp(home: PantallaOnboarding()));
    await tester.pumpAndSettle();
    final abajoBoton = tester.getRect(find.byType(FilledButton).last).bottom;
    expect(
      abajoBoton,
      lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema),
    );
  });
}
