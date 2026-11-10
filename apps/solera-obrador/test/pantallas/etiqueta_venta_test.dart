import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/modelos/hornada.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/pantallas/pantalla_etiqueta_venta.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraObrador.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  testWidgets('desde una hornada: vista previa con lote y cambio a granel',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final ingredientes = {
      1: Ingrediente(id: 1, nombre: 'Harina de trigo', alergenos: {'gluten'}),
      2: Ingrediente(id: 2, nombre: 'Agua'),
    };
    final receta = Receta(
        id: 1, nombre: 'Hogaza', denominacion: 'pan_comun', piezasPorMasa: 2);
    final composicion = ComposicionReceta.calcular(
      recetaId: 1,
      recetas: {1: receta},
      lineasPorReceta: {
        1: [
          LineaReceta(recetaId: 1, ingredienteId: 1, gramos: 1000),
          LineaReceta(recetaId: 1, ingredienteId: 2, gramos: 700),
        ]
      },
      ingredientes: ingredientes,
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
          home: PantallaEtiquetaVenta(
        receta: receta,
        composicion: composicion,
        ingredientes: ingredientes,
        hornada: Hornada(
            recetaId: 1,
            fechaMs: DateTime(2026, 11, 10).millisecondsSinceEpoch,
            piezas: 6,
            codigoLote: '20261110-1-1'),
      )));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });
    final lista = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Así queda'), 300,
        scrollable: lista);
    expect(find.textContaining('L 20261110-1-1', findRichText: true),
        findsOneWidget);
    expect(find.text('6'), findsOneWidget); // copias = piezas de la hornada
    await tester.scrollUntilVisible(find.text('Granel / cartel'), -300,
        scrollable: lista);
    await tester.tap(find.text('Granel / cartel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Así queda'), 300,
        scrollable: lista);
    expect(find.textContaining('Contiene', findRichText: true), findsOneWidget);
    expect(find.textContaining('L 20261110-1-1', findRichText: true),
        findsNothing);
  });
}
