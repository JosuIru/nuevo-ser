<?php
/**
 * Tests de la lectura de versión desde el tag de las releases del plugin.
 *
 * Ejecutar: php tests/test_actualizaciones.php
 */

define( 'ABSPATH', __DIR__ );

function add_action( $hook, $callback, $prioridad = 10, $argumentos = 1 ) {}
function add_filter( $hook, $callback, $prioridad = 10, $argumentos = 1 ) {}

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
afirmar( array( 0, 6, 10, 31 ), szs_piezas_version_tag( 'solera-zunbeltz-0.6.10+31' ), 'piezas de la versión de una etiqueta' );
$ordenadas = szs_ordenar_releases_por_version(
	array(
		array( 'tag_name' => 'plugin-solera-zunbeltz-sync-0.9.9' ),
		array( 'tag_name' => 'plugin-solera-zunbeltz-sync-0.9.10' ),
		array( 'tag_name' => 'plugin-solera-zunbeltz-sync-1.0.0' ),
		(object) array( 'tag_name' => 'tema-zunbeltz-espacio-0.2.1' ),
	)
);
afirmar( array( 'plugin-solera-zunbeltz-sync-1.0.0', 'plugin-solera-zunbeltz-sync-0.9.10', 'plugin-solera-zunbeltz-sync-0.9.9', 'tema-zunbeltz-espacio-0.2.1' ), array_map( static fn( $r ) => is_array( $r ) ? $r['tag_name'] : $r->tag_name, $ordenadas ), 'de la versión más alta a la más baja (0.9.10 > 0.9.9)' );
afirmar( '0.2.0', szs_version_tema_desde_tag( 'tema-zunbeltz-espacio-0.2.0' ), 'tag del tema' );
afirmar( null, szs_version_tema_desde_tag( 'plugin-solera-zunbeltz-sync-0.9.3' ), 'la release del plugin no es del tema' );
afirmar( null, szs_version_desde_tag( 'tema-zunbeltz-espacio-0.2.0' ), 'ni la del tema del plugin' );
afirmar( '0.2.0', szs_filtro_version_desde_tag( 'tema-zunbeltz-espacio-' )( (object) array( 'version' => 'tema-zunbeltz-espacio-0.2.0' ) )->version, 'el filtro deja solo el número' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallo(s)\n", $fallos );
	exit( 1 );
}
echo "test_actualizaciones: OK\n";
