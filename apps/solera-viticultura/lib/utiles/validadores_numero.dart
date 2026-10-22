import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Validadores de los campos numéricos de los formularios. Leen a la
/// española con `leerNumero` del core y avisan si lo escrito no se
/// entiende, en vez de guardar un 0 o dejarlo vacío sin decir nada.

const textoNumeroNoValido = 'Número no válido (ej. 1.200,50)';

/// Importe en euros opcional: vacío vale; si hay texto, tiene que leerse.
String? validarImporteOpcional(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  return centimosDesdeTexto(limpio) == null ? textoNumeroNoValido : null;
}

/// Cantidad opcional (kilos, botellas…): «1.200» es ambiguo y se avisa.
String? validarCantidadOpcional(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  return leerNumero(limpio, nullSiAmbiguo: true) == null
      ? textoNumeroNoValido
      : null;
}

/// Medida opcional (hectáreas, coordenadas): un punto suelto es decimal.
String? validarMedidaOpcional(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  return leerNumero(limpio) == null ? textoNumeroNoValido : null;
}
