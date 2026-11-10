import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/pantalla_acerca_de.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge,
/// Android 15+, targetSdk ≥ 35): lo último de la pantalla tiene que quedar
/// por encima al llegar al final del scroll.
const double alturaBarraSistema = 48;

void simularBarraSistema(WidgetTester tester) {
  final escala = tester.view.devicePixelRatio;
  tester.view.viewPadding =
      FakeViewPadding(bottom: alturaBarraSistema * escala);
  tester.view.padding = FakeViewPadding(bottom: alturaBarraSistema * escala);
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

/// Lleva el scroll hasta el final (varias veces: una lista perezosa
/// recalcula su extensión al construir los últimos hijos).
Future<void> irAlFinal(WidgetTester tester) async {
  for (var vuelta = 0; vuelta < 5; vuelta++) {
    final posicion =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posicion.jumpTo(posicion.maxScrollExtent);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
      'Acerca de: el botón de actualizaciones y el cierre quedan sobre la '
      'barra del sistema', (tester) async {
    simularBarraSistema(tester);
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaAcercaDe(),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    await irAlFinal(tester);

    final limiteBarra = altoPantalla(tester) - alturaBarraSistema;
    final abajoBoton = tester
        .getRect(find.byKey(const ValueKey('boton-actualizaciones')))
        .bottom;
    final abajoCierre = tester.getRect(find.text('hasta mañana')).bottom;
    expect(abajoBoton, lessThanOrEqualTo(limiteBarra));
    expect(abajoCierre, lessThanOrEqualTo(limiteBarra));
  });
}
