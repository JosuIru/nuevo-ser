import '../i18n/solera_l10n.dart';
import 'numeros.dart';

/// Validadores de los campos numéricos de los formularios, comunes a toda la
/// suite. La lectura (coma decimal, punto de millares) la hace [leerNumero];
/// aquí se decide qué aviso ve la persona cuando lo escrito no se entiende,
/// en vez de guardar un 0 en silencio. Los avisos van por [SoleraL10n].
///
/// Por defecto no se admiten negativos: en los formularios de la suite
/// (importes, kilos, superficies, medidas) un negativo es un error de
/// tecleo. Donde tenga sentido (temperaturas), `permitirNegativos: true`.

String? _avisoSiNegativo(num numero, bool permitirNegativos) =>
    !permitirNegativos && numero < 0
        ? SoleraL10n.t('no_puede_ser_negativo')
        : null;

/// Número opcional: vacío vale; si hay texto, tiene que leerse.
/// [nullSiAmbiguo] para cantidades (en «1.200 kg» no se adivina si el punto
/// es de millares).
String? validarNumeroOpcional(String? texto,
    {bool nullSiAmbiguo = false, bool permitirNegativos = false}) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  final numero = leerNumero(limpio, nullSiAmbiguo: nullSiAmbiguo);
  if (numero == null) return SoleraL10n.t('numero_no_valido');
  return _avisoSiNegativo(numero, permitirNegativos);
}

/// Número obligatorio (vacío no vale).
String? validarNumeroObligatorio(String? texto,
    {bool nullSiAmbiguo = false, bool permitirNegativos = false}) {
  if ((texto ?? '').trim().isEmpty) return SoleraL10n.t('numero_no_valido');
  return validarNumeroOpcional(texto,
      nullSiAmbiguo: nullSiAmbiguo, permitirNegativos: permitirNegativos);
}

/// Importe en euros opcional: vacío vale; si hay texto, «1.200,50» o «12,5».
String? validarImporteOpcional(String? texto,
    {bool permitirNegativos = false}) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  final centimos = centimosDesdeTexto(limpio);
  if (centimos == null) return SoleraL10n.t('importe_no_valido');
  return _avisoSiNegativo(centimos, permitirNegativos);
}

/// Importe en euros obligatorio y mayor que cero.
String? validarImporteObligatorio(String? texto) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return SoleraL10n.t('importe_obligatorio');
  final centimos = centimosDesdeTexto(limpio);
  if (centimos == null) return SoleraL10n.t('importe_no_valido');
  if (centimos <= 0) return SoleraL10n.t('mayor_que_cero');
  return null;
}

/// Entero escrito a mano (colmenas, días, piezas, año…), o `null` si está
/// vacío, no se entiende o lleva decimales. «1.200» es ambiguo y también da
/// `null`: mejor avisar que adivinar.
int? leerEntero(String texto) {
  final numero = leerNumero(texto, nullSiAmbiguo: true);
  if (numero == null || numero != numero.roundToDouble()) return null;
  return numero.round();
}

/// Entero opcional: vacío vale; si hay texto, tiene que ser entero.
String? validarEnteroOpcional(String? texto, {bool permitirNegativos = false}) {
  final limpio = (texto ?? '').trim();
  if (limpio.isEmpty) return null;
  final entero = leerEntero(limpio);
  if (entero == null) return SoleraL10n.t('numero_entero_no_valido');
  return _avisoSiNegativo(entero, permitirNegativos);
}

/// Número guardado → texto para volver a editarlo, con coma decimal, para
/// que al releerlo no parezca un punto de millares («1.234» kg no es 1,234).
String numeroParaEditar(num numero) {
  final texto = numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toString();
  return texto.replaceAll('.', ',');
}
