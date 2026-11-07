import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_frutal/datos/base_datos.dart';
import 'package:solera_frutal/modelos/contrato_polinizacion.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/fila_arboles.dart';
import 'package:solera_frutal/modelos/parcela.dart';
import 'package:solera_frutal/modelos/tratamiento.dart';
import 'package:solera_frutal/pantallas/pantalla_cosecha.dart';
import 'package:solera_frutal/pantallas/pantalla_cuaderno.dart';
import 'package:solera_frutal/pantallas/pantalla_ficha_parcela.dart';
import 'package:solera_frutal/pantallas/pantalla_hoy.dart';
import 'package:solera_frutal/pantallas/pantalla_parcelas.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraFrutal.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Deja correr la BD real (ffi) y repinta varias veces: la primera
  /// apertura tarda más cuando los tests van en paralelo.
  Future<void> esperar(WidgetTester tester, [int milisegundos = 300]) async {
    for (var vuelta = 0; vuelta < 4; vuelta++) {
      await Future<void>.delayed(Duration(milliseconds: milisegundos ~/ 2));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('alta de una parcela desde la lista', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaParcelas()));
      await esperar(tester, 200);
      expect(find.text(SoleraL10n.t('frut.sin_parcelas')), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'La Loma');
      await tester.enterText(find.byType(TextField).at(2), '2,5');
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: find
              .descendant(
                  of: find.byType(PantallaEditarParcela),
                  matching: find.byType(Scrollable))
              .first);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await esperar(tester);
      await esperar(tester, 200);
    });
    expect(find.text('La Loma'), findsOneWidget);
    final parcela = (await tester.runAsync(baseDatos.listarParcelas))!.single;
    expect((parcela.especieId, parcela.superficieHa), ('almendro', 2.5));
  });

  testWidgets('Hoy: primeros pasos sin parcelas', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('frut.primeros_pasos')), findsOneWidget);
  });

  testWidgets('Hoy: plazo de seguridad abierto y colmenas puestas',
      (tester) async {
    await tester.runAsync(() async {
      final ahora = DateTime.now();
      final parcela = await baseDatos
          .guardarParcela(Parcela(nombre: 'Avellanar', especieId: 'avellano'));
      await baseDatos.guardarTratamiento(Tratamiento(
          parcelaId: parcela,
          fechaMs: ahora.millisecondsSinceEpoch,
          sustanciaActivaId: 'Azufre',
          plazoSeguridadDias: 10));
      await baseDatos.guardarContratoPolinizacion(ContratoPolinizacion(
          parcelaId: parcela,
          campania: ahora.year,
          apicultorNombre: 'Miren',
          numeroColmenas: 6,
          fechaEntradaMs:
              ahora.subtract(const Duration(days: 1)).millisecondsSinceEpoch));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Avellanar · Azufre'), findsOneWidget);
    expect(find.textContaining('Miren'), findsOneWidget);
  });

  testWidgets('la ficha de parcela enseña filas y contratos', (tester) async {
    late int parcela;
    await tester.runAsync(() async {
      parcela = await baseDatos.guardarParcela(Parcela(
          nombre: 'Almendral',
          especieId: 'almendro',
          superficieHa: 2,
          marcoPlantacion: '7x6'));
      await baseDatos.guardarFilaArboles(FilaArboles(
          parcelaId: parcela,
          etiqueta: 'Filas 1-3',
          variedadId: 'marcona',
          numeroArboles: 60));
      await baseDatos.guardarContratoPolinizacion(ContratoPolinizacion(
          parcelaId: parcela,
          campania: 2027,
          apicultorNombre: 'Iñaki',
          numeroColmenas: 8));
      await tester.pumpWidget(
          MaterialApp(home: PantallaFichaParcela(parcelaId: parcela)));
      await esperar(tester);
    });
    expect(find.text('Filas 1-3 · Marcona'), findsOneWidget);
    // Marcona sola: necesita polinizadora (orientación del catálogo).
    expect(find.text(SoleraL10n.t('frut.poli_sin_polinizadora')),
        findsOneWidget);
    expect(find.text('2027 · Iñaki'), findsOneWidget);
    expect(find.textContaining('4,0 colmenas/ha'), findsOneWidget);
  });

  testWidgets('cuaderno y cosecha listan lo apuntado', (tester) async {
    await tester.runAsync(() async {
      final anyo = DateTime.now().year;
      final parcela = await baseDatos.guardarParcela(
          Parcela(nombre: 'Nogueral', especieId: 'nogal', superficieHa: 1));
      await baseDatos.guardarTratamiento(Tratamiento(
          parcelaId: parcela,
          fechaMs: DateTime(anyo, 5, 10).millisecondsSinceEpoch,
          sustanciaActivaId: 'Cobre',
          problemaFitosanitario: 'Bacteriosis'));
      await baseDatos.guardarCosecha(Cosecha(
          parcelaId: parcela,
          campania: anyo,
          fechaMs: DateTime(anyo, 10, 1).millisecondsSinceEpoch,
          kgCascara: 1500,
          rendimientoGranoPorcentaje: 50));
      await tester.pumpWidget(const MaterialApp(home: PantallaCuaderno()));
      await esperar(tester);
    });
    expect(find.text('Cobre'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaCosecha()));
      await esperar(tester);
    });
    expect(find.text('Nogueral'), findsOneWidget);
    expect(find.textContaining('750 kg'), findsOneWidget);
  });
}
