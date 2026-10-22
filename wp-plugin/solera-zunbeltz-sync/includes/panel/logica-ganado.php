<?php
/**
 * Lógica pura del ganado para el panel (sin WordPress): dónde está cada
 * rebaño, cabezas, UGM, supresión vigente y tratamientos en ecológico.
 * Mismos cálculos que la app (`lib/modelos/ganado.dart`,
 * `carga_ganadera.dart`, `ganado_ecologico.dart`); probada en
 * tests/test_ganado.php.
 *
 * Recibe entidades normalizadas (`tipo`, `uid`, `datos`, `actualizado_ms`…).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Fuente de los coeficientes de UGM (PROVISIONAL). */
const SZS_FUENTE_UGM = 'Tabla de equivalencias en UGM por cabeza y especie (Junta de Andalucía)';

/** Fecha local (Y-m-d) de un instante en ms. */
function szs_dia_local( int $ms, string $zona ): DateTimeImmutable {
	$fecha = ( new DateTimeImmutable( '@' . intdiv( $ms, 1000 ) ) )->setTimezone( new DateTimeZone( $zona ) );
	return $fecha->setTime( 0, 0 );
}

/** Meses cumplidos de calendario entre el nacimiento y ahora. */
function szs_meses_cumplidos( int $nacimiento_ms, int $ahora_ms, string $zona ): int {
	$nacimiento = szs_dia_local( $nacimiento_ms, $zona );
	$ahora      = szs_dia_local( $ahora_ms, $zona );
	$meses      = ( (int) $ahora->format( 'Y' ) - (int) $nacimiento->format( 'Y' ) ) * 12 + (int) $ahora->format( 'n' ) - (int) $nacimiento->format( 'n' );
	if ( (int) $ahora->format( 'j' ) < (int) $nacimiento->format( 'j' ) ) {
		$meses--;
	}
	return max( 0, $meses );
}

/** UGM de una cabeza (sin fecha de nacimiento, adulta). PROVISIONAL. */
function szs_ugm_por_cabeza( string $especie, string $sexo, ?int $nacimiento_ms, int $ahora_ms, string $zona ): float {
	$meses  = null === $nacimiento_ms || 0 === $nacimiento_ms ? null : szs_meses_cumplidos( $nacimiento_ms, $ahora_ms, $zona );
	$adulto = null === $meses || $meses >= 12;
	switch ( $especie ) {
		case 'vacuno':
			if ( null === $meses || $meses >= 24 ) {
				return 1.0;
			}
			return $meses < 6 ? 0.2 : 0.6;
		case 'ovino':
		case 'caprino':
			if ( ! $adulto ) {
				return $meses < 4 ? 0.05 : 0.10;
			}
			return 'macho' === $sexo ? 0.12 : 0.15;
		case 'equino':
			if ( null === $meses || $meses >= 12 ) {
				return 1.0;
			}
			return $meses < 6 ? 0.2 : 0.5;
		case 'porcino':
			return $adulto && 'macho' === $sexo ? 0.30 : 0.25;
		case 'aves':
			return 0.015;
		default:
			return 0.0;
	}
}

function szs_animal_activo( array $animal ): bool {
	return 'activo' === ( $animal['datos']['estado'] ?? 'activo' );
}

/** Cabezas: animales en el espacio más los que no llevan crotal. */
function szs_cabezas_de_lote( array $lote, array $animales_del_lote ): int {
	return count( array_filter( $animales_del_lote, 'szs_animal_activo' ) ) + (int) ( $lote['datos']['cabezas_sin_identificar'] ?? 0 );
}

function szs_ugm_de_lote( array $lote, array $animales_del_lote, int $ahora_ms, string $zona ): float {
	$especie_lote = (string) ( $lote['datos']['especie'] ?? '' );
	$total        = 0.0;
	foreach ( array_filter( $animales_del_lote, 'szs_animal_activo' ) as $animal ) {
		$datos   = $animal['datos'];
		$especie = '' !== (string) ( $datos['especie'] ?? '' ) ? (string) $datos['especie'] : $especie_lote;
		$total  += szs_ugm_por_cabeza( $especie, (string) ( $datos['sexo'] ?? '' ), isset( $datos['fecha_nacimiento_ms'] ) ? (int) $datos['fecha_nacimiento_ms'] : null, $ahora_ms, $zona );
	}
	return $total + (int) ( $lote['datos']['cabezas_sin_identificar'] ?? 0 ) * szs_ugm_por_cabeza( $especie_lote, '', null, $ahora_ms, $zona );
}

/** El último movimiento por fecha (a igual fecha, el último apuntado). */
function szs_ultimo_movimiento( array $movimientos ): ?array {
	$ultimo = null;
	foreach ( $movimientos as $movimiento ) {
		$clave = array( (int) ( $movimiento['datos']['fecha_ms'] ?? 0 ), (int) ( $movimiento['actualizado_ms'] ?? 0 ) );
		if ( null === $ultimo || $clave > array( (int) ( $ultimo['datos']['fecha_ms'] ?? 0 ), (int) ( $ultimo['actualizado_ms'] ?? 0 ) ) ) {
			$ultimo = $movimiento;
		}
	}
	return $ultimo;
}

