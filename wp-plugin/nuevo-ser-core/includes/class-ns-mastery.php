<?php
/**
 * Espejo PHP del motor adaptativo (`packages/nuevo_ser_core/lib/src/mastery/`).
 *
 * La doc nuevo-ser-core-arquitectura.md §6.2 EXIGE paridad bit a bit
 * con el motor Dart. Cualquier cambio en P1Precision (Dart) debe
 * espejarse aquí; el test `tests/test_paridad_motor.php` consume las
 * mismas fixtures que el equivalente Dart y debe pasar idénticamente.
 *
 * El estado de habilidad y el payload se representan como arrays
 * asociativos con la misma forma que `EstadoHabilidad.aJson()` y
 * `IntentoHabilidad.aJson()` del Dart — eso permite serializar
 * directamente entre ambos lados sin transformación.
 *
 * Los cuatro perfiles P1-P4 están implementados. La clase base
 * `NS_Mastery_Profile_Stub` se conserva para perfiles futuros.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) && ! defined( 'NS_TEST_STANDALONE' ) ) {
	exit;
}

const NS_MASTERY_ID_PERFIL_P1 = 'P1';
const NS_MASTERY_ID_PERFIL_P2 = 'P2';
const NS_MASTERY_ID_PERFIL_P3 = 'P3';
const NS_MASTERY_ID_PERFIL_P4 = 'P4';

/**
 * Niveles de maestría — orden estable, mismo valor numérico que
 * `NivelMaestria.values.indexOf` en Dart.
 */
final class NS_Nivel_Maestria {
	const INEXPLORADA   = 0;
	const INTRODUCIDA   = 1;
	const EN_DESARROLLO = 2;
	const COMPETENTE    = 3;
	const MAESTRIA      = 4;
}

/**
 * Configuración de un perfil de medición. Replica `ProfileConfig` de
 * Dart con los mismos defaults (P1 calcado de Uno Roto MVP).
 */
final class NS_Profile_Config {
	public float $umbral_precision_maestria;
	public float $umbral_precision_competente;
	public float $umbral_precision_en_desarrollo;
	public int   $exposiciones_min_maestria;
	public int   $sesiones_consecutivas_min_maestria;
	public int   $sesiones_consecutivas_min_competente;
	public float $precision_min_sesion_buena;
	public int   $gap_horas_nueva_sesion;
	public int   $max_intentos_recientes;

	public function __construct(
		float $umbral_precision_maestria,
		float $umbral_precision_competente,
		float $umbral_precision_en_desarrollo,
		int   $exposiciones_min_maestria,
		int   $sesiones_consecutivas_min_maestria,
		int   $sesiones_consecutivas_min_competente,
		float $precision_min_sesion_buena,
		int   $gap_horas_nueva_sesion,
		int   $max_intentos_recientes
	) {
		$this->umbral_precision_maestria             = $umbral_precision_maestria;
		$this->umbral_precision_competente           = $umbral_precision_competente;
		$this->umbral_precision_en_desarrollo        = $umbral_precision_en_desarrollo;
		$this->exposiciones_min_maestria             = $exposiciones_min_maestria;
		$this->sesiones_consecutivas_min_maestria    = $sesiones_consecutivas_min_maestria;
		$this->sesiones_consecutivas_min_competente  = $sesiones_consecutivas_min_competente;
		$this->precision_min_sesion_buena            = $precision_min_sesion_buena;
		$this->gap_horas_nueva_sesion                = $gap_horas_nueva_sesion;
		$this->max_intentos_recientes                = $max_intentos_recientes;
	}

	public static function default_p1(): self {
		return new self(
			0.90, 0.75, 0.50,
			20, 5, 3,
			0.75,
			4,
			20
		);
	}

	/**
	 * Configuración por defecto del perfil P2 (detección F1). Los
	 * umbrales se reinterpretan como F1 en lugar de precisión simple.
	 * Espejo de `ProfileConfig.defaultP2` del Dart.
	 */
	public static function default_p2(): self {
		return new self(
			0.85, 0.70, 0.40,
			20, 5, 3,
			0.70,
			4,
			20
		);
	}

