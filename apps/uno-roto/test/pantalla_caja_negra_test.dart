import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/caja_negra.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_caja_negra.dart';

void main() {
  testWidgets('La caja negra: experimentar añade filas; la buena abre la caja', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 4;
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaCajaNegra(registro: null, dificultad: 1, semilla: semilla),
    ));
    final reto = GeneradorCaja(azar: math.Random(semilla))
        .generar(TipoCaja.directa, nivel: 1, dificultad: 1);
    expect(find.text('Si entra ${reto.dato}, ¿qué sale?'), findsOneWidget);
    expect(find.text('Prueba números (4 intentos)'), findsOneWidget);

    final nueva = reto.probables.firstWhere((x) => !reto.filasIniciales.contains(x));
    await tester.tap(find.byKey(ValueKey('probar-$nueva')));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Prueba números (3 intentos)'), findsOneWidget);
    expect(find.text('${reto.regla.aplicar(nueva)}'), findsWidgets);

    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('La caja se abre'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
