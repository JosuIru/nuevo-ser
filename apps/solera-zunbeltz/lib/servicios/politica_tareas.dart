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

  bool esResponsable(TareaMantenimiento tarea) =>
      !modoLocal && _miUid.isNotEmpty && tarea.responsableUid == _miUid;

  bool esCreadora(TareaMantenimiento tarea) =>
      !modoLocal && _miUid.isNotEmpty && tarea.creadoPorUid == _miUid;

  bool get puedeCrear => _puede(capacidadCrearTareas);

  /// Asignar a cualquier persona. Sin esta capacidad sólo cabe asignarse
  /// una misma o dejar la tarea sin asignar.
  bool get puedeAsignarAOtras => _puede(capacidadAsignarTareas);

  bool get puedeVerTodas => _puede(capacidadVerTodasTareas);

  /// Estado y coste: quien la tiene asignada o la creó.
  bool puedeEjecutar(TareaMantenimiento tarea) =>
      _puede(capacidadEditarCualquierTarea) ||
      esResponsable(tarea) ||
      esCreadora(tarea);

  /// Título, descripción, prioridad, fecha y periodicidad: quien la creó.
  bool puedeEditarContenido(TareaMantenimiento tarea) =>
      _puede(capacidadEditarCualquierTarea) || esCreadora(tarea);

  /// Cogerse una tarea que no tiene a nadie asignado.
  bool puedeCogerse(TareaMantenimiento tarea) =>
      !modoLocal && tarea.responsableUid.isEmpty;

  /// Soltar una tarea propia para que quede libre.
  bool puedeSoltar(TareaMantenimiento tarea) => esResponsable(tarea);
}
