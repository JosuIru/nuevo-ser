import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solera_viticultura/pantallas/pantalla_acerca.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge,
/// Android 15+): el último botón tiene que quedar por encima.
const double alturaBarraSistema = 48;

void simularBarraSistema(WidgetTester tester, {double teclado = 0}) {
  final escala = tester.view.devicePixelRatio;
  tester.view.viewPadding =
      FakeViewPadding(bottom: alturaBarraSistema * escala);
  // Con el teclado abierto Android pone el padding a 0 (el teclado tapa la
  // barra) y deja el viewPadding.
  tester.view.padding =
      FakeViewPadding(bottom: teclado > 0 ? 0 : alturaBarraSistema * escala);
  tester.view.viewInsets = FakeViewPadding(bottom: teclado * escala);
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

void main() {
  testWidgets('lo último de «Acerca de» queda sobre la barra del sistema',
      (tester) async {
    simularBarraSistema(tester);
    await tester.pumpWidget(const MaterialApp(home: PantallaAcerca()));
    await tester.pump();
    final lista = find.byType(Scrollable).first;
    for (var intento = 0; intento < 40; intento++) {
      await tester.drag(lista, const Offset(0, -400));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final textos = find.descendant(
        of: find.byType(ListView).first, matching: find.byType(Text));
    final abajoUltimo = tester.getRect(textos.last).bottom;
    expect(abajoUltimo,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema));
  });
}
