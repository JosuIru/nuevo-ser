<?php
/**
 * API de la app: `/wp-json/concejo/v1/…`, identificando a la persona por
 * su código personal en `Authorization: Bearer <código>` (cabecera que la
 * API REST de WordPress ya deja pasar en CORS, para la app web).
 *
 * - `GET  /estado?huella=…` lo que ve la persona (ver `vista.php`). Si no
 *   ha cambiado desde la huella que manda la app, solo `sin_cambios`.
 * - `POST /acciones` `{acciones: [...]}` aplica la cola de la app en
 *   orden y dice cuáles se aceptaron (ver `almacen.php`).
 * - `POST /personas/<uid>/codigo` (mesa) código nuevo para una persona,
 *   para dárselo en papel; anula el anterior.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'rest_api_init', 'concejo_registrar_rutas' );

function concejo_registrar_rutas(): void {
	register_rest_route(
		'concejo/v1',
		'/estado',
		array(
			'methods'             => 'GET',
			'callback'            => 'concejo_endpoint_estado',
			'permission_callback' => 'concejo_permiso_codigo',
		)
	);
	register_rest_route(
		'concejo/v1',
		'/acciones',
		array(
			'methods'             => 'POST',
			'callback'            => 'concejo_endpoint_acciones',
			'permission_callback' => 'concejo_permiso_codigo',
		)
	);
	register_rest_route(
		'concejo/v1',
		'/personas/(?P<uid>[A-Za-z0-9_.\-]+)/codigo',
		array(
			'methods'             => 'POST',
			'callback'            => 'concejo_endpoint_codigo',
			'permission_callback' => 'concejo_permiso_codigo',
		)
	);
}

function concejo_permiso_codigo( WP_REST_Request $peticion ) {
	$cabecera = (string) $peticion->get_header( 'Authorization' );
	$codigo   = str_starts_with( $cabecera, 'Bearer ' ) ? substr( $cabecera, 7 ) : '';
	$persona  = concejo_persona_por_codigo( $codigo );
	if ( null === $persona ) {
		return new WP_Error( 'concejo_codigo', 'Código personal incorrecto o persona dada de baja.', array( 'status' => 401 ) );
	}
	$peticion->set_param( 'concejo_persona', $persona );
	return true;
}

function concejo_endpoint_estado( WP_REST_Request $peticion ): WP_REST_Response {
	$persona = $peticion->get_param( 'concejo_persona' );
	$vista   = concejo_vista(
		concejo_cargar_estado(),
		concejo_cargar_papeletas(),
		$persona['uid'],
		concejo_nombre_espacio(),
		concejo_revision(),
		concejo_ahora(),
		concejo_zona()
	);
	$huella  = sha1( (string) wp_json_encode( $vista ) );
	if ( (string) $peticion->get_param( 'huella' ) === $huella ) {
		return new WP_REST_Response(
			array(
				'sin_cambios' => true,
				'huella'      => $huella,
			)
		);
	}
	$vista['huella'] = $huella;
	return new WP_REST_Response( $vista );
}

function concejo_endpoint_acciones( WP_REST_Request $peticion ): WP_REST_Response {
	$cuerpo   = $peticion->get_json_params();
	$acciones = is_array( $cuerpo['acciones'] ?? null ) ? array_slice( $cuerpo['acciones'], 0, 200 ) : array();
	$recibido = concejo_recibir_acciones( $peticion->get_param( 'concejo_persona' ), $acciones );
	return new WP_REST_Response( $recibido, empty( $recibido['ocupado'] ) ? 200 : 503 );
}

function concejo_endpoint_codigo( WP_REST_Request $peticion ) {
	$persona = $peticion->get_param( 'concejo_persona' );
	$estado  = concejo_cargar_estado();
	if ( ! concejo_es_mesa( $estado['personas'][ $persona['uid'] ] ?? null, concejo_ahora(), concejo_zona() ) ) {
		return new WP_Error( 'concejo_mesa', 'Esto lo hace la mesa.', array( 'status' => 403 ) );
	}
	$uid = (string) $peticion->get_param( 'uid' );
	if ( ! isset( $estado['personas'][ $uid ] ) ) {
		return new WP_Error( 'concejo_persona', 'No existe esa persona.', array( 'status' => 404 ) );
	}
	return new WP_REST_Response( array( 'codigo' => concejo_nuevo_codigo( $uid ) ) );
}
