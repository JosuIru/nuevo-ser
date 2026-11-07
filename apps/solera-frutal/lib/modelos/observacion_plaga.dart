/// Seguimiento de una plaga o enfermedad en una parcela: lo que se vio en
/// el muestreo. Si supera o no el umbral lo decide la persona (o su
/// asesor) con la guía de gestión integrada; la app solo lo apunta.
class ObservacionPlaga {
  ObservacionPlaga({
    this.id,
    required this.parcelaId,
    required this.fechaMs,
    required this.plagaId,
    this.recuento,
    this.superaUmbral = false,
    this.notas = '',
  });

  final int? id;
  final int parcelaId;
  final int fechaMs;

  /// Id del catálogo de plagas o texto libre.
  final String plagaId;

  /// Capturas en trampa, % de órganos afectados… (la unidad va en notas).
  final double? recuento;
  final bool superaUmbral;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'fecha_ms': fechaMs,
        'plaga_id': plagaId,
        'recuento': recuento,
        'supera_umbral': superaUmbral ? 1 : 0,
        'notas': notas,
      };

  factory ObservacionPlaga.fromMap(Map<String, Object?> mapa) =>
      ObservacionPlaga(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        plagaId: (mapa['plaga_id'] as String?) ?? '',
        recuento: (mapa['recuento'] as num?)?.toDouble(),
        superaUmbral: (mapa['supera_umbral'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
