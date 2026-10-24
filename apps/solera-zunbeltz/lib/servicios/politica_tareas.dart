import '../modelos/persona_espacio.dart';
import '../modelos/tarea_mantenimiento.dart';

/// Qué puede hacer la persona conectada con las tareas. Replica las reglas
/// del servidor (`wp-plugin/solera-zunbeltz-sync/includes/politica-tareas.php`)
/// sólo para no ofrecer en la interfaz lo que el servidor va a rechazar:
/// **quien manda es el servidor**, que revierte al sincronizar cualquier
/// cambio no permitido.
///
/// Sin sesión ([sesion] `null`: sincronización sin configurar) la app está
/// en modo local de un solo dispositivo y todo está permitido.
class PoliticaTareas {
  const PoliticaTareas(this.sesion);

  final SesionEspacio? sesion;

  bool get modoLocal => sesion == null;

  String get _miUid => sesion?.persona.uid ?? '';

  bool _puede(String capacidad) => sesion?.puede(capacidad) ?? true;

  /// Está entre las responsables (sola o en una tarea compartida).
  bool esResponsable(TareaMantenimiento tarea) =>
      !modoLocal && tarea.tieneResponsable(_miUid);

  bool esCreadora(TareaMantenimiento tarea) =>
      !modoLocal && _miUid.isNotEmpty && tarea.creadoPorUid == _miUid;

  bool get puedeCrear => _puede(capacidadCrearTareas);

  /// Asignar a cualquier persona. Sin esta capacidad sólo cabe asignarse
  /// una misma o dejar la tarea sin asignar.
  bool get puedeAsignarAOtras => _puede(capacidadAsignarTareas);

  bool get puedeVerTodas => _puede(capacidadVerTodasTareas);

  /// Sin ver todas: las asignadas (también las compartidas), las creadas y
  /// las generales (sin responsable). Mismo criterio que
  /// `szs_tarea_visible` en el servidor.
  bool tareaVisible(TareaMantenimiento tarea) =>
      puedeVerTodas ||
      tarea.sinResponsables ||
      esResponsable(tarea) ||
      esCreadora(tarea);

  /// Estado y coste: quien la tiene asignada (cualquiera de las
  /// responsables de una compartida) o la creó.
  bool puedeEjecutar(TareaMantenimiento tarea) =>
      _puede(capacidadEditarCualquierTarea) ||
      esResponsable(tarea) ||
      esCreadora(tarea);

  /// Título, descripción, prioridad, fecha y periodicidad: quien la creó.
  bool puedeEditarContenido(TareaMantenimiento tarea) =>
      _puede(capacidadEditarCualquierTarea) || esCreadora(tarea);

  /// Cogerse una tarea: una general (sin nadie) o, quien puede asignar,
  /// sumarse a una que ya tiene responsables. Se añade a la lista
  /// ([responsablesAlCogerse]).
  bool puedeCogerse(TareaMantenimiento tarea) =>
      !modoLocal &&
      !esResponsable(tarea) &&
      (tarea.sinResponsables || puedeAsignarAOtras);

  /// Soltar una tarea propia. Sale solo quien suelta: en una compartida
  /// las demás siguen ([responsablesAlSoltar]); si era la única, queda
  /// general.
  bool puedeSoltar(TareaMantenimiento tarea) => esResponsable(tarea);

  /// Cambiar a quién está asignada una tarea que ya existe (la deja
  /// compartida entre las elegidas, no la trocea).
  bool puedeCambiarResponsables(TareaMantenimiento tarea) =>
      !modoLocal && puedeAsignarAOtras;

  List<String> responsablesAlCogerse(TareaMantenimiento tarea) =>
      [...tarea.uidsResponsables.where((uid) => uid != _miUid), _miUid];

  List<String> responsablesAlSoltar(TareaMantenimiento tarea) =>
      tarea.uidsResponsables.where((uid) => uid != _miUid).toList();
}
