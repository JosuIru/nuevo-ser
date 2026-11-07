// Copiado de Zunbeltz (commit 92ade2b) sin cambios de lógica.
/// Polígono, parcela y (si la hay) subparcela de la referencia SIGPAC o
/// catastral de una pieza, para enseñarla como «24 · 2 · M».
///
/// El campo es texto libre: entiende «Pol. 24 parc. 2 subp. M» (con o sin
/// municipio delante, como lo siembra la app) y «24-2-M» / «24/2». Si no
/// encaja, `null`, y quien lo pinte enseña el texto tal cual.
List<String>? partesRecintoSigpac(String recinto) {
  final texto = recinto.trim();
  if (texto.isEmpty) return null;
  final conRotulos = RegExp(
    r'pol(?:[ií]gono|\.)?\s*(\d+)[\s,·]*parc(?:ela|\.)?\s*(\d+)'
    r'(?:[\s,·]*subp(?:arcela|\.)?\s*([a-z0-9]+))?',
    caseSensitive: false,
  ).firstMatch(texto);
  final soloNumeros = RegExp(
          r'^(\d+)\s*[-/·]\s*(\d+)(?:\s*[-/·]\s*([a-z0-9]+))?$',
          caseSensitive: false)
      .firstMatch(texto);
  final encontrado = conRotulos ?? soloNumeros;
  if (encontrado == null) return null;
  return [
    encontrado.group(1)!,
    encontrado.group(2)!,
    if (encontrado.group(3) != null) encontrado.group(3)!.toUpperCase(),
  ];
}
