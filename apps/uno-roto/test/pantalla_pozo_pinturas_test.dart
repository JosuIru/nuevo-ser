import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/pinturas.dart';
import 'package:uno_roto/dominio/minijuegos/pozo.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_pinturas.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_pozo.dart';

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
  testWidgets('El pozo: tocar la planta buena hace el viaje y lo confirma', (tester) async {
    _movil(tester);
    const semilla = 5;
    await tester.pumpWidget(_envolver(const PantallaPozo(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorPozo(azar: math.Random(semilla)).generar(TipoPozo.viaje, nivel: 1);
    expect(find.textContaining('Sales de la planta ${reto.inicio < 0 ? '−${-reto.inicio}' : reto.inicio}'), findsOneWidget);

    // Dónde está esa planta en el pozo (mismo rango que la pantalla).
    final paradas = recorrido(reto.inicio, reto.ordenes);
    final todas = [...paradas, 0];
    var abajo = todas.reduce(math.min) - 2;
    var arriba = todas.reduce(math.max) + 2;
    while (arriba - abajo < 12) {
      arriba++;
      abajo--;
    }
    final pozo = tester.getRect(find.byKey(const ValueKey('pozo')));
    final alto = pozo.height / (arriba - abajo + 1);
    await tester.tapAt(Offset(pozo.center.dx, pozo.top + (arriba - reto.respuesta + 0.5) * alto));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('Justo donde dijiste'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Pinturas: un cubo malo destiñe; el bueno recupera el color', (tester) async {
    _movil(tester);
    const semilla = 6;
    await tester.pumpWidget(_envolver(const PantallaPinturas(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorPinturas(azar: math.Random(semilla)).generar(TipoPintura.reconocer);
    final malo = (reto.respuesta + 1) % reto.cubos.length;
    await tester.tap(find.byKey(ValueKey('cubo-$malo')));
    await tester.pump();
    expect(find.textContaining('no guarda la receta'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('cubo-${reto.respuesta}')));
    await tester.pump();
    expect(find.textContaining('recupera su color'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
