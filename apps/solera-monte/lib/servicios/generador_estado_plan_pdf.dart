import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
import '../dominio/plan_gestion.dart';
import '../dominio/superficies.dart';
import '../modelos/actuacion_plan.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/ejecucion.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../utiles/textos_monte.dart';
import 'cabecera_monte.dart';

/// Sello hasta que el técnico forestal valide el formato. Lo vigila
/// test/sello_provisional_test.dart.
const String selloEstadoPlan = 'PROVISIONAL';

class DatosEstadoPlan {
  DatosEstadoPlan({
    required this.anyoActual,
    required this.monte,
    this.rodales = const [],
    this.actuaciones = const [],
    this.ejecuciones = const [],
    this.aprovechamientos = const [],
  });

  /// Año con el que se calculan las actuaciones atrasadas.
  final int anyoActual;
  final Monte monte;
  final List<Rodal> rodales;
  final List<ActuacionPlan> actuaciones;
  final List<Ejecucion> ejecuciones;
  final List<Aprovechamiento> aprovechamientos;
}

/// Tablas del estado del plan: inventario de rodales, superficie por
/// especie, previsto frente a ejecutado por año, cada actuación con su
/// estado, lo hecho fuera del plan y volumen previsto frente a aprovechado.
List<TablaInforme> tablasEstadoPlan(DatosEstadoPlan datos) {
  final rodalPorId = {for (final rodal in datos.rodales) rodal.id: rodal};
  String rodal(int? id) => id == null
      ? SoleraL10n.t('mont.todo_el_monte')
      : rodalPorId[id]?.etiqueta ?? '#$id';
  final resumen = resumenPlanPorAnyo(
      datos.actuaciones, datos.ejecuciones, datos.anyoActual);
  final anyosVolumen = {
    ...datos.actuaciones
        .where((a) => (a.volumenPrevistoM3 ?? 0) > 0)
        .map((a) => a.anyoPrevisto),
    ...datos.aprovechamientos
        .where((a) => a.esMaderableOLenoso)
        .map((a) => a.campanya),
  }.toList()
    ..sort();
  return [
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_inventario_rodales'),
      headers: [
        SoleraL10n.t('mont.rodal'),
        SoleraL10n.t('mont.especie_principal'),
        SoleraL10n.t('mont.estado_masa'),
        SoleraL10n.t('mont.pdf_edad'),
        SoleraL10n.t('mont.superficie_declarada'),
        SoleraL10n.t('mont.pdf_superficie_dibujada'),
      ],
      filas: [
        for (final rodal in datos.rodales)
          [
            rodal.etiqueta,
            nombreEspecie(rodal.especiePrincipalId),
            nombreEstadoMasa(rodal.estadoMasa),
            numeroOGuion(rodal.edadEn(datos.anyoActual)),
            numeroOGuion(rodal.superficieDeclaradaHa, decimales: 2),
            rodal.tieneContorno
                ? formatearNumero(rodal.superficieCalculadaHa, decimales: 2)
                : vacioPdf,
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.sin_rodales'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_superficie_especie'),
      headers: [SoleraL10n.t('mont.especie'), 'ha'],
      filas: [
        for (final (especie, superficie) in superficiePorEspecie(datos.rodales))
          [nombreEspecie(especie), formatearNumero(superficie, decimales: 2)],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_previsto_ejecutado'),
      headers: [
        SoleraL10n.t('mont.pdf_anyo'),
        SoleraL10n.t('mont.pdf_previstas'),
        SoleraL10n.t('mont.estado_ejecutada'),
        SoleraL10n.t('mont.estado_en_curso'),
        SoleraL10n.t('mont.estado_atrasada'),
        SoleraL10n.t('mont.estado_cancelada'),
        SoleraL10n.t('mont.pdf_ha_previstas'),
        SoleraL10n.t('mont.pdf_ha_ejecutadas'),
      ],
      filas: [
        for (final anyo in resumen)
          [
            '${anyo.anyo}',
            '${anyo.previstas}',
            '${anyo.ejecutadas}',
            '${anyo.enCurso}',
            '${anyo.atrasadas}',
            '${anyo.canceladas}',
            formatearNumero(anyo.superficiePrevistaHa, decimales: 2),
            formatearNumero(anyo.superficieEjecutadaHa, decimales: 2),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.sin_actuaciones'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_actuaciones'),
      headers: [
        SoleraL10n.t('mont.pdf_anyo'),
        SoleraL10n.t('mont.rodal'),
        SoleraL10n.t('mont.tipo_actuacion'),
        SoleraL10n.t('mont.superficie_ha'),
        SoleraL10n.t('mont.volumen_previsto_m3'),
        SoleraL10n.t('mont.pdf_estado'),
        SoleraL10n.t('mont.pdf_hecho'),
      ],
      filas: [
        for (final actuacion in datos.actuaciones)
          [
            '${actuacion.anyoPrevisto}',
            rodal(actuacion.rodalId),
            nombreTipoActuacion(actuacion.tipo),
            numeroOGuion(actuacion.superficiePrevistaHa, decimales: 2),
            numeroOGuion(actuacion.volumenPrevistoM3),
            textoEstadoActuacion(estadoActuacion(
                actuacion, datos.ejecuciones, datos.anyoActual)),
            [
              for (final ejecucion in datos.ejecuciones
                  .where((e) => e.actuacionPlanId == actuacion.id))
                '${formatearFecha(ejecucion.fechaMs)}'
                    '${ejecucion.superficieHa == null ? '' : ' ${formatearNumero(ejecucion.superficieHa!, decimales: 2)} ha'}'
                    '${ejecucion.ejecutor.isEmpty ? '' : ' (${ejecucion.ejecutor})'}'
            ].join('; ').ifEmpty(vacioPdf),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_no_previstas'),
      headers: [
        SoleraL10n.t('mont.fecha'),
        SoleraL10n.t('mont.rodal'),
        SoleraL10n.t('mont.tipo_actuacion'),
        SoleraL10n.t('mont.superficie_ha'),
        SoleraL10n.t('mont.ejecutor'),
      ],
      filas: [
        for (final ejecucion in ejecucionesNoPrevistas(datos.ejecuciones))
          [
            formatearFecha(ejecucion.fechaMs),
            rodal(ejecucion.rodalId),
            nombreTipoActuacion(ejecucion.tipo),
            numeroOGuion(ejecucion.superficieHa, decimales: 2),
            o(ejecucion.ejecutor),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_volumen'),
      headers: [
        SoleraL10n.t('mont.campanya'),
        SoleraL10n.t('mont.pdf_previsto_m3'),
        SoleraL10n.t('mont.pdf_aprovechado_m3'),
        SoleraL10n.t('mont.pdf_diferencia_m3'),
      ],
      filas: [
        for (final anyo in anyosVolumen)
          () {
            final comparacion = compararVolumen(anyo,
                actuaciones: datos.actuaciones,
                aprovechamientos: datos.aprovechamientos,
                m3PorEstereo: m3PorEstereo);
            return [
              '$anyo',
              formatearNumero(comparacion.previstoPlanM3),
              formatearNumero(comparacion.aprovechadoM3),
              formatearNumero(comparacion.diferenciaM3),
            ];
          }(),
      ],
    ),
  ];
}

extension on String {
  String ifEmpty(String alternativa) => isEmpty ? alternativa : this;
}

/// Estado del plan de gestión en PDF: previsto frente a ejecutado.
Future<Uint8List> generarEstadoPlanPdf(DatosEstadoPlan datos,
    {pw.ThemeData? tema}) {
  final monte = datos.monte;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('mont.estado_plan')} · ${datos.anyoActual}',
    subtituloCabecera: subtituloMonte(monte, selloEstadoPlan),
    bulletsResumen: [
      ...identificacionMonte(monte),
      SoleraL10n.tf('mont.superficie_total', {
        'ha': formatearNumero(superficieTotal(datos.rodales), decimales: 2)
      }),
      if (monte.estaCertificado)
        SoleraL10n.tf('mont.pdf_certificacion', {
          'sistema': nombreCertificacion(monte.certificacion),
          'codigo': o(monte.codigoCertificado),
        }),
      SoleraL10n.t('mont.pdf_aviso_plan'),
      SoleraL10n.t('mont.superficie_orientativa'),
      SoleraL10n.t('mont.aviso_documento_provisional'),
    ],
    tablas: tablasEstadoPlan(datos),
    operador: monte.titular.isEmpty ? null : monte.titular,
    tema: tema,
  );
}
