<?php
/**
 * Tests de los permisos de la página Personas: solo quien tiene
 * `manage_options` enlaza una persona con un usuario de WordPress o le da
 * acceso al panel; coordinación sin ese permiso sigue dando de alta,
 * cambiando el rol, el correo y desactivando. Se prueba la acción del
 * formulario (`szs_procesar_accion_admin`) tal como llega al servidor, con
 * una BD falsa en memoria. Sin WordPress.
 *
 * Ejecutar: php tests/test_personas.php
 */

define( 'ABSPATH', __DIR__ );
define( 'ARRAY_A', 'ARRAY_A' );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $valor;
}
function sanitize_text_field( $texto ) {
	return trim( (string) $texto );
}
function sanitize_key( $texto ) {
	return strtolower( preg_replace( '/[^a-z0-9_\-]/i', '', (string) $texto ) );
}
function sanitize_email( $texto ) {
	return trim( (string) $texto );
}
function wp_unslash( $valor ) {
	return $valor;
}
function check_admin_referer( $accion ) {
	return true;
}

/** Usuario conectado: ¿administra el WordPress? */
$administra_wordpress = false;
function current_user_can( $capacidad ) {
	return 'manage_options' === $capacidad && $GLOBALS['administra_wordpress'];
}

/** Usuario de WordPress falso con capacidades propias. */
class UsuarioFalso {
	public array $caps = array();
	public function __construct( public int $ID, public bool $es_administrador = false, public string $locale = 'es_ES', public string $user_email = '' ) {}
	public function add_cap( $capacidad ) {
		$this->caps[ $capacidad ] = true;
	}
	public function remove_cap( $capacidad ) {
		unset( $this->caps[ $capacidad ] );
	}
	public function has_cap( $capacidad ) {
		return $this->es_administrador || ! empty( $this->caps[ $capacidad ] );
	}
}
$usuarios_wp = array(
	10 => new UsuarioFalso( 10, false, 'eu', 'ane@wp.eus' ),
	11 => new UsuarioFalso( 11 ),
	12 => new UsuarioFalso( 12, true ),
);
function get_user_locale( $id = 0 ) {
	return 0 === $id ? 'es_ES' : $GLOBALS['usuarios_wp'][ (int) $id ]->locale;
}
function get_locale() {
	return 'es_ES';
}
function get_userdata( $id ) {
	return $GLOBALS['usuarios_wp'][ (int) $id ] ?? false;
}

/** BD falsa: solo la tabla de personas y las consultas que usa personas.php. */
class BdFalsa {
	public string $prefix = 'wp_';
	public array $personas = array();
	public function prepare( $sql, ...$argumentos ) {
		return array( $sql, $argumentos );
	}
	private function filas( array $consulta ): array {
		list( $sql, $argumentos ) = $consulta;
		$filas = array_values( $this->personas );
		if ( str_contains( $sql, 'WHERE uid = %s' ) ) {
			$filas = array_filter( $filas, static fn( $fila ) => $fila['uid'] === $argumentos[0] );
		}
		if ( str_contains( $sql, 'WHERE wp_user_id = %d' ) ) {
			$filas = array_filter( $filas, static fn( $fila ) => (int) $fila['wp_user_id'] === (int) $argumentos[0] );
		}
		if ( str_contains( $sql, 'activo = 1' ) ) {
			$filas = array_filter( $filas, static fn( $fila ) => 1 === (int) $fila['activo'] );
		}
		return array_values( $filas );
	}
	public function get_var( $consulta ) {
		$fila = $this->filas( $consulta )[0] ?? null;
		if ( null === $fila ) {
			return null;
		}
		preg_match( '/SELECT (\w+)/', $consulta[0], $columna );
		return (string) $fila[ $columna[1] ];
	}
	public function get_row( $consulta, $formato = null ) {
		return $this->filas( $consulta )[0] ?? null;
	}
	public function get_results( $sql, $formato = null ) {
		return array_values( $this->personas );
	}
	public function update( $tabla, $datos, $donde, $formatos = null, $formatos_donde = null ) {
		$uid = $donde['uid'];
		if ( isset( $this->personas[ $uid ] ) ) {
			$this->personas[ $uid ] = array_merge( $this->personas[ $uid ], $datos );
		}
		return 1;
	}
	public function insert( $tabla, $datos, $formatos = null ) {
		$this->personas[ $datos['uid'] ] = array_merge( array( 'wp_user_id' => 0, 'correo' => '' ), $datos );
		return 1;
	}
}
$wpdb = new BdFalsa();

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

