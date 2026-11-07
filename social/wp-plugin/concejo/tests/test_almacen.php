<?php
/**
 * Las piezas que se guardan: ida y vuelta, y solo se escribe lo que cambia.
 *
 * Ejecutar: php tests/test_almacen.php
 */

require_once __DIR__ . '/arranque.php';
require_once __DIR__ . '/../includes/codigos.php';
require_once __DIR__ . '/../includes/almacen.php';

$pueblo = pueblo_de_ejemplo();
$estado = $pueblo['inicial']['estado'];

$documentos = concejo_documentos( $estado );
$personas   = array_map(
	fn( $p ) => array_merge( $p, array( 'mandato_hasta' => $p['mandato_hasta'] ?? '' ) ),
	array_values( $estado['personas'] )
);
$leido = concejo_estado_desde_documentos( $documentos, $personas );
comprobar( concejo_documentos( $leido ) === $documentos, 'las piezas van y vuelven sin cambios' );
comprobar( array_keys( $leido['personas'] ) === array_keys( $estado['personas'] ), 'las personas también' );
comprobar( null === $leido['personas']['maite']['mandato_hasta'], 'sin mandato queda null' );
$con_correo = array_map( fn( $p ) => $p + array( 'correo' => 'x@example.org', 'resumen' => 'semanal' ), $personas );
$leido_con_correo = concejo_estado_desde_documentos( $documentos, $con_correo );
comprobar( ! isset( $leido_con_correo['personas']['maite']['correo'] ), 'el correo no entra en el estado (ni en la vista de la app)' );

$resultado = concejo_aplicar_accion(
	$estado,
	array(
		'tipo'  => 'aportar',
		'datos' => array( 'uid' => 'ap1', 'asunto_uid' => 'fiestas', 'tipo' => 'duda', 'texto' => '¿Y la charanga?' ),
	),
	'maite',
	$pueblo['ahora'],
	$pueblo['zona']
);
$cambios = concejo_cambios_documentos( $documentos, concejo_documentos( $resultado['estado'] ) );
comprobar( array( 'debate:fiestas' ) === array_keys( $cambios['guardar'] ), 'solo se reescribe el debate que cambia' );
comprobar( array() === $cambios['borrar'], 'no se borra nada' );

$sin_txoko = $estado;
unset( $sin_txoko['asuntos']['txoko'] );
$cambios = concejo_cambios_documentos( $documentos, concejo_documentos( $sin_txoko ) );
comprobar( array( 'asunto:txoko' ) === $cambios['borrar'], 'un borrador borrado se borra' );

terminar();
