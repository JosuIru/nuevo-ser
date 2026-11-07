import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Nombre visible de un valor de lista cerrada: clave `huer.<grupo>_<id>`.
/// Si la clave no existe, el propio id.
String _texto(String grupo, String id) {
  final clave = 'huer.${grupo}_$id';
  return SoleraL10n.clavesDisponibles.contains(clave)
      ? SoleraL10n.t(clave)
      : id;
}

String nombreEstadoEcologico(String id) => _texto('estado_eco', id);
String nombreSistemaRiego(String id) => _texto('riego', id);
String nombreTipoSiembra(String id) => _texto('tipo_siembra', id);
String nombreUnidadSiembra(String id) => _texto('unidad', id);
String nombreDestinoCosecha(String id) => _texto('destino', id);
String nombreTipoInsumo(String id) => _texto('tipo_insumo', id);
String nombreEficacia(String id) => _texto('eficacia', id);
String nombreOrigenSemilla(String id) => _texto('origen', id);
String nombreTamanoCesta(String id) => _texto('tamano', id);
String nombreFrecuencia(String id) => _texto('frecuencia', id);
String nombreEstadoCesta(String id) => _texto('estado_cesta', id);
String nombreResultadoEntrega(String id) => _texto('resultado', id);

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número con [decimales] en el formato del idioma de la app.
String formatearNumero(num valor, {int decimales = 1}) =>
    NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: decimales)
        .format(valor);

/// Kilos con hasta 2 decimales sin ceros sobrantes: «1,5 kg».
String formatearKilos(double kg) {
  final redondeado = (kg * 100).round() / 100;
  final decimales = redondeado == redondeado.roundToDouble()
      ? 0
      : ((redondeado * 10) == (redondeado * 10).roundToDouble() ? 1 : 2);
  return '${formatearNumero(redondeado, decimales: decimales)} kg';
}

/// Fecha corta (dd/MM/aaaa), igual en todos los idiomas: es la de los
/// documentos oficiales.
String formatearFecha(int fechaMs) => DateFormat('dd/MM/yyyy')
    .format(DateTime.fromMillisecondsSinceEpoch(fechaMs));

String formatearFechaDia(DateTime fecha) =>
    formatearFecha(fecha.millisecondsSinceEpoch);

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

/// Número para un campo de texto editable (vacío si es null).
String numeroParaCampo(num? valor, {int decimales = 2}) {
  if (valor == null) return '';
  if (valor == valor.roundToDouble()) return valor.round().toString();
  return formatearNumero(valor, decimales: decimales);
}

/// Inicio y fin (ms, ambos incluidos) del año natural [anyo].
(int, int) intervaloAnyo(int anyo) => (
      DateTime(anyo).millisecondsSinceEpoch,
      DateTime(anyo + 1).millisecondsSinceEpoch - 1,
    );