/** Envía el formulario de Personas como lo haría el navegador. */
function enviar_formulario( array $campos ): ?array {
	$_SERVER['REQUEST_METHOD'] = 'POST';
	$_POST                     = $campos;
	return szs_procesar_accion_admin();
}

function persona( string $uid ): array {
	return $GLOBALS['wpdb']->personas[ $uid ];
}

function tiene_panel( int $wp_user_id ): bool {
	return $GLOBALS['usuarios_wp'][ $wp_user_id ]->has_cap( SZS_CAPACIDAD_WP_PANEL );
}

$wpdb->personas = array(
	'ane'   => array( 'uid' => 'ane', 'nombre' => 'Ane', 'rol' => SZS_ROL_COORDINADOR, 'activo' => 1, 'wp_user_id' => 0, 'correo' => '' ),
	'mikel' => array( 'uid' => 'mikel', 'nombre' => 'Mikel', 'rol' => SZS_ROL_TESTER, 'activo' => 1, 'wp_user_id' => 0, 'correo' => '' ),
);

// --- coordinación sin manage_options ---
$administra_wordpress = false;
afirmar( false, szs_puede_dar_acceso_panel(), 'sin manage_options no se da acceso al panel' );

$aviso = enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '10', 'szs_correo' => 'ane@zunbeltz.eus' ) );
afirmar( 'warning', $aviso[0], 'enlazar sin manage_options avisa' );
afirmar( 0, (int) persona( 'ane' )['wp_user_id'], '… y el enlace no cambia (aunque el formulario lo mande)' );
afirmar( 'ane@zunbeltz.eus', persona( 'ane' )['correo'], '… pero el correo sí se guarda' );
afirmar( false, tiene_panel( 10 ), '… y el usuario no recibe acceso al panel' );

$aviso = enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '0', 'szs_correo' => 'ane2@zunbeltz.eus' ) );
afirmar( 'success', $aviso[0], 'guardar solo el correo (enlace igual) no es un cambio de acceso' );

$aviso = enviar_formulario( array( 'szs_accion' => 'crear', 'szs_nombre' => 'Elena', 'szs_rol' => SZS_ROL_TESTER ) );
afirmar( 'success', $aviso[0], 'coordinación sin manage_options da de alta personas' );
afirmar( true, is_string( $aviso[2] ) && strlen( $aviso[2] ) > 20, '… y ve su clave de usuario' );

// --- la administradora enlaza ---
$administra_wordpress = true;
$aviso                = enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '10', 'szs_correo' => '' ) );
afirmar( 'success', $aviso[0], 'con manage_options se enlaza' );
afirmar( 10, (int) persona( 'ane' )['wp_user_id'], '… el enlace queda guardado' );
afirmar( true, tiene_panel( 10 ), '… y la persona de coordinación entra al panel' );
enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'mikel', 'szs_wp_user_id' => '11', 'szs_correo' => '' ) );
afirmar( false, tiene_panel( 11 ), 'una tester enlazada no recibe acceso al panel' );

// --- coordinación sin manage_options no puede quitar ni mover el enlace ---
$administra_wordpress = false;
$aviso                = enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '0', 'szs_correo' => '' ) );
afirmar( 'warning', $aviso[0], 'quitar el enlace sin manage_options avisa' );
afirmar( 10, (int) persona( 'ane' )['wp_user_id'], '… y el enlace sigue' );
afirmar( true, tiene_panel( 10 ), '… y el acceso también' );
enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '11', 'szs_correo' => '' ) );
afirmar( 10, (int) persona( 'ane' )['wp_user_id'], 'tampoco se puede mover el enlace a otro usuario' );

