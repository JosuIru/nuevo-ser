import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_aromaticas/dominio/trazabilidad.dart';
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/secado.dart';
import 'package:solera_aromaticas/modelos/titular.dart';
import 'package:solera_aromaticas/modelos/tratamiento.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';
import 'package:solera_aromaticas/servicios/generador_cuaderno_recoleccion_pdf.dart';
import 'package:solera_aromaticas/servicios/generador_libro_destilacion_pdf.dart';
import 'package:solera_aromaticas/servicios/generador_pasaporte_lote_pdf.dart';

int ms(int mes, int dia) => DateTime(2026, mes, dia).millisecondsSinceEpoch;

void main() {
  setUpAll(initializeDateFormatting);
  final titular =
      Titular(nombre: 'Explotación de prueba', nif: 'X1', municipio: 'Ansó');
  final parcelas = [
    Parcela(
        id: 4,
        nombre: 'Bancal',
        especieId: 'lavandin',
        superficieHa: 1.5,
        codigoSigpac: '22:28:0:0:1:2:1'),
  ];
  final zonas = [
    ZonaRecoleccion(
      id: 9,
      nombre: 'Monte comunal',
      comunidadAutonoma: 'Aragón',
      numeroPermiso: 'AUT-1',
      inicioVigenciaMs: ms(5, 1),
      finVigenciaMs: ms(9, 30),
      especiesPermitidas: ['tomillo_comun'],
      limiteKg: 100,
    ),
  ];
  final cosechas = [
    Cosecha(
        id: 1,
        zonaRecoleccionId: 9,
        especieId: 'tomillo_comun',
        fechaMs: ms(6, 10),
        kgFrescos: 60,
        estadoFenologico: 'plena_floracion',
        recolector: 'Ane'),
    // Fuera de la vigencia y especie no incluida: el cuaderno lo avisa.
    Cosecha(
        id: 2,
        zonaRecoleccionId: 9,
        especieId: 'romero',
        fechaMs: ms(10, 5),
        kgFrescos: 20),
    Cosecha(
        id: 3,
        parcelaId: 4,
        especieId: 'lavandin',
        fechaMs: ms(7, 20),
        kgFrescos: 300),
  ];

  test('cuaderno: zonas con kg de la vigencia, avisos y parcelas numeradas',
      () {
    final [zonasT, recoleccionesT, parcelasT, cultivoT, tratamientosT] =
        tablasCuadernoRecoleccion(DatosCuadernoRecoleccion(
      anyo: 2026,
      titular: titular,
      parcelas: parcelas,
      zonas: zonas,
      cosechas: cosechas,
      tratamientos: [
        Tratamiento(
            parcelaId: 4,
            fechaMs: ms(4, 1),
            sustanciaActivaId: 'Azufre',
            nombreProducto: 'Producto X',
            numeroRegistroProducto: 'ES-1')
      ],
    ));
    final zona = zonasT.filas.single;
    expect(zonasT.headers, hasLength(zona.length));
    expect(zona[3], 'AUT-1');
    expect(zona.last, '60', reason: 'los 20 kg de octubre quedan fuera');
    expect(recoleccionesT.filas, hasLength(2));
    expect(recoleccionesT.filas.first[3], contains('Thymus vulgaris'));
    expect(recoleccionesT.filas.first.last, '—');
    expect(recoleccionesT.filas.last.last, isNot('—'),
        reason: 'fuera de vigencia y especie no incluida');
    expect(parcelasT.filas.single.take(2), ['1', '22:28:0:0:1:2:1']);
    expect(cultivoT.filas.single[1], '1 · Bancal');
    expect(tratamientosT.filas.single[4], 'Producto X / ES-1');
    expect(tratamientosT.headers, hasLength(tratamientosT.filas.single.length));
  });

  test('cuaderno sin parcelas: no sale la sección de tratamientos', () {
    final tablas = tablasCuadernoRecoleccion(DatosCuadernoRecoleccion(
        anyo: 2026, titular: titular, zonas: zonas, cosechas: cosechas));
    expect(tablas.last.filas, isEmpty);
    expect(tablas.last.mensajeSiVacia, isNull);
  });

  final lotes = [
    LoteProducto(
        id: 1,
        codigo: 'AE-2026-001',
        tipo: 'aceite_esencial',
        especieId: 'tomillo_comun',
        fechaMs: ms(6, 12),
        cantidad: 150),
    LoteProducto(
        id: 2,
        codigo: 'PS-2026-001',
        tipo: 'planta_seca',
        especieId: 'lavandin',
        fechaMs: ms(7, 30),
        cantidad: 120),
  ];
  final datosLibro = DatosLibroDestilacion(
    anyo: 2026,
    titular: titular,
    destilaciones: [
      Destilacion(
          fechaMs: ms(6, 12),
          especieId: 'tomillo_comun',
          cosechasUsadasIds: [1],
          kgPlanta: 60,
          mlAceiteEsencial: 150,
          litrosHidrolato: 20,
          loteAceiteId: 1),
    ],
    secados: [
      Secado(
          fechaInicioMs: ms(7, 21),
          especieId: 'lavandin',
          cosechasUsadasIds: [3],
          kgFrescos: 300,
          kgSecos: 120,
          loteProductoId: 2),
    ],
    lotes: lotes,
    cosechas: cosechas,
    parcelas: parcelas,
    zonas: zonas,
  );

  test('libro: rendimientos con orientativo y origen de cada lote', () {
    final [destilacionesT, resumenT, secadosT, lotesT] =
        tablasLibroDestilacion(datosLibro);
    final destilacion = destilacionesT.filas.single;
    expect(destilacionesT.headers, hasLength(destilacion.length));
    expect(destilacion[7], '2,50', reason: '150 ml / 60 kg');
    expect(destilacion[8], '1-4', reason: 'tomillo, CTFC tabla 5');
    expect(destilacion.last, 'AE-2026-001');
    expect(resumenT.filas.single[5], '2,50');
    expect(secadosT.filas.single[6], '40', reason: '120 / 300');
    expect(secadosT.filas.single.last, 'PS-2026-001');
    expect(lotesT.filas.first.last, 'Monte comunal (AUT-1)');
    expect(lotesT.filas.last.last, 'Bancal');
  });

  test('pasaporte: solo trazabilidad, con el permiso de la zona', () {
    final origen = origenDeLote(lotes.first,
        secados: datosLibro.secados,
        destilaciones: datosLibro.destilaciones,
        cosechas: cosechas,
        parcelas: parcelas,
        zonas: zonas);
    final filas =
        filasPasaporteLote(lote: lotes.first, titular: titular, origen: origen);
    final texto = filas.map((fila) => '${fila.$1}: ${fila.$2}').join('\n');
    expect(texto, contains('AE-2026-001'));
    expect(texto, contains('Thymus vulgaris'));
    expect(texto, contains('Monte comunal (AUT-1)'));
    expect(texto, contains('Ansó'));
  });

  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('los tres documentos se generan como PDF', () async {
    expect(
        esPdf(await generarCuadernoRecoleccionPdf(DatosCuadernoRecoleccion(
            anyo: 2026,
            titular: titular,
            parcelas: parcelas,
            zonas: zonas,
            cosechas: cosechas))),
        isTrue);
    expect(esPdf(await generarLibroDestilacionPdf(datosLibro)), isTrue);
    expect(
        esPdf(await generarPasaporteLotePdf(
            lote: lotes.first,
            titular: titular,
            origen: origenDeLote(lotes.first,
                secados: const [],
                destilaciones: datosLibro.destilaciones,
                cosechas: cosechas,
                parcelas: parcelas,
                zonas: zonas))),
        isTrue);
  });
}
