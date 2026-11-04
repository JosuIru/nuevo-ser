import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../modelos/arbol.dart';

/// Nombre visible (traducido) del estado de un árbol.
String etiquetaEstadoArbol(EstadoArbol estado) {
  switch (estado) {
    case EstadoArbol.sano:
      return SoleraL10n.t('arb.estado_sano');
    case EstadoArbol.observacion:
      return SoleraL10n.t('arb.estado_observacion');
    case EstadoArbol.riesgo:
      return SoleraL10n.t('arb.estado_riesgo');
    case EstadoArbol.caido:
      return SoleraL10n.t('arb.estado_caido');
    case EstadoArbol.sustituido:
      return SoleraL10n.t('arb.estado_sustituido');
  }
}

/// «de enero», «urtarrileko», «de gener»… para componer fechas.
String deMesTraducido(int mes) => [
        SoleraL10n.t('arb.de_mes_1'),
        SoleraL10n.t('arb.de_mes_2'),
        SoleraL10n.t('arb.de_mes_3'),
        SoleraL10n.t('arb.de_mes_4'),
        SoleraL10n.t('arb.de_mes_5'),
        SoleraL10n.t('arb.de_mes_6'),
        SoleraL10n.t('arb.de_mes_7'),
        SoleraL10n.t('arb.de_mes_8'),
        SoleraL10n.t('arb.de_mes_9'),
        SoleraL10n.t('arb.de_mes_10'),
        SoleraL10n.t('arb.de_mes_11'),
        SoleraL10n.t('arb.de_mes_12'),
    ][(mes - 1).clamp(0, 11)];

/// «4/11/2026 a las 10:30» en el idioma de la app.
String fechaYHoraTraducida(DateTime momento) => SoleraL10n.tf('arb.fecha_a_las_hora', {
      'fecha': DateFormat('d/MM/yyyy').format(momento),
      'hora': DateFormat('HH:mm').format(momento),
    });

/// Validador de campo obligatorio: «Nombre obligatorio».
String? Function(String?) validadorObligatorio(String nombreCampo) =>
    (valor) => (valor ?? '').trim().isEmpty
        ? SoleraL10n.tf('arb.campo_obligatorio', {'campo': nombreCampo})
        : null;

/// Estado guardado en una inspección (`sano`, `observacion`, `riesgo`,
/// `caido`…) en el idioma de la app. Un valor desconocido sale tal cual.
String etiquetaEstadoInspeccion(String estado) {
  switch (estado) {
    case 'sano':
      return SoleraL10n.t('arb.estado_sano');
    case 'observacion':
      return SoleraL10n.t('arb.estado_observacion');
    case 'riesgo':
      return SoleraL10n.t('arb.estado_riesgo');
    case 'caido':
      return SoleraL10n.t('arb.estado_caido_eliminado');
    case 'sustituido':
      return SoleraL10n.t('arb.estado_sustituido');
    default:
      return estado;
  }
}

/// Tipos de incidencia tal como se guardan en BD, en su orden visible.
const tiposIncidencia = [
  'golpe_vehiculo',
  'vandalismo',
  'temporal',
  'alcorque_danado',
  'raices_acera',
  'riesgo_caida',
  'otro',
];

/// Nombre visible de un tipo de incidencia; si no es conocido, tal cual.
String etiquetaTipoIncidencia(String tipo) {
  switch (tipo) {
    case 'golpe_vehiculo':
      return SoleraL10n.t('arb.incidencia_golpe_vehiculo');
    case 'vandalismo':
      return SoleraL10n.t('arb.incidencia_vandalismo');
    case 'temporal':
      return SoleraL10n.t('arb.incidencia_temporal');
    case 'alcorque_danado':
      return SoleraL10n.t('arb.incidencia_alcorque_danado');
    case 'raices_acera':
      return SoleraL10n.t('arb.incidencia_raices_acera');
    case 'riesgo_caida':
      return SoleraL10n.t('arb.incidencia_riesgo_caida');
    case 'otro':
      return SoleraL10n.t('arb.incidencia_otro');
    default:
      return tipo;
  }
}

/// Día de la semana (1 = lunes … 7 = domingo, como `DateTime.weekday`).
String diaSemanaTraducido(int diaSemana) => [
        SoleraL10n.t('arb.dia_semana_1'),
        SoleraL10n.t('arb.dia_semana_2'),
        SoleraL10n.t('arb.dia_semana_3'),
        SoleraL10n.t('arb.dia_semana_4'),
        SoleraL10n.t('arb.dia_semana_5'),
        SoleraL10n.t('arb.dia_semana_6'),
        SoleraL10n.t('arb.dia_semana_7'),
    ][(diaSemana - 1).clamp(0, 6)];
