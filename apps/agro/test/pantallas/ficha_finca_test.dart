import 'package:agro/modelos/finca.dart';
import 'package:agro/pantallas/pantalla_editar_sigpac.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;

Future<void> abrirFicha(WidgetTester tester, Finca finca) async {
  await tester.pumpWidget(
    MaterialApp(home: PantallaEditarSigpac(finca: finca)),
  );
  await tester.pumpAndSettle();
}

Future<void> desplazarHasta(WidgetTester tester, Finder objetivo) =>
    tester.scrollUntilVisible(
      objetivo,
      200,
      scrollable: find.byType(Scrollable).first,
    );

void main() {
  testWidgets('la ficha de la finca ofrece marcar el punto y el área', (
    tester,
  ) async {
    await abrirFicha(
      tester,
      Finca(id: 1, nombre: 'El Soto', colorEntero: 1, fechaCreacionMs: 1),
    );
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await desplazarHasta(tester, marcarArea);
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  testWidgets('con área, ofrece copiar la superficie calculada al campo', (
    tester,
  ) async {
    const area = [
      LatLng(42.0, -1.0),
      LatLng(42.0, -0.99),
      LatLng(42.01, -0.99),
      LatLng(42.01, -1.0),
    ];
    await abrirFicha(
      tester,
      Finca(
        id: 1,
        nombre: 'El Soto',
        colorEntero: 1,
        fechaCreacionMs: 1,
        contorno: codificarContorno(area),
      ),
    );
    final usarSuperficie = find.textContaining(
      SoleraL10n.tf('mapa.usar_superficie', {'hectareas': ''}).split('(').first,
    );
    await desplazarHasta(tester, usarSuperficie);
    final campoSuperficie = find.widgetWithText(
      TextField,
      SoleraL10n.t('agro.superficie_hectareas'),
    );
    expect(tester.widget<TextField>(campoSuperficie).controller!.text, isEmpty);

    await tester.ensureVisible(usarSuperficie);
    await tester.pumpAndSettle();
    await tester.tap(usarSuperficie);
    await tester.pump();
    // Unas 90 ha (0,01° × 0,01° a 42° N): no se copia sola, solo al pulsar.
    final copiada = tester.widget<TextField>(campoSuperficie).controller!.text;
    expect(copiada, isNotEmpty);
    expect(double.parse(copiada.replaceAll(',', '.')), closeTo(91.8, 2));
  });
}
