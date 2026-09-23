import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/planos.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_planos.dart';

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

void main() {
  testWidgets('Planos: dos toques dibujan; entregar mal lo explica, bien lo sella', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 6;
    await tester.pumpWidget(_envolver(
        const PantallaPlanos(registro: null, dificultad: 1, semilla: semilla)));
    final espejo = PartidaPlanos(tipo: TipoEncargo.area, dificultad: 1, azar: math.Random(semilla));
    expect(find.textContaining('Una habitación de ${espejo.encargo.valor} m²'), findsOneWidget);

    final cuadricula = tester.getRect(find.byKey(const ValueKey('cuadricula-planos')));
    final lado = cuadricula.width / PartidaPlanos.columnas;
    Offset centro(int fila, int columna) =>
        cuadricula.topLeft + Offset((columna + 0.5) * lado, (fila + 0.5) * lado);
    Future<void> dibujar(Rectangulo r) async {
      await tester.tapAt(centro(r.fila, r.columna));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tapAt(centro(r.fila + r.alto - 1, r.columna + r.ancho - 1));
      await tester.pump(const Duration(milliseconds: 400));
    }

    // Un rectángulo de área distinta.
    final mala = espejo.encargo.valor == 4 ? const Rectangulo(0, 0, 3, 1) : const Rectangulo(0, 0, 2, 2);
    await dibujar(mala);
    expect(find.text('Área: ${mala.area} m² · Valla: ${mala.perimetro} m'), findsOneWidget);
    await tester.tap(find.text('ENTREGAR'));
    await tester.pump();
    expect(find.textContaining('El encargo pide otra cosa'), findsOneWidget);

    final buena = espejo.solucionesColocables().first;
    await dibujar(buena);
    await tester.tap(find.text('ENTREGAR'));
    await tester.pump();
    expect(find.textContaining('Sellado'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('2 / 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
