<?php
/**
 * Avisos al momento en la versión web de la app (Web Push): en el
 * ordenador, en Android desde el navegador y en el iPhone con la app
 * añadida a la pantalla de inicio (iOS 16.4 o posterior).
 *
 * - La app pide permiso y se suscribe en el navegador; manda la
 *   suscripción a `POST /push/suscripcion` con el token de la persona.
 * - Cuando entra una alarma, una petición o una tarea para alguien, se
 *   manda al terminar la petición (como los correos) a cada suscripción de
 *   quien le toca. El service worker de la app (`sw_zunbeltz.js`) la enseña.
 * - Sin cuentas de terceros: el servidor se identifica con su propio par de
 *   claves VAPID (RFC 8292), que se crea solo la primera vez. El mensaje va
 *   cifrado de punta a punta (RFC 8291, aes128gcm): el servicio de push del
 *   navegador (Google, Mozilla, Apple) no puede leerlo.
 * - Solo se envía a los servicios de push conocidos
 *   (`SZS_SERVICIOS_PUSH`): una suscripción no puede hacer que el servidor
 *   llame a otra dirección.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_OPCION_VAPID = 'szs_push_web_vapid';

/** Cabecera DER de una clave pública P-256 sin comprimir (SubjectPublicKeyInfo). */
const SZS_PREFIJO_DER_CLAVE_P256 = '3059301306072a8648ce3d020106082a8648ce3d030107034200';

/** Dominios de los servicios de push de los navegadores. */
const SZS_SERVICIOS_PUSH = array(
	'fcm.googleapis.com',
	'push.services.mozilla.com',
	'push.apple.com',
	'notify.windows.com',
);

/** Cuánto guarda el servicio de push un aviso si el móvil está apagado. */
const SZS_VIDA_AVISO_PUSH_S = 12 * 3600;

add_action( 'rest_api_init', 'szs_registrar_rutas_push_web' );
add_action( 'szs_entidad_guardada', 'szs_avisar_por_push_entidad', 10, 3 );
add_action( 'szs_tarea_guardada', 'szs_avisar_por_push_tarea', 10, 3 );

function szs_tabla_suscripciones_push(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_SUSCRIPCIONES_PUSH;
}

function szs_instalar_esquema_push_web( string $charset_collate ): void {
	$tabla = szs_tabla_suscripciones_push();
	dbDelta(
		"CREATE TABLE {$tabla} (
		endpoint_hash CHAR(64) NOT NULL,
		persona_uid VARCHAR(64) NOT NULL DEFAULT '',
		endpoint TEXT NOT NULL,
		p256dh VARCHAR(200) NOT NULL DEFAULT '',
		auth VARCHAR(100) NOT NULL DEFAULT '',
		idioma VARCHAR(8) NOT NULL DEFAULT 'es',
		creada_ms BIGINT NOT NULL DEFAULT 0,
		PRIMARY KEY  (endpoint_hash),
		KEY persona_uid (persona_uid)
	) {$charset_collate};"
	);
}

// ============================================================
// Codificación y claves (puro)
// ============================================================

function szs_base64url( string $bytes ): string {
	return rtrim( strtr( base64_encode( $bytes ), '+/', '-_' ), '=' );
}

/** '' si no es base64url válido. */
function szs_desde_base64url( string $texto ): string {
	if ( ! preg_match( '/^[A-Za-z0-9_-]*={0,2}$/', $texto ) ) {
		return '';
	}
	$bytes = base64_decode( strtr( rtrim( $texto, '=' ), '-_', '+/' ), true );
	return false === $bytes ? '' : $bytes;
}

/**
 * Par de claves P-256 nuevo.
 *
 * @return array{privada_pem: string, publica: string} publica en bruto (65 bytes, 0x04‖x‖y).
 */
function szs_crear_par_claves_p256(): array {
	$clave = openssl_pkey_new(
		array(
			'private_key_type' => OPENSSL_KEYTYPE_EC,
			'curve_name'       => 'prime256v1',
		)
	);
	if ( false === $clave || ! openssl_pkey_export( $clave, $privada_pem ) ) {
		throw new RuntimeException( 'OpenSSL no puede crear claves P-256' );
	}
	$detalles = openssl_pkey_get_details( $clave );
	$publica  = "\x04" . str_pad( $detalles['ec']['x'], 32, "\0", STR_PAD_LEFT ) . str_pad( $detalles['ec']['y'], 32, "\0", STR_PAD_LEFT );
	return array(
		'privada_pem' => $privada_pem,
		'publica'     => $publica,
	);
}

