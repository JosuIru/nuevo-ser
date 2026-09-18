import 'constantes.dart';

/// Una tarea de mantenimiento, anclada a una finca y opcionalmente a un
/// punto de infraestructura o a una zona dibujada. Lleva responsable, prioridad, estado,
/// fecha objetivo, fotos antes/después y coste opcional (que en una fase
/// posterior enchufa con el libro económico).
class TareaMantenimiento {
  TareaMantenimiento({
    this.id,
    required this.fincaId,
    this.puntoId,
    this.zonaId,
    this.titulo = '',
    this.descripcion = '',
    this.responsable = '',
    this.prioridad = prioridadTareaPorDefecto,
    this.estado = estadoTareaPorDefecto,
    this.fechaObjetivoMs,
    this.rutasFotosAntesJson = '[]',
    this.rutasFotosDespuesJson = '[]',
    this.costeCentimos,
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final int fincaId;

  /// Punto al que se ancla la tarea. `null` = tarea de finca (no de un punto
  /// concreto). FK con ON DELETE SET NULL: borrar el punto no borra su
  /// historial de tareas.
  final int? puntoId;

  /// Zona a la que se ancla la tarea (desbrozar una parcela, reparar el
  /// cierre de un cercado). Excluyente con [puntoId] en la práctica: una
  /// tarea se ancla a un punto, a una zona o a nada. Al borrar la zona se
  /// pone a null por código (ver `borrarZona`), conservando la tarea.
  final int? zonaId;

  final String titulo;
  final String descripcion;

  /// Responsable en texto libre (testador, mentor, operario, externo o sin
  /// asignar). Se estructura por rol cuando llegue el backend multi-rol (FZ-9).
  final String responsable;

  /// Código de `prioridadesTarea` (baja / media / alta).
  final String prioridad;

  /// Código de `estadosTarea` (pendiente / en_curso / hecha / bloqueada).
  final String estado;

  final int? fechaObjetivoMs;
  final String rutasFotosAntesJson;
  final String rutasFotosDespuesJson;

  /// Coste en céntimos (opcional). Entero para evitar imprecisión de coma
  /// flotante en dinero.
  final int? costeCentimos;

  final int fechaCreacionMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'finca_id': fincaId,
        'punto_id': puntoId,
        'zona_id': zonaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'responsable': responsable,
        'prioridad': prioridad,
        'estado': estado,
        'fecha_objetivo_ms': fechaObjetivoMs,
        'rutas_fotos_antes_json': rutasFotosAntesJson,
        'rutas_fotos_despues_json': rutasFotosDespuesJson,
        'coste_centimos': costeCentimos,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory TareaMantenimiento.fromMap(Map<String, Object?> mapa) =>
      TareaMantenimiento(
        id: mapa['id'] as int?,
        fincaId: (mapa['finca_id'] as int?) ?? 0,
        puntoId: mapa['punto_id'] as int?,
        zonaId: mapa['zona_id'] as int?,
        titulo: (mapa['titulo'] as String?) ?? '',
        descripcion: (mapa['descripcion'] as String?) ?? '',
        responsable: (mapa['responsable'] as String?) ?? '',
        prioridad: (mapa['prioridad'] as String?) ?? prioridadTareaPorDefecto,
        estado: (mapa['estado'] as String?) ?? estadoTareaPorDefecto,
        fechaObjetivoMs: mapa['fecha_objetivo_ms'] as int?,
        rutasFotosAntesJson: (mapa['rutas_fotos_antes_json'] as String?) ?? '[]',
        rutasFotosDespuesJson:
            (mapa['rutas_fotos_despues_json'] as String?) ?? '[]',
        costeCentimos: mapa['coste_centimos'] as int?,
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );

  TareaMantenimiento copiarCon({
    int? id,
    int? fincaId,
    int? puntoId,
    int? zonaId,
    String? titulo,
    String? descripcion,
    String? responsable,
    String? prioridad,
    String? estado,
    int? fechaObjetivoMs,
    String? rutasFotosAntesJson,
    String? rutasFotosDespuesJson,
    int? costeCentimos,
    int? fechaCreacionMs,
  }) =>
      TareaMantenimiento(
        id: id ?? this.id,
        fincaId: fincaId ?? this.fincaId,
        puntoId: puntoId ?? this.puntoId,
        zonaId: zonaId ?? this.zonaId,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        responsable: responsable ?? this.responsable,
        prioridad: prioridad ?? this.prioridad,
        estado: estado ?? this.estado,
        fechaObjetivoMs: fechaObjetivoMs ?? this.fechaObjetivoMs,
        rutasFotosAntesJson: rutasFotosAntesJson ?? this.rutasFotosAntesJson,
        rutasFotosDespuesJson:
            rutasFotosDespuesJson ?? this.rutasFotosDespuesJson,
        costeCentimos: costeCentimos ?? this.costeCentimos,
        fechaCreacionMs: fechaCreacionMs ?? this.fechaCreacionMs,
      );
}
