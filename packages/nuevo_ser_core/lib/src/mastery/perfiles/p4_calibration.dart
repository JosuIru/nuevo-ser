import '../habilidad.dart';
import '../mastery_profile.dart';

/// **P4 Calibración epistémica** — Brier invertido del doc 02 de Las
/// Versiones §4.1, para AH.03 (declaración de niveles de confianza):
///
///     calibración = 1 − Σ wᵢ·(confianza_declaradaᵢ − fiabilidad_realᵢ)² / Σ wᵢ
///
/// con confianza y fiabilidad en {0, 0.5, 1} = {Disputado, Probable,
/// Sólido}. Cada intento es una afirmación declarada.
///
/// Pesos: `wᵢ = dificultad × (2 si hay sobreconfianza, 1 si no)`. La
/// ficha de AH.03 (§13.1) pide «penalización doble por sobreconfianza
/// sostenida frente a subconfianza: la sobreconfianza es el vicio más
/// peligroso del oficio». Doblar el peso (y no el error) mantiene la
/// calibración en [0, 1] y hace que una afirmación sobreconfiada pese
/// como dos. Sin sobreconfianza la fórmula es exactamente la del doc.
///
/// Los intentos sin pareja `confianzaDeclarada`/`fiabilidadReal` se
/// guardan pero no cuentan (defensivo, como P2).
class P4Calibration extends MasteryProfile {
  const P4Calibration();

  /// Factor de peso de una afirmación sobreconfiada.
  static const double penalizacionSobreconfianza = 2.0;

  @override
  String get id => 'P4';

  @override
  ScoreResult compute({
    required SessionPayload payload,
    required EstadoHabilidad previo,
    required ProfileConfig config,
  }) {
    assert(payload.dificultad >= 0.5 && payload.dificultad <= 2.0);

    final intentoNuevo = IntentoHabilidad(
      instante: payload.instante,
      acierto: payload.acierto,
      dificultad: payload.dificultad,
      duracionSegundos: payload.duracionSegundos,
      confianzaDeclarada: payload.confianzaDeclarada,
      fiabilidadReal: payload.fiabilidadReal,
    );
    final intentos = [...previo.intentosRecientes, intentoNuevo];
    if (intentos.length > config.maxIntentosRecientes) {
      intentos.removeRange(0, intentos.length - config.maxIntentosRecientes);
    }

    final calibracion = calibracionDe(intentos);
    return ScoreResult(
      precision: calibracion,
      tiempoMedianoSeg: _tiempoMediano(intentos),
      sesionesConsecutivasBuenas: _actualizarSesionesConsecutivas(
        previo: previo,
        ahora: payload.instante,
        calibracionActual: calibracion,
        config: config,
      ),
      totalExposiciones: previo.totalExposiciones + 1,
      intentosRecientes: intentos,
    );
  }

  @override
  NivelMaestria levelFromScore({
    required ScoreResult score,
    required ProfileConfig config,
    required NivelMaestria nivelPrevio,
  }) {
    if (score.precision >= config.umbralPrecisionMaestria &&
        score.totalExposiciones >= config.exposicionesMinMaestria &&
        score.sesionesConsecutivasBuenas >= config.sesionesConsecutivasMinMaestria) {
      return NivelMaestria.maestria;
    }
    if (score.precision >= config.umbralPrecisionCompetente &&
        score.sesionesConsecutivasBuenas >= config.sesionesConsecutivasMinCompetente) {
      return NivelMaestria.competente;
    }
    if (score.precision >= config.umbralPrecisionEnDesarrollo) {
      return NivelMaestria.enDesarrollo;
    }
    if (score.totalExposiciones > 0) return NivelMaestria.introducida;
    return NivelMaestria.inexplorada;
  }

  /// Calibración de una lista de intentos, en [0, 1]. `0` si ninguno
  /// lleva la pareja declarada/real.
  static double calibracionDe(List<IntentoHabilidad> intentos) {
    var sumaPesos = 0.0;
    var sumaErrores = 0.0;
    for (final intento in intentos) {
      final declarada = intento.confianzaDeclarada;
      final real = intento.fiabilidadReal;
      if (declarada == null || real == null) continue;
      final diferencia = declarada - real;
      final peso = intento.dificultad *
          (diferencia > 0 ? penalizacionSobreconfianza : 1.0);
      sumaPesos += peso;
      sumaErrores += peso * diferencia * diferencia;
    }
    if (sumaPesos <= 0) return 0;
    return 1 - sumaErrores / sumaPesos;
  }

  double _tiempoMediano(List<IntentoHabilidad> intentos) {
    if (intentos.isEmpty) return 0;
    final tiempos = intentos.map((i) => i.duracionSegundos).toList()..sort();
    final mitad = tiempos.length ~/ 2;
    if (tiempos.length.isOdd) return tiempos[mitad].toDouble();
    return (tiempos[mitad - 1] + tiempos[mitad]) / 2;
  }

  int _actualizarSesionesConsecutivas({
    required EstadoHabilidad previo,
    required DateTime ahora,
    required double calibracionActual,
    required ProfileConfig config,
  }) {
    final gapHoras = ahora.difference(previo.ultimaPractica).inHours;
    final esNuevaSesion = gapHoras >= config.gapHorasNuevaSesion;
    if (!esNuevaSesion) return previo.sesionesConsecutivasBuenas;
    if (calibracionActual >= config.precisionMinSesionBuena) {
      return previo.sesionesConsecutivasBuenas + 1;
    }
    return 0;
  }
}
