/// Cómo entra el cultivo en el bancal. La «Plantacion» de la ficha es una
/// [Siembra] de tipo `plantacion` (trasplante de plantel): comparten todos
/// los campos y la rotación las trata igual.
const List<String> tiposSiembra = [
  'siembra_directa',
  'semillero',
  'plantacion'
];

/// Unidades en que se apunta la cantidad sembrada o plantada.
const List<String> unidadesSiembra = ['plantas', 'gramos', 'metros_lineales'];

/// Siembra o plantación de un cultivo en un bancal, planificada o hecha.
///
/// Una siembra **planificada** solo tiene fecha prevista; al hacerla se
/// apunta la real. Las siembras escalonadas comparten [serieEscalonada].
class Siembra {
  Siembra({
    this.id,
    required this.bancalId,
    required this.cultivoId,
    required this.fechaPrevistaMs,
    this.tipo = 'siembra_directa',
    this.fechaRealMs,
    this.loteSemillaId,
    this.cantidad,
    this.unidad = 'plantas',
    this.superficieM2,
    this.inicioCosechaPrevistaMs,
    this.kgPrevistos,
    this.fechaLevantadaMs,
    this.serieEscalonada = '',
    this.notas = '',
  });

  final int? id;
  final int bancalId;
  final int cultivoId;

  /// Uno de [tiposSiembra].
  final String tipo;
  final int fechaPrevistaMs;

  /// Null mientras está solo planificada.
  final int? fechaRealMs;
  final int? loteSemillaId;
  final double? cantidad;

  /// Uno de [unidadesSiembra].
  final String unidad;
  final double? superficieM2;

  /// Primer día de cosecha previsto. Si es null, se calcula con el ciclo
  /// del catálogo (ver `prevision_cosecha.dart`).
  final int? inicioCosechaPrevistaMs;

  /// Kilos que se espera cosechar en total (para prever las cestas).
  final double? kgPrevistos;

  /// Día en que se levantó el cultivo y el bancal quedó libre.
  final int? fechaLevantadaMs;

  /// Identificador común de una serie de siembras escalonadas.
  final String serieEscalonada;
  final String notas;

  bool get realizada => fechaRealMs != null;

  /// La fecha que cuenta: la real si la hay; si no, la prevista.
  int get fechaReferenciaMs => fechaRealMs ?? fechaPrevistaMs;

  Siembra copiar({int? fechaRealMs, int? fechaLevantadaMs}) => Siembra(
        id: id,
        bancalId: bancalId,
        cultivoId: cultivoId,
        tipo: tipo,
        fechaPrevistaMs: fechaPrevistaMs,
        fechaRealMs: fechaRealMs ?? this.fechaRealMs,
        loteSemillaId: loteSemillaId,
        cantidad: cantidad,
        unidad: unidad,
        superficieM2: superficieM2,
        inicioCosechaPrevistaMs: inicioCosechaPrevistaMs,
        kgPrevistos: kgPrevistos,
        fechaLevantadaMs: fechaLevantadaMs ?? this.fechaLevantadaMs,
        serieEscalonada: serieEscalonada,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'bancal_id': bancalId,
        'cultivo_id': cultivoId,
        'tipo': tipo,
        'fecha_prevista_ms': fechaPrevistaMs,
        'fecha_real_ms': fechaRealMs,
        'lote_semilla_id': loteSemillaId,
        'cantidad': cantidad,
        'unidad': unidad,
        'superficie_m2': superficieM2,
        'inicio_cosecha_prevista_ms': inicioCosechaPrevistaMs,
        'kg_previstos': kgPrevistos,
        'fecha_levantada_ms': fechaLevantadaMs,
        'serie_escalonada': serieEscalonada,
        'notas': notas,
      };

  factory Siembra.fromMap(Map<String, Object?> mapa) => Siembra(
        id: mapa['id'] as int?,
        bancalId: mapa['bancal_id'] as int,
        cultivoId: mapa['cultivo_id'] as int,
        tipo: (mapa['tipo'] as String?) ?? 'siembra_directa',
        fechaPrevistaMs: mapa['fecha_prevista_ms'] as int,
        fechaRealMs: mapa['fecha_real_ms'] as int?,
        loteSemillaId: mapa['lote_semilla_id'] as int?,
        cantidad: (mapa['cantidad'] as num?)?.toDouble(),
        unidad: (mapa['unidad'] as String?) ?? 'plantas',
        superficieM2: (mapa['superficie_m2'] as num?)?.toDouble(),
        inicioCosechaPrevistaMs: mapa['inicio_cosecha_prevista_ms'] as int?,
        kgPrevistos: (mapa['kg_previstos'] as num?)?.toDouble(),
        fechaLevantadaMs: mapa['fecha_levantada_ms'] as int?,
        serieEscalonada: (mapa['serie_escalonada'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
