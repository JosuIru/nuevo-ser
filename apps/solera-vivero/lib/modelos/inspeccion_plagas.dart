/// Quién hizo la inspección.
const List<String> tiposInspeccion = ['autoinspeccion', 'oficial'];

/// Resultado de la inspección para la plaga.
const List<String> resultadosInspeccion = [
  'no_detectada',
  'sospecha',
  'detectada',
];

/// Inspección de plagas reguladas (cuarentenarias y RNQP) sobre una
/// partida o una zona. El operador autorizado está obligado a
/// autoinspeccionar y a avisar de inmediato a la autoridad si sospecha una
/// cuarentenaria (RD 1054/2021, art. 22.2).
///
/// La app **no da por sana una partida**: guarda lo que vio la persona o el
/// inspector, con su resultado.
class InspeccionPlagas {
  InspeccionPlagas({
    this.id,
    required this.fechaMs,
    this.partidaId,
    this.zonaId,
    required this.plagaId,
    this.tipo = 'autoinspeccion',
    this.inspectorNombre = '',
    this.resultado = 'no_detectada',
    this.muestraTomada = false,
    this.notificadaAutoridad = false,
    this.notas = '',
  });

  final int? id;
  final int fechaMs;
  final int? partidaId;
  final int? zonaId;

  /// Id del catálogo de plagas reguladas o texto libre.
  final String plagaId;

  /// Uno de [tiposInspeccion].
  final String tipo;
  final String inspectorNombre;

  /// Uno de [resultadosInspeccion].
  final String resultado;
  final bool muestraTomada;
  final bool notificadaAutoridad;
  final String notas;

  /// Hay sospecha o detección y todavía no se ha avisado a la autoridad.
  bool get pendienteDeNotificar =>
      resultado != 'no_detectada' && !notificadaAutoridad;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'partida_id': partidaId,
        'zona_id': zonaId,
        'plaga_id': plagaId,
        'tipo': tipo,
        'inspector_nombre': inspectorNombre,
        'resultado': resultado,
        'muestra_tomada': muestraTomada ? 1 : 0,
        'notificada_autoridad': notificadaAutoridad ? 1 : 0,
        'notas': notas,
      };

  factory InspeccionPlagas.fromMap(Map<String, Object?> mapa) =>
      InspeccionPlagas(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        partidaId: mapa['partida_id'] as int?,
        zonaId: mapa['zona_id'] as int?,
        plagaId: (mapa['plaga_id'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'autoinspeccion',
        inspectorNombre: (mapa['inspector_nombre'] as String?) ?? '',
        resultado: (mapa['resultado'] as String?) ?? 'no_detectada',
        muestraTomada: (mapa['muestra_tomada'] as int?) == 1,
        notificadaAutoridad: (mapa['notificada_autoridad'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
