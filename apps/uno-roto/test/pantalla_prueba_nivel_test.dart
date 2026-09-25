import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/nivel_escolar.dart';
import 'package:uno_roto/dominio/prueba_nivel.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/l10n/narrativa_ca.dart';
import 'package:uno_roto/l10n/narrativa_eu.dart';
import 'package:uno_roto/vista/pantalla_prueba_nivel.dart';
import 'dart:math' as math;

void main() {
  testWidgets('quien lo sabe todo acaba en 2.º de ESO, y se aplica al perfil', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioProgreso();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    NivelEscolar? devuelto;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: Builder(
        builder: (contexto) => TextButton(
          onPressed: () async => devuelto = await Navigator.of(contexto).push<NivelEscolar>(
              MaterialPageRoute(builder: (_) => PantallaPruebaNivel(repositorio: repositorio, semilla: 5))),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No cuentan para nada'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('prueba-empezar')));
    await tester.pump();
    // La misma secuencia de preguntas que verá la pantalla: se contesta
    // siempre la buena.
    final espejo = PruebaNivel(azar: math.Random(5));
    while (!espejo.terminada) {
      final respuesta = espejo.preguntaActual.respuesta;
      expect(find.byKey(ValueKey('prueba-opcion-$respuesta')), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('prueba-opcion-$respuesta')));
      await tester.pump();
      espejo.responder(respuesta);
    }
    expect(find.textContaining('2.º de ESO'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('prueba-vamos')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(devuelto, NivelEscolar.segundoEso);
    expect(await tester.runAsync(repositorio.cargarNivelEscolar), NivelEscolar.segundoEso);
    // Lo de 4.º de Primaria (FR.01), dado por sabido.
    expect((await tester.runAsync(() => repositorio.cargarEstadoHabilidad('FR.01')))!.nivel.index, greaterThanOrEqualTo(3));
  });

  test('todos los enunciados y las frases de la prueba están traducidos', () {
    final generador = GeneradorPreguntasNivel(azar: math.Random(2));
    final textos = <String>{
      for (final curso in NivelEscolar.values) ...[
        curso.nombre,
        for (var i = 0; i < 60; i++) generador.pregunta(curso).enunciado,
      ],
      'Son iguales',
    };
    for (final texto in textos) {
      expect(narrativaEu.containsKey(texto) && narrativaCa.containsKey(texto), isTrue, reason: texto);
    }
  });
}
