import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/datos/ajuste_sin_prisas.dart';
import 'package:uno_roto/dominio/minijuegos/encaje.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_encaje.dart';

void main() {
  tearDown(() => AjusteSinPrisas.activo.value = false);

  testWidgets('Encaje sin prisas: la pieza no cae sola', (tester) async {
    AjusteSinPrisas.activo.value = true;
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
      home: PantallaEncaje(dificultad: 3, semilla: 4),
    ));
    final tablero = (tester
            .widget<CustomPaint>(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is PintorEncaje))
            .painter as PintorEncaje)
        .tablero;
    final altura = tablero.altura;
    expect(find.textContaining('Sin prisas'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(tablero.altura, altura);
    await tester.tap(find.text('SOLTAR'));
    await tester.pump();
    expect(tablero.filas[0], isNotEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
