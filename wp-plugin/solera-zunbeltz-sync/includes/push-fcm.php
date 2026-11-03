<?php
/**
 * Avisos al momento en la app de Android, con Firebase Cloud Messaging
 * (FCM, API HTTP v1). Son los mismos avisos que van por Web Push
 * (`push-web.php`: alarmas, peticiones, tareas asignadas) y se deciden allí;
 * aquí solo se guardan los tokens de los móviles y se envían.
 *
 * - La app registra el token de su móvil en `POST /push/fcm` con el token
 *   de la persona; lo quita con `DELETE /push/fcm` al cerrar la sesión.
 * - El servidor se identifica ante Google con la clave de una cuenta de
 *   servicio del proyecto de Firebase: un fichero JSON fuera de la raíz web
 *   cuya ruta se pone en `wp-config.php`:
 *       define( 'SZS_FCM_CREDENCIALES', '/ruta/privada/larrea-fcm.json' );
 *   Sin esa constante (o con un fichero que no vale) no se envía nada por
 *   FCM y los móviles siguen con la sincronización de cada ~15 min.
 * - Se manda un mensaje **solo de datos** (ya traducido al idioma del
 *   móvil): la app lo enseña con sus propias notificaciones y apunta la
 *   clave de lo avisado, para que la sincronización no lo repita.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_AMBITO_FCM       = 'https://www.googleapis.com/auth/firebase.messaging';
const SZS_URL_TOKEN_GOOGLE = 'https://oauth2.googleapis.com/token';
const SZS_TRANSITORIO_FCM  = 'szs_fcm_token_acceso';

add_action( 'rest_api_init', 'szs_registrar_rutas_push_fcm' );

function szs_tabla_tokens_fcm(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_TOKENS_FCM;
}

function szs_instalar_esquema_push_fcm( string $charset_collate ): void {
	$tabla = szs_tabla_tokens_fcm();
	dbDelta(
		"CREATE TABLE {$tabla} (
		token_hash CHAR(64) NOT NULL,
		persona_uid VARCHAR(64) NOT NULL DEFAULT '',
		token VARCHAR(512) NOT NULL DEFAULT '',
		idioma VARCHAR(8) NOT NULL DEFAULT 'es',
		creado_ms BIGINT NOT NULL DEFAULT 0,
		PRIMARY KEY  (token_hash),
		KEY persona_uid (persona_uid)
	) {$charset_collate};"
	);
}

// ============================================================
// Puro: credenciales, JWT de la cuenta de servicio, mensaje
// ============================================================

/**
 * Lo que hace falta de la clave de la cuenta de servicio, o null si no es
 * una clave de cuenta de servicio válida.
 *
 * @return array{proyecto: string, correo: string, clave_privada: string}|null
 */
function szs_leer_credenciales_fcm( string $json ): ?array {
	$datos = json_decode( $json, true );
	if ( ! is_array( $datos ) || 'service_account' !== ( $datos['type'] ?? '' ) ) {
		return null;
	}
	$proyecto = (string) ( $datos['project_id'] ?? '' );
	$correo   = (string) ( $datos['client_email'] ?? '' );
	$clave    = (string) ( $datos['private_key'] ?? '' );
	if ( ! preg_match( '/^[a-z0-9-]{4,40}$/', $proyecto ) || '' === $correo || false === openssl_pkey_get_private( $clave ) ) {
		return null;
	}
	return array(
		'proyecto'      => $proyecto,
		'correo'        => $correo,
		'clave_privada' => $clave,
	);
}

/** JWT firmado (RS256) con el que se pide a Google un token de acceso. */
function szs_jwt_cuenta_servicio( array $credenciales, int $ahora ): string {
	$cabecera = szs_base64url( (string) wp_json_encode( array( 'alg' => 'RS256', 'typ' => 'JWT' ) ) );
	$cuerpo   = szs_base64url(
		(string) wp_json_encode(
			array(
				'iss'   => $credenciales['correo'],
				'scope' => SZS_AMBITO_FCM,
				'aud'   => SZS_URL_TOKEN_GOOGLE,
				'iat'   => $ahora,
				'exp'   => $ahora + 3600,
			),
			JSON_UNESCAPED_SLASHES
		)
	);
	$firma = '';
	if ( ! openssl_sign( $cabecera . '.' . $cuerpo, $firma, $credenciales['clave_privada'], OPENSSL_ALGO_SHA256 ) ) {
		throw new RuntimeException( 'No se pudo firmar el JWT de la cuenta de servicio.' );
	}
	return $cabecera . '.' . $cuerpo . '.' . szs_base64url( $firma );
}

