import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Aviso que sale bajo un campo numérico cuando lo escrito no se entiende.
const textoNumeroNoValido = 'Número no válido (ej. 12,5)';

/// Entero escrito a mano (colmenas, varroas caídas, días, año…), o `null`
/// si está vacío, no se entiende o lleva decimales. «1.200» es ambiguo y
/// también da `null`: mejor avisar que adivinar.
int? leerEntero(String texto) {
  final numero = leerNumero(texto, nullSiAmbiguo: true);
  if (numero == null || numero != numero.roundToDouble()) return null;
  return numero.round();
}

/// Validador de un importe en euros opcional: vacío vale; si hay algo
/// escrito, tiene que entenderse.
String? validarImporteOpcional(String? texto) {
  if ((texto ?? '').trim().isEmpty) return null;
  return centimosDesdeTexto(texto!) == null ? textoNumeroNoValido : null;
}

/// Validador de una cantidad con decimales opcional (kilos, unidades).
String? validarCantidadOpcional(String? texto) {
  if ((texto ?? '').trim().isEmpty) return null;
  return leerNumero(texto!, nullSiAmbiguo: true) == null
      ? textoNumeroNoValido
      : null;
}

/// Validador de un entero opcional.
String? validarEnteroOpcional(String? texto) {
  if ((texto ?? '').trim().isEmpty) return null;
  return leerEntero(texto!) == null ? textoNumeroNoValido : null;
}

/// Validador de una superficie o coordenada opcional (el punto es decimal).
String? validarDecimalOpcional(String? texto) {
  if ((texto ?? '').trim().isEmpty) return null;
  return leerNumero(texto!) == null ? textoNumeroNoValido : null;
}
