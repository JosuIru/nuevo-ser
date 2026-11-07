import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_huerta/datos/base_datos.dart';
import 'package:solera_huerta/dominio/resumen_economico.dart';
import 'package:solera_huerta/modelos/apunte_economico.dart';
import 'package:solera_huerta/modelos/configuracion_fiscal.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/titular.dart';
import 'package:solera_huerta/servicios/generador_extracto_economico_pdf.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('guardarraíles fiscales (PROVISIONAL)', () {
    test('el 12 % agrícola y el 4 % de hortalizas no cambian sin asesor', () {
      expect(compensacionReagpAgricolaPorcentaje, 12);
      expect(tipoIvaVentaHortalizasPorDefecto, 4);
    });

    test('REAGP: compensación solo si el comprador es empresario', () {
      final reagp = ConfiguracionFiscal(regimenIva: 'reagp');
      expect(reagp.impuestosVenta(compradorEmpresario: true),
          (0, compensacionReagpAgricolaPorcentaje));
      expect(reagp.impuestosVenta(compradorEmpresario: false), (0, 0.0),
          reason: 'a un socio de cestas no se le carga ni IVA ni compensación');
    });

    test('general: IVA y sin compensación; sin elegir: nada', () {
      expect(
          ConfiguracionFiscal(regimenIva: 'general')
              .impuestosVenta(compradorEmpresario: false),
          (tipoIvaVentaHortalizasPorDefecto, 0.0));
      expect(ConfiguracionFiscal().impuestosVenta(compradorEmpresario: true),
          (0, 0.0));
      expect(ConfiguracionFiscal().estaConfigurada, isFalse);
      expect(
          ConfiguracionFiscal.fromMap({'regimen_iva': 'inventado'}).regimenIva,
          'sin_elegir');
    });

    test('apunte: compensación, IVA y total en céntimos', () {
      final venta = ApunteEconomico(
          esIngreso: true,
          fechaMs: 0,
          concepto: 'Verdura al restaurante',
          categoria: 'venta_restaurantes',
          baseCentimos: 100000,
          compensacionReagpPorcentaje: 12,
          compradorEmpresario: true);
      expect(venta.compensacionReagpCentimos, 12000);
      expect(venta.cuotaIvaCentimos, 0);
      expect(venta.totalCentimos, 112000);
      final gasto = ApunteEconomico(
          esIngreso: false,
          fechaMs: 0,
          concepto: 'Compost',
          categoria: 'abonos_enmiendas',
          baseCentimos: 1001,
          tipoIvaPorcentaje: 10,
          parcelaId: 2);
      expect(gasto.cuotaIvaCentimos, 100);
      final vuelta = ApunteEconomico.fromMap(venta.toMap());
      expect(vuelta.compradorEmpresario, isTrue);
      expect(ApunteEconomico.fromMap(gasto.toMap()).parcelaId, 2);
    });

    test('las ventas son las categorías venta_*', () {
      expect(categoriasIngreso.where(esCategoriaVenta), hasLength(4));
      expect(categoriasGasto.any(esCategoriaVenta), isFalse);
    });
  });

  test('resumen: resultado, ventas por canal y margen por parcela', () {
    final resumen = ResumenEconomico.calcular([
      ApunteEconomico(
          esIngreso: true,
          fechaMs: 0,
          concepto: 'Cestas',
          categoria: 'venta_cestas',
          baseCentimos: 5000,
          parcelaId: 1),
      ApunteEconomico(
          esIngreso: true,
          fechaMs: 0,
          concepto: 'Cestas 2',
          categoria: 'venta_cestas',
          baseCentimos: 3000),
      ApunteEconomico(
          esIngreso: false,
          fechaMs: 0,
          concepto: 'Semilla',
          categoria: 'semillas_plantel',
          baseCentimos: 2000,
          parcelaId: 1,
          tipoIvaPorcentaje: 10),
    ]);
    expect(resumen.resultado, 6000);
    expect(resumen.basePorCategoria['venta_cestas'], 8000);
    expect(resumen.margenParcela(1), 3000);
    expect(resumen.ivaSoportado, 200);
  });

  group('BD', () {
    final entorno = EntornoBaseDatosTemporal();
    final baseDatos = BaseDatosSoleraHuerta.instancia;
    setUp(entorno.preparar);
    tearDown(() async {
      await baseDatos.cerrar();
      await entorno.limpiar();
    });

    test('configuración fiscal en una fila y apuntes por fecha', () async {
      await baseDatos.guardarConfiguracionFiscal(
          ConfiguracionFiscal(regimenIva: 'general'));
      await baseDatos
          .guardarConfiguracionFiscal(ConfiguracionFiscal(regimenIva: 'reagp'));
      expect((await baseDatos.obtenerConfiguracionFiscal()).esReagp, isTrue);
      final parcela = await baseDatos.guardarParcela(Parcela(nombre: 'P'));
      for (final fecha in [10, 20]) {
        await baseDatos.guardarApunteEconomico(ApunteEconomico(
            esIngreso: true,
            fechaMs: fecha,
            concepto: 'x',
            categoria: 'venta_cestas',
            baseCentimos: 1,
            parcelaId: parcela));
      }
      expect(await baseDatos.listarApuntesEconomicos(desdeMs: 15, hastaMs: 30),
          hasLength(1));
      await baseDatos.borrarParcela(parcela);
      final apuntes =
          await baseDatos.listarApuntesEconomicos(desdeMs: 0, hastaMs: 99);
      expect(apuntes.every((apunte) => apunte.parcelaId == null), isTrue);
    });
  });

  test('el extracto se genera como PDF', () async {
    final bytes = await generarExtractoEconomicoPdf(
      anyo: 2026,
      titular: Titular(nombre: 'Ane'),
      configuracion: ConfiguracionFiscal(regimenIva: 'reagp'),
      apuntes: [
        ApunteEconomico(
            esIngreso: true,
            fechaMs: 0,
            concepto: 'Cestas',
            categoria: 'venta_cestas',
            baseCentimos: 5000),
      ],
    );
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
  });
}
