/// Tipos de tarea del calendario sanitario.
const List<String> tiposTareaSanitaria = [
  'saneamiento',
  'desparasitacion',
  'vacunacion',
  'revision',
  'otro',
];

/// Una tarea del calendario sanitario que **planifica el veterinario**
/// (saneamiento, desparasitación…). La app no propone ninguna: solo recuerda
/// las que se apuntan.
class TareaSanitaria {
  TareaSanitaria({
    this.id,
    required this.titulo,
    this.tipo = 'saneamiento',
    this.loteId,
    required this.fechaPrevistaMs,
    this.hechaMs,
    this.notas = '',
  });

  final int? id;
  final String titulo;

  /// Código de [tiposTareaSanitaria].
  final String tipo;

  /// Rebaño al que se refiere; null = toda la explotación.
  final int? loteId;
  final int fechaPrevistaMs;

  /// Cuándo se hizo; null = pendiente.
  final int? hechaMs;
  final String notas;

  bool get pendiente => hechaMs == null;

  TareaSanitaria marcarHecha(int fechaMs) => TareaSanitaria(
        id: id,
        titulo: titulo,
        tipo: tipo,
        loteId: loteId,
        fechaPrevistaMs: fechaPrevistaMs,
        hechaMs: fechaMs,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'titulo': titulo,
        'tipo': tipo,
        'lote_id': loteId,
        'fecha_prevista_ms': fechaPrevistaMs,
        'hecha_ms': hechaMs,
        'notas': notas,
      };

  factory TareaSanitaria.fromMap(Map<String, Object?> mapa) => TareaSanitaria(
        id: mapa['id'] as int?,
        titulo: (mapa['titulo'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'saneamiento',
        loteId: mapa['lote_id'] as int?,
        fechaPrevistaMs: (mapa['fecha_prevista_ms'] as num?)?.toInt() ?? 0,
        hechaMs: (mapa['hecha_ms'] as num?)?.toInt(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
