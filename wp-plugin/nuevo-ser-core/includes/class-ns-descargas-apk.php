<?php
/**
 * Enlace para descargar la app Android de un juego desde GitHub Releases
 * del monorepo:
 *
 *   [nuevo_ser_descarga juego="las-versiones"]
 *
 * Busca el release más reciente con el formato que publica
 * `scripts/publicar_release.sh` (el mismo que lee la pantalla
 * «Actualizaciones» de las apps): tag `<juego>-<versión>` con un asset
 * `.apk`. Los bundles antiguos (`apks-2026-05-18`…) no cuentan: sus APK
 * se quedaron viejas. La consulta a GitHub la hace el servidor y se
 * guarda una hora; el visitante sólo va a GitHub si pulsa el enlace.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Descargas_Apk {

	/** Repositorio público donde se publican las APK (propietario/nombre). */
	const REPOSITORIO = 'JosuIru/nuevo-ser';

	const CLAVE_CACHE = 'ns_releases_apk';

	public static function registrar(): void {
		add_shortcode( 'nuevo_ser_descarga', array( __CLASS__, 'shortcode' ) );
	}

	/**
	 * Elige la APK más reciente de [juego] entre los releases que
	 * devuelve la API de GitHub (ya en orden, el más nuevo primero).
	 *
	 * @param array  $releases Releases decodificados de la API.
	 * @param string $juego    Carpeta de apps/ (uno-roto, las-versiones…).
	 * @return array|null url, version, tamano (bytes), fecha; o null.
	 */
	public static function elegir_apk( array $releases, string $juego ): ?array {
		$prefijo = $juego . '-';
		foreach ( $releases as $release ) {
			if ( ! is_array( $release ) || ! empty( $release['draft'] ) || ! empty( $release['prerelease'] ) ) {
				continue;
			}
			$tag = (string) ( $release['tag_name'] ?? '' );
			// La versión empieza por dígito: así «solera» no se queda con
			// los releases de «solera-quesera».
			if ( 0 !== strpos( $tag, $prefijo ) || ! ctype_digit( substr( $tag, strlen( $prefijo ), 1 ) ) ) {
				continue;
			}
			foreach ( (array) ( $release['assets'] ?? array() ) as $asset ) {
				$nombre = (string) ( $asset['name'] ?? '' );
				if ( '.apk' === substr( $nombre, -4 ) && ! empty( $asset['browser_download_url'] ) ) {
					return array(
						'url'     => (string) $asset['browser_download_url'],
						'version' => substr( $tag, strlen( $prefijo ) ),
						'tamano'  => (int) ( $asset['size'] ?? 0 ),
						'fecha'   => (string) ( $release['published_at'] ?? '' ),
					);
				}
			}
		}
		return null;
	}

	/** La APK más reciente de [juego], o null si no hay (o GitHub no responde). */
	public static function ultima_apk( string $juego ): ?array {
		return self::elegir_apk( self::releases(), $juego );
	}

	/** Releases del repositorio, guardados una hora (diez minutos si GitHub falla). */
	private static function releases(): array {
		$guardados = get_transient( self::CLAVE_CACHE );
		if ( is_array( $guardados ) ) {
			return $guardados;
		}
		$respuesta = wp_remote_get(
			'https://api.github.com/repos/' . self::REPOSITORIO . '/releases?per_page=100',
			array(
				'timeout' => 5,
				'headers' => array(
					'Accept'     => 'application/vnd.github+json',
					'User-Agent' => 'nuevo-ser-core',
				),
			)
		);
		$releases = array();
		if ( ! is_wp_error( $respuesta ) && 200 === wp_remote_retrieve_response_code( $respuesta ) ) {
			$decodificados = json_decode( wp_remote_retrieve_body( $respuesta ), true );
			$releases      = is_array( $decodificados ) ? self::compactar( $decodificados ) : array();
		}
		set_transient( self::CLAVE_CACHE, $releases, $releases ? HOUR_IN_SECONDS : 10 * MINUTE_IN_SECONDS );
		return $releases;
	}

	/** Sólo lo que hace falta de cada release: la respuesta entera pesa mucho para un transient. */
	private static function compactar( array $releases ): array {
		$compactos = array();
		foreach ( $releases as $release ) {
			if ( ! is_array( $release ) ) {
				continue;
			}
			$assets = array();
			foreach ( (array) ( $release['assets'] ?? array() ) as $asset ) {
				$assets[] = array(
					'name'                 => $asset['name'] ?? '',
					'browser_download_url' => $asset['browser_download_url'] ?? '',
					'size'                 => $asset['size'] ?? 0,
				);
			}
			$compactos[] = array(
				'tag_name'     => $release['tag_name'] ?? '',
				'draft'        => ! empty( $release['draft'] ),
				'prerelease'   => ! empty( $release['prerelease'] ),
				'published_at' => $release['published_at'] ?? '',
				'assets'       => $assets,
			);
		}
		return $compactos;
	}

	/**
	 * Enlace de descarga de [juego] con la clase CSS [clase], o '' si no
	 * hay APK publicada.
	 */
	public static function enlace( string $juego, string $clase = 'ns-descarga-apk' ): string {
		$apk = self::ultima_apk( $juego );
		if ( null === $apk ) {
			return '';
		}
		$icono = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M12 4v11M7 10l5 5 5-5M5 20h14"/></svg>';
		$datos = 'v' . $apk['version'];
		if ( $apk['tamano'] > 0 ) {
			$datos .= ' · ' . size_format( $apk['tamano'] );
		}
		return sprintf(
			'<a class="%1$s" href="%2$s" rel="noopener">%3$s<span>%4$s</span><small>%5$s</small></a>',
			esc_attr( $clase ),
			esc_url( $apk['url'] ),
			$icono,
			esc_html__( 'Descargar para Android', 'nuevo-ser-core' ),
			esc_html( $datos )
		);
	}

	/** @param array|string $atributos juego (carpeta de apps/). */
	public static function shortcode( $atributos ): string {
		$atributos = shortcode_atts( array( 'juego' => '' ), is_array( $atributos ) ? $atributos : array(), 'nuevo_ser_descarga' );
		$juego     = sanitize_key( $atributos['juego'] );
		return '' === $juego ? '' : self::enlace( $juego );
	}
}
