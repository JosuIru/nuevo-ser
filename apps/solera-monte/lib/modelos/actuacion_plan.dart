/// Tipos de actuación del plan de gestión. El señalamiento lo hace el
/// técnico forestal: la app solo lo apunta.
const List<String> tiposActuacion = [
  'clara',
  'clareo',
  'poda',
  'desbroce',
  'corta_regeneracion',
  'corta_final',
  'repoblacion',
  'senalamiento',
  'mantenimiento_pista',
  'mantenimiento_cortafuegos',
  'otra',
];

/// Una actuación prevista en el plan de gestión para un año y un rodal (o
/// para todo el monte si [rodalId] es null).
class ActuacionPlan {
  ActuacionPlan({
    this.id,
    this.rodalId,
    required this.anyoPrevisto,
    required this.tipo,
    this.superficiePrevistaHa,
    this.volumenPrevistoM3,
    this.descripcion = '',
    this.cancelada = false,
  });

  final int? id;
  final int? rodalId;
  final int anyoPrevisto;

  /// Uno de [tiposActuacion].
  final String tipo;
  final double? superficiePrevistaHa;

  /// Volumen de madera o leña que el plan prevé sacar (m³); null si la
  /// actuación no saca producto.
  final double? volumenPrevistoM3;
  final String descripcion;

  /// Descartada por la junta o el técnico (no cuenta como pendiente).
  final bool cancelada;

  Map<String, Object?> toMap() => {
        'id': id,
        'rodal_id': rodalId,
        'anyo_previsto': anyoPrevisto,
        'tipo': tipo,
        'superficie_prevista_ha': superficiePrevistaHa,
        'volumen_previsto_m3': volumenPrevistoM3,
        'descripcion': descripcion,
        'cancelada': cancelada ? 1 : 0,
      };

  factory ActuacionPlan.fromMap(Map<String, Object?> mapa) => ActuacionPlan(
        id: mapa['id'] as int?,
        rodalId: mapa['rodal_id'] as int?,
        anyoPrevisto: mapa['anyo_previsto'] as int,
        tipo: tiposActuacion.contains(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'otra',
        superficiePrevistaHa:
            (mapa['superficie_prevista_ha'] as num?)?.toDouble(),
        volumenPrevistoM3: (mapa['volumen_previsto_m3'] as num?)?.toDouble(),
        descripcion: (mapa['descripcion'] as String?) ?? '',
        cancelada: (mapa['cancelada'] as int?) == 1,
      );
}
