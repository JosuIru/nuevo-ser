import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/dominio/resumen_economico.dart';
import 'package:solera_obrador/modelos/apunte_economico.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/modelos/titular.dart';
import 'package:solera_obrador/servicios/generador_extracto_economico_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final apuntes = [
    ApunteEconomico(
        esIngreso: true,
        fechaMs: 0,
        concepto: 'Mostrador',
        categoria: 'venta_mostrador',
        baseCentimos: 10000,
        tipoIvaPorcentaje: 4),
    ApunteEconomico(
        esIngreso: false,
        fechaMs: 0,
        concepto: 'Harina',
        categoria: 'materia_prima',
        baseCentimos: 3000,
        tipoIvaPorcentaje: 4),
    ApunteEconomico(
        esIngreso: false,
        fechaMs: 0,
        concepto: 'Luz',
        categoria: 'energia',
        baseCentimos: 1000,
        tipoIvaPorcentaje: 21),
  ];

  test('cuota, total y resumen del periodo', () {
    expect(apuntes.last.cuotaIvaCentimos, 210);
    expect(apuntes.last.totalCentimos, 1210);
    final resumen = ResumenEconomico.calcular(apuntes);
    expect(resumen.ingresosBase, 10000);
    expect(resumen.gastosBase, 4000);
    expect(resumen.resultado, 6000);
    expect(resumen.ivaRepercutido, 400);
    expect(resumen.ivaSoportado, 120 + 210);
    expect(resumen.basePorCategoria['energia'], 1000);
    final vuelta = ApunteEconomico.fromMap(apuntes.first.toMap());
    expect(vuelta.esIngreso, isTrue);
    expect(vuelta.tipoIvaPorcentaje, 4);
  });

  test('margen por pieza solo si hay precio', () {
    final composicion = ComposicionReceta.calcular(
      recetaId: 1,
      recetas: {1: Receta(id: 1, nombre: 'Pan', piezasPorMasa: 2)},
      lineasPorReceta: {
        1: [LineaReceta(recetaId: 1, ingredienteId: 1, gramos: 1000)]
      },
      ingredientes: {
        1: Ingrediente(id: 1, nombre: 'Harina', precioCentimosPorKg: 100)
      },
    );
    expect(margenPorPieza(Receta(id: 1, nombre: 'Pan'), composicion), isNull);
    final margen = margenPorPieza(
        Receta(id: 1, nombre: 'Pan', precioVentaCentimosPieza: 200),
        composicion)!;
    expect(margen.margenCentimos, 150); // 2,00 € − 0,50 € de harina
    expect(margen.porcentaje, 75);
  });

  test('el extracto se genera como PDF', () async {
    final bytes = await generarExtractoEconomicoPdf(
        periodo: 'noviembre 2026',
        titular: Titular(nombre: 'Obrador'),
        apuntes: apuntes);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
