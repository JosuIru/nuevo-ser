<?php
/**
 * Lo que manda el servidor a cada persona y la papeleta secreta.
 *
 * Ejecutar: php tests/test_vista.php
 */

require_once __DIR__ . '/arranque.php';

$pueblo    = pueblo_de_ejemplo();
$zona      = $pueblo['zona'];
$ahora     = $pueblo['ahora'];
$estado    = $pueblo['inicial']['estado'];
$papeletas = $pueblo['inicial']['papeletas'];

$aplicar = function ( string $persona, string $tipo, array $datos ) use ( &$estado, $ahora, $zona ): array {
	$resultado = concejo_aplicar_accion( $estado, array( 'tipo' => $tipo, 'datos' => $datos ), $persona, $ahora, $zona );
	$estado    = $resultado['estado'];
	return $resultado;
};
// Con `use (&…)`: una función flecha copiaría el estado del principio.
$vista = function ( string $persona ) use ( &$estado, &$papeletas, $ahora, $zona ): array {
	return json_decode(
		(string) json_encode( concejo_vista( $estado, $papeletas, $persona, 'Concejo de Ejemplo', 3, $ahora, $zona ) ),
		true
	);
};

// La papeleta secreta: sin persona ni hora, y la participación aparte.
$voto = $aplicar( 'maite', 'votar', array( 'asunto_uid' => 'fiestas', 'opciones' => array( 'si' ) ) );
comprobar( null === $voto['papeleta']['persona_uid'], 'la papeleta secreta no lleva persona' );
comprobar( null === $voto['papeleta']['hora'], 'la papeleta secreta no lleva hora' );
comprobar( concejo_ha_participado( $estado['urnas']['fiestas'], 'maite' ), 'la participación queda apuntada' );
$papeletas['fiestas'][] = $voto['papeleta'];

// Mientras se vota no sale ninguna papeleta; cerrado el plazo, sí.
$urna_fiestas = array_values( array_filter( $vista( 'ane' )['urnas'], fn( $u ) => 'fiestas' === $u['asunto_uid'] ) )[0];
comprobar( array() === $urna_fiestas['papeletas'], 'ni la mesa ve las papeletas mientras se vota' );
comprobar( 1 === count( $urna_fiestas['participaciones'] ), 'sí se ve quién ha participado' );
$urna_txoko = array_values( array_filter( $vista( 'maite' )['urnas'], fn( $u ) => 'txoko' === $u['asunto_uid'] ) )[0];
comprobar( 4 === count( $urna_txoko['papeletas'] ), 'cerrada la votación salen las papeletas' );

// Anónimas y moderación.
$aplicar( 'maite', 'aportar', array( 'uid' => 'an1', 'asunto_uid' => 'fiestas', 'tipo' => 'duda', 'texto' => 'Sin nombre', 'anonima' => true ) );
$buscar = function ( array $vista_persona, string $uid ): ?array {
	foreach ( $vista_persona['debates'] as $debate ) {
		foreach ( $debate['aportaciones'] as $aportacion ) {
			if ( $aportacion['uid'] === $uid ) {
				return $aportacion;
			}
		}
	}
	return null;
};
comprobar( null === $buscar( $vista( 'pili' ), 'an1' ), 'una anónima pendiente no la ve otra vecina' );
comprobar( 'maite' === $buscar( $vista( 'maite' ), 'an1' )['autor_uid'], 'quien la escribió la ve como suya' );
comprobar( '' === $buscar( $vista( 'ane' ), 'an1' )['autor_uid'], 'la mesa la ve sin nombre' );
$aplicar( 'ane', 'moderar', array( 'asunto_uid' => 'fiestas', 'aportacion_uid' => 'an1', 'estado' => 'retirada', 'motivo' => 'Insulta' ) );
$retirada = $buscar( $vista( 'pili' ), 'an1' );
comprobar( '' === $retirada['texto'] && 'Insulta' === $retirada['motivo_retirada'], 'de una retirada queda el hueco con el motivo' );

// Borradores.
$borrador = $estado['asuntos']['fiestas'];
$borrador['uid']     = 'borrador';
$borrador['abierto'] = false;
$aplicar( 'ane', 'guardarBorrador', array( 'asunto' => $borrador ) );
$uids = function ( string $persona ) use ( $vista ): array {
	return array_map( fn( $a ) => $a['uid'], $vista( $persona )['asuntos'] );
};
comprobar( in_array( 'borrador', $uids( 'mikel' ), true ), 'la mesa ve los borradores' );
comprobar( ! in_array( 'borrador', $uids( 'pili' ), true ), 'una vecina no ve los borradores' );

// Lo que lee la app: los mapas vacíos salen como objeto.
$json = (string) json_encode( concejo_vista( array( 'personas' => $estado['personas'] ), array(), 'pili', 'x', 0, $ahora, $zona ) );
comprobar( str_contains( $json, '"consentimientos":{}' ), 'consentimientos vacío sale como objeto' );

// Las asambleas las ve todo el mundo.
$sesiones_vecina = $vista( 'pili' )['sesiones'];
comprobar( 2 === count( $sesiones_vecina ), 'una vecina ve las asambleas' );
comprobar( in_array( 'maite', array_merge( ...array_column( $sesiones_vecina, 'asistentes_uids' ) ), true ), 'y quién vino' );

terminar();
