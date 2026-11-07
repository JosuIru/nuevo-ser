import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/modelos/pedido_fijo.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/pantallas/pantalla_hoy.dart';
import 'package:solera_obrador/pantallas/pantalla_ingredientes.dart';

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

  testWidgets('alta de un ingrediente desde la lista', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaIngredientes()));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Harina de espelta');
      await tester
          .tap(find.text('Gluten').first); // el de alérgenos, no el de trazas
      await tester.pump();
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: find
              .descendant(
                  of: find.byType(PantallaEditarIngrediente),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(find.byType(FilledButton));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });
    expect(find.text('Harina de espelta'), findsOneWidget);
    expect(
        (await tester.runAsync(baseDatos.listarIngredientes))!.single.alergenos,
        {'gluten'});
  });

  testWidgets('Hoy muestra las piezas pedidas para hoy', (tester) async {
    await tester.runAsync(() async {
      final pan =
          await baseDatos.guardarReceta(Receta(nombre: 'Pan de pueblo'));
      await baseDatos.guardarPedidoFijo(PedidoFijo(
          cliente: 'Bar',
          recetaId: pan,
          piezas: 12,
          diasSemana: {1, 2, 3, 4, 5, 6, 7}));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });
    expect(find.text('Pan de pueblo'), findsOneWidget);
    expect(find.text('12'), findsWidgets);
  });
}
