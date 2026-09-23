import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/esclusas.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_esclusas.dart';

Widget _envolver(Widget pantalla) => MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: pantalla,
    );

void main() {
  testWidgets('Esclusas: la esclusa buena la deja pasar; otra, explica', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 5;
    await tester.pumpWidget(_envolver(
        const PantallaEsclusas(registro: null, dificultad: 1, semilla: semilla)));
    await tester.pump(const Duration(milliseconds: 100));
    // La misma partida, con la misma semilla, para saber la respuesta.
    final espejo = PartidaEsclusas(nivel: 1, dificultad: 1, azar: math.Random(semilla));
    final buena = espejo.carga.esclusaBuena!;
    expect(find.text('0 / 6'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('esclusa-${(buena + 1) % 3}')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('no está en ese tramo'), findsOneWidget);
    expect(find.text('0 / 6'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('esclusa-$buena')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('1 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
