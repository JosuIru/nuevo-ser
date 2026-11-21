<?php
/**
 * Actualizaciones del propio plugin desde GitHub Releases del monorepo,
 * como cualquier otro plugin (Escritorio → Actualizaciones, «Actualizar
 * ahora» en Plugins y actualizaciones automáticas si se activan).
 *
 * El release lo publica `scripts/wp/publicar_plugin.sh`:
 *   tag     nuevo-ser-core-<versión>         p. ej. nuevo-ser-core-0.21.0
 *   assets  nuevo-ser-core-<versión>.zip     con la carpeta nuevo-ser-core/ dentro
 *           nuevo-ser-core-<versión>.zip.sha256
 *
 * Se engancha con la cabecera `Update URI` (WordPress 5.8+): WordPress pide
 * la información al filtro `update_plugins_github.com` en vez de a
 * wordpress.org. Antes de instalar se comprueba el sha256 del zip: si no
 * coincide, la actualización se cancela y el plugin que había sigue igual.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Actualizaciones {

	const PREFIJO_TAG = 'nuevo-ser-core-';
	const SLUG        = 'nuevo-ser-core';

	public static function registrar(): void {
		add_filter( 'update_plugins_github.com', array( __CLASS__, 'comprobar' ), 10, 3 );
		add_filter( 'plugins_api', array( __CLASS__, 'informacion' ), 10, 3 );
		add_filter( 'upgrader_pre_download', array( __CLASS__, 'descargar_comprobando' ), 10, 3 );
	}

	// =================================================================
	// Lógica pura (cubierta por tests/test_actualizaciones.php)
	// =================================================================

	/**
	 * El release más reciente del plugin entre los releases (el más nuevo
	 * primero, como los devuelve la API de GitHub). Sólo con zip y sha256.
	 *
	 * @return array|null version, url, url_sha256, fecha, notas; o null.
	 */
	public static function elegir_release( array $releases ): ?array {
		$mejor = null;
		foreach ( $releases as $release ) {
			if ( ! is_array( $release ) || ! empty( $release['draft'] ) || ! empty( $release['prerelease'] ) ) {
				continue;
			}
			$tag = (string) ( $release['tag_name'] ?? '' );
			if ( 0 !== strpos( $tag, self::PREFIJO_TAG ) ) {
				continue;
			}
			$version = substr( $tag, strlen( self::PREFIJO_TAG ) );
			if ( ! preg_match( '/^\d+\.\d+\.\d+$/', $version ) ) {
				continue;
			}
			$zip    = null;
			$sha256 = null;
			foreach ( (array) ( $release['assets'] ?? array() ) as $asset ) {
				$nombre = (string) ( $asset['name'] ?? '' );
				$url    = (string) ( $asset['browser_download_url'] ?? '' );
				if ( '' === $url ) {
					continue;
				}
				if ( self::PREFIJO_TAG . $version . '.zip' === $nombre ) {
					$zip = $url;
				} elseif ( self::PREFIJO_TAG . $version . '.zip.sha256' === $nombre ) {
					$sha256 = $url;
				}
			}
			if ( null === $zip || null === $sha256 ) {
				continue;
			}
			// No se fía del orden de GitHub: se queda con la versión más alta.
			if ( null === $mejor || version_compare( $version, $mejor['version'], '>' ) ) {
				$mejor = array(
					'version'    => $version,
					'url'        => $zip,
					'url_sha256' => $sha256,
					'fecha'      => (string) ( $release['published_at'] ?? '' ),
					'notas'      => (string) ( $release['body'] ?? '' ),
				);
			}
		}
		return $mejor;
	}

	/** Si [remota] es más nueva que [instalada]. */
	public static function hay_version_nueva( string $instalada, string $remota ): bool {
		return '' !== $remota && version_compare( $remota, $instalada, '>' );
	}

	/** Si [url] es un zip de un release del plugin (para no tocar otras descargas). */
	public static function es_paquete_del_plugin( string $url ): bool {
		return (bool) preg_match( '#^https://github\.com/' . preg_quote( NS_Descargas_Apk::REPOSITORIO, '#' ) . '/releases/download/' . preg_quote( self::PREFIJO_TAG, '#' ) . '\d+\.\d+\.\d+/' . preg_quote( self::PREFIJO_TAG, '#' ) . '\d+\.\d+\.\d+\.zip$#', $url );
	}

	// =================================================================
	// Enganches con WordPress
	// =================================================================

	/** El release más reciente (con la copia de una hora de los releases). */
	private static function ultimo(): ?array {
		return self::elegir_release( NS_Descargas_Apk::releases() );
	}

	/**
	 * Responde a WordPress si hay versión nueva (filtro
	 * `update_plugins_github.com`, uno por plugin con ese Update URI).
	 *
	 * @param array|false $actualizacion Lo que haya respondido otro filtro.
	 * @param array       $datos         Cabeceras del plugin.
	 * @param string      $archivo       Ruta relativa del plugin.
	 * @return array|false
	 */
	public static function comprobar( $actualizacion, $datos, $archivo ) {
		if ( plugin_basename( NS_CORE_DIR . 'nuevo-ser-core.php' ) !== $archivo ) {
			return $actualizacion;
		}
		$ultimo = self::ultimo();
		if ( null === $ultimo ) {
			return $actualizacion;
		}
		return array(
			'id'           => 'github.com/' . NS_Descargas_Apk::REPOSITORIO . '/' . self::SLUG,
			'slug'         => self::SLUG,
			'version'      => $ultimo['version'],
			'url'          => 'https://github.com/' . NS_Descargas_Apk::REPOSITORIO . '/releases/tag/' . self::PREFIJO_TAG . $ultimo['version'],
			'package'      => $ultimo['url'],
			'requires_php' => '8.1',
		);
	}

	/**
	 * Ventana «Ver detalles» de la actualización (filtro `plugins_api`).
	 *
	 * @param false|object|array $resultado
	 * @param string             $accion
	 * @param object             $argumentos
	 * @return false|object|array
	 */
	public static function informacion( $resultado, $accion, $argumentos ) {
		if ( 'plugin_information' !== $accion || ! isset( $argumentos->slug ) || self::SLUG !== $argumentos->slug ) {
			return $resultado;
		}
		$ultimo = self::ultimo();
		if ( null === $ultimo ) {
			return $resultado;
		}
		$notas = '' !== trim( $ultimo['notas'] ) ? $ultimo['notas'] : 'Nueva versión de Nuevo Ser Core.';
		return (object) array(
			'name'          => 'Nuevo Ser Core',
			'slug'          => self::SLUG,
			'version'       => $ultimo['version'],
			'author'        => 'Equipo Colección Nuevo Ser',
			'homepage'      => 'https://coleccion-nuevo-ser.gailu.net/',
			'requires'      => '6.4',
			'requires_php'  => '8.1',
			'last_updated'  => $ultimo['fecha'],
			'download_link' => $ultimo['url'],
			'sections'      => array(
				'changelog' => wpautop( esc_html( $notas ) ),
			),
		);
	}

	/**
	 * Descarga el zip del plugin comprobando su sha256 antes de que
	 * WordPress lo instale (filtro `upgrader_pre_download`). Devolver la
	 * ruta del zip hace que WordPress no lo descargue otra vez.
	 *
	 * @param bool|string|WP_Error $respuesta
	 * @param string               $paquete URL del paquete.
	 * @return bool|string|WP_Error
	 */
	public static function descargar_comprobando( $respuesta, $paquete, $actualizador = null ) {
		if ( false !== $respuesta || ! is_string( $paquete ) || ! self::es_paquete_del_plugin( $paquete ) ) {
			return $respuesta;
		}
		$respuesta_sha = wp_remote_get( $paquete . '.sha256', array( 'timeout' => 15 ) );
		$esperado      = is_wp_error( $respuesta_sha ) ? null : NS_Instalador_Juegos_Web::leer_sha256( wp_remote_retrieve_body( $respuesta_sha ) );
		if ( null === $esperado ) {
			return new WP_Error( 'ns_sin_sha256', 'No se pudo leer el sha256 de la actualización de Nuevo Ser Core. No se ha cambiado nada.' );
		}
		require_once ABSPATH . 'wp-admin/includes/file.php';
		$zip = download_url( $paquete, 300 );
		if ( is_wp_error( $zip ) ) {
			return $zip;
		}
		if ( ! hash_equals( $esperado, (string) hash_file( 'sha256', $zip ) ) ) {
			wp_delete_file( $zip );
			return new WP_Error( 'ns_sha256', 'La actualización de Nuevo Ser Core no coincide con su sha256 (descarga incompleta o alterada). No se ha cambiado nada.' );
		}
		return $zip;
	}
}
