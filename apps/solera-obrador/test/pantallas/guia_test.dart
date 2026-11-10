import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/dominio/guia_obrador.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/pantallas/pantalla_guia.dart';
import 'package:solera_obrador/servicios/copiar_receta_guia.dart';

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

  test('las claves de la guía están traducidas', () {
    expect(
        SoleraL10n.clavesDisponibles,
        containsAll([
          'obra.guia',
          'obra.guia_aviso',
          'obra.guia_copiar',
          for (final seccion in seccionesGuiaObrador)
            'obra.guia_seccion_$seccion',
        ]));
  });

  test('copiar una receta: gramos, ingredientes reutilizados y creados',
      () async {
    final harinaId = await baseDatos.guardarIngrediente(Ingrediente(
        nombre: 'harina de trigo', alergenos: {'gluten'}, proveedor: 'Molino'));
    final copia =
        await copiarRecetaGuia(recetaGuiaPorId('rustico')!, gramosHarina: 2000);
    final ingredientes = {
      for (final ingrediente in await baseDatos.listarIngredientes())
        ingrediente.id!: ingrediente
    };
    expect(ingredientes, hasLength(4), reason: 'reutiliza la harina');
    expect(copia.ingredientesCreados,
        unorderedEquals(['Agua', 'Sal', 'Levadura fresca de panadería']));
    expect(ingredientes[harinaId]!.proveedor, 'Molino');
    final recetas = await baseDatos.listarRecetas();
    final receta = recetas.single;
    expect(receta.nombre, 'Pan rústico de flama');
    expect(receta.denominacion, 'pan_comun');
    expect(receta.mermaCoccionPorcentaje, 15);
    final lineas = await baseDatos.lineasPorReceta();
    final gramos = {
      for (final linea in lineas[receta.id]!)
        ingredientes[linea.ingredienteId]!.nombre: linea.gramos
    };
    expect(gramos['harina de trigo'], 2000);
    expect(gramos['Agua'], 1360);
    expect(gramos['Sal'], 36);
    final composicion = ComposicionReceta.calcular(
        recetaId: receta.id!,
        recetas: {receta.id!: receta},
        lineasPorReceta: lineas,
        ingredientes: ingredientes);
    expect(composicion.alergenos, {'gluten'});
    expect(composicion.salEstimadaGramosPor100g, lessThan(1.31));
  });

  testWidgets('la guía cambia de sección, busca y abre la calculadora',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaGuiaObrador()));
    expect(find.text(SoleraL10n.t('obra.guia_aviso')), findsOneWidget);
    expect(find.text('Chapata'), findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('obra.guia_seccion_tiempos')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Temperatura del agua (fórmula)'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(1), '20');
    await tester.enterText(campos.at(2), '22');
    await tester.enterText(campos.at(3), '4');
    await tester.pump();
    expect(
        find.text(
            SoleraL10n.tf('obra.guia_calc_resultado', {'grados': '26,0'})),
        findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'centeno');
    await tester.pump();
    expect(find.text('Pan de centeno'), findsOneWidget);
    expect(find.text(SoleraL10n.t('obra.guia_seccion_recetas')), findsOneWidget,
        reason: 'con búsqueda se ven todas las secciones con su cabecera');
  });

  testWidgets('«Copiar a mis recetas» desde la ficha de la receta',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
          home: PantallaRecetaGuia(receta: recetaGuiaPorId('focaccia')!)));
      await tester.tap(find.text(SoleraL10n.t('obra.guia_copiar')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.text(SoleraL10n.t('obra.guia_copiar_por_masa')).first);
      await tester.pump();
      await tester.enterText(
          find.descendant(
              of: find.byType(AlertDialog), matching: find.byType(TextField)),
          '1835');
      await tester.tap(find.descendant(
          of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
      for (var vuelta = 0; vuelta < 6; vuelta++) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
    final receta = (await tester.runAsync(baseDatos.listarRecetas))!.single;
    expect(receta.nombre, 'Focaccia');
    final lineas = (await tester.runAsync(baseDatos.lineasPorReceta))!;
    expect(lineas[receta.id]!.map((linea) => linea.gramos),
        containsAll([1000.0, 750.0, 50.0, 20.0, 15.0]));
  });
}
