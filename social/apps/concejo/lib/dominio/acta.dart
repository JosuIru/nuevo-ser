/// El acta de un asunto (`docs/04-concejo.md` §4.6): sale en PDF en cuanto
/// se cierra y lleva la marca BORRADOR hasta que la firman dos personas de
/// la mesa (como el conteo en papel).
///
/// En cuanto alguien firma, lo que recoge el acta (resultado, conteos,
/// resumen del debate) queda quieto: quien firma tiene que firmar lo mismo
/// que la segunda persona. Mientras falte una firma, quien ha firmado puede
/// retirarla para corregir algo.
library;

class FirmaActa {
  const FirmaActa({required this.personaUid, required this.firmada});

  final String personaUid;
  final DateTime firmada;
}

class Acta {
  const Acta({
    required this.asuntoUid,
    this.firmas = const [],
    this.compromisosAlFirmarUids,
  });

  static const firmasNecesarias = 2;

  final String asuntoUid;
  final List<FirmaActa> firmas;

  /// Los compromisos que recoge el acta, fijados cuando queda firmada. Los
  /// que se apunten después siguen en «¿Se ha hecho?», pero no cambian un
  /// acta ya firmada. `null` mientras es borrador.
  final List<String>? compromisosAlFirmarUids;

  bool get definitiva => firmas.length >= firmasNecesarias;
  bool get tieneFirmas => firmas.isNotEmpty;
  bool firmadaPor(String personaUid) =>
      firmas.any((f) => f.personaUid == personaUid);

  /// [compromisosUids]: los compromisos del asunto en este momento; se
  /// guardan si esta firma es la que la deja definitiva.
  Acta firmar({
    required String personaUid,
    required DateTime ahora,
    required List<String> compromisosUids,
  }) {
    if (definitiva) throw StateError('El acta ya está firmada');
    if (firmadaPor(personaUid)) {
      throw StateError('La misma persona no firma dos veces');
    }
    final nuevasFirmas = [
      ...firmas,
      FirmaActa(personaUid: personaUid, firmada: ahora),
    ];
    return Acta(
      asuntoUid: asuntoUid,
      firmas: List.unmodifiable(nuevasFirmas),
      compromisosAlFirmarUids: nuevasFirmas.length >= firmasNecesarias
          ? List.unmodifiable(compromisosUids)
          : null,
    );
  }

  Acta retirarFirma(String personaUid) {
    if (definitiva) throw StateError('Un acta firmada ya no se toca');
    if (!firmadaPor(personaUid)) throw StateError('No la habías firmado');
    return Acta(
      asuntoUid: asuntoUid,
      firmas: List.unmodifiable(
          firmas.where((f) => f.personaUid != personaUid)),
    );
  }
}