	/**
	 * Configuración por defecto del perfil P3 (rúbrica compuesta). Los
	 * umbrales se reinterpretan como puntuación rúbrica.
	 * Espejo de `ProfileConfig.defaultP3` del Dart.
	 */
	public static function default_p3(): self {
		return new self(
			0.85, 0.70, 0.40,
			12, 4, 2,
			0.70,
			4,
			12
		);
	}

	/**
	 * Configuración por defecto del perfil P4 (calibración epistémica).
	 * Espejo de `ProfileConfig.defaultP4` del Dart: umbrales del doc 02
	 * de Las Versiones §4.1 y ficha AH.03 (30 afirmaciones, 6 sesiones).
	 */
	public static function default_p4(): self {
		return new self(
			0.90, 0.75, 0.55,
			30, 6, 3,
			0.75,
			4,
			30
		);
	}
}

interface NS_Mastery_Profile {
	public function id(): string;

	/**
	 * @param array $payload  ['acierto'=>bool,'dificultad'=>float,'duracionSegundos'=>int,'instante'=>string ISO8601]
	 * @param array $previo   forma de EstadoHabilidad.aJson() del Dart
	 * @return array          ['precision','tiempoMedianoSeg','sesionesConsecutivasBuenas','totalExposiciones','intentosRecientes']
	 */
	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array;

	/**
	 * @return int  uno de NS_Nivel_Maestria::*
	 */
	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int;
}

final class NS_P1_Precision implements NS_Mastery_Profile {
	public function id(): string {
		return NS_MASTERY_ID_PERFIL_P1;
	}

	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array {
		$dificultad = (float) $payload['dificultad'];
		assert( $dificultad >= 0.5 && $dificultad <= 2.0 );

		$intento_nuevo = array(
			't' => $payload['instante'],
			'a' => (bool) $payload['acierto'],
			'd' => $dificultad,
			's' => (int) $payload['duracionSegundos'],
		);

		$intentos = $previo['ir'];
		$intentos[] = $intento_nuevo;
		if ( count( $intentos ) > $config->max_intentos_recientes ) {
			$intentos = array_slice( $intentos, count( $intentos ) - $config->max_intentos_recientes );
		}

		$precision      = self::precision_ponderada( $intentos );
		$tiempo_mediano = self::tiempo_mediano( $intentos );
		$total_exposiciones = (int) $previo['te'] + 1;
		$sesiones_consecutivas = self::actualizar_sesiones_consecutivas(
			$previo,
			$payload['instante'],
			$precision,
			$config
		);

		return array(
			'precision'                  => $precision,
			'tiempoMedianoSeg'           => $tiempo_mediano,
			'sesionesConsecutivasBuenas' => $sesiones_consecutivas,
			'totalExposiciones'          => $total_exposiciones,
			'intentosRecientes'          => $intentos,
		);
	}

	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int {
		if (
			$score['precision'] >= $config->umbral_precision_maestria &&
			$score['totalExposiciones'] >= $config->exposiciones_min_maestria &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_maestria
		) {
			return NS_Nivel_Maestria::MAESTRIA;
		}
		if (
			$score['precision'] >= $config->umbral_precision_competente &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_competente
		) {
			return NS_Nivel_Maestria::COMPETENTE;
		}
		if ( $score['precision'] >= $config->umbral_precision_en_desarrollo ) {
			return NS_Nivel_Maestria::EN_DESARROLLO;
		}
		if ( $score['totalExposiciones'] > 0 ) {
			return NS_Nivel_Maestria::INTRODUCIDA;
		}
		return NS_Nivel_Maestria::INEXPLORADA;
	}

	private static function precision_ponderada( array $intentos ): float {
		if ( empty( $intentos ) ) {
			return 0.0;
		}
		$numerador   = 0.0;
		$denominador = 0.0;
		foreach ( $intentos as $intento ) {
			$d = (float) $intento['d'];
			$numerador   += ( $intento['a'] ? 1.0 : 0.0 ) * $d;
			$denominador += $d;
		}
		return $denominador <= 0 ? 0.0 : $numerador / $denominador;
	}

