// La ayuda pinta sus apartados y el buscador filtra (y abre) los que casan.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_ayuda.dart';

Widget _envolver(Locale idioma) => MaterialApp(
      locale: idioma,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PantallaAyuda(),
    );

void main() {
  testWidgets('Muestra los grupos y apartados en castellano', (tester) async {
    await tester.pumpWidget(_envolver(const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Primeros pasos'), findsOneWidget);
    expect(find.text('¿Qué es esta app?'), findsOneWidget);
  });

  testWidgets('Buscar filtra sin distinguir tildes y abre el apartado',
      (tester) async {
    await tester.pumpWidget(_envolver(const Locale('es')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'periodica');
    await tester.pumpAndSettle();
    expect(find.text('Tareas que se repiten'), findsOneWidget);
    expect(find.text('¿Qué es esta app?'), findsNothing);
    // Abierto: se ve un paso numerado del cuerpo.
    expect(find.textContaining('crea sola la siguiente'), findsOneWidget);
  });

  testWidgets('Sin coincidencias muestra el aviso', (tester) async {
    await tester.pumpWidget(_envolver(const Locale('eu')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('Ez dago hitz hori'), findsOneWidget);
  });
}
