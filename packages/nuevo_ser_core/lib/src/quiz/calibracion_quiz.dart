/// Cuánto se fía la persona de su respuesta, declarado antes de ver si
/// acierta. Es genérico: cada juego pone sus palabras («Sólido /
/// Probable / Disputado» en Las Versiones, «Seguro / Creo que sí / No
/// estoy seguro» en otros).
///
/// No reutiliza `NivelConfianza` de `calibration/` a propósito: aquel
/// describe una afirmación (su nivel canónico); este, la confianza en
/// una respuesta propia.
enum ConfianzaRespuesta { alta, media, baja }

/// Probabilidad de acierto que equivale a cada nivel declarado. La
/// baja se deja en `null` para que valga el azar puro de la pregunta
/// (1 / número de opciones): «no lo sé» significa «estoy adivinando».
class EscalaConfianza {
  const EscalaConfianza({
    this.probabilidadAlta = 0.9,
    this.probabilidadMedia = 0.65,
    this.probabilidadBaja,
  });

  final double probabilidadAlta;
  final double probabilidadMedia;
  final double? probabilidadBaja;

  double probabilidad(ConfianzaRespuesta confianza, int numeroOpciones) {
    switch (confianza) {
      case ConfianzaRespuesta.alta:
        return probabilidadAlta;
      case ConfianzaRespuesta.media:
        return probabilidadMedia;
      case ConfianzaRespuesta.baja:
        return probabilidadBaja ?? 1.0 / numeroOpciones;
    }
  }
}

/// Una respuesta con su confianza declarada.
class RespuestaCalibrada {
  const RespuestaCalibrada({
    required this.confianza,
    required this.acierto,
    required this.numeroOpciones,
  });

  final ConfianzaRespuesta confianza;
  final bool acierto;
  final int numeroOpciones;
}

/// Hacia dónde se desvía la confianza de la persona en conjunto.
enum TendenciaCalibracion { equilibrada, sobreconfianza, timidez }

/// Resumen de calibración de una partida. Es lo que alimenta la
/// «balanza» del cierre: no dice cuántas se acertaron, sino si la
/// confianza declarada iba de acuerdo con los aciertos.
class ResumenCalibracionQuiz {
  const ResumenCalibracionQuiz._({
    required this.numeroRespuestas,
    required this.scoreMedio,
    required this.desviacion,
    required this.tendencia,
  });

  /// Umbral por debajo del cual la desviación se considera ruido.
  static const double umbralTendencia = 0.1;

  factory ResumenCalibracionQuiz.calcular(
    List<RespuestaCalibrada> respuestas, {
    EscalaConfianza escala = const EscalaConfianza(),
  }) {
    if (respuestas.isEmpty) {
      return const ResumenCalibracionQuiz._(
        numeroRespuestas: 0,
        scoreMedio: 0.0,
        desviacion: 0.0,
        tendencia: TendenciaCalibracion.equilibrada,
      );
    }
    var sumaBrier = 0.0;
    var sumaProbabilidades = 0.0;
    var aciertos = 0;
    for (final respuesta in respuestas) {
      final probabilidad =
          escala.probabilidad(respuesta.confianza, respuesta.numeroOpciones);
      final resultado = respuesta.acierto ? 1.0 : 0.0;
      sumaBrier += (probabilidad - resultado) * (probabilidad - resultado);
      sumaProbabilidades += probabilidad;
      if (respuesta.acierto) aciertos++;
    }
    final numero = respuestas.length;
    final desviacion = sumaProbabilidades / numero - aciertos / numero;
    final TendenciaCalibracion tendencia;
    if (desviacion > umbralTendencia) {
      tendencia = TendenciaCalibracion.sobreconfianza;
    } else if (desviacion < -umbralTendencia) {
      tendencia = TendenciaCalibracion.timidez;
    } else {
      tendencia = TendenciaCalibracion.equilibrada;
    }
    return ResumenCalibracionQuiz._(
      numeroRespuestas: numero,
      scoreMedio: 1.0 - sumaBrier / numero,
      desviacion: desviacion,
      tendencia: tendencia,
    );
  }

  final int numeroRespuestas;

  /// `1 − Brier` binario medio, en [0, 1]. 1 = confianza perfectamente
  /// ajustada a los aciertos.
  final double scoreMedio;

  /// Confianza media declarada menos tasa de acierto. Positiva =
  /// se fía de más; negativa = se fía de menos.
  final double desviacion;

  final TendenciaCalibracion tendencia;
}
