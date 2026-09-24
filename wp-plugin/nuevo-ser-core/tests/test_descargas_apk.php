<?php
/**
 * Smoke tests de la elección de APK entre los releases de GitHub. Sin
 * PHPUnit, como el resto: `php tests/test_descargas_apk.php`. Imprime
 * "OK" y sale con 0; si falla, imprime el caso y sale con 1.
 */

define( 'ABSPATH', __DIR__ );

require_once __DIR__ . '/../includes/class-ns-descargas-apk.php';

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
			'published_at' => '2026-09-24T12:00:00Z',
			'assets'       => array_map(
				static function ( $nombre ) {
					return array(
						'name'                 => $nombre,
						'browser_download_url' => 'https://github.com/x/y/releases/download/' . rawurlencode( $nombre ),
						'size'                 => 1000,
					);
				},
				$assets
			),
		),
		$extra
	);
}

// La API devuelve los releases del más nuevo al más viejo.
$releases = array(
	release( 'solera-quesera-0.3.0+2', array( 'solera-quesera-0.3.0+2.apk' ) ),
	release( 'uno-roto-1.0.0+21', array( 'uno-roto-1.0.0+21.apk' ), array( 'draft' => true ) ),
	release( 'uno-roto-1.0.0+20', array( 'notas.txt', 'uno-roto-1.0.0+20.apk' ) ),
	release( 'uno-roto-1.0.0+19', array( 'uno-roto-1.0.0+19.apk' ) ),
	release( 'apks-2026-05-18', array( 'las-versiones-0.0.1.apk', 'uno-roto-1.0.0+5.apk' ) ),
	release( 'solera-0.1.0', array( 'solera-0.1.0.apk' ) ),
);

$apk = NS_Descargas_Apk::elegir_apk( $releases, 'uno-roto' );
afirmar( '1.0.0+20', $apk['version'] ?? null, 'la más nueva publicada, sin borradores' );
afirmar( true, '.apk' === substr( $apk['url'] ?? '', -4 ), 'el asset es la APK, no otro archivo' );
afirmar( 1000, $apk['tamano'] ?? null, 'tamaño del asset' );

afirmar( null, NS_Descargas_Apk::elegir_apk( $releases, 'las-versiones' ), 'los bundles apks-* viejos no cuentan' );
afirmar( '0.1.0', NS_Descargas_Apk::elegir_apk( $releases, 'solera' )['version'] ?? null, 'solera no se queda con solera-quesera' );
afirmar( '0.3.0+2', NS_Descargas_Apk::elegir_apk( $releases, 'solera-quesera' )['version'] ?? null, 'solera-quesera la suya' );

$solo_prerelease = array( release( 'el-cuaderno-0.1.0', array( 'el-cuaderno-0.1.0.apk' ), array( 'prerelease' => true ) ) );
afirmar( null, NS_Descargas_Apk::elegir_apk( $solo_prerelease, 'el-cuaderno' ), 'los prerelease no se ofrecen' );

$sin_apk = array( release( 'el-descifrador-0.1.0', array( 'notas.txt' ) ) );
afirmar( null, NS_Descargas_Apk::elegir_apk( $sin_apk, 'el-descifrador' ), 'release sin APK: nada' );

afirmar( null, NS_Descargas_Apk::elegir_apk( array( 'basura', null ), 'uno-roto' ), 'respuesta rara: nada' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallo(s)\n", $fallos );
	exit( 1 );
}
echo "OK\n";
