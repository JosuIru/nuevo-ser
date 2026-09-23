import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/datos/registro_maestria_minijuego.dart';
import 'package:uno_roto/dominio/minijuegos/ayudas_maquinas.dart';
import 'package:uno_roto/dominio/minijuegos/balanza.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_balanza.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_serpiente.dart';

/// Apunta lo que se registraría en el motor de maestría.
class _RegistroEspia implements RegistroMaestriaMinijuego {
  final registros = <(String, bool)>[];

  @override
  Future<void> registrar({
    required String idHabilidad,
    required bool acierto,
    required double dificultad,
    required Duration duracion,
  }) async =>
      registros.add((idHabilidad, acierto));

  @override
  dynamic noSuchMethod(Invocation invocacion) => super.noSuchMethod(invocacion);
}

Widget _envolver(Widget pantalla, {String idioma = 'es'}) => MaterialApp(
      locale: Locale(idioma),
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
  testWidgets('el botón de ayuda abre cómo se juega y el truco, y se cierra',
      (tester) async {
    _movil(tester);
    await tester.pumpWidget(_envolver(const PantallaSerpiente(
        registro: null, dificultad: 1, habilidadesPracticadas: ['ARI.01'], semilla: 1)));
    await tester.tap(find.byKey(const ValueKey('ayuda-maquina')));
    await tester.pumpAndSettle();
    expect(find.text('CÓMO SE JUEGA'), findsOneWidget);
    expect(find.text('EL TRUCO'), findsOneWidget);
    expect(find.text(trucosPorHabilidad['ARI.01']!), findsOneWidget);
    await tester.tap(find.text('SEGUIR'));
    await tester.pumpAndSettle();
    expect(find.text('CÓMO SE JUEGA'), findsNothing);
  });

  testWidgets('la ayuda sale traducida al euskera', (tester) async {
    _movil(tester);
    await tester.pumpWidget(_envolver(
        const PantallaSerpiente(
            registro: null, dificultad: 1, habilidadesPracticadas: ['ARI.01'], semilla: 1),
        idioma: 'eu'));
    await tester.tap(find.byKey(const ValueKey('ayuda-maquina')));
    await tester.pumpAndSettle();
    expect(find.text('NOLA JOKATZEN DEN'), findsOneWidget);
    expect(find.text('TRIKIMAILUA'), findsOneWidget);
  });

  testWidgets('Balanza: paso a paso enseña a despejar y esa ecuación no puntúa',
      (tester) async {
    _movil(tester);
    const semilla = 3;
    final registro = _RegistroEspia();
    await tester.pumpWidget(_envolver(PantallaBalanza(
        registro: registro, dificultad: 1, habilidadesPracticadas: const ['ALG.01'], semilla: semilla)));
    final ecuacion =
        GeneradorBalanza(azar: math.Random(semilla)).generar('ALG.01', dificultad: 1);
    final pasos = pasosDespejar(ecuacion);

    await tester.tap(find.byKey(const ValueKey('pasos-abrir')));
    await tester.pump();
    expect(find.textContaining('1.'), findsOneWidget);
    for (var i = 1; i < pasos.length; i++) {
      await tester.tap(find.byKey(const ValueKey('pasos-siguiente')));
      await tester.pump();
    }
    expect(find.textContaining('→ x = ${ecuacion.solucion}'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('pasos-cerrar')));
    await tester.pump();

    for (var i = 1; i < ecuacion.solucion; i++) {
      await tester.tap(find.byKey(const ValueKey('boton-mas')));
    }
    await tester.tap(find.text('PESAR'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.textContaining('Equilibrio.'), findsOneWidget);
    expect(registro.registros, isEmpty);
    await tester.pump(const Duration(seconds: 2));
  });
}
