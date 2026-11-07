import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_ganadera/datos/base_datos.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/tarea_sanitaria.dart';
import 'package:solera_ganadera/pantallas/pantalla_ficha_lote.dart';
import 'package:solera_ganadera/pantallas/pantalla_hoy.dart';
import 'package:solera_ganadera/pantallas/pantalla_manejo.dart';
import 'package:solera_ganadera/pantallas/pantalla_pastos.dart';
import 'package:solera_ganadera/pantallas/pantalla_rebanos.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraGanadera.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  Future<void> esperar(WidgetTester tester) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('alta de un rebaño desde la lista', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaRebanos()));
      await esperar(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Latxas de arriba');
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: find
              .descendant(
                  of: find.byType(BottomSheet),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(find.byType(FilledButton));
      await esperar(tester);
      await esperar(tester);
    });
    expect(find.text('Latxas de arriba'), findsOneWidget);
    final lotes = (await tester.runAsync(baseDatos.listarLotes))!;
    expect(lotes.single.especie, 'ovino');
  });

  testWidgets('pastos: la pieza con su rebaño y su carga', (tester) async {
    await tester.runAsync(() async {
      final pieza = await baseDatos
          .guardarPieza(PiezaPasto(nombre: 'Larre altua', superficieHa: 10));
      final lote = await baseDatos.guardarLote(LoteGanado(
          nombre: 'Latxas', especie: 'ovino', cabezasSinIdentificar: 50));
      await baseDatos.guardarMovimiento(MovimientoGanado(
          loteId: lote,
          fechaMs: 1,
          tipo: tipoMovimientoEntrada,
          piezaDestinoId: pieza));
      await tester.pumpWidget(const MaterialApp(home: PantallaPastos()));
      await esperar(tester);
    });
    expect(find.text('Larre altua'), findsOneWidget);
    expect(find.textContaining('Latxas (50)'), findsOneWidget);
    expect(find.textContaining('0,50 UGM/ha'), findsOneWidget);
  });

  testWidgets('Hoy: dónde está cada rebaño y las tareas que tocan',
      (tester) async {
    await tester.runAsync(() async {
      final pieza = await baseDatos.guardarPieza(PiezaPasto(nombre: 'Soto'));
      final lote = await baseDatos
          .guardarLote(LoteGanado(nombre: 'Vacas', especie: 'vacuno'));
      await baseDatos.guardarMovimiento(MovimientoGanado(
          loteId: lote,
          fechaMs: 1,
          tipo: tipoMovimientoEntrada,
          piezaDestinoId: pieza));
      await baseDatos.guardarTareaSanitaria(TareaSanitaria(
          titulo: 'Saneamiento de tuberculosis',
          fechaPrevistaMs: DateTime.now()
              .add(const Duration(days: 3))
              .millisecondsSinceEpoch));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Vacas'), findsOneWidget);
    expect(find.textContaining('Soto'), findsOneWidget);
    expect(find.text('Saneamiento de tuberculosis'), findsOneWidget);
  });

  testWidgets('ficha del rebaño: ubicación, animales y movimientos',
      (tester) async {
    late int lote;
    await tester.runAsync(() async {
      final soto = await baseDatos.guardarPieza(PiezaPasto(nombre: 'Soto'));
      final larre = await baseDatos.guardarPieza(PiezaPasto(nombre: 'Larre'));
      lote = await baseDatos
          .guardarLote(LoteGanado(nombre: 'Cabras', especie: 'caprino'));
      await baseDatos.guardarAnimal(Animal(
          identificacion: 'ES031101234567', nombre: 'Beltza', loteId: lote));
      await baseDatos.guardarMovimiento(MovimientoGanado(
          loteId: lote,
          fechaMs: 1,
          tipo: tipoMovimientoEntrada,
          piezaDestinoId: soto));
      await baseDatos.guardarMovimiento(MovimientoGanado(
          loteId: lote,
          fechaMs: 2,
          piezaOrigenId: soto,
          piezaDestinoId: larre));
      await tester
          .pumpWidget(MaterialApp(home: PantallaFichaLote(loteId: lote)));
      await esperar(tester);
    });
    expect(find.text('Larre'), findsOneWidget);
    expect(find.text('ES031101234567 · Beltza'), findsOneWidget);
    expect(find.text('Soto → Larre'), findsOneWidget);
  });

  testWidgets('manejo: alta de una visita veterinaria', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaManejo()));
      await esperar(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester);
      await tester.tap(find.byIcon(Icons.badge_outlined).last);
      await esperar(tester);
      await tester.enterText(
          find.byType(TextField).first, 'Miren, veterinaria');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: find
              .descendant(
                  of: find.byType(BottomSheet),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(find.byType(FilledButton));
      await esperar(tester);
      await esperar(tester);
    });
    expect(find.text('Miren, veterinaria'), findsOneWidget);
    final visitas = (await tester.runAsync(baseDatos.listarVisitas))!;
    expect(visitas.single.esVeterinaria, isTrue);
  });
}
