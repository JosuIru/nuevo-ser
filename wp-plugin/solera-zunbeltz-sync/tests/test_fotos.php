<?php
/**
 * Tests de las fotos sincronizadas (`includes/fotos.php`): validación de
 * la subida (cabecera real, tamaño, hash, espacio total), listas de
 * hashes, permisos de las fotos de tareas y puntos, y la subida de punta a
 * punta contra una carpeta temporal (guardar, deduplicar, carpeta
 * protegida, tope). Sin WordPress: stubs mínimos.
 *
 * Ejecutar: php tests/test_fotos.php
 */

define( 'ABSPATH', __DIR__ );

$GLOBALS['opciones_de_prueba'] = array();
$GLOBALS['filtros_de_prueba']  = array();
$GLOBALS['subidas_de_prueba']  = sys_get_temp_dir() . '/szs-test-fotos-' . bin2hex( random_bytes( 4 ) );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $GLOBALS['filtros_de_prueba'][ $hook ] ?? $valor;
}
function sanitize_text_field( $texto ) {
	return trim( (string) $texto );
}
function sanitize_textarea_field( $texto ) {
	return trim( (string) $texto );
}
function get_option( $nombre, $por_defecto = false ) {
	return $GLOBALS['opciones_de_prueba'][ $nombre ] ?? $por_defecto;
}
function update_option( $nombre, $valor, $autoload = null ) {
	$GLOBALS['opciones_de_prueba'][ $nombre ] = $valor;
	return true;
}
function wp_upload_dir( $tiempo = null, $crear = true ) {
	return array( 'basedir' => $GLOBALS['subidas_de_prueba'] );
}
function untrailingslashit( $texto ) {
	return rtrim( $texto, '/\\' );
}
function trailingslashit( $texto ) {
	return rtrim( $texto, '/\\' ) . '/';
}
function wp_mkdir_p( $ruta ) {
	return is_dir( $ruta ) || mkdir( $ruta, 0777, true );
}

