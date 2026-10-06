const String estadoPeticionPendiente = 'pendiente';
const String estadoPeticionAceptada = 'aceptada';
const String estadoPeticionDescartada = 'descartada';

/// Petición de tarea: lo que una persona tester ve que hace falta (comprar
/// pienso, arreglar una cancela…) y pide a coordinación, que es quien crea
/// y asigna tareas. Coordinación la acepta (y crea la tarea) o la descarta
/// con una respuesta.
class PeticionTarea {
  PeticionTarea({
    this.id,
    this.autorUid = '',
    this.fincaId,
    this.puntoId,
    this.titulo = '',
    this.descripcion = '',
    this.urgente = false,
    this.estado = estadoPeticionPendiente,
    this.respuesta = '',
    this.tareaUid = '',
    this.fechaCreacionMs = 0,
  });

  final int? id;

  /// Quién la pidió (persona del espacio). Lo fija el servidor.
  final String autorUid;
  final int? fincaId;
  final int? puntoId;
  final String titulo;
  final String descripcion;
  final bool urgente;

  /// `pendiente` · `aceptada` · `descartada`.
  final String estado;

  /// Lo que contesta coordinación (sobre todo al descartar).
  final String respuesta;

  /// Tarea creada al aceptarla.
  final String tareaUid;
  final int fechaCreacionMs;

  bool get pendiente => estado == estadoPeticionPendiente;

  Map<String, Object?> toMap() => {
        'id': id,
        'autor_uid': autorUid,
        'finca_id': fincaId,
        'punto_id': puntoId,
        'titulo': titulo,
        'descripcion': descripcion,
        'urgente': urgente ? 1 : 0,
        'estado': estado,
        'respuesta': respuesta,
        'tarea_uid': tareaUid,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory PeticionTarea.fromMap(Map<String, Object?> mapa) => PeticionTarea(
        id: mapa['id'] as int?,
        autorUid: (mapa['autor_uid'] as String?) ?? '',
        fincaId: mapa['finca_id'] as int?,
        puntoId: mapa['punto_id'] as int?,
        titulo: (mapa['titulo'] as String?) ?? '',
        descripcion: (mapa['descripcion'] as String?) ?? '',
        urgente: ((mapa['urgente'] as int?) ?? 0) != 0,
        estado: (mapa['estado'] as String?) ?? estadoPeticionPendiente,
        respuesta: (mapa['respuesta'] as String?) ?? '',
        tareaUid: (mapa['tarea_uid'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