/** PEM de una clave pública P-256 en bruto (65 bytes). */
function szs_clave_publica_p256_a_pem( string $publica ): string {
	$der = hex2bin( SZS_PREFIJO_DER_CLAVE_P256 ) . $publica;
	return "-----BEGIN PUBLIC KEY-----\n" . chunk_split( base64_encode( $der ), 64, "\n" ) . "-----END PUBLIC KEY-----\n";
}

/** Clave pública en bruto válida: 65 bytes que empiezan por 0x04 y están en la curva. */
function szs_clave_publica_p256_valida( string $publica ): bool {
	return 65 === strlen( $publica ) && "\x04" === $publica[0]
		&& false !== openssl_pkey_get_public( szs_clave_publica_p256_a_pem( $publica ) );
}

/**
 * Firma ECDSA de OpenSSL (DER: SEQUENCE { INTEGER r, INTEGER s }) a la
 * forma que pide JWS ES256: r‖s, 32 bytes cada uno.
 */
function szs_firma_der_a_raw( string $der ): string {
	$posicion = 2; // 0x30 y la longitud (< 128 en P-256).
	$partes   = array();
	for ( $i = 0; $i < 2; $i++ ) {
		$longitud  = ord( $der[ $posicion + 1 ] );
		$entero    = ltrim( substr( $der, $posicion + 2, $longitud ), "\0" );
		$partes[]  = str_pad( $entero, 32, "\0", STR_PAD_LEFT );
		$posicion += 2 + $longitud;
	}
	return $partes[0] . $partes[1];
}

/** JWT de VAPID (RFC 8292) firmado con ES256. */
function szs_jwt_vapid( string $audiencia, string $sujeto, int $caduca, string $privada_pem ): string {
	$cabecera = szs_base64url( (string) wp_json_encode( array( 'typ' => 'JWT', 'alg' => 'ES256' ) ) );
	$cuerpo   = szs_base64url(
		(string) wp_json_encode(
			array(
				'aud' => $audiencia,
				'exp' => $caduca,
				'sub' => $sujeto,
			),
			JSON_UNESCAPED_SLASHES
		)
	);
	$firmado = $cabecera . '.' . $cuerpo;
	if ( ! openssl_sign( $firmado, $firma_der, $privada_pem, OPENSSL_ALGO_SHA256 ) ) {
		throw new RuntimeException( 'No se pudo firmar el JWT de VAPID' );
	}
	return $firmado . '.' . szs_base64url( szs_firma_der_a_raw( $firma_der ) );
}

/** Origen (esquema + host) de la dirección de una suscripción: la «aud» del JWT. */
function szs_audiencia_push( string $endpoint ): string {
	$partes = wp_parse_url( $endpoint );
	return $partes['scheme'] . '://' . $partes['host'] . ( isset( $partes['port'] ) ? ':' . $partes['port'] : '' );
}

/** Solo https y de un servicio de push conocido. */
function szs_endpoint_push_valido( string $endpoint ): bool {
	$partes = wp_parse_url( $endpoint );
	if ( ! is_array( $partes ) || 'https' !== ( $partes['scheme'] ?? '' ) || empty( $partes['host'] ) || strlen( $endpoint ) > 2000 ) {
		return false;
	}
	$host = strtolower( $partes['host'] );
	foreach ( SZS_SERVICIOS_PUSH as $dominio ) {
		if ( $host === $dominio || str_ends_with( $host, '.' . $dominio ) ) {
			return true;
		}
	}
	return false;
}

/**
 * Cifra el mensaje para una suscripción (RFC 8291 con aes128gcm, RFC 8188):
 * cabecera (sal, tamaño de registro, clave pública efímera) y un único
 * registro cifrado.
 *
 * @param string $p256dh Clave pública del navegador, en bruto (65 bytes).
 * @param string $auth   Secreto de autenticación del navegador (16 bytes).
 */
