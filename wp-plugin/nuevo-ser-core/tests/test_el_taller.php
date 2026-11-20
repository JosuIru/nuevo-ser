<?php
/**
 * Smoke tests de El Taller: fusión del progreso (paridad con el cliente),
 * validación de la petición al sensei, cuerpo de la petición y lectura de la respuesta.
 * Sin PHPUnit ni WordPress: `php tests/test_el_taller.php`.
 *
 * tests/fixtures/el-taller-fusion.json es copia de educa/src/nucleo/casos/fusion.json:
 * si cambian los casos allí, se copian aquí (los dos lados deben dar lo mismo).
 */

define( 'ABSPATH', __DIR__ );

require_once __DIR__ . '/../includes/class-ns-el-taller.php';

$fallos = 0;

/**
 * @param mixed $esperado
 * @param mixed $real
 */
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

/** Ordena las claves de practicas para comparar sin depender del orden de inserción. */
function ordenado( array $estado ): array {
	ksort( $estado['practicas'] );
	return $estado;
}

// ───────── Fusión: casos compartidos con el cliente ─────────
$casos = json_decode( file_get_contents( __DIR__ . '/fixtures/el-taller-fusion.json' ), true );
foreach ( $casos as $caso ) {
	afirmar( ordenado( $caso['esperado'] ), ordenado( NS_El_Taller::fusionar_estados( $caso['a'], $caso['b'] ) ), 'paridad: ' . $caso['titulo'] );
	afirmar( ordenado( $caso['esperado'] ), ordenado( NS_El_Taller::fusionar_estados( $caso['b'], $caso['a'] ) ), 'paridad (al revés): ' . $caso['titulo'] );
}
$fusion = NS_El_Taller::fusionar_estados( $casos[0]['a'], $casos[0]['b'] );
afirmar( ordenado( $fusion ), ordenado( NS_El_Taller::fusionar_estados( $fusion, $casos[0]['b'] ) ), 'idempotente: sincronizar dos veces no suma dos veces' );

// ───────── Normalización ─────────
$reparado = NS_El_Taller::normalizar_estado( array( 'tinta' => -5, 'practicas' => array( 'gesto' => 'x', 'trazo-lineas' => 2 ), 'diasActivos' => array( '2026-11-20', 'basura', '2026-11-20' ) ) );
afirmar( 0, $reparado['tinta'], 'tinta negativa → 0' );
afirmar( array( 'trazo-lineas' => 2 ), $reparado['practicas'], 'prácticas no numéricas fuera' );
afirmar( array( '2026-11-20' ), $reparado['diasActivos'], 'días válidos y sin repetir' );
afirmar( NS_El_Taller::estado_inicial(), NS_El_Taller::normalizar_estado( 'basura' ), 'cualquier cosa → estado vacío' );
$sin_id = NS_El_Taller::normalizar_estado( array( 'registro' => array( array( 'fecha' => '2026-11-20', 'idHabilidad' => 'gesto', 'tinta' => 10 ) ) ) );
afirmar( 'antiguo-2026-11-20-gesto-0', $sin_id['registro'][0]['id'], 'anotación antigua recibe id estable' );

