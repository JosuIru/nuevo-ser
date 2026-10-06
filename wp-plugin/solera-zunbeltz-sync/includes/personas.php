<?php
/**
 * Personas del Espacio Test: quién usa la app, con qué rol y con qué
 * token personal. Se gestionan desde el admin de WordPress (ver
 * `admin.php`); la app sólo las lee.
 *
 * El token se entrega una vez al crearlo o regenerarlo y en BD sólo se
 * guarda su SHA-256: si la BD se filtra, los tokens no.
 *
 * Las personas no son usuarios de WordPress a propósito: las testers no
 * necesitan entrar al escritorio, y un token por dispositivo funciona sin
 * cobertura estable. Una persona **puede enlazarse** con un usuario de
 * WordPress (`wp_user_id`): si es de coordinación, ese usuario entra al
 * panel de la oficina y lo que hace allí queda a nombre de la persona.
 * El `correo` es para los avisos (resumen diario, alarmas).
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

/** @return array<int, array{uid: string, nombre: string, rol: string, activo: string, wp_user_id: string, correo: string}> */
function szs_listar_personas( bool $solo_activas = true ): array {
	global $wpdb;
	$tabla  = szs_tabla_personas();
	$filtro = $solo_activas ? 'WHERE activo = 1' : '';
	return (array) $wpdb->get_results(
		"SELECT uid, nombre, rol, activo, wp_user_id, correo FROM {$tabla} {$filtro} ORDER BY nombre ASC",
		ARRAY_A
	);
}

/**
 * Enlaza una persona con un usuario de WordPress (0 = ninguno) y guarda su
 * correo. El usuario recibe acceso al panel si la persona es de un rol que
 * gestiona proyectos (coordinación); se le quita si deja de tenerlo.
 */
function szs_enlazar_persona_usuario( string $uid, int $wp_user_id, string $correo ): void {
	global $wpdb;
	$tabla    = szs_tabla_personas();
	$anterior = (int) $wpdb->get_var( $wpdb->prepare( "SELECT wp_user_id FROM {$tabla} WHERE uid = %s", $uid ) );
	$wpdb->update(
		$tabla,
		array(
			'wp_user_id' => max( 0, $wp_user_id ),
			'correo'     => sanitize_email( $correo ),
		),
		array( 'uid' => $uid ),
		array( '%d', '%s' ),
		array( '%s' )
	);
	if ( $anterior > 0 && $anterior !== $wp_user_id ) {
		szs_sincronizar_acceso_panel( $anterior );
	}
	if ( $wp_user_id > 0 ) {
		szs_sincronizar_acceso_panel( $wp_user_id );
	}
}

/**
 * Da o quita a un usuario de WordPress el acceso al panel según la persona
 * enlazada con él. Los administradores lo tienen siempre por su rol.
 */
function szs_sincronizar_acceso_panel( int $wp_user_id ): void {
	global $wpdb;
	$usuario = get_userdata( $wp_user_id );
	if ( false === $usuario ) {
		return;
	}
	$tabla = szs_tabla_personas();
	$rol   = $wpdb->get_var( $wpdb->prepare( "SELECT rol FROM {$tabla} WHERE wp_user_id = %d AND activo = 1", $wp_user_id ) );
	$puede = null !== $rol && in_array( SZS_CAPACIDAD_GESTIONAR_PROYECTOS, szs_capacidades_de_rol( (string) $rol ), true );
	if ( $puede ) {
		$usuario->add_cap( SZS_CAPACIDAD_WP_PANEL );
	} else {
		$usuario->remove_cap( SZS_CAPACIDAD_WP_PANEL );
	}
}

/**
 * Correos a los que avisar: personas activas de coordinación (su correo o,
 * si no tienen, el de su usuario de WordPress enlazado).
 *
 * @return string[]
 */
function szs_correos_coordinacion(): array {
	$correos = array();
	foreach ( szs_listar_personas() as $persona ) {
		if ( ! in_array( SZS_CAPACIDAD_GESTIONAR_PROYECTOS, szs_capacidades_de_rol( (string) $persona['rol'] ), true ) ) {
			continue;
		}
		$correo = (string) $persona['correo'];
		if ( '' === $correo && (int) $persona['wp_user_id'] > 0 ) {
			$usuario = get_userdata( (int) $persona['wp_user_id'] );
			$correo  = false === $usuario ? '' : (string) $usuario->user_email;
		}
		if ( '' !== $correo ) {
			$correos[] = $correo;
		}
	}
	return array_values( array_unique( $correos ) );
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
	szs_resincronizar_acceso_de_persona( $uid );
}

function szs_resincronizar_acceso_de_persona( string $uid ): void {
	global $wpdb;
	$tabla      = szs_tabla_personas();
	$wp_user_id = (int) $wpdb->get_var( $wpdb->prepare( "SELECT wp_user_id FROM {$tabla} WHERE uid = %s", $uid ) );
	if ( $wp_user_id > 0 ) {
		szs_sincronizar_acceso_panel( $wp_user_id );
	}
}

/**
 * Desactivar corta el acceso sin borrar la persona: sus tareas siguen
 * mostrando quién las hizo.
 */
function szs_activar_persona( string $uid, bool $activa ): void {
	global $wpdb;
	$wpdb->update( szs_tabla_personas(), array( 'activo' => $activa ? 1 : 0 ), array( 'uid' => $uid ), array( '%d' ), array( '%s' ) );
	szs_resincronizar_acceso_de_persona( $uid );
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
