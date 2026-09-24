import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/rebote.dart';
import 'package:uno_roto/dominio/minijuegos/taller.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_rebote.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_taller.dart';

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
  testWidgets('Rebote: medir mal lo explica; bien pasa de ronda', (tester) async {
    _movil(tester);
    const semilla = 2;
    await tester.pumpWidget(_envolver(const PantallaRebote(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorRebote(azar: math.Random(semilla)).generar(TipoRebote.medir);
    final mala = reto.opciones.firstWhere((o) => o != reto.respuesta);
    await tester.tap(find.byKey(ValueKey('opcion-$mala')));
    await tester.pump();
    expect(find.textContaining('cero del transportador'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    await tester.pump();
    expect(find.textContaining('Medido y apuntado'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Taller: poner piezas, entregar de menos y completar', (tester) async {
    _movil(tester);
    const semilla = 3;
    await tester.pumpWidget(_envolver(const PantallaTaller(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorTaller(azar: math.Random(semilla)).generar(Banco.regla);
    expect(find.text('Corta una varilla de ${reto.objetivo}.'), findsOneWidget);
    // Con la pieza de 1 cm se llega siempre; primero una de menos.
    final unCm = reto.piezas.firstWhere((p) => p.valor == 1);
    for (var i = 0; i < reto.objetivoBase - 1 && i < 3; i++) {
      await tester.tap(find.byKey(ValueKey('pieza-${unCm.etiqueta}')));
    }
    await tester.pump();
    await tester.tap(find.text('ENTREGAR'));
    await tester.pump();
    expect(find.textContaining('faltan'), findsOneWidget);
    // Ahora justo: quitar lo puesto y poner las piezas grandes y luego las de 1 cm.
    var restante = reto.objetivoBase - 3;
    for (final pieza in [...reto.piezas]..sort((a, b) => b.valor.compareTo(a.valor))) {
      while (restante >= pieza.valor) {
        await tester.tap(find.byKey(ValueKey('pieza-${pieza.etiqueta}')));
        restante -= pieza.valor;
      }
    }
    await tester.pump();
    await tester.tap(find.text('ENTREGAR'));
    await tester.pump();
    expect(find.textContaining('Justo lo que pedían'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
