<?php
/**
 * Personas del Espacio Test: quién usa la app, con qué rol y con qué
 * token personal. Se gestionan desde el admin de WordPress (ver
 * `admin.php`); la app sólo las lee.
 *
 * El token se entrega una vez al crearlo o regenerarlo y en BD sólo se
 * guarda su SHA-256: si la BD se filtra, los tokens no.
 *
 * Las personas no son usuarios de WordPress a propósito: testers y
 * mentores no necesitan entrar al escritorio de WP, y un token por
 * dispositivo funciona sin cobertura estable. Si más adelante se quiere
 * enlazar con cuentas WP, basta añadir una columna `wp_user_id`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function szs_tabla_personas(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_PERSONAS;
}

function szs_generar_token(): string {
	return bin2hex( random_bytes( 24 ) );
}

function szs_hash_token( string $token ): string {
	return hash( 'sha256', $token );
}

/**
 * Persona activa dueña de este token, o null.
 */
function szs_persona_por_token( string $token ): ?array {
	global $wpdb;
	if ( '' === $token ) {
		return null;
	}
	$tabla = szs_tabla_personas();
	$fila  = $wpdb->get_row(
		$wpdb->prepare(
			"SELECT uid, nombre, rol FROM {$tabla} WHERE token_hash = %s AND activo = 1",
			szs_hash_token( $token )
		),
		ARRAY_A
	);
	return is_array( $fila ) ? $fila : null;
}

/** @return array<int, array{uid: string, nombre: string, rol: string, activo: string}> */
function szs_listar_personas( bool $solo_activas = true ): array {
	global $wpdb;
	$tabla  = szs_tabla_personas();
	$filtro = $solo_activas ? 'WHERE activo = 1' : '';
	return (array) $wpdb->get_results(
		"SELECT uid, nombre, rol, activo FROM {$tabla} {$filtro} ORDER BY nombre ASC",
		ARRAY_A
	);
}

function szs_nombre_persona( string $uid ): ?string {
	global $wpdb;
	if ( '' === $uid ) {
		return null;
	}
	$tabla  = szs_tabla_personas();
	$nombre = $wpdb->get_var( $wpdb->prepare( "SELECT nombre FROM {$tabla} WHERE uid = %s", $uid ) );
	return null === $nombre ? null : (string) $nombre;
}

/**
 * Crea una persona y devuelve su token en claro (única vez que se ve).
 */
function szs_crear_persona( string $nombre, string $rol ): ?string {
	global $wpdb;
	if ( '' === $nombre || ! szs_rol_existe( $rol ) ) {
		return null;
	}
	$token = szs_generar_token();
	$wpdb->insert(
		szs_tabla_personas(),
		array(
			'uid'        => bin2hex( random_bytes( 16 ) ),
			'nombre'     => $nombre,
			'rol'        => $rol,
			'token_hash' => szs_hash_token( $token ),
			'activo'     => 1,
			'creado_en'  => gmdate( 'Y-m-d H:i:s' ),
		),
		array( '%s', '%s', '%s', '%s', '%d', '%s' )
	);
	return $token;
}

/**
 * Invalida el token anterior y devuelve el nuevo en claro.
 */
function szs_regenerar_token_persona( string $uid ): string {
	global $wpdb;
	$token = szs_generar_token();
	$wpdb->update(
		szs_tabla_personas(),
		array( 'token_hash' => szs_hash_token( $token ) ),
		array( 'uid' => $uid ),
		array( '%s' ),
		array( '%s' )
	);
	return $token;
}

function szs_cambiar_rol_persona( string $uid, string $rol ): void {
	global $wpdb;
	if ( ! szs_rol_existe( $rol ) ) {
		return;
	}
	$wpdb->update( szs_tabla_personas(), array( 'rol' => $rol ), array( 'uid' => $uid ), array( '%s' ), array( '%s' ) );
}

/**
 * Desactivar corta el acceso sin borrar la persona: sus tareas siguen
 * mostrando quién las hizo.
 */
function szs_activar_persona( string $uid, bool $activa ): void {
	global $wpdb;
	$wpdb->update( szs_tabla_personas(), array( 'activo' => $activa ? 1 : 0 ), array( 'uid' => $uid ), array( '%d' ), array( '%s' ) );
}

/**
 * Lo que la app necesita saber de la persona conectada.
 */
function szs_persona_a_json_yo( array $persona ): array {
	return array(
		'uid'          => (string) $persona['uid'],
		'nombre'       => (string) $persona['nombre'],
		'rol'          => (string) $persona['rol'],
		'etiqueta_rol' => szs_etiqueta_rol( (string) $persona['rol'] ),
		'capacidades'  => szs_capacidades_de_rol( (string) $persona['rol'] ),
	);
}

function szs_persona_a_json( array $persona ): array {
	return array(
		'uid'          => (string) $persona['uid'],
		'nombre'       => (string) $persona['nombre'],
		'rol'          => (string) $persona['rol'],
		'etiqueta_rol' => szs_etiqueta_rol( (string) $persona['rol'] ),
	);
}