/**
 * Dónde está un rebaño: `['zona_uid' => …]` si está en una pieza,
 * `['fuera' => destino]` si salió, o null sin movimientos.
 */
function szs_ubicacion_lote( array $movimientos_del_lote ): ?array {
	$ultimo = szs_ultimo_movimiento( $movimientos_del_lote );
	if ( null === $ultimo ) {
		return null;
	}
	if ( 'salida' === ( $ultimo['datos']['tipo'] ?? '' ) ) {
		return array( 'fuera' => (string) ( $ultimo['datos']['destino_externo'] ?? '' ) );
	}
	return array( 'zona_uid' => (string) ( $ultimo['datos']['zona_destino_uid'] ?? '' ) );
}

/** ¿Dobla la espera en ecológico? Vacunas y remedios naturales no. */
function szs_clase_dobla_espera( string $clase ): bool {
	return 'vacuna' !== $clase && 'natural' !== $clase;
}

/** Espera que vale para vender como ecológico: el doble y mínimo 2 días (48 h). */
function szs_plazo_efectivo_dias( int $dias, bool $ecologico, string $clase ): int {
	if ( ! $ecologico || ! szs_clase_dobla_espera( $clase ) ) {
		return $dias;
	}
	return max( 2, $dias * 2 );
}

/**
 * Hasta qué día (Y-m-d, exclusivo como en la app: libre desde ese día) dura
 * la supresión de carne y de leche en [ahora]; null si no hay.
 *
 * @return array{carne: ?string, leche: ?string}
 */
function szs_supresion_vigente( array $eventos, int $ahora_ms, string $zona, bool $ecologico ): array {
	$hoy       = szs_dia_local( $ahora_ms, $zona );
	$resultado = array(
		'carne' => null,
		'leche' => null,
	);
	foreach ( $eventos as $evento ) {
		$datos = $evento['datos'];
		if ( ! in_array( $datos['tipo'] ?? '', SZS_TIPOS_EVENTO_CON_MEDICAMENTO, true ) ) {
			continue;
		}
		foreach ( array( 'carne', 'leche' ) as $de ) {
			$dias = szs_plazo_efectivo_dias( (int) ( $datos[ "plazo_supresion_{$de}_dias" ] ?? 0 ), $ecologico, (string) ( $datos['clase_medicamento'] ?? '' ) );
			if ( $dias <= 0 ) {
				continue;
			}
			$fin = szs_dia_local( (int) ( $datos['fecha_ms'] ?? 0 ), $zona )->modify( "+{$dias} days" );
			if ( $fin > $hoy && ( null === $resultado[ $de ] || $fin->format( 'Y-m-d' ) > $resultado[ $de ] ) ) {
				$resultado[ $de ] = $fin->format( 'Y-m-d' );
			}
		}
	}
	return $resultado;
}

/** ¿Cuenta para el límite ecológico? Solo tratamientos que no son vacuna, antiparasitario ni natural. */
function szs_cuenta_para_limite_ecologico( array $evento ): bool {
	$datos = $evento['datos'];
	return 'tratamiento' === ( $datos['tipo'] ?? '' ) && ! in_array( $datos['clase_medicamento'] ?? '', array( 'vacuna', 'antiparasitario', 'natural' ), true );
}

/**
 * Tratamientos que cuentan en los 12 meses anteriores (desde el mismo día del
 * año anterior) y el límite: 3, o 1 con vida productiva menor de un año.
 *
 * @return array{tratamientos: int, limite: int, superado: bool, en_limite: bool}
 */
function szs_estado_tratamientos_ecologico( array $eventos, int $ahora_ms, string $zona, bool $ciclo_corto ): array {
	$desde  = szs_dia_local( $ahora_ms, $zona )->modify( '-1 year' );
	$cuenta = 0;
	foreach ( $eventos as $evento ) {
		if ( szs_cuenta_para_limite_ecologico( $evento ) && szs_dia_local( (int) ( $evento['datos']['fecha_ms'] ?? 0 ), $zona ) >= $desde ) {
			$cuenta++;
		}
	}
	$limite = $ciclo_corto ? 1 : 3;
	return array(
		'tratamientos' => $cuenta,
		'limite'       => $limite,
		'superado'     => $cuenta > $limite,
		'en_limite'    => $cuenta === $limite,
	);
}

/** Un CSV para Excel (BOM, punto y coma, celdas escapadas) a partir de filas. */
function szs_filas_a_csv( array $cabecera, array $filas ): string {
	$lineas = array( implode( ';', array_map( 'szs_campo_csv', $cabecera ) ) );
	foreach ( $filas as $fila ) {
		$lineas[] = implode( ';', array_map( 'szs_campo_csv', $fila ) );
	}
	return "\u{FEFF}" . implode( "\r\n", $lineas ) . "\r\n";
}
