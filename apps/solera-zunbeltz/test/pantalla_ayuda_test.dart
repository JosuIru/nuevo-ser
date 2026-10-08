// La ayuda pinta sus apartados y el buscador filtra (y abre) los que casan.
// Además, la pantalla, el índice que usa el manual imprimible y los ARB
// tienen que decir lo mismo: ningún apartado sin pintar ni sin imprimir.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/pantallas/indice_ayuda.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_ayuda.dart';

Map<String, dynamic> _arb(String idioma) =>
    jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync())
        as Map<String, dynamic>;

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

  testWidgets('La pantalla muestra los apartados del índice, en su orden',
      (tester) async {
    tester.view.physicalSize = const Size(800, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver(const Locale('es')));
    await tester.pumpAndSettle();

    final arb = _arb('es');
    final titulosEsperados = [
      for (final apartados in indiceAyuda.values)
        for (final clave in apartados) arb['${clave}T'] as String,
    ];
    final titulosPintados = [
      for (final tile
          in tester.widgetList<ExpansionTile>(find.byType(ExpansionTile)))
        (tile.title as Text).data,
    ];
    expect(titulosPintados, titulosEsperados);
    for (final claveGrupo in indiceAyuda.keys) {
      expect(find.text(arb[claveGrupo] as String), findsOneWidget);
    }
  });

  test('Cada apartado de los ARB está en el índice y traducido', () {
    final enIndice = {for (final lista in indiceAyuda.values) ...lista};
    for (final idioma in ['es', 'eu']) {
      final arb = _arb(idioma);
      final enArb = {
        for (final clave in arb.keys)
          if (RegExp(r'^ayuda[A-Z]\w*T$').hasMatch(clave))
            clave.substring(0, clave.length - 1),
      };
      expect(enArb, enIndice, reason: 'apartados del ARB $idioma');
      for (final clave in enIndice) {
        expect((arb['${clave}B'] as String?)?.isNotEmpty, isTrue,
            reason: '${clave}B en $idioma');
      }
    }
  });
}
