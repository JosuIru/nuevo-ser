import '../modelos/aviso_campo.dart';
import '../modelos/entrada_actividad.dart';
import '../modelos/peticion_tarea.dart';
import '../modelos/tarea_mantenimiento.dart';
import 'cliente_sync_zunbeltz.dart';
import 'politica_espacio.dart';

/// Lo que merece una notificación tras una sincronización. Solo lo que han
/// hecho otras personas: lo propio no se notifica.
class ResumenNotificable {
  const ResumenNotificable({
    this.alarmas = const [],
    this.peticionesNuevas = 0,
    this.actividadAjena = const [],
  });

  /// Títulos de las alarmas de campo abiertas que han llegado.
  final List<String> alarmas;
  final int peticionesNuevas;

  /// Cambios de otras personas (solo para quien ve la actividad).
  final List<EntradaActividad> actividadAjena;

  bool get vacio =>
      alarmas.isEmpty && peticionesNuevas == 0 && actividadAjena.isEmpty;
}

/// [yaNotificadas]: `tipo|uid` de lo que ya se notificó antes (una alarma
/// editada no vuelve a sonar).
ResumenNotificable resumirParaNotificar(
  ResultadoSyncZunbeltz resultado,
  PoliticaEspacio politica, {
  Set<String> yaNotificadas = const {},
}) {
  final miUid = politica.miUid;
  bool esAjena(Map<String, Object?> entidad) =>
      (entidad['autor_uid'] as String? ?? '') != miUid;
  bool esNueva(Map<String, Object?> entidad) =>
      !yaNotificadas.contains('${entidad['tipo']}|${entidad['uid']}');

  final alarmas = <String>[];
  var peticiones = 0;
  for (final entidad in resultado.entidadesNuevasRecibidas) {
    if (entidad['borrado'] == true || !esAjena(entidad) || !esNueva(entidad)) {
      continue;
    }
    final datos = (entidad['datos'] as Map?) ?? const {};
    if (entidad['tipo'] == 'aviso' &&
        datos['gravedad'] == gravedadAlarma &&
        (datos['estado'] ?? estadoAvisoAbierto) == estadoAvisoAbierto) {
      alarmas.add((datos['titulo'] as String?) ?? '');
    }
    if (entidad['tipo'] == 'peticion' &&
        politica.puedeGestionarPeticiones &&
        (datos['estado'] ?? estadoPeticionPendiente) == estadoPeticionPendiente) {
      peticiones++;
    }
  }
  return ResumenNotificable(
    alarmas: alarmas,
    peticionesNuevas: peticiones,
    actividadAjena: politica.puedeVerActividad
        ? [
            for (final entrada in resultado.actividadNueva)
              if (entrada.personaUid != miUid) entrada,
          ]
        : const [],
  );
}

/// Claves `tipo|uid` de lo notificado en [resultado], para no repetir.
/// Solo lo que de verdad suena (alarmas abiertas, peticiones pendientes):
/// un aviso normal que después se sube a alarma tiene que sonar entonces.
Set<String> clavesNotificadas(ResultadoSyncZunbeltz resultado) => {
      for (final entidad in resultado.entidadesNuevasRecibidas)
        if (_suena(entidad)) '${entidad['tipo']}|${entidad['uid']}',
    };

bool _suena(Map<String, Object?> entidad) {
  final datos = (entidad['datos'] as Map?) ?? const {};
  return switch (entidad['tipo']) {
    'aviso' => datos['gravedad'] == gravedadAlarma &&
        (datos['estado'] ?? estadoAvisoAbierto) == estadoAvisoAbierto,
    'peticion' => (datos['estado'] ?? estadoPeticionPendiente) ==
        estadoPeticionPendiente,
    _ => false,
  };
}

/// Tareas vencidas que le tocan a esta persona: fecha objetivo anterior a
/// hoy y sin hacer. Coordinación, todas; una persona tester, las suyas y las
/// generales (sin responsable).
int contarTareasVencidas(
  List<TareaMantenimiento> tareas,
  DateTime ahora,
  PoliticaEspacio politica,
) {
  final inicioDeHoy =
      DateTime(ahora.year, ahora.month, ahora.day).millisecondsSinceEpoch;
  return tareas.where((tarea) {
    final fecha = tarea.fechaObjetivoMs;
    if (fecha == null || fecha >= inicioDeHoy || tarea.estado == 'hecha') {
      return false;
    }
    return politica.modoLocal ||
        politica.puedeGestionarProyectos ||
        tarea.responsableUid.isEmpty ||
        tarea.responsableUid == politica.miUid;
  }).length;
}

/// Tareas sin hacer con fecha en los próximos [dias] días (hoy incluido).
int contarTareasProximas(List<TareaMantenimiento> tareas, DateTime ahora,
    {int dias = 7}) {
  final inicioDeHoy = DateTime(ahora.year, ahora.month, ahora.day);
  final limite = inicioDeHoy.add(Duration(days: dias)).millisecondsSinceEpoch;
  return tareas.where((tarea) {
    final fecha = tarea.fechaObjetivoMs;
    return fecha != null &&
        tarea.estado != 'hecha' &&
        fecha >= inicioDeHoy.millisecondsSinceEpoch &&
        fecha < limite;
  }).length;
}
