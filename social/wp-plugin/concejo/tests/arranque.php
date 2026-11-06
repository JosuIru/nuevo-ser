<?php
/**
 * Arranque común de los tests sin WordPress: carga la lógica pura y un
 * `comprobar()` mínimo. Cada test termina con `terminar()`.
 */

define( 'ABSPATH', __DIR__ );

require_once __DIR__ . '/../includes/logica.php';
require_once __DIR__ . '/../includes/vista.php';
require_once __DIR__ . '/../includes/instantanea.php';

$GLOBALS['concejo_fallos']  = 0;
$GLOBALS['concejo_pruebas'] = 0;

function comprobar( bool $condicion, string $descripcion ): void {
	++$GLOBALS['concejo_pruebas'];
	if ( ! $condicion ) {
		++$GLOBALS['concejo_fallos'];
		fwrite( STDERR, "✗ {$descripcion}\n" );
	}
}

function terminar(): void {
	$fallos  = $GLOBALS['concejo_fallos'];
	$pruebas = $GLOBALS['concejo_pruebas'];
	echo ( 0 === $fallos ? 'OK' : 'FALLOS' ) . ": {$pruebas} comprobaciones, {$fallos} fallos\n";
	exit( 0 === $fallos ? 0 : 1 );
}

/** El pueblo de ejemplo de la app, el día del fichero de paridad. */
function pueblo_de_ejemplo(): array {
	$paridad = json_decode( (string) file_get_contents( __DIR__ . '/paridad.json' ), true );
	$zona    = new DateTimeZone( 'Europe/Madrid' );
	return array(
		'paridad' => $paridad,
		'zona'    => $zona,
		'ahora'   => new DateTimeImmutable( $paridad['hoy'], $zona ),
		'inicial' => concejo_estado_desde_instantanea( $paridad['inicial'] ),
	);
}
