/// Un riego apuntado en una parcela de regadío.
class Riego {
  Riego({
    this.id,
    required this.parcelaId,
    required this.fechaMs,
    this.volumenM3 = 0,
    this.horas,
    this.origenAgua = '',
    this.notas = '',
  });

  final int? id;
  final int parcelaId;
  final int fechaMs;
  final double volumenM3;
  final double? horas;

  /// Pozo, comunidad de regantes, balsa…
  final String origenAgua;
  final String notas;

  /// Litros por árbol con [arbolesEnParcela] árboles; null si no hay datos.
  double? litrosPorArbol(int arbolesEnParcela) =>
      arbolesEnParcela <= 0 ? null : volumenM3 * 1000 / arbolesEnParcela;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'fecha_ms': fechaMs,
        'volumen_m3': volumenM3,
        'horas': horas,
        'origen_agua': origenAgua,
        'notas': notas,
      };

  factory Riego.fromMap(Map<String, Object?> mapa) => Riego(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        volumenM3: (mapa['volumen_m3'] as num?)?.toDouble() ?? 0,
        horas: (mapa['horas'] as num?)?.toDouble(),
        origenAgua: (mapa['origen_agua'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
