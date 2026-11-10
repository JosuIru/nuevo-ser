import '../dominio/planificador_hornada.dart';

/// Una hornada planificada hacia atrás: las fases con sus horas, tal como
/// se calcularon (y se movieron al marcarlas hechas).
class PlanHornada {
  PlanHornada({
    this.id,
    required this.nombre,
    this.recetaId,
    this.recetaGuiaId = '',
    required this.listoMs,
    required this.temperaturaCocinaC,
    required this.fases,
    this.avisosProgramados = false,
    this.terminado = false,
    required this.creadoMs,
  });

  final int? id;

  /// Nombre de la receta al planificar (la receta puede borrarse después).
  final String nombre;
  final int? recetaId;

  /// Id de la receta de la guía (`rustico`…), vacío si es una propia.
  final String recetaGuiaId;
  final int listoMs;
  final double temperaturaCocinaC;
  final List<FasePlanificada> fases;
  final bool avisosProgramados;
  final bool terminado;
  final int creadoMs;

  PlanHornada copiar({
    int? id,
    List<FasePlanificada>? fases,
    bool? avisosProgramados,
    bool? terminado,
  }) =>
      PlanHornada(
        id: id ?? this.id,
        nombre: nombre,
        recetaId: recetaId,
        recetaGuiaId: recetaGuiaId,
        listoMs: listoMs,
        temperaturaCocinaC: temperaturaCocinaC,
        fases: fases ?? this.fases,
        avisosProgramados: avisosProgramados ?? this.avisosProgramados,
        terminado: terminado ?? this.terminado,
        creadoMs: creadoMs,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'receta_id': recetaId,
        'receta_guia_id': recetaGuiaId,
        'listo_ms': listoMs,
        'temperatura_cocina_c': temperaturaCocinaC,
        'fases_json': fasesAJson(fases),
        'avisos_programados': avisosProgramados ? 1 : 0,
        'terminado': terminado ? 1 : 0,
        'creado_ms': creadoMs,
      };

  factory PlanHornada.fromMap(Map<String, Object?> mapa) => PlanHornada(
        id: mapa['id'] as int?,
        nombre: mapa['nombre'] as String,
        recetaId: mapa['receta_id'] as int?,
        recetaGuiaId: (mapa['receta_guia_id'] as String?) ?? '',
        listoMs: mapa['listo_ms'] as int,
        temperaturaCocinaC: (mapa['temperatura_cocina_c'] as num).toDouble(),
        fases: fasesDeJson(mapa['fases_json'] as String),
        avisosProgramados: (mapa['avisos_programados'] as int?) == 1,
        terminado: (mapa['terminado'] as int?) == 1,
        creadoMs: mapa['creado_ms'] as int,
      );
}
