import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aromaticas/datos/base_datos.dart';
import 'package:solera_aromaticas/dominio/resumen_economico.dart';
import 'package:solera_aromaticas/modelos/apunte_economico.dart';
import 'package:solera_aromaticas/modelos/configuracion_fiscal.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/titular.dart';
import 'package:solera_aromaticas/pantallas/pantalla_economia.dart';
import 'package:solera_aromaticas/servicios/generador_extracto_economico_pdf.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('guardarraíles fiscales (PROVISIONAL)', () {
    test('REAGP: la planta lleva compensación; lo destilado, nunca', () {
      final reagp = ConfiguracionFiscal(regimenIva: 'reagp');
      expect(reagp.impuestosVenta('venta_planta'),
          (0, compensacionReagpAgricolaPorcentaje));
      for (final categoria in categoriasVentaDestilado) {
        expect(reagp.impuestosVenta(categoria),
            (tipoIvaVentaDestiladoPorDefecto, 0.0));
        expect(reagp.avisoTransformacion(categoria), isTrue);
      }
      expect(reagp.avisoTransformacion('venta_planta'), isFalse);
      expect(reagp.impuestosVenta('subvenciones'), (0, 0.0));
    });

    test('general: IVA y sin compensación; sin elegir: nada', () {
      final general = ConfiguracionFiscal(regimenIva: 'general');
      expect(general.impuestosVenta('venta_planta'),
          (tipoIvaVentaPlantaPorDefecto, 0.0));
      expect(general.avisoTransformacion('venta_hidrolato'), isFalse);
      expect(ConfiguracionFiscal().impuestosVenta('venta_planta'), (0, 0.0));
      expect(ConfiguracionFiscal().estaConfigurada, isFalse);
      expect(
          ConfiguracionFiscal.fromMap({'regimen_iva': 'inventado'}).regimenIva,
          'sin_elegir');
    });

    test('apunte: compensación, IVA y total en céntimos', () {
      final venta = ApunteEconomico(
          esIngreso: true,
          fechaMs: 0,
          concepto: 'Tomillo seco',
          categoria: 'venta_planta',
          baseCentimos: 100000,
          compensacionReagpPorcentaje: 12);
      expect(venta.compensacionReagpCentimos, 12000);
      expect(venta.cuotaIvaCentimos, 0);
      expect(venta.totalCentimos, 112000);
      final gasto = ApunteEconomico(
          esIngreso: false,
          fechaMs: 0,
          concepto: 'Abono',
          categoria: 'abonos',
          baseCentimos: 1001,
          tipoIvaPorcentaje: 10,
          parcelaId: 2);
      expect(gasto.cuotaIvaCentimos, 100);
      final vuelta = ApunteEconomico.fromMap(venta.toMap());
      expect(vuelta.compensacionReagpPorcentaje, 12);
      expect(ApunteEconomico.fromMap(gasto.toMap()).parcelaId, 2);
    });

    test('resumen: resultado, compensaciones y margen por parcela', () {
      final resumen = ResumenEconomico.calcular([
        ApunteEconomico(
            esIngreso: true,
            fechaMs: 0,
            concepto: 'Venta',
            categoria: 'venta_planta',
            baseCentimos: 50000,
            compensacionReagpPorcentaje: 12,
            parcelaId: 1),
        ApunteEconomico(
            esIngreso: false,
            fechaMs: 0,
            concepto: 'Plantones',
            categoria: 'plantones',
            baseCentimos: 20000,
            tipoIvaPorcentaje: 21,
            parcelaId: 1),
        ApunteEconomico(
            esIngreso: false,
            fechaMs: 0,
            concepto: 'Leña del alambique',
            categoria: 'combustible_alambique',
            baseCentimos: 5000),
      ]);
      expect(resumen.resultado, 25000);
      expect(resumen.compensacionesReagp, 6000);
      expect(resumen.ivaSoportado, 4200);
      expect(resumen.margenParcela(1), 30000);
      expect(resumen.margenParcela(null), -5000);
    });

    test('extracto: filas y PDF', () async {
      final apunte = ApunteEconomico(
          esIngreso: true,
          fechaMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
          concepto: 'Venta',
          categoria: 'venta_planta',
          baseCentimos: 1000,
          compensacionReagpPorcentaje: 12,
          parcelaId: 1);
      final filas = filasApuntes(
          [apunte], {1: Parcela(id: 1, nombre: 'Loma', especieId: 'lavandin')});
      expect(filas.single[3], 'Loma');
      expect(filas.single[5], 'REAGP 12 %');
      final bytes = await generarExtractoEconomicoPdf(
          anyo: 2026,
          titular: Titular(nombre: 'Prueba'),
          configuracion: ConfiguracionFiscal(regimenIva: 'reagp'),
          apuntes: [apunte]);
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    });
  });

  group('pantalla y BD', () {
    final entorno = EntornoBaseDatosTemporal();
    final baseDatos = BaseDatosSoleraAromaticas.instancia;
    setUp(entorno.preparar);
    tearDown(() async {
      await baseDatos.cerrar();
      await entorno.limpiar();
    });

    test('configuración fiscal en una sola fila', () async {
      await baseDatos.guardarConfiguracionFiscal(
          ConfiguracionFiscal(regimenIva: 'general'));
      await baseDatos
          .guardarConfiguracionFiscal(ConfiguracionFiscal(regimenIva: 'reagp'));
      expect((await baseDatos.obtenerConfiguracionFiscal()).esReagp, isTrue);
      expect(
          await (await baseDatos.basedatos).query('configuraciones_fiscales'),
          hasLength(1));
    });

    testWidgets('la pantalla muestra el resultado del año', (tester) async {
      await tester.runAsync(() async {
        await baseDatos.guardarApunteEconomico(ApunteEconomico(
            esIngreso: true,
            fechaMs: DateTime.now().millisecondsSinceEpoch,
            concepto: 'Venta de lavanda seca',
            categoria: 'venta_planta',
            baseCentimos: 123400));
        await tester.pumpWidget(const MaterialApp(home: PantallaEconomia()));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
      });
      expect(find.text('Venta de lavanda seca'), findsOneWidget);
      expect(find.text(SoleraL10n.t('arom.aviso_fiscal')), findsOneWidget);
    });
  });
}
