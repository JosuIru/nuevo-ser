<?php
/**
 * Test de paridad PHP/Dart del motor adaptativo, perfil P4 (calibración epistémica).
 *
 * Carga `packages/nuevo_ser_core/test/fixtures/motor_p4.json` — la misma
 * fixture que `mastery_engine_paridad_p4_test.dart` — y verifica que el
 * motor PHP produce idéntico resultado.
 *
 * Ejecutable directo: `php tests/test_paridad_motor_p4.php` desde la raíz
 * del plugin. Sale con código 0 si todo verde, código 1 si algún caso
 * falla.
 */

define( 'NS_TEST_STANDALONE', true );

require_once __DIR__ . '/../includes/class-ns-mastery.php';

$ruta_fixture = __DIR__
	. '/../../../packages/nuevo_ser_core/test/fixtures/motor_p4.json';

if ( ! file_exists( $ruta_fixture ) ) {
	fwrite( STDERR, "FIXTURE NO ENCONTRADA: $ruta_fixture\n" );
	exit( 1 );
}

$fixture = json_decode( file_get_contents( $ruta_fixture ), true );
if ( null === $fixture || ! isset( $fixture['casos'] ) ) {
	fwrite( STDERR, "FIXTURE INVÁLIDA: $ruta_fixture\n" );
	exit( 1 );
}

$motor    = new NS_Mastery_Engine();
$config   = NS_Profile_Config::default_p4();
$fallidos = 0;

foreach ( $fixture['casos'] as $caso ) {
	$nombre = $caso['nombre'];
	$estado = $caso['estado_inicial'];

	foreach ( $caso['secuencia'] as $payload ) {
		$estado = $motor->actualizar_maestria(
			$estado,
			$payload,
			NS_MASTERY_ID_PERFIL_P4,
			$config
		);
	}

	$esperado = $caso['esperado_final'];
	$errores  = comparar_estado_p4( $estado, $esperado );

	if ( empty( $errores ) ) {
		echo "OK  $nombre\n";
	} else {
		++$fallidos;
		echo "FAIL  $nombre\n";
		foreach ( $errores as $error ) {
			echo "      - $error\n";
		}
	}
}

if ( $fallidos > 0 ) {
	fwrite( STDERR, "\n$fallidos caso(s) divergen entre PHP y la fixture P4.\n" );
	exit( 1 );
}

echo "\nOK — paridad PHP/Dart confirmada (P4) sobre " . count( $fixture['casos'] ) . " casos.\n";
exit( 0 );

// ---------------------------------------------------------------------

function comparar_estado_p4( array $obtenido, array $esperado ): array {
	$errores = array();
	foreach ( array( 'id', 'nv', 'up', 'scb', 'te' ) as $campo ) {
		if ( $obtenido[ $campo ] !== $esperado[ $campo ] ) {
			$errores[] = "$campo: esperado="
				. var_export( $esperado[ $campo ], true )
				. ' obtenido=' . var_export( $obtenido[ $campo ], true );
		}
	}
	foreach ( array( 'pr', 'tm' ) as $campo ) {
		if ( abs( (float) $obtenido[ $campo ] - (float) $esperado[ $campo ] ) > 1e-9 ) {
			$errores[] = "$campo: esperado="
				. $esperado[ $campo ]
				. ' obtenido=' . $obtenido[ $campo ];
		}
	}
	if ( count( $obtenido['ir'] ) !== count( $esperado['ir'] ) ) {
		$errores[] = 'ir.length: esperado=' . count( $esperado['ir'] )
			. ' obtenido=' . count( $obtenido['ir'] );
		return $errores;
	}
	for ( $i = 0; $i < count( $esperado['ir'] ); $i++ ) {
		$o = $obtenido['ir'][ $i ];
		$e = $esperado['ir'][ $i ];
		foreach ( array( 't', 'a', 's' ) as $campo ) {
			if ( $o[ $campo ] !== $e[ $campo ] ) {
				$errores[] = "ir[$i].$campo: esperado="
					. var_export( $e[ $campo ], true )
					. ' obtenido=' . var_export( $o[ $campo ], true );
			}
		}
		if ( abs( (float) $o['d'] - (float) $e['d'] ) > 1e-9 ) {
			$errores[] = "ir[$i].d: esperado={$e['d']} obtenido={$o['d']}";
		}
		foreach ( array( 'cd', 'fr' ) as $campo ) {
			$tiene_e = array_key_exists( $campo, $e );
			$tiene_o = array_key_exists( $campo, $o );
			if ( $tiene_e !== $tiene_o ) {
				$errores[] = "ir[$i].$campo presencia: esperado="
					. var_export( $tiene_e, true )
					. ' obtenido=' . var_export( $tiene_o, true );
				continue;
			}
			if ( $tiene_e && abs( (float) $o[ $campo ] - (float) $e[ $campo ] ) > 1e-9 ) {
				$errores[] = "ir[$i].$campo: esperado="
					. var_export( $e[ $campo ], true )
					. ' obtenido=' . var_export( $o[ $campo ], true );
			}
		}
	}
	return $errores;
}
