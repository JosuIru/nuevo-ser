import 'solera_l10n.dart';

/// Nombre del idioma, tal como se le pide a Claude que conteste.
const _nombreIdiomaParaClaude = {
  'es': 'castellano',
  'eu': 'euskera (batua)',
  'ca': 'catalán',
  'gl': 'gallego (normativa RAG)',
};

/// Frase para añadir al prompt de sistema: Claude contesta en el idioma
/// elegido en la app ([SoleraL10n.idioma], o [idioma] si se pasa).
///
/// Los valores cerrados que la app compara (tipos, categorías del JSON) se
/// quedan como estén definidos en el prompt; solo cambian los textos libres.
String instruccionIdiomaRespuestaClaude({String? idioma}) {
  final nombre = _nombreIdiomaParaClaude[idioma ?? SoleraL10n.idioma] ??
      _nombreIdiomaParaClaude['es']!;
  return 'IDIOMA: escribe todo el texto libre de tu respuesta en $nombre. '
      'Los valores cerrados (listas de opciones, claves del JSON) déjalos '
      'exactamente como se indican.';
}
