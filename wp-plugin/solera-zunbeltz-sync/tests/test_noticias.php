<?php
/**
 * Tests de la lógica pura de las noticias del sector: limpieza del texto
 * de los feeds, filtro por palabras clave, normalización de cada elemento
 * y la lista que baja la app. Sin WordPress.
 *
 * Ejecutar: php tests/test_noticias.php
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

$ahora_ms = 1_791_244_800_000; // 2026-10-06 00:00 UTC
$dia_ms   = 86_400_000;

// --- texto plano ---
afirmar( 'Feria de ganado en Estella', szs_texto_plano_noticia( '<p>Feria  de <b>ganado</b>&nbsp;en Estella</p>', 100 ), 'quita etiquetas, entidades y espacios dobles' );
afirmar( 'Hola', szs_texto_plano_noticia( '<script>alert(1)</script>Hola<style>p{}</style>', 100 ), 'quita scripts y estilos con su contenido' );
afirmar( 'Ayudas a la incorporación de…', szs_texto_plano_noticia( 'Ayudas a la incorporación de jóvenes agricultores', 33 ), 'recorta sin partir palabras' );
afirmar( 'Ganadería «ecológica»', szs_texto_plano_noticia( 'Ganader&iacute;a &laquo;ecol&oacute;gica&raquo;', 100 ), 'decodifica entidades con tildes' );

// --- palabras clave ---
afirmar( true, szs_noticia_pasa_filtro( 'Cualquier cosa', '', '' ), 'sin palabras clave pasa todo' );
afirmar( true, szs_noticia_pasa_filtro( 'Nueva convocatoria de GANADERÍA', '', 'ovino, ganaderia' ), 'sin distinguir mayúsculas ni tildes' );
afirmar( true, szs_noticia_pasa_filtro( 'Titular', 'habla del ecorrégimen de pastos', "pac\npastos" ), 'busca también en la entradilla y acepta saltos de línea' );
afirmar( false, szs_noticia_pasa_filtro( 'Osasuna gana en casa', 'Fútbol', 'ganadería, ovino' ), 'sin coincidencias no pasa' );
afirmar( false, szs_noticia_pasa_filtro( 'El impacto del acuerdo', '', 'PAC' ), 'la palabra clave no se busca en mitad de otra palabra' );
afirmar( true, szs_noticia_pasa_filtro( 'Cambios en la PAC', '', 'pac' ), '… pero sí como palabra suelta' );
afirmar( true, szs_noticia_pasa_filtro( 'Jornada para ganaderos', '', 'ganader' ), '… y como comienzo de palabra' );
afirmar( array( 'ovino', 'PAC' ), szs_palabras_clave( ' ovino ,, PAC ,' ), 'ignora palabras vacías' );

// --- enlaces ---
afirmar( true, szs_enlace_web_valido( 'https://www.navarra.es/es/noticias/1' ), 'https vale' );
afirmar( false, szs_enlace_web_valido( 'javascript:alert(1)' ), 'javascript: no vale' );
afirmar( false, szs_enlace_web_valido( 'file:///etc/passwd' ), 'file: no vale' );
afirmar( false, szs_enlace_web_valido( '/noticia/relativa' ), 'relativo no vale' );

// --- normalización de un elemento ---
$canal   = array( 'id' => 3, 'palabras_clave' => '' );
$noticia = szs_normalizar_item_noticia(
	array(
		'titulo'      => 'Abierta la convocatoria',
		'descripcion' => '',
		'contenido'   => '<p>Texto largo del artículo</p>',
		'enlace'      => 'https://ejemplo.eus/berria',
		'guid'        => 'guid-1',
		'fecha_s'     => intdiv( $ahora_ms - $dia_ms, 1000 ),
	),
	$canal,
	$ahora_ms
);
afirmar( 'Texto largo del artículo', $noticia['entradilla'], 'sin descripción usa el contenido' );
afirmar( $ahora_ms - $dia_ms, $noticia['fecha_ms'], 'fecha del feed en ms' );
afirmar( sha1( '3|guid-1' ), $noticia['guid_hash'], 'el guid identifica la noticia dentro de su canal' );
$sin_guid = szs_normalizar_item_noticia( array( 'titulo' => 'T', 'enlace' => 'https://a.es/x' ), $canal, $ahora_ms );
afirmar( sha1( '3|https://a.es/x' ), $sin_guid['guid_hash'], 'sin guid se identifica por el enlace' );
afirmar( $ahora_ms, $sin_guid['fecha_ms'], 'sin fecha, la de ahora' );
$futura = szs_normalizar_item_noticia( array( 'titulo' => 'T', 'enlace' => 'https://a.es/x', 'fecha_s' => intdiv( $ahora_ms, 1000 ) + 86400 * 30 ), $canal, $ahora_ms );
afirmar( $ahora_ms, $futura['fecha_ms'], 'una fecha futura no la deja fijada arriba' );
afirmar( null, szs_normalizar_item_noticia( array( 'titulo' => '', 'enlace' => 'https://a.es' ), $canal, $ahora_ms ), 'sin título se descarta' );
afirmar( null, szs_normalizar_item_noticia( array( 'titulo' => 'Vieja', 'enlace' => 'https://a.es/v', 'fecha_s' => intdiv( $ahora_ms, 1000 ) - 86400 * 91 ), $canal, $ahora_ms ), 'lo que la limpieza borraría por viejo no entra' );
afirmar( null, szs_normalizar_item_noticia( array( 'titulo' => 'T', 'enlace' => 'javascript:x' ), $canal, $ahora_ms ), 'sin enlace web se descarta' );
afirmar( null, szs_normalizar_item_noticia( array( 'titulo' => 'Fútbol', 'enlace' => 'https://a.es' ), array( 'id' => 3, 'palabras_clave' => 'ovino' ), $ahora_ms ), 'fuera del filtro del canal se descarta' );

// --- lista para la app ---
$fila  = static fn( int $id, int $hace_dias, int $oculta = 0, int $fijada = 0, int $canal_id = 1 ): array => array(
	'id'           => $id,
	'canal_id'     => $canal_id,
	'titulo'       => "N{$id}",
	'entradilla'   => '',
	'enlace'       => 'https://a.es',
	'fecha_ms'     => $ahora_ms - $hace_dias * $dia_ms,
	'oculta'       => $oculta,
	'fijada'       => $fijada,
	'canal_nombre' => 'INTIA',
	'canal_idioma' => 'eu',
);
$lista = szs_noticias_para_app( array( $fila( 1, 5 ), $fila( 2, 1 ), $fila( 3, 2, 1 ), $fila( 4, 95 ), $fila( 5, 120, 0, 1 ) ), $ahora_ms );
afirmar( array( 5, 2, 1 ), array_column( $lista, 'id' ), 'fijadas primero aunque sean viejas; sin ocultas ni pasadas de fecha; luego la más reciente' );
afirmar( array( 1 ), array_column( szs_noticias_para_app( array( $fila( 1, 34 ) ), $ahora_ms ), 'id' ), 'un canal que publica poco sigue saliendo al mes' );
$muchas = array();
for ( $i = 1; $i <= 15; $i++ ) {
	$muchas[] = $fila( $i, 0, 0, 0, 1 );
}
$muchas[] = $fila( 99, 30, 0, 0, 2 );
$repartidas = szs_noticias_para_app( $muchas, $ahora_ms );
afirmar( SZS_MAXIMO_POR_CANAL_EN_APP + 1, count( $repartidas ), 'como mucho 10 por canal' );
afirmar( 99, end( $repartidas )['id'], 'el canal que publica poco no queda tapado' );
afirmar( 'INTIA', $lista[0]['fuente'], 'lleva el nombre del canal' );
afirmar( 'eu', $lista[0]['idioma'], 'y su idioma' );
afirmar( true, $lista[0]['fijada'], 'y si está fijada' );
afirmar( 2, count( szs_noticias_para_app( array( $fila( 1, 1 ), $fila( 2, 2 ), $fila( 3, 3 ) ), $ahora_ms, 30, 2 ) ), 'respeta el límite' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallos\n", $fallos );
	exit( 1 );
}
echo "test_noticias: todo bien\n";
