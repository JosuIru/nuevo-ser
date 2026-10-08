/// Noticia de fuera del espacio (administración, sindicatos agrarios,
/// prensa del sector…) que el servidor lee de los canales RSS que da de
/// alta coordinación en el panel. Solo titular, entradilla y enlace al
/// original; no se guarda en la base de datos ni se sincroniza: llega con
/// `GET /noticias` y se guarda en caché para verla sin cobertura.
class NoticiaSector {
  const NoticiaSector({
    required this.id,
    required this.titulo,
    required this.enlace,
    required this.fechaMs,
    this.entradilla = '',
    this.fuente = '',
    this.idioma = 'es',
    this.fijada = false,
  });

  final int id;
  final String titulo;
  final String entradilla;
  final String enlace;
  final int fechaMs;

  /// Nombre del canal del que viene (p. ej. «UAGN»).
  final String fuente;

  /// `es`, `eu` o `mixto`, según el canal.
  final String idioma;

  /// Coordinación la ha fijado arriba.
  final bool fijada;

  /// `null` si le falta lo imprescindible o el enlace no es web.
  static NoticiaSector? desdeJson(Map<Object?, Object?> json) {
    final titulo = json['titulo'];
    final enlace = json['enlace'];
    if (titulo is! String || titulo.isEmpty || enlace is! String) return null;
    final uri = Uri.tryParse(enlace);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return NoticiaSector(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: titulo,
      entradilla: (json['entradilla'] as String?) ?? '',
      enlace: enlace,
      fechaMs: (json['fecha_ms'] as num?)?.toInt() ?? 0,
      fuente: (json['fuente'] as String?) ?? '',
      idioma: (json['idioma'] as String?) ?? 'es',
      fijada: json['fijada'] == true,
    );
  }

  Map<String, Object?> aJson() => {
        'id': id,
        'titulo': titulo,
        'entradilla': entradilla,
        'enlace': enlace,
        'fecha_ms': fechaMs,
        'fuente': fuente,
        'idioma': idioma,
        'fijada': fijada,
      };
}