	private static function tiempo_mediano( array $intentos ): float {
		return self::tiempo_mediano_publico( $intentos );
	}

	/**
	 * Helper público para que los perfiles P2/P3 reusen el cálculo de
	 * tiempo mediano sin duplicarlo. Se mantiene también el método
	 * privado por simetría con el código previo y para no exponer un
	 * nombre _publico en el contrato si en el futuro pasa a interna.
	 */
	public static function tiempo_mediano_publico( array $intentos ): float {
		if ( empty( $intentos ) ) {
			return 0.0;
		}
		$tiempos = array_map( static fn( $i ) => (int) $i['s'], $intentos );
		sort( $tiempos );
		$mitad = intdiv( count( $tiempos ), 2 );
		if ( count( $tiempos ) % 2 === 1 ) {
			return (float) $tiempos[ $mitad ];
		}
		return ( $tiempos[ $mitad - 1 ] + $tiempos[ $mitad ] ) / 2.0;
	}

	private static function actualizar_sesiones_consecutivas(
		array $previo,
		string $ahora_iso,
		float $precision_actual,
		NS_Profile_Config $config
	): int {
		$ahora    = new DateTimeImmutable( $ahora_iso );
		$ultima   = new DateTimeImmutable( $previo['up'] );
		$gap_seg  = $ahora->getTimestamp() - $ultima->getTimestamp();
		// `inHours` de Dart trunca a entero hacia cero.
		$gap_horas = intdiv( $gap_seg, 3600 );
		$es_nueva_sesion = $gap_horas >= $config->gap_horas_nueva_sesion;
		if ( ! $es_nueva_sesion ) {
			return (int) $previo['scb'];
		}
		if ( $precision_actual >= $config->precision_min_sesion_buena ) {
			return (int) $previo['scb'] + 1;
		}
		return 0;
	}
}

abstract class NS_Mastery_Profile_Stub implements NS_Mastery_Profile {
	private string $razon;

	public function __construct( string $razon ) {
		$this->razon = $razon;
	}

	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array {
		throw new RuntimeException( $this->razon . ' compute()' );
	}

	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int {
		throw new RuntimeException( $this->razon . ' level_from_score()' );
	}
}

/**
 * Perfil P2 — detección binaria con métrica F1. Espejo de
 * `P2Detection` del Dart. Cada intento reciente lleva
 * `senalEsperada` (clase real) y `clasePredicha` (lo que dijo la
 * persona) en `ir[].se`/`ir[].cp`; F1 se calcula sobre los pares
 * presentes ponderados por dificultad. Los intentos sin pareja se
 * ignoran (defensivo) pero se registran.
 */
