/// Cómo se puso el material en la bandeja.
const List<String> metodosSiembra = ['siembra', 'estaquillado', 'injerto'];

/// Siembra (o estaquillado) de un lote de material en una bandeja. De ella
/// nace la partida de planta.
class Siembra {
  Siembra({
    this.id,
    required this.loteMaterialId,
    required this.bandejaId,
    required this.fechaMs,
    this.metodo = 'siembra',
    this.alveolosOcupados = 0,
    this.unidadesPorAlveolo = 1,
    this.cantidadMaterialUsada = 0,
    this.notas = '',
  });

  final int? id;
  final int loteMaterialId;
  final int bandejaId;
  final int fechaMs;

  /// Uno de [metodosSiembra].
  final String metodo;
  final int alveolosOcupados;
  final int unidadesPorAlveolo;

  /// En la unidad del lote (g de semilla, esquejes…).
  final double cantidadMaterialUsada;
  final String notas;

  /// Semillas o esquejes puestos en total.
  int get unidadesPuestas => alveolosOcupados * unidadesPorAlveolo;

  Map<String, Object?> toMap() => {
        'id': id,
        'lote_material_id': loteMaterialId,
        'bandeja_id': bandejaId,
        'fecha_ms': fechaMs,
        'metodo': metodo,
        'alveolos_ocupados': alveolosOcupados,
        'unidades_por_alveolo': unidadesPorAlveolo,
        'cantidad_material_usada': cantidadMaterialUsada,
        'notas': notas,
      };

  factory Siembra.fromMap(Map<String, Object?> mapa) => Siembra(
        id: mapa['id'] as int?,
        loteMaterialId: mapa['lote_material_id'] as int,
        bandejaId: mapa['bandeja_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        metodo: (mapa['metodo'] as String?) ?? 'siembra',
        alveolosOcupados: (mapa['alveolos_ocupados'] as int?) ?? 0,
        unidadesPorAlveolo: (mapa['unidades_por_alveolo'] as int?) ?? 1,
        cantidadMaterialUsada:
            (mapa['cantidad_material_usada'] as num?)?.toDouble() ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
