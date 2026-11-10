import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, separacionCamposSolera;
import 'package:solera_viticultura/modelos/vinedo.dart';
import 'package:solera_viticultura/pantallas/pantalla_editar_vinedo.dart';

void main() {
  testWidgets('la ficha del viñedo ofrece marcar el punto y el área', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarVinedo()));
    await tester.pumpAndSettle();
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await tester.scrollUntilVisible(
      marcarArea,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  testWidgets('entre dos filas de campos queda la separación común', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarVinedo()));
    await tester.pumpAndSettle();
    final cajas = find.byType(InputDecorator);
    final rectangulos = [
      for (var indice = 0; indice < cajas.evaluate().length; indice++)
        tester.getRect(cajas.at(indice)),
    ]..sort((a, b) => a.top.compareTo(b.top));
    // Agrupa por fila (los campos de una Row comparten la parte de arriba).
    final filas = <Rect>[];
    for (final caja in rectangulos) {
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

  testWidgets('borrar solo aparece al editar un viñedo guardado', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarVinedo()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaEditarVinedo(
          vinedo: Vinedo(
            id: 7,
            nombre: 'Viña Alta',
            colorEntero: 0xFF7D2A2A,
            fechaCreacionMs: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(
      find.text(
        SoleraL10n.tf('viti.borrar_vinedo_aviso', {'nombre': 'Viña Alta'}),
      ),
      findsOneWidget,
    );
    // Cancelar no borra ni cierra la ficha.
    await tester.tap(find.text(SoleraL10n.t('cancelar')));
    await tester.pumpAndSettle();
    expect(find.text('Viña Alta'), findsWidgets);
  });

  group('punto del viñedo', () {
    const area = [
      LatLng(42.0, -1.0),
      LatLng(42.0, -0.99),
      LatLng(42.01, -0.99),
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
