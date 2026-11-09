import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aromaticas/pantallas/pantalla_guia.dart';

/// Sin red en los tests: ninguna especie tiene fotos.
Future<List<String>> _sinFotos(String _) async => const [];

void main() {
  setUpAll(initializeDateFormatting);

  Future<void> abrirGuia(WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PantallaGuia(buscarFotos: _sinFotos)));
    await tester.pumpAndSettle();
  }

  testWidgets('la lista avisa de que no habilita el consumo y busca',
      (tester) async {
    await abrirGuia(tester);
    expect(find.text(SoleraL10n.t('arom.guia_aviso')), findsOneWidget);
    // La primera familia por orden alfabético.
    expect(find.text('Apiaceae'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'genciana');
    await tester.pumpAndSettle();
    expect(find.text('Genciana'), findsOneWidget);
    expect(find.text('Lavanda'), findsNothing);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('arom.guia_sin_resultados')), findsOneWidget);
  });

  testWidgets('la ficha muestra rasgos, protección y confundibles',
      (tester) async {
    await abrirGuia(tester);
    await tester.enterText(find.byType(TextField), 'genciana');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Genciana'));
    await tester.pumpAndSettle();

    expect(find.text('Gentiana lutea'), findsWidgets);
    expect(find.text(SoleraL10n.t('arom.guia_rasgos')), findsOneWidget);
    expect(find.text(SoleraL10n.t('arom.guia_sin_epoca')), findsOneWidget);
    expect(find.textContaining(SoleraL10n.t('arom.aviso_especie_protegida')),
        findsWidgets);
    expect(find.text(SoleraL10n.t('arom.guia_sin_fotos')), findsOneWidget);
    // Aviso de no consumo: en la lista (detrás) y en la ficha.
    expect(find.text(SoleraL10n.t('arom.guia_aviso')), findsNWidgets(2));
  });

  testWidgets('desde una confundible se abre su ficha', (tester) async {
    await abrirGuia(tester);
    await tester.enterText(find.byType(TextField), 'lavandula angustifolia');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lavanda'));
    await tester.pumpAndSettle();
    final chipEspliego = find.widgetWithText(ActionChip, 'Espliego');
    await tester.ensureVisible(chipEspliego);
    await tester.pumpAndSettle();
    await tester.tap(chipEspliego);
    await tester.pumpAndSettle();
    expect(find.text('Lavandula latifolia'), findsWidgets);
  });
}
