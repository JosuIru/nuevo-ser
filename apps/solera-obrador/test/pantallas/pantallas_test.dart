import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/modelos/hornada.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/masa_madre.dart';
import 'package:solera_obrador/modelos/pedido_fijo.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_obrador/pantallas/pantalla_ayuda.dart';
import 'package:solera_obrador/pantallas/pantalla_hornadas.dart';
import 'package:solera_obrador/pantallas/pantalla_hoy.dart';
import 'package:solera_obrador/pantallas/pantalla_masa_madre.dart';
import 'package:solera_obrador/pantallas/pantalla_pedidos_fijos.dart';
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
      // Con ingredientes y recetas ya no sale la tarjeta de primeros pasos.
      await baseDatos.guardarIngrediente(Ingrediente(nombre: 'Harina'));
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

  testWidgets('pedidos fijos, masa madre y hornadas se listan', (tester) async {
    await tester.runAsync(() async {
      final pan = await baseDatos.guardarReceta(Receta(nombre: 'Barra'));
      await baseDatos.guardarPedidoFijo(PedidoFijo(
          cliente: 'Bar Txoko', recetaId: pan, piezas: 8, diasSemana: {1, 5}));
      final masa = await baseDatos
          .guardarMasaMadre(MasaMadre(nombre: 'Centeno', creadaMs: 0));
      await baseDatos.guardarRefresco(RefrescoMasaMadre(
          masaMadreId: masa,
          fechaMs: 0,
          gramosMasaMadre: 50,
          gramosHarina: 100,
          gramosAgua: 100));
      await baseDatos.guardarHornada(Hornada(
          recetaId: pan,
          fechaMs: DateTime.now().millisecondsSinceEpoch,
          piezas: 40,
          codigoLote: 'L-7'));
    });
    for (final (pantalla, esperado) in [
      (const PantallaPedidosFijos(), 'Bar Txoko · Barra'),
      (const PantallaMasaMadre(), '1:2:2 · 100 %'),
      (const PantallaHornadas(), 'Barra · 40'),
    ]) {
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(home: pantalla));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
      });
      expect(find.text(esperado), findsOneWidget, reason: '$pantalla');
    }
  });

  test('cada apartado de la ayuda tiene título y texto traducidos', () {
    for (final (titulo, texto) in apartadosAyudaObrador) {
      expect(SoleraL10n.clavesDisponibles, containsAll([titulo, texto]));
    }
  });
}
