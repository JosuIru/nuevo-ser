<?php
/**
 * Actualización del plugin desde las releases de GitHub del monorepo, con
 * plugin-update-checker (`lib/plugin-update-checker`, MIT): WordPress
 * avisa en Plugins de que hay versión nueva y se actualiza con un clic,
 * sin subir el zip a mano.
 *
 * El repo es un monorepo con releases de varias apps, así que solo cuentan
 * las de tag `plugin-solera-zunbeltz-sync-<versión>` con un zip
 * `solera-zunbeltz-sync-<versión>.zip` adjunto (`dev/publicar_release.sh`).
 * El tag no empieza por `solera-zunbeltz-` a propósito: ese prefijo es el
 * que busca la app Android para actualizarse.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_REPO_ACTUALIZACIONES = 'https://github.com/JosuIru/nuevo-ser';
const SZS_PREFIJO_TAG_PLUGIN   = 'plugin-solera-zunbeltz-sync-';

/**
 * Versión de una release a partir de su tag, o null si el tag no es de
 * este plugin.
 */
function szs_version_desde_tag( string $tag ): ?string {
	$tag = ltrim( trim( $tag ), 'v' );
	if ( ! str_starts_with( $tag, SZS_PREFIJO_TAG_PLUGIN ) ) {
		return null;
	}
	$version = substr( $tag, strlen( SZS_PREFIJO_TAG_PLUGIN ) );
	return 1 === preg_match( '/^\d+(\.\d+)*$/', $version ) ? $version : null;
}

add_action( 'plugins_loaded', 'szs_activar_actualizaciones' );

function szs_activar_actualizaciones(): void {
	$cargador = dirname( __DIR__ ) . '/lib/plugin-update-checker/plugin-update-checker.php';
	if ( ! is_readable( $cargador ) ) {
		return;
	}
	require_once $cargador;

	$comprobador = \YahnisElsts\PluginUpdateChecker\v5\PucFactory::buildUpdateChecker(
		SZS_REPO_ACTUALIZACIONES,
		dirname( __DIR__ ) . '/solera-zunbeltz-sync.php',
		'solera-zunbeltz-sync'
	);
	$api = $comprobador->getVcsApi();
	// Entre las últimas releases del monorepo, la primera que sea del plugin.
	$api->setReleaseFilter(
		static fn( $version_tag ) => null !== szs_version_desde_tag( (string) $version_tag ),
		\YahnisElsts\PluginUpdateChecker\v5p4\Vcs\Api::RELEASE_FILTER_SKIP_PRERELEASE,
		50
	);
	$api->enableReleaseAssets( '/^solera-zunbeltz-sync-[\d.]+\.zip$/i' );
	// En desarrollo la carpeta es un enlace al repo: actualizar la vaciaría.
	if ( is_link( WP_PLUGIN_DIR . '/solera-zunbeltz-sync' ) ) {
		add_filter( 'upgrader_pre_download', 'szs_bloquear_actualizacion_enlazada', 10, 4 );
	}
	// PUC toma el tag entero como versión; WordPress tiene que ver «0.8.1».
	$comprobador->addResultFilter(
		static function ( $info ) {
			if ( is_object( $info ) && isset( $info->version ) ) {
				$version = szs_version_desde_tag( (string) $info->version );
				if ( null !== $version ) {
					$info->version = $version;
				}
			}
			return $info;
		}
	);
}

/**
 * @param mixed $respuesta  false, o lo que haya decidido otro filtro.
 * @param array $extra      Incluye `plugin` al actualizar un plugin.
 * @return mixed
 */
function szs_bloquear_actualizacion_enlazada( $respuesta, $paquete, $actualizador, $extra = array() ) {
	if ( 'solera-zunbeltz-sync/solera-zunbeltz-sync.php' !== ( $extra['plugin'] ?? '' ) ) {
		return $respuesta;
	}
	return new WP_Error( 'szs_plugin_enlazado', 'Este plugin es un enlace simbólico (desarrollo): actualizarlo desde aquí borraría la carpeta enlazada.' );
}
