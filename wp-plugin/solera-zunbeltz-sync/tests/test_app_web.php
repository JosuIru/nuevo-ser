<?php
/**
 * Tests de la parte pura del servido de la app web desde el plugin (`/app/`).
 *
 * Ejecutar: php tests/test_app_web.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback, $prioridad = 10, $argumentos = 1 ) {}
function add_filter( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $valor;
}
function sanitize_text_field( $texto ) {
	return trim( (string) $texto );
}
function sanitize_textarea_field( $texto ) {
	return trim( (string) $texto );
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

// --- qué fichero pide cada ruta ---
afirmar( null, szs_ruta_relativa_app_web( '/wp-admin/', '/app' ), 'fuera de /app no es de la app' );
afirmar( null, szs_ruta_relativa_app_web( '/aplicacion', '/app' ), 'un prefijo parecido no cuenta' );
afirmar( '', szs_ruta_relativa_app_web( '/app', '/app' ), '/app sin barra: la raíz (se redirige)' );
afirmar( 'index.html', szs_ruta_relativa_app_web( '/app/', '/app' ), '/app/ sirve el index' );
afirmar( 'main.dart.js', szs_ruta_relativa_app_web( '/app/main.dart.js', '/app' ), 'un fichero de la app' );
afirmar( 'assets/fuentes/Archivo-Regular.ttf', szs_ruta_relativa_app_web( '/app/assets/fuentes/Archivo-Regular.ttf', '/app' ), 'ficheros en subcarpetas' );
afirmar( 'index.html', szs_ruta_relativa_app_web( '/zunbeltz/app/', '/zunbeltz/app' ), 'WordPress en subcarpeta' );
afirmar( null, szs_ruta_relativa_app_web( '/app/../wp-config.php', '/app' ), 'sin escaparse de la carpeta con ..' );
afirmar( null, szs_ruta_relativa_app_web( '/app/assets/%2e%2e/x', '/app' ), 'ni con .. codificado' );

// --- tipo de cada fichero ---
afirmar( 'application/wasm', szs_tipo_mime_app_web( 'sqlite3.wasm' ), 'el SQLite de la app web es wasm' );
afirmar( 'text/javascript; charset=utf-8', szs_tipo_mime_app_web( 'flutter_bootstrap.js' ), 'js' );
afirmar( 'text/html; charset=utf-8', szs_tipo_mime_app_web( 'index.html' ), 'html' );
afirmar( 'font/ttf', szs_tipo_mime_app_web( 'assets/fuentes/Spectral-Regular.ttf' ), 'fuentes' );
afirmar( 'application/octet-stream', szs_tipo_mime_app_web( 'raro.xyz' ), 'desconocido' );

// --- caché ---
afirmar( true, szs_etag_coincide( '"abc"', '"abc"' ), 'misma etiqueta' );
afirmar( true, szs_etag_coincide( 'W/"abc"', '"abc"' ), 'forma débil que pone nginx al comprimir' );
afirmar( true, szs_etag_coincide( '"x", W/"abc"', '"abc"' ), 'varias etiquetas' );
afirmar( false, szs_etag_coincide( '"otra"', '"abc"' ), 'etiqueta distinta' );
afirmar( false, szs_etag_coincide( '', '"abc"' ), 'sin cabecera' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests de la app web pasaron.\n";
