/// Lectura de números escritos a mano en los formularios, a la española:
/// coma decimal y punto de millares («1.200,50»), aunque también vale el
/// punto decimal («12.5»). Devuelve `null` si el texto está vacío o no se
/// entiende, para que el formulario avise en vez de guardar un 0.
///
/// Un solo punto seguido de tres cifras («1.200») es ambiguo: con
/// [puntoDeMillares] se lee como millares (importes en euros); con
/// [nullSiAmbiguo] no se lee (cantidades: «1.200 kg» podría ser 1,2 o
/// 1200, y mejor avisar que adivinar); sin ninguno, como decimal
/// (coordenadas, hectáreas).
double? leerNumero(String texto,
    {bool puntoDeMillares = false, bool nullSiAmbiguo = false}) {
  var limpio = texto.replaceAll(RegExp(r'[\s €]'), '');
  if (limpio.isEmpty) return null;
  final tieneComa = limpio.contains(',');
  final tienePunto = limpio.contains('.');
  // Sin cero delante: «0.500» es medio, no quinientos.
  final millaresConPuntos = RegExp(r'^-?[1-9]\d{0,2}(\.\d{3})+$');
  final millaresConComas = RegExp(r'^-?\d{1,3}(,\d{3})+$');

  if (tieneComa && tienePunto) {
    // El separador que va último es el decimal; el otro, de millares.
    final comaEsDecimal = limpio.lastIndexOf(',') > limpio.lastIndexOf('.');
    limpio = comaEsDecimal
        ? limpio.replaceAll('.', '').replaceAll(',', '.')
        : limpio.replaceAll(',', '');
  } else if (tieneComa) {
    if (','.allMatches(limpio).length > 1) {
      if (!millaresConComas.hasMatch(limpio)) return null;
      limpio = limpio.replaceAll(',', '');
    } else {
      limpio = limpio.replaceAll(',', '.');
    }
  } else if (tienePunto) {
    final variosPuntos = '.'.allMatches(limpio).length > 1;
    if (variosPuntos && !millaresConPuntos.hasMatch(limpio)) return null;
    if (!variosPuntos &&
        nullSiAmbiguo &&
        !puntoDeMillares &&
        millaresConPuntos.hasMatch(limpio)) {
      return null;
    }
    if (variosPuntos || (puntoDeMillares && millaresConPuntos.hasMatch(limpio))) {
      limpio = limpio.replaceAll('.', '');
    }
  }
  if (!RegExp(r'^-?(\d+\.?\d*|\.\d+)$').hasMatch(limpio)) return null;
  final numero = double.tryParse(limpio);
  return numero == null || numero.isNaN || numero.isInfinite ? null : numero;
}

/// Importe en euros escrito a mano → céntimos, o `null` si no se entiende.
int? centimosDesdeTexto(String texto) {
  final euros = leerNumero(texto, puntoDeMillares: true);
  return euros == null ? null : (euros * 100).round();
}
