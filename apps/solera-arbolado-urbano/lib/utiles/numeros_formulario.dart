import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Texto de error de un campo numérico que no se entiende.
const textoNumeroNoValido = 'Número no válido. Escríbelo como 12,5.';

/// Medida opcional escrita a mano (perímetro, altura, volumen): vacío →
/// `null`; si no, el número leído a la española (un punto es decimal).
double? medidaDesdeTexto(String texto) =>
    texto.trim().isEmpty ? null : leerNumero(texto);

/// Validador de un campo numérico opcional: vacío vale; lo escrito tiene
/// que entenderse, para no guardar en silencio un hueco o un 0.
String? validarMedidaOpcional(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  return leerNumero(limpio) == null ? textoNumeroNoValido : null;
}
