<?php
/**
 * Tests de las rutas de la presentación del proyecto.
 *
 * Ejecutar: php tests/test_presentacion.php
 */

define( 'ABSPATH', __DIR__ );

function add_action( $hook, $callback, $prioridad = 10, $argumentos = 1 ) {}

require_once __DIR__ . '/../includes/presentacion.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

afirmar( 'servir', szs_accion_presentacion( '/presentacion/', '/presentacion' ), 'con barra' );
afirmar( 'servir', szs_accion_presentacion( '/presentacion/index.html', '/presentacion' ), 'index.html' );
afirmar( 'redirigir', szs_accion_presentacion( '/presentacion', '/presentacion' ), 'sin barra se redirige' );
afirmar( 'servir', szs_accion_presentacion( '/wp/presentacion/', '/wp/presentacion' ), 'WordPress en subcarpeta' );
afirmar( null, szs_accion_presentacion( '/presentacion/otra.html', '/presentacion' ), 'otros ficheros no' );
afirmar( null, szs_accion_presentacion( '/presentaciones/', '/presentacion' ), 'otra ruta parecida no' );
afirmar( null, szs_accion_presentacion( '/eu/', '/presentacion' ), 'el resto de la web no' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallo(s)\n", $fallos );
	exit( 1 );
}
echo "test_presentacion: OK\n";
