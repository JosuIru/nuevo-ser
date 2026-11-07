import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

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
