/// A dónde va la cosecha.
const List<String> destinosCosecha = [
  'cestas',
  'mercado',
  'restaurante',
  'autoconsumo',
  'semilla',
  'otros',
];

/// Una pasada de cosecha de un cultivo en un bancal.
class Cosecha {
  Cosecha({
    this.id,
    required this.bancalId,
    required this.cultivoId,
    required this.fechaMs,
    this.siembraId,
    this.kg = 0,
    this.unidades,
    this.destino = 'cestas',
    this.loteCosecha = '',
    this.notas = '',
  });

  final int? id;
  final int bancalId;
  final int cultivoId;

  /// La siembra de la que sale, si se sabe.
  final int? siembraId;
  final int fechaMs;
  final double kg;

  /// Piezas (lechugas, manojos, coles) si se cuenta por unidades.
  final int? unidades;

  /// Uno de [destinosCosecha].
  final String destino;

  /// Código de lote para la trazabilidad de la venta.
  final String loteCosecha;
  final String notas;

  bool get porUnidades => unidades != null && unidades! > 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'bancal_id': bancalId,
        'cultivo_id': cultivoId,
        'siembra_id': siembraId,
        'fecha_ms': fechaMs,
        'kg': kg,
        'unidades': unidades,
        'destino': destino,
        'lote_cosecha': loteCosecha,
        'notas': notas,
      };

  factory Cosecha.fromMap(Map<String, Object?> mapa) => Cosecha(
        id: mapa['id'] as int?,
        bancalId: mapa['bancal_id'] as int,
        cultivoId: mapa['cultivo_id'] as int,
        siembraId: mapa['siembra_id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        kg: (mapa['kg'] as num?)?.toDouble() ?? 0,
        unidades: mapa['unidades'] as int?,
        destino: (mapa['destino'] as String?) ?? 'cestas',
        loteCosecha: (mapa['lote_cosecha'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
