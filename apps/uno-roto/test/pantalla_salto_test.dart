import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_salto.dart';

void main() {
  testWidgets('Salto: espera al primer toque; luego corre y salta', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaSalto(
          registro: null, dificultad: 1, habilidadesPracticadas: ['ARI.01'], semilla: 1),
    ));
    PintorSalto pintor() => tester
        .widget<CustomPaint>(find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is PintorSalto))
        .painter as PintorSalto;

    expect(find.textContaining('Toca para empezar'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(pintor().partida.x, 0);

    await tester.tap(find.byKey(const ValueKey('pista-salto')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(pintor().partida.x, greaterThan(0));

    await tester.tap(find.byKey(const ValueKey('pista-salto')));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    expect(pintor().partida.y, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });
}
