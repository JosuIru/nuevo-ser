import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_sidra/dominio/resumen_economico.dart';
import 'package:solera_sidra/modelos/apunte_economico.dart';
import 'package:solera_sidra/modelos/titular.dart';
import 'package:solera_sidra/servicios/generador_extracto_economico_pdf.dart';

ApunteEconomico _apunte(String categoria, int base,
        {bool ingreso = true, int iva = 0, bool compensacion = false}) =>
    ApunteEconomico(
        esIngreso: ingreso,
        fechaMs: DateTime(2026, 11, 3).millisecondsSinceEpoch,
        concepto: categoria,
        categoria: categoria,
        baseCentimos: base,
        tipoIvaPorcentaje: iva,
        conCompensacionReagp: compensacion);

void main() {
  setUpAll(initializeDateFormatting);

  test('tipos de IVA propuestos: fruta 4, txotx 10, sidra 21', () {
    expect(tipoIvaPropuesto('venta_manzana'), 4);
    expect(tipoIvaPropuesto('compra_manzana'), 4);
    expect(tipoIvaPropuesto('venta_txotx'), 10);
    expect(tipoIvaPropuesto('fitosanitarios'), 10);
    expect(tipoIvaPropuesto('venta_sidra_botella'), 21);
    expect(tipoIvaPropuesto('venta_txakoli'), 21);
  });

  test('la compensación del REAGP solo se propone en la venta de manzana', () {
    expect(compensacionPropuesta('venta_manzana', 'reagp'), isTrue);
    expect(compensacionPropuesta('venta_manzana', 'general'), isFalse);
    // Elaborar y vender sidra es transformación: fuera del régimen.
    expect(compensacionPropuesta('venta_sidra_botella', 'reagp'), isFalse);
    expect(compensacionPropuesta('venta_txotx', 'reagp'), isFalse);
  });

  test('resumen: separa actividad agraria y transformación', () {
    final resumen = ResumenEconomico.calcular([
      _apunte('venta_manzana', 100000, compensacion: true),
      _apunte('venta_sidra_botella', 50000, iva: 21),
      _apunte('venta_txotx', 20000, iva: 10),
      _apunte('compra_manzana', 30000, ingreso: false, compensacion: true),
      _apunte('envases', 10000, ingreso: false, iva: 21),
    ]);
    expect(resumen.ingresosBase, 170000);
    expect(resumen.gastosBase, 40000);
    expect(resumen.resultado, 130000);
    expect(resumen.ingresosActividadAgraria, 100000);
    expect(resumen.ingresosTransformacion, 70000);
    expect(resumen.ivaRepercutido, 10500 + 2000);
    expect(resumen.ivaSoportado, 2100);
    expect(resumen.compensacionesCobradas, 12000);
    expect(resumen.compensacionesPagadas, 3600);
    expect(resumen.basePorCategoria['envases'], 10000);
  });

  test('el extracto lista los apuntes y sale en PDF con el sello', () async {
    final apuntes = [
      _apunte('venta_manzana', 100000, compensacion: true),
      _apunte('envases', 10000, ingreso: false, iva: 21),
    ];
    final tablas = tablasExtractoEconomico(apuntes);
    expect(tablas.first.filas, hasLength(2));
    expect(tablas.first.filas.first[4], '—'); // con compensación, sin IVA
    final bytes = await generarExtractoEconomicoPdf(
        mes: DateTime(2026, 11),
        titular: Titular(nombre: 'Zelaia', regimenFiscal: 'reagp'),
        apuntes: apuntes);
    expect(bytes.length, greaterThan(1000));
    expect(selloExtractoEconomico, 'PROVISIONAL');
  });
}
