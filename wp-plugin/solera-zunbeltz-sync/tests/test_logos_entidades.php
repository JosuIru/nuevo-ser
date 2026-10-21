<?php
/**
 * Tests de la lógica pura de las entidades y sus logos: lista de partida,
 * claves, normalización de lo que llega del panel y lo que baja la app.
 * Sin WordPress.
 *
 * Ejecutar: php tests/test_logos_entidades.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

// --- lista de partida ---
$por_defecto = szs_logos_entidades_por_defecto();
afirmar( 19, count( $por_defecto ), 'diecinueve entidades de partida, como el pie de zunbeltz.com' );
afirmar( $por_defecto, szs_normalizar_logos_entidades( $por_defecto ), 'la lista de partida ya está normalizada' );
foreach ( $por_defecto as $entidad ) {
	afirmar( true, szs_hay_logo_de_partida( $entidad['clave'] ), "hay logo de partida para {$entidad['clave']}" );
}
afirmar( false, szs_hay_logo_de_partida( '../solera-zunbeltz-sync' ), 'una clave con barras no sale del directorio de logos' );
afirmar( array( 'impulsan', 'financian', 'colaboran', 'miembro_de' ), array_keys( SZS_GRUPOS_LOGOS ), 'los cuatro grupos que pidió Zunbeltz, en su orden' );
afirmar( 'Con el apoyo económico de', SZS_GRUPOS_LOGOS['financian'][0], 'rótulo del apoyo económico' );
afirmar(
	array( 'carasso', 'gobierno_navarra' ),
	array_column( array_filter( $por_defecto, static fn( $entidad ) => 'financian' === $entidad['grupo'] ), 'clave' ),
	'financian la Fundación Carasso y el Gobierno de Navarra (Zunbeltz, 2026-10-16)'
);

// --- una lista guardada antes de que hubiera grupo de financiadoras ---
$guardada_antes = array(
	array( 'clave' => 'carasso', 'nombre' => 'Carasso', 'grupo' => 'apoyan', 'enlace' => '', 'adjunto_id' => 9, 'orden' => 10, 'activo' => true ),
	array( 'clave' => 'gobierno_navarra', 'nombre' => 'GN', 'grupo' => 'colaboran', 'enlace' => '', 'adjunto_id' => 0, 'orden' => 20, 'activo' => true ),
	array( 'clave' => 'upna', 'nombre' => 'UPNA', 'grupo' => 'apoyan', 'enlace' => '', 'adjunto_id' => 0, 'orden' => 30, 'activo' => true ),
);
$movida = szs_logos_con_financiadoras( $guardada_antes );
afirmar( array( 'financian', 'financian', 'apoyan' ), array_column( $movida, 'grupo' ), 'las financiadoras pasan a su grupo; el resto se queda' );
afirmar( array( 'financian', 'financian', 'colaboran' ), array_column( szs_normalizar_logos_entidades( $movida ), 'grupo' ), 'el antiguo grupo «apoyan» pasa a «colaboran» al normalizar' );
afirmar( 9, $movida[0]['adjunto_id'], 'conservan el logo que les pusieran' );

// --- claves ---
afirmar( 'fundacion_la_caixa', szs_clave_logo_desde_nombre( 'Fundación «la Caixa»' ), 'clave sin tildes ni símbolos' );
afirmar( 'entidad', szs_clave_logo_desde_nombre( '«»' ), 'clave de reserva si no queda nada' );
afirmar( 'upna_3', szs_clave_logo_libre( 'upna', array( 'upna', 'upna_2' ) ), 'clave libre con sufijo' );

// --- normalización ---
$normalizada = szs_normalizar_logos_entidades(
	array(
		array( 'nombre' => 'Sin clave', 'grupo' => 'apoyan', 'enlace' => 'https://ejemplo.org', 'activo' => '1' ),
		array( 'clave' => 'sin_clave', 'nombre' => 'Repetida', 'grupo' => 'inventado', 'enlace' => 'javascript:alert(1)', 'adjunto_id' => '-4' ),
		array( 'clave' => 'vacia', 'nombre' => '  ' ),
		'basura',
	)
);
afirmar( 2, count( $normalizada ), 'descarta las que no tienen nombre y lo que no es una entidad' );
afirmar( 'sin_clave', $normalizada[0]['clave'], 'sin clave, se saca del nombre' );
afirmar( 'sin_clave_2', $normalizada[1]['clave'], 'clave repetida, con sufijo' );
afirmar( 'colaboran', $normalizada[1]['grupo'], 'grupo desconocido → colaboran' );
afirmar( '', $normalizada[1]['enlace'], 'enlace que no es web se descarta' );
afirmar( 0, $normalizada[1]['adjunto_id'], 'adjunto negativo → 0' );
afirmar( array( true, false ), array( $normalizada[0]['activo'], $normalizada[1]['activo'] ), 'visible solo si viene marcada' );

// --- lo que baja la app ---
$lista = array(
	array( 'clave' => 'reta', 'nombre' => 'RETA', 'grupo' => 'miembro_de', 'enlace' => '', 'adjunto_id' => 0, 'orden' => 10, 'activo' => true ),
	array( 'clave' => 'b', 'nombre' => 'B', 'grupo' => 'impulsan', 'enlace' => '', 'adjunto_id' => 7, 'orden' => 20, 'activo' => true ),
	array( 'clave' => 'a', 'nombre' => 'A', 'grupo' => 'impulsan', 'enlace' => 'https://a.eus', 'adjunto_id' => 0, 'orden' => 10, 'activo' => true ),
	array( 'clave' => 'oculta', 'nombre' => 'Oculta', 'grupo' => 'apoyan', 'enlace' => '', 'adjunto_id' => 0, 'orden' => 10, 'activo' => false ),
);
$para_app = szs_logos_entidades_para_app( $lista, static fn( array $entidad ): string => "https://x/{$entidad['clave']}.png" );
afirmar( array( 'a', 'b', 'reta' ), array_column( $para_app, 'clave' ), 'sin las ocultas, por grupo y luego por orden' );
afirmar( array( false, true, false ), array_column( $para_app, 'logo_propio' ), 'logo propio solo con adjunto de la biblioteca' );
afirmar( 'https://x/a.png', $para_app[0]['logo_url'], 'url del logo' );
afirmar( 'https://a.eus', $para_app[0]['enlace'], 'enlace' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallos\n", $fallos );
	exit( 1 );
}
echo "test_logos_entidades: OK\n";
