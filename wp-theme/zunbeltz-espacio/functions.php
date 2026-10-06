<?php
/**
 * Tema Zunbeltz Espacio: la entrada a la herramienta del Espacio Test.
 *
 * La portada (`patterns/portada.php`) enlaza con la app web que sirve el
 * plugin solera-zunbeltz-sync en `/app/` y con la oficina de coordinación
 * (`/wp-admin/admin.php?page=solera-zunbeltz`). Los patrones son PHP para
 * que esas direcciones salgan bien aunque WordPress esté en una subcarpeta.
 *
 * @package ZunbeltzEspacio
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'init', 'zunbeltz_espacio_registrar_categoria_patrones' );

function zunbeltz_espacio_registrar_categoria_patrones(): void {
	register_block_pattern_category( 'zunbeltz-espacio', array( 'label' => 'Zunbeltz' ) );
}

/** Dirección de la app web (plugin solera-zunbeltz-sync). */
function zunbeltz_espacio_url_app(): string {
	return function_exists( 'szs_url_app_web' ) ? szs_url_app_web() : home_url( '/app/' );
}

/** Oficina de coordinación (panel del plugin); pide iniciar sesión. */
function zunbeltz_espacio_url_oficina(): string {
	return admin_url( 'admin.php?page=solera-zunbeltz' );
}

/**
 * Descarga de la app Android que sirve el plugin, o null si todavía no se
 * ha publicado ninguna (la portada no muestra el botón).
 */
function zunbeltz_espacio_url_android(): ?string {
	if ( ! function_exists( 'szs_apk_publicado' ) || null === szs_apk_publicado() ) {
		return null;
	}
	return szs_url_apk();
}

function zunbeltz_espacio_imagen( string $fichero ): string {
	return get_theme_file_uri( 'assets/imagenes/' . $fichero );
}
