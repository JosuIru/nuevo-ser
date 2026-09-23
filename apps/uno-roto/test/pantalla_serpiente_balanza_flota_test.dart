import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/balanza.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart' show Direccion;
import 'package:uno_roto/dominio/minijuegos/flota.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_balanza.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_flota.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_serpiente.dart';

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
  testWidgets('Balanza: con la solución, equilibrio', (tester) async {
    _movil(tester);
    const semilla = 3;
    await tester.pumpWidget(_envolver(const PantallaBalanza(
        registro: null, dificultad: 1, habilidadesPracticadas: ['ALG.01'], semilla: semilla)));
    final ecuacion =
        GeneradorBalanza(azar: math.Random(semilla)).generar('ALG.01', dificultad: 1);
    expect(find.text(ecuacion.texto), findsOneWidget);
    // Primero un valor malo (si la solución no es 1): la balanza se inclina.
    for (var i = 1; i < ecuacion.solucion; i++) {
      await tester.tap(find.byKey(const ValueKey('boton-mas')));
    }
    await tester.pump();
    expect(find.text('x = ${ecuacion.solucion}'), findsOneWidget);
    await tester.tap(find.text('PESAR'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.textContaining('Equilibrio. x vale ${ecuacion.solucion}.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('2 / 6'), findsOneWidget);
  });

  testWidgets('La flota: tocar la casilla cantada dispara; otra, corrige',
      (tester) async {
    _movil(tester);
    const semilla = 6;
    await tester.pumpWidget(_envolver(const PantallaFlota(
        registro: null, dificultad: 1, habilidadesPracticadas: ['FR.22'], semilla: semilla)));
    final partida = PartidaFlota(
        habilidades: ['FR.22'], dificultad: 1, azar: math.Random(semilla));
    expect(find.text(partida.columna.expresion), findsWidgets);

    final tablero = tester.getRect(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is PintorFlota));
    Offset centroDe(int fila, int columna) {
      final inicio = tablero.width * 0.1;
      final lado = (tablero.width - inicio) / 8;
      return tablero.topLeft +
          Offset(inicio + (columna + 0.5) * lado, inicio + (fila + 0.5) * lado);
    }

    final objetivo = partida.objetivo;
    await tester.tapAt(centroDe((objetivo.fila + 3) % 8, objetivo.columna));
    await tester.pump();
    expect(find.textContaining('Era la casilla columna ${objetivo.columna + 1}'),
        findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1100));

    // Ahora bien: la casilla del objetivo nuevo.
    partida.tocar(objetivo);
    partida.nuevoObjetivo();
    final siguiente = partida.objetivo;
    await tester.tapAt(centroDe(siguiente.fila, siguiente.columna));
    await tester.pump();
    expect(find.textContaining(RegExp(r'Agua\.|Tocado|Hundido')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1100));
  });

  testWidgets('Serpiente: espera al primer gesto y la cruceta la gira',
      (tester) async {
    _movil(tester);
    await tester.pumpWidget(_envolver(const PantallaSerpiente(
      registro: null,
      dificultad: 1,
      habilidadesPracticadas: ['ARI.01'],
      semilla: 2,
      periodo: Duration(milliseconds: 100),
    )));
    PintorSerpiente pintor() => tester
        .widget<CustomPaint>(find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is PintorSerpiente))
        .painter as PintorSerpiente;
    final cabeza = pintor().partida.cabeza;
    await tester.pump(const Duration(milliseconds: 400));
    expect(pintor().partida.cabeza, cabeza);
    await tester.tap(find.byKey(const ValueKey('cruceta-abajo')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(pintor().partida.direccion, Direccion.abajo);
    expect(pintor().partida.cabeza, isNot(cabeza));
    await tester.pumpWidget(const SizedBox());
  });
}
