<?php
/**
 * Ejecutar: php tests/test_codigos.php
 */

require_once __DIR__ . '/arranque.php';
require_once __DIR__ . '/../includes/codigos.php';

$codigo = concejo_generar_codigo();
comprobar( 1 === preg_match( '/^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$/', $codigo ), "forma del código ({$codigo})" );
comprobar( 0 === preg_match( '/[01ILO]/', $codigo ), 'sin caracteres que se confunden' );
comprobar( $codigo !== concejo_generar_codigo(), 'dos códigos no salen iguales' );
comprobar(
	concejo_huella_codigo( $codigo ) === concejo_huella_codigo( strtolower( str_replace( '-', ' ', $codigo ) ) ),
	'da igual cómo se teclee'
);
comprobar( 64 === strlen( concejo_huella_codigo( $codigo ) ), 'se guarda la huella sha256' );

terminar();
