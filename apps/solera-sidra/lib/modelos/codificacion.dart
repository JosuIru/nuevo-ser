/// Conjuntos de identificadores de catálogo guardados como texto
/// `a|b|c` (ordenado, sin vacíos ni repetidos).
String codificarIds(Iterable<String> ids) {
  final limpios = ids.map((id) => id.trim()).where((id) => id.isNotEmpty);
  return (limpios.toSet().toList()..sort()).join('|');
}

Set<String> decodificarIds(Object? texto) => texto is String
    ? texto
        .split('|')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
    : <String>{};

double? comoDecimal(Object? valor) => (valor as num?)?.toDouble();

bool comoBooleano(Object? valor) => valor == 1 || valor == true;
