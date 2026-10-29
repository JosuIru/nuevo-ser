<?php
/**
 * Tests de los avisos al momento de la app web (`includes/push-web.php`):
 * base64url, la firma ES256 del JWT de VAPID, el cifrado aes128gcm (se
 * descifra aquí como lo haría el navegador), los servicios de push
 * admitidos, la validación de la suscripción y a quién le toca cada aviso.
 * Sin WordPress.
 *
 * Ejecutar: php tests/test_push_web.php
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

// --- base64url ---
$bytes = random_bytes( 33 ) . "\xfb\xff";
afirmar( $bytes, szs_desde_base64url( szs_base64url( $bytes ) ), 'base64url ida y vuelta' );
afirmar( false, str_contains( szs_base64url( "\xfb\xff\xfe" ), '+' ) || str_contains( szs_base64url( "\xfb\xff\xfe" ), '/' ), 'base64url sin + ni /' );
afirmar( '', szs_desde_base64url( 'no válido!' ), 'base64url inválido' );

// --- JWT de VAPID: la firma r‖s verifica con la clave pública ---
$servidor = szs_crear_par_claves_p256();
afirmar( 65, strlen( $servidor['publica'] ), 'clave pública en bruto de 65 bytes' );
afirmar( true, szs_clave_publica_p256_valida( $servidor['publica'] ), 'clave pública válida' );
afirmar( false, szs_clave_publica_p256_valida( str_repeat( "\x04", 65 ) ), 'punto fuera de la curva' );
for ( $intento = 0; $intento < 20; $intento++ ) {
	$jwt                         = szs_jwt_vapid( 'https://fcm.googleapis.com', 'mailto:oficina@zunbeltz.com', 1800000000, $servidor['privada_pem'] );
	list( $cabecera, $cuerpo, $firma ) = explode( '.', $jwt );
	$firma_raw                   = szs_desde_base64url( $firma );
	afirmar( 64, strlen( $firma_raw ), 'firma ES256 de 64 bytes' );
	// r‖s → DER para que OpenSSL la compruebe.
	$entero_der = static function ( string $entero ): string {
		$entero = ltrim( $entero, "\0" );
		if ( '' === $entero || ord( $entero[0] ) >= 0x80 ) {
			$entero = "\0" . $entero;
		}
		return "\x02" . chr( strlen( $entero ) ) . $entero;
	};
	$secuencia = $entero_der( substr( $firma_raw, 0, 32 ) ) . $entero_der( substr( $firma_raw, 32 ) );
	afirmar( 1, openssl_verify( $cabecera . '.' . $cuerpo, "\x30" . chr( strlen( $secuencia ) ) . $secuencia, szs_clave_publica_p256_a_pem( $servidor['publica'] ), OPENSSL_ALGO_SHA256 ), 'la firma del JWT verifica' );
}
afirmar(
	array(
		'aud' => 'https://fcm.googleapis.com',
		'exp' => 1800000000,
		'sub' => 'mailto:oficina@zunbeltz.com',
	),
	json_decode( szs_desde_base64url( $cuerpo ), true ),
	'reclamaciones del JWT'
);
afirmar( 'https://web.push.apple.com', szs_audiencia_push( 'https://web.push.apple.com/QGe3/abc?x=1' ), 'audiencia = origen' );

// --- Cifrado: el navegador lo descifra (RFC 8291) ---
$navegador = szs_crear_par_claves_p256();
$auth      = random_bytes( 16 );
$mensaje   = '{"titulo":"Alarma en el espacio","texto":"Vaca suelta en la carretera — ñ"}';
$cifrado   = szs_cifrar_push( $mensaje, $navegador['publica'], $auth );

$sal              = substr( $cifrado, 0, 16 );
$tamano_registro  = unpack( 'N', substr( $cifrado, 16, 4 ) )[1];
$longitud_id      = ord( $cifrado[20] );
$publica_efimera  = substr( $cifrado, 21, $longitud_id );
$registro         = substr( $cifrado, 21 + $longitud_id );
afirmar( 4096, $tamano_registro, 'tamaño de registro' );
afirmar( 65, $longitud_id, 'la clave efímera va en la cabecera' );
$secreto  = openssl_pkey_derive( openssl_pkey_get_public( szs_clave_publica_p256_a_pem( $publica_efimera ) ), openssl_pkey_get_private( $navegador['privada_pem'] ), 32 );
$material = hash_hkdf( 'sha256', $secreto, 32, "WebPush: info\0" . $navegador['publica'] . $publica_efimera, $auth );
$claro    = openssl_decrypt(
	substr( $registro, 0, -16 ),
	'aes-128-gcm',
	hash_hkdf( 'sha256', $material, 16, "Content-Encoding: aes128gcm\0", $sal ),
	OPENSSL_RAW_DATA,
	hash_hkdf( 'sha256', $material, 12, "Content-Encoding: nonce\0", $sal ),
	substr( $registro, -16 )
);
afirmar( $mensaje . "\x02", $claro, 'el navegador descifra el mensaje (con el delimitador)' );
afirmar( false, $cifrado === szs_cifrar_push( $mensaje, $navegador['publica'], $auth ), 'cada envío lleva sal y clave efímera nuevas' );

// --- Servicios de push admitidos ---
foreach ( array(
	'https://fcm.googleapis.com/fcm/send/abc'            => true,
	'https://updates.push.services.mozilla.com/wpush/v2/x' => true,
	'https://web.push.apple.com/QGe3'                    => true,
	'https://wns2-db5p.notify.windows.com/w/?token=x'    => true,
	'http://fcm.googleapis.com/fcm/send/abc'             => false,
	'https://fcm.googleapis.com.malo.com/x'              => false,
	'https://evilpush.apple.com.example/x'               => false,
	'https://127.0.0.1/x'                                => false,
	'https://app.zunbeltz.com/wp-json/x'                 => false,
) as $endpoint => $esperado ) {
	afirmar( $esperado, szs_endpoint_push_valido( $endpoint ), "endpoint {$endpoint}" );
}

// --- Validar la suscripción que manda la app ---
$suscripcion = array(
	'endpoint' => 'https://fcm.googleapis.com/fcm/send/abc',
	'keys'     => array(
		'p256dh' => szs_base64url( $navegador['publica'] ),
		'auth'   => szs_base64url( $auth ),
	),
	'idioma'   => 'eu',
);
$validada = szs_validar_suscripcion_push( $suscripcion );
afirmar( 'eu', $validada['idioma'] ?? null, 'suscripción válida con su idioma' );
afirmar( 'es', szs_validar_suscripcion_push( array_merge( $suscripcion, array( 'idioma' => 'fr' ) ) )['idioma'], 'idioma desconocido → es' );
afirmar( 'servicio_push_desconocido', szs_validar_suscripcion_push( array_merge( $suscripcion, array( 'endpoint' => 'https://ejemplo.com/x' ) ) ), 'endpoint ajeno' );
afirmar( 'claves_invalidas', szs_validar_suscripcion_push( array_merge( $suscripcion, array( 'keys' => array( 'p256dh' => 'abc', 'auth' => 'abc' ) ) ) ), 'claves rotas' );
afirmar( 'cuerpo_invalido', szs_validar_suscripcion_push( null ), 'sin cuerpo' );

// --- A quién le toca ---
$personas = array(
	array( 'uid' => 'coord', 'rol' => SZS_ROL_COORDINADOR ),
	array( 'uid' => 'ane', 'rol' => SZS_ROL_TESTER ),
	array( 'uid' => 'mikel', 'rol' => SZS_ROL_TESTER ),
);
$alarma = array(
	'tipo'    => 'aviso',
	'uid'     => 'a1',
	'borrado' => false,
	'datos'   => array(
		'titulo'   => 'Vaca suelta',
		'gravedad' => 'alarma',
		'estado'   => 'abierto',
	),
);
afirmar(
	array(
		'clase'         => 'alarma',
		'titulo'        => 'Vaca suelta',
		'destinatarios' => array( 'coord', 'mikel' ),
	),
	szs_aviso_push_de_entidad( $alarma, null, 'ane', $personas ),
	'alarma nueva: a todo el mundo menos a quien la da'
);
afirmar( null, szs_aviso_push_de_entidad( $alarma, $alarma, 'ane', $personas ), 'una alarma editada no vuelve a sonar' );
$aviso_normal = $alarma;
$aviso_normal['datos']['gravedad'] = 'aviso';
afirmar( null, szs_aviso_push_de_entidad( $aviso_normal, null, 'ane', $personas ), 'un aviso normal no salta' );
afirmar( 'alarma', szs_aviso_push_de_entidad( $alarma, $aviso_normal, 'coord', $personas )['clase'] ?? null, 'un aviso que pasa a alarma sí' );
$cerrada = $alarma;
$cerrada['datos']['estado'] = 'resuelto';
afirmar( null, szs_aviso_push_de_entidad( $cerrada, null, 'ane', $personas ), 'una alarma ya cerrada no salta' );
$borrada = array_merge( $alarma, array( 'borrado' => true ) );
afirmar( null, szs_aviso_push_de_entidad( $borrada, null, 'ane', $personas ), 'lo borrado no salta' );

$peticion = array(
	'tipo'    => 'peticion',
	'uid'     => 'p1',
	'borrado' => false,
	'datos'   => array(
		'titulo'  => 'Arreglar el bebedero',
		'urgente' => true,
	),
);
afirmar(
	array(
		'clase'         => 'peticion_urgente',
		'titulo'        => 'Arreglar el bebedero',
		'destinatarios' => array( 'coord' ),
	),
	szs_aviso_push_de_entidad( $peticion, null, 'ane', $personas ),
	'petición: a coordinación'
);
afirmar( null, szs_aviso_push_de_entidad( $peticion, null, 'coord', $personas ), 'la petición de coordinación no le avisa a ella misma' );
afirmar( null, szs_aviso_push_de_entidad( $peticion, $peticion, 'ane', $personas ), 'una petición editada no avisa' );
afirmar( null, szs_aviso_push_de_entidad( array_merge( $alarma, array( 'tipo' => 'finca' ) ), null, 'ane', $personas ), 'otros tipos no avisan' );

$tarea = array(
	'uid'               => 't1',
	'titulo'            => 'Revisar el pastor eléctrico',
	'estado'            => 'pendiente',
	'responsable_uid'   => 'ane',
	'responsables_uids' => array( 'ane', 'mikel' ),
);
afirmar(
	array(
		'clase'         => 'tarea',
		'titulo'        => 'Revisar el pastor eléctrico',
		'destinatarios' => array( 'ane', 'mikel' ),
	),
	szs_aviso_push_de_tarea( $tarea, null, 'coord' ),
	'tarea nueva: a sus responsables'
);
$antes = array_merge( $tarea, array( 'responsables_uids' => array( 'ane' ) ) );
afirmar( array( 'mikel' ), szs_aviso_push_de_tarea( $tarea, $antes, 'coord' )['destinatarios'] ?? null, 'al cambiar responsables, solo a quien entra' );
afirmar( null, szs_aviso_push_de_tarea( $tarea, $tarea, 'coord' ), 'sin responsables nuevas, nada' );
afirmar( array( 'mikel' ), szs_aviso_push_de_tarea( $tarea, null, 'ane' )['destinatarios'] ?? null, 'quien se la asigna no se avisa' );
afirmar( null, szs_aviso_push_de_tarea( array_merge( $tarea, array( 'estado' => 'hecha' ) ), null, 'coord' ), 'una tarea hecha no avisa' );

// --- El mensaje, en el idioma de cada suscripción ---
afirmar(
	array(
		'titulo'   => 'Alarma gunean',
		'texto'    => 'Vaca suelta',
		'etiqueta' => 'zunbeltz-alarma',
	),
	szs_mensaje_push( 'alarma', 'Vaca suelta', 'eu' ),
	'mensaje en euskera'
);
afirmar( 'Tarea para ti', szs_mensaje_push( 'tarea', 'x', 'es' )['titulo'], 'mensaje en castellano' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} fallo(s) en test_push_web.\n" );
	exit( 1 );
}
echo "test_push_web: OK\n";
