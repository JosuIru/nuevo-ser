<?php
/**
 * Registro de actividad del espacio: quién hizo qué, sobre qué y cuándo
 * («Ane ha marcado hecha "Revisar vallado"», «Jon ha añadido Abrevadero en
 * Zunbeltz»). Lo escribe el servidor al aceptar cada cambio, venga de la
 * app o del panel, así que la huella no depende de lo que diga el
 * dispositivo. Lo recibe quien tiene `ver_actividad` (coordinación).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Qué ha pasado con una tarea, comparando la versión anterior con la
 * guardada. Pura, para poder probarla.
 *
 * @return array{0: string, 1: string} acción y detalle (nuevo estado,
 *                                       nombre de la persona asignada…).
 */
function szs_accion_tarea( ?array $antes, array $despues ): array {
	if ( null === $antes ) {
		return array( 'crear', '' );
	}
	if ( $antes['estado'] !== $despues['estado'] ) {
		return array( 'estado', $despues['estado'] );
	}
	if ( $antes['responsable_uid'] !== $despues['responsable_uid'] ) {
		return array( 'asignar', $despues['responsable'] );
	}
	return array( 'editar', '' );
}

/**
 * Qué ha pasado con una entidad. Pura.
 *
 * @return string `crear` | `borrar` | `mover` (solo cambia la posición de
 *                un punto) | `editar`.
 */
function szs_accion_entidad( ?array $antes, array $despues ): string {
	if ( null === $antes ) {
		return 'crear';
	}
	if ( $despues['borrado'] ) {
		return 'borrar';
	}
	if ( 'punto' === $despues['tipo'] && szs_solo_cambian( $antes['datos'], $despues['datos'], array( 'latitud', 'longitud' ) ) ) {
		return 'mover';
	}
	return 'editar';
}

function szs_registrar_actividad( array $persona, string $accion, string $tipo, string $uid, string $etiqueta, string $contexto, string $detalle, string $origen ): void {
	global $wpdb;
	$wpdb->insert(
		$wpdb->prefix . SZS_TABLA_ACTIVIDAD,
		array(
			'momento_ms'     => (int) round( microtime( true ) * 1000 ),
			'persona_uid'    => (string) ( $persona['uid'] ?? '' ),
			'persona_nombre' => (string) ( $persona['nombre'] ?? '' ),
			'accion'         => $accion,
			'tipo'           => $tipo,
			'uid'            => $uid,
			'etiqueta'       => szs_recortar( $etiqueta, 255 ),
			'contexto'       => szs_recortar( $contexto, 255 ),
			'detalle'        => szs_recortar( $detalle, 255 ),
			'origen'         => $origen,
		)
	);
}

function szs_registrar_actividad_tarea( array $persona, ?array $antes, array $despues, string $origen ): void {
	list( $accion, $detalle ) = szs_accion_tarea( $antes, $despues );
	szs_registrar_actividad( $persona, $accion, 'tarea', $despues['uid'], $despues['titulo'], $despues['finca_nombre'], $detalle, $origen );
}

/**
 * Entradas posteriores a `$desde_id`, de la más antigua a la más reciente
 * (así el dispositivo avanza su cursor al último id recibido).
 *
 * @return array<int, array>
 */
function szs_listar_actividad( int $desde_id, int $limite = 500 ): array {
	global $wpdb;
	$tabla = $wpdb->prefix . SZS_TABLA_ACTIVIDAD;
	$filas = (array) $wpdb->get_results(
		$wpdb->prepare( "SELECT * FROM {$tabla} WHERE id > %d ORDER BY id ASC LIMIT %d", $desde_id, $limite ),
		ARRAY_A
	);
	return array_map( 'szs_actividad_a_json', $filas );
}

function szs_actividad_a_json( array $fila ): array {
	return array(
		'id'             => (int) $fila['id'],
		'momento_ms'     => (int) $fila['momento_ms'],
		'persona_uid'    => (string) $fila['persona_uid'],
		'persona_nombre' => (string) $fila['persona_nombre'],
		'accion'         => (string) $fila['accion'],
		'tipo'           => (string) $fila['tipo'],
		'uid'            => (string) $fila['uid'],
		'etiqueta'       => (string) $fila['etiqueta'],
		'contexto'       => (string) $fila['contexto'],
		'detalle'        => (string) $fila['detalle'],
		'origen'         => (string) $fila['origen'],
	);
}
