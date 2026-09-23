import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/dominio/minijuegos/puentes.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_puentes.dart';

/// Puentes: un puente exacto pasa a la siguiente ronda; uno corto se
/// queda y lo dice, sin castigo.
void main() {
  const semilla = 7;

  Widget envolver() => MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
        home: const PantallaPuentes(
          registro: null,
          dificultad: 1,
          habilidadesPracticadas: ['FR.14'],
          semilla: semilla,
        ),
      );

  // El primer reto de la pantalla es el primero que da el generador con
  // la misma semilla.
  final reto = GeneradorPuentes(semilla: semilla)
      .generar(ModoPuente.mismoDenominador, dificultad: 1);

  Finder tablonDeLaBandeja(String etiqueta) => find
      .ancestor(
        of: find.text(etiqueta),
        matching: find.byWidgetPredicate((w) =>
            w.key is ValueKey &&
            '${(w.key as ValueKey).value}'.startsWith('tablon-Tablones-')),
      )
      .first;

  Future<void> preparar(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(envolver());
    await tester.pump();
  }

  testWidgets('un puente exacto cruza y pasa a la ronda 2', (tester) async {
    await preparar(tester);
    expect(find.text('1 / 5'), findsOneWidget);
    for (final tablon in reto.solucion) {
      await tester.tap(tablonDeLaBandeja(reto.etiqueta(tablon)));
      await tester.pump();
    }
    await tester.tap(find.text('PROBAR EL PUENTE'));
    await tester.pump(); // arranca el carro
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Justo. El carro pasa.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('un puente corto se queda en la misma ronda', (tester) async {
    await preparar(tester);
    // Un solo tablón de la solución nunca basta (hay al menos dos).
    await tester.tap(tablonDeLaBandeja(reto.etiqueta(reto.solucion.first)));
    await tester.pump();
    await tester.tap(find.text('PROBAR EL PUENTE'));
    await tester.pump(); // arranca el carro
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Falta un trozo'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });
}