// --- rol y desactivar siguen siendo de coordinación; dar acceso no ---
$aviso = enviar_formulario( array( 'szs_accion' => 'cambiar_rol', 'szs_uid' => 'mikel', 'szs_rol' => SZS_ROL_COORDINADOR ) );
afirmar( SZS_ROL_COORDINADOR, persona( 'mikel' )['rol'], 'coordinación sin manage_options cambia el rol' );
afirmar( false, tiene_panel( 11 ), '… pero ascender a una persona enlazada no le abre el panel' );
afirmar( 'warning', $aviso[0], '… y lo avisa' );

$aviso = enviar_formulario( array( 'szs_accion' => 'desactivar', 'szs_uid' => 'ane' ) );
afirmar( 'success', $aviso[0], 'desactivar sigue siendo de coordinación' );
afirmar( 0, (int) persona( 'ane' )['activo'], '… la persona queda desactivada' );
afirmar( false, tiene_panel( 10 ), '… y pierde el acceso al panel (quitarlo al desactivar siempre se hace)' );

$aviso = enviar_formulario( array( 'szs_accion' => 'activar', 'szs_uid' => 'ane' ) );
afirmar( 1, (int) persona( 'ane' )['activo'], 'reactivar también' );
afirmar( false, tiene_panel( 10 ), '… pero devolver el acceso al panel no' );
afirmar( 'warning', $aviso[0], '… y lo avisa' );

// --- la administradora vuelve a guardar el enlace: acceso al día ---
$administra_wordpress = true;
enviar_formulario( array( 'szs_accion' => 'enlazar', 'szs_uid' => 'ane', 'szs_wp_user_id' => '10', 'szs_correo' => '' ) );
afirmar( true, tiene_panel( 10 ), 'al volver a guardar el enlace, la administradora le devuelve el acceso' );
$aviso = enviar_formulario( array( 'szs_accion' => 'cambiar_rol', 'szs_uid' => 'ane', 'szs_rol' => SZS_ROL_TESTER ) );
afirmar( false, tiene_panel( 10 ), 'pasar a tester quita el acceso' );
afirmar( 'success', $aviso[0], '… sin aviso' );

// --- un administrador del WordPress ya tiene el panel por su rol ---
$administra_wordpress = false;
$wpdb->personas['jefa'] = array( 'uid' => 'jefa', 'nombre' => 'Jefa', 'rol' => SZS_ROL_COORDINADOR, 'activo' => 0, 'wp_user_id' => 12, 'correo' => '' );
$aviso                  = enviar_formulario( array( 'szs_accion' => 'activar', 'szs_uid' => 'jefa' ) );
afirmar( 'success', $aviso[0], 'reactivar a quien ya entra por ser administradora no avisa' );

// --- correos a coordinación, cada cual en el idioma de su usuario de WordPress ---
$wpdb->personas['ane']['rol']    = SZS_ROL_COORDINADOR;
$wpdb->personas['ane']['correo'] = '';
$wpdb->personas['mikel']['correo'] = 'mikel@zunbeltz.eus';
afirmar(
	array(
		'eu' => array( 'ane@wp.eus' ),
		'es' => array( 'mikel@zunbeltz.eus' ),
	),
	szs_correos_coordinacion_por_idioma(),
	'correos por idioma: el del usuario enlazado (eu) o el del sitio; sin correo propio, el del usuario'
);
afirmar( array( 'ane@wp.eus', 'mikel@zunbeltz.eus' ), szs_correos_coordinacion(), 'todos los correos de coordinación' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "\n%d fallo(s) en test_personas.\n", $fallos );
	exit( 1 );
}
echo "test_personas: OK\n";
