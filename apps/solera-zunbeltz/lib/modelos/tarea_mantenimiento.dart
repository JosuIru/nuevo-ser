import 'constantes.dart';
import '../utiles/uid.dart';

/// Una tarea de mantenimiento, anclada a una finca y opcionalmente a un
/// punto de infraestructura o a una zona dibujada. Lleva responsable, prioridad, estado,
/// fecha objetivo, fotos antes/después y coste opcional (que en una fase
/// posterior enchufa con el libro económico).
class TareaMantenimiento {
  TareaMantenimiento({
    this.id,
    String? uid,
    required this.fincaId,
    this.puntoId,
    this.zonaId,
    this.titulo = '',
    this.descripcion = '',
    this.responsable = '',
    this.responsableUid = '',
    this.creadoPorUid = '',
    this.prioridad = prioridadTareaPorDefecto,
    this.estado = estadoTareaPorDefecto,
    this.fechaObjetivoMs,
    this.rutasFotosAntesJson = '[]',
    this.rutasFotosDespuesJson = '[]',
    this.costeCentimos,
    this.fechaCreacionMs = 0,
    this.recurrenciaDias,
    int? actualizadoMs,
  })  : uid = (uid == null || uid.isEmpty) ? generarUid() : uid,
        actualizadoMs = actualizadoMs ?? fechaCreacionMs;

  final int? id;

  /// Clave estable de sincronización (16 bytes en hex, generada en el
  /// dispositivo). A diferencia de [id] — autoincrement local a cada
  /// sqflite — el `uid` es el mismo en todos los dispositivos tras
  /// sincronizar, así que es la clave que usa el servidor para el upsert.
  final String uid;

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

  /// Nombre del responsable. Con sincronización es el nombre de la persona
  /// [responsableUid] (lo fija el servidor); en modo local, texto libre.
  final String responsable;

  /// `uid` de la persona del espacio asignada (ver `PersonaEspacio`). Vacío
  /// = sin asignar o responsable en texto libre (modo local).
  final String responsableUid;

  /// `uid` de la persona que creó la tarea. Da derecho a editarla aunque no
  /// se tengan permisos de coordinación (ver `PoliticaTareas`). Vacío en
  /// tareas creadas en modo local.
  final String creadoPorUid;

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

  /// Periodicidad en días (rellenar comederos cada 7, revisar vallados cada
  /// 30…). `null` = tarea puntual, no se regenera. Al marcarla hecha con
  /// [BaseDatosSoleraZunbeltz.marcarTareaHecha] se crea automáticamente la
  /// siguiente instancia pendiente desplazada estos días.
  final int? recurrenciaDias;

  /// Marca de tiempo de la última modificación local. La sincronización la
  /// usa para decidir qué versión gana (last-write-wins) al fusionar la
  /// misma tarea (mismo [uid]) editada en dos dispositivos.
  final int actualizadoMs;

  bool get esRecurrente => recurrenciaDias != null && recurrenciaDias! > 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'uid': uid,
        'finca_id': fincaId,
        'punto_id': puntoId,
        'zona_id': zonaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'responsable': responsable,
        'responsable_uid': responsableUid,
        'creado_por_uid': creadoPorUid,
        'prioridad': prioridad,
        'estado': estado,
        'fecha_objetivo_ms': fechaObjetivoMs,
        'rutas_fotos_antes_json': rutasFotosAntesJson,
        'rutas_fotos_despues_json': rutasFotosDespuesJson,
        'coste_centimos': costeCentimos,
        'fecha_creacion_ms': fechaCreacionMs,
        'recurrencia_dias': recurrenciaDias,
        'actualizado_ms': actualizadoMs,
      };

  factory TareaMantenimiento.fromMap(Map<String, Object?> mapa) =>
      TareaMantenimiento(
        id: mapa['id'] as int?,
        uid: mapa['uid'] as String?,
        fincaId: (mapa['finca_id'] as int?) ?? 0,
        puntoId: mapa['punto_id'] as int?,
        zonaId: mapa['zona_id'] as int?,
        titulo: (mapa['titulo'] as String?) ?? '',
        descripcion: (mapa['descripcion'] as String?) ?? '',
        responsable: (mapa['responsable'] as String?) ?? '',
        responsableUid: (mapa['responsable_uid'] as String?) ?? '',
        creadoPorUid: (mapa['creado_por_uid'] as String?) ?? '',
        prioridad: (mapa['prioridad'] as String?) ?? prioridadTareaPorDefecto,
        estado: (mapa['estado'] as String?) ?? estadoTareaPorDefecto,
        fechaObjetivoMs: mapa['fecha_objetivo_ms'] as int?,
        rutasFotosAntesJson: (mapa['rutas_fotos_antes_json'] as String?) ?? '[]',
        rutasFotosDespuesJson:
            (mapa['rutas_fotos_despues_json'] as String?) ?? '[]',
        costeCentimos: mapa['coste_centimos'] as int?,
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
        recurrenciaDias: mapa['recurrencia_dias'] as int?,
        actualizadoMs: mapa['actualizado_ms'] as int?,
      );

  TareaMantenimiento copiarCon({
    int? id,
    int? fincaId,
    int? puntoId,
    int? zonaId,
    String? titulo,
    String? descripcion,
    String? responsable,
    String? responsableUid,
    String? creadoPorUid,
    String? prioridad,
    String? estado,
    int? fechaObjetivoMs,
    String? rutasFotosAntesJson,
    String? rutasFotosDespuesJson,
    int? costeCentimos,
    int? fechaCreacionMs,
    int? recurrenciaDias,
    bool limpiarRecurrencia = false,
    int? actualizadoMs,
  }) =>
      TareaMantenimiento(
        id: id ?? this.id,
        uid: uid,
        fincaId: fincaId ?? this.fincaId,
        puntoId: puntoId ?? this.puntoId,
        zonaId: zonaId ?? this.zonaId,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        responsable: responsable ?? this.responsable,
        responsableUid: responsableUid ?? this.responsableUid,
        creadoPorUid: creadoPorUid ?? this.creadoPorUid,
        prioridad: prioridad ?? this.prioridad,
        estado: estado ?? this.estado,
        fechaObjetivoMs: fechaObjetivoMs ?? this.fechaObjetivoMs,
        rutasFotosAntesJson: rutasFotosAntesJson ?? this.rutasFotosAntesJson,
        rutasFotosDespuesJson:
            rutasFotosDespuesJson ?? this.rutasFotosDespuesJson,
        costeCentimos: costeCentimos ?? this.costeCentimos,
        fechaCreacionMs: fechaCreacionMs ?? this.fechaCreacionMs,
        recurrenciaDias: limpiarRecurrencia
            ? null
            : (recurrenciaDias ?? this.recurrenciaDias),
        actualizadoMs: actualizadoMs ?? this.actualizadoMs,
      );
}
