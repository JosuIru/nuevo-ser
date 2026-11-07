<?php
/**
 * El resumen semanal por correo (texto puro, sin WordPress).
 *
 * Ejecutar: php tests/test_correo.php
 */

require_once __DIR__ . '/arranque.php';
require_once __DIR__ . '/../includes/correo.php';

$pueblo = pueblo_de_ejemplo();
$zona   = $pueblo['zona'];
$ahora  = $pueblo['ahora']; // 10 de noviembre de 2026, 12:00.
$estado = $pueblo['inicial']['estado'];

$resumen = concejo_resumen_semanal( $estado, 'maite', 'Concejo de Ejemplo', $ahora, $zona, 'https://ejemplo.org/baja' );
$texto   = $resumen['texto'];

comprobar( str_contains( $resumen['asunto'], 'Concejo de Ejemplo' ), 'el asunto del correo dice de qué pueblo es' );
comprobar( str_contains( $texto, 'Hola, Maite' ), 'saluda por el nombre' );
comprobar( str_contains( $texto, '¿Pasamos las fiestas a septiembre?' ), 'sale lo que se decide ahora' );
comprobar( str_contains( $texto, 'cierra el 15 de noviembre' ), 'con la fecha de cierre' );
comprobar( str_contains( $texto, 'Aún no has participado' ), 'y si la persona ya ha participado o no' );
comprobar( str_contains( $texto, 'Normas para el uso de la leña del comunal' ), 'sale lo que está en debate' );
comprobar( str_contains( $texto, 'Poner el cartel' ) && str_contains( $texto, 'venció el 7 de noviembre' ), 'los compromisos vencidos, con fecha' );
comprobar( ! str_contains( $texto, 'Avisar a las cuadrillas' ), 'los compromisos hechos no' );
comprobar( str_contains( $texto, 'en papel' ), 'recuerda que se puede participar sin la app' );
comprobar( str_contains( $texto, 'https://ejemplo.org/baja' ), 'lleva el enlace para darse de baja' );

// Los borradores no salen nunca: solo los ve la mesa, y en la app.
$con_borrador                              = $estado;
$con_borrador['asuntos']['b1']             = $estado['asuntos']['fiestas'];
$con_borrador['asuntos']['b1']['uid']      = 'b1';
$con_borrador['asuntos']['b1']['titulo']   = 'Borrador secreto';
$con_borrador['asuntos']['b1']['abierto']  = false;
$texto_mesa = concejo_resumen_semanal( $con_borrador, 'ane', 'X', $ahora, $zona, '' )['texto'];
comprobar( ! str_contains( $texto_mesa, 'Borrador secreto' ), 'un borrador no sale ni a la mesa' );

// Quien ya votó lo lee.
$estado_votado                                         = $estado;
$estado_votado['urnas']['fiestas']['participaciones'][] = array(
	'asunto_uid'  => 'fiestas',
	'persona_uid' => 'maite',
	'canal'       => 'app',
	'hora'        => null,
);
$texto_votado = concejo_resumen_semanal( $estado_votado, 'maite', 'X', $ahora, $zona, '' )['texto'];
comprobar( str_contains( $texto_votado, 'Ya has participado' ), 'a quien ya votó se lo dice' );

// Lo decidido en la última semana.
$dos_semanas = $ahora->modify( '+10 days' ); // 20-nov: «fiestas» cerró el 15.
$texto_tarde = concejo_resumen_semanal( $estado, 'maite', 'X', $dos_semanas, $zona, '' )['texto'];
comprobar( str_contains( $texto_tarde, 'DECIDIDO ESTA SEMANA' ) && str_contains( $texto_tarde, '¿Pasamos las fiestas a septiembre?' ), 'lo decidido esta semana' );

// Fin de mandato, solo a quien lo tiene.
$antes_del_fin = new DateTimeImmutable( '2026-12-10T10:00:00', $zona );
comprobar( str_contains( concejo_resumen_semanal( $estado, 'ane', 'X', $antes_del_fin, $zona, '' )['texto'], 'Tu cargo en la mesa acaba el 20 de diciembre' ), 'avisa a la mesa de que acaba su cargo' );
comprobar( ! str_contains( concejo_resumen_semanal( $estado, 'maite', 'X', $antes_del_fin, $zona, '' )['texto'], 'Tu cargo' ), 'a una vecina no' );

// Si no hay nada que contar, no se manda nada.
$vacio = array_merge( $estado, array( 'asuntos' => array(), 'compromisos' => array() ) );
comprobar( null === concejo_resumen_semanal( $vacio, 'maite', 'X', $ahora, $zona, '' ), 'sin nada que contar no hay correo' );
comprobar( null === concejo_resumen_semanal( $estado, 'nadie', 'X', $ahora, $zona, '' ), 'ni a quien no existe' );

// Enlace de baja firmado.
$firma = concejo_firma_baja( 'maite', 'sal' );
comprobar( concejo_firma_baja_valida( 'maite', $firma, 'sal' ), 'la firma de la baja vale para esa persona' );
comprobar( ! concejo_firma_baja_valida( 'pili', $firma, 'sal' ), 'y no para otra' );
comprobar( ! concejo_firma_baja_valida( 'maite', $firma, 'otra sal' ), 'ni con otra clave' );

// Toca enviar los lunes, una vez por semana.
$lunes  = new DateTimeImmutable( '2026-11-09T08:00:00', $zona );
$martes = new DateTimeImmutable( '2026-11-10T08:00:00', $zona );
comprobar( concejo_toca_resumen( $lunes, 1, '' ), 'el lunes toca' );
comprobar( ! concejo_toca_resumen( $martes, 1, '' ), 'el martes no' );
comprobar( ! concejo_toca_resumen( $lunes, 1, concejo_semana( $lunes ) ), 'ni dos veces la misma semana' );
comprobar( concejo_toca_resumen( $lunes->modify( '+7 days' ), 1, concejo_semana( $lunes ) ), 'a la semana siguiente sí' );

terminar();
