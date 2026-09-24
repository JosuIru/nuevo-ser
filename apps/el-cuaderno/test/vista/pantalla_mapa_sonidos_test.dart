import 'dart:typed_data';

import 'package:el_cuaderno/nucleo/i18n/generado/textos_app.dart';
import 'package:el_cuaderno/vista/pantalla_observacion/pantalla_mapa_sonidos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder superficie() => find.byKey(const ValueKey('superficie-mapa-sonidos'));
  Finder botonGuardar() => find.widgetWithText(TextButton, 'guardar mapa');

  Future<void> bombear(WidgetTester tester, {Widget? inicio}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: TextosApp.localizationsDelegates,
      supportedLocales: TextosApp.supportedLocales,
      locale: const Locale('es'),
      home: inicio ?? const PantallaMapaSonidos(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('sin marcas no se puede guardar; con una, sí', (tester) async {
    await bombear(tester);
    expect(tester.widget<TextButton>(botonGuardar()).onPressed, isNull);

    await tester.tap(find.text('agua'));
    await tester.pump();
    await tester.tapAt(tester.getCenter(superficie()) + const Offset(60, -40));
    await tester.pump();

    expect(tester.widget<TextButton>(botonGuardar()).onPressed, isNotNull);
    // La leyenda aparece con el tipo usado (además del chip).
    expect(find.text('agua'), findsNWidgets(2));
  });

  testWidgets('tocar una marca la quita', (tester) async {
    await bombear(tester);
    final punto = tester.getCenter(superficie()) + const Offset(-80, 30);
    await tester.tapAt(punto);
    await tester.pump();
    expect(tester.widget<TextButton>(botonGuardar()).onPressed, isNotNull);

    await tester.tapAt(punto);
    await tester.pump();
    expect(tester.widget<TextButton>(botonGuardar()).onPressed, isNull);
  });

  testWidgets('guardar devuelve un PNG', (tester) async {
    Uint8List? devuelto;
    await bombear(
      tester,
      inicio: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              devuelto = await Navigator.of(context).push<Uint8List?>(
                MaterialPageRoute(builder: (_) => const PantallaMapaSonidos()),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(superficie()) + const Offset(0, -100));
    await tester.pump();

    // toImage/toByteData son asíncronos de verdad: se espera en tiempo
    // real hasta que la pantalla devuelva los bytes (con tope), no un
    // retardo fijo que falla cuando la máquina va cargada.
    await tester.runAsync(() async {
      await tester.tap(botonGuardar());
      for (var intento = 0; intento < 100 && devuelto == null; intento++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(devuelto, isNotNull);
    expect(devuelto!.sublist(1, 4), 'PNG'.codeUnits);
  });
}
