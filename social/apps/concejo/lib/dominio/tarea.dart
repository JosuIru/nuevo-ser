/// Una **tarea en común** (auzolan, vereda, hacendera, turno): un trabajo
/// con día, hora y lugar para el que hacen falta manos. Limpiar el camino
/// del monte, abrir el local el sábado, montar las mesas de la fiesta.
///
/// La crea la mesa, con cuántas personas hacen falta (0: las que vengan).
/// Cada participante se apunta o se borra hasta que empieza; la mesa puede
/// apuntar a quien se lo pide de palabra. Se anula (con motivo) antes de
/// empezar y, desde ese día, la mesa la da por hecha con una nota.
///
/// Los turnos que se repiten (abrir el local cada sábado) son varias
/// tareas de una plaza: el formulario las crea de una vez.
library;

enum ProblemaTarea { faltaTitulo, plazasNegativas, yaHaEmpezado }

class Tarea {
  const Tarea({
    required this.uid,
    required this.titulo,
    required this.inicio,
    this.lugar = '',
    this.descripcion = '',
    this.plazas = 0,
    this.creadaPorUid = '',
    this.apuntadosUids = const {},
    this.anulada = false,
    this.motivoAnulacion = '',
    this.estaHecha = false,
    this.notaHecha = '',
  });

  final String uid;
  final String titulo;
  final DateTime inicio;
  final String lugar;
  final String descripcion;

  /// Personas que hacen falta. 0: sin límite.
  final int plazas;
  final String creadaPorUid;
  final Set<String> apuntadosUids;
  final bool anulada;
  final String motivoAnulacion;
  final bool estaHecha;
  final String notaHecha;

  bool get llena => plazas > 0 && apuntadosUids.length >= plazas;

  /// `null` si no hay límite.
  int? get plazasLibres =>
      plazas == 0 ? null : (plazas - apuntadosUids.length).clamp(0, plazas);

  bool empezadaEn(DateTime ahora) => !ahora.isBefore(inicio);

  /// Desde el día de la tarea se puede dar por hecha.
  bool admiteHechaEn(DateTime ahora) =>
      !anulada &&
      !ahora.isBefore(DateTime(inicio.year, inicio.month, inicio.day));

  List<ProblemaTarea> problemas(DateTime ahora) => [
        if (titulo.trim().isEmpty) ProblemaTarea.faltaTitulo,
        if (plazas < 0) ProblemaTarea.plazasNegativas,
        if (empezadaEn(ahora)) ProblemaTarea.yaHaEmpezado,
      ];

  Tarea conApuntado(String personaUid,
      {required bool apuntado, required DateTime ahora}) {
    _soloAntesDeEmpezar(ahora);
    if (!apuntado) {
      return _copiar(apuntadosUids: {...apuntadosUids}..remove(personaUid));
    }
    if (apuntadosUids.contains(personaUid)) return this;
    if (llena) throw StateError('No quedan plazas');
    return _copiar(apuntadosUids: {...apuntadosUids, personaUid});
  }

  Tarea anular(String motivo, DateTime ahora) {
    _soloAntesDeEmpezar(ahora);
    if (motivo.trim().isEmpty) {
      throw ArgumentError('Para anular una tarea hay que decir por qué');
    }
    return _copiar(anulada: true, motivoAnulacion: motivo.trim());
  }

  Tarea hecha(String nota, DateTime ahora) {
    if (anulada) throw StateError('La tarea está anulada');
    if (!admiteHechaEn(ahora)) {
      throw StateError('Se da por hecha desde el día de la tarea');
    }
    return _copiar(estaHecha: true, notaHecha: nota.trim());
  }

  void _soloAntesDeEmpezar(DateTime ahora) {
    if (anulada) throw StateError('La tarea está anulada');
    if (estaHecha) throw StateError('La tarea ya está hecha');
    if (empezadaEn(ahora)) throw StateError('La tarea ya ha empezado');
  }

  Tarea _copiar({
    Set<String>? apuntadosUids,
    bool? anulada,
    String? motivoAnulacion,
    bool? estaHecha,
    String? notaHecha,
  }) =>
      Tarea(
        uid: uid,
        titulo: titulo,
        inicio: inicio,
        lugar: lugar,
        descripcion: descripcion,
        plazas: plazas,
        creadaPorUid: creadaPorUid,
        apuntadosUids: apuntadosUids ?? this.apuntadosUids,
        anulada: anulada ?? this.anulada,
        motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
        estaHecha: estaHecha ?? this.estaHecha,
        notaHecha: notaHecha ?? this.notaHecha,
      );
}
