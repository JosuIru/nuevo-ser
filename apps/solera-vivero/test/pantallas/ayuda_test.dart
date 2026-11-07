import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_vivero/pantallas/pantalla_ayuda.dart';

void main() {
  testWidgets('la ayuda tiene sus apartados y dice lo que la app no hace',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaAyuda()));
    expect(
        find.byType(ExpansionTile), findsNWidgets(apartadosAyudaVivero.length));
    await tester.scrollUntilVisible(
        find.text(SoleraL10n.t('vive.ayuda_limites_titulo')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(SoleraL10n.t('vive.ayuda_limites_titulo')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No expide pasaportes'), findsOneWidget);
  });
}
