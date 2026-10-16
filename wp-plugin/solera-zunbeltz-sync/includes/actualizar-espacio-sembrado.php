<?php
/**
 * Pone al día en el servidor las zonas y puntos que sembró la app.
 *
 * La app siembra el espacio (fincas, zonas, puntos y tareas de Zunbeltz) con
 * uid fijo y `actualizado_ms` 1: sube al servidor si no lo tiene, pero no
 * pisa nunca lo que hay allí. Por eso, cuando cambia lo sembrado (un nombre
 * que da Zunbeltz, un contorno mejor, una zona que sobra), los espacios ya
 * sincronizados no se enteran. Esto lo arregla desde el servidor:
 *
 * - Lo sembrado (`includes/espacio-sembrado.php`, generado por la app) se
 *   compara con lo que hay. Lo que **nadie ha tocado** (`actualizado_ms` 1,
 *   o la marca que dejó aquí mismo una corrección anterior) toma los datos
 *   nuevos; lo editado por una persona se respeta.
 * - Lo nuevo se crea si su finca está en el servidor y nunca ha estado
 *   (una lápida no se resucita).
 * - Lo que ya no se siembra se retira con lápida, si nadie lo ha tocado.
 * - Se escribe con revisión nueva y marca de ahora: los móviles lo reciben
 *   en su siguiente sincronización.
 *
 * Corre una vez por cada versión de lo sembrado (huella del fichero
 * generado), al cargar el plugin.
 *
 * El plan (`szs_plan_espacio_sembrado`) es puro: tests/test_espacio_sembrado.php.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_OPCION_ESPACIO_SEMBRADO_HUELLA = 'szs_espacio_sembrado_huella';
/** uid => `actualizado_ms` de lo que escribió aquí la última corrección. */
const SZS_OPCION_ESPACIO_SEMBRADO_MARCAS = 'szs_espacio_sembrado_marcas';

add_action( 'plugins_loaded', 'szs_actualizar_espacio_sembrado_si_hace_falta', 20 );

// ============================================================
// Plan (puro)
// ============================================================

/** Si nadie ha cambiado `$existente` desde que se sembró o se corrigió aquí. */
function szs_entidad_sembrada_intacta( array $existente, array $marcas ): bool {
	$actualizado_ms = (int) $existente['actualizado_ms'];
	return $actualizado_ms <= 1 || ( $marcas[ $existente['uid'] ] ?? null ) === $actualizado_ms;
}

/**
 * Lo que hay que escribir para dejar el servidor al día.
 *
 * @param array    $sembrado     `entidades` (tipo, uid, datos) y `retiradas` (tipo, uid).
 * @param array    $existentes   "tipo:uid" => entidad del servidor, para las que hay.
 * @param string[] $fincas_vivas uids de las fincas del servidor sin borrar.
 * @param array    $marcas       uid => marca de la corrección anterior.
 *
 * @return array<int, array{entidad: array, existente: ?array}>
 */
