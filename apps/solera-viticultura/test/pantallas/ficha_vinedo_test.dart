import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_viticultura/pantallas/pantalla_editar_vinedo.dart';

void main() {
  testWidgets('la ficha del viñedo ofrece marcar el punto y el área',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarVinedo()));
    await tester.pumpAndSettle();
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await tester.scrollUntilVisible(marcarArea, 200,
        scrollable: find.byType(Scrollable).first);
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  group('punto del viñedo', () {
    const area = [
      LatLng(42.0, -1.0),
      LatLng(42.0, -0.99),
      LatLng(42.01, -0.99)
    ];

    test('si hay punto, se queda el punto', () {
      expect(puntoOCentroDelArea(41.5, -2.0, area), (41.5, -2.0));
    });

    test('si hay área y no punto, el punto es el centro del área', () {
      final (latitud, longitud) = puntoOCentroDelArea(null, null, area);
      expect(latitud, closeTo(42.0033, 0.001));
      expect(longitud, closeTo(-0.9933, 0.001));
    });

    test('sin punto ni área, no hay punto', () {
      expect(puntoOCentroDelArea(null, null, const []), (null, null));
    });
  });
}
