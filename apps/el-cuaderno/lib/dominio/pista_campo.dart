/// Pista de campo abierta — una invitación corta a observar algo
/// concreto del lugar real del niño. Garantiza que el home siempre
/// tenga algo que proponer aunque el catálogo de Misterios filtrado
/// por estación + región esté vacío (decisión 2026-05-20 con el
/// operador, ver memoria `project_el_cuaderno_decisiones_humanas_pendientes`).
///
/// Las pistas son **abiertas**: no se cierran, no se anclan a
/// evidencia, no llevan estado. Son texto puro pensado para
/// despertar la atención del niño hacia su entorno inmediato sin
/// necesidad de catálogo curado por el comité científico. La
/// pedagogía sigue siendo "observar antes que interpretar" — solo
/// que aquí no hay pregunta sostenida detrás, solo invitación.
///
/// Traducciones eu/ca BORRADOR (B2) — el operador las redacta junto
/// a la pista en castellano; pendientes de revisión por hablantes
/// nativos con criterio terminológico naturalista.
class PistaCampo {
  const PistaCampo({
    required this.id,
    required this.texto,
    this.traducciones = const <String, String>{},
  });

  final String id;

  /// Texto canónico en castellano.
  final String texto;

  /// Traducciones BORRADOR por código de locale ('eu', 'ca'). Si el
  /// locale activo no está en el mapa, se cae al castellano.
  final Map<String, String> traducciones;

  /// Devuelve el texto en el locale solicitado, con fallback al
  /// castellano. `null` o vacío vuelve al castellano.
  String textoEnLocale(String? codigoLocale) {
    if (codigoLocale == null || codigoLocale.isEmpty) return texto;
    return traducciones[codigoLocale] ?? texto;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'texto': texto,
        if (traducciones.isNotEmpty) 'traducciones': traducciones,
      };

  static PistaCampo fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final texto = json['texto'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('PistaCampo: campo "id" obligatorio y no vacío');
    }
    if (texto is! String || texto.isEmpty) {
      throw const FormatException(
        'PistaCampo: campo "texto" obligatorio y no vacío',
      );
    }
    final crudoTraducciones = json['traducciones'];
    final traducciones = <String, String>{};
    if (crudoTraducciones is Map) {
      for (final entry in crudoTraducciones.entries) {
        if (entry.key is String && entry.value is String) {
          traducciones[entry.key as String] = entry.value as String;
        }
      }
    }
    return PistaCampo(id: id, texto: texto, traducciones: traducciones);
  }

  @override
  bool operator ==(Object other) =>
      other is PistaCampo &&
      other.id == id &&
      other.texto == texto &&
      _mapsIguales(other.traducciones, traducciones);

  @override
  int get hashCode => Object.hash(id, texto, traducciones.length);

  static bool _mapsIguales(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