final class NS_P2_Detection implements NS_Mastery_Profile {
	public function id(): string {
		return NS_MASTERY_ID_PERFIL_P2;
	}

	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array {
		$dificultad = (float) $payload['dificultad'];
		assert( $dificultad >= 0.5 && $dificultad <= 2.0 );

		$intento_nuevo = array(
			't' => $payload['instante'],
			'a' => (bool) $payload['acierto'],
			'd' => $dificultad,
			's' => (int) $payload['duracionSegundos'],
		);
		if ( array_key_exists( 'senalEsperada', $payload ) && null !== $payload['senalEsperada'] ) {
			$intento_nuevo['se'] = (bool) $payload['senalEsperada'];
		}
		if ( array_key_exists( 'clasePredicha', $payload ) && null !== $payload['clasePredicha'] ) {
			$intento_nuevo['cp'] = (bool) $payload['clasePredicha'];
		}

		$intentos   = $previo['ir'];
		$intentos[] = $intento_nuevo;
		if ( count( $intentos ) > $config->max_intentos_recientes ) {
			$intentos = array_slice(
				$intentos,
				count( $intentos ) - $config->max_intentos_recientes
			);
		}

		$f1                    = self::f1_score( $intentos );
		$tiempo_mediano        = NS_P1_Precision::tiempo_mediano_publico( $intentos );
		$total_exposiciones    = (int) $previo['te'] + 1;
		$sesiones_consecutivas = self::actualizar_sesiones_consecutivas(
			$previo,
			$payload['instante'],
			$f1,
			$config
		);

		return array(
			'precision'                  => $f1,
			'tiempoMedianoSeg'           => $tiempo_mediano,
			'sesionesConsecutivasBuenas' => $sesiones_consecutivas,
			'totalExposiciones'          => $total_exposiciones,
			'intentosRecientes'          => $intentos,
		);
	}

	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int {
		if (
			$score['precision'] >= $config->umbral_precision_maestria &&
			$score['totalExposiciones'] >= $config->exposiciones_min_maestria &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_maestria
		) {
			return NS_Nivel_Maestria::MAESTRIA;
		}
		if (
			$score['precision'] >= $config->umbral_precision_competente &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_competente
		) {
			return NS_Nivel_Maestria::COMPETENTE;
		}
		if ( $score['precision'] >= $config->umbral_precision_en_desarrollo ) {
			return NS_Nivel_Maestria::EN_DESARROLLO;
		}
		if ( $score['totalExposiciones'] > 0 ) {
			return NS_Nivel_Maestria::INTRODUCIDA;
		}
		return NS_Nivel_Maestria::INEXPLORADA;
	}

	private static function f1_score( array $intentos ): float {
		$tp = 0.0;
		$fp = 0.0;
		$fn = 0.0;
		foreach ( $intentos as $intento ) {
			if ( ! array_key_exists( 'se', $intento ) || ! array_key_exists( 'cp', $intento ) ) {
				continue;
			}
			$senal = (bool) $intento['se'];
			$clase = (bool) $intento['cp'];
			$peso  = (float) $intento['d'];
			if ( $senal && $clase ) {
				$tp += $peso;
			} elseif ( ! $senal && $clase ) {
				$fp += $peso;
			} elseif ( $senal && ! $clase ) {
				$fn += $peso;
			}
		}
		if ( $tp <= 0 ) {
			return 0.0;
		}
		$precision = $tp / ( $tp + $fp );
		$recall    = $tp / ( $tp + $fn );
		if ( $precision + $recall <= 0 ) {
			return 0.0;
		}
		return 2 * $precision * $recall / ( $precision + $recall );
	}

	private static function actualizar_sesiones_consecutivas(
		array $previo,
		string $ahora_iso,
		float $f1_actual,
		NS_Profile_Config $config
	): int {
		$ahora     = new DateTimeImmutable( $ahora_iso );
		$ultima    = new DateTimeImmutable( $previo['up'] );
		$gap_seg   = $ahora->getTimestamp() - $ultima->getTimestamp();
		$gap_horas = intdiv( $gap_seg, 3600 );
		$es_nueva  = $gap_horas >= $config->gap_horas_nueva_sesion;
		if ( ! $es_nueva ) {
			return (int) $previo['scb'];
		}
		if ( $f1_actual >= $config->precision_min_sesion_buena ) {
			return (int) $previo['scb'] + 1;
		}
		return 0;
	}
}

/**
 * Perfil P3 — rúbrica compuesta de cuatro componentes. Espejo de
 * `P3Construction` del Dart. Pesos canónicos del doc 02 §6.1
 * (anclaje 0.35 + calibración 0.25 + completud 0.25 + falacias 0.15).
 * Cada intento lleva los componentes en `ir[].cr.{a,c,p,f}` (cada uno
 * 0..1, clipeado defensivamente).
 */
final class NS_P3_Construction implements NS_Mastery_Profile {
	const PESO_ANCLAJE            = 0.35;
	const PESO_CALIBRACION        = 0.25;
	const PESO_COMPLETUD          = 0.25;
	const PESO_AUSENCIA_FALACIAS  = 0.15;

