/// Cómo se decide un asunto: las cuatro formas de `docs/04-concejo.md` §4.4.
/// Se eligen **antes** de abrir y se ven desde el principio.
library;

import 'asunto.dart' show ProblemaAsunto;

enum FormaDecision {
  /// Sí / No / Abstención.
  votacion,

  /// Cada persona marca todas las opciones que acepta; gana la más
  /// aceptada (voto por aprobación).
  eleccionEntreOpciones,

  /// Se aprueba si nadie plantea una objeción razonada que siga sin
  /// resolver. No es secreta: las objeciones llevan nombre.
  consentimiento,

  /// Bolsa de dinero y propuestas con coste; entran por apoyos mientras
  /// quepan.
  presupuesto,
}

/// Mayoría exigida en una [FormaDecision.votacion].
enum Mayoria {
  /// Más síes que noes. Las abstenciones no cuentan.
  simple,

  /// Más de la mitad de los votos emitidos, abstenciones incluidas.
  absoluta,

  /// Al menos dos tercios de los síes y noes.
  dosTercios,
}

class OpcionDecision {
  const OpcionDecision(
      {required this.id, required this.texto, this.costeEuros});

  final String id;
  final String texto;

  /// Solo en [FormaDecision.presupuesto].
  final double? costeEuros;
}

class ReglasDecision {
  const ReglasDecision({
    required this.forma,
    this.mayoria = Mayoria.simple,
    this.quorumPersonas = 0,
    this.secreta = true,
    this.opciones = const [],
    this.bolsaEuros,
    this.rondasConsentimiento = 2,
  });

  final FormaDecision forma;
  final Mayoria mayoria;

  /// Mínimo de personas que tienen que participar (en la app o en persona)
  /// para que el resultado valga. 0 = sin quórum.
  final int quorumPersonas;

  /// Voto secreto. En [FormaDecision.consentimiento] no aplica: una
  /// objeción se razona y lleva nombre.
  final bool secreta;

  /// Opciones de [FormaDecision.eleccionEntreOpciones] o propuestas de
  /// [FormaDecision.presupuesto].
  final List<OpcionDecision> opciones;

  /// Dinero disponible en [FormaDecision.presupuesto].
  final double? bolsaEuros;

  /// Vueltas de consentimiento antes de llevarlo a votación o a la
  /// asamblea en persona.
  final int rondasConsentimiento;

  bool get esSecreta => secreta && forma != FormaDecision.consentimiento;

  List<ProblemaAsunto> problemas() {
    final ids = opciones.map((opcion) => opcion.id).toList();
    return [
      if (quorumPersonas < 0) ProblemaAsunto.quorumNegativo,
      if ((forma == FormaDecision.eleccionEntreOpciones &&
              opciones.length < 2) ||
          (forma == FormaDecision.presupuesto && opciones.isEmpty))
        ProblemaAsunto.faltanOpciones,
      if (ids.toSet().length != ids.length) ProblemaAsunto.opcionesRepetidas,
      if (forma == FormaDecision.presupuesto &&
          (bolsaEuros == null || bolsaEuros! <= 0))
        ProblemaAsunto.faltaBolsa,
      if (forma == FormaDecision.presupuesto &&
          opciones.any(
              (opcion) => opcion.costeEuros == null || opcion.costeEuros! <= 0))
        ProblemaAsunto.propuestaSinCoste,
    ];
  }
}
