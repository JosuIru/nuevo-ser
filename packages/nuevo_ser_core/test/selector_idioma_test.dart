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

  test('un valor guardado raro no cambia el idioma', () async {
    SharedPreferences.setMockInitialValues({'solera.idioma_app': 'xx'});
    await cargarIdiomaSolera();
    expect(SoleraL10n.idioma, 'es');
  });
}
