import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_parametros_ecoregimen.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_tabla_ugm.dart';
import 'package:solera_ganadera/dominio/informe_ecoregimen.dart';
import 'package:solera_ganadera/estado/datos_ganado.dart';
import 'package:solera_ganadera/modelos/carga_ganadera.dart';
import 'package:solera_ganadera/modelos/explotacion.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/ganado_ecologico.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/titular.dart';
import 'package:solera_ganadera/modelos/visita.dart';
import 'package:solera_ganadera/servicios/generador_documento_movimiento_pdf.dart';
import 'package:solera_ganadera/servicios/generador_informe_ecoregimen_pdf.dart';
import 'package:solera_ganadera/servicios/generador_libro_registro_pdf.dart';

int dia(int anio, int mes, int diaDelMes) =>
    DateTime(anio, mes, diaDelMes, 10).millisecondsSinceEpoch;

void main() {
  setUpAll(initializeDateFormatting);
  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  final titular = Titular(nombre: 'Ane Etxeberria', nif: '12345678Z');
  final explotacion = Explotacion(
      codigoRega: 'ES310000000001',
      municipio: 'Ultzama',
      provincia: 'Navarra',
      especies: {'ovino'});
  final latxas = LoteGanado(
      id: 1,
      nombre: 'Latxas',
      especie: 'ovino',
      cabezasSinIdentificar: 98,
      ecologico: true);
  final piezas = [
    PiezaPasto(
        id: 10,
        nombre: 'Larre altua',
        superficieHa: 50,
        tipoPasto: pastoHumedo,
        recintoSigpac: '31:250:0:0:3:12:1'),
    PiezaPasto(id: 11, nombre: 'Soto', superficieHa: 5),
  ];
  final animales = [
    Animal(id: 1, identificacion: 'ES031101234567', loteId: 1),
    Animal(id: 2, identificacion: 'ES031101234568', loteId: 1),
  ];
  final movimientos = [
    MovimientoGanado(
        id: 1,
        loteId: 1,
        fechaMs: dia(2026, 1, 1),
        tipo: tipoMovimientoEntrada,
        piezaDestinoId: 11,
        cabezas: 100,
        explotacionExterna: 'ES310000000099',
        titularExterno: 'Mikel'),
    MovimientoGanado(
        id: 2,
        loteId: 1,
        fechaMs: dia(2026, 5, 1),
        piezaOrigenId: 11,
        piezaDestinoId: 10,
        cabezas: 100),
    MovimientoGanado(
        id: 3,
        loteId: 1,
        fechaMs: dia(2026, 9, 28),
        piezaOrigenId: 10,
        piezaDestinoId: 11,
        cabezas: 100),
    MovimientoGanado(
        id: 4,
        loteId: 1,
        fechaMs: dia(2026, 10, 15),
        tipo: tipoMovimientoBajaParcial,
        cabezas: 20,
        identificaciones: 'ES1, ES2',
        explotacionExterna: 'ES310000000555',
        codigoRemo: 'REMO-77'),
  ];
  final eventos = [
    EventoGanado(
        id: 1,
        loteId: 1,
        fechaMs: dia(2026, 3, 2),
        medicamento: 'Lo que pone la receta',
        sustanciaActiva: 'Ivermectina',
        claseMedicamento: claseAntiparasitario,
        plazoSupresionCarneDias: 14,
        receta: 'R-1'),
    EventoGanado(
        id: 2,
        animalId: 1,
        fechaMs: dia(2026, 4, 2),
        tipo: tipoEventoEnfermedad,
        descripcion: 'Ectima'),
  ];
  final datos = DatosGanado(
      piezas: piezas,
      lotes: [latxas],
      animales: animales,
      movimientos: movimientos,
      eventos: eventos,
      tareas: const []);

  test('libro: los apartados del anexo V con entradas y salidas separadas', () {
    final tablas = tablasLibroRegistro(
      titular: titular,
      explotacion: explotacion,
      datos: datos,
      visitas: [Visita(fechaMs: dia(2026, 6, 1), persona: 'Miren')],
      desde: DateTime(2026),
      hasta: DateTime(2027),
      ahora: DateTime(2026, 11, 7),
    );
    expect(tablas, hasLength(10));
    final porTitulo = {for (final tabla in tablas) tabla.titulo: tabla};
    expect(porTitulo['9. Entradas de animales']!.filas.single[2],
        'ES310000000099');
    final salida = porTitulo['10. Salidas de animales']!.filas.single;
    expect(salida, contains('REMO-77'));
    expect(salida.last, 'ES1, ES2');
    expect(porTitulo['Cambios de pieza (dentro de la explotación)']!.filas,
        hasLength(2));
    final tratamiento =
        porTitulo['Tratamientos con medicamentos (RD 666/2023, art. 41)']!
            .filas
            .single;
    expect(tratamiento[2], 'Lo que pone la receta');
    expect(tratamiento[6], '14 → 28 (eco)');
    expect(
        porTitulo['6. Enfermedades infecciosas o parasitarias']!.filas.single,
        contains('Ectima'));
    expect(porTitulo['11. Visitas y vehículos']!.filas, hasLength(1));
    expect(porTitulo['Censo actual por rebaño']!.filas.single[3], '100');
  });

  test('libro: el periodo deja fuera lo de otros años', () {
    final tablas = tablasLibroRegistro(
      titular: titular,
      explotacion: explotacion,
      datos: datos,
      visitas: const [],
      desde: DateTime(2025),
      hasta: DateTime(2026),
      ahora: DateTime(2026, 11, 7),
    );
    expect(tablas[3].filas, isEmpty);
    expect(tablas[6].filas, isEmpty);
  });

  test('documento de movimiento: en una salida la propia es el origen', () {
    final tablas = tablasDocumentoMovimiento(
        movimiento: movimientos.last,
        lote: latxas,
        animalesDelLote: animales,
        titular: titular,
        explotacion: explotacion);
    expect(tablas, hasLength(5));
    expect(tablas[0].filas.first.last, 'ES310000000001');
    expect(tablas[1].filas.first.last, 'ES310000000555');
    expect(tablas[2].filas.first.last, 'REMO-77');
    expect(tablas[3].filas.map((fila) => fila.last), ['ES1', 'ES2']);
    final entrada = tablasDocumentoMovimiento(
        movimiento: movimientos.first,
        lote: latxas,
        animalesDelLote: animales,
        titular: titular,
        explotacion: explotacion);
    expect(entrada[0].filas.first.last, 'ES310000000099');
    expect(entrada[3].filas, hasLength(2), reason: 'los crotales del rebaño');
  });

  test('eco-régimen: días y carga por pieza, con avisos', () {
    final informes = calcularInformeEcoregimen(
      piezas: piezas,
      lotes: [latxas],
      animales: animales,
      movimientos: movimientos,
      tabla: tablaDeTramite(catalogoCoeficientesUgm, tramitePac),
      parametros: catalogoParametrosEcoregimen,
      desde: DateTime(2026),
      hasta: DateTime(2026, 12, 31),
      ahora: DateTime(2026, 11, 7),
    );
    final larre = informes.firstWhere((informe) => informe.pieza.id == 10);
    // Del 1-may al 27-sep: 150 días con 100 cabezas × 0,1 = 10 UGM en 50 ha.
    expect(larre.diasConGanado, 150);
    expect(larre.cargaMedia, closeTo(0.2, 1e-9));
    expect(larre.pocosDias, isFalse);
    expect(larre.cargaPorDebajo, isTrue, reason: 'húmedo: mínimo 0,4');
    final soto = informes.firstWhere((informe) => informe.pieza.id == 11);
    expect(soto.diasConGanado, 365 - 150);
    expect(soto.cargaMaxima, closeTo(2.0, 1e-9));
    expect(soto.cargaPorEncima, isTrue, reason: 'mediterráneo: máximo 1,2');
    expect(avisosDeRecinto(soto), contains('1,20'));
  });

  test('eco-régimen: sin movimientos no hay días; sin superficie, sin carga',
      () {
    final informes = calcularInformeEcoregimen(
      piezas: [PiezaPasto(id: 1, nombre: 'Sin medir')],
      lotes: const [],
      animales: const [],
      movimientos: const [],
      tabla: const [],
      parametros: catalogoParametrosEcoregimen,
      desde: DateTime(2026),
      hasta: DateTime(2026, 3, 1),
      ahora: DateTime(2026, 3, 1),
    );
    expect(informes.single.diasConGanado, 0);
    expect(informes.single.cargaMedia, isNull);
    expect(informes.single.sinSuperficie, isTrue);
    expect(informes.single.pocosDias, isTrue);
  });

  test('los tres documentos se generan como PDF', () async {
    expect(
        esPdf(await generarLibroRegistroPdf(
            titular: titular,
            explotacion: explotacion,
            datos: datos,
            visitas: const [],
            desde: DateTime(2026),
            hasta: DateTime(2027))),
        isTrue);
    expect(
        esPdf(await generarDocumentoMovimientoPdf(
            movimiento: movimientos.last,
            lote: latxas,
            animalesDelLote: animales,
            titular: titular,
            explotacion: explotacion)),
        isTrue);
    expect(
        esPdf(await generarInformeEcoregimenPdf(
            campana: 2026,
            nombreTramite: 'PAC',
            informes: calcularInformeEcoregimen(
                piezas: piezas,
                lotes: [latxas],
                animales: animales,
                movimientos: movimientos,
                tabla: tablaDeTramite(catalogoCoeficientesUgm, tramitePac),
                parametros: catalogoParametrosEcoregimen,
                desde: DateTime(2026),
                hasta: DateTime(2026, 2, 1),
                ahora: DateTime(2026, 11, 7)),
            titular: titular,
            explotacion: explotacion)),
        isTrue);
  });
}
