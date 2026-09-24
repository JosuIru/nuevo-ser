import 'habilidad.dart';

/// Payload de un intento individual de la persona usuaria contra una
/// habilidad. Es la unidad mínima que el motor recibe; cada perfil de
/// medición decide qué hacer con ella.
///
/// `instante` lo inyecta el llamante (no se usa `DateTime.now()` dentro
/// del motor) para que los tests sean deterministas y para que la cola
/// offline pueda re-emitir intentos viejos sin distorsionar timestamps.
class SessionPayload {
  final bool acierto;

  /// Coeficiente 0.5..2.0 que pondera el peso del intento en la
  /// precisión agregada. Un puzzle más difícil pesa más cuando se
  /// acierta y más cuando se falla.
  final double dificultad;

  final int duracionSegundos;
  final DateTime instante;

  /// **P2 — clase real**: `true` si el caso pertenece a la clase
  /// positiva (la "señal"), `false` si negativo. `null` para perfiles
  /// que no requieren clasificación binaria (P1, P4).
  final bool? senalEsperada;

  /// **P2 — clase predicha**: lo que la persona dijo. Si [acierto] es
  /// true, [clasePredicha] == [senalEsperada]; si false, la opuesta.
  /// `null` cuando [senalEsperada] es null.
  final bool? clasePredicha;

  /// **P3 — componentes de rúbrica** 0..1. Claves esperadas: `a`
  /// (anclaje), `c` (calibración), `p` (completud), `f` (ausencia de
  /// falacias). `null` para intentos no rúbrica.
  final Map<String, double>? componentesRubrica;

  /// **P4 — confianza declarada** en {0, 0.5, 1} (Disputado, Probable,
  /// Sólido). `null` para perfiles que no miden calibración.
  final double? confianzaDeclarada;

  /// **P4 — fiabilidad real** según la reconstrucción de referencia,
  /// misma escala.
  final double? fiabilidadReal;

  const SessionPayload({
    required this.acierto,
    required this.dificultad,
    required this.duracionSegundos,
    required this.instante,
    this.senalEsperada,
    this.clasePredicha,
    this.componentesRubrica,
    this.confianzaDeclarada,
    this.fiabilidadReal,
  });
}

/// Resultado de la fase de cómputo de un perfil. Es el material que
/// `MasteryProfile.levelFromScore` usa para decidir el nivel; el motor
/// también lo proyecta al nuevo `EstadoHabilidad`.
class ScoreResult {
  final double precision;
  final double tiempoMedianoSeg;
  final int sesionesConsecutivasBuenas;
  final int totalExposiciones;
  final List<IntentoHabilidad> intentosRecientes;

  const ScoreResult({
    required this.precision,
    required this.tiempoMedianoSeg,
    required this.sesionesConsecutivasBuenas,
    required this.totalExposiciones,
    required this.intentosRecientes,
  });
}

/// Parámetros que ajustan el comportamiento de un perfil de medición
/// para una habilidad o juego concreto.
///
/// Los valores por defecto reflejan el modelo P1 actual de Uno Roto
/// (`docs/02 §16` y `docs/03 §8`). Las Versiones podrá pasar otra
/// configuración cuando arranque sus perfiles P2-P4.
class ProfileConfig {
  final double umbralPrecisionMaestria;
  final double umbralPrecisionCompetente;
  final double umbralPrecisionEnDesarrollo;
  final int exposicionesMinMaestria;
  final int sesionesConsecutivasMinMaestria;
  final int sesionesConsecutivasMinCompetente;
  final double precisionMinSesionBuena;
  final int gapHorasNuevaSesion;
  final int maxIntentosRecientes;

  const ProfileConfig({
    required this.umbralPrecisionMaestria,
    required this.umbralPrecisionCompetente,
    required this.umbralPrecisionEnDesarrollo,
    required this.exposicionesMinMaestria,
    required this.sesionesConsecutivasMinMaestria,
    required this.sesionesConsecutivasMinCompetente,
    required this.precisionMinSesionBuena,
    required this.gapHorasNuevaSesion,
    required this.maxIntentosRecientes,
  });

  /// Configuración por defecto del perfil P1 calcada de Uno Roto MVP.
  /// Cualquier juego que no proporcione su `ProfileConfig` recibirá
  /// estos valores.
  static const ProfileConfig defaultP1 = ProfileConfig(
    umbralPrecisionMaestria: 0.90,
    umbralPrecisionCompetente: 0.75,
    umbralPrecisionEnDesarrollo: 0.50,
    exposicionesMinMaestria: 20,
    sesionesConsecutivasMinMaestria: 5,
    sesionesConsecutivasMinCompetente: 3,
    precisionMinSesionBuena: 0.75,
    gapHorasNuevaSesion: 4,
    maxIntentosRecientes: 20,
  );