	public function id(): string {
		return NS_MASTERY_ID_PERFIL_P3;
	}

	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array {
		$dificultad = (float) $payload['dificultad'];
		assert( $dificultad >= 0.5 && $dificultad <= 2.0 );

		$intento_nuevo = array(
			't' => $payload['instante'],
			'a' => (bool) $payload['acierto'],
			'd' => $dificultad,
			's' => (int) $payload['duracionSegundos'],
		);
		if ( array_key_exists( 'componentesRubrica', $payload ) && null !== $payload['componentesRubrica'] ) {
			$intento_nuevo['cr'] = $payload['componentesRubrica'];
		}

		$intentos   = $previo['ir'];
		$intentos[] = $intento_nuevo;
		if ( count( $intentos ) > $config->max_intentos_recientes ) {
			$intentos = array_slice(
				$intentos,
				count( $intentos ) - $config->max_intentos_recientes
			);
		}

		$puntuacion            = self::puntuacion_rubrica_ponderada( $intentos );
		$tiempo_mediano        = NS_P1_Precision::tiempo_mediano_publico( $intentos );
		$total_exposiciones    = (int) $previo['te'] + 1;
		$sesiones_consecutivas = self::actualizar_sesiones_consecutivas(
			$previo,
			$payload['instante'],
			$puntuacion,
			$config
		);

		return array(
			'precision'                  => $puntuacion,
			'tiempoMedianoSeg'           => $tiempo_mediano,
			'sesionesConsecutivasBuenas' => $sesiones_consecutivas,
			'totalExposiciones'          => $total_exposiciones,
			'intentosRecientes'          => $intentos,
		);
	}

	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int {
		if (
			$score['precision'] >= $config->umbral_precision_maestria &&
			$score['totalExposiciones'] >= $config->exposiciones_min_maestria &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_maestria
		) {
			return NS_Nivel_Maestria::MAESTRIA;
		}
		if (
			$score['precision'] >= $config->umbral_precision_competente &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_competente
		) {
			return NS_Nivel_Maestria::COMPETENTE;
		}
		if ( $score['precision'] >= $config->umbral_precision_en_desarrollo ) {
			return NS_Nivel_Maestria::EN_DESARROLLO;
		}
		if ( $score['totalExposiciones'] > 0 ) {
			return NS_Nivel_Maestria::INTRODUCIDA;
		}
		return NS_Nivel_Maestria::INEXPLORADA;
	}

	private static function puntuacion_rubrica_ponderada( array $intentos ): float {
		$numerador   = 0.0;
		$denominador = 0.0;
		foreach ( $intentos as $intento ) {
			if ( ! array_key_exists( 'cr', $intento ) || ! is_array( $intento['cr'] ) ) {
				continue;
			}
			$puntuacion   = self::puntuacion_por_intento( $intento['cr'] );
			$dificultad   = (float) $intento['d'];
			$numerador   += $puntuacion * $dificultad;
			$denominador += $dificultad;
		}
		if ( $denominador <= 0 ) {
			return 0.0;
		}
		return $numerador / $denominador;
	}

	private static function puntuacion_por_intento( array $componentes ): float {
		$a = self::clip_unitario( (float) ( $componentes['a'] ?? 0 ) );
		$c = self::clip_unitario( (float) ( $componentes['c'] ?? 0 ) );
		$p = self::clip_unitario( (float) ( $componentes['p'] ?? 0 ) );
		$f = self::clip_unitario( (float) ( $componentes['f'] ?? 0 ) );
		return $a * self::PESO_ANCLAJE
			+ $c * self::PESO_CALIBRACION
			+ $p * self::PESO_COMPLETUD
			+ $f * self::PESO_AUSENCIA_FALACIAS;
	}

	private static function clip_unitario( float $valor ): float {
		if ( $valor < 0 ) {
			return 0.0;
		}
		if ( $valor > 1 ) {
			return 1.0;
		}
		return $valor;
	}