// ───────── Sensei: validación ─────────
$valida = NS_El_Taller::validar_peticion_sensei( array( 'imagen' => base64_encode( 'png falso' ), 'idioma' => 'eu', 'habilidad' => 'Cara de manga', 'pregunta' => '¿Los ojos están bien?' ) );
afirmar( true, $valida['ok'], 'petición válida' );
afirmar( 'eu', $valida['idioma'], 'idioma euskera' );
afirmar( 'image/jpeg', $valida['tipo'], 'jpeg por defecto' );
afirmar( 'falta_imagen', NS_El_Taller::validar_peticion_sensei( array() )['error'] ?? null, 'sin imagen' );
afirmar( 'imagen_no_es_base64', NS_El_Taller::validar_peticion_sensei( array( 'imagen' => 'no es <base64>' ) )['error'] ?? null, 'imagen que no es base64' );
afirmar( 'tipo_de_imagen_no_admitido', NS_El_Taller::validar_peticion_sensei( array( 'imagen' => 'QUJD', 'tipo_imagen' => 'image/svg+xml' ) )['error'] ?? null, 'svg no' );
afirmar( 'imagen_demasiado_grande', NS_El_Taller::validar_peticion_sensei( array( 'imagen' => str_repeat( 'A', NS_El_Taller::MAXIMO_BYTES_IMAGEN + 4 ) ) )['error'] ?? null, 'imagen enorme' );
afirmar( 'pregunta_demasiado_larga', NS_El_Taller::validar_peticion_sensei( array( 'imagen' => 'QUJD', 'pregunta' => str_repeat( 'a', 301 ) ) )['error'] ?? null, 'pregunta larga' );
afirmar( 'es', NS_El_Taller::validar_peticion_sensei( array( 'imagen' => 'QUJD', 'idioma' => 'fr' ) )['idioma'] ?? null, 'idioma desconocido → castellano' );

// ───────── Sensei: petición a la API ─────────
$cuerpo = NS_El_Taller::cuerpo_peticion( $valida, 'claude-opus-5-5' );
afirmar( 'claude-opus-5-5', $cuerpo['model'], 'modelo' );
afirmar( 'image', $cuerpo['messages'][0]['content'][0]['type'], 'la imagen va primero' );
afirmar( 'base64', $cuerpo['messages'][0]['content'][0]['source']['type'], 'imagen en base64' );
afirmar( 'default', $cuerpo['fallbacks'] ?? null, 'Opus 5.5 con fallback del servidor' );
afirmar( 'medium', $cuerpo['output_config']['effort'] ?? null, 'esfuerzo medio explícito' );
afirmar( false, isset( $cuerpo['temperature'] ), 'sin temperature' );
afirmar( 'ephemeral', $cuerpo['system'][0]['cache_control']['type'] ?? null, 'instrucciones cacheables' );
afirmar( true, false !== strpos( $cuerpo['system'][0]['text'], 'euskera' ), 'instrucciones en euskera si lo pide' );
afirmar( false, (bool) preg_match( '/\d{4}-\d{2}-\d{2}/', $cuerpo['system'][0]['text'] ), 'instrucciones sin fechas (caché estable)' );
$cuerpo_haiku = NS_El_Taller::cuerpo_peticion( $valida, 'claude-haiku-4-5' );
afirmar( false, isset( $cuerpo_haiku['fallbacks'] ) || isset( $cuerpo_haiku['output_config'] ), 'Haiku 4.5 sin fallback ni effort' );
afirmar( true, false !== strpos( NS_El_Taller::texto_usuario( $valida ), 'Cara de manga' ), 'el texto dice qué practica' );

// ───────── Sensei: lectura de la respuesta ─────────
afirmar(
	'Me gusta la línea de acción.',
	NS_El_Taller::texto_de_respuesta(
		array(
			'stop_reason' => 'end_turn',
			'content'     => array(
				array( 'type' => 'thinking', 'thinking' => '' ),
				array( 'type' => 'text', 'text' => 'Me gusta la línea de acción.' ),
			),
		)
	),
	'ignora el razonamiento y se queda con el texto'
);
afirmar( null, NS_El_Taller::texto_de_respuesta( array( 'stop_reason' => 'refusal', 'content' => array( array( 'type' => 'text', 'text' => 'x' ) ) ) ), 'rechazo → sin texto' );
afirmar( null, NS_El_Taller::texto_de_respuesta( array( 'content' => array() ) ), 'vacía → sin texto' );
afirmar( null, NS_El_Taller::texto_de_respuesta( 'basura' ), 'formato raro → sin texto' );

if ( $fallos > 0 ) {
	exit( 1 );
}
echo "OK\n";
