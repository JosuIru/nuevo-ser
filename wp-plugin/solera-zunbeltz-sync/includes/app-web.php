<?php
/**
 * La versión web de la app, servida por el propio WordPress en `/app/`
 * (p. ej. `https://app.zunbeltz.com/app/`).
 *
 * Así la oficina tiene una sola dirección para el panel (`/wp-admin`) y la
 * app, no hace falta CORS (mismo origen que la API) y la app rellena sola
 * la dirección del servidor: cada persona solo pone su token.
 *
 * Los ficheros vienen de `app-web/` dentro del plugin, generados con
 * `dev/construir_app_web.sh` (compila `apps/solera-zunbeltz` con
 * `--base-href /app/`). Si el WordPress está en una subcarpeta, hay que
 * compilar con esa ruta (`dev/construir_app_web.sh /subcarpeta/app/`).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_RUTA_APP_WEB = 'app';

add_action( 'init', 'szs_servir_app_web', 0 );

/**
 * Fichero (relativo a `app-web/`) que pide una ruta de la petición, `''`
 * para la raíz sin barra (se redirige a la barra) o `null` si la ruta no es
 * de la app o intenta salirse de su carpeta. Pura.
 */
function szs_ruta_relativa_app_web( string $ruta, string $base ): ?string {
	if ( $ruta === $base ) {
		return '';
	}
	if ( ! str_starts_with( $ruta, $base . '/' ) ) {
		return null;
	}
	$relativa = rawurldecode( substr( $ruta, strlen( $base ) + 1 ) );
	if ( '' === $relativa ) {
		return 'index.html';
	}
	foreach ( explode( '/', $relativa ) as $tramo ) {
		if ( '..' === $tramo || '.' === $tramo || str_contains( $tramo, "\0" ) ) {
			return null;
		}
	}
	return $relativa;
}

/** Tipo MIME por extensión (el wasm tiene que ir como wasm). Pura. */
function szs_tipo_mime_app_web( string $fichero ): string {
	$tipos = array(
		'html'  => 'text/html; charset=utf-8',
		'js'    => 'text/javascript; charset=utf-8',
		'mjs'   => 'text/javascript; charset=utf-8',
		'json'  => 'application/json; charset=utf-8',
		'wasm'  => 'application/wasm',
		'css'   => 'text/css; charset=utf-8',
		'png'   => 'image/png',
		'jpg'   => 'image/jpeg',
		'svg'   => 'image/svg+xml',
		'ico'   => 'image/x-icon',
		'ttf'   => 'font/ttf',
		'otf'   => 'font/otf',
		'woff2' => 'font/woff2',
		'txt'   => 'text/plain; charset=utf-8',
		'bin'   => 'application/octet-stream',
	);
	$extension = strtolower( pathinfo( $fichero, PATHINFO_EXTENSION ) );
	return $tipos[ $extension ] ?? 'application/octet-stream';
}

/**
 * ¿La cabecera `If-None-Match` del navegador incluye esta etiqueta? Acepta
 * varias separadas por comas y la forma débil `W/"…"` que pone nginx al
 * comprimir. Pura.
 */
function szs_etag_coincide( string $cabecera, string $etiqueta ): bool {
	foreach ( explode( ',', $cabecera ) as $candidata ) {
		$candidata = trim( $candidata );
		if ( str_starts_with( $candidata, 'W/' ) ) {
			$candidata = substr( $candidata, 2 );
		}
		if ( '*' === $candidata || $candidata === $etiqueta ) {
			return true;
		}
	}
	return false;
}

function szs_carpeta_app_web(): string {
	return dirname( __DIR__ ) . '/app-web';
}

function szs_url_app_web(): string {
	return home_url( '/' . SZS_RUTA_APP_WEB . '/' );
}

function szs_servir_app_web(): void {
	$ruta = (string) wp_parse_url( (string) ( $_SERVER['REQUEST_URI'] ?? '' ), PHP_URL_PATH );
	$base = rtrim( (string) wp_parse_url( home_url( '/' ), PHP_URL_PATH ), '/' ) . '/' . SZS_RUTA_APP_WEB;

	$relativa = szs_ruta_relativa_app_web( $ruta, $base );
	if ( null === $relativa ) {
		return;
	}
	if ( '' === $relativa ) {
		wp_safe_redirect( szs_url_app_web(), 301 );
		exit;
	}

	$carpeta = realpath( szs_carpeta_app_web() );
	if ( false === $carpeta ) {
		status_header( 503 );
		header( 'Content-Type: text/plain; charset=utf-8' );
		echo 'La app web no está instalada en este servidor (falta app-web/ en el plugin).';
		exit;
	}
	$fichero = realpath( $carpeta . '/' . $relativa );
	if ( false === $fichero || ! str_starts_with( $fichero, $carpeta . DIRECTORY_SEPARATOR ) || ! is_file( $fichero ) ) {
		status_header( 404 );
		header( 'Content-Type: text/plain; charset=utf-8' );
		echo 'No encontrado.';
		exit;
	}

	// Revalidar siempre: tras actualizar el plugin, nadie se queda con una
	// app vieja en caché. Si no ha cambiado, 304 sin cuerpo.
	$modificado = (int) filemtime( $fichero );
	$etiqueta   = '"' . md5( $fichero . $modificado . filesize( $fichero ) ) . '"';
	status_header( 200 );
	header( 'Content-Type: ' . szs_tipo_mime_app_web( $fichero ) );
	header( 'Cache-Control: no-cache' );
	header( 'ETag: ' . $etiqueta );
	header( 'Last-Modified: ' . gmdate( 'D, d M Y H:i:s', $modificado ) . ' GMT' );
	header( 'X-Content-Type-Options: nosniff' );
	if ( szs_etag_coincide( wp_unslash( (string) ( $_SERVER['HTTP_IF_NONE_MATCH'] ?? '' ) ), $etiqueta ) ) {
		status_header( 304 );
		exit;
	}
	header( 'Content-Length: ' . filesize( $fichero ) );
	readfile( $fichero );
	exit;
}
