/// Lote de un ingrediente recibido (trazabilidad «un paso atrás»).
class LoteIngrediente {
  LoteIngrediente({
    this.id,
    required this.ingredienteId,
    required this.codigoLote,
    required this.fechaRecepcionMs,
    this.consumoPreferenteMs,
    this.cantidadKg = 0,
    this.temperaturaRecepcionC,
    this.notas = '',
  });

  final int? id;
  final int ingredienteId;
  final String codigoLote;
  final int fechaRecepcionMs;
  final int? consumoPreferenteMs;
  final double cantidadKg;
  final double? temperaturaRecepcionC;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'ingrediente_id': ingredienteId,
        'codigo_lote': codigoLote,
        'fecha_recepcion_ms': fechaRecepcionMs,
        'consumo_preferente_ms': consumoPreferenteMs,
        'cantidad_kg': cantidadKg,
        'temperatura_recepcion_c': temperaturaRecepcionC,
        'notas': notas,
      };

  factory LoteIngrediente.fromMap(Map<String, Object?> mapa) => LoteIngrediente(
        id: mapa['id'] as int?,
        ingredienteId: mapa['ingrediente_id'] as int,
        codigoLote: mapa['codigo_lote'] as String,
        fechaRecepcionMs: mapa['fecha_recepcion_ms'] as int,
        consumoPreferenteMs: mapa['consumo_preferente_ms'] as int?,
        cantidadKg: ((mapa['cantidad_kg'] as num?) ?? 0).toDouble(),
        temperaturaRecepcionC:
            (mapa['temperatura_recepcion_c'] as num?)?.toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
