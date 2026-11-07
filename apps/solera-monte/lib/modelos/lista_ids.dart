import 'dart:convert';

/// Lista de textos guardada como «a|b|c» (los ids de catálogo no llevan «|»).
String unirLista(List<String> elementos) => elementos
    .map((elemento) => elemento.trim())
    .where((elemento) => elemento.isNotEmpty)
    .join('|');

List<String> separarLista(String? texto) => (texto ?? '')
    .split('|')
    .map((elemento) => elemento.trim())
    .where((elemento) => elemento.isNotEmpty)
    .toList();

/// Lista de ids enteros guardada como JSON `[1, 4, 7]` (sqflite no tiene
/// listas). Como `partidasUsadasJson` de la molturación de aceitera.
String codificarIds(List<int> ids) => jsonEncode(ids);

/// Lista vacía si el JSON no es válido (defensivo con datos antiguos).
List<int> decodificarIds(String? json) {
  try {
    final crudo = jsonDecode(json ?? '[]');
    if (crudo is! List) return const [];
    return crudo.whereType<num>().map((numero) => numero.toInt()).toList();
  } catch (_) {
    return const [];
  }
}
