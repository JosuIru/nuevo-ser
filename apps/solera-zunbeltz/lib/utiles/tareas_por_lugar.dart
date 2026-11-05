import '../modelos/tarea_mantenimiento.dart';
import 'tareas_hoy.dart';

/// Dónde está un grupo de tareas del tablero.
enum LugarTarea { punto, zona, finca }

/// Las tareas de un mismo sitio: un punto, una pieza o, si no tienen
/// ninguno (o ya no existe), la finca entera.
class GrupoTareasLugar {
  const GrupoTareasLugar(this.lugar, this.id, this.tareas);

  final LugarTarea lugar;

  /// Id del punto, de la pieza o de la finca, según [lugar].
  final int id;
  final List<TareaMantenimiento> tareas;
}

/// Agrupa las tareas por el sitio al que van ancladas (pantalla 07 de la
/// propuesta). Gana el punto sobre la pieza; un punto o una pieza que ya
/// no están (`puntosExistentes`, `zonasExistentes`) cuentan como finca.
/// Dentro de cada grupo, por urgencia; los grupos, por su tarea más
/// urgente.
List<GrupoTareasLugar> agruparTareasPorLugar(
  List<TareaMantenimiento> tareas, {
  required Set<int> puntosExistentes,
  required Set<int> zonasExistentes,
}) {
  final ordenadas = [...tareas]..sort(compararTareasPorUrgencia);
  final grupos = <(LugarTarea, int), List<TareaMantenimiento>>{};
  for (final tarea in ordenadas) {
    final puntoId = tarea.puntoId;
    final zonaId = tarea.zonaId;
    final clave = puntoId != null && puntosExistentes.contains(puntoId)
        ? (LugarTarea.punto, puntoId)
        : zonaId != null && zonasExistentes.contains(zonaId)
            ? (LugarTarea.zona, zonaId)
            : (LugarTarea.finca, tarea.fincaId);
    grupos.putIfAbsent(clave, () => []).add(tarea);
  }
  return [
    for (final MapEntry(key: (lugar, id), value: lista) in grupos.entries)
      GrupoTareasLugar(lugar, id, lista),
  ];
}
