import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aceitera/pantallas/pantalla_nueva_parcela.dart';

void main() {
  testWidgets('el alta de parcela ofrece marcar el punto y el área',
      (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: PantallaNuevaParcela(olivarId: 1)));
    await tester.pumpAndSettle();
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await tester.scrollUntilVisible(marcarArea, 200,
        scrollable: find.byType(Scrollable).first);
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });
}
