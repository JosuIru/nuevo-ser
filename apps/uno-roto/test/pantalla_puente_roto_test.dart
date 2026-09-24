import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/dominio/minijuegos/puentes.dart';
import 'package:uno_roto/dominio/problema_espejo.dart' show Fraccion;
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_puentes.dart';

/// El puente roto: sale montado entero; quitando lo que sobra, pasa.
void main() {
  const semilla = 7;

  testWidgets('se quita lo que sobra y el carro pasa', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
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
        habilidadesPracticadas: ['FR.15'],
        semilla: semilla,
      ),
    ));
    await tester.pump();
    final reto = GeneradorPuentes(semilla: semilla).generar(ModoPuente.restaMismoDenominador, dificultad: 1);
    expect(find.textContaining('ha salido largo'), findsOneWidget);

    final sobrantes = <Fraccion>[...reto.tablones];
    for (final tablon in reto.solucion) {
      sobrantes.remove(tablon);
    }
    for (final sobrante in sobrantes) {
      await tester.tap(find
          .ancestor(
            of: find.text(reto.etiqueta(sobrante)),
            matching: find.byWidgetPredicate((w) =>
                w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('tablon-En el puente-')),
          )
          .first);
      await tester.pump();
    }
    await tester.tap(find.text('PROBAR EL PUENTE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Justo. El carro pasa.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpWidget(const SizedBox());
  });
}
