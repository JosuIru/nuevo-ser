import '../modelos/persona_espacio.dart';
import '../modelos/tarea_mantenimiento.dart';
import 'uid.dart';

/// Cómo se reparte una tarea dada de alta con dos o más responsables.
enum RepartoTarea {
  /// Una sola tarea con todas: un único estado para todas.
  compartida,

  /// Una tarea igual para cada persona, cada una con su estado.
  unaParaCada,
}

/// Nombres de las personas [uids] según el espacio, unidos como los guarda
/// `responsable` («Ane, Mikel»). Una persona que ya no está en el espacio
/// no sale (el servidor tampoco la conserva).
String nombresDeResponsables(List<String> uids, List<PersonaEspacio> personas) {
  final nombrePorUid = {
    for (final persona in personas) persona.uid: persona.nombre,
  };
  return unirNombresResponsables(
      [for (final uid in uids) nombrePorUid[uid] ?? '']);
}

/// La tarea con estas responsables: lista, primera en `responsable_uid` y
/// nombres en `responsable`.
TareaMantenimiento conResponsables(TareaMantenimiento tarea, List<String> uids,
        List<PersonaEspacio> personas) =>
    tarea.copiarCon(
      responsablesUids: uids,
      responsableUid: uids.isEmpty ? '' : uids.first,
      responsable: nombresDeResponsables(uids, personas),
    );

/// Columnas que cambian al asignar una tarea que ya existe (para
/// `actualizarTarea`).
Map<String, Object?> columnasResponsables(
    List<String> uids, List<PersonaEspacio> personas) {
  final tarea = conResponsables(TareaMantenimiento(fincaId: 0), uids, personas);
  final mapa = tarea.toMap();
  return {
    'responsables_uids': mapa['responsables_uids'],
    'responsable_uid': mapa['responsable_uid'],
    'responsable': mapa['responsable'],
  };
}

/// Las tareas que se guardan en un alta según el [reparto]: la misma
/// compartida, o una por persona con su propio uid (la primera conserva el
/// de [base]) y todo lo demás igual: finca, punto, zona, fecha, prioridad,
/// periodicidad y fotos de antes.
List<TareaMantenimiento> tareasDelAlta(TareaMantenimiento base,
    List<String> uids, List<PersonaEspacio> personas, RepartoTarea reparto) {
  if (reparto == RepartoTarea.compartida || uids.length < 2) {
    return [conResponsables(base, uids, personas)];
  }
  return [
    for (var indice = 0; indice < uids.length; indice++)
      conResponsables(indice == 0 ? base : base.copiarCon(uid: generarUid()),
          [uids[indice]], personas),
  ];
}