	private static function actualizar_sesiones_consecutivas(
		array $previo,
		string $ahora_iso,
		float $puntuacion_actual,
		NS_Profile_Config $config
	): int {
		$ahora     = new DateTimeImmutable( $ahora_iso );
		$ultima    = new DateTimeImmutable( $previo['up'] );
		$gap_seg   = $ahora->getTimestamp() - $ultima->getTimestamp();
		$gap_horas = intdiv( $gap_seg, 3600 );
		$es_nueva  = $gap_horas >= $config->gap_horas_nueva_sesion;
		if ( ! $es_nueva ) {
			return (int) $previo['scb'];
		}
		if ( $puntuacion_actual >= $config->precision_min_sesion_buena ) {
			return (int) $previo['scb'] + 1;
		}
		return 0;
	}
}

/**
 * Perfil P4 — calibración epistémica (AH.03 de Las Versiones). Espejo
 * de `P4Calibration` del Dart:
 *
 *   calibración = 1 − Σ wᵢ·(cdᵢ − frᵢ)² / Σ wᵢ
 *
 * con cd (confianza declarada) y fr (fiabilidad real) en {0, 0.5, 1} y
 * wᵢ = dificultad × 2 si cd > fr (sobreconfianza, penalización doble de
 * la ficha AH.03). Los intentos sin pareja cd/fr se guardan y no cuentan.
 */
final class NS_P4_Calibration implements NS_Mastery_Profile {
	const PENALIZACION_SOBRECONFIANZA = 2.0;

	public function id(): string {
		return NS_MASTERY_ID_PERFIL_P4;
	}

	public function compute( array $payload, array $previo, NS_Profile_Config $config ): array {
		$dificultad = (float) $payload['dificultad'];
		assert( $dificultad >= 0.5 && $dificultad <= 2.0 );

		$intento_nuevo = array(
			't' => $payload['instante'],
			'a' => (bool) $payload['acierto'],
			'd' => $dificultad,
			's' => (int) $payload['duracionSegundos'],
		);
		if ( array_key_exists( 'confianzaDeclarada', $payload ) && null !== $payload['confianzaDeclarada'] ) {
			$intento_nuevo['cd'] = (float) $payload['confianzaDeclarada'];
		}
		if ( array_key_exists( 'fiabilidadReal', $payload ) && null !== $payload['fiabilidadReal'] ) {
			$intento_nuevo['fr'] = (float) $payload['fiabilidadReal'];
		}

		$intentos   = $previo['ir'];
		$intentos[] = $intento_nuevo;
		if ( count( $intentos ) > $config->max_intentos_recientes ) {
			$intentos = array_slice(
				$intentos,
				count( $intentos ) - $config->max_intentos_recientes
			);
		}

		$calibracion = self::calibracion_de( $intentos );

		return array(
			'precision'                  => $calibracion,
			'tiempoMedianoSeg'           => NS_P1_Precision::tiempo_mediano_publico( $intentos ),
			'sesionesConsecutivasBuenas' => self::actualizar_sesiones_consecutivas(
				$previo,
				$payload['instante'],
				$calibracion,
				$config
			),
			'totalExposiciones'          => (int) $previo['te'] + 1,
			'intentosRecientes'          => $intentos,
		);
	}

	public function level_from_score( array $score, NS_Profile_Config $config, int $nivel_previo ): int {
		if (
			$score['precision'] >= $config->umbral_precision_maestria &&
			$score['totalExposiciones'] >= $config->exposiciones_min_maestria &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_maestria
		) {
			return NS_Nivel_Maestria::MAESTRIA;
		}
		if (
			$score['precision'] >= $config->umbral_precision_competente &&
			$score['sesionesConsecutivasBuenas'] >= $config->sesiones_consecutivas_min_competente
		) {
			return NS_Nivel_Maestria::COMPETENTE;
		}
		if ( $score['precision'] >= $config->umbral_precision_en_desarrollo ) {
			return NS_Nivel_Maestria::EN_DESARROLLO;
		}
		if ( $score['totalExposiciones'] > 0 ) {
			return NS_Nivel_Maestria::INTRODUCIDA;
		}
		return NS_Nivel_Maestria::INEXPLORADA;
	}

