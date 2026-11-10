import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aromaticas/pantallas/hoja_formulario.dart';

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

Future<void> abrirHojaFormulario(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => mostrarHojaFormulario(
              context,
              titulo: 'Alta',
              construir: (_) => [const TextField()],
              guardar: () async => false,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el botón Guardar de la hoja queda sobre la barra del sistema',
      (tester) async {
    simularBarraSistema(tester);
    await abrirHojaFormulario(tester);
    final abajoGuardar =
        tester.getRect(find.text(SoleraL10n.t('guardar'))).bottom;
    expect(abajoGuardar,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema - 16));
  });

  testWidgets('con el teclado abierto no se suman teclado y barra',
      (tester) async {
    simularBarraSistema(tester, teclado: 250);
    await abrirHojaFormulario(tester);
    final abajoBoton = tester
        .getRect(find.ancestor(
            of: find.text(SoleraL10n.t('guardar')),
            matching: find.byType(FilledButton)))
        .bottom;
    expect(abajoBoton, moreOrLessEquals(altoPantalla(tester) - 250 - 16));
  });
}
