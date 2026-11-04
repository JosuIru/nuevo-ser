import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SoleraL10n.idioma = 'es');

  testWidgets('el idioma elegido se guarda y se recupera al volver a abrir',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SelectorIdioma())));
    await tester.tap(find.text('Euskera'));
    await tester.pumpAndSettle();
    expect(SoleraL10n.idioma, 'eu');

    SoleraL10n.idioma = 'es'; // como al cerrar y abrir la app
    await cargarIdiomaSolera();
    expect(SoleraL10n.idioma, 'eu');
  });

  testWidgets('al elegir idioma cambian el chip y los textos de la pantalla',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          const _TextoTraducido(),
          const SelectorIdioma(),
        ]),
      ),
    ));
    final textoEnCastellano = SoleraL10n.t('seccion_preferencias');
    expect(find.text(textoEnCastellano), findsOneWidget);

    await tester.tap(find.text('Euskera'));
    await tester.pumpAndSettle();

    final chipEuskera = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Euskera'));
    expect(chipEuskera.selected, isTrue);
    expect(find.text(SoleraL10n.t('seccion_preferencias', idioma: 'eu')),
        findsOneWidget);
  });

  test('un valor guardado raro no cambia el idioma', () async {
    SharedPreferences.setMockInitialValues({'solera.idioma_app': 'xx'});
    await cargarIdiomaSolera();
    expect(SoleraL10n.idioma, 'es');
  });
}

class _TextoTraducido extends StatelessWidget {
  const _TextoTraducido();

  @override
  Widget build(BuildContext context) =>
      Text(SoleraL10n.t('seccion_preferencias'));
}
