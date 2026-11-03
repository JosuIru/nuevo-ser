<?php
/**
 * Tests de los avisos por FCM a la app de Android (`includes/push-fcm.php`):
 * lectura de la clave de la cuenta de servicio, el JWT RS256 que se cambia
 * por un token de acceso (la firma verifica con la clave pública), el
 * cuerpo del mensaje, los tokens admitidos y cuándo se olvida un móvil.
 * Con una clave RSA generada aquí, nunca la real. Sin WordPress.
 *
 * Ejecutar: php tests/test_push_fcm.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $valor;
}
function wp_json_encode( $valor, $opciones = 0 ) {
	return json_encode( $valor, $opciones );
}
function wp_parse_url( $url, $componente = -1 ) {
	return parse_url( $url, $componente );
}
function sanitize_text_field( $texto ) {
	return trim( (string) $texto );
}
function get_user_locale() {
	return 'es_ES';
}

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

// --- Clave de la cuenta de servicio ---
$rsa = openssl_pkey_new( array( 'private_key_type' => OPENSSL_KEYTYPE_RSA, 'private_key_bits' => 2048 ) );
openssl_pkey_export( $rsa, $privada_pem );
$publica_pem = openssl_pkey_get_details( $rsa )['key'];
$json_cuenta = json_encode(
	array(
		'type'         => 'service_account',
		'project_id'   => 'larrea-zunbeltz',
		'private_key'  => $privada_pem,
		'client_email' => 'firebase-adminsdk@larrea-zunbeltz.iam.gserviceaccount.com',
	)
);
$credenciales = szs_leer_credenciales_fcm( $json_cuenta );
afirmar( 'larrea-zunbeltz', $credenciales['proyecto'] ?? null, 'lee el proyecto' );
afirmar( 'firebase-adminsdk@larrea-zunbeltz.iam.gserviceaccount.com', $credenciales['correo'] ?? null, 'lee el correo de la cuenta' );
afirmar( null, szs_leer_credenciales_fcm( '{"type":"authorized_user"}' ), 'otro tipo de credencial no vale' );
afirmar( null, szs_leer_credenciales_fcm( 'no es json' ), 'JSON roto' );
afirmar( null, szs_leer_credenciales_fcm( str_replace( 'larrea-zunbeltz"', 'otro/../x"', $json_cuenta ) ), 'proyecto con caracteres raros' );
$sin_clave = json_decode( $json_cuenta, true );
$sin_clave['private_key'] = 'nada';
afirmar( null, szs_leer_credenciales_fcm( json_encode( $sin_clave ) ), 'clave privada que no es clave' );

// --- JWT RS256 ---
$jwt = szs_jwt_cuenta_servicio( $credenciales, 1800000000 );
list( $cabecera, $cuerpo, $firma ) = explode( '.', $jwt );
afirmar( array( 'alg' => 'RS256', 'typ' => 'JWT' ), json_decode( szs_desde_base64url( $cabecera ), true ), 'cabecera RS256' );
afirmar(
	array(
		'iss'   => 'firebase-adminsdk@larrea-zunbeltz.iam.gserviceaccount.com',
		'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
		'aud'   => 'https://oauth2.googleapis.com/token',
		'iat'   => 1800000000,
		'exp'   => 1800003600,
	),
	json_decode( szs_desde_base64url( $cuerpo ), true ),
	'reclamaciones del JWT'
);
afirmar( 1, openssl_verify( $cabecera . '.' . $cuerpo, szs_desde_base64url( $firma ), $publica_pem, OPENSSL_ALGO_SHA256 ), 'la firma verifica con la clave pública' );

// --- Tokens admitidos ---
afirmar( true, szs_token_fcm_valido( 'dQw4w9WgXcQ:APA91bH' . str_repeat( 'x_-', 40 ) ), 'token de FCM normal' );
afirmar( false, szs_token_fcm_valido( 'corto' ), 'demasiado corto' );
afirmar( false, szs_token_fcm_valido( str_repeat( 'a', 30 ) . ' ' ), 'con espacio' );
afirmar( false, szs_token_fcm_valido( str_repeat( 'a', 30 ) . '"}' ), 'con comillas' );
afirmar( false, szs_token_fcm_valido( str_repeat( 'a', 513 ) ), 'demasiado largo' );

// --- Cuerpo del mensaje ---
$mensaje = szs_mensaje_push( 'alarma', 'Vaca suelta', 'eu' );
afirmar(
	array(
		'message' => array(
			'token'   => 'tok',
			'data'    => array(
				'clase'  => 'alarma',
				'clave'  => 'aviso|a1',
				'titulo' => 'Alarma gunean',
				'texto'  => 'Vaca suelta',
			),
			'android' => array(
				'priority' => 'HIGH',
				'ttl'      => '43200s',
			),
		),
	),
	szs_cuerpo_mensaje_fcm( 'tok', 'alarma', 'aviso|a1', $mensaje ),
	'solo datos, traducido, con prioridad alta'
);

// --- Cuándo se olvida un móvil ---
$no_registrado = json_encode( array( 'error' => array( 'details' => array( array( 'errorCode' => 'UNREGISTERED' ) ) ) ) );
$argumento     = json_encode( array( 'error' => array( 'details' => array( array( 'errorCode' => 'INVALID_ARGUMENT' ) ) ) ) );
afirmar( true, szs_token_fcm_caducado( 404, '' ), '404' );
afirmar( true, szs_token_fcm_caducado( 400, $no_registrado ), '400 UNREGISTERED' );
afirmar( false, szs_token_fcm_caducado( 400, $argumento ), 'un mensaje mal hecho no borra el móvil' );
afirmar( false, szs_token_fcm_caducado( 500, '' ), 'error de Google' );
afirmar( false, szs_token_fcm_caducado( 200, '' ), 'enviado' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} fallo(s) en test_push_fcm.\n" );
	exit( 1 );
}
echo "test_push_fcm: OK\n";
