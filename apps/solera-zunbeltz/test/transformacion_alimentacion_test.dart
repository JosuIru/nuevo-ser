// Calculadora de transformación y alimentación por días.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/calculo_transformacion.dart';
import 'package:solera_zunbeltz/modelos/registro_actividad.dart';
import 'package:solera_zunbeltz/servicios/alimentacion_por_dias.dart';

void main() {
  group('calculadora de transformación', () {
    test('de peso vivo a producto, ingreso, costes y margen', () {
      final calculo = CalculoTransformacion(
        pesoVivoKg: 100,
        animales: 2,
        rendimientoCanalPorcentaje: 50,
        rendimientoProductoPorcentaje: 80,
        precioKgCentimos: 1500,
        costeSacrificioCentimos: 3000,
        costeTransformacionKgCentimos: 200,
        otrosCostesCentimos: 1000,
      );
      expect(calculo.kgCanal, 100, reason: '2 animales × 100 kg × 50 %');
      expect(calculo.kgProducto, 80);
      expect(calculo.ingresoCentimos, 120000, reason: '80 kg × 15 €');
      expect(calculo.costesCentimos, 6000 + 16000 + 1000,
          reason: 'sacrificio por animal + transformación por kg de producto + otros');
      expect(calculo.margenCentimos, 120000 - 23000);
      expect(calculo.margenPorKgVivoCentimos, ((120000 - 23000) / 200).round());
    });

    test('venta en canal: producto vendible al 100 %', () {
      final calculo = CalculoTransformacion(
        pesoVivoKg: 30, rendimientoCanalPorcentaje: 48, precioKgCentimos: 1000);
      expect(calculo.kgProducto, closeTo(14.4, 0.0001));
      expect(calculo.ingresoCentimos, 14400);
      expect(calculo.margenCentimos, 14400);
    });

    test('sin datos no revienta', () {
      final calculo = CalculoTransformacion();
      expect(calculo.kgProducto, 0);
      expect(calculo.margenPorKgVivoCentimos, 0);
    });
  });

  group('alimentación por días', () {
    final dia5 = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch;
    final dia6 = DateTime(2026, 10, 6, 9).millisecondsSinceEpoch;
    final registros = [
      RegistroActividad(fincaId: 1, tipo: 'alimentacion', cantidad: 120, fechaMs: dia6, lote: 'Rebaño A'),
      RegistroActividad(fincaId: 1, tipo: 'alimentacion', cantidad: 30.5, fechaMs: dia6 + 3600000, lote: 'Rebaño A'),
      RegistroActividad(fincaId: 1, tipo: 'alimentacion', cantidad: 80, fechaMs: dia5, lote: 'Rebaño B'),
      RegistroActividad(fincaId: 1, tipo: 'paricion', cantidad: 3, fechaMs: dia6),
    ];

    test('una fila por día y lote, sumando los kg', () {
      final filas = alimentacionPorDias(registros);
      expect(filas.length, 2);
      expect(filas.first.dia, DateTime(2026, 10, 5));
      expect(filas.first.lote, 'Rebaño B');
      expect(filas.last.kg, 150.5);
    });

    test('CSV para Excel con total, como el del WordPress', () {
      final csv = alimentacionACsv(alimentacionPorDias(registros));
      expect(csv.startsWith('﻿Fecha;Lote;Kg'), isTrue);
      expect(csv, contains('06/10/2026;Rebaño A;150,5'));
      expect(csv, contains('Total;;230,5'));
    });
  });
}
