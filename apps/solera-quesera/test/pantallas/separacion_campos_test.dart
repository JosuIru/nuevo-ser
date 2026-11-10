import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show separacionCamposSolera;
import 'package:solera_quesera/datos/base_datos.dart';
import 'package:solera_quesera/pantallas/pantalla_lista_recetas.dart';
import 'package:solera_quesera/pantallas/pantalla_nuevo_lote.dart';

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

/// Abre [pantalla] con la BD temporal y, si [tocarBotonFlotante], el
/// formulario de su botón flotante; luego comprueba sus campos.
Future<void> comprobarFormulario(WidgetTester tester, Widget pantalla,
    {bool tocarBotonFlotante = false}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: pantalla));
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
  if (tocarBotonFlotante) {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }
  comprobarSeparacionEntreCampos(tester);
}

void main() {
  final entorno = EntornoBaseDatosTemporal();
  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await BaseDatosSoleraQuesera.instancia.cerrar();
    await entorno.limpiar();
  });

  testWidgets('los campos de la receta no se pegan', (tester) async {
    await comprobarFormulario(tester, const PantallaListaRecetas(),
        tocarBotonFlotante: true);
  });

  testWidgets('los campos del lote nuevo no se pegan', (tester) async {
    await comprobarFormulario(tester, const PantallaNuevoLote());
  });
}
