import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número con [decimales] en el formato del idioma de la app.
String formatearNumero(num valor, {int decimales = 1}) =>
    NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: decimales)
        .format(valor);

/// «1.250 l».
String formatearLitros(num litros) =>
    '${formatearNumero(litros, decimales: 0)} l';

/// Lee «1.234,5» o «1234.5»; null si no se entiende.
double? leerNumero(String texto) {
  final limpio = texto.trim().replaceAll(' ', '');
  if (limpio.isEmpty) return null;
  final normalizado = limpio.contains(',')
      ? limpio.replaceAll('.', '').replaceAll(',', '.')
      : limpio;
  return double.tryParse(normalizado);
}

/// Lee un entero; null si no se entiende.
int? leerEntero(String texto) {
  final numero = leerNumero(texto);
  return numero == null || numero != numero.roundToDouble()
      ? null
      : numero.round();
}

/// «4 nov.» en el idioma de la app.
String formatearFechaCorta(int milisegundos) =>
    DateFormat.MMMd(SoleraL10n.idioma)
        .format(DateTime.fromMillisecondsSinceEpoch(milisegundos));

/// «04/11/2026».
String formatearFecha(int milisegundos) => DateFormat('dd/MM/yyyy')
    .format(DateTime.fromMillisecondsSinceEpoch(milisegundos));

/// Nombre visible de un valor de lista cerrada: busca `sidr.<grupo>_<valor>`.
/// Para valores vacíos devuelve «—».
String nombreValor(String grupo, String valor) {
  if (valor.isEmpty) return '—';
  final clave = 'sidr.${grupo}_$valor';
  return SoleraL10n.t(clave);
}

/// Claves de los valores de listas cerradas (las usa el test de traducciones).
const List<String> clavesValores = [
  'sidr.perfil_sidra',
  'sidr.perfil_txakoli',
  'sidr.perfil_ambos',
  'sidr.cultivo_manzano',
  'sidr.cultivo_vid',
  'sidr.fruta_manzana',
  'sidr.fruta_uva',
  'sidr.estado_fruta_sana',
  'sidr.estado_fruta_danos_leves',
  'sidr.estado_fruta_danos_graves',
  'sidr.material_madera',
  'sidr.material_inoxidable',
  'sidr.material_otro',
  'sidr.producto_sidra',
  'sidr.producto_txakoli',
  'sidr.calificacion_pendiente',
  'sidr.calificacion_apta',
  'sidr.calificacion_descalificada',
  'sidr.eficacia_buena',
  'sidr.eficacia_regular',
  'sidr.eficacia_mala',
  'sidr.movimiento_prensado',
  'sidr.movimiento_trasiego_entrada',
  'sidr.movimiento_trasiego_salida',
  'sidr.movimiento_retirada',
  'sidr.movimiento_txotx',
  'sidr.movimiento_embotellado',
  'sidr.dop_euskal_sagardoa',
  'sidr.dop_sidra_asturias',
  'sidr.dop_bizkaiko_txakolina',
  'sidr.dop_getariako_txakolina',
  'sidr.dop_arabako_txakolina',
  'sidr.aviso_acidez_volatil_alta',
  'sidr.aviso_grado_bajo',
  'sidr.aviso_sulfuroso_alto',
  'sidr.aviso_densidad_mosto_baja',
  'sidr.aviso_rendimiento_alto',
  'sidr.aviso_rendimiento_bajo',
  'sidr.regimen_general',
  'sidr.regimen_reagp',
];
