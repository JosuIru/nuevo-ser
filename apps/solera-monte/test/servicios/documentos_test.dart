import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_monte/dominio/sorteo_lena.dart';
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/ejecucion.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/modelos/sorteo_lena.dart';
import 'package:solera_monte/servicios/generador_acta_sorteo_pdf.dart';
import 'package:solera_monte/servicios/generador_estado_plan_pdf.dart';
import 'package:solera_monte/servicios/generador_parte_aprovechamientos_pdf.dart';
import 'package:solera_monte/servicios/generador_revision_incendios_pdf.dart';

int ms(int mes, int dia) => DateTime(2026, mes, dia).millisecondsSinceEpoch;

void main() {
  setUpAll(initializeDateFormatting);
  final monte = Monte(
    nombre: 'Monte Común de Arbaio',
    titular: 'Junta vecinal de Arbaio',
    figura: 'comunal_junta_vecinal',
    comunidadAutonoma: 'Navarra',
    instrumentoGestion: 'proyecto_ordenacion',
    referenciaInstrumento: 'PO-12',
    inicioEpocaPeligroMes: 6,
    inicioEpocaPeligroDia: 1,
  );
  final rodales = [
    Rodal(
        id: 1,
        codigo: '1a',
        nombre: 'Pinar',
        especiePrincipalId: 'pinus_sylvestris',
        superficieDeclaradaHa: 10,
        anyoOrigen: 1970),
    Rodal(
        id: 2,
        codigo: '2b',
        especiePrincipalId: 'fagus_sylvatica',
        superficieDeclaradaHa: 6),
  ];
  final aprovechamientos = [
    Aprovechamiento(
        id: 1,
        campanya: 2026,
        rodalId: 2,
        tipo: 'lena',
        fechaInicioMs: ms(1, 10),
        fechaFinMs: ms(3, 15),
        cantidad: 40,
        unidad: 'estereos',
        modalidad: 'lotes_vecinales',
        tramite: 'declaracion_responsable',
        referenciaTramite: 'DR-7',
        comercializado: true),
    Aprovechamiento(
        id: 2,
        campanya: 2026,
        rodalId: 1,
        tipo: 'madera',
        fechaInicioMs: ms(9, 1),
        cantidad: 8,
        unidad: 'm3'),
  ];
  final sorteo = SorteoLena(
    id: 5,
    campanya: 2026,
    nombre: 'Suertes 2026',
    participantes: const ['Casa Juana', 'Casa Pello', 'Casa Miren'],
    semilla: '04211',
    huellaParticipantes:
        huellaLista(const ['Casa Juana', 'Casa Pello', 'Casa Miren']),
    fechaCierreListaMs: ms(10, 1),
    fechaSorteoMs: ms(10, 20),
    realizado: true,
  );
  final adjudicacion = sortear(
      semilla: '04211',
      participantes: sorteo.participantes,
      numerosLote: [1, 2]).adjudicacionPorLote;
  final lotes = [
    for (final numero in [1, 2])
      LoteLena(
          sorteoId: 5,
          numero: numero,
          rodalId: 2,
          cantidad: 20,
          adjudicatario: adjudicacion[numero]!),
  ];

  test('parte: aprovechamientos con trámite, avisos y totales', () {
    final [aprovechamientosT, avisosT, totalesT, lotesT] =
        tablasParteAprovechamientos(DatosParteAprovechamientos(
            campanya: 2026,
            monte: monte,
            rodales: rodales,
            aprovechamientos: aprovechamientos,
            sorteos: [sorteo],
            lotes: lotes,
            hoy: DateTime(2026, 4, 30)));
    final lena = aprovechamientosT.filas.first;
    expect(aprovechamientosT.headers, hasLength(lena.length));
    expect(lena[0], contains('2b (6,00 ha)'));
    expect(lena[0], contains('Haya (Fagus sylvatica)'));
    expect(lena[4], contains('DR-7'));
    final avisos = avisosT.filas.map((fila) => fila.join(' | ')).toList();
    expect(avisos.where((aviso) => aviso.contains('15/04/2026')), hasLength(1),
        reason: 'un mes desde el fin, art. 37.4, ya vencido el 30/04');
    expect(
        avisos.where((aviso) =>
            aviso.contains(SoleraL10n.t('mont.aviso_menor_cuantia'))),
        hasLength(1));
    expect(avisos.last, contains(SoleraL10n.t('mont.aviso_tramite_pendiente')),
        reason: 'la madera sin trámite');
    expect(totalesT.filas.first, [
      SoleraL10n.t('mont.aprov_lena'),
      '40 ${SoleraL10n.t('mont.unidad_estereos')}',
      '26',
    ]);
    expect(lotesT.filas.map((fila) => fila.last).toSet(),
        adjudicacion.values.toSet());
  });

  test('estado del plan: previsto frente a hecho y volumen', () {
    final tablas = tablasEstadoPlan(DatosEstadoPlan(
      anyoActual: 2026,
      monte: monte,
      rodales: rodales,
      actuaciones: [
        ActuacionPlan(
            id: 1,
            rodalId: 1,
            anyoPrevisto: 2026,
            tipo: 'clara',
            volumenPrevistoM3: 30,
            superficiePrevistaHa: 4),
        ActuacionPlan(id: 2, anyoPrevisto: 2025, tipo: 'desbroce'),
      ],
      ejecuciones: [
        Ejecucion(
            actuacionPlanId: 1,
            rodalId: 1,
            fechaMs: ms(9, 30),
            tipo: 'clara',
            superficieHa: 4,
            ejecutor: 'Vereda'),
        Ejecucion(fechaMs: ms(5, 2), tipo: 'poda'),
      ],
      aprovechamientos: aprovechamientos,
    ));
    final [inventario, porEspecie, resumen, actuaciones, noPrevistas, volumen] =
        tablas;
    expect(inventario.filas.first[3], '56', reason: 'edad 2026 − 1970');
    expect(porEspecie.filas.first.first, 'Pino albar o silvestre');
    expect(resumen.filas.map((fila) => fila.first), ['2025', '2026']);
    expect(resumen.filas.first[4], '1',
        reason: 'el desbroce de 2025, atrasado');
    expect(actuaciones.filas.first.last, contains('Vereda'));
    expect(noPrevistas.filas.single[2], SoleraL10n.t('mont.actuacion_poda'));
    // 2026: 30 m³ previstos; 8 m³ de madera + 40 estéreos × 0,65 = 34.
    expect(volumen.filas.single, ['2026', '30', '34', '4']);
  });

  test('revisión de incendios: estado de la campaña y revisiones del año', () {
    final [estadoT, revisionesT] =
        tablasRevisionIncendios(DatosRevisionIncendios(
      anyo: 2026,
      monte: monte,
      infraestructuras: [
        InfraestructuraIncendios(
            id: 1, tipo: 'punto_agua', nombre: 'Balsa', capacidadM3: 80),
        InfraestructuraIncendios(
            id: 2, tipo: 'pista', nombre: 'Pista del alto', longitudM: 1200),
        InfraestructuraIncendios(
            id: 3, tipo: 'cortafuegos', nombre: 'Viejo', activa: false),
      ],
      revisiones: [
        RevisionIncendios(
            infraestructuraId: 1,
            fechaMs: ms(5, 10),
            estado: 'necesita_mantenimiento',
            trabajosNecesarios: 'Limpiar el fondo'),
        RevisionIncendios(
            infraestructuraId: 2,
            fechaMs: DateTime(2025, 5).millisecondsSinceEpoch),
      ],
    ));
    expect(estadoT.filas, hasLength(2), reason: 'sin la inactiva');
    expect(estadoT.filas.first.last, 'Limpiar el fondo');
    expect(estadoT.filas.last[2], '1.200 m');
    expect(estadoT.filas.last[4], SoleraL10n.t('mont.sin_revisar'),
        reason: 'la revisión de 2025 no vale para 2026');
    expect(revisionesT.filas, hasLength(1));
  });

  test('acta del sorteo: lista, lotes y orden que cualquiera puede repetir',
      () {
    final [listaT, lotesT, ordenT] =
        tablasActaSorteo(sorteo: sorteo, lotes: lotes, rodales: rodales);
    expect(listaT.filas.map((fila) => fila.last), sorteo.participantes);
    expect(lotesT.filas.map((fila) => fila.last).toSet(),
        adjudicacion.values.toSet());
    expect(ordenT.filas, hasLength(3));
    expect(ordenT.filas.last.last, SoleraL10n.t('mont.lista_espera'));
    final clave = claveSorteo('04211', ordenT.filas.first[1]);
    expect(ordenT.filas.first[2].replaceAll(' ', ''), clave);
    expect(claveEnGrupos('a' * 64).split(' '), hasLength(4));
  });

  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('los cuatro documentos se generan como PDF', () async {
    expect(
        esPdf(await generarParteAprovechamientosPdf(DatosParteAprovechamientos(
            campanya: 2026,
            monte: monte,
            rodales: rodales,
            aprovechamientos: aprovechamientos))),
        isTrue);
    expect(
        esPdf(await generarEstadoPlanPdf(
            DatosEstadoPlan(anyoActual: 2026, monte: monte, rodales: rodales))),
        isTrue);
    expect(
        esPdf(await generarRevisionIncendiosPdf(
            DatosRevisionIncendios(anyo: 2026, monte: monte))),
        isTrue);
    expect(
        esPdf(await generarActaSorteoPdf(
            monte: monte, sorteo: sorteo, lotes: lotes, rodales: rodales)),
        isTrue);
  });
}
