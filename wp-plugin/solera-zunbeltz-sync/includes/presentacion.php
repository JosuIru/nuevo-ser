<?php
/**
 * La presentación del proyecto (la propuesta de la herramienta para
 * Zunbeltz), servida en `/presentacion/`, para enlazarla desde el pie de la
 * web.
 *
 * El original es `apps/solera-zunbeltz/presentacion/index.html`;
 * `dev/empaquetar.sh` lo copia a `presentacion/` dentro del plugin. Si el
 * plugin está enlazado al repo (desarrollo), se sirve el original.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_RUTA_PRESENTACION = 'presentacion';

add_action( 'init', 'szs_servir_presentacion', 0 );

/**
 * Qué hacer con una ruta: `'servir'` (la presentación), `'redirigir'` (sin
 * barra final) o null si no es la suya. Pura.
 */
function szs_accion_presentacion( string $ruta, string $base ): ?string {
	if ( $ruta === $base ) {
		return 'redirigir';
	}
	if ( $ruta === $base . '/' || $ruta === $base . '/index.html' ) {
		return 'servir';
	}
	return null;
}

/** Fichero de la presentación, o null si no está. */
function szs_fichero_presentacion(): ?string {
	$candidatos = array(
		dirname( __DIR__ ) . '/presentacion/index.html',
		dirname( __DIR__, 3 ) . '/apps/solera-zunbeltz/presentacion/index.html',
	);
	foreach ( $candidatos as $candidato ) {
		if ( is_file( $candidato ) ) {
			return $candidato;
		}
	}
	return null;
}

function szs_url_presentacion(): string {
	return home_url( '/' . SZS_RUTA_PRESENTACION . '/' );
}

/** ¿Hay presentación que enlazar? (el tema lo pregunta para el pie). */
function szs_hay_presentacion(): bool {
	return null !== szs_fichero_presentacion();
}

function szs_servir_presentacion(): void {
	$ruta   = (string) wp_parse_url( (string) ( $_SERVER['REQUEST_URI'] ?? '' ), PHP_URL_PATH );
	$base   = rtrim( (string) wp_parse_url( home_url( '/' ), PHP_URL_PATH ), '/' ) . '/' . SZS_RUTA_PRESENTACION;
	$accion = szs_accion_presentacion( $ruta, $base );
	if ( null === $accion ) {
		return;
	}
	if ( 'redirigir' === $accion ) {
		wp_safe_redirect( szs_url_presentacion(), 301 );
		exit;
	}
	$fichero = szs_fichero_presentacion();
	if ( null === $fichero ) {
		return;
	}
	$modificado = (int) filemtime( $fichero );
	$etiqueta   = '"' . md5( $fichero . $modificado . filesize( $fichero ) ) . '"';
	status_header( 200 );
	header( 'Content-Type: text/html; charset=utf-8' );
	header( 'Cache-Control: no-cache' );
	header( 'ETag: ' . $etiqueta );
	header( 'X-Content-Type-Options: nosniff' );
	if ( szs_etag_coincide( wp_unslash( (string) ( $_SERVER['HTTP_IF_NONE_MATCH'] ?? '' ) ), $etiqueta ) ) {
		status_header( 304 );
		exit;
	}
	header( 'Content-Length: ' . filesize( $fichero ) );
	readfile( $fichero );
	exit;
}
