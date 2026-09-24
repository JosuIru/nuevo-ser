import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/hornada.dart';
import 'package:uno_roto/dominio/minijuegos/telar.dart';
import 'package:uno_roto/dominio/minijuegos/tranvia.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_hornada.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_telar.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_tranvia.dart';

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
  testWidgets('La hornada: tocar los trozos pedidos y entregar', (tester) async {
    _movil(tester);
    const semilla = 4;
    await tester.pumpWidget(_envolver(const PantallaHornada(registro: null, dificultad: 1, semilla: semilla)));
    final pedido = GeneradorHornada(azar: math.Random(semilla)).generar(TipoPedido.parte);
    final bandeja = tester.getRect(find.byKey(const ValueKey('bandeja')));
    final pintor = PintorBandeja(pedido: pedido, enCaja: const {});
    // Centro de cada trozo: a media distancia del radio, en el ángulo del trozo.
    final radio = math.min(bandeja.width / (pedido.panes * 2.3), bandeja.height * 0.42);
    final centro = bandeja.topLeft + Offset(bandeja.width / pedido.panes / 2, bandeja.height / 2);
    for (var t = 0; t < pedido.trozos; t++) {
      final a = (t + 0.5) / pedido.cortes * math.pi * 2 - math.pi / 2;
      final punto = centro + Offset(math.cos(a), math.sin(a)) * radio * 0.6;
      expect(pintor.trozoEn(punto - bandeja.topLeft, bandeja.size), (0, t));
      await tester.tapAt(punto);
    }
    await tester.pump();
    await tester.tap(find.text('ENTREGAR'));
    await tester.pump();
    expect(find.textContaining('justo el pedido'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('El telar: una mala lo explica, la buena tiñe y sigue', (tester) async {
    _movil(tester);
    const semilla = 5;
    await tester.pumpWidget(_envolver(const PantallaTelar(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorTelar(azar: math.Random(semilla)).generar(TipoTelar.porNatural);
    final mala = reto.opciones.firstWhere((o) => o != reto.respuesta);
    await tester.tap(find.byKey(ValueKey('opcion-$mala')));
    await tester.pump();
    expect(find.textContaining('Junta las telas'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('opcion-${reto.respuesta}')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('El tranvía: tocar la vía en la parada pedida', (tester) async {
    _movil(tester);
    const semilla = 6;
    await tester.pumpWidget(_envolver(const PantallaTranvia(registro: null, dificultad: 1, semilla: semilla)));
    final reto = GeneradorTranvia(azar: math.Random(semilla)).generar(TipoTranvia.situar);
    expect(find.textContaining('parada ${enDecimal(reto.valor)}'), findsOneWidget);
    final via = tester.getRect(find.byKey(const ValueKey('via')));
    final x = via.left + PintorVia.margen +
        (reto.valor - reto.desde) / (reto.hasta - reto.desde) * (via.width - 2 * PintorVia.margen);
    await tester.tapAt(Offset(x, via.center.dy));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.textContaining('Todos abajo'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
