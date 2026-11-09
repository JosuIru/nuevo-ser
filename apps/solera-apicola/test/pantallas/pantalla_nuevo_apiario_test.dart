import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_apicola/pantallas/pantalla_nuevo_apiario.dart';

void main() {
  testWidgets('la ficha del apiario ofrece marcar el punto y el área',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaNuevoApiario()));
    await tester.pumpAndSettle();
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await tester.scrollUntilVisible(marcarArea, 200,
        scrollable: find.byType(Scrollable).first);
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });
}
