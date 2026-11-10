// Barra de navegación de Android (edge-to-edge, Android 15+, targetSdk
// ≥ 35): lo último del cuaderno tiene que quedar por encima. Hoy cabe
// por el margen de la hoja (24) más su relleno (32); la hoja de papel sí
// se mete bajo la barra, pero sin texto: es decorado.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:el_descifrador/dominio/estado_sesion.dart';
import 'package:el_descifrador/dominio/familiaridad_remitente.dart';
import 'package:el_descifrador/dominio/vocabulario_jugador.dart';
import 'package:el_descifrador/l10n/app_localizations.dart';
import 'package:el_descifrador/vista/pantalla_cuaderno.dart';

/// Barra de navegación de 48 px lógicos.
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

void main() {
  testWidgets('el final del cuaderno queda sobre la barra del sistema',
      (tester) async {
    simularBarraSistema(tester);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: PantallaCuaderno(
        estadoSesion: EstadoSesion.inicial(const []),
        familiaridad: FamiliaridadRemitente.inicial(),
        vocabulario: VocabularioJugador.inicial(),
      ),
    ));
    await tester.pump();

    final posicion =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posicion.jumpTo(posicion.maxScrollExtent);
    await tester.pump();

    final limiteBarra = altoPantalla(tester) - alturaBarraSistema;
    final abajoUltimoTexto = tester
        .getRect(find.textContaining('Aún no has decidido sobre ninguna pieza'))
        .bottom;
    expect(abajoUltimoTexto, lessThanOrEqualTo(limiteBarra));
  });
}
