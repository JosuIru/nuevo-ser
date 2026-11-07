// Guardarraíles fiscales (PROVISIONAL hasta el asesor fiscal): la app solo
// propone impuestos a la venta de madera y leña de un particular, nunca a
// cesiones o arrendamientos (pastos, caza) ni a comunidades o entidades
// locales, cuyo régimen está por verificar.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_monte/dominio/resumen_economico.dart';
import 'package:solera_monte/modelos/apunte_economico.dart';
import 'package:solera_monte/modelos/configuracion_fiscal.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/servicios/generador_extracto_economico_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('REAGP: compensación del 12 % solo en madera y leña', () {
    expect(impuestosVenta('particular_reagp', 'venta_madera'), (0, 12.0));
    expect(impuestosVenta('particular_reagp', 'venta_lena'), (0, 12.0));
    for (final categoria in categoriasIngresoDudosas) {
      expect(impuestosVenta('particular_reagp', categoria), (0, 0.0),
          reason: categoria);
    }
    expect(impuestosVenta('particular_reagp', 'ayudas'), (0, 0.0));
  });

  test('régimen general: 21 % por verificar en madera y leña', () {
    expect(impuestosVenta('particular_general', 'venta_madera'), (21, 0.0));
    expect(impuestosVenta('particular_general', 'pastos'), (0, 0.0));
  });

  test('comunidades, entidades locales y sin régimen: nada, y con aviso', () {
    for (final regimen in ['comunidad_montes', 'entidad_local', 'sin_elegir']) {
      expect(impuestosVenta(regimen, 'venta_madera'), (0, 0.0),
          reason: regimen);
      expect(necesitaAvisoFiscal(regimen, 'venta_madera'), isTrue);
    }
    expect(necesitaAvisoFiscal('particular_reagp', 'venta_madera'), isFalse);
    expect(necesitaAvisoFiscal('particular_reagp', 'caza'), isTrue);
  });

  test('las categorías de las reglas existen', () {
    expect(categoriasIngreso, containsAll(categoriasVentaForestal));
    expect(categoriasIngreso, containsAll(categoriasIngresoDudosas));
    expect(regimenesFiscalesMonte.first, 'sin_elegir');
  });

  final apuntes = [
    ApunteEconomico(
        esIngreso: true,
        fechaMs: DateTime(2026, 3, 1).millisecondsSinceEpoch,
        concepto: 'Subasta de pino',
        categoria: 'venta_madera',
        baseCentimos: 500000,
        compensacionReagpPorcentaje: 12,
        rodalId: 1),
    ApunteEconomico(
        esIngreso: true,
        fechaMs: DateTime(2026, 4, 1).millisecondsSinceEpoch,
        concepto: 'Pastos',
        categoria: 'pastos',
        baseCentimos: 80000),
    ApunteEconomico(
        esIngreso: false,
        fechaMs: DateTime(2026, 5, 1).millisecondsSinceEpoch,
        concepto: 'Desbroce',
        categoria: 'trabajos_selvicolas',
        baseCentimos: 200000,
        tipoIvaPorcentaje: 21,
        rodalId: 1),
  ];

  test('resumen: resultado, REAGP, IVA, por categoría y margen por rodal', () {
    final resumen = ResumenEconomico.calcular(apuntes);
    expect(resumen.ingresosBase, 580000);
    expect(resumen.gastosBase, 200000);
    expect(resumen.resultado, 380000);
    expect(resumen.compensacionesReagp, 60000);
    expect(resumen.ivaSoportado, 42000);
    expect(resumen.ingresosPorCategoria['pastos'], 80000);
    expect(resumen.margenRodal(1), 300000);
    expect(resumen.margenRodal(null), 80000);
  });

  test('extracto: filas puras y PDF con sello', () async {
    final filas = filasApuntes(apuntes.take(1),
        {1: Rodal(id: 1, codigo: '1a', especiePrincipalId: 'pinus_pinea')});
    expect(filas.single[3], '1a');
    expect(filas.single[6], 'REAGP 12 %');
    final bytes = await generarExtractoEconomicoPdf(
        anyo: 2026,
        monte: Monte(nombre: 'Monte'),
        regimen: 'particular_reagp',
        apuntes: apuntes);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    expect(selloExtractoEconomico, 'PROVISIONAL');
  });
}
