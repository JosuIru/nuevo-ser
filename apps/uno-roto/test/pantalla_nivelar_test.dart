import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/nivelar.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_nivelar.dart';

void main() {
  testWidgets('Nivelar: una mala lo explica; la buena lo demuestra y sigue', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 2;
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaNivelar(registro: null, dificultad: 1, semilla: semilla),
    ));
    final reto = GeneradorNivelar(azar: math.Random(semilla)).generar(TipoPregunta.leerPila);
    final mala = reto.opcionesEnMedios.firstWhere((o) => o != reto.respuestaEnMedios);
    await tester.tap(find.byKey(ValueKey('opcion-$mala')));
    await tester.pump();
    expect(find.textContaining('Cuenta otra vez'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuestaEnMedios}')));
    await tester.pump();
    expect(find.textContaining('Bien leído'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
