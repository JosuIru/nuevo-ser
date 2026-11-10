import 'package:agro/modelos/finca.dart';
import 'package:agro/pantallas/pantalla_editar_sigpac.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, separacionCamposSolera;
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

  testWidgets('entre dos filas de campos queda la separación común', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await abrirFicha(
      tester,
      Finca(id: 1, nombre: 'El Soto', colorEntero: 1, fechaCreacionMs: 1),
    );
    final cajas = tester
        .widgetList(find.byType(InputDecorator))
        .map((caja) => tester.getRect(find.byWidget(caja)))
        .toList();
    // Agrupa por fila (los campos de una Row comparten la parte de arriba).
    final filas = <Rect>[];
    for (final caja in cajas..sort((a, b) => a.top.compareTo(b.top))) {
      if (filas.isNotEmpty && (caja.top - filas.last.top).abs() < 1) {
        filas.last = filas.last.expandToInclude(caja);
      } else {
        filas.add(caja);
      }
    }
    expect(filas.length, greaterThanOrEqualTo(3));
    for (var indice = 1; indice < filas.length; indice++) {
      expect(
        filas[indice].top - filas[indice - 1].bottom,
        greaterThanOrEqualTo(separacionCamposSolera),
        reason: 'fila $indice',
      );
    }
  });
}
