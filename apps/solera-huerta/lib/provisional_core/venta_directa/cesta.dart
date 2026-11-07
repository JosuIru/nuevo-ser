// PROVISIONAL CORE — módulo transversal T2 (venta directa). Ver socio.dart.

/// Estados de una cesta antes de entregarla (la entrega va en [Entrega]).
const List<String> estadosCesta = ['prevista', 'preparada'];

/// Cesta de una suscripción en una semana.
class Cesta {
  Cesta({
    this.id,
    required this.suscripcionId,
    required this.semanaLunesMs,
    this.estado = 'prevista',
    this.notas = '',
  });

  final int? id;
  final int suscripcionId;

  /// Lunes de la semana (ver `lunesDeSemana`). Una cesta por suscripción y
  /// semana (UNIQUE en la BD).
  final int semanaLunesMs;

  /// Uno de [estadosCesta].
  final String estado;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'suscripcion_id': suscripcionId,
        'semana_lunes_ms': semanaLunesMs,
        'estado': estado,
        'notas': notas,
      };

  factory Cesta.fromMap(Map<String, Object?> mapa) => Cesta(
        id: mapa['id'] as int?,
        suscripcionId: mapa['suscripcion_id'] as int,
        semanaLunesMs: mapa['semana_lunes_ms'] as int,
        estado: (mapa['estado'] as String?) ?? 'prevista',
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Lo que lleva una cesta de un cultivo: kilos o piezas.
class LineaCesta {
  LineaCesta({
    this.id,
    required this.cestaId,
    required this.cultivoId,
    this.kg = 0,
    this.unidades,
  });

  final int? id;
  final int cestaId;
  final int cultivoId;
  final double kg;

  /// Piezas, si el cultivo se reparte por unidades (lechugas, manojos).
  final int? unidades;

  bool get porUnidades => unidades != null;

  Map<String, Object?> toMap() => {
        'id': id,
        'cesta_id': cestaId,
        'cultivo_id': cultivoId,
        'kg': kg,
        'unidades': unidades,
      };

  factory LineaCesta.fromMap(Map<String, Object?> mapa) => LineaCesta(
        id: mapa['id'] as int?,
        cestaId: mapa['cesta_id'] as int,
        cultivoId: mapa['cultivo_id'] as int,
        kg: (mapa['kg'] as num?)?.toDouble() ?? 0,
        unidades: mapa['unidades'] as int?,
      );
}
