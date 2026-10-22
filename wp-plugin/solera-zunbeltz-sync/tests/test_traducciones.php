<?php
/**
 * Tests del panel en euskera (`includes/i18n.php`): toda cadena literal
 * envuelta en `szs_t()` / `szs_tn()` tiene traducción en
 * `includes/traducciones-eu.php`, con los mismos marcadores de `sprintf`
 * y las mismas etiquetas HTML; también las etiquetas de los catálogos que
 * se traducen al mostrarlas. Sin WordPress.
 *
 * Ejecutar: php tests/test_traducciones.php [diccionario-extra.php ...]
 * (los diccionarios extra, que devuelven un array como el principal, se
 * suman al comprobar: sirven para probar traducciones antes de pasarlas).
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $valor;
}

$locale_de_prueba = 'es_ES';
function get_user_locale() {
	return $GLOBALS['locale_de_prueba'];
}

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}
function fallar( string $mensaje ): void {
	global $fallos;
	$fallos++;
	fprintf( STDERR, "FALLO: %s\n", $mensaje );
}

$diccionario = szs_diccionario_euskera();
foreach ( array_slice( $argv, 1 ) as $extra ) {
	$diccionario = array_merge( $diccionario, (array) require $extra );
}

// --- comportamiento ---
afirmar( 'es', szs_idioma_de_locale( 'es_ES' ), 'es_ES → castellano' );
afirmar( 'eu', szs_idioma_de_locale( 'eu' ), 'eu → euskera' );
afirmar( 'eu', szs_idioma_de_locale( 'eu_ES' ), 'eu_ES → euskera' );
afirmar( 'es', szs_idioma_de_locale( 'en_US' ), 'otro idioma → castellano' );
afirmar( 'Tareas', szs_t( 'Tareas' ), 'en castellano sale tal cual' );
afirmar( 'Texto que no está', szs_con_idioma( 'eu', static fn() => szs_t( 'Texto que no está' ) ), 'sin traducción sale en castellano' );
afirmar( 'Vacuna 3', szs_t( 'Vacuna %d', 3 ), 'con argumentos pasa por sprintf' );
afirmar( 'Txertoa', szs_con_idioma( 'eu', static fn() => szs_t( 'Vacuna' ) ), 'forzado a euskera' );
afirmar( 'es', szs_idioma_panel(), 'szs_con_idioma deja el idioma como estaba' );
$GLOBALS['locale_de_prueba'] = 'eu';
afirmar( 'Txertoa', szs_t( 'Vacuna' ), 'usuario con locale eu ve euskera' );
afirmar( 'Vacuna', szs_con_idioma( 'es', static fn() => szs_t( 'Vacuna' ) ), 'el idioma forzado manda sobre el del usuario' );
$GLOBALS['locale_de_prueba'] = 'es_ES';
afirmar( 'Pesaje', szs_tn( 'Pesaje', 'Parto', 1 ), 'szs_tn: singular con 1' );
afirmar( 'Parto', szs_tn( 'Pesaje', 'Parto', 2 ), 'szs_tn: plural con 2' );

// --- cadenas envueltas en el código ---

/**
 * Marcadores de sprintf como lista ordenada de tipos (sin posición). Sin
 * el modificador «espacio», para que «100 % si…» no cuente como `%s`.
 */
function marcadores( string $texto ): array {
	preg_match_all( '/%(?:\d+\$)?[-+0#]*\d*(?:\.\d+)?([bcdeEfFgGosuxX%])/', $texto, $coincidencias );
	$tipos = array_values( array_filter( $coincidencias[1], static fn( $tipo ) => '%' !== $tipo ) );
	sort( $tipos );
	return $tipos;
}

function etiquetas_html( string $texto ): array {
	preg_match_all( '/<\/?([a-zA-Z][a-zA-Z0-9]*)/', $texto, $coincidencias );
	$etiquetas = $coincidencias[0];
	sort( $etiquetas );
	return $etiquetas;
}

/** Valor de un literal de cadena de PHP. */
function valor_literal( string $literal ): string {
	return (string) eval( 'return ' . $literal . ';' ); // phpcs:ignore Squiz.PHP.Eval
}

/**
 * @return array<int, array{texto: string, sitio: string}> literales envueltos.
 */
function cadenas_envueltas( string $fichero, int &$dinamicas ): array {
	$tokens  = token_get_all( file_get_contents( $fichero ) );
	$cadenas = array();
	$total   = count( $tokens );
	$sitio   = basename( dirname( $fichero ) ) . '/' . basename( $fichero );
	for ( $i = 0; $i < $total; $i++ ) {
		if ( ! is_array( $tokens[ $i ] ) || T_STRING !== $tokens[ $i ][0] || ! in_array( $tokens[ $i ][1], array( 'szs_t', 'szs_tn' ), true ) ) {
			continue;
		}
		$anterior = $i - 1;
		while ( $anterior >= 0 && is_array( $tokens[ $anterior ] ) && T_WHITESPACE === $tokens[ $anterior ][0] ) {
			$anterior--;
		}
		if ( $anterior >= 0 && is_array( $tokens[ $anterior ] ) && T_FUNCTION === $tokens[ $anterior ][0] ) {
			continue;
		}
		$linea       = $tokens[ $i ][2];
		$literales   = 'szs_tn' === $tokens[ $i ][1] ? 2 : 1;
		$j           = $i + 1;
		$siguiente   = static function () use ( &$j, $tokens, $total ) {
			while ( $j < $total && is_array( $tokens[ $j ] ) && in_array( $tokens[ $j ][0], array( T_WHITESPACE, T_COMMENT ), true ) ) {
				$j++;
			}
			return $tokens[ $j ] ?? null;
		};
		if ( '(' !== $siguiente() ) {
			continue;
		}
		$j++;
		for ( $argumento = 0; $argumento < $literales; $argumento++ ) {
			$token = $siguiente();
			if ( ! is_array( $token ) || T_CONSTANT_ENCAPSED_STRING !== $token[0] ) {
				$dinamicas++;
				break;
			}
			$j++;
			$tras = $siguiente();
			if ( ',' !== $tras && ')' !== $tras ) {
				fallar( "{$sitio}:{$linea}: cadena de szs_t concatenada o con expresión; usa argumentos (%s)" );
				break;
			}
			$cadenas[] = array( 'texto' => valor_literal( $token[1] ), 'sitio' => "{$sitio}:{$linea}" );
			$j++;
		}
	}
	return $cadenas;
}

