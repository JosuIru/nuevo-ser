import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, separacionCamposSolera;
import 'package:solera_arbolado_urbano/datos/base_datos.dart';
import 'package:solera_arbolado_urbano/pantallas/pantalla_editar_zona.dart';
import 'package:solera_arbolado_urbano/pantallas/pantalla_tecnicos.dart';

import '../datos/soporte_contrato_base_datos.dart';

/// Comprueba que entre cada par de campos visibles seguidos (uno debajo del
/// otro) queda al menos la separación común del core.
void comprobarSeparacionEntreCampos(WidgetTester tester) {
  final cajas = find.byType(InputDecorator);
  final rectangulos = [
    for (var indice = 0; indice < cajas.evaluate().length; indice++)
      tester.getRect(cajas.at(indice)),
  ]..sort((primero, segundo) => primero.top.compareTo(segundo.top));
  expect(rectangulos.length, greaterThanOrEqualTo(2));
  for (var indice = 1; indice < rectangulos.length; indice++) {
    final anterior = rectangulos[indice - 1];
    final actual = rectangulos[indice];
    // Dos campos de la misma fila no cuentan.
    if ((actual.top - anterior.top).abs() < 1) continue;
    expect(
      actual.top - anterior.bottom,
      greaterThanOrEqualTo(separacionCamposSolera),
      reason: 'campos $indice-1 y $indice',
    );
  }
}

void main() {
  final entorno = EntornoBaseDatosTemporal();

  setUp(entorno.preparar);
  tearDown(() async {
    await BaseDatosSoleraArbolado.instancia.cerrar();
    await entorno.limpiar();
  });

  testWidgets('los campos de la ficha de zona no se pegan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarZona()));
    await tester.pumpAndSettle();
    comprobarSeparacionEntreCampos(tester);
  });

  testWidgets('los campos del técnico no se pegan', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: PantallaTecnicos()));
      for (var intento = 0;
          intento < 50 &&
              find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
          intento++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('arb.carnet_de_aplicador')), findsOneWidget);
    comprobarSeparacionEntreCampos(tester);
  });
}
