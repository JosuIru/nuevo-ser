/// Pieza de queso — cada rueda o porción individual con trazabilidad
/// propia. Entidad persistente análoga a Cepa/Colmena/Arbol en las
/// otras Larrea.
///
/// `numeroPieza` se autogenera como AAAAMMDD-NNN-NN (lote + secuencia
/// dentro del lote). `ubicacionActual` es texto libre (nombre de cava,
/// estantería, zona) para que el quesero organice su afinado como quiera.
class Pieza {
  final int? id;
  final int loteProduccionId;
  final String numeroPieza;
  final double pesoInicial;
  final double? pesoActual;
  final String ubicacionActual;
  final String estado; // afinando / lista / expedida / baja
  final int? fechaExpedicionMs;
  final String notas;
  final int fechaCreacionMs;

  Pieza({
    this.id,
    required this.loteProduccionId,
    required this.numeroPieza,
    this.pesoInicial = 0,
    this.pesoActual,
    this.ubicacionActual = '',
    this.estado = 'afinando',
    this.fechaExpedicionMs,
    this.notas = '',
    required this.fechaCreacionMs,
  });

  /// Días transcurridos desde la creación de la pieza.
  int get edadDias =>
      DateTime.fromMillisecondsSinceEpoch(fechaCreacionMs)
          .difference(DateTime.now())
          .inDays
          .abs();

  /// Pérdida de peso relativa al peso inicial, en porcentaje.
  double? get perdidaPesoPorcentaje {
    if (pesoInicial <= 0 || pesoActual == null) return null;
    return ((pesoInicial - pesoActual!) / pesoInicial) * 100;
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'lote_produccion_id': loteProduccionId,
        'numero_pieza': numeroPieza,
        'peso_inicial': pesoInicial,
        'peso_actual': pesoActual,
        'ubicacion_actual': ubicacionActual,
        'estado': estado,
        'fecha_expedicion_ms': fechaExpedicionMs,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Pieza.fromMap(Map<String, Object?> mapa) => Pieza(
        id: mapa['id'] as int?,
        loteProduccionId: mapa['lote_produccion_id'] as int,
        numeroPieza: mapa['numero_pieza'] as String,
        pesoInicial: (mapa['peso_inicial'] as num?)?.toDouble() ?? 0,
        pesoActual: (mapa['peso_actual'] as num?)?.toDouble(),
        ubicacionActual: (mapa['ubicacion_actual'] as String?) ?? '',
        estado: (mapa['estado'] as String?) ?? 'afinando',
        fechaExpedicionMs: mapa['fecha_expedicion_ms'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
