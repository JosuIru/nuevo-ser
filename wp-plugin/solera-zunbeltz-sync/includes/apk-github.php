<?php
/**
 * El APK de la app Android sale de las releases de GitHub del monorepo
 * (`solera-zunbeltz-<versión>` con `solera-zunbeltz-<versión>.apk`), las
 * mismas de las que se actualiza la app. `/app/descargar/android` redirige
 * a la última; si GitHub no responde o no hay ninguna, se sirve el APK
 * subido en el panel (`includes/panel/pagina-android.php`).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_API_RELEASES_APK     = 'https://api.github.com/repos/JosuIru/nuevo-ser/releases?per_page=50';
const SZS_PREFIJO_TAG_APK      = 'solera-zunbeltz-';
const SZS_TRANSITORIO_APK      = 'szs_apk_github';
const SZS_CADUCIDAD_APK        = 3600;
const SZS_CADUCIDAD_APK_FALLO  = 600;

/**
 * De la lista de releases de la API de GitHub (las más nuevas primero), la
 * primera de la app con su APK: `version`, `url`, `tamano`, `fecha`
 * (timestamp), o null. Pura.
 */
function szs_elegir_release_apk( array $releases ): ?array {
	foreach ( $releases as $release ) {
		if ( ! is_array( $release ) || ! empty( $release['draft'] ) || ! empty( $release['prerelease'] ) ) {
			continue;
		}
		$tag = (string) ( $release['tag_name'] ?? '' );
		if ( ! str_starts_with( $tag, SZS_PREFIJO_TAG_APK ) ) {
			continue;
		}
		$version = substr( $tag, strlen( SZS_PREFIJO_TAG_APK ) );
		// Fuera las releases del plugin u otras con el mismo prefijo.
		if ( 1 !== preg_match( '/^\d+(\.\d+)*(\+\d+)?$/', $version ) ) {
			continue;
		}
		foreach ( (array) ( $release['assets'] ?? array() ) as $asset ) {
			$nombre = (string) ( $asset['name'] ?? '' );
			$url    = (string) ( $asset['browser_download_url'] ?? '' );
			if ( str_starts_with( $nombre, SZS_PREFIJO_TAG_APK ) && str_ends_with( strtolower( $nombre ), '.apk' )
				&& str_starts_with( $url, 'https://github.com/' ) ) {
				return array(
					'version' => $version,
					'url'     => $url,
					'tamano'  => (int) ( $asset['size'] ?? 0 ),
					'fecha'   => (int) strtotime( (string) ( $release['published_at'] ?? '' ) ),
				);
			}
		}
	}
	return null;
}

/**
 * Último APK publicado en GitHub, con caché. null si no hay o GitHub no
 * responde (el fallo se recuerda unos minutos para no insistir).
 */
function szs_apk_github(): ?array {
	$guardado = get_transient( SZS_TRANSITORIO_APK );
	if ( is_array( $guardado ) ) {
		return $guardado['apk'] ?? null;
	}
	$respuesta = wp_remote_get(
		SZS_API_RELEASES_APK,
		array(
			'timeout' => 8,
			'headers' => array(
				'Accept'     => 'application/vnd.github+json',
				'User-Agent' => 'solera-zunbeltz-sync/' . SZS_VERSION,
			),
		)
	);
	$apk = null;
	if ( ! is_wp_error( $respuesta ) && 200 === (int) wp_remote_retrieve_response_code( $respuesta ) ) {
		$lista = json_decode( (string) wp_remote_retrieve_body( $respuesta ), true );
		$apk   = is_array( $lista ) ? szs_elegir_release_apk( $lista ) : null;
	}
	set_transient( SZS_TRANSITORIO_APK, array( 'apk' => $apk ), null === $apk ? SZS_CADUCIDAD_APK_FALLO : SZS_CADUCIDAD_APK );
	return $apk;
}
