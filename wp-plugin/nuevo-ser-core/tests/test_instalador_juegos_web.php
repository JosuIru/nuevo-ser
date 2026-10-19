<?php
/**
 * Smoke tests del instalador de juegos web: elección del build entre los
 * releases, lectura del sha256 y rutas del zip. Sin PHPUnit:
 * `php tests/test_instalador_juegos_web.php`. Imprime "OK" y sale con 0;
 * si falla, imprime el caso y sale con 1.
 */

define( 'ABSPATH', __DIR__ );

require_once __DIR__ . '/../includes/class-ns-instalador-juegos-web.php';

$fallos = 0;

/**
 * @param mixed $esperado
 * @param mixed $real
 */
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

function release( string $tag, array $assets, array $extra = array() ): array {
	return array_merge(
		array(
			'tag_name'     => $tag,
			'draft'        => false,
			'prerelease'   => false,
			'published_at' => '2026-10-19T12:00:00Z',
			'assets'       => array_map(
				static function ( $nombre ) {
					return array(
						'name'                 => $nombre,
						'browser_download_url' => 'https://github.com/x/y/releases/download/' . rawurlencode( $nombre ),
						'size'                 => 50000000,
					);
				},
				$assets
			),
		),
		$extra
	);
}

$releases = array(
	release( 'web-uno-roto-1.0.0+22', array( 'uno-roto-web-1.0.0+22.zip', 'uno-roto-web-1.0.0+22.zip.sha256' ), array( 'draft' => true ) ),
	release( 'uno-roto-1.0.0+21', array( 'uno-roto-1.0.0+21.apk' ) ),
	release( 'web-uno-roto-1.0.0+21', array( 'uno-roto-web-1.0.0+21.zip' ) ),
	release( 'web-las-versiones-0.4.0+3', array( 'las-versiones-web-0.4.0+3.zip', 'las-versiones-web-0.4.0+3.zip.sha256' ) ),
	release( 'web-uno-roto-1.0.0+20', array( 'uno-roto-web-1.0.0+20.zip.sha256', 'uno-roto-web-1.0.0+20.zip' ) ),
);

$build = NS_Instalador_Juegos_Web::elegir_build( $releases, 'uno-roto' );
afirmar( '1.0.0+20', $build['version'] ?? null, 'el más nuevo publicado con zip y sha256, sin borradores' );
afirmar( true, '.zip' === substr( $build['url'] ?? '', -4 ), 'url apunta al zip' );
afirmar( true, '.zip.sha256' === substr( $build['url_sha256'] ?? '', -11 ), 'url_sha256 apunta al .sha256' );
afirmar( 50000000, $build['tamano'] ?? null, 'tamaño del zip' );
afirmar( '0.4.0+3', NS_Instalador_Juegos_Web::elegir_build( $releases, 'las-versiones' )['version'] ?? null, 'cada juego el suyo' );
afirmar( null, NS_Instalador_Juegos_Web::elegir_build( $releases, 'uno' ), 'un prefijo de otro juego no vale' );
afirmar( null, NS_Instalador_Juegos_Web::elegir_build( array(), 'uno-roto' ), 'sin releases, null' );

$hash = str_repeat( 'ab12', 16 );
afirmar( $hash, NS_Instalador_Juegos_Web::leer_sha256( $hash . "  uno-roto-web-1.0.0+20.zip\n" ), 'formato de sha256sum' );
afirmar( $hash, NS_Instalador_Juegos_Web::leer_sha256( strtoupper( $hash ) ), 'en mayúsculas, se normaliza' );
afirmar( null, NS_Instalador_Juegos_Web::leer_sha256( 'Not Found' ), 'sin hash, null' );

foreach ( array( 'index.html', 'assets/fonts/Roboto.ttf', 'canvaskit/', 'sw_uno_roto.js' ) as $ruta ) {
	afirmar( true, NS_Instalador_Juegos_Web::ruta_segura_en_zip( $ruta ), "ruta segura: $ruta" );
}
foreach ( array( '', '../wp-config.php', 'assets/../../x', '/etc/passwd', 'C:/x', 'a\\b', "a\0b" ) as $ruta ) {
	afirmar( false, NS_Instalador_Juegos_Web::ruta_segura_en_zip( $ruta ), 'ruta rechazada: ' . addslashes( $ruta ) );
}

if ( $fallos > 0 ) {
	exit( 1 );
}
echo "OK\n";
