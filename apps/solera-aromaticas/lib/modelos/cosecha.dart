/// Estados fenológicos que se apuntan en la cosecha (la planta y su
/// aceite cambian mucho según el momento de la floración).
const List<String> estadosFenologicosCosecha = [
  'vegetativo',
  'inicio_floracion',
  'plena_floracion',
  'final_floracion',
  'fructificacion',
];

/// Cosecha de una parcela de cultivo **o** recolección en una zona
/// silvestre (exactamente uno de los dos orígenes).
class Cosecha {
  Cosecha({
    this.id,
    this.parcelaId,
    this.zonaRecoleccionId,
    required this.especieId,
    required this.fechaMs,
    this.kgFrescos = 0,
    this.estadoFenologico = '',
    this.parteRecolectada = '',
    this.recolector = '',
    this.notas = '',
  }) : assert((parcelaId == null) != (zonaRecoleccionId == null),
            'una cosecha viene de una parcela o de una zona, no de las dos');

  final int? id;
  final int? parcelaId;
  final int? zonaRecoleccionId;

  /// Id del catálogo de especies o nombre libre.
  final String especieId;
  final int fechaMs;
  final double kgFrescos;

  /// Uno de [estadosFenologicosCosecha] o vacío.
  final String estadoFenologico;

  /// Parte de la planta: sumidad florida, hoja, flor… (texto libre).
  final String parteRecolectada;

  /// Persona que recolecta (en silvestre, quien figura en el permiso).
  final String recolector;
  final String notas;

  bool get esSilvestre => zonaRecoleccionId != null;

  /// Campaña = año natural de la fecha.
  int get campania => DateTime.fromMillisecondsSinceEpoch(fechaMs).year;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'zona_recoleccion_id': zonaRecoleccionId,
        'especie_id': especieId,
        'fecha_ms': fechaMs,
        'kg_frescos': kgFrescos,
        'estado_fenologico': estadoFenologico,
        'parte_recolectada': parteRecolectada,
        'recolector': recolector,
        'notas': notas,
      };

  factory Cosecha.fromMap(Map<String, Object?> mapa) => Cosecha(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int?,
        zonaRecoleccionId: mapa['zona_recoleccion_id'] as int?,
        especieId: (mapa['especie_id'] as String?) ?? '',
        fechaMs: mapa['fecha_ms'] as int,
        kgFrescos: (mapa['kg_frescos'] as num?)?.toDouble() ?? 0,
        estadoFenologico: (mapa['estado_fenologico'] as String?) ?? '',
        parteRecolectada: (mapa['parte_recolectada'] as String?) ?? '',
        recolector: (mapa['recolector'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