function szs_cifrar_push( string $mensaje, string $p256dh, string $auth ): string {
	$efimera = szs_crear_par_claves_p256();
	$secreto = openssl_pkey_derive(
		openssl_pkey_get_public( szs_clave_publica_p256_a_pem( $p256dh ) ),
		openssl_pkey_get_private( $efimera['privada_pem'] ),
		32
	);
	if ( false === $secreto ) {
		throw new RuntimeException( 'ECDH fallido' );
	}
	$sal          = random_bytes( 16 );
	$material     = hash_hkdf( 'sha256', $secreto, 32, "WebPush: info\0" . $p256dh . $efimera['publica'], $auth );
	$clave        = hash_hkdf( 'sha256', $material, 16, "Content-Encoding: aes128gcm\0", $sal );
	$nonce        = hash_hkdf( 'sha256', $material, 12, "Content-Encoding: nonce\0", $sal );
	$etiqueta_gcm = '';
	// 0x02: delimitador del último (y único) registro.
	$cifrado = openssl_encrypt( $mensaje . "\x02", 'aes-128-gcm', $clave, OPENSSL_RAW_DATA, $nonce, $etiqueta_gcm, '', 16 );
	return $sal . pack( 'N', 4096 ) . chr( 65 ) . $efimera['publica'] . $cifrado . $etiqueta_gcm;
}

// ============================================================
// A quién y qué (puro)
// ============================================================

/**
 * Qué aviso toca por una entidad guardada y a quién, o null.
 * Una alarma nueva (o un aviso que pasa a alarma), a todo el mundo; una
 * petición nueva, a quien gestiona peticiones. Nunca a quien lo ha hecho.
 *
 * @param array<int, array{uid: string, rol: string}> $personas Activas.
 * @return array{clase: string, titulo: string, destinatarios: string[]}|null
 */
function szs_aviso_push_de_entidad( array $entidad, ?array $existente, string $autor_uid, array $personas ): ?array {
	if ( ! empty( $entidad['borrado'] ) ) {
		return null;
	}
	$datos = $entidad['datos'];
	if ( 'aviso' === $entidad['tipo'] ) {
		$era_alarma = null !== $existente && 'alarma' === ( $existente['datos']['gravedad'] ?? '' );
		if ( 'alarma' !== ( $datos['gravedad'] ?? '' ) || $era_alarma || 'abierto' !== ( $datos['estado'] ?? 'abierto' ) ) {
			return null;
		}
		$clase    = 'alarma';
		$elegidas = $personas;
	} elseif ( 'peticion' === $entidad['tipo'] && null === $existente ) {
		$clase    = ! empty( $datos['urgente'] ) ? 'peticion_urgente' : 'peticion';
		$elegidas = array_filter(
			$personas,
			static fn( array $persona ): bool => szs_puede( szs_capacidades_de_rol( (string) $persona['rol'] ), SZS_CAPACIDAD_GESTIONAR_PETICIONES )
		);
	} else {
		return null;
	}
	$destinatarios = array_values(
		array_diff( array_map( static fn( array $persona ): string => (string) $persona['uid'], $elegidas ), array( $autor_uid ) )
	);
	return empty( $destinatarios ) ? null : array(
		'clase'         => $clase,
		'titulo'        => szs_etiqueta_entidad( $entidad ),
		'destinatarios' => $destinatarios,
	);
}

/**
 * Una tarea con responsables nuevas (al crearla o al cambiarlas), para
 * ellas, salvo quien la ha guardado. Las hechas no avisan.
 *
 * @return array{clase: string, titulo: string, destinatarios: string[]}|null
 */
function szs_aviso_push_de_tarea( array $tarea, ?array $antes, string $autor_uid ): ?array {
	if ( 'hecha' === ( $tarea['estado'] ?? '' ) ) {
		return null;
	}
	$nuevas = array_diff(
		szs_responsables_de_tarea( $tarea ),
		null === $antes ? array() : szs_responsables_de_tarea( $antes ),
		array( $autor_uid, '' )
	);
	return empty( $nuevas ) ? null : array(
		'clase'         => 'tarea',
		'titulo'        => (string) $tarea['titulo'],
		'destinatarios' => array_values( $nuevas ),
	);
}

/**
 * El mensaje que enseña la notificación, en el idioma de la suscripción.
 *
 * @return array{titulo: string, texto: string, etiqueta: string}
 */
function szs_mensaje_push( string $clase, string $titulo, string $idioma ): array {
	return szs_con_idioma(
		$idioma,
		static function () use ( $clase, $titulo ): array {
			$encabezados = array(
				'alarma'           => szs_t( 'Alarma en el espacio' ),
				'peticion_urgente' => szs_t( 'Petición urgente' ),
				'peticion'         => szs_t( 'Petición nueva' ),
				'tarea'            => szs_t( 'Tarea para ti' ),
			);
			return array(
				'titulo'   => $encabezados[ $clase ] ?? 'Larrea Zunbeltz',
				'texto'    => szs_recortar( $titulo, 200 ),
				// Las de la misma clase se sustituyen en vez de amontonarse.
				'etiqueta' => 'zunbeltz-' . $clase,
			);
		}
	);
}

