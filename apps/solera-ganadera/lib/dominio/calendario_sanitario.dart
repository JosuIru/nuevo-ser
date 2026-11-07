import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../modelos/tarea_sanitaria.dart';

/// Qué recuerda un aviso del calendario sanitario.
enum TipoAvisoSanitario { tarea, finSupresionCarne, finSupresionLeche }

/// Un aviso del calendario: una tarea que planificó el veterinario o el día
/// en que termina un plazo de supresión de la receta. La app no inventa
/// tareas ni plazos: solo ordena lo apuntado.
class AvisoSanitario {
  const AvisoSanitario({
    required this.tipo,
    required this.dia,
    this.tarea,
    this.loteId,
    this.animalId,
    this.evento,
  });

  final TipoAvisoSanitario tipo;
  final DateTime dia;
  final TareaSanitaria? tarea;
  final int? loteId;
  final int? animalId;
  final EventoGanado? evento;

  /// Una tarea cuyo día ya pasó sin hacerse.
  bool vencido(DateTime ahora) =>
      tipo == TipoAvisoSanitario.tarea &&
      dia.isBefore(DateTime(ahora.year, ahora.month, ahora.day));
}

/// Los avisos de hoy en adelante (y las tareas atrasadas), por fecha:
/// - las tareas pendientes;
/// - el fin de cada plazo de supresión que sigue vigente, con el plazo doble
///   si el rebaño es ecológico.
/// [diasHorizonte] limita lo que viene (las atrasadas salen siempre).
List<AvisoSanitario> avisosSanitarios({
  required List<TareaSanitaria> tareas,
  required List<EventoGanado> eventos,
  required List<LoteGanado> lotes,
  required List<Animal> animales,
  required DateTime ahora,
  int diasHorizonte = 60,
}) {
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final limite = hoy.add(Duration(days: diasHorizonte));
  final lotePorId = {for (final lote in lotes) lote.id: lote};
  final animalPorId = {for (final animal in animales) animal.id: animal};
  final avisos = <AvisoSanitario>[
    for (final tarea in tareas.where((tarea) => tarea.pendiente))
      if (!DateTime.fromMillisecondsSinceEpoch(tarea.fechaPrevistaMs)
          .isAfter(limite))
        AvisoSanitario(
          tipo: TipoAvisoSanitario.tarea,
          dia: () {
            final fecha =
                DateTime.fromMillisecondsSinceEpoch(tarea.fechaPrevistaMs);
            return DateTime(fecha.year, fecha.month, fecha.day);
          }(),
          tarea: tarea,
          loteId: tarea.loteId,
        ),
  ];
  for (final evento in eventos.where((evento) => evento.llevaMedicamento)) {
    final loteId = evento.animalId == null
        ? evento.loteId
        : animalPorId[evento.animalId]?.loteId;
    final ecologico = lotePorId[loteId]?.ecologico ?? false;
    final efectivo = eventoConPlazosEfectivos(evento, ecologico: ecologico);
    for (final (dias, tipo) in [
      (efectivo.plazoSupresionCarneDias, TipoAvisoSanitario.finSupresionCarne),
      (efectivo.plazoSupresionLecheDias, TipoAvisoSanitario.finSupresionLeche),
    ]) {
      if (dias <= 0) continue;
      final fin = finDePlazo(evento.fechaMs, dias);
      if (fin.isAfter(hoy) && !fin.isAfter(limite)) {
        avisos.add(AvisoSanitario(
            tipo: tipo,
            dia: fin,
            loteId: loteId,
            animalId: evento.animalId,
            evento: evento));
      }
    }
  }
  avisos.sort((a, b) => a.dia.compareTo(b.dia));
  return avisos;
}
