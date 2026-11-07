import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_huerta/estado/datos_huerta.dart';
import 'package:solera_huerta/estado/semana_cestas.dart';
import 'package:solera_huerta/modelos/bancal.dart';
import 'package:solera_huerta/modelos/cosecha.dart';
import 'package:solera_huerta/modelos/cultivo.dart';
import 'package:solera_huerta/modelos/insumo.dart';
import 'package:solera_huerta/modelos/lote_semilla.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/siembra.dart';
import 'package:solera_huerta/modelos/titular.dart';
import 'package:solera_huerta/modelos/tratamiento.dart';
import 'package:solera_huerta/provisional_core/venta_directa/cesta.dart';
import 'package:solera_huerta/provisional_core/venta_directa/entrega.dart';
import 'package:solera_huerta/provisional_core/venta_directa/socio.dart';
import 'package:solera_huerta/provisional_core/venta_directa/suscripcion.dart';
import 'package:solera_huerta/servicios/generador_cuaderno_ecologico_pdf.dart';
import 'package:solera_huerta/servicios/generador_hoja_cestas_pdf.dart';

int ms(DateTime fecha) => fecha.millisecondsSinceEpoch;

void main() {
  setUpAll(initializeDateFormatting);

  final datos = DatosHuerta(
    parcelas: [
      Parcela(
          id: 4,
          nombre: 'Vega',
          codigoSigpac: '31:1:0:0:2:5:1',
          superficieHa: 0.6,
          estadoEcologico: 'conversion',
          fechaInicioConversionMs: ms(DateTime(2025, 3, 1))),
    ],
    bancales: [
      Bancal(id: 1, parcelaId: 4, nombre: 'B1'),
      Bancal(id: 2, parcelaId: 4, nombre: 'B2'),
    ],
    cultivos: [
      Cultivo(id: 10, especieId: 'Tomate', familiaId: 'solanaceas'),
      Cultivo(id: 11, especieId: 'Lechuga', familiaId: 'asteraceas'),
    ],
    lotes: [
      LoteSemilla(
          id: 30,
          codigo: 'TOM-1',
          especieId: 'Tomate',
          origen: 'no_ecologica_autorizada'),
      LoteSemilla(id: 31, codigo: 'SIN-USO', especieId: 'Lechuga'),
    ],
    insumos: [
      Insumo(
          id: 20,
          nombre: 'Compost',
          tipo: 'enmienda',
          permitidoEcologico: true,
          justificantePermitido: 'certificado'),
      Insumo(
          id: 21,
          nombre: 'Azufre mojable',
          tipo: 'fitosanitario',
          numeroRegistro: 'ES-1'),
    ],
    siembras: [
      Siembra(
          id: 100,
          bancalId: 1,
          cultivoId: 10,
          fechaPrevistaMs: ms(DateTime(2025, 4, 1)),
          fechaRealMs: ms(DateTime(2025, 4, 1))),
      Siembra(
          id: 101,
          bancalId: 1,
          cultivoId: 10,
          fechaPrevistaMs: ms(DateTime(2026, 4, 10)),
          fechaRealMs: ms(DateTime(2026, 4, 10)),
          loteSemillaId: 30,
          cantidad: 40),
      Siembra(
          id: 102,
          bancalId: 2,
          cultivoId: 11,
          fechaPrevistaMs: ms(DateTime(2026, 9, 1))),
    ],
  );
  final titular = Titular(
      nombre: 'Ane', nombreHuerta: 'Huerta Ane', organismoControl: 'CPAEN');
  final entrada = DatosCuadernoEcologico(
    anyo: 2026,
    titular: titular,
    datos: datos,
    cosechas: [
      Cosecha(
          bancalId: 1,
          cultivoId: 10,
          fechaMs: ms(DateTime(2026, 7, 2)),
          kg: 12),
      Cosecha(
          bancalId: 1, cultivoId: 10, fechaMs: ms(DateTime(2026, 7, 9)), kg: 8),
    ],
    aplicaciones: [
      Tratamiento(
          parcelaId: 4,
          bancalId: 1,
          insumoId: 21,
          fechaMs: ms(DateTime(2026, 6, 1)),
          aplicadorNombre: 'Ane',
          carnetAplicador: 'C-1',
          plazoSeguridadDias: 5),
      Tratamiento(
          parcelaId: 4, insumoId: 20, fechaMs: ms(DateTime(2026, 3, 1))),
    ],
  );

  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('cuaderno: tablas, orden y contenidos', () {
    final tablas = tablasCuadernoEcologico(entrada);
    expect(tablas, hasLength(8));
    final [
      parcelas,
      rotacion,
      siembras,
      semillas,
      insumos,
      fitos,
      cosechas,
      totales
    ] = tablas;
    expect(parcelas.filas.single.take(3), ['1', '31:1:0:0:2:5:1', 'Vega']);
    expect(parcelas.filas.single[5], '01/03/2025');
    expect(rotacion.headers.skip(1), ['2023', '2024', '2025', '2026']);
    expect(rotacion.filas.first.first, '1 · Vega · B1');
    expect(rotacion.filas.first.last, 'solanaceas');
    expect(rotacion.filas.last.last, '—',
        reason: 'la siembra solo planificada no cuenta');
    expect(siembras.filas, hasLength(1), reason: 'solo las hechas en 2026');
    expect(
        siembras.filas.single.last, isNot(SoleraL10n.t('huer.pdf_sin_aviso')),
        reason: 'tomate tras tomate al año siguiente');
    expect(semillas.filas.single.first, 'TOM-1');
    expect(semillas.filas.single.last, SoleraL10n.t('huer.falta_autorizacion'));
    expect(insumos.filas.first[2], 'Compost', reason: 'por fecha');
    expect(insumos.filas.first[1], '1 · Vega', reason: 'toda la parcela');
    expect(insumos.filas.last[5], SoleraL10n.t('huer.pdf_no_marcado'));
    expect(fitos.filas.single[6], 'Ane / C-1');
    expect(fitos.headers, hasLength(fitos.filas.single.length));
    expect(cosechas.filas, hasLength(2));
    expect(totales.filas.single.take(3), ['Tomate', '2', '20,00']);
  });

  test('sin fitosanitarios su tabla no sale', () {
    final sinFitos = tablasCuadernoEcologico(
        DatosCuadernoEcologico(anyo: 2026, titular: titular, datos: datos));
    expect(sinFitos[5].filas, isEmpty);
    expect(sinFitos[5].mensajeSiVacia, isNull);
  });

  SemanaCestas semana() {
    final lunes = DateTime(2026, 7, 6);
    return SemanaCestas(
      lunes: lunes,
      datos: datos,
      socios: [
        Socio(id: 1, nombre: 'Jon', puntoEntrega: 'Local del grupo'),
        Socio(id: 2, nombre: 'Miren'),
        Socio(id: 3, nombre: 'De baja', activo: false),
      ],
      suscripciones: [
        Suscripcion(id: 7, socioId: 1, fechaInicioMs: 0),
        Suscripcion(id: 8, socioId: 2, fechaInicioMs: 0, tamano: 'grande'),
        Suscripcion(id: 9, socioId: 3, fechaInicioMs: 0),
      ],
      cestas: [Cesta(id: 50, suscripcionId: 7, semanaLunesMs: ms(lunes))],
      lineas: [
        LineaCesta(id: 1, cestaId: 50, cultivoId: 10, kg: 1.5),
        LineaCesta(id: 2, cestaId: 50, cultivoId: 11, unidades: 2),
      ],
      entregas: [Entrega(cestaId: 50, fechaMs: ms(DateTime(2026, 7, 9)))],
      real: {10: (kg: 2.0, unidades: 0), 11: (kg: 0.0, unidades: 2)},
      prevista: const {},
    );
  }

  test('hoja de cestas: preparar por cultivo y cestas de socios activos', () {
    final [porCultivo, cestas] = tablasHojaCestas(semana());
    final tomate = porCultivo.filas.first;
    expect(tomate.first, 'Tomate');
    expect(tomate[3], '1');
    expect(tomate.last, isNot('—'), reason: 'sobra medio kilo');
    expect(porCultivo.filas.last.last, '—', reason: 'lechugas: no sobra nada');
    expect(cestas.filas, hasLength(2), reason: 'el socio de baja no sale');
    expect(cestas.filas.first[2], 'Local del grupo');
    expect(cestas.filas.last[3], SoleraL10n.t('huer.sin_componer'));
    expect(cestas.filas.last.last, '[ ]');
  });

  test('los dos documentos se generan como PDF', () async {
    expect(esPdf(await generarCuadernoEcologicoPdf(entrada)), isTrue);
    expect(
        esPdf(await generarHojaCestasPdf(semana: semana(), titular: titular)),
        isTrue);
  });
}