/** Un token de FCM tiene esta pinta; lo demás se rechaza. */
function szs_token_fcm_valido( string $token ): bool {
	return (bool) preg_match( '/^[A-Za-z0-9_:\-]{20,512}$/', $token );
}

/**
 * Cuerpo de `messages:send` para un móvil. Solo datos (todo texto), con
 * prioridad alta para que despierte al móvil en reposo.
 *
 * @param array{titulo: string, texto: string, etiqueta: string} $mensaje De `szs_mensaje_push`.
 */
function szs_cuerpo_mensaje_fcm( string $token, string $clase, string $clave, array $mensaje ): array {
	return array(
		'message' => array(
			'token'   => $token,
			'data'    => array(
				'clase'  => $clase,
				'clave'  => $clave,
				'titulo' => (string) $mensaje['titulo'],
				'texto'  => (string) $mensaje['texto'],
			),
			'android' => array(
				'priority' => 'HIGH',
				'ttl'      => SZS_VIDA_AVISO_PUSH_S . 's',
			),
		),
	);
}

/**
 * Si la respuesta de FCM dice que el token ya no sirve (app desinstalada,
 * datos borrados), para olvidarlo.
 */
function szs_token_fcm_caducado( int $codigo, string $cuerpo ): bool {
	if ( 404 === $codigo ) {
		return true;
	}
	if ( 400 !== $codigo ) {
		return false;
	}
	$datos = json_decode( $cuerpo, true );
	foreach ( (array) ( $datos['error']['details'] ?? array() ) as $detalle ) {
		// INVALID_ARGUMENT no: también sale por un mensaje mal hecho, y
		// entonces se borrarían todos los móviles.
		if ( 'UNREGISTERED' === ( $detalle['errorCode'] ?? '' ) ) {
			return true;
		}
	}
	return false;
}

// ============================================================
// WordPress: credenciales, rutas y envío
// ============================================================

/** Las credenciales configuradas, o null si FCM no está configurado. */
function szs_credenciales_fcm(): ?array {
	static $credenciales = false;
	if ( false !== $credenciales ) {
		return $credenciales;
	}
	$credenciales = null;
	if ( defined( 'SZS_FCM_CREDENCIALES' ) && is_readable( (string) SZS_FCM_CREDENCIALES ) ) {
		$credenciales = szs_leer_credenciales_fcm( (string) file_get_contents( (string) SZS_FCM_CREDENCIALES ) );
	}
	return $credenciales;
}

function szs_fcm_activo(): bool {
	return null !== szs_credenciales_fcm();
}

/** Token de acceso de Google (vale 1 h; se guarda 55 min). */
function szs_token_acceso_fcm( array $credenciales ): ?string {
	$guardado = get_transient( SZS_TRANSITORIO_FCM );
	if ( is_string( $guardado ) && '' !== $guardado ) {
		return $guardado;
	}
	try {
		$jwt = szs_jwt_cuenta_servicio( $credenciales, time() );
	} catch ( Throwable $error ) {
		return null;
	}
	$respuesta = wp_safe_remote_post(
		SZS_URL_TOKEN_GOOGLE,
		array(
			'timeout' => 10,
			'body'    => array(
				'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
				'assertion'  => $jwt,
			),
		)
	);
	$datos = json_decode( (string) wp_remote_retrieve_body( $respuesta ), true );
	$token = is_array( $datos ) ? (string) ( $datos['access_token'] ?? '' ) : '';
	if ( '' === $token ) {
		return null;
	}
	set_transient( SZS_TRANSITORIO_FCM, $token, 55 * MINUTE_IN_SECONDS );
	return $token;
}

function szs_registrar_rutas_push_fcm(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/push/fcm',
		array(
			array(
				'methods'             => 'POST',
				'callback'            => 'szs_endpoint_guardar_token_fcm',
				'permission_callback' => 'szs_permiso_token',
			),
			array(
				'methods'             => 'DELETE',
				'callback'            => 'szs_endpoint_borrar_token_fcm',
				'permission_callback' => 'szs_permiso_token',
			),
		)
	);
}

