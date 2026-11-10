import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, separacionCamposSolera;
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

  testWidgets('entre dos campos seguidos queda la separación común',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: PantallaNuevoApiario()));
    await tester.pumpAndSettle();
    final cajas = find.byType(InputDecorator);
    final rectangulos = [
      for (var indice = 0; indice < cajas.evaluate().length; indice++)
        tester.getRect(cajas.at(indice)),
    ]..sort((a, b) => a.top.compareTo(b.top));
    expect(rectangulos.length, greaterThanOrEqualTo(5));
    for (var indice = 1; indice < rectangulos.length; indice++) {
      expect(
        rectangulos[indice].top - rectangulos[indice - 1].bottom,
        greaterThanOrEqualTo(separacionCamposSolera),
        reason: 'campo $indice',
      );
    }
  });
}
