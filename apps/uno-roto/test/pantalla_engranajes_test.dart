import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/engranajes.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_engranajes.dart';

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
  testWidgets('Engranajes: un número malo lo explica; el bueno pasa de ronda', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 4;
    await tester.pumpWidget(_envolver(
        const PantallaEngranajes(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorEngranajes(azar: math.Random(semilla)).generar(TipoEngranaje.mcm);
    expect(find.textContaining('Ruedas de ${reto.numeros[0]} y ${reto.numeros[1]}'), findsOneWidget);

    final mala = reto.opciones.firstWhere((o) => o != reto.respuesta);
    await tester.tap(find.byKey(ValueKey('opcion-$mala')));
    // El giro empieza a contar en el primer fotograma: dos avances.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.textContaining(RegExp('vueltas enteras|antes ya se habían')), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    // El giro empieza a contar en el primer fotograma: dos avances.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.textContaining('la grúa arranca'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
