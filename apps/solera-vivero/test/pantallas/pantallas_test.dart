import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_vivero/datos/base_datos.dart';
import 'package:solera_vivero/modelos/bandeja.dart';
import 'package:solera_vivero/modelos/inspeccion_plagas.dart';
import 'package:solera_vivero/modelos/lote_material.dart';
import 'package:solera_vivero/modelos/partida_planta.dart';
import 'package:solera_vivero/modelos/salida.dart';
import 'package:solera_vivero/modelos/siembra.dart';
import 'package:solera_vivero/modelos/vivero.dart';
import 'package:solera_vivero/pantallas/pantalla_bandejas.dart';
import 'package:solera_vivero/pantallas/pantalla_hoy.dart';
import 'package:solera_vivero/pantallas/pantalla_material.dart';
import 'package:solera_vivero/pantallas/pantalla_plantas.dart';
import 'package:solera_vivero/pantallas/pantalla_salidas.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraVivero.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Deja correr la BD real (ffi) y repinta varias veces.
  Future<void> esperar(WidgetTester tester, [int milisegundos = 300]) async {
    // Sin pumpAndSettle: mientras carga, el indicador de progreso no para.
    for (var vuelta = 0; vuelta < 8; vuelta++) {
      await Future<void>.delayed(Duration(milliseconds: milisegundos ~/ 4));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Lote, bandeja y partida sembrada. Devuelve el id de la partida.
  Future<int> sembrar() async {
    final lote = await baseDatos.guardarLoteMaterial(LoteMaterial(
        codigo: 'SEM-1',
        especieId: 'Tomate',
        nombreBotanico: 'Solanum lycopersicum',
        fechaEntradaMs: 1));
    final bandeja =
        await baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0001'));
    return baseDatos.sembrar(
        Siembra(loteMaterialId: lote, bandejaId: bandeja, fechaMs: 2),
        PartidaPlanta(
            codigo: 'P26-0001',
            especieId: 'Tomate',
            nombreBotanico: 'Solanum lycopersicum',
            cantidadInicial: 100,
            bandejaId: bandeja,
            fechaAltaMs: 3));
  }

  testWidgets('alta de un lote desde Material', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaMaterial()));
      await esperar(tester, 200);
      expect(find.text(SoleraL10n.t('vive.sin_lotes')), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester, 200);
      await tester.enterText(find.byType(TextField).at(0), 'SEM-77');
      await tester.enterText(find.byType(TextField).at(1), 'Castaño');
      await tester.enterText(find.byType(TextField).at(2), 'Castanea sativa');
      final boton = find.byType(FilledButton);
      await tester.scrollUntilVisible(boton, 300,
          scrollable: find
              .descendant(
                  of: find.byType(BottomSheet),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(boton);
      await esperar(tester);
    });
    expect(find.textContaining('SEM-77'), findsOneWidget);
    final lote = (await tester.runAsync(baseDatos.listarLotesMaterial))!.single;
    expect((
      lote.especieId,
      lote.nombreBotanico,
      lote.paisOrigen
    ), (
      'castano',
      'Castanea sativa',
      'ES'
    ), reason: 'el catálogo convierte el nombre en su id');
  });

  testWidgets('la ficha de zona ofrece marcar el punto y el área',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaZonas()));
      await esperar(tester, 200);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester, 200);
      final marcarArea = find.text(SoleraL10n.t('mapa.marcar_area'));
      await tester.scrollUntilVisible(marcarArea, 200,
          scrollable: find
              .descendant(
                  of: find.byType(BottomSheet),
                  matching: find.byType(Scrollable))
              .first);
    });
    expect(find.text(SoleraL10n.t('mapa.marcar_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  testWidgets('alta de una bandeja con el siguiente código', (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0004'));
      await tester.pumpWidget(const MaterialApp(home: PantallaBandejas()));
      await esperar(tester, 200);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester, 200);
      expect(find.text('VIV-B-0005'), findsOneWidget);
      final boton = find.byType(FilledButton);
      await tester.scrollUntilVisible(boton, 300,
          scrollable: find
              .descendant(
                  of: find.byType(BottomSheet),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(boton);
      await esperar(tester);
    });
    expect(find.text('VIV-B-0005'), findsOneWidget);
    expect(await tester.runAsync(baseDatos.listarBandejas), hasLength(2));
  });

  testWidgets('Hoy: primeros pasos sin datos', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('vive.primeros_pasos')), findsOneWidget);
  });

  testWidgets(
      'Hoy: avisa de la inspección sin notificar y de la salida sin '
      'pasaporte', (tester) async {
    await tester.runAsync(() async {
      final partida = await sembrar();
      await baseDatos.guardarInspeccion(InspeccionPlagas(
          fechaMs: 1,
          partidaId: partida,
          plagaId: 'Xylella fastidiosa',
          resultado: 'sospecha'));
      await baseDatos
          .guardarSalida(Salida(partidaId: partida, fechaMs: 5, cantidad: 10));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.textContaining('Xylella fastidiosa', skipOffstage: false),
        findsOneWidget);
    expect(
        find.text(SoleraL10n.tf('vive.salidas_sin_pasaporte', {'n': 1}),
            skipOffstage: false),
        findsOneWidget);
  });

  testWidgets('Plantas: stock y ficha con la trazabilidad hasta el lote',
      (tester) async {
    await tester.runAsync(() async {
      await sembrar();
      await tester.pumpWidget(const MaterialApp(home: PantallaPlantas()));
      await esperar(tester);
      expect(
          find.text(SoleraL10n.tf('vive.disponibles_n', {'n': 100}),
              findRichText: true),
          findsNothing);
      await tester.tap(find.textContaining('P26-0001'));
      await esperar(tester);
    });
    expect(find.text('100'), findsOneWidget);
    expect(find.text('SEM-1'), findsOneWidget);
    expect(find.text('VIV-B-0001'), findsOneWidget);
    expect(
        find.text(SoleraL10n.t('vive.trazabilidad_incompleta')), findsNothing);
  });

  testWidgets('Salida: registra el pasaporte como borrador sin autorización',
      (tester) async {
    late int salida;
    await tester.runAsync(() async {
      final partida = await sembrar();
      await baseDatos.guardarVivero(Vivero(codigoRopveg: 'ES-15200001'));
      salida = await baseDatos
          .guardarSalida(Salida(partidaId: partida, fechaMs: 5, cantidad: 10));
      await tester
          .pumpWidget(MaterialApp(home: PantallaFichaSalida(salidaId: salida)));
      await esperar(tester);
      expect(find.text('ES-15200001'), findsOneWidget);
      expect(find.text(SoleraL10n.t('vive.sin_autorizacion_borrador')),
          findsOneWidget);
      final preparar = find.text(SoleraL10n.t('vive.preparar_pasaporte'));
      await tester.scrollUntilVisible(preparar, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(preparar);
      await esperar(tester, 200);
      await tester.tap(find.byType(FilledButton).last);
      await esperar(tester);
    });
    final pasaporte = (await tester
            .runAsync(() => baseDatos.listarPasaportes(salidaId: salida)))!
        .single;
    expect((pasaporte.esBorrador, pasaporte.codigoOperador, pasaporte.cantidad),
        (true, 'ES-15200001', 10));
  });
}
