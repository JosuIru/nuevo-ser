import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aromaticas/datos/base_datos.dart';
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';
import 'package:solera_aromaticas/pantallas/pantalla_campo.dart';
import 'package:solera_aromaticas/pantallas/pantalla_editar_origen.dart';
import 'package:solera_aromaticas/pantallas/pantalla_hoy.dart';
import 'package:solera_aromaticas/pantallas/pantalla_lotes.dart';
import 'package:solera_aromaticas/pantallas/pantalla_taller.dart';
import 'package:solera_aromaticas/servicios/fotos_wikipedia.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraAromaticas.instancia;

  setUpAll(() async {
    await initializeDateFormatting();
    // Sin red en los tests: la guía abre sin fotos.
    buscadorFotosGuia = (_) async => const [];
  });
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Deja correr la BD real (ffi) y repinta varias veces.
  Future<void> esperar(WidgetTester tester, [int milisegundos = 300]) async {
    for (var vuelta = 0; vuelta < 4; vuelta++) {
      await Future<void>.delayed(Duration(milliseconds: milisegundos ~/ 2));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Hoy: primeros pasos sin parcelas ni zonas', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('arom.primeros_pasos')), findsOneWidget);
    expect(find.text(SoleraL10n.t('arom.catalogos_provisionales')),
        findsOneWidget);
  });

  testWidgets('Hoy: una especie en temporada abre su ficha de la guía',
      (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarParcela(
          Parcela(nombre: 'Bancal', especieId: 'lavanda', superficieHa: 1));
      await tester.pumpWidget(MaterialApp(
          home: PantallaHoy(fechaParaPruebas: DateTime(2026, 8, 10))));
      await esperar(tester);
    });
    final enTemporada = find.widgetWithText(ListTile, 'Lavanda');
    await tester.ensureVisible(enTemporada);
    await tester.tap(enTemporada);
    await tester.pumpAndSettle();
    expect(find.text('Lavandula angustifolia'), findsWidgets);
    expect(find.text(SoleraL10n.t('arom.guia_rasgos')), findsOneWidget);
    expect(find.text(SoleraL10n.t('arom.guia_aviso')), findsOneWidget);
  });

  testWidgets('la ficha de parcela ofrece marcar el punto y el área',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PantallaEditarParcela()));
    await tester.pumpAndSettle();
    final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
    await tester.scrollUntilVisible(marcarArea, 200,
        scrollable: find.byType(Scrollable).first);
    expect(marcarArea, findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  testWidgets('Hoy: zona sin permiso y permiso que vence', (tester) async {
    await tester.runAsync(() async {
      final pronto = DateTime.now().add(const Duration(days: 5));
      await baseDatos
          .guardarZonaRecoleccion(ZonaRecoleccion(nombre: 'Barranco'));
      await baseDatos.guardarZonaRecoleccion(ZonaRecoleccion(
          nombre: 'Comunal',
          numeroPermiso: 'P-1',
          finVigenciaMs: pronto.millisecondsSinceEpoch));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Barranco'), findsOneWidget);
    expect(
        find.text(SoleraL10n.t('arom.sin_permiso_apuntado')), findsOneWidget);
    expect(find.text('Comunal'), findsOneWidget);
  });

  testWidgets('alta de una zona de recolección con su permiso', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaEditarZona()));
      await esperar(tester, 100);
      await tester.enterText(find.byType(TextField).at(0), 'Monte comunal');
      await tester.enterText(find.byType(TextField).at(4), 'AUT-7');
      final boton = find.byType(FilledButton);
      await tester.scrollUntilVisible(boton, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(boton);
      await esperar(tester);
    });
    final zona =
        (await tester.runAsync(baseDatos.listarZonasRecoleccion))!.single;
    expect((zona.nombre, zona.numeroPermiso, zona.tipoTerreno),
        ('Monte comunal', 'AUT-7', 'monte_publico'));
  });

  testWidgets('Campo lista parcelas y, en su pestaña, las zonas',
      (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarParcela(
          Parcela(nombre: 'Bancal', especieId: 'lavandin', superficieHa: 1.5));
      await baseDatos.guardarZonaRecoleccion(ZonaRecoleccion(
          nombre: 'Solana', numeroPermiso: 'P-9', limiteKg: 300));
      await tester.pumpWidget(const MaterialApp(home: PantallaCampo()));
      await esperar(tester);
    });
    expect(find.text('Bancal'), findsOneWidget);
    expect(find.textContaining('Lavandín'), findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('arom.zonas')));
    await tester.pumpAndSettle();
    expect(find.text('Solana'), findsOneWidget);
    expect(find.textContaining('0 de 300 kg'), findsOneWidget);
  });

  testWidgets('Taller enseña el rendimiento de la destilación', (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarDestilacion(Destilacion(
          fechaMs: DateTime.now().millisecondsSinceEpoch,
          especieId: 'romero',
          kgPlanta: 100,
          mlAceiteEsencial: 400,
          litrosHidrolato: 30));
      await tester.pumpWidget(const MaterialApp(home: PantallaTaller()));
      await esperar(tester);
    });
    expect(find.text('Romero · 100 kg → 400 ml'), findsOneWidget);
    // 4 ml/kg: dentro del intervalo orientativo del romero (2-6 g/kg).
    expect(
        find.textContaining(SoleraL10n.t('arom.rend_dentro')), findsOneWidget);
  });

  testWidgets('la ficha del lote sigue la trazabilidad hasta la zona',
      (tester) async {
    late int lote;
    await tester.runAsync(() async {
      final zona = await baseDatos.guardarZonaRecoleccion(
          ZonaRecoleccion(nombre: 'Umbría', numeroPermiso: 'AUT-3'));
      final cosecha = await baseDatos.guardarCosecha(Cosecha(
          zonaRecoleccionId: zona,
          especieId: 'tomillo_comun',
          fechaMs: DateTime(2026, 6, 1).millisecondsSinceEpoch,
          kgFrescos: 80));
      lote = await baseDatos.guardarLoteProducto(LoteProducto(
          codigo: 'AE-2026-001',
          tipo: 'aceite_esencial',
          especieId: 'tomillo_comun',
          fechaMs: DateTime(2026, 6, 2).millisecondsSinceEpoch,
          cantidad: 200));
      await baseDatos.guardarDestilacion(Destilacion(
          fechaMs: DateTime(2026, 6, 2).millisecondsSinceEpoch,
          especieId: 'tomillo_comun',
          cosechasUsadasIds: [cosecha],
          kgPlanta: 80,
          mlAceiteEsencial: 200,
          loteAceiteId: lote));
      await tester
          .pumpWidget(MaterialApp(home: PantallaFichaLote(loteId: lote)));
      await esperar(tester);
    });
    expect(find.text('AE-2026-001'), findsOneWidget);
    expect(find.text('Umbría'), findsOneWidget);
    expect(find.text(SoleraL10n.tf('arom.permiso_n', {'numero': 'AUT-3'})),
        findsOneWidget);
  });

  testWidgets('Lotes vacío explica de dónde salen', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaLotes()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('arom.sin_lotes')), findsOneWidget);
  });
}
