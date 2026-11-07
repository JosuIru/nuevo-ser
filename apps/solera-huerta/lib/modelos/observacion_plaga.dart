/// Observación de una plaga, enfermedad o carencia en un bancal (muestreo).
///
/// Sirve de registro de que hacía falta actuar antes de usar un
/// fitosanitario (Reglamento (UE) 2018/848, anexo II, parte I, 1.10.2) y es
/// lo que propone la IA del bloque 7: una observación, nunca un tratamiento.
class ObservacionPlaga {
  ObservacionPlaga({
    this.id,
    required this.bancalId,
    required this.fechaMs,
    required this.plagaId,
    this.cultivoId,
    this.notas = '',
  });

  final int? id;
  final int bancalId;
  final int? cultivoId;
  final int fechaMs;

  /// Id del catálogo de plagas o texto libre.
  final String plagaId;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'bancal_id': bancalId,
        'cultivo_id': cultivoId,
        'fecha_ms': fechaMs,
        'plaga_id': plagaId,
        'notas': notas,
      };

  factory ObservacionPlaga.fromMap(Map<String, Object?> mapa) =>
      ObservacionPlaga(
        id: mapa['id'] as int?,
        bancalId: mapa['bancal_id'] as int,
        cultivoId: mapa['cultivo_id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        plagaId: (mapa['plaga_id'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
