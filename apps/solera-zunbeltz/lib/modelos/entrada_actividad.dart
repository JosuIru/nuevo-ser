/// Una entrada del registro de actividad del espacio, tal como la escribe
/// el servidor al aceptar un cambio («Ane ha movido Corral móvil en
/// Zunbeltz»). Solo la recibe quien tiene la capacidad `ver_actividad`.
class EntradaActividad {
  const EntradaActividad({
    required this.id,
    required this.momentoMs,
    this.personaUid = '',
    this.personaNombre = '',
    this.accion = '',
    this.tipo = '',
    this.uid = '',
    this.etiqueta = '',
    this.contexto = '',
    this.detalle = '',
    this.origen = 'app',
  });

  /// Id del servidor: cursor de la sincronización de actividad.
  final int id;
  final int momentoMs;
  final String personaUid;
  final String personaNombre;

  /// `crear` · `editar` · `borrar` · `mover` · `estado` · `asignar`.
  final String accion;

  /// Tipo de lo afectado (`tarea`, `punto`, `apunte`…).
  final String tipo;
  final String uid;

  /// Nombre de lo afectado (título de la tarea, nombre del punto…).
  final String etiqueta;

  /// Finca o proyecto donde ocurre.
  final String contexto;

  /// Nuevo estado de una tarea, persona asignada…
  final String detalle;

  /// `app` o `panel` (escritorio de WordPress).
  final String origen;

  Map<String, Object?> toMap() => {
        'id': id,
        'momento_ms': momentoMs,
        'persona_uid': personaUid,
        'persona_nombre': personaNombre,
        'accion': accion,
        'tipo': tipo,
        'uid': uid,
        'etiqueta': etiqueta,
        'contexto': contexto,
        'detalle': detalle,
        'origen': origen,
      };

  factory EntradaActividad.fromMap(Map<String, Object?> mapa) =>
      EntradaActividad(
        id: (mapa['id'] as num?)?.toInt() ?? 0,
        momentoMs: (mapa['momento_ms'] as num?)?.toInt() ?? 0,
        personaUid: (mapa['persona_uid'] as String?) ?? '',
        personaNombre: (mapa['persona_nombre'] as String?) ?? '',
        accion: (mapa['accion'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? '',
        uid: (mapa['uid'] as String?) ?? '',
        etiqueta: (mapa['etiqueta'] as String?) ?? '',
        contexto: (mapa['contexto'] as String?) ?? '',
        detalle: (mapa['detalle'] as String?) ?? '',
        origen: (mapa['origen'] as String?) ?? 'app',
      );
}
