import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../modelos/colmena.dart';

/// Nombres visibles (en el idioma elegido) de valores guardados en BD.
/// Los valores en sí no se traducen nunca: solo lo que se pinta.

/// «blanco», «amarillo»… (valor de [Colmena.colorMarcaReina]) en el
/// idioma actual. Si el valor no se conoce, lo devuelve tal cual.
String etiquetaColorMarcaReina(String? color) {
  switch (color) {
    case 'blanco':
      return SoleraL10n.t('api.color_blanco');
    case 'amarillo':
      return SoleraL10n.t('api.color_amarillo');
    case 'rojo':
      return SoleraL10n.t('api.color_rojo');
    case 'verde':
      return SoleraL10n.t('api.color_verde');
    case 'azul':
      return SoleraL10n.t('api.color_azul');
  }
  return color ?? '';
}

/// Estado de la colmena en el idioma actual.
String etiquetaEstadoColmena(EstadoColmena estado) {
  switch (estado) {
    case EstadoColmena.viva:
      return SoleraL10n.t('api.estado_viva');
    case EstadoColmena.vacia:
      return SoleraL10n.t('api.estado_vacia');
    case EstadoColmena.descolmenada:
      return SoleraL10n.t('api.estado_descolmenada');
    case EstadoColmena.enjambreNuevo:
      return SoleraL10n.t('api.estado_enjambre_nuevo');
  }
}

/// Presencia de la reina en una revisión ('presente' | 'ausente' |
/// 'no_observada').
String etiquetaPresenciaReina(String valor) {
  switch (valor) {
    case 'presente':
      return SoleraL10n.t('api.reina_presente');
    case 'ausente':
      return SoleraL10n.t('api.reina_ausente');
    case 'no_observada':
      return SoleraL10n.t('api.reina_no_observada');
  }
  return valor;
}

/// Tipo de tratamiento ('varroa' | 'nosema' | 'sanitario_general' | 'otro').
String etiquetaTipoTratamiento(String valor) {
  switch (valor) {
    case 'varroa':
      return SoleraL10n.t('api.tratamiento_varroa');
    case 'nosema':
      return SoleraL10n.t('api.tratamiento_nosema');
    case 'sanitario_general':
      return SoleraL10n.t('api.tratamiento_sanitario_general');
    case 'otro':
      return SoleraL10n.t('api.otro');
  }
  return valor;
}

/// Tipo de incidencia ('sanitario' | 'mortalidad' | 'enjambrazon' | 'robo' |
/// 'vespa_velutina' | 'polilla_cera' | 'otro').
String etiquetaTipoIncidencia(String valor) {
  switch (valor) {
    case 'sanitario':
      return SoleraL10n.t('api.incidencia_sanitario');
    case 'mortalidad':
      return SoleraL10n.t('api.incidencia_mortalidad');
    case 'enjambrazon':
      return SoleraL10n.t('api.incidencia_enjambrazon');
    case 'robo':
      return SoleraL10n.t('api.incidencia_robo');
    case 'vespa_velutina':
      return SoleraL10n.t('api.incidencia_vespa_velutina');
    case 'polilla_cera':
      return SoleraL10n.t('api.incidencia_polilla_cera');
    case 'otro':
      return SoleraL10n.t('api.otro');
  }
  return valor;
}

/// Motivo de un movimiento ('mielada' | 'invernada' | 'sanitario' | 'baja' |
/// 'alta' | 'recogida_enjambre' | 'venta' | 'compra' | 'otro').
String etiquetaMotivoMovimiento(String valor) {
  switch (valor) {
    case 'mielada':
      return SoleraL10n.t('api.motivo_mielada');
    case 'invernada':
      return SoleraL10n.t('api.motivo_invernada');
    case 'sanitario':
      return SoleraL10n.t('api.motivo_sanitario');
    case 'baja':
      return SoleraL10n.t('baja');
    case 'alta':
      return SoleraL10n.t('api.motivo_alta');
    case 'recogida_enjambre':
      return SoleraL10n.t('api.motivo_recogida_enjambre');
    case 'venta':
      return SoleraL10n.t('api.motivo_venta');
    case 'compra':
      return SoleraL10n.t('api.motivo_compra');
    case 'otro':
      return SoleraL10n.t('api.otro');
  }
  return valor;
}
