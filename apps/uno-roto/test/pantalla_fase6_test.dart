import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/andamios.dart';
import 'package:uno_roto/dominio/minijuegos/depositos.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_andamios.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_depositos.dart';

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
  testWidgets('Depósitos: pedir de más lo derrama; lo justo llena y sigue', (tester) async {
    _movil(tester);
    const semilla = 8;
    await tester.pumpWidget(_envolver(const PantallaDepositos(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorDepositos(azar: math.Random(semilla)).generar(TipoDeposito.cubos);
    expect(find.textContaining('${reto.datos[0]} × ${reto.datos[1]} × ${reto.datos[2]} cubitos'), findsOneWidget);
    final demasiado = reto.opciones.firstWhere((o) => o > reto.respuesta);
    await tester.tap(find.byKey(ValueKey('opcion-$demasiado')));
    await tester.pump();
    expect(find.textContaining('Las Fugas'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Andamios: la mitad del área no es el lado; el lado justo sí', (tester) async {
    _movil(tester);
    const semilla = 2;
    await tester.pumpWidget(_envolver(const PantallaAndamios(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorAndamios(azar: math.Random(semilla)).generar(TipoAndamio.plataforma);
    expect(find.textContaining('de ${reto.datos[0]} m²'), findsOneWidget);
    final mala = reto.opciones.firstWhere((o) => o != reto.respuesta);
    await tester.tap(find.byKey(ValueKey('opcion-$mala')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Lado justo'), findsNothing);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Lado justo'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('una escalera apoyada sube lo que dice Pitágoras', () {
    expect(PintorAndamio.alturaApoyada(10, 6), 8);
    expect(PintorAndamio.alturaApoyada(5, 5), 0);
  });
}
