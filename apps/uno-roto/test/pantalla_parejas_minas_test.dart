import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/minas.dart';
import 'package:uno_roto/dominio/minijuegos/parejas.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_minas.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_parejas.dart';

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

void _movil(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Parejas: una pareja buena se retira; una mala no', (tester) async {
    _movil(tester);
    const semilla = 11;
    await tester.pumpWidget(_envolver(const PantallaParejas(
      registro: null,
      dificultad: 1,
      habilidadesPracticadas: ['DEC.08'],
      semilla: semilla,
    )));
    // El primer tablero es el primero del generador con la misma semilla.
    final tablero =
        GeneradorParejas(semilla: semilla).generar(['DEC.08'], dificultad: 1);
    final companera = tablero.cartas.indexWhere(
        (c) => c.idPareja == tablero.cartas[0].idPareja && c != tablero.cartas[0]);
    final otra =
        tablero.cartas.indexWhere((c) => c.idPareja != tablero.cartas[0].idPareja);

    await tester.tap(find.byKey(const ValueKey('carta-0')));
    await tester.tap(find.byKey(ValueKey('carta-$otra')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('no valen lo mismo'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('carta-0')));
    await tester.tap(find.byKey(ValueKey('carta-$companera')));
    await tester.pump(const Duration(milliseconds: 400));
    final opacidad = tester.widget<AnimatedOpacity>(find
        .ancestor(
            of: find.byKey(const ValueKey('carta-0')),
            matching: find.byType(AnimatedOpacity))
        .first);
    expect(opacidad.opacity, 0.0);
  });

  testWidgets('Minas: abrir, marcar y fallo con la verdad a la vista',
      (tester) async {
    _movil(tester);
    const semilla = 4;
    await tester.pumpWidget(_envolver(const PantallaMinas(
      registro: null,
      dificultad: 1,
      habilidadesPracticadas: ['DIV.05'],
      semilla: semilla,
    )));
    expect(find.text('Las minas: números primos.'), findsOneWidget);
    final tablero = TableroMinas.generar(
        idHabilidad: 'DIV.05', dificultad: 1, azar: math.Random(semilla));
    final segura = tablero.casillas.indexWhere((c) => !c.esMina);
    final mina = tablero.casillas.indexWhere((c) => c.esMina);

    await tester.tap(find.byKey(ValueKey('casilla-$segura')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('modo-marcar')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('casilla-$mina')));
    await tester.pump();
    expect(find.byIcon(Icons.flag), findsOneWidget);

    // Marcar una segura es un fallo: se abre y Rexán dice por qué.
    final otraSegura = tablero.casillas.lastIndexWhere((c) => !c.esMina);
    await tester.tap(find.byKey(ValueKey('casilla-$otraSegura')));
    await tester.pump();
    expect(find.textContaining('no cumple la regla: era segura'), findsOneWidget);
  });
}
