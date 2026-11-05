import '../modelos/tarea_mantenimiento.dart';
import '../servicios/politica_espacio.dart';

/// Las tres listas de tareas de la pantalla Hoy.
enum FiltroTareasHoy { vencidas, semana, mias }

/// Las tareas de un filtro de Hoy, de la más urgente a la menos. Mismos
/// criterios que los contadores de `resumen_notificaciones.dart`:
/// - [FiltroTareasHoy.vencidas]: fecha anterior a hoy, sin hacer; una
///   persona tester solo ve las suyas y las generales.
/// - [FiltroTareasHoy.semana]: sin hacer, con fecha en los próximos 7 días.
/// - [FiltroTareasHoy.mias]: sin hacer, con esta persona entre sus
///   responsables (vacía sin sesión).
List<TareaMantenimiento> tareasDeHoy(
  List<TareaMantenimiento> tareas,
  FiltroTareasHoy filtro,
  DateTime ahora,
  PoliticaEspacio politica,
) {
  final inicioDeHoy = DateTime(ahora.year, ahora.month, ahora.day);
  final inicioMs = inicioDeHoy.millisecondsSinceEpoch;
  final limiteSemanaMs =
      DateTime(inicioDeHoy.year, inicioDeHoy.month, inicioDeHoy.day + 7)
          .millisecondsSinceEpoch;
  final miUid = politica.miUid;

  bool meToca(TareaMantenimiento tarea) =>
      politica.modoLocal ||
      politica.puedeGestionarProyectos ||
      tarea.sinResponsables ||
      tarea.tieneResponsable(miUid);

  final elegidas = tareas.where((tarea) {
    if (tarea.estado == 'hecha') return false;
    final fecha = tarea.fechaObjetivoMs;
    return switch (filtro) {
      FiltroTareasHoy.vencidas =>
        fecha != null && fecha < inicioMs && meToca(tarea),
      FiltroTareasHoy.semana =>
        fecha != null && fecha >= inicioMs && fecha < limiteSemanaMs,
      FiltroTareasHoy.mias => miUid.isNotEmpty && tarea.tieneResponsable(miUid),
    };
  }).toList();

  elegidas.sort(compararTareasPorUrgencia);
  return elegidas;
}

/// Con fecha antes que sin ella; a igual fecha, la de más prioridad.
int compararTareasPorUrgencia(TareaMantenimiento a, TareaMantenimiento b) {
  const ordenPrioridad = {'alta': 0, 'media': 1, 'baja': 2};
  final fechaA = a.fechaObjetivoMs ?? 1 << 62;
  final fechaB = b.fechaObjetivoMs ?? 1 << 62;
  if (fechaA != fechaB) return fechaA.compareTo(fechaB);
  return (ordenPrioridad[a.prioridad] ?? 1)
      .compareTo(ordenPrioridad[b.prioridad] ?? 1);
}
