<?php
/**
 * Idioma del panel de coordinación: castellano o euskera.
 *
 * MECANISMO (elegido el 2026-10-23): las cadenas se escriben en castellano
 * en el código, envueltas en `szs_t( 'Texto', ...$argumentos )`, y la
 * traducción al euskera sale de un diccionario PHP plano
 * (`traducciones-eu.php`: castellano => euskera). Se descartó gettext
 * (.po/.mo) porque obliga a compilar con `msgfmt` y a mantener un text
 * domain y ficheros binarios en el repo; aquí basta con editar un array.
 *
 * - Idioma: el del usuario de WordPress (`get_user_locale()`): si empieza
 *   por `eu`, euskera; si no, castellano. Para los correos, que no tienen
 *   usuario conectado, `szs_con_idioma()` fuerza el de cada destinatario.
 * - Si una cadena no está en el diccionario sale en castellano: nunca se
 *   rompe nada, solo queda sin traducir. `tests/test_traducciones.php`
 *   falla si una cadena envuelta (literal) no tiene traducción o si la
 *   traducción no lleva los mismos marcadores (`%s`, `%d`…) y etiquetas HTML.
 * - Con argumentos, la cadena pasa por `sprintf`: un «%» literal se escribe
 *   «%%». Si el euskera necesita otro orden, usa marcadores con posición
 *   (`%2$s … %1$s`).
 * - Plurales: `szs_tn( 'singular', 'plural', $n, ...$argumentos )`; las dos
 *   formas en castellano son claves del diccionario.
 * - Las etiquetas de los catálogos generados desde la app (bloques de gasto,
 *   especies…) se traducen al mostrarlas: `szs_t( $etiqueta )`. El test
 *   recorre esos catálogos para que no falte ninguna.
 * - Lo que se guarda como dato (títulos de tareas tipo, textos de las
 *   personas) no se traduce.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Idioma forzado por `szs_con_idioma()` (correos), o null. */
$GLOBALS['szs_idioma_forzado'] = null;

/** `eu` o `es` según el locale dado (`eu`, `eu_ES`…). */
function szs_idioma_de_locale( string $locale ): string {
	return str_starts_with( strtolower( $locale ), 'eu' ) ? 'eu' : 'es';
}

/** Idioma del panel para el usuario conectado (o el forzado). */
function szs_idioma_panel(): string {
	if ( null !== $GLOBALS['szs_idioma_forzado'] ) {
		return $GLOBALS['szs_idioma_forzado'];
	}
	return szs_idioma_de_locale( function_exists( 'get_user_locale' ) ? (string) get_user_locale() : 'es_ES' );
}

/**
 * Ejecuta `$funcion` con el idioma dado (`es`/`eu`) y lo deja como estaba.
 *
 * @return mixed Lo que devuelva `$funcion`.
 */
function szs_con_idioma( string $idioma, callable $funcion ) {
	$anterior                      = $GLOBALS['szs_idioma_forzado'];
	$GLOBALS['szs_idioma_forzado'] = 'eu' === $idioma ? 'eu' : 'es';
	try {
		return $funcion();
	} finally {
		$GLOBALS['szs_idioma_forzado'] = $anterior;
	}
}

/** @return array<string, string> castellano => euskera. */
function szs_diccionario_euskera(): array {
	static $diccionario = null;
	if ( null === $diccionario ) {
		$diccionario = (array) require __DIR__ . '/traducciones-eu.php';
	}
	return $diccionario;
}

/**
 * Texto en el idioma del panel. `$texto` va en castellano; con argumentos
 * se formatea con `sprintf`.
 */
function szs_t( string $texto, ...$argumentos ): string {
	$traducido = $texto;
	if ( 'eu' === szs_idioma_panel() ) {
		$diccionario = szs_diccionario_euskera();
		if ( isset( $diccionario[ $texto ] ) && '' !== $diccionario[ $texto ] ) {
			$traducido = $diccionario[ $texto ];
		}
	}
	return empty( $argumentos ) ? $traducido : sprintf( $traducido, ...$argumentos );
}

/** Singular o plural según `$cantidad`, traducido. */
function szs_tn( string $singular, string $plural, int $cantidad, ...$argumentos ): string {
	return szs_t( 1 === $cantidad ? $singular : $plural, ...$argumentos );
}

/**
 * Etiquetas de un mapa `clave => etiqueta en castellano` (catálogos de la
 * app, estados…) traducidas, para selectores y listados.
 *
 * @param array<string, string> $opciones
 * @return array<string, string>
 */
function szs_t_opciones( array $opciones ): array {
	return array_map( static fn( $etiqueta ) => szs_t( (string) $etiqueta ), $opciones );
}
