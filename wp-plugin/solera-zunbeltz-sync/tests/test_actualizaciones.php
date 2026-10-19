<?php
/**
 * Tests de la lectura de versión desde el tag de las releases del plugin.
 *
 * Ejecutar: php tests/test_actualizaciones.php
 */

define( 'ABSPATH', __DIR__ );

function add_action( $hook, $callback, $prioridad = 10, $argumentos = 1 ) {}

require_once __DIR__ . '/../includes/actualizaciones.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

afirmar( '0.8.1', szs_version_desde_tag( 'plugin-solera-zunbeltz-sync-0.8.1' ), 'tag del plugin' );
afirmar( '1.10.0', szs_version_desde_tag( 'plugin-solera-zunbeltz-sync-1.10.0' ), 'versión de varias cifras' );
afirmar( null, szs_version_desde_tag( 'solera-zunbeltz-0.6.1+22' ), 'la release de la app no cuenta' );
afirmar( null, szs_version_desde_tag( 'uno-roto-1.0.0+26' ), 'releases de otras apps no cuentan' );
afirmar( null, szs_version_desde_tag( 'plugin-solera-zunbeltz-sync-0.9.0-beta' ), 'sin sufijos raros' );
afirmar( null, szs_version_desde_tag( 'plugin-solera-zunbeltz-sync-' ), 'sin versión' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallo(s)\n", $fallos );
	exit( 1 );
}
echo "test_actualizaciones: OK\n";
