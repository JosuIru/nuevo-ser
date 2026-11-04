import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Nombres visibles (traducidos) de valores que se guardan en la base de
/// datos como identificadores. El valor guardado no cambia nunca; solo
/// su etiqueta en pantalla.

/// Categoría comercial del aceite (`virgen_extra`, `virgen`, `lampante`,
/// `por_clasificar`).
String nombreCategoriaAceite(String categoria) => switch (categoria) {
      'virgen_extra' => SoleraL10n.t('acei.categoria_virgen_extra'),
      'virgen' => SoleraL10n.t('acei.categoria_virgen'),
      'lampante' => SoleraL10n.t('acei.categoria_lampante'),
      'por_clasificar' => SoleraL10n.t('acei.categoria_por_clasificar'),
      _ => categoria,
    };

/// Tipo de movimiento del libro del aceite (`entrada_molturacion`,
/// `traslado_deposito`, `mezcla_lotes`, `envasado`, `venta_granel`,
/// `autoconsumo`, `merma`).
String nombreTipoMovimiento(String tipo) => switch (tipo) {
      'entrada_molturacion' =>
        SoleraL10n.t('acei.movimiento_entrada_molturacion'),
      'traslado_deposito' => SoleraL10n.t('acei.movimiento_traslado_deposito'),
      'mezcla_lotes' => SoleraL10n.t('acei.movimiento_mezcla_lotes'),
      'envasado' => SoleraL10n.t('acei.movimiento_envasado'),
      'venta_granel' => SoleraL10n.t('acei.movimiento_venta_granel'),
      'autoconsumo' => SoleraL10n.t('acei.movimiento_autoconsumo'),
      'merma' => SoleraL10n.t('acei.movimiento_merma'),
      _ => tipo,
    };

/// Estado de la aceituna recolectada (`verde`, `envero`, `negra`).
String nombreTipoAceituna(String tipo) => switch (tipo) {
      'verde' => SoleraL10n.t('acei.aceituna_verde'),
      'envero' => SoleraL10n.t('acei.aceituna_envero'),
      'negra' => SoleraL10n.t('acei.aceituna_negra'),
      _ => tipo,
    };

/// Método de recolección (`vibrador`, `manual`, `paraguas`, `peine`,
/// `vareo`).
String nombreMetodoRecoleccion(String metodo) => switch (metodo) {
      'vibrador' => SoleraL10n.t('acei.metodo_vibrador'),
      'manual' => SoleraL10n.t('acei.metodo_manual'),
      'paraguas' => SoleraL10n.t('acei.metodo_paraguas'),
      'peine' => SoleraL10n.t('acei.metodo_peine'),
      'vareo' => SoleraL10n.t('acei.metodo_vareo'),
      _ => metodo,
    };

/// Sistema de riego de la parcela (`secano`, `superficial`, `goteo`,
/// `aspersion`, `mixto`).
String nombreSistemaRiego(String sistema) => switch (sistema) {
      'secano' => SoleraL10n.t('acei.riego_secano'),
      'superficial' => SoleraL10n.t('acei.riego_superficial'),
      'goteo' => SoleraL10n.t('acei.riego_goteo'),
      'aspersion' => SoleraL10n.t('acei.riego_aspersion'),
      'mixto' => SoleraL10n.t('acei.riego_mixto'),
      _ => sistema,
    };

/// Tipo de problema que devuelve la IA (`plaga`, `enfermedad`,
/// `fisiologico`, `abiotico`, `indeterminado`).
String nombreTipoProblemaIa(String tipo) => switch (tipo) {
      'plaga' => SoleraL10n.t('acei.problema_plaga'),
      'enfermedad' => SoleraL10n.t('acei.problema_enfermedad'),
      'fisiologico' => SoleraL10n.t('acei.problema_fisiologico'),
      'abiotico' => SoleraL10n.t('acei.problema_abiotico'),
      'indeterminado' => SoleraL10n.t('acei.problema_indeterminado'),
      _ => tipo,
    };

/// Tipo de tercero (`cliente`, `proveedor`, `ambos`).
String nombreTipoTercero(String tipo) => switch (tipo) {
      'cliente' => SoleraL10n.t('acei.tercero_cliente'),
      'proveedor' => SoleraL10n.t('proveedor'),
      'ambos' => SoleraL10n.t('acei.tercero_ambos'),
      _ => tipo,
    };

/// Tipos de gasto del libro económico, en el orden del desplegable.
const tiposGastoAceitera = [
  'insumos_olivar',
  'fitosanitarios',
  'recoleccion',
  'molturacion_externa',
  'envasado',
  'analiticas',
  'cuota_dop',
  'maquinaria',
  'mano_obra',
  'combustible',
  'seguros',
  'transporte',
  'certificacion',
  'otro',
];

String nombreTipoGasto(String tipo) => switch (tipo) {
      'insumos_olivar' => SoleraL10n.t('acei.gasto_insumos_olivar'),
      'fitosanitarios' => SoleraL10n.t('acei.gasto_fitosanitarios'),
      'recoleccion' => SoleraL10n.t('acei.gasto_recoleccion'),
      'molturacion_externa' => SoleraL10n.t('acei.gasto_molturacion_externa'),
      'envasado' => SoleraL10n.t('acei.gasto_envasado'),
      'analiticas' => SoleraL10n.t('acei.gasto_analiticas'),
      'cuota_dop' => SoleraL10n.t('acei.gasto_cuota_dop'),
      'maquinaria' => SoleraL10n.t('acei.gasto_maquinaria'),
      'mano_obra' => SoleraL10n.t('acei.gasto_mano_obra'),
      'combustible' => SoleraL10n.t('acei.gasto_combustible'),
      'seguros' => SoleraL10n.t('acei.gasto_seguros'),
      'transporte' => SoleraL10n.t('acei.gasto_transporte'),
      'certificacion' => SoleraL10n.t('acei.gasto_certificacion'),
      'otro' => SoleraL10n.t('acei.gasto_otro'),
      _ => tipo,
    };

/// Tipos de ingreso del libro económico, en el orden del desplegable.
const tiposIngresoAceitera = [
  'venta_aceituna',
  'venta_aceite_envasado',
  'venta_aceite_granel',
  'alquiler_terreno',
  'ayuda_pac',
  'subvencion_autonomica',
  'subproducto_alperujo',
  'otro',
];

String nombreTipoIngreso(String tipo) => switch (tipo) {
      'venta_aceituna' => SoleraL10n.t('acei.ingreso_venta_aceituna'),
      'venta_aceite_envasado' =>
        SoleraL10n.t('acei.ingreso_venta_aceite_envasado'),
      'venta_aceite_granel' => SoleraL10n.t('acei.ingreso_venta_aceite_granel'),
      'alquiler_terreno' => SoleraL10n.t('acei.ingreso_alquiler_terreno'),
      'ayuda_pac' => SoleraL10n.t('acei.ingreso_ayuda_pac'),
      'subvencion_autonomica' =>
        SoleraL10n.t('acei.ingreso_subvencion_autonomica'),
      'subproducto_alperujo' =>
        SoleraL10n.t('acei.ingreso_subproducto_alperujo'),
      'otro' => SoleraL10n.t('acei.ingreso_otro'),
      _ => tipo,
    };