  /// Configuración por defecto del perfil P2 (detección F1). Los
  /// umbrales se reinterpretan como F1 ≥ {0.85, 0.70, 0.40}: P2 usa los
  /// mismos campos del struct pero la métrica es F1 en lugar de
  /// precisión simple. Bajado respecto a P1 porque F1 castiga
  /// asimétricamente falsos positivos y negativos — exigir 0.90 sería
  /// inalcanzable con clases moderadamente desbalanceadas.
  static const ProfileConfig defaultP2 = ProfileConfig(
    umbralPrecisionMaestria: 0.85,
    umbralPrecisionCompetente: 0.70,
    umbralPrecisionEnDesarrollo: 0.40,
    exposicionesMinMaestria: 20,
    sesionesConsecutivasMinMaestria: 5,
    sesionesConsecutivasMinCompetente: 3,
    precisionMinSesionBuena: 0.70,
    gapHorasNuevaSesion: 4,
    maxIntentosRecientes: 20,
  );

  /// Configuración por defecto del perfil P3 (rúbrica compuesta). Los
  /// umbrales se reinterpretan como puntuación rúbrica ≥ {0.85, 0.70,
  /// 0.40}: P3 calcula promedio ponderado de los cuatro componentes
  /// (anclaje·0.35 + calibración·0.25 + completud·0.25 + ausencia
  /// falacias·0.15) sobre los últimos N intentos.
  static const ProfileConfig defaultP3 = ProfileConfig(
    umbralPrecisionMaestria: 0.85,
    umbralPrecisionCompetente: 0.70,
    umbralPrecisionEnDesarrollo: 0.40,
    exposicionesMinMaestria: 12,
    sesionesConsecutivasMinMaestria: 4,
    sesionesConsecutivasMinCompetente: 2,
    precisionMinSesionBuena: 0.70,
    gapHorasNuevaSesion: 4,
    maxIntentosRecientes: 12,
  );

  /// Configuración por defecto del perfil P4 (calibración epistémica),
  /// del doc 02 de Las Versiones §4.1 y la ficha de AH.03 (§13.1):
  /// umbrales de calibración 0.55 / 0.75 / 0.90 y «30 afirmaciones
  /// evaluadas en al menos 6 Brechas». Las 6 Brechas se aproximan con 6
  /// sesiones buenas seguidas (una Brecha suele ser una sesión); la
  /// ventana guarda las 30 últimas afirmaciones.
  static const ProfileConfig defaultP4 = ProfileConfig(
    umbralPrecisionMaestria: 0.90,
    umbralPrecisionCompetente: 0.75,
    umbralPrecisionEnDesarrollo: 0.55,
    exposicionesMinMaestria: 30,
    sesionesConsecutivasMinMaestria: 6,
    sesionesConsecutivasMinCompetente: 3,
    precisionMinSesionBuena: 0.75,
    gapHorasNuevaSesion: 4,
    maxIntentosRecientes: 30,
  );
}

/// Patrón Strategy de la doc §6.1 — un perfil define cómo se observa la
/// maestría sobre una habilidad. Los cuatro perfiles previstos:
///
/// - **P1 Precisión**: el clásico — proporción de aciertos ponderada
///   por dificultad sobre los últimos N intentos. Usado por todas las
///   habilidades de Uno Roto MVP.
/// - **P2 Detección**: mide si la persona sabe distinguir un caso del
///   contraejemplo (p. ej. en Las Versiones, "qué versión es la
///   contemporánea, qué versión es la post-hoc").
/// - **P3 Construcción**: mide si la persona produce respuestas
///   correctas a problema abierto (no basta elegir).
/// - **P4 Calibración**: mide si la persona estima bien su propio nivel
///   antes de intentarlo (metacognición).
///
/// Cada perfil tiene `compute` (cálculo agregado) y `levelFromScore`
/// (mapeo a `NivelMaestria`). Mantenerlos separados permite a P3/P4
/// reusar el cálculo de P1 cuando convenga, y deja una superficie
/// estrecha para tests de paridad Dart/PHP (doc §6.2).
abstract class MasteryProfile {
  const MasteryProfile();

  /// Identificador estable del perfil en `skills.measurement_profile`.
  String get id;

  /// Calcula los agregados a partir del intento nuevo y el estado
  /// previo persistido. La implementación es pura (no toca tiempo real
  /// ni almacenamiento).
  ScoreResult compute({
    required SessionPayload payload,
    required EstadoHabilidad previo,
    required ProfileConfig config,
  });

  /// Decide el nivel de maestría a partir del score y el nivel previo.
  /// Recibe el nivel previo para que un perfil pueda evitar oscilación
  /// (p. ej. no bajar de competente si el siguiente intento bajó la
  /// precisión por casualidad estadística).
  NivelMaestria levelFromScore({
    required ScoreResult score,
    required ProfileConfig config,
    required NivelMaestria nivelPrevio,
  });
}
