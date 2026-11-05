// Tablero de tareas agrupado por punto, pieza o finca.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/utiles/tareas_por_lugar.dart';

void main() {
  TareaMantenimiento tarea(String titulo,
          {int? punto,
          int? zona,
          int finca = 1,
          int? fecha,
          String prioridad = 'media'}) =>
      TareaMantenimiento(
          fincaId: finca,
          puntoId: punto,
          zonaId: zona,
          titulo: titulo,
          fechaObjetivoMs: fecha,
          prioridad: prioridad);

  test('agrupa por punto, pieza y finca; el punto gana a la pieza', () {
    final grupos = agruparTareasPorLugar([
      tarea('a', punto: 7, zona: 3, fecha: 10),
      tarea('b', zona: 3, fecha: 20),
      tarea('c', fecha: 30),
      tarea('d', punto: 7, fecha: 40),
    ], puntosExistentes: {
      7
    }, zonasExistentes: {
      3
    });
    expect(grupos.map((g) => (g.lugar, g.id)).toList(), [
      (LugarTarea.punto, 7),
      (LugarTarea.zona, 3),
      (LugarTarea.finca, 1),
    ]);
    expect(grupos.first.tareas.map((t) => t.titulo), ['a', 'd']);
  });

  test('un punto o pieza que ya no existe cuenta como la finca', () {
    final grupos = agruparTareasPorLugar([
      tarea('a', punto: 99, finca: 2),
      tarea('b', zona: 98, finca: 2),
    ], puntosExistentes: const {}, zonasExistentes: const {});
    expect(grupos, hasLength(1));
    expect((grupos.single.lugar, grupos.single.id), (LugarTarea.finca, 2));
  });

  test('los grupos van por su tarea más urgente', () {
    final grupos = agruparTareasPorLugar([
      tarea('sin fecha', zona: 1),
      tarea('mañana', zona: 2, fecha: 5),
      tarea('alta sin fecha', zona: 1, prioridad: 'alta'),
    ], puntosExistentes: const {}, zonasExistentes: {
      1,
      2
    });
    expect(grupos.map((g) => g.id), [2, 1]);
    expect(grupos.last.tareas.map((t) => t.titulo),
        ['alta sin fecha', 'sin fecha']);
  });
}
