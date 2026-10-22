import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Texto de error para un campo numérico de formulario: `null` si está
/// vacío o se entiende como número (a la española, «12,5» o «1.200,50»);
/// si no se entiende, un aviso corto para no guardar un 0 sin querer.
///
/// Las opciones son las de [leerNumero]: [puntoDeMillares] para importes
/// en euros y [nullSiAmbiguo] para cantidades (litros, kg), donde «1.200»
/// no se sabe si es 1,2 o 1200.
String? avisoNumeroNoValido(String? texto,
    {bool puntoDeMillares = false, bool nullSiAmbiguo = false}) {
  if (texto == null || texto.trim().isEmpty) return null;
  final numero = leerNumero(texto,
      puntoDeMillares: puntoDeMillares, nullSiAmbiguo: nullSiAmbiguo);
  return numero == null ? textoNumeroNoValido : null;
}

/// Aviso común de los campos numéricos que no se entienden.
const textoNumeroNoValido = 'Número no válido (p. ej. 12,5)';
