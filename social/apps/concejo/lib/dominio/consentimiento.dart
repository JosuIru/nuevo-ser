/// Decisión por **consentimiento** (`docs/04-concejo.md` §4.4): se aprueba
/// si nadie plantea una objeción razonada («esto causa este daño») que siga
/// sin resolver. No es secreta: cada objeción lleva nombre y motivo.
///
/// Cada vuelta: se plantea la propuesta, la gente objeta o no, la mesa
/// integra las objeciones (cambia la propuesta) o las da por resueltas
/// con quien objetó, y se vuelve a preguntar. Si al cerrar la última vuelta
/// queda alguna objeción viva, el asunto **no se decide aquí**: pasa a
/// votación o a la asamblea en persona.
///
/// Objetar no es estar en contra: «no me gusta» no es una objeción. Por eso
/// el motivo es obligatorio y la mesa puede rechazar una objeción que no
/// razone un daño, dejando constancia ([EstadoObjecion.noEsObjecion]).
library;

enum EstadoObjecion {
  viva,

  /// Se ha cambiado la propuesta para resolverla.
  integrada,

  /// Quien objetó la retira.
  retirada,

  /// La mesa entiende que no razona un daño. Queda en el acta con el
  /// motivo de la mesa.
  noEsObjecion,
}

class Objecion {
  const Objecion({
    required this.uid,
    required this.autorUid,
    required this.ronda,
    required this.motivo,
    this.estado = EstadoObjecion.viva,
    this.respuesta = '',
  });

  final String uid;
  final String autorUid;

  /// Vuelta en la que se planteó (empieza en 1).
  final int ronda;
  final String motivo;
  final EstadoObjecion estado;

  /// Cómo se integró, o por qué la mesa entiende que no es objeción.
  final String respuesta;

  Objecion resolver(EstadoObjecion nuevo, String respuesta) {
    if (nuevo == EstadoObjecion.viva) {
      throw ArgumentError('Resolver es pasarla a otro estado');
    }
    if (nuevo != EstadoObjecion.retirada && respuesta.trim().isEmpty) {
      throw ArgumentError('Hay que decir cómo se ha resuelto');
    }
    return Objecion(
      uid: uid,
      autorUid: autorUid,
      ronda: ronda,
      motivo: motivo,
      estado: nuevo,
      respuesta: respuesta,
    );
  }
}

enum DesenlaceConsentimiento {
  /// Sigue la vuelta en curso o hay objeciones por resolver.
  enCurso,
  aprobada,

  /// Se agotaron las vueltas con objeciones vivas.
  pasaAVotacionOAsamblea,
}

class EstadoConsentimiento {
  const EstadoConsentimiento({
    required this.rondaActual,
    required this.rondasMaximas,
    this.objeciones = const [],
  });

  final int rondaActual;
  final int rondasMaximas;
  final List<Objecion> objeciones;

  List<Objecion> get vivas =>
      objeciones.where((o) => o.estado == EstadoObjecion.viva).toList();

  EstadoConsentimiento objetar({
    required String uid,
    required String autorUid,
    required String motivo,
  }) {
    if (motivo.trim().isEmpty) {
      throw ArgumentError('Una objeción explica qué daño causa la propuesta');
    }
    return _con(objeciones: [
      ...objeciones,
      Objecion(
          uid: uid, autorUid: autorUid, ronda: rondaActual, motivo: motivo),
    ]);
  }

  EstadoConsentimiento resolverObjecion(
    String objecionUid,
    EstadoObjecion nuevo,
    String respuesta,
  ) =>
      _con(objeciones: [
        for (final o in objeciones)
          o.uid == objecionUid ? o.resolver(nuevo, respuesta) : o,
      ]);

  /// La mesa cierra la vuelta en curso. Si no queda nada vivo, la propuesta
  /// está aprobada; si quedan objeciones y hay más vueltas, empieza otra;
  /// si no, pasa a votación o a la asamblea.
  ({EstadoConsentimiento estado, DesenlaceConsentimiento desenlace})
      cerrarRonda() {
    if (vivas.isEmpty) {
      return (estado: this, desenlace: DesenlaceConsentimiento.aprobada);
    }
    if (rondaActual >= rondasMaximas) {
      return (
        estado: this,
        desenlace: DesenlaceConsentimiento.pasaAVotacionOAsamblea,
      );
    }
    return (
      estado: _con(rondaActual: rondaActual + 1),
      desenlace: DesenlaceConsentimiento.enCurso,
    );
  }

  EstadoConsentimiento _con({int? rondaActual, List<Objecion>? objeciones}) =>
      EstadoConsentimiento(
        rondaActual: rondaActual ?? this.rondaActual,
        rondasMaximas: rondasMaximas,
        objeciones: objeciones ?? this.objeciones,
      );
}
