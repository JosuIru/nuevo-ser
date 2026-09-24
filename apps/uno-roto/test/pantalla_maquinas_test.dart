import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';
import 'package:uno_roto/dominio/minijuegos/reto_semanal.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_maquinas.dart';

Widget _envolver() => MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaMaquinas(repositorio: RepositorioProgreso()),
    );

void main() {
  testWidgets('sin práctica ni modo dios, todas en reparación', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.textContaining('todavía la está arreglando'),
        findsNWidgets(CatalogoMinijuegos.deLaSala(1).length));
    expect(find.byKey(const ValueKey('dios-puentes-1')), findsNothing);
  });

  testWidgets('en modo dios todas encendidas con sus tres dificultades',
      (tester) async {
    SharedPreferences.setMockInitialValues({'uroto.modo_dios_activo': true});
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.textContaining('todavía la está arreglando'), findsNothing);
    for (final definicion in CatalogoMinijuegos.deLaSala(1)) {
      for (final dificultad in [1, 2, 3]) {
        expect(find.byKey(ValueKey('dios-${definicion.id.name}-$dificultad')),
            findsOneWidget);
      }
    }
  });

  testWidgets('la escalera a la planta de arriba: cerrada sin llaves', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('escalera-segunda-sala')), findsOneWidget);
    expect(find.textContaining('cuando domines bien'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('escalera-segunda-sala')));
    await tester.pumpAndSettle();
    expect(find.text('LA PLANTA DE ARRIBA'), findsOneWidget); // sigue en la escalera, no sube
    expect(find.textContaining('enseñan cosas nuevas. Sólo se encienden'), findsNothing);
  });

  testWidgets('en modo dios se sube y Engranajes está encendida', (tester) async {
    SharedPreferences.setMockInitialValues({'uroto.modo_dios_activo': true});
    tester.view.physicalSize = const Size(1080, 12000);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('escalera-segunda-sala')));
    await tester.pumpAndSettle();
    expect(find.textContaining('enseñan cosas nuevas. Sólo se encienden'), findsOneWidget);
    for (final definicion in CatalogoMinijuegos.deLaSala(2)) {
      expect(find.byKey(ValueKey('dios-${definicion.id.name}-1')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('escalera-segunda-sala')), findsNothing);
  });

  testWidgets('sin práctica no hay reto de la semana', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reto-semanal')), findsNothing);
  });

  testWidgets('el cartel del reto abre la máquina con su ronda especial', (tester) async {
    SharedPreferences.setMockInitialValues({'uroto.modo_dios_activo': true});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    // Una semana en la que toca el puente roto.
    final todas = {for (final e in especialesSemanales) e.maquina: e.habilidades};
    var fecha = DateTime(2026, 1, 5);
    while (retoDeLaSemana(fecha, todas)!.especial != EspecialSemanal.puenteRoto) {
      fecha = fecha.add(const Duration(days: 7));
    }
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaMaquinas(repositorio: RepositorioProgreso(), fecha: fecha),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Los puentes rotos'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reto-semanal')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('ha salido largo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cada especial del reto abre su máquina sin romperse', (tester) async {
    SharedPreferences.setMockInitialValues({'uroto.modo_dios_activo': true});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final todas = {for (final e in especialesSemanales) e.maquina: e.habilidades};
    for (final especial in [EspecialSemanal.sinTransportador, EspecialSemanal.dobleNegacion, EspecialSemanal.casaCompleta]) {
      var fecha = DateTime(2026, 1, 5);
      while (retoDeLaSemana(fecha, todas)!.especial != especial) {
        fecha = fecha.add(const Duration(days: 7));
      }
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
        home: PantallaMaquinas(key: ValueKey(especial), repositorio: RepositorioProgreso(), fecha: fecha),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('reto-semanal')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final esperado = switch (especial) {
        EspecialSemanal.sinTransportador => 'A ojo, sin transportador',
        EspecialSemanal.dobleNegacion => '−(−',
        _ => 'en tres habitaciones',
      };
      expect(find.textContaining(esperado), findsWidgets, reason: '$especial');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
