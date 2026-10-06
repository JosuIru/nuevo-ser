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
 * Además sirve la **app Android** (APK) en `/app/descargar/android`. El APK
 * se sube desde el panel («App Android») y se guarda en
 * `wp-content/uploads/solera-zunbeltz/`, fuera del plugin: así no se pierde
 * al actualizarlo ni engorda su `.zip`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_RUTA_APP_WEB       = 'app';
const SZS_RUTA_DESCARGA_APK  = 'descargar/android';
const SZS_OPCION_APK         = 'solera_zunbeltz_apk';
const SZS_FICHERO_APK        = 'solera-zunbeltz.apk';

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
		'apk'   => 'application/vnd.android.package-archive',
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

/** Nombre con que se descarga el APK (con su versión, saneada). Pura. */
function szs_nombre_descarga_apk( string $version ): string {
	$version = trim( (string) preg_replace( '/[^A-Za-z0-9.\-]+/', '_', trim( $version ) ), '_' );
	return '' === $version ? 'solera-zunbeltz.apk' : "solera-zunbeltz-{$version}.apk";
}

/** ¿Parece un APK? Un APK es un zip: empieza por «PK\x03\x04». Pura. */
function szs_es_apk( string $primeros_bytes ): bool {
	return str_starts_with( $primeros_bytes, "PK\x03\x04" );
}

/** Carpeta del APK en uploads (se crea si no existe). */
function szs_carpeta_apk(): string {
	$subidas = wp_upload_dir( null, false );
	return trailingslashit( $subidas['basedir'] ) . 'solera-zunbeltz';
}

function szs_ruta_apk(): string {
	return szs_carpeta_apk() . '/' . SZS_FICHERO_APK;
}

/**
 * Datos del APK publicado: `version`, `tamano`, `fecha` (timestamp) o
 * null si no hay ninguno.
 */
function szs_apk_publicado(): ?array {
	$ruta = szs_ruta_apk();
	if ( ! is_file( $ruta ) ) {
		return null;
	}
	$datos = (array) get_option( SZS_OPCION_APK, array() );
	return array(
		'version' => (string) ( $datos['version'] ?? '' ),
		'tamano'  => (int) filesize( $ruta ),
		'fecha'   => (int) filemtime( $ruta ),
	);
}

function szs_url_apk(): string {
	return home_url( '/' . SZS_RUTA_APP_WEB . '/' . SZS_RUTA_DESCARGA_APK );
}

/**
 * Publica un APK (fichero temporal subido o generado). Comprueba que lo
 * parece y lo deja en su sitio con la versión indicada.
 *
 * @return string|null Mensaje de error, o null si fue bien.
 */
function szs_publicar_apk( string $ruta_origen, string $version, bool $mover_subido = true ): ?string {
	$cabeza = (string) file_get_contents( $ruta_origen, false, null, 0, 4 );
	if ( ! szs_es_apk( $cabeza ) ) {
		return 'El fichero no es un APK de Android.';
	}
	$carpeta = szs_carpeta_apk();
	if ( ! wp_mkdir_p( $carpeta ) ) {
		return 'No se pudo crear la carpeta en uploads.';
	}
	// Que nadie liste la carpeta; el APK se descarga solo por /app/descargar/android.
	if ( ! is_file( $carpeta . '/index.php' ) ) {
		file_put_contents( $carpeta . '/index.php', "<?php\n// Silencio.\n" );
	}
	$destino = szs_ruta_apk();
	$movido  = $mover_subido ? move_uploaded_file( $ruta_origen, $destino ) : copy( $ruta_origen, $destino );
	if ( ! $movido ) {
		return 'No se pudo guardar el APK.';
	}
	update_option(
		SZS_OPCION_APK,
		array(
			'version' => sanitize_text_field( $version ),
			'subido'  => time(),
		),
		false
	);
	return null;
}

function szs_descargar_apk(): void {
	$apk = szs_apk_publicado();
	if ( null === $apk ) {
		status_header( 404 );
		header( 'Content-Type: text/plain; charset=utf-8' );
		echo 'Todavía no hay app Android publicada. Pídela a coordinación.';
		exit;
	}
	nocache_headers();
	status_header( 200 );
	header( 'Content-Type: ' . szs_tipo_mime_app_web( SZS_FICHERO_APK ) );
	header( 'Content-Disposition: attachment; filename="' . szs_nombre_descarga_apk( $apk['version'] ) . '"' );
	header( 'Content-Length: ' . $apk['tamano'] );
	header( 'X-Content-Type-Options: nosniff' );
	readfile( szs_ruta_apk() );
	exit;
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
	if ( SZS_RUTA_DESCARGA_APK === $relativa ) {
		szs_descargar_apk();
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