function szs_plan_espacio_sembrado( array $sembrado, array $existentes, array $fincas_vivas, array $marcas, int $ahora_ms ): array {
	$plan = array();
	foreach ( $sembrado['entidades'] ?? array() as $sembrada ) {
		$existente = $existentes[ $sembrada['tipo'] . ':' . $sembrada['uid'] ] ?? null;
		if ( null === $existente ) {
			if ( ! in_array( $sembrada['datos']['finca_uid'] ?? '', $fincas_vivas, true ) ) {
				continue;
			}
			$plan[] = array(
				'entidad'   => array(
					'tipo'           => $sembrada['tipo'],
					'uid'            => $sembrada['uid'],
					'actualizado_ms' => $ahora_ms,
					'borrado'        => false,
					'proyecto_uid'   => '',
					'autor_uid'      => '',
					'datos'          => $sembrada['datos'] + array( 'fecha_creacion_ms' => $ahora_ms ),
				),
				'existente' => null,
			);
			continue;
		}
		if ( $existente['borrado'] || ! szs_entidad_sembrada_intacta( $existente, $marcas ) ) {
			continue;
		}
		$datos = array_merge( $existente['datos'], $sembrada['datos'] );
		if ( $datos == $existente['datos'] ) { // phpcs:ignore Universal.Operators.StrictComparisons -- 1.0 y 1 son lo mismo.
			continue;
		}
		$plan[] = array(
			'entidad'   => array_merge(
				$existente,
				array(
					'datos'          => $datos,
					'actualizado_ms' => $ahora_ms,
					'borrado'        => false,
				)
			),
			'existente' => $existente,
		);
	}
	foreach ( $sembrado['retiradas'] ?? array() as $retirada ) {
		$existente = $existentes[ $retirada['tipo'] . ':' . $retirada['uid'] ] ?? null;
		if ( null === $existente || $existente['borrado'] || ! szs_entidad_sembrada_intacta( $existente, $marcas ) ) {
			continue;
		}
		$plan[] = array(
			'entidad'   => array_merge(
				$existente,
				array(
					'actualizado_ms' => $ahora_ms,
					'borrado'        => true,
				)
			),
			'existente' => $existente,
		);
	}
	return $plan;
}

/** Las marcas que quedan después de aplicar `$plan`. */
function szs_marcas_tras_plan( array $marcas, array $plan ): array {
	foreach ( $plan as $paso ) {
		$marcas[ $paso['entidad']['uid'] ] = (int) $paso['entidad']['actualizado_ms'];
	}
	return $marcas;
}

// ============================================================
// Aplicar
// ============================================================

function szs_actualizar_espacio_sembrado_si_hace_falta(): void {
	// Sin el esquema al día no hay tablas donde mirar.
	if ( (int) get_option( SZS_OPCION_VERSION_ESQUEMA, 0 ) < SZS_VERSION_ESQUEMA ) {
		return;
	}
	$huella = md5( szs_espacio_sembrado_json() );
	if ( get_option( SZS_OPCION_ESPACIO_SEMBRADO_HUELLA ) === $huella ) {
		return;
	}
	szs_actualizar_espacio_sembrado();
	update_option( SZS_OPCION_ESPACIO_SEMBRADO_HUELLA, $huella, false );
}

/** Aplica el plan. Devuelve cuántas entidades ha escrito. */
function szs_actualizar_espacio_sembrado(): int {
	$sembrado = json_decode( szs_espacio_sembrado_json(), true );
	if ( ! is_array( $sembrado ) ) {
		return 0;
	}
	$existentes = array();
	foreach ( array_merge( $sembrado['entidades'] ?? array(), $sembrado['retiradas'] ?? array() ) as $referencia ) {
		$existente = szs_obtener_entidad( $referencia['tipo'], $referencia['uid'] );
		if ( null !== $existente ) {
			$existente['borrado']                                            = (bool) $existente['borrado'];
			$existentes[ $referencia['tipo'] . ':' . $referencia['uid'] ] = $existente;
		}
	}
	$fincas_vivas = array();
	foreach ( array_keys( SZS_FINCAS_DEL_ESPACIO ) as $uid_finca ) {
		$finca = szs_obtener_entidad( 'finca', $uid_finca );
		if ( null !== $finca && ! $finca['borrado'] ) {
			$fincas_vivas[] = $uid_finca;
		}
	}
	$marcas = get_option( SZS_OPCION_ESPACIO_SEMBRADO_MARCAS, array() );
	$marcas = is_array( $marcas ) ? $marcas : array();
	$plan   = szs_plan_espacio_sembrado( $sembrado, $existentes, $fincas_vivas, $marcas, (int) round( microtime( true ) * 1000 ) );
	foreach ( $plan as $paso ) {
		szs_guardar_entidad( $paso['entidad'], $paso['existente'], $paso['entidad']['autor_uid'] );
	}
	update_option( SZS_OPCION_ESPACIO_SEMBRADO_MARCAS, szs_marcas_tras_plan( $marcas, $plan ), false );
	return count( $plan );
}
