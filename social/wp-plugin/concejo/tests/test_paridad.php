<?php
/**
 * El servidor acepta y rechaza las mismas acciones que la app. Los casos y
 * lo que decide la app están en `paridad.json`, que genera el test de
 * Flutter `test/paridad_servidor_test.dart` de `social/apps/concejo`.
 *
 * Ejecutar: php tests/test_paridad.php
 */

require_once __DIR__ . '/arranque.php';

$pueblo = pueblo_de_ejemplo();
foreach ( $pueblo['paridad']['casos'] as $caso ) {
	$estado = $pueblo['inicial']['estado'];
	foreach ( $caso['pasos'] as $indice => $paso ) {
		$accion = $paso['accion'];
		try {
			$resultado = concejo_aplicar_accion( $estado, $accion, $accion['autor_uid'], $pueblo['ahora'], $pueblo['zona'] );
			$estado    = $resultado['estado'];
			$aceptada  = true;
			$motivo    = '';
		} catch ( Concejo_Rechazo $rechazo ) {
			$aceptada = false;
			$motivo   = $rechazo->getMessage();
		}
		$esperado = $paso['aceptada'] ? 'aceptada' : 'rechazada';
		comprobar(
			$aceptada === $paso['aceptada'],
			"«{$caso['nombre']}» paso {$indice} ({$accion['autor_uid']}: {$accion['tipo']}): la app la da por {$esperado}" . ( '' !== $motivo ? " y el servidor dice «{$motivo}»" : '' )
		);
	}
}

terminar();