function szs_endpoint_guardar_token_fcm( WP_REST_Request $request ) {
	$persona = $request->get_param( 'szs_persona' );
	$cuerpo  = json_decode( $request->get_body(), true );
	$token   = is_array( $cuerpo ) ? (string) ( $cuerpo['token'] ?? '' ) : '';
	if ( ! szs_token_fcm_valido( $token ) ) {
		return new WP_Error( 'szs_token_fcm_invalido', 'Token de FCM no válido.', array( 'status' => 400 ) );
	}
	global $wpdb;
	// El mismo móvil con otra persona: pasa a ser de la nueva.
	$wpdb->replace(
		szs_tabla_tokens_fcm(),
		array(
			'token_hash'  => hash( 'sha256', $token ),
			'persona_uid' => (string) $persona['uid'],
			'token'       => $token,
			'idioma'      => 'eu' === ( $cuerpo['idioma'] ?? '' ) ? 'eu' : 'es',
			'creado_ms'   => szs_ahora_ms(),
		)
	);
	// `activo`: si el servidor tiene la clave de Firebase puesta.
	return rest_ensure_response(
		array(
			'ok'     => true,
			'activo' => szs_fcm_activo(),
		)
	);
}

function szs_endpoint_borrar_token_fcm( WP_REST_Request $request ) {
	$persona = $request->get_param( 'szs_persona' );
	$cuerpo  = json_decode( $request->get_body(), true );
	global $wpdb;
	$wpdb->delete(
		szs_tabla_tokens_fcm(),
		array(
			'token_hash'  => hash( 'sha256', is_array( $cuerpo ) ? (string) ( $cuerpo['token'] ?? '' ) : '' ),
			'persona_uid' => (string) $persona['uid'],
		)
	);
	return rest_ensure_response( array( 'ok' => true ) );
}

/**
 * Manda un aviso (de `szs_aviso_push_de_*`) a los móviles de sus
 * destinatarias. Lo llama `szs_enviar_push_pendientes` al terminar la
 * petición.
 */
function szs_enviar_fcm_aviso( array $aviso ): void {
	$credenciales = szs_credenciales_fcm();
	if ( null === $credenciales || empty( $aviso['destinatarios'] ) ) {
		return;
	}
	global $wpdb;
	$tabla      = szs_tabla_tokens_fcm();
	$marcadores = implode( ',', array_fill( 0, count( $aviso['destinatarios'] ), '%s' ) );
	$moviles    = (array) $wpdb->get_results(
		$wpdb->prepare( "SELECT * FROM {$tabla} WHERE persona_uid IN ({$marcadores})", $aviso['destinatarios'] ),
		ARRAY_A
	);
	if ( empty( $moviles ) ) {
		return;
	}
	$acceso = szs_token_acceso_fcm( $credenciales );
	if ( null === $acceso ) {
		return;
	}
	$url = 'https://fcm.googleapis.com/v1/projects/' . $credenciales['proyecto'] . '/messages:send';
	foreach ( $moviles as $movil ) {
		$mensaje   = szs_mensaje_push( $aviso['clase'], $aviso['titulo'], (string) $movil['idioma'] );
		$respuesta = wp_safe_remote_post(
			$url,
			array(
				'timeout' => 10,
				'headers' => array(
					'Authorization' => 'Bearer ' . $acceso,
					'Content-Type'  => 'application/json; charset=utf-8',
				),
				'body'    => (string) wp_json_encode(
					szs_cuerpo_mensaje_fcm( (string) $movil['token'], $aviso['clase'], (string) ( $aviso['clave'] ?? '' ), $mensaje ),
					JSON_UNESCAPED_UNICODE
				),
			)
		);
		$codigo = (int) wp_remote_retrieve_response_code( $respuesta );
		if ( 401 === $codigo ) {
			// Token de acceso caducado antes de tiempo: se pide otro la próxima vez.
			delete_transient( SZS_TRANSITORIO_FCM );
			return;
		}
		if ( szs_token_fcm_caducado( $codigo, (string) wp_remote_retrieve_body( $respuesta ) ) ) {
			$wpdb->delete( $tabla, array( 'token_hash' => (string) $movil['token_hash'] ) );
		}
	}
}