$raiz      = dirname( __DIR__ );
$ficheros  = array_merge( array( $raiz . '/solera-zunbeltz-sync.php' ), glob( $raiz . '/includes/*.php' ), glob( $raiz . '/includes/panel/*.php' ) );
$dinamicas = 0;
$usadas    = array();
$envueltas = 0;
foreach ( $ficheros as $fichero ) {
	if ( in_array( basename( $fichero ), array( 'i18n.php', 'traducciones-eu.php' ), true ) ) {
		continue;
	}
	foreach ( cadenas_envueltas( $fichero, $dinamicas ) as $cadena ) {
		$envueltas++;
		$texto            = $cadena['texto'];
		$usadas[ $texto ] = true;
		if ( ! isset( $diccionario[ $texto ] ) || '' === trim( $diccionario[ $texto ] ) ) {
			fallar( "{$cadena['sitio']}: sin traducción al euskera: " . var_export( $texto, true ) );
			continue;
		}
		$traduccion = $diccionario[ $texto ];
		if ( marcadores( $texto ) !== marcadores( $traduccion ) ) {
			fallar( "{$cadena['sitio']}: marcadores distintos en " . var_export( $texto, true ) . ' → ' . var_export( $traduccion, true ) );
		}
		if ( etiquetas_html( $texto ) !== etiquetas_html( $traduccion ) ) {
			fallar( "{$cadena['sitio']}: etiquetas HTML distintas en " . var_export( $texto, true ) . ' → ' . var_export( $traduccion, true ) );
		}
	}
}
afirmar( true, $envueltas > 0, 'hay cadenas envueltas' );

// --- catálogos que se traducen al mostrarlos (`szs_t( $etiqueta )`) ---
$catalogos = array(
	'SZS_ESTADOS_TAREA',
	'SZS_PRIORIDADES_TAREA',
	'SZS_CATEGORIAS_AVISO',
	'SZS_BLOQUES_GASTO',
	'SZS_PARTIDAS_GASTO',
	'SZS_ASUMIDO_POR',
	'SZS_TIPOS_MOVIMIENTO_FIANZA',
	'SZS_NIVELES_INCIDENCIA',
	'SZS_TIPOS_ACOMPANAMIENTO',
	'SZS_ESPECIES_GANADO',
	'SZS_SEXOS_ANIMAL',
	'SZS_ESTADOS_ANIMAL',
	'SZS_TIPOS_MOVIMIENTO_GANADO',
	'SZS_TIPOS_EVENTO_GANADO',
	'SZS_CLASES_MEDICAMENTO',
	'SZS_TIPOS_CONTACTO',
	'SZS_GRUPOS_BIEN',
	'SZS_MODOS_PARTIDA',
	'SZS_ASISTENCIAS',
	'SZS_IDIOMAS_CANAL',
	'SZS_FUENTE_UGM',
);
$recorrer = static function ( $valor, string $nombre ) use ( &$recorrer, $diccionario, &$usadas ): void {
	if ( is_array( $valor ) ) {
		foreach ( $valor as $dentro ) {
			$recorrer( $dentro, $nombre );
		}
		return;
	}
	if ( ! is_string( $valor ) ) {
		return;
	}
	$usadas[ $valor ] = true;
	if ( ! isset( $diccionario[ $valor ] ) ) {
		fallar( "catálogo {$nombre}: sin traducción al euskera: " . var_export( $valor, true ) );
	}
};
foreach ( $catalogos as $nombre ) {
	if ( ! defined( $nombre ) ) {
		fallar( "catálogo {$nombre} no definido" );
		continue;
	}
	$recorrer( constant( $nombre ), $nombre );
}
foreach ( szs_roles() as $rol ) {
	$recorrer( $rol['etiqueta'], 'roles' );
}

// --- el propio diccionario ---
foreach ( $diccionario as $castellano => $euskera ) {
	if ( marcadores( (string) $castellano ) !== marcadores( (string) $euskera ) ) {
		fallar( 'diccionario: marcadores distintos en ' . var_export( $castellano, true ) );
	}
}
$sin_uso = array_diff_key( $diccionario, $usadas );

if ( $fallos > 0 ) {
	fprintf( STDERR, "\n%d fallo(s) en test_traducciones.\n", $fallos );
	exit( 1 );
}
printf( "test_traducciones: OK (%d cadenas envueltas, %d llamadas con texto dinámico, %d entradas en el diccionario, %d sin uso literal)\n", $envueltas, $dinamicas, count( $diccionario ), count( $sin_uso ) );
if ( getenv( 'SZS_LISTAR_SIN_USO' ) ) {
	foreach ( array_keys( $sin_uso ) as $texto ) {
		echo '  sin uso: ' . var_export( $texto, true ) . "\n";
	}
}
