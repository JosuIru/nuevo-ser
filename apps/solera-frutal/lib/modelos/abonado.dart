/// Formas de aportar el abono.
const List<String> metodosAbonado = [
  'fondo',
  'cobertera',
  'fertirrigacion',
  'foliar',
];

/// Abonado o enmienda aplicada en una parcela (apartado de fertilización
/// del cuaderno de explotación).
class Abonado {
  Abonado({
    this.id,
    required this.parcelaId,
    required this.fechaMs,
    required this.tipoAbono,
    this.riquezaNpk = '',
    this.cantidadKgPorHa = 0,
    this.metodo = 'fondo',
    this.superficieHa = 0,
    this.notas = '',
  });

  final int? id;
  final int parcelaId;
  final int fechaMs;

  /// Lo que pone el saco o el albarán: «estiércol de oveja», «15-15-15»…
  final String tipoAbono;

  /// Riqueza N-P-K tal como figura (texto, p. ej. «8-4-12»).
  final String riquezaNpk;
  final double cantidadKgPorHa;

  /// Uno de [metodosAbonado].
  final String metodo;
  final double superficieHa;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'fecha_ms': fechaMs,
        'tipo_abono': tipoAbono,
        'riqueza_npk': riquezaNpk,
        'cantidad_kg_ha': cantidadKgPorHa,
        'metodo': metodo,
        'superficie_ha': superficieHa,
        'notas': notas,
      };

  factory Abonado.fromMap(Map<String, Object?> mapa) => Abonado(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        tipoAbono: (mapa['tipo_abono'] as String?) ?? '',
        riquezaNpk: (mapa['riqueza_npk'] as String?) ?? '',
        cantidadKgPorHa: (mapa['cantidad_kg_ha'] as num?)?.toDouble() ?? 0,
        metodo: (mapa['metodo'] as String?) ?? 'fondo',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble() ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
