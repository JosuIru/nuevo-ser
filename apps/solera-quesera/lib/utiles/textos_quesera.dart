import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Textos visibles de valores guardados en BD (tipos, estados,
/// categorías). El valor guardado no cambia nunca: solo se traduce lo que
/// se enseña. Si llega un valor desconocido se muestra tal cual.

String _traducirValor(Map<String, String> clavesPorValor, String valor) {
  final clave = clavesPorValor[valor];
  return clave == null ? valor : SoleraL10n.t(clave);
}

/// Locale de `intl` para fechas según el idioma elegido en Ajustes.
String localeFechasQuesera() => switch (SoleraL10n.idioma) {
      'eu' => 'eu',
      'ca' => 'ca',
      'gl' => 'gl',
      _ => 'es_ES',
    };

const _clavesTipoLeche = {
  'oveja': 'ques.leche_oveja',
  'cabra': 'ques.leche_cabra',
  'vaca': 'ques.leche_vaca',
  'mezcla': 'ques.leche_mezcla',
  'mixto': 'ques.leche_mezcla',
};

/// Oveja / cabra / vaca / mezcla.
String textoTipoLeche(String valor) => _traducirValor(_clavesTipoLeche, valor);

const _clavesTipoCuajo = {
  'animal': 'ques.cuajo_animal',
  'vegetal': 'ques.cuajo_vegetal',
  'microbiano': 'ques.cuajo_microbiano',
};

/// Animal / vegetal / microbiano (corto, sin el ejemplo del desplegable).
String textoTipoCuajo(String valor) => _traducirValor(_clavesTipoCuajo, valor);

const _clavesEstadoPieza = {
  'afinando': 'ques.estado_afinando',
  'lista': 'lista',
  'expedida': 'ques.estado_expedida',
  'baja': 'baja',
};

String textoEstadoPieza(String valor) =>
    _traducirValor(_clavesEstadoPieza, valor);

const _clavesTipoEvento = {
  'volteo': 'ques.evento_volteo',
  'cepillado': 'ques.evento_cepillado',
  'ahumado': 'ques.evento_ahumado',
  'baño': 'ques.evento_bano',
  'controlPeso': 'ques.evento_control_peso',
  'inspeccionVisual': 'ques.evento_inspeccion_visual',
  'otro': 'ques.otro',
};

String textoTipoEventoCuracion(String valor) =>
    _traducirValor(_clavesTipoEvento, valor);

const _clavesTipoAnalitica = {
  'microbiologica': 'ques.analitica_microbiologica',
  'fisico_quimica': 'ques.analitica_fisico_quimica',
  'sensorial': 'ques.analitica_sensorial',
  'agua': 'ques.analitica_agua',
  'superficie': 'ques.analitica_superficie',
};

String textoTipoAnalitica(String valor) =>
    _traducirValor(_clavesTipoAnalitica, valor);

const _clavesTipoIncidencia = {
  'defecto': 'ques.incidencia_defecto',
  'rotura': 'ques.incidencia_rotura',
  'contaminacion': 'ques.incidencia_contaminacion',
  'hinchazon': 'ques.incidencia_hinchazon',
  'mohoIndeseado': 'ques.incidencia_moho_indeseado',
  'alteracionOrganoleptica': 'ques.incidencia_alteracion_organoleptica',
  'retirada': 'ques.incidencia_retirada',
  'otra': 'ques.otra',
};

String textoTipoIncidencia(String valor) =>
    _traducirValor(_clavesTipoIncidencia, valor);

const _clavesEstadoFactura = {
  'emitida': 'ques.factura_emitida',
  'pagada': 'ques.factura_pagada',
  'vencida': 'ques.factura_vencida',
  'anulada': 'ques.factura_anulada',
};

String textoEstadoFactura(String valor) =>
    _traducirValor(_clavesEstadoFactura, valor);

const _clavesCategoriaApunte = {
  // Ingresos
  'venta_queso': 'ques.cat_venta_queso',
  'feria': 'ques.cat_feria',
  'suscripcion': 'ques.cat_suscripcion',
  'distribuidor': 'ques.cat_distribuidor',
  'subvencion_do': 'ques.cat_subvencion_do',
  // Gastos
  'leche': 'ques.cat_leche',
  'fermentos_cuajo': 'ques.cat_fermentos_cuajo',
  'energia_cava': 'ques.cat_energia_cava',
  'etiquetado': 'ques.cat_etiquetado',
  'analiticas': 'ques.cat_analiticas',
  'cuota_do': 'ques.cat_cuota_do',
  'transporte': 'ques.cat_transporte',
  'mano_obra': 'ques.cat_mano_obra',
  'material_limpieza': 'ques.cat_material_limpieza',
  'seguros': 'ques.cat_seguros',
  'otro': 'ques.otro',
};

/// Categoría de un apunte del libro económico (ingreso o gasto).
String textoCategoriaApunte(String valor) =>
    _traducirValor(_clavesCategoriaApunte, valor);

const _clavesTipoDefectoIa = {
  'textura': 'ques.defecto_textura',
  'corteza': 'ques.defecto_corteza',
  'color': 'ques.defecto_color',
  'sabor': 'ques.defecto_sabor',
  'hinchazon': 'ques.incidencia_hinchazon',
  'otro': 'ques.otro',
};

/// Tipo de defecto que devuelve la IA (textura, corteza…).
String textoTipoDefectoIa(String valor) =>
    _traducirValor(_clavesTipoDefectoIa, valor);

/// Edad de una pieza: «12 días», «2 meses», «2 meses 5 días».
String textoEdadPieza(int dias) {
  if (dias < 30) return SoleraL10n.tf('ques.dias_n', {'n': dias});
  final meses = dias ~/ 30;
  final resto = dias % 30;
  return resto > 0
      ? SoleraL10n.tf('ques.meses_y_dias_n', {'meses': meses, 'dias': resto})
      : SoleraL10n.tf('ques.meses_n', {'n': meses});
}

/// «12,5 °C / 85 % HR» para el último control de una cava.
String textoTemperaturaHumedad(double temperatura, double humedad) =>
    SoleraL10n.tf('ques.temp_y_humedad', {
      'temp': temperatura.toStringAsFixed(1),
      'hr': humedad.toStringAsFixed(0),
    });