class WP_REST_Request {
	public function __construct( private array $parametros, private string $cuerpo = '' ) {}
	public function get_param( $clave ) {
		return $this->parametros[ $clave ] ?? null;
	}
	public function get_body() {
		return $this->cuerpo;
	}
}
class WP_REST_Response {
	public function __construct( public $data = null, public int $status = 200 ) {}
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

$jpeg = "\xFF\xD8\xFF\xE0" . str_repeat( 'x', 100 );
$png  = "\x89PNG\r\n\x1A\n" . str_repeat( 'y', 50 );
$webp = 'RIFF' . "\x10\x00\x00\x00" . 'WEBP' . 'VP8 ' . str_repeat( 'z', 20 );
$hash_jpeg = hash( 'sha256', $jpeg );

// --- cabecera real ---
afirmar( 'image/jpeg', szs_tipo_mime_imagen( $jpeg ), 'JPEG por su cabecera' );
afirmar( 'image/png', szs_tipo_mime_imagen( $png ), 'PNG por su cabecera' );
afirmar( 'image/webp', szs_tipo_mime_imagen( $webp ), 'WebP por su cabecera' );
afirmar( null, szs_tipo_mime_imagen( 'GIF89a' . str_repeat( 'g', 20 ) ), 'GIF no se admite' );
afirmar( null, szs_tipo_mime_imagen( '<?php echo 1; ?>' ), 'un PHP con extensión .jpg no es una imagen' );
afirmar( null, szs_tipo_mime_imagen( 'RIFF0000WAVE' ), 'RIFF que no es WebP no se admite' );

// --- validación de la subida ---
$mb = 1024 * 1024;
$v  = szs_validar_subida_foto( $hash_jpeg, $jpeg, 2 * $mb, 0, 10 * $mb, false );
afirmar( array( true, 201, 'guardada', 'image/jpeg' ), array( $v['ok'], $v['estado'], $v['codigo'], $v['mime'] ), 'JPEG válido se guarda' );
afirmar( 400, szs_validar_subida_foto( 'abc', $jpeg, 2 * $mb, 0, 10 * $mb, false )['estado'], 'hash mal formado: 400' );
afirmar( 400, szs_validar_subida_foto( strtoupper( $hash_jpeg ), $jpeg, 2 * $mb, 0, 10 * $mb, false )['estado'], 'hash en mayúsculas: 400' );
afirmar( 'vacia', szs_validar_subida_foto( hash( 'sha256', '' ), '', 2 * $mb, 0, 10 * $mb, false )['codigo'], 'cuerpo vacío' );
afirmar( 413, szs_validar_subida_foto( $hash_jpeg, $jpeg, 50, 0, 10 * $mb, false )['estado'], 'más grande que el máximo: 413' );
$texto = 'no soy una foto';
afirmar( 415, szs_validar_subida_foto( hash( 'sha256', $texto ), $texto, 2 * $mb, 0, 10 * $mb, false )['estado'], 'sin cabecera de imagen: 415' );
afirmar( 'hash_no_coincide', szs_validar_subida_foto( hash( 'sha256', $png ), $jpeg, 2 * $mb, 0, 10 * $mb, false )['codigo'], 'el hash tiene que ser el de los bytes' );
afirmar( 507, szs_validar_subida_foto( $hash_jpeg, $jpeg, 2 * $mb, 10 * $mb - 10, 10 * $mb, false )['estado'], 'sin espacio total: 507' );
$v = szs_validar_subida_foto( $hash_jpeg, $jpeg, 2 * $mb, 10 * $mb, 10 * $mb, true );
afirmar( array( true, 200, 'ya_estaba' ), array( $v['ok'], $v['estado'], $v['codigo'] ), 'la que ya está no cuenta para el tope (dedupe)' );

// --- listas de hashes ---
$h1 = str_repeat( 'a', 64 );
$h2 = str_repeat( 'b', 64 );
afirmar( array( $h1, $h2 ), szs_normalizar_lista_fotos( array( $h1, '/sdcard/foto.jpg', $h2, $h1, 7, null ) ), 'solo hashes, sin repetir ni rutas' );
afirmar( array( $h2 ), szs_normalizar_lista_fotos( wp_json_encode_prueba( array( $h2 ) ) ), 'acepta su JSON (columna de la BD)' );
afirmar( array(), szs_normalizar_lista_fotos( 'basura' ), 'texto que no es JSON: vacía' );
afirmar( array(), szs_normalizar_lista_fotos( array( 'x' => array( $h1 ) ) ), 'anidada: vacía' );
$muchas = array();
for ( $i = 0; $i < 80; $i++ ) {
	$muchas[] = hash( 'sha256', (string) $i );
}
afirmar( SZS_FOTOS_MAXIMO_POR_LISTA, count( szs_normalizar_lista_fotos( $muchas ) ), 'como mucho 50 por lista' );
afirmar( substr( $h1, 0, 2 ) . '/' . $h1 . '.png', szs_ruta_relativa_foto( $h1, 'image/png' ), 'subcarpeta por los dos primeros caracteres' );

function wp_json_encode_prueba( $valor ): string {
	return json_encode( $valor );
}

// --- entidades: saneado y app anterior ---
$entidad = szs_normalizar_entidad(
	array(
		'tipo'  => 'punto',
		'uid'   => 'p1',
		'datos' => array( 'nombre' => 'Abrevadero', 'fotos' => array( $h1, '../../wp-config.php' ) ),
	)
);
afirmar( array( $h1 ), $entidad['datos']['fotos'], 'datos.fotos se sanean a hashes' );
$sin_fotos = szs_normalizar_entidad( array( 'tipo' => 'punto', 'uid' => 'p1', 'datos' => array( 'nombre' => 'Abrevadero' ) ) );
afirmar( false, array_key_exists( 'fotos', $sin_fotos['datos'] ), 'sin clave fotos no se inventa' );
$guardada = $entidad;
afirmar( array( $h1 ), szs_conservar_fotos_si_faltan( $guardada, $sin_fotos )['datos']['fotos'], 'una app anterior (sin fotos) no borra las del servidor' );
$con_vacias                     = $sin_fotos;
$con_vacias['datos']['fotos']   = array();
afirmar( array(), szs_conservar_fotos_si_faltan( $guardada, $con_vacias )['datos']['fotos'], 'una app nueva sí puede quitarlas todas' );
afirmar( false, array_key_exists( 'fotos', szs_conservar_fotos_si_faltan( null, $sin_fotos )['datos'] ), 'alta sin fotos: nada que conservar' );

// Un punto: la tester puede añadirle fotos (como moverlo o cambiarle el estado).
$tester       = szs_capacidades_de_rol( 'tester' );
$coordinacion = szs_capacidades_de_rol( 'coordinador' );
$punto_antes  = array_merge( $sin_fotos, array( 'actualizado_ms' => 1, 'autor_uid' => 'coord' ) );
$punto_fotos  = array_merge( $entidad, array( 'actualizado_ms' => 2 ) );
afirmar( 'actualizar', szs_resolver_entidad_entrante( $punto_antes, $punto_fotos, 'ane', $tester, null )['accion'], 'tester añade fotos a un punto' );

// --- tareas ---
function tarea_con( array $cambios = array() ): array {
	return szs_normalizar_tarea(
		array_merge(
			array(
				'uid'             => 't1',
				'finca_nombre'    => 'Zunbeltz',
				'titulo'          => 'Reparar cierre',
				'responsable_uid' => 'ane',
				'creado_por_uid'  => 'coord',
				'estado'          => 'pendiente',
				'actualizado_ms'  => 100,
			),
			$cambios
		)
	);
}
$guardada_tarea = tarea_con( array( 'fotos_antes' => wp_json_encode_prueba( array( $h1 ) ), 'fotos_despues' => '[]' ) );
afirmar( array( $h1 ), $guardada_tarea['fotos_antes'], 'la fila de la BD (JSON) se lee como lista' );
afirmar( null, tarea_con()['fotos_antes'], 'sin fotos en el JSON: null (app anterior)' );

$r = szs_resolver_tarea_entrante( $guardada_tarea, tarea_con( array( 'actualizado_ms' => 200, 'fotos_despues' => array( $h2 ) ) ), 'ane', $tester );
afirmar( 'actualizar', $r['accion'], 'la responsable añade fotos de después' );
afirmar( array( $h2 ), $r['datos']['fotos_despues'], '… y se guardan' );
afirmar( array( $h1 ), $r['datos']['fotos_antes'], '… sin tocar las de antes' );

$r = szs_resolver_tarea_entrante( $guardada_tarea, tarea_con( array( 'actualizado_ms' => 200, 'estado' => 'hecha' ) ), 'ane', $tester );
afirmar( array( $h1 ), $r['datos']['fotos_antes'], 'una app anterior (sin fotos) que cierra la tarea no borra sus fotos' );
afirmar( false, $r['ajustada'], '… y no se le fuerza nada' );

$ajena = tarea_con( array( 'responsable_uid' => 'jon', 'fotos_antes' => '[]', 'fotos_despues' => '[]' ) );
$r     = szs_resolver_tarea_entrante( $ajena, tarea_con( array( 'responsable_uid' => 'jon', 'actualizado_ms' => 200, 'fotos_despues' => array( $h2 ) ) ), 'ane', $tester );
afirmar( 'rechazar', $r['accion'], 'una tester no pone fotos en la tarea de otra' );

$r = szs_resolver_tarea_entrante( null, tarea_con( array( 'creado_por_uid' => 'coord' ) ), 'coord', $coordinacion );
afirmar( array( array(), array() ), array( $r['datos']['fotos_antes'], $r['datos']['fotos_despues'] ), 'alta sin fotos: listas vacías' );

$siguiente = szs_siguiente_tarea_periodica( array_merge( $guardada_tarea, array( 'recurrencia_dias' => 7, 'fotos_despues' => array( $h2 ) ) ), 1700000000000, 'siguiente' );
afirmar( array( array(), array() ), array( $siguiente['fotos_antes'], $siguiente['fotos_despues'] ), 'la siguiente periódica empieza sin fotos' );

// --- subida de punta a punta (carpeta temporal) ---
$respuesta = szs_endpoint_subir_foto( new WP_REST_Request( array( 'hash' => $hash_jpeg ), $jpeg ) );
afirmar( 201, $respuesta->status, 'subida nueva: 201' );
afirmar( false, $respuesta->data['ya_estaba'], '… no estaba' );
$directorio = szs_directorio_fotos();
afirmar( true, str_starts_with( $directorio, $GLOBALS['subidas_de_prueba'] . '/solera-zunbeltz-fotos-' ), 'la carpeta está en uploads' );
afirmar( 1, preg_match( '/solera-zunbeltz-fotos-[0-9a-f]{32}$/', $directorio ), '… con un sufijo aleatorio que no se adivina' );
afirmar( true, str_contains( (string) file_get_contents( $directorio . '/.htaccess' ), 'Require all denied' ), '… protegida con .htaccess' );
afirmar( true, is_file( $directorio . '/index.php' ), '… y con index.php vacío' );
afirmar( $jpeg, file_get_contents( $directorio . '/' . szs_ruta_relativa_foto( $hash_jpeg, 'image/jpeg' ) ), 'la foto se guarda tal cual, por su hash' );
afirmar( $directorio, szs_directorio_fotos(), 'la carpeta no cambia entre llamadas' );

$respuesta = szs_endpoint_subir_foto( new WP_REST_Request( array( 'hash' => $hash_jpeg ), $jpeg ) );
afirmar( array( 200, true ), array( $respuesta->status, $respuesta->data['ya_estaba'] ), 'la misma foto otra vez: ya estaba (dedupe)' );
afirmar( 1, count( glob( $directorio . '/*/*' ) ), '… y no se duplica' );
afirmar( strlen( $jpeg ), szs_bytes_fotos_usados(), 'cuenta lo que ocupan (sin .htaccess ni index.php)' );

$GLOBALS['filtros_de_prueba']['szs_fotos_espacio_maximo'] = strlen( $jpeg ) + 10;
$respuesta = szs_endpoint_subir_foto( new WP_REST_Request( array( 'hash' => hash( 'sha256', $png ) ), $png ) );
afirmar( 507, $respuesta->status, 'pasado el tope configurable (filtro), 507' );
unset( $GLOBALS['filtros_de_prueba']['szs_fotos_espacio_maximo'] );

$respuesta = szs_endpoint_subir_foto( new WP_REST_Request( array( 'hash' => hash( 'sha256', $png ) ), $jpeg ) );
afirmar( 422, $respuesta->status, 'bytes que no son los del hash: 422' );
afirmar( null, szs_buscar_foto( hash( 'sha256', $png ) ), '… y no se guarda nada' );

$GLOBALS['filtros_de_prueba']['szs_fotos_tamano_maximo'] = 10;
$respuesta = szs_endpoint_subir_foto( new WP_REST_Request( array( 'hash' => hash( 'sha256', $png ) ), $png ) );
afirmar( 413, $respuesta->status, 'tamaño máximo configurable (filtro)' );
unset( $GLOBALS['filtros_de_prueba']['szs_fotos_tamano_maximo'] );

afirmar( array( 'ruta' => $directorio . '/' . szs_ruta_relativa_foto( $hash_jpeg, 'image/jpeg' ), 'mime' => 'image/jpeg' ), szs_buscar_foto( $hash_jpeg ), 'se encuentra por hash' );
afirmar( null, szs_buscar_foto( '../' . $hash_jpeg ), 'un hash con ../ no busca fuera' );
$respuesta = szs_endpoint_bajar_foto( new WP_REST_Request( array( 'hash' => $h1 ) ) );
afirmar( 404, $respuesta->status, 'bajar una que no está: 404 propio (no rest_no_route)' );

// Dónde va la carpeta: fuera de la raíz web si se puede.
afirmar( '/srv/sitio/fotos', szs_elegir_directorio_fotos( '/srv/sitio/web/wp-content/uploads/fotos', '/srv/sitio/fotos', '/srv/sitio/web', false, true ), 'fuera de la raíz web si se puede escribir' );
afirmar( '/srv/sitio/web/wp-content/uploads/fotos', szs_elegir_directorio_fotos( '/srv/sitio/web/wp-content/uploads/fotos', '/srv/sitio/fotos', '/srv/sitio/web', true, true ), 'si ya hay en uploads, se sigue allí' );
afirmar( '/srv/sitio/web/wp-content/uploads/fotos', szs_elegir_directorio_fotos( '/srv/sitio/web/wp-content/uploads/fotos', '/srv/sitio/fotos', '/srv/sitio/web', false, false ), 'si fuera no se puede escribir, uploads' );
afirmar( '/srv/web/wp/wp-content/uploads/fotos', szs_elegir_directorio_fotos( '/srv/web/wp/wp-content/uploads/fotos', '/srv/web/fotos', '/srv/web', false, true ), 'WordPress en subcarpeta: «fuera» seguiría siendo web, uploads' );
afirmar( '/srv/sitio/fotos', szs_elegir_directorio_fotos( '/srv/sitio/web/wp-content/uploads/fotos', '/srv/sitio/fotos', '/srv/sitio/webs', false, true ), 'prefijo de nombre no es estar dentro' );

// Limpieza.
$iterador = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( $GLOBALS['subidas_de_prueba'], FilesystemIterator::SKIP_DOTS ), RecursiveIteratorIterator::CHILD_FIRST );
foreach ( $iterador as $fichero ) {
	$fichero->isDir() ? rmdir( $fichero->getPathname() ) : unlink( $fichero->getPathname() );
}
rmdir( $GLOBALS['subidas_de_prueba'] );

if ( $fallos > 0 ) {
	fprintf( STDERR, "test_fotos: %d fallos\n", $fallos );
	exit( 1 );
}
echo "test_fotos: OK\n";
