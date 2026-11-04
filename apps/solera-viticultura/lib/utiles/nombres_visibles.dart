import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Nombre visible, en el idioma actual, del `tipo` guardado en una
/// incidencia ('plaga' | 'enfermedad' | 'estres' | 'fisiologico' | 'otro').
/// El valor guardado en BD no cambia; si llega uno desconocido se muestra
/// tal cual.
String nombreVisibleTipoIncidencia(String tipo) => switch (tipo) {
      'plaga' => SoleraL10n.t('viti.tipo_incidencia_plaga'),
      'enfermedad' => SoleraL10n.t('viti.tipo_incidencia_enfermedad'),
      'estres' => SoleraL10n.t('viti.tipo_incidencia_estres'),
      'fisiologico' => SoleraL10n.t('viti.tipo_incidencia_fisiologico'),
      'otro' => SoleraL10n.t('viti.tipo_otro'),
      _ => tipo,
    };

/// Nombre visible, en el idioma actual, del `tipo` guardado en un
/// tratamiento ('fitosanitario' | 'abono' | 'riego' | 'poda' | 'otro').
String nombreVisibleTipoTratamiento(String tipo) => switch (tipo) {
      'fitosanitario' => SoleraL10n.t('viti.tipo_tratamiento_fitosanitario'),
      'abono' => SoleraL10n.t('viti.tipo_tratamiento_abono'),
      'riego' => SoleraL10n.t('viti.tipo_tratamiento_riego'),
      'poda' => SoleraL10n.t('viti.tipo_tratamiento_poda'),
      'otro' => SoleraL10n.t('viti.tipo_otro'),
      _ => tipo,
    };