// ============================================================
// Claves VAPID, suscripciones y envío (WordPress)
// ============================================================

/** @return array{privada_pem: string, publica: string} La del servidor; se crea la primera vez. */
function szs_claves_vapid(): array {
	$guardadas = get_option( SZS_OPCION_VAPID );
	if ( is_array( $guardadas ) && ! empty( $guardadas['privada_pem'] ) && ! empty( $guardadas['publica'] ) ) {
		return array(
			'privada_pem' => (string) $guardadas['privada_pem'],
			'publica'     => szs_desde_base64url( (string) $guardadas['publica'] ),
		);
	}
	$nuevas = szs_crear_par_claves_p256();
	update_option(
		SZS_OPCION_VAPID,
		array(
			'privada_pem' => $nuevas['privada_pem'],
			'publica'     => szs_base64url( $nuevas['publica'] ),
		),
		false
	);
	return $nuevas;
}

function szs_registrar_rutas_push_web(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/push/clave',
		array(
			'methods'             => 'GET',
			'callback'            => static fn() => rest_ensure_response( array( 'clave_publica' => szs_base64url( szs_claves_vapid()['publica'] ) ) ),
			'permission_callback' => '__return_true',
		)
	);
	register_rest_route(
		'solera-zunbeltz/v1',
		'/push/suscripcion',
		array(
			array(
				'methods'             => 'POST',
				'callback'            => 'szs_endpoint_guardar_suscripcion_push',
				'permission_callback' => 'szs_permiso_token',
			),
			array(
				'methods'             => 'DELETE',
				'callback'            => 'szs_endpoint_borrar_suscripcion_push',
				'permission_callback' => 'szs_permiso_token',
			),
		)
	);
}

/**
 * Suscripción recibida de la app, validada, o un código de error.
 *
 * @return array{endpoint: string, p256dh: string, auth: string, idioma: string}|string
 */
function szs_validar_suscripcion_push( $cuerpo ) {
	if ( ! is_array( $cuerpo ) ) {
		return 'cuerpo_invalido';
	}
	$endpoint = (string) ( $cuerpo['endpoint'] ?? '' );
	if ( ! szs_endpoint_push_valido( $endpoint ) ) {
		return 'servicio_push_desconocido';
	}
	$claves = is_array( $cuerpo['keys'] ?? null ) ? $cuerpo['keys'] : array();
	$p256dh = szs_desde_base64url( (string) ( $claves['p256dh'] ?? '' ) );
	$auth   = szs_desde_base64url( (string) ( $claves['auth'] ?? '' ) );
	if ( ! szs_clave_publica_p256_valida( $p256dh ) || 16 !== strlen( $auth ) ) {
		return 'claves_invalidas';
	}
	return array(
		'endpoint' => $endpoint,
		'p256dh'   => szs_base64url( $p256dh ),
		'auth'     => szs_base64url( $auth ),
		'idioma'   => 'eu' === ( $cuerpo['idioma'] ?? '' ) ? 'eu' : 'es',
	);
}

function szs_endpoint_guardar_suscripcion_push( WP_REST_Request $request ) {
	$persona     = $request->get_param( 'szs_persona' );
	$suscripcion = szs_validar_suscripcion_push( json_decode( $request->get_body(), true ) );
	if ( is_string( $suscripcion ) ) {
		return new WP_Error( 'szs_' . $suscripcion, 'Suscripción no válida.', array( 'status' => 400 ) );
	}
	global $wpdb;
	// El mismo navegador con otra persona: pasa a ser de la nueva.
	$wpdb->replace(
		szs_tabla_suscripciones_push(),
		array(
			'endpoint_hash' => hash( 'sha256', $suscripcion['endpoint'] ),
			'persona_uid'   => (string) $persona['uid'],
			'endpoint'      => $suscripcion['endpoint'],
			'p256dh'        => $suscripcion['p256dh'],
			'auth'          => $suscripcion['auth'],
			'idioma'        => $suscripcion['idioma'],
			'creada_ms'     => szs_ahora_ms(),
		)
	);
	return rest_ensure_response( array( 'ok' => true ) );
}

