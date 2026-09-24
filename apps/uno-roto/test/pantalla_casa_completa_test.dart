import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/planos.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_planos.dart';

void main() {
  testWidgets('casa completa: tres habitaciones que suman el total sellan la casa', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    const semilla = 11;
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaPlanos(registro: null, dificultad: 1, semilla: semilla, casaCompleta: true),
    ));
    // La pantalla gasta el azar primero en la partida y luego en la casa:
    // se reproduce el mismo orden.
    final azar = math.Random(semilla);
    PartidaPlanos(tipo: TipoEncargo.area, dificultad: 1, azar: azar);
    final casa = CasaCompleta.generar(dificultad: 1, azar: azar);
    expect(find.textContaining('Una casa de ${casa.total} m²'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);

    final cuadricula = tester.getRect(find.byKey(const ValueKey('cuadricula-planos')));
    final lado = cuadricula.width / PartidaPlanos.columnas;
    Offset centroDe(int fila, int columna) =>
        cuadricula.topLeft + Offset((columna + 0.5) * lado, (fila + 0.5) * lado);
    for (final habitacion in casa.solucion) {
      await tester.tapAt(centroDe(habitacion.fila, habitacion.columna));
      await tester.pump();
      await tester.tapAt(centroDe(habitacion.fila + habitacion.alto - 1, habitacion.columna + habitacion.ancho - 1));
      await tester.pump();
      await tester.tap(find.text('PONER LA HABITACIÓN'));
      await tester.pump();
    }
    expect(find.textContaining('Casa completa: ${casa.total} m² justos'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
