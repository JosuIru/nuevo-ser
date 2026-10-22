import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Texto de error común cuando lo escrito en un campo numérico no se
/// entiende («1,2,3», «doce», «1.200» en kg, que puede ser 1,2 o 1200).
const textoNumeroNoValido = 'Número no válido';

/// Validador para campos numéricos opcionales: vacío vale, pero si hay
/// algo escrito tiene que poder leerse (ver `leerNumero` del core).
String? validarNumeroOpcional(String? texto,
    {bool puntoDeMillares = false, bool nullSiAmbiguo = false}) {
  if (texto == null || texto.trim().isEmpty) return null;
  final numero = leerNumero(texto,
      puntoDeMillares: puntoDeMillares, nullSiAmbiguo: nullSiAmbiguo);
  if (numero == null || numero < 0) return textoNumeroNoValido;
  return null;
}

/// Validador para importes en euros opcionales («1.200,50» = 1200,50 €).
String? validarImporteOpcional(String? texto) =>
    validarNumeroOpcional(texto, puntoDeMillares: true);