function szs_endpoint_borrar_suscripcion_push( WP_REST_Request $request ) {
	$persona = $request->get_param( 'szs_persona' );
	$cuerpo  = json_decode( $request->get_body(), true );
	global $wpdb;
	$wpdb->delete(
		szs_tabla_suscripciones_push(),
		array(
			'endpoint_hash' => hash( 'sha256', (string) ( $cuerpo['endpoint'] ?? '' ) ),
			'persona_uid'   => (string) $persona['uid'],
		)
	);
	return rest_ensure_response( array( 'ok' => true ) );
}

function szs_avisar_por_push_entidad( array $entidad, ?array $existente, array $persona ): void {
	$aviso = szs_aviso_push_de_entidad( $entidad, $existente, (string) ( $persona['uid'] ?? '' ), szs_listar_personas() );
	if ( null !== $aviso ) {
		szs_encolar_push( $aviso );
	}
}

function szs_avisar_por_push_tarea( array $tarea, ?array $antes, array $persona ): void {
	$aviso = szs_aviso_push_de_tarea( $tarea, $antes, (string) ( $persona['uid'] ?? '' ) );
	if ( null !== $aviso ) {
		szs_encolar_push( $aviso );
	}
}

/** @var array<int, array{clase: string, titulo: string, destinatarios: string[]}> */
$GLOBALS['szs_push_pendientes'] = array();

/** Se mandan al terminar la petición, ya soltado el candado del espacio. */
function szs_encolar_push( array $aviso ): void {
	if ( empty( $GLOBALS['szs_push_pendientes'] ) ) {
		add_action( 'shutdown', 'szs_enviar_push_pendientes' );
	}
	$GLOBALS['szs_push_pendientes'][] = $aviso;
}

function szs_enviar_push_pendientes(): void {
	$pendientes                     = $GLOBALS['szs_push_pendientes'];
	$GLOBALS['szs_push_pendientes'] = array();
	if ( empty( $pendientes ) ) {
		return;
	}
	global $wpdb;
	$tabla = szs_tabla_suscripciones_push();
	foreach ( $pendientes as $aviso ) {
		$marcadores    = implode( ',', array_fill( 0, count( $aviso['destinatarios'] ), '%s' ) );
		$suscripciones = (array) $wpdb->get_results(
			$wpdb->prepare( "SELECT * FROM {$tabla} WHERE persona_uid IN ({$marcadores})", $aviso['destinatarios'] ),
			ARRAY_A
		);
		foreach ( $suscripciones as $suscripcion ) {
			szs_enviar_push( $suscripcion, szs_mensaje_push( $aviso['clase'], $aviso['titulo'], (string) $suscripcion['idioma'] ) );
		}
	}
}

/**
 * Manda un aviso a una suscripción. Si el servicio dice que ya no existe
 * (404/410: permiso retirado, navegador borrado), se olvida.
 */
function szs_enviar_push( array $suscripcion, array $mensaje ): bool {
	$endpoint = (string) $suscripcion['endpoint'];
	if ( ! szs_endpoint_push_valido( $endpoint ) ) {
		return false;
	}
	try {
		$claves = szs_claves_vapid();
		$cuerpo = szs_cifrar_push(
			(string) wp_json_encode( $mensaje, JSON_UNESCAPED_UNICODE ),
			szs_desde_base64url( (string) $suscripcion['p256dh'] ),
			szs_desde_base64url( (string) $suscripcion['auth'] )
		);
		$jwt    = szs_jwt_vapid(
			szs_audiencia_push( $endpoint ),
			'mailto:' . get_option( 'admin_email' ),
			time() + SZS_VIDA_AVISO_PUSH_S,
			$claves['privada_pem']
		);
	} catch ( Throwable $error ) {
		return false;
	}
	$respuesta = wp_safe_remote_post(
		$endpoint,
		array(
			'timeout' => 10,
			'headers' => array(
				'Authorization'    => 'vapid t=' . $jwt . ', k=' . szs_base64url( $claves['publica'] ),
				'Content-Encoding' => 'aes128gcm',
				'Content-Type'     => 'application/octet-stream',
				'TTL'              => (string) SZS_VIDA_AVISO_PUSH_S,
				'Urgency'          => 'high',
			),
			'body'    => $cuerpo,
		)
	);
	$codigo = (int) wp_remote_retrieve_response_code( $respuesta );
	if ( 404 === $codigo || 410 === $codigo ) {
		global $wpdb;
		$wpdb->delete( szs_tabla_suscripciones_push(), array( 'endpoint_hash' => hash( 'sha256', $endpoint ) ) );
	}
	return $codigo >= 200 && $codigo < 300;
}
