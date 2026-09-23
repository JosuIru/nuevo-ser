import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/encaje.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_encaje.dart';

void main() {
  Widget envolver() => const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
        home: PantallaEncaje(
          dificultad: 1,
          semilla: 4,
          // Sin caída automática: el test controla el tiempo.
          periodoCaida: Duration(hours: 1),
        ),
      );

  TableroEncaje tablero(WidgetTester tester) => (tester
          .widget<CustomPaint>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter is PintorEncaje))
          .painter as PintorEncaje)
      .tablero;

  testWidgets('soltar encaja la pieza abajo y entra la siguiente',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(envolver());
    expect(find.text('SIGUIENTE'), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);

    await tester.tap(find.text('SOLTAR'));
    await tester.pump();
    expect(tablero(tester).filas[0], isNotEmpty);
    expect(tablero(tester).piezaActual, isNotNull);

    // Arrastrar mueve la pieza nueva a la izquierda del todo.
    final lienzo = tester.getRect(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is PintorEncaje));
    await tester.dragFrom(lienzo.center, Offset(-lienzo.width, 0));
    await tester.pump();
    expect(tablero(tester).columna, 0);

    await tester.pumpWidget(const SizedBox());
  });
}
