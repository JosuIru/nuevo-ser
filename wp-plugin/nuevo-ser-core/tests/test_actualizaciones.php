<?php
/**
 * Smoke tests de las actualizaciones del plugin desde GitHub Releases:
 * elección del release, comparación de versiones y qué descargas se
 * comprueban. Sin PHPUnit: `php tests/test_actualizaciones.php`.
 * Imprime "OK" y sale con 0; si falla, imprime el caso y sale con 1.
 */

define( 'ABSPATH', __DIR__ );

require_once __DIR__ . '/../includes/class-ns-descargas-apk.php';
require_once __DIR__ . '/../includes/class-ns-instalador-juegos-web.php';
require_once __DIR__ . '/../includes/class-ns-actualizaciones.php';

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

function release_plugin( string $version, bool $con_sha = true, array $extra = array() ): array {
	$base   = 'https://github.com/JosuIru/nuevo-ser/releases/download/nuevo-ser-core-' . $version . '/';
	$assets = array( array( 'name' => 'nuevo-ser-core-' . $version . '.zip', 'browser_download_url' => $base . 'nuevo-ser-core-' . $version . '.zip', 'size' => 300000 ) );
	if ( $con_sha ) {
		$assets[] = array( 'name' => 'nuevo-ser-core-' . $version . '.zip.sha256', 'browser_download_url' => $base . 'nuevo-ser-core-' . $version . '.zip.sha256', 'size' => 90 );
	}
	return array_merge( array( 'tag_name' => 'nuevo-ser-core-' . $version, 'draft' => false, 'prerelease' => false, 'published_at' => '2026-11-21T12:00:00Z', 'body' => 'Notas ' . $version, 'assets' => $assets ), $extra );
}

$releases = array(
	array( 'tag_name' => 'web-el-taller-0.12.0', 'draft' => false, 'prerelease' => false, 'assets' => array() ),
	release_plugin( '0.22.0', true, array( 'prerelease' => true ) ),
	release_plugin( '0.21.1', false ),
	release_plugin( '0.21.0' ),
	release_plugin( '0.20.5' ),
);
$elegido = NS_Actualizaciones::elegir_release( $releases );
afirmar( '0.21.0', $elegido['version'] ?? null, 'Elige la versión más alta con zip y sha256 (sin prerreleases)' );
afirmar( 'Notas 0.21.0', $elegido['notas'] ?? null, 'Lleva las notas del release' );
afirmar( null, NS_Actualizaciones::elegir_release( array( release_plugin( '0.21.0', false ) ) ), 'Sin sha256 no hay actualización' );
afirmar( null, NS_Actualizaciones::elegir_release( array( array( 'tag_name' => 'nuevo-ser-core-beta', 'assets' => array() ) ) ), 'Un tag sin versión no vale' );
afirmar( '0.21.0', NS_Actualizaciones::elegir_release( array( release_plugin( '0.20.5' ), release_plugin( '0.21.0' ) ) )['version'] ?? null, 'No depende del orden de GitHub' );

afirmar( true, NS_Actualizaciones::hay_version_nueva( '0.20.0', '0.21.0' ), '0.21.0 es más nueva que 0.20.0' );
afirmar( true, NS_Actualizaciones::hay_version_nueva( '0.9.0', '0.10.0' ), 'Compara números, no texto' );
afirmar( false, NS_Actualizaciones::hay_version_nueva( '0.21.0', '0.21.0' ), 'La misma versión no es nueva' );
afirmar( false, NS_Actualizaciones::hay_version_nueva( '0.21.0', '' ), 'Sin versión remota no hay nada' );

afirmar( true, NS_Actualizaciones::es_paquete_del_plugin( 'https://github.com/JosuIru/nuevo-ser/releases/download/nuevo-ser-core-0.21.0/nuevo-ser-core-0.21.0.zip' ), 'Reconoce el zip del plugin' );
afirmar( false, NS_Actualizaciones::es_paquete_del_plugin( 'https://github.com/JosuIru/nuevo-ser/releases/download/web-el-taller-0.12.0/el-taller-web-0.12.0.zip' ), 'No toca los zips de los juegos' );
afirmar( false, NS_Actualizaciones::es_paquete_del_plugin( 'https://downloads.wordpress.org/plugin/akismet.zip' ), 'No toca las descargas de otros plugins' );
afirmar( false, NS_Actualizaciones::es_paquete_del_plugin( 'https://github.com/otro/repo/releases/download/nuevo-ser-core-0.21.0/nuevo-ser-core-0.21.0.zip' ), 'Sólo el repositorio del monorepo' );

if ( $fallos ) {
	exit( 1 );
}
echo "OK\n";
