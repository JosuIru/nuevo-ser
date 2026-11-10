// Pantalla de la guía del huerto y tarjeta «Esta semana en el huerto».

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_huerta/dominio/guia.dart';
import 'package:solera_huerta/pantallas/pantalla_guia.dart';
import 'package:solera_huerta/pantallas/pantalla_hoy.dart';

void main() {
  setUpAll(initializeDateFormatting);

  Future<void> abrirGuia(WidgetTester tester,
      {SeccionGuia seccion = SeccionGuia.cultivos}) async {
    await tester
        .pumpWidget(MaterialApp(home: PantallaGuia(seccionInicial: seccion)));
    await tester.pumpAndSettle();
  }

  testWidgets('cuatro secciones y el buscador filtra', (tester) async {
    await abrirGuia(tester);
    for (final clave in [
      'huer.guia_cultivos',
      'huer.guia_fauna',
      'huer.guia_plantas',
      'huer.guia_tecnicas',
    ]) {
      expect(find.text(SoleraL10n.t(clave)), findsOneWidget);
    }
    await tester.enterText(find.byType(TextField), 'calabac');
    await tester.pumpAndSettle();
    expect(find.text('Calabacín'), findsOneWidget);
    expect(find.text('Tomate'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('huer.guia_sin_resultados')), findsOneWidget);
  });

  testWidgets('ficha de cultivo con aviso, calendario y fuentes',
      (tester) async {
    await abrirGuia(tester);
    await tester.enterText(find.byType(TextField), 'tomate');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomate').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('aviso-guia')), findsOneWidget);
    expect(find.text(SoleraL10n.t('huer.guia_aviso')), findsOneWidget);
    expect(find.text(SoleraL10n.t('huer.guia_calendario')), findsOneWidget);
    final tradicion =
        find.text(SoleraL10n.t('huer.guia_asociaciones_tradicion'));
    await tester.scrollUntilVisible(tradicion, 300,
        scrollable: find.byType(Scrollable).last);
    expect(tradicion, findsOneWidget);
    final fuentes = find.text(SoleraL10n.t('huer.guia_fuentes'));
    await tester.scrollUntilVisible(fuentes, 300,
        scrollable: find.byType(Scrollable).last);
    expect(fuentes, findsOneWidget);
  });

  testWidgets('desde una plaga de la ficha, la fauna que la combate',
      (tester) async {
    await abrirGuia(tester);
    await tester.enterText(find.byType(TextField), 'haba');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haba').first);
    await tester.pumpAndSettle();
    final chip = find.widgetWithText(ActionChip, 'Pulgones');
    await tester.scrollUntilVisible(chip, 300,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('huer.guia_auxiliares')), findsOneWidget);
    expect(find.text('Mariquitas'), findsOneWidget);
  });

  testWidgets('fauna: ficha con cómo reconocerla y plantas que la atraen',
      (tester) async {
    await abrirGuia(tester, seccion: SeccionGuia.fauna);
    await tester.tap(find.text('Sírfidos (moscas de las flores)'));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('huer.guia_reconocer')), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text(SoleraL10n.t('huer.guia_plantas_que_atraen')), 300,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Aliso marítimo'), findsOneWidget);
  });

  testWidgets('técnica de rotación con la tabla de años de la app',
      (tester) async {
    await abrirGuia(tester, seccion: SeccionGuia.tecnicas);
    await tester.enterText(find.byType(TextField), 'rotación');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rotación de cultivos'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text(SoleraL10n.t('huer.guia_rotacion_tabla')), 300,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Solanáceas'), findsOneWidget);
  });

  testWidgets('tarjeta «Esta semana en el huerto» abre la ficha',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: TarjetaSemanaGuia(mes: 10, especiesPropias: {'haba'}))));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('huer.guia_semana_titulo')), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(4));
    await tester.tap(find.text('Haba'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('aviso-guia')), findsOneWidget);
  });
}
