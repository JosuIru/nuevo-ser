import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/planificador_hornada.dart';

/// Nombre visible de un alérgeno del anexo II (el id no cambia nunca).
String nombreAlergeno(String id) => switch (id) {
      'gluten' => SoleraL10n.t('obra.alergeno_gluten'),
      'crustaceos' => SoleraL10n.t('obra.alergeno_crustaceos'),
      'huevos' => SoleraL10n.t('obra.alergeno_huevos'),
      'pescado' => SoleraL10n.t('obra.alergeno_pescado'),
      'cacahuetes' => SoleraL10n.t('obra.alergeno_cacahuetes'),
      'soja' => SoleraL10n.t('obra.alergeno_soja'),
      'lacteos' => SoleraL10n.t('obra.alergeno_lacteos'),
      'frutos_cascara' => SoleraL10n.t('obra.alergeno_frutos_cascara'),
      'apio' => SoleraL10n.t('obra.alergeno_apio'),
      'mostaza' => SoleraL10n.t('obra.alergeno_mostaza'),
      'sesamo' => SoleraL10n.t('obra.alergeno_sesamo'),
      'sulfitos' => SoleraL10n.t('obra.alergeno_sulfitos'),
      'altramuces' => SoleraL10n.t('obra.alergeno_altramuces'),
      'moluscos' => SoleraL10n.t('obra.alergeno_moluscos'),
      _ => id,
    };

/// Nombre visible de un tipo de registro de autocontrol.
String nombreTipoAutocontrol(String tipo) => switch (tipo) {
      'temperatura' => SoleraL10n.t('obra.tipo_temperatura'),
      'limpieza' => SoleraL10n.t('obra.tipo_limpieza'),
      'plagas' => SoleraL10n.t('obra.tipo_plagas'),
      'proveedor' => SoleraL10n.t('obra.tipo_proveedor'),
      'formacion' => SoleraL10n.t('obra.tipo_formacion'),
      'incidencia' => SoleraL10n.t('obra.tipo_incidencia'),
      _ => tipo,
    };

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número con [decimales] en el formato del idioma de la app.
String formatearNumero(num valor, {int decimales = 1}) =>
    NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: decimales)
        .format(valor);

/// Lee «1.234,5» o «1234.5»; null si no se entiende.
double? leerNumero(String texto) {
  final limpio = texto.trim().replaceAll(' ', '');
  if (limpio.isEmpty) return null;
  final normalizado = limpio.contains(',')
      ? limpio.replaceAll('.', '').replaceAll(',', '.')
      : limpio;
  return double.tryParse(normalizado);
}

/// Nombre visible de una categoría del libro de ingresos y gastos.
String nombreCategoriaEconomica(String categoria) => switch (categoria) {
      'venta_mostrador' => SoleraL10n.t('obra.categoria_venta_mostrador'),
      'venta_pedidos' => SoleraL10n.t('obra.categoria_venta_pedidos'),
      'otros_ingresos' => SoleraL10n.t('obra.categoria_otros_ingresos'),
      'materia_prima' => SoleraL10n.t('obra.categoria_materia_prima'),
      'envases' => SoleraL10n.t('obra.categoria_envases'),
      'energia' => SoleraL10n.t('obra.categoria_energia'),
      'alquiler' => SoleraL10n.t('obra.categoria_alquiler'),
      'personal' => SoleraL10n.t('obra.categoria_personal'),
      'maquinaria' => SoleraL10n.t('obra.categoria_maquinaria'),
      'otros_gastos' => SoleraL10n.t('obra.categoria_otros_gastos'),
      _ => categoria,
    };

/// Nombre visible de una fase de la hornada.
String nombreFaseHornada(FaseHornada fase) => switch (fase) {
      FaseHornada.refrescoMasaMadre => SoleraL10n.t('obra.plan_fase_refresco'),
      FaseHornada.autolisis => SoleraL10n.t('obra.plan_fase_autolisis'),
      FaseHornada.amasado => SoleraL10n.t('obra.plan_fase_amasado'),
      FaseHornada.primeraFermentacion =>
        SoleraL10n.t('obra.plan_fase_primera_fermentacion'),
      FaseHornada.formado => SoleraL10n.t('obra.plan_fase_formado'),
      FaseHornada.fermentacionFinal =>
        SoleraL10n.t('obra.plan_fase_fermentacion_final'),
      FaseHornada.precalentarHorno => SoleraL10n.t('obra.plan_fase_precalentar'),
      FaseHornada.coccion => SoleraL10n.t('obra.plan_fase_coccion'),
      FaseHornada.enfriado => SoleraL10n.t('obra.plan_fase_enfriado'),
    };

/// 95 min → «1 h 35 min»; 40 → «40 min».
String formatearDuracion(Duration duracion) {
  final minutos = duracion.inMinutes;
  if (minutos < 60) return '$minutos min';
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  return resto == 0 ? '$horas h' : '$horas h $resto min';
}

/// Rango de minutos como «1 h 30 min – 2 h».
String formatearRangoMinutos(int minimo, int maximo) => minimo == maximo
    ? formatearDuracion(Duration(minutes: minimo))
    : '${formatearDuracion(Duration(minutes: minimo))} – '
        '${formatearDuracion(Duration(minutes: maximo))}';
