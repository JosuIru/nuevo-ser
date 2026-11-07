/// Producción de una receta en un día: el lote del producto acabado.
class Hornada {
  Hornada({
    this.id,
    required this.recetaId,
    required this.fechaMs,
    required this.piezas,
    required this.codigoLote,
    this.temperaturaHornoC,
    this.minutosHorno,
    this.responsable = '',
    this.notas = '',
  });

  final int? id;
  final int recetaId;
  final int fechaMs;
  final int piezas;
  final String codigoLote;
  final double? temperaturaHornoC;
  final int? minutosHorno;
  final String responsable;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'receta_id': recetaId,
        'fecha_ms': fechaMs,
        'piezas': piezas,
        'codigo_lote': codigoLote,
        'temperatura_horno_c': temperaturaHornoC,
        'minutos_horno': minutosHorno,
        'responsable': responsable,
        'notas': notas,
      };

  factory Hornada.fromMap(Map<String, Object?> mapa) => Hornada(
        id: mapa['id'] as int?,
        recetaId: mapa['receta_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        piezas: mapa['piezas'] as int,
        codigoLote: mapa['codigo_lote'] as String,
        temperaturaHornoC: (mapa['temperatura_horno_c'] as num?)?.toDouble(),
        minutosHorno: mapa['minutos_horno'] as int?,
        responsable: (mapa['responsable'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Código de lote por defecto de una hornada: `AAAAMMDD-<receta>-<n>`.
String codigoLoteHornada(DateTime fecha, int recetaId, int numeroDelDia) {
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${fecha.year}${dos(fecha.month)}${dos(fecha.day)}'
      '-$recetaId-$numeroDelDia';
}
