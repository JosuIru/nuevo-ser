import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_canales.dart';

void main() {
  Widget envolver() => const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
        home: PantallaCanales(
          registro: null,
          dificultad: 1,
          habilidadesPracticadas: ['DIV.05'],
          semilla: 5,
          periodo: Duration(milliseconds: 100),
        ),
      );

  PartidaCanales partida(WidgetTester tester) => (tester
          .widget<CustomPaint>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter is PintorCanales))
          .painter as PintorCanales)
      .partida;

  testWidgets('espera al primer gesto y la cruceta mueve al Fragmento',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(envolver());
    expect(find.text('Sólo números primos.'), findsOneWidget);
    expect(find.textContaining('Lee la regla'), findsOneWidget);

    final salida = partida(tester).laberinto.salida;
    await tester.pump(const Duration(milliseconds: 500));
    expect(partida(tester).jugador, salida); // nada se mueve aún

    await tester.tap(find.byKey(const ValueKey('cruceta-derecha')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(partida(tester).jugador, isNot(salida));

    await tester.pumpWidget(const SizedBox());
  });
}
