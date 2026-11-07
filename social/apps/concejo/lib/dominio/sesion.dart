/// Una **asamblea** (sesión, batzarre, junta): día, hora, lugar y orden del
/// día. Los asuntos se deciden en la app y en papel, pero en un concejo o
/// una asociación se tratan en sesiones: la sesión los reúne, recoge quién
/// vino y lo que se habló en cada punto.
///
/// La convoca la mesa. Se puede cambiar o anular (con motivo) hasta que
/// empieza; desde ese día se apunta la asistencia y lo hablado.
library;

class PuntoOrdenDia {
  const PuntoOrdenDia({
    required this.uid,
    required this.texto,
    this.asuntoUid,
    this.notas = '',
  });

  final String uid;

  /// «Fiestas de septiembre», «Ruegos y preguntas»…
  final String texto;

  /// Si el punto es un asunto de la app, su uid: la ficha enlaza con él.
  final String? asuntoUid;

  /// Lo que se habló o acordó, lo apunta la mesa en la sesión o después.
  final String notas;

  PuntoOrdenDia conNotas(String nuevas) => PuntoOrdenDia(
      uid: uid, texto: texto, asuntoUid: asuntoUid, notas: nuevas);
}

enum ProblemaSesion {
  faltaTitulo,
  faltaLugar,
  sinPuntos,
  puntoVacio,
  puntoRepetido
}

class Sesion {
  const Sesion({
    required this.uid,
    required this.titulo,
    required this.inicio,
    required this.lugar,
    required this.puntos,
    this.convocadaPorUid = '',
    this.asistentesUids = const {},
    this.asistentesSinApp = 0,
    this.anulada = false,
    this.motivoAnulacion = '',
  });

  final String uid;
  final String titulo;
  final DateTime inicio;
  final String lugar;
  final List<PuntoOrdenDia> puntos;
  final String convocadaPorUid;

  /// Personas con cuenta que vinieron.
  final Set<String> asistentesUids;

  /// Gente sin cuenta en la app que también vino: se cuenta, no se nombra.
  final int asistentesSinApp;
  final bool anulada;
  final String motivoAnulacion;

  int get asistentes => asistentesUids.length + asistentesSinApp;

  /// Ya ha empezado (o pasado): no se cambia ni se anula.
  bool empezadaEn(DateTime ahora) => !ahora.isBefore(inicio);

  /// Desde el día de la sesión se apunta quién vino y lo hablado.
  bool admiteAsistenciaEn(DateTime ahora) =>
      !anulada &&
      !ahora.isBefore(DateTime(inicio.year, inicio.month, inicio.day));

  /// Lo que falta para convocarla. Vacío = se puede.
  List<ProblemaSesion> problemas() {
    final textos = puntos.map((p) => p.texto.trim().toLowerCase()).toList();
    return [
      if (titulo.trim().isEmpty) ProblemaSesion.faltaTitulo,
      if (lugar.trim().isEmpty) ProblemaSesion.faltaLugar,
      if (puntos.isEmpty) ProblemaSesion.sinPuntos,
      if (textos.any((t) => t.isEmpty)) ProblemaSesion.puntoVacio,
      if (textos.toSet().length != textos.length ||
          puntos.map((p) => p.uid).toSet().length != puntos.length)
        ProblemaSesion.puntoRepetido,
    ];
  }

  Sesion anular(String motivo, DateTime ahora) {
    _soloAntesDeEmpezar(ahora);
    if (motivo.trim().isEmpty) {
      throw ArgumentError('Para anular una asamblea hay que decir por qué');
    }
    return _copiar(anulada: true, motivoAnulacion: motivo.trim());
  }

  Sesion conAsistencia(String personaUid,
      {required bool presente, required DateTime ahora}) {
    _soloConAsistencia(ahora);
    return _copiar(
      asistentesUids: presente
          ? {...asistentesUids, personaUid}
          : ({...asistentesUids}..remove(personaUid)),
    );
  }

  Sesion conAsistentesSinApp(int cantidad, DateTime ahora) {
    _soloConAsistencia(ahora);
    if (cantidad < 0) throw ArgumentError('No puede venir gente en negativo');
    return _copiar(asistentesSinApp: cantidad);
  }

  Sesion conNotas(String puntoUid, String notas, DateTime ahora) {
    _soloConAsistencia(ahora);
    if (!puntos.any((p) => p.uid == puntoUid)) {
      throw StateError('No existe ese punto del orden del día');
    }
    return _copiar(puntos: [
      for (final punto in puntos)
        punto.uid == puntoUid ? punto.conNotas(notas.trim()) : punto,
    ]);
  }

  /// Cambiar la convocatoria (fecha, lugar, puntos) solo antes de empezar.
  /// Lo apuntado en la sesión no viene en la nueva: no lo hay todavía.
  Sesion cambiadaPor(Sesion nueva, DateTime ahora) {
    _soloAntesDeEmpezar(ahora);
    if (nueva.uid != uid) throw StateError('Otra asamblea');
    return nueva;
  }

  void _soloAntesDeEmpezar(DateTime ahora) {
    if (anulada) throw StateError('La asamblea está anulada');
    if (empezadaEn(ahora)) throw StateError('La asamblea ya ha empezado');
  }

  void _soloConAsistencia(DateTime ahora) {
    if (anulada) throw StateError('La asamblea está anulada');
    if (!admiteAsistenciaEn(ahora)) {
      throw StateError('La asistencia se apunta desde el día de la asamblea');
    }
  }

  Sesion _copiar({
    List<PuntoOrdenDia>? puntos,
    Set<String>? asistentesUids,
    int? asistentesSinApp,
    bool? anulada,
    String? motivoAnulacion,
  }) =>
      Sesion(
        uid: uid,
        titulo: titulo,
        inicio: inicio,
        lugar: lugar,
        puntos: puntos ?? this.puntos,
        convocadaPorUid: convocadaPorUid,
        asistentesUids: asistentesUids ?? this.asistentesUids,
        asistentesSinApp: asistentesSinApp ?? this.asistentesSinApp,
        anulada: anulada ?? this.anulada,
        motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
      );
}
