/// Repicado (o trasplante a otro formato): pasa plantas de una partida a
/// otra nueva, en otra bandeja o en maceta. Queda el eslabón para la
/// trazabilidad.
class Repicado {
  Repicado({
    this.id,
    required this.partidaOrigenId,
    required this.partidaDestinoId,
    required this.fechaMs,
    required this.cantidad,
    this.notas = '',
  });

  final int? id;
  final int partidaOrigenId;
  final int partidaDestinoId;
  final int fechaMs;

  /// Plantas que salen de la partida de origen.
  final int cantidad;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'partida_origen_id': partidaOrigenId,
        'partida_destino_id': partidaDestinoId,
        'fecha_ms': fechaMs,
        'cantidad': cantidad,
        'notas': notas,
      };

  factory Repicado.fromMap(Map<String, Object?> mapa) => Repicado(
        id: mapa['id'] as int?,
        partidaOrigenId: mapa['partida_origen_id'] as int,
        partidaDestinoId: mapa['partida_destino_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        cantidad: (mapa['cantidad'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
