import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Validadores de los campos numéricos de los formularios. La lectura
/// (coma decimal, punto de millares) la hace `leerNumero` del core; aquí
/// solo se decide qué texto de error ve la persona cuando lo que ha
/// escrito no se entiende, en vez de guardar un 0 en silencio.

/// Campo numérico opcional: vacío vale; si hay texto, tiene que leerse.
/// [nullSiAmbiguo] para cantidades («1.200 kg» no se adivina).
String? validarNumeroOpcional(String? texto, {bool nullSiAmbiguo = false}) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  final numero = leerNumero(limpio, nullSiAmbiguo: nullSiAmbiguo);
  if (numero == null) return 'Número no válido (p. ej. 12,5)';
  if (numero < 0) return 'No puede ser negativo';
  return null;
}

/// Importe en euros opcional: vacío vale; si hay texto, «1.200,50» o «12,5».
String? validarImporteOpcional(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  final centimos = centimosDesdeTexto(limpio);
  if (centimos == null) return 'Importe no válido (p. ej. 1.200,50)';
  if (centimos < 0) return 'No puede ser negativo';
  return null;
}

/// Importe obligatorio y mayor que cero.
String? validarImporteObligatorio(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return 'Importe obligatorio';
  final centimos = centimosDesdeTexto(limpio);
  if (centimos == null) return 'Importe no válido (p. ej. 1.200,50)';
  if (centimos <= 0) return 'Mayor que cero';
  return null;
}

/// Número guardado → texto para volver a editarlo, con coma decimal, para
/// que al releerlo no parezca un punto de millares («1.234» kg).
String numeroParaEditar(double numero) {
  final texto = numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toString();
  return texto.replaceAll('.', ',');
}
