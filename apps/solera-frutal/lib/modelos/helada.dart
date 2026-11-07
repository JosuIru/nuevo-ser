/// Episodio de helada (o de pedrisco) apuntado por la persona. Sirve de
/// memoria para el siniestro del seguro agrario: la app no lo tramita.
class Helada {
  Helada({
    this.id,
    this.parcelaId,
    required this.fechaMs,
    this.temperaturaMinimaC,
    this.estadoFenologico = '',
    this.danioEstimadoPorcentaje,
    this.esPedrisco = false,
    this.comunicadaAlSeguro = false,
    this.notas = '',
  });

  final int? id;

  /// Null: afecta a toda la explotación.
  final int? parcelaId;
  final int fechaMs;
  final double? temperaturaMinimaC;

  /// Estado en que estaban los árboles (texto o id del catálogo de fenología).
  final String estadoFenologico;
  final double? danioEstimadoPorcentaje;

  /// Pedrisco en vez de helada (el mismo apunte para el seguro).
  final bool esPedrisco;
  final bool comunicadaAlSeguro;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'fecha_ms': fechaMs,
        'temperatura_minima_c': temperaturaMinimaC,
        'estado_fenologico': estadoFenologico,
        'danio_estimado_pct': danioEstimadoPorcentaje,
        'es_pedrisco': esPedrisco ? 1 : 0,
        'comunicada_seguro': comunicadaAlSeguro ? 1 : 0,
        'notas': notas,
      };

  factory Helada.fromMap(Map<String, Object?> mapa) => Helada(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        temperaturaMinimaC: (mapa['temperatura_minima_c'] as num?)?.toDouble(),
        estadoFenologico: (mapa['estado_fenologico'] as String?) ?? '',
        danioEstimadoPorcentaje:
            (mapa['danio_estimado_pct'] as num?)?.toDouble(),
        esPedrisco: (mapa['es_pedrisco'] as int?) == 1,
        comunicadaAlSeguro: (mapa['comunicada_seguro'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
