import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_frutal/modelos/abonado.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/helada.dart';
import 'package:solera_frutal/modelos/parcela.dart';
import 'package:solera_frutal/modelos/riego.dart';
import 'package:solera_frutal/modelos/titular.dart';
import 'package:solera_frutal/modelos/tratamiento.dart';
import 'package:solera_frutal/servicios/generador_cuaderno_explotacion_pdf.dart';
import 'package:solera_frutal/servicios/generador_parte_cosecha_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final parcelas = [
    Parcela(
        id: 7,
        nombre: 'La Loma',
        especieId: 'almendro',
        superficieHa: 2,
        codigoSigpac: '50:1:0:0:3:12:1'),
    Parcela(
        id: 3,
        nombre: 'Vega',
        especieId: 'avellano',
        superficieHa: 1,
        regadio: true,
        sistemaRiego: 'goteo'),
  ];
  final titular = Titular(nombre: 'Explotación de prueba', nif: 'X1');
  final datos = DatosCuadernoExplotacion(
    anyo: 2026,
    titular: titular,
    parcelas: parcelas,
    tratamientos: [
      Tratamiento(
          parcelaId: 3,
          fechaMs: DateTime(2026, 5, 2).millisecondsSinceEpoch,
          sustanciaActivaId: 'azufre',
          problemaFitosanitario: 'eriofido',
          nombreProducto: 'Producto X',
          numeroRegistroProducto: 'ES-00001',
          aplicadorNombre: 'Ana',
          carnetAplicador: 'C-1',
          eficacia: 'buena'),
      Tratamiento(
          parcelaId: 7,
          fechaMs: DateTime(2026, 3, 1).millisecondsSinceEpoch,
          sustanciaActivaId: 'cobre'),
    ],
    abonados: [
      Abonado(
          parcelaId: 7,
          fechaMs: DateTime(2026, 2, 1).millisecondsSinceEpoch,
          tipoAbono: 'Estiércol')
    ],
    cosechas: [
      Cosecha(
          parcelaId: 7,
          campania: 2026,
          fechaMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
          kgCascara: 2000,
          rendimientoGranoPorcentaje: 25,
          destino: 'Cooperativa'),
    ],
    nombreSustancia: (id) => id == 'azufre' ? 'Azufre' : id,
  );

  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('cuaderno: tablas en el orden del modelo andaluz v8', () {
    final tablas = tablasCuadernoExplotacion(datos);
    expect(tablas, hasLength(7));
    final [
      personas,
      equipos,
      parcelasT,
      tratamientosT,
      abonosT,
      riegosT,
      cosechaT
    ] = tablas;
    expect(personas.filas.single, ['1', 'Ana', 'C-1']);
    expect(equipos.filas, isEmpty);
    expect(equipos.mensajeSiVacia, isNull, reason: 'sin equipos no sale');
    expect(parcelasT.filas.first.take(3), ['1', '50:1:0:0:3:12:1', 'La Loma']);
    expect(parcelasT.filas.first.last, 'SEC');
    expect(parcelasT.filas.last.last, 'LOC');
    final tratamientos = tratamientosT.filas;
    expect(tratamientos.first[1], '1 · La Loma (Almendro)',
        reason: 'el de marzo va primero');
    expect(tratamientos.last[4], 'Azufre');
    expect(tratamientos.last[5], 'Producto X / ES-00001');
    expect(tratamientos.last[7], 'Ana / C-1');
    expect(tratamientosT.headers, hasLength(tratamientos.last.length));
    expect(abonosT.headers, hasLength(abonosT.filas.single.length));
    expect(riegosT.filas, isEmpty);
    expect(riegosT.mensajeSiVacia, isNull,
        reason: 'sin riegos no sale la sección');
    expect(cosechaT.filas.single[1], 'Almendro');
    expect(cosechaT.filas.single[4], 'Cooperativa');
  });

  test('códigos del modelo andaluz y nitrógeno aportado', () {
    expect(codigoRiegoModelo(parcelas[0]), 'SEC');
    expect(
        codigoRiegoModelo(Parcela(
            nombre: 'a',
            especieId: 'nogal',
            regadio: true,
            sistemaRiego: 'aspersion')),
        'ASP');
    expect(codigoAbonadoModelo('fertirrigacion'), 'F');
    expect(codigoAbonadoModelo('fondo'), 'AF');
    expect(codigoAbonadoModelo('cobertera'), 'AC');
    expect(nitrogenoKgPorHa('15-15-15', 200), 30);
    expect(nitrogenoKgPorHa('8,5-4-12', 100), closeTo(8.5, 1e-9));
    expect(nitrogenoKgPorHa('estiércol', 100), isNull);
    expect(nitrogenoKgPorHa('15-15-15', 0), isNull);
  });

  test('riego: m³/ha y acumulado por parcela', () {
    final tablas = tablasCuadernoExplotacion(DatosCuadernoExplotacion(
      anyo: 2026,
      titular: titular,
      parcelas: parcelas,
      riegos: [
        Riego(parcelaId: 3, fechaMs: 2, volumenM3: 30),
        Riego(parcelaId: 3, fechaMs: 1, volumenM3: 20),
      ],
    ));
    final riegos = tablas[5].filas;
    expect(riegos.first[3], '20,0');
    expect(riegos.last[5], '50,0', reason: 'acumulado (1 ha)');
  });

  test('parte de cosecha: totales por parcela y heladas', () {
    final tablas = tablasParteCosecha(
      parcelas: parcelas,
      cosechas: datos.cosechas,
      heladas: [Helada(fechaMs: 0, temperaturaMinimaC: -2)],
    );
    final fila = tablas.first.filas.single;
    expect(fila.first, 'La Loma');
    expect(tablas.first.headers, hasLength(fila.length));
    expect(fila[5], '1.000', reason: 'kg/ha');
    expect(tablas.last.filas.single[2], isNotEmpty);
  });

  test('los dos documentos se generan como PDF', () async {
    expect(esPdf(await generarCuadernoExplotacionPdf(datos)), isTrue);
    expect(
        esPdf(await generarParteCosechaPdf(
            campania: 2026,
            titular: titular,
            parcelas: parcelas,
            cosechas: datos.cosechas)),
        isTrue);
  });
}
