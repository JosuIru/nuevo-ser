import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_frutal/modelos/abonado.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/helada.dart';
import 'package:solera_frutal/modelos/parcela.dart';
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

  test('cuaderno: parcelas con número de orden y tratamientos por fecha', () {
    final tablas = tablasCuadernoExplotacion(datos);
    expect(tablas, hasLength(5));
    expect(tablas[0].filas.first.take(3), ['1', '50:1:0:0:3:12:1', 'La Loma']);
    final tratamientos = tablas[1].filas;
    expect(tratamientos.first[1], '1 · La Loma',
        reason: 'el de marzo va primero');
    expect(tratamientos.last[4], 'Azufre');
    expect(tratamientos.last[5], 'Producto X / ES-00001');
    expect(tratamientos.last[7], 'Ana / C-1');
    expect(tablas[1].headers, hasLength(tratamientos.last.length));
    expect(tablas[3].filas, isEmpty);
    expect(tablas[3].mensajeSiVacia, isNull,
        reason: 'sin riegos no sale la sección');
    expect(tablas[4].filas.single[3], 'Cooperativa');
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
