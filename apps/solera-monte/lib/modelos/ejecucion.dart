import 'actuacion_plan.dart';

/// Lo que se ha hecho de verdad. Puede cumplir una actuación del plan
/// ([actuacionPlanId]) o ser una actuación no prevista (null).
class Ejecucion {
  Ejecucion({
    this.id,
    this.actuacionPlanId,
    this.rodalId,
    required this.fechaMs,
    required this.tipo,
    this.superficieHa,
    this.ejecutor = '',
    this.completa = true,
    this.notas = '',
  });

  final int? id;
  final int? actuacionPlanId;
  final int? rodalId;
  final int fechaMs;

  /// Uno de [tiposActuacion].
  final String tipo;
  final double? superficieHa;

  /// Quién la hizo (vecinos en vereda, empresa, cuadrilla…).
  final String ejecutor;

  /// false = hecha en parte (la actuación del plan sigue abierta).
  final bool completa;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'actuacion_plan_id': actuacionPlanId,
        'rodal_id': rodalId,
        'fecha_ms': fechaMs,
        'tipo': tipo,
        'superficie_ha': superficieHa,
        'ejecutor': ejecutor,
        'completa': completa ? 1 : 0,
        'notas': notas,
      };

  factory Ejecucion.fromMap(Map<String, Object?> mapa) => Ejecucion(
        id: mapa['id'] as int?,
        actuacionPlanId: mapa['actuacion_plan_id'] as int?,
        rodalId: mapa['rodal_id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        tipo: tiposActuacion.contains(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'otra',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble(),
        ejecutor: (mapa['ejecutor'] as String?) ?? '',
        completa: (mapa['completa'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
