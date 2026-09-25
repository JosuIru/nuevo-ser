import 'package:flutter/widgets.dart';

import '../dominio/eso/problema_eso.dart' show traduccionesEso;
import 'narrativa_arco_cinco.dart';
import 'narrativa_ca.dart';
import 'narrativa_eu.dart';

/// Traduce un texto narrativo del castellano al idioma de [locale].
///
/// El castellano es la fuente canónica: las claves de los maps
/// [narrativaEu] y [narrativaCa] son texto literal en castellano. Si una
/// línea no está traducida, se devuelve el original — la app sigue
/// funcionando con mezcla durante la fase de revisión.
///
/// El emparejamiento se hace por igualdad estricta (incluyendo
/// puntuación y tokens como `{nombre}`). Aplica esta función ANTES de
/// `aplicarTokens` para no perder la coincidencia.
String traducirNarrativa(String textoEs, Locale? locale) {
  if (locale == null) return textoEs;
  switch (locale.languageCode) {
    case 'eu':
      return narrativaEu[textoEs] ?? narrativaArcoCinco[textoEs]?[0] ?? traduccionesEso[textoEs]?[0] ?? textoEs;
    case 'ca':
      return narrativaCa[textoEs] ?? narrativaArcoCinco[textoEs]?[1] ?? traduccionesEso[textoEs]?[1] ?? textoEs;
    default:
      return textoEs;
  }
}