	public static function calibracion_de( array $intentos ): float {
		$suma_pesos   = 0.0;
		$suma_errores = 0.0;
		foreach ( $intentos as $intento ) {
			if ( ! array_key_exists( 'cd', $intento ) || ! array_key_exists( 'fr', $intento ) ) {
				continue;
			}
			$diferencia    = (float) $intento['cd'] - (float) $intento['fr'];
			$peso          = (float) $intento['d']
				* ( $diferencia > 0 ? self::PENALIZACION_SOBRECONFIANZA : 1.0 );
			$suma_pesos   += $peso;
			$suma_errores += $peso * $diferencia * $diferencia;
		}
		if ( $suma_pesos <= 0 ) {
			return 0.0;
		}
		return 1 - $suma_errores / $suma_pesos;
	}

	private static function actualizar_sesiones_consecutivas(
		array $previo,
		string $ahora_iso,
		float $calibracion_actual,
		NS_Profile_Config $config
	): int {
		$ahora     = new DateTimeImmutable( $ahora_iso );
		$ultima    = new DateTimeImmutable( $previo['up'] );
		$gap_seg   = $ahora->getTimestamp() - $ultima->getTimestamp();
		$gap_horas = intdiv( $gap_seg, 3600 );
		$es_nueva  = $gap_horas >= $config->gap_horas_nueva_sesion;
		if ( ! $es_nueva ) {
			return (int) $previo['scb'];
		}
		if ( $calibracion_actual >= $config->precision_min_sesion_buena ) {
			return (int) $previo['scb'] + 1;
		}
		return 0;
	}
}

/**
 * Dispatcher del motor adaptativo en PHP. Replica el comportamiento de
 * `MasteryEngine` (Dart): puro, sin tocar reloj ni almacenamiento.
 */
final class NS_Mastery_Engine {

	/** @var array<string, NS_Mastery_Profile> */
	private array $perfiles;

	/**
	 * @param array<string, NS_Mastery_Profile>|null $perfiles
	 */
	public function __construct( ?array $perfiles = null ) {
		$this->perfiles = $perfiles ?? array(
			NS_MASTERY_ID_PERFIL_P1 => new NS_P1_Precision(),
			NS_MASTERY_ID_PERFIL_P2 => new NS_P2_Detection(),
			NS_MASTERY_ID_PERFIL_P3 => new NS_P3_Construction(),
			NS_MASTERY_ID_PERFIL_P4 => new NS_P4_Calibration(),
		);
	}

	public function perfil( string $id ): NS_Mastery_Profile {
		if ( ! isset( $this->perfiles[ $id ] ) ) {
			throw new InvalidArgumentException(
				'Perfil de medición desconocido: "' . $id . '". '
				. 'Perfiles registrados: ' . implode( ', ', array_keys( $this->perfiles ) ) . '.'
			);
		}
		return $this->perfiles[ $id ];
	}

	/**
	 * Aplica un intento sobre el estado previo y devuelve el estado
	 * actualizado en la misma forma JSON que EstadoHabilidad.aJson() del
	 * Dart.
	 *
	 * @param array $previo  EstadoHabilidad.aJson()
	 * @param array $payload SessionPayload (acierto/dificultad/duracionSegundos/instante)
	 */
	public function actualizar_maestria(
		array $previo,
		array $payload,
		string $id_perfil = NS_MASTERY_ID_PERFIL_P1,
		?NS_Profile_Config $config = null
	): array {
		$config_efectiva = $config ?? NS_Profile_Config::default_p1();
		$perfil          = $this->perfil( $id_perfil );
		$score           = $perfil->compute( $payload, $previo, $config_efectiva );
		$nivel           = $perfil->level_from_score( $score, $config_efectiva, (int) $previo['nv'] );

		return array(
			'id'  => $previo['id'],
			'nv'  => $nivel,
			'pr'  => $score['precision'],
			'tm'  => $score['tiempoMedianoSeg'],
			'up'  => $payload['instante'],
			'scb' => $score['sesionesConsecutivasBuenas'],
			'te'  => $score['totalExposiciones'],
			'ir'  => $score['intentosRecientes'],
		);
	}
}
