import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show separacionCamposSolera;
import 'package:solera_aceitera/datos/base_datos.dart';
import 'package:solera_aceitera/pantallas/pantalla_nueva_parcela.dart';
import 'package:solera_aceitera/pantallas/pantalla_nuevo_ingreso.dart';

import '../datos/soporte_contrato_base_datos.dart';

/// Comprueba que entre cada par de campos seguidos (uno debajo del otro)
/// queda al menos la separación común del core.
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

void ponerPantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  final entorno = EntornoBaseDatosTemporal();
  setUp(entorno.preparar);
  tearDown(() async {
    await BaseDatosSoleraAceitera.instancia.cerrar();
    await entorno.limpiar();
  });

  testWidgets('los campos del ingreso no se pegan', (tester) async {
    ponerPantallaAlta(tester);
    // Con la fuente de los tests (cada letra un cuadrado ancho), las
    // etiquetas largas de los desplegables de tipo y parcela desbordan por
    // la derecha. No es lo que se mide aquí: se ignora solo ese aviso.
    final avisoErroresOriginal = FlutterError.onError;
    FlutterError.onError = (detalles) {
      if (detalles.exceptionAsString().contains('RenderFlex overflowed')) {
        return;
      }
      avisoErroresOriginal?.call(detalles);
    };
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaNuevoIngreso()));
      for (var intento = 0;
          intento < 100 &&
              find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
          intento++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    FlutterError.onError = avisoErroresOriginal;
    comprobarSeparacionEntreCampos(tester);
  });

  testWidgets('los campos de la parcela no se pegan', (tester) async {
    ponerPantallaAlta(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PantallaNuevaParcela(olivarId: 1)),
    );
    await tester.pumpAndSettle();
    comprobarSeparacionEntreCampos(tester);
  });
}
