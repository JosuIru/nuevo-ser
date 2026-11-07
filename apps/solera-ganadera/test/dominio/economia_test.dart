import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_ganadera/dominio/resumen_economico.dart';
import 'package:solera_ganadera/modelos/apunte_economico.dart';
import 'package:solera_ganadera/modelos/titular.dart';
import 'package:solera_ganadera/servicios/exportacion_datos.dart';
import 'package:solera_ganadera/servicios/generador_extracto_economico_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final apuntes = [
    ApunteEconomico(
        esIngreso: true,
        fechaMs: 1,
        concepto: 'Corderos a la cooperativa',
        categoria: 'venta_animales',
        baseCentimos: 200000,
        regimen: regimenReagp,
        porcentaje: 10.5),
    ApunteEconomico(
        esIngreso: true,
        fechaMs: 2,
        concepto: 'Carne en canal a un restaurante',
        categoria: 'venta_carne',
        baseCentimos: 50000,
        porcentaje: 10),
    ApunteEconomico(
        esIngreso: false,
        fechaMs: 3,
        concepto: 'Pienso',
        categoria: 'piensos_forraje',
        baseCentimos: 80000,
        porcentaje: 10),
  ];

  test('resumen: la compensación REAGP no es IVA repercutido', () {
    final resumen = ResumenEconomico.calcular(apuntes);
    expect(resumen.ingresosBase, 250000);
    expect(resumen.gastosBase, 80000);
    expect(resumen.resultado, 170000);
    expect(resumen.compensacionReagp, 21000);
    expect(resumen.ivaRepercutido, 5000);
    expect(resumen.ivaSoportado, 8000);
    expect(resumen.basePorCategoria['venta_animales'], 200000);
  });

  test(
      'guardarraíl fiscal: la compensación por defecto es editable y está '
      'marcada como por verificar', () {
    expect(compensacionReagpGanaderaPorDefecto, 10.5);
    expect(selloExtractoEconomico, 'PROVISIONAL');
    expect(filaExtracto(apuntes.first)[5], contains('REAGP'));
    expect(filaExtracto(apuntes[1])[5], contains('10 %'));
  });

  test('el extracto se genera como PDF', () async {
    final bytes = await generarExtractoEconomicoPdf(
        periodo: 'noviembre de 2026',
        titular: Titular(nombre: 'Ane'),
        apuntes: apuntes);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
  });

  test('exportación: una tabla en CSV con todas sus columnas y comillas', () {
    final csv = tablaACsv([
      {'id': 1, 'nombre': 'Larre, alto', 'superficie_ha': null},
      {'id': 2, 'nombre': 'Soto', 'notas': 'con "comillas"'},
    ]);
    final lineas = csv.trim().split('\n');
    expect(lineas.first, 'id,nombre,superficie_ha,notas');
    expect(lineas[1], '1,"Larre, alto",,');
    expect(lineas[2], contains('"con ""comillas"""'));
    expect(tablaACsv(const []), '\n');
  });
}
