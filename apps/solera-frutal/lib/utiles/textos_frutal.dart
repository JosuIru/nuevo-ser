import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Nombre visible de una especie (el id no cambia nunca).
String nombreEspecie(String id) => switch (id) {
      'almendro' => SoleraL10n.t('frut.especie_almendro'),
      'avellano' => SoleraL10n.t('frut.especie_avellano'),
      'nogal' => SoleraL10n.t('frut.especie_nogal'),
      'castano' => SoleraL10n.t('frut.especie_castano'),
      'pistachero' => SoleraL10n.t('frut.especie_pistachero'),
      'hueso' => SoleraL10n.t('frut.especie_hueso'),
      'pepita' => SoleraL10n.t('frut.especie_pepita'),
      _ => id,
    };

String nombreSistemaRiego(String id) => switch (id) {
      'goteo' => SoleraL10n.t('frut.riego_goteo'),
      'aspersion' => SoleraL10n.t('frut.riego_aspersion'),
      'superficie' => SoleraL10n.t('frut.riego_superficie'),
      _ => id,
    };

String nombreMetodoAbonado(String id) => switch (id) {
      'fondo' => SoleraL10n.t('frut.abonado_fondo'),
      'cobertera' => SoleraL10n.t('frut.abonado_cobertera'),
      'fertirrigacion' => SoleraL10n.t('frut.abonado_fertirrigacion'),
      'foliar' => SoleraL10n.t('frut.abonado_foliar'),
      _ => id,
    };

String nombreEficacia(String id) => switch (id) {
      'buena' => SoleraL10n.t('frut.eficacia_buena'),
      'regular' => SoleraL10n.t('frut.eficacia_regular'),
      'mala' => SoleraL10n.t('frut.eficacia_mala'),
      _ => id,
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

/// Fecha corta (dd/MM/aaaa), igual en todos los idiomas: es la de los
/// documentos oficiales.
String formatearFecha(int fechaMs) => DateFormat('dd/MM/yyyy')
    .format(DateTime.fromMillisecondsSinceEpoch(fechaMs));

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
int? leerEntero(String texto) => leerNumero(texto)?.round();

/// Inicio y fin (ms, ambos incluidos) del año natural [anyo].
(int, int) intervaloAnyo(int anyo) => (
      DateTime(anyo).millisecondsSinceEpoch,
      DateTime(anyo + 1).millisecondsSinceEpoch - 1,
    );
