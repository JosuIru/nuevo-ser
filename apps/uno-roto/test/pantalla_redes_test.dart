import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/redes.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_redes.dart';

void main() {
  testWidgets('Las redes: elegir la mejor red, echarla y pasar de ronda', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 3;
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaRedes(registro: null, dificultad: 1, semilla: semilla),
    ));
    final reto = GeneradorRedes(azar: math.Random(semilla)).generar(1);
    final mejor = reto.redes[reto.mejor!];
    expect(find.text('${mejor.ambar} ámbar de ${mejor.total}'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('red-${reto.mejor}')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 2300));
    expect(find.textContaining(RegExp('Buena red|buena decisión')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2700));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
