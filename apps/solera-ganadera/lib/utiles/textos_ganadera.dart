import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Nombre visible de un código de catálogo: la clave `gana.<grupo>_<código>`
/// si existe; si no, el código tal cual (nunca la clave en bruto).
String nombreDeCodigo(String grupo, String codigo) {
  if (codigo.isEmpty) return '';
  final clave = 'gana.${grupo}_$codigo';
  return SoleraL10n.clavesDisponibles.contains(clave)
      ? SoleraL10n.t(clave)
      : codigo;
}

String nombreEspecie(String codigo) => nombreDeCodigo('especie', codigo);
String nombreSexo(String codigo) => nombreDeCodigo('sexo', codigo);
String nombreEstadoAnimal(String codigo) => nombreDeCodigo('estado', codigo);
String nombreDispositivo(String codigo) =>
    nombreDeCodigo('dispositivo', codigo);
String nombreTipoMovimiento(String codigo) =>
    nombreDeCodigo('movimiento', codigo);
String nombreTipoEvento(String codigo) => nombreDeCodigo('evento', codigo);
String nombreClaseMedicamento(String codigo) => nombreDeCodigo('clase', codigo);
String nombreTipoPasto(String codigo) => nombreDeCodigo('pasto', codigo);
String nombreTitularidad(String codigo) =>
    nombreDeCodigo('titularidad', codigo);
String nombreTipoTarea(String codigo) => nombreDeCodigo('tarea', codigo);
String nombreCategoriaEconomica(String codigo) =>
    nombreDeCodigo('categoria', codigo);

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número con [decimales] en el formato del idioma de la app.
String formatearNumero(num valor, {int decimales = 1}) =>
    NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: decimales)
        .format(valor);

/// Fecha corta dd/MM/yyyy (la de los documentos).
String formatearFecha(int? fechaMs) => fechaMs == null
    ? ''
    : DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(fechaMs));

String formatearDia(DateTime dia) => DateFormat('dd/MM/yyyy').format(dia);

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
int? leerEntero(String texto) => int.tryParse(texto.trim());
