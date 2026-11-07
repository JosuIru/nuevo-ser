// Guardarraíles fiscales (PROVISIONAL hasta el asesor fiscal).
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_vivero/datos/base_datos.dart';
import 'package:solera_vivero/dominio/resumen_economico.dart';
import 'package:solera_vivero/modelos/apunte_economico.dart';
import 'package:solera_vivero/modelos/configuracion_fiscal.dart';
import 'package:solera_vivero/modelos/vivero.dart';
import 'package:solera_vivero/servicios/generador_extracto_economico_pdf.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('porcentajes leídos en la Ley 37/1992 (12 % REAGP, 10 % planta)', () {
    expect(compensacionReagpAgricolaPorcentaje, 12);
    expect(tipoIvaVentaPlantaPorDefecto, 10);
    expect(ConfiguracionFiscal(regimenIva: 'reagp').impuestosVentaPlanta(),
        (0, 12.0));
    expect(ConfiguracionFiscal(regimenIva: 'general').impuestosVentaPlanta(),
        (10, 0.0));
    expect(ConfiguracionFiscal().impuestosVentaPlanta(), (0, 0.0),
        reason: 'sin régimen elegido no se inventa ningún impuesto');
    expect(ConfiguracionFiscal.fromMap({'regimen_iva': 'raro'}).regimenIva,
        'sin_elegir');
  });

  test('apunte: IVA o compensación, nunca los dos; redondeo en céntimos', () {
    final gasto = ApunteEconomico(
        esIngreso: false,
        fechaMs: 0,
        concepto: 'Sustrato',
        categoria: 'sustratos_macetas',
        baseCentimos: 1999,
        tipoIvaPorcentaje: 21);
    expect((gasto.cuotaIvaCentimos, gasto.totalCentimos), (420, 2419));
    final venta = ApunteEconomico.fromMap(ApunteEconomico(
            esIngreso: true,
            fechaMs: 0,
            concepto: 'Esquejes',
            categoria: 'otras_ventas',
            baseCentimos: 10000,
            compensacionReagpPorcentaje: 12)
        .toMap());
    expect(
        (venta.cuotaIvaCentimos, venta.compensacionReagpCentimos), (0, 1200));
  });

  test('resumen: ventas de planta con el régimen actual más el libro', () {
    final ventas = [
      const VentaPlanta(
          fechaMs: 1, especieId: 'tomate', cantidad: 100, baseCentimos: 3000),
      const VentaPlanta(
          fechaMs: 2, especieId: 'tomate', cantidad: 50, baseCentimos: 1500),
      const VentaPlanta(
          fechaMs: 3, especieId: 'castano', cantidad: 10, baseCentimos: 5000),
    ];
    final apuntes = [
      ApunteEconomico(
          esIngreso: false,
          fechaMs: 1,
          concepto: 'Semilla',
          categoria: 'semillas_material',
          baseCentimos: 2000,
          tipoIvaPorcentaje: 10),
      ApunteEconomico(
          esIngreso: true,
          fechaMs: 1,
          concepto: 'Ayuda',
          categoria: 'subvenciones',
          baseCentimos: 1000),
    ];
    final general = ResumenEconomico.calcular(
        apuntes: apuntes,
        ventas: ventas,
        configuracion: ConfiguracionFiscal(regimenIva: 'general'));
    expect(general.ventasBase, 9500);
    expect(general.ingresosBase, 10500);
    expect(general.resultado, 8500);
    expect(general.ivaRepercutido, 950);
    expect(general.ivaSoportado, 200);
    expect(general.compensacionesReagp, 0);
    expect(general.ventasPorEspecie, {'tomate': 4500, 'castano': 5000});
    expect(general.gastosPorCategoria, {'semillas_material': 2000});
    final reagp = ResumenEconomico.calcular(
        apuntes: apuntes,
        ventas: ventas,
        configuracion: ConfiguracionFiscal(regimenIva: 'reagp'));
    expect((reagp.ivaRepercutido, reagp.compensacionesReagp), (0, 1140));
  });

  group('BD y PDF', () {
    final entorno = EntornoBaseDatosTemporal();
    final baseDatos = BaseDatosSoleraVivero.instancia;
    setUp(entorno.preparar);
    tearDown(() async {
      await baseDatos.cerrar();
      await entorno.limpiar();
    });

    test('configuración de una fila y apuntes por fechas', () async {
      await baseDatos
          .guardarConfiguracionFiscal(ConfiguracionFiscal(regimenIva: 'reagp'));
      await baseDatos.guardarConfiguracionFiscal(
          ConfiguracionFiscal(regimenIva: 'general'));
      expect(
          (await baseDatos.obtenerConfiguracionFiscal()).regimenIva, 'general');
      for (final fecha in [5, 15]) {
        await baseDatos.guardarApunteEconomico(ApunteEconomico(
            esIngreso: false,
            fechaMs: fecha,
            concepto: 'x',
            categoria: 'otros_gastos',
            baseCentimos: 1));
      }
      expect(
          await baseDatos.listarApuntesEconomicos(desdeMs: 10), hasLength(1));
    });

    test('extracto con sello', () async {
      expect(selloExtractoEconomico, 'PROVISIONAL');
      final bytes = await generarExtractoEconomicoPdf(
          anyo: 2026,
          vivero: Vivero(nombre: 'Vivero'),
          configuracion: ConfiguracionFiscal(regimenIva: 'reagp'),
          apuntes: const [],
          ventas: const [
            VentaPlanta(
                fechaMs: 0, especieId: 'tomate', cantidad: 1, baseCentimos: 100)
          ]);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(
          filasVentas(const [
            VentaPlanta(
                fechaMs: 0,
                especieId: 'tomate',
                cantidad: 3,
                baseCentimos: 100,
                cliente: 'Ana')
          ]).single.sublist(1, 4),
          ['tomate', '3', 'Ana']);
    });
  });
}
