<?php
/**
 * Tema Zunbeltz Espacio: la entrada a la herramienta del Espacio Test.
 *
 * Bilingüe castellano/euskera con WPML: la portada es una **página** («Portada»
 * en castellano y su traducción «Atarikoa» en euskera), editable en Gutenberg
 * y enlazada en WPML; cabecera, pie y 404 cambian de idioma según la página.
 * Sin WPML, todo sale en castellano.
 *
 * Las portadas se crean solas al activar el tema si no existen
 * (`zunbeltz_espacio_crear_portadas()`, también a mano por WP-CLI:
 * `wp eval 'zunbeltz_espacio_crear_portadas();'`). Su contenido sale de los
 * patrones `portada-es` y `portada-eu` con las direcciones de este servidor.
 *
 * @package ZunbeltzEspacio
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'init', 'zunbeltz_espacio_registrar_categoria_patrones' );
add_action( 'after_switch_theme', 'zunbeltz_espacio_crear_portadas' );
add_action( 'admin_notices', 'zunbeltz_espacio_avisar_portadas_desactualizadas' );
add_action( 'admin_post_zunbeltz_espacio_rehacer_portadas', 'zunbeltz_espacio_atender_rehacer_portadas' );

function zunbeltz_espacio_registrar_categoria_patrones(): void {
	register_block_pattern_category( 'zunbeltz-espacio', array( 'label' => 'Zunbeltz' ) );
}

/** Idioma que se está mostrando: `es` o `eu`. */
function zunbeltz_espacio_idioma(): string {
	$idioma = (string) apply_filters( 'wpml_current_language', 'es' );
	return 'eu' === $idioma ? 'eu' : 'es';
}

/** El texto en el idioma que se está mostrando. */
function zunbeltz_espacio_texto( string $castellano, string $euskera ): string {
	return 'eu' === zunbeltz_espacio_idioma() ? $euskera : $castellano;
}

/**
 * Enlaces a la página actual en cada idioma activo, para el selector
 * ES · EU de la cabecera. Sin WPML, vacío.
 *
 * @return array<int, array{codigo: string, url: string, actual: bool}>
 */
function zunbeltz_espacio_idiomas(): array {
	$idiomas = apply_filters( 'wpml_active_languages', null, array( 'skip_missing' => 0, 'orderby' => 'code', 'order' => 'desc' ) );
	if ( ! is_array( $idiomas ) ) {
		return array();
	}
	$enlaces = array();
	foreach ( $idiomas as $codigo => $idioma ) {
		$enlaces[] = array(
			'codigo' => (string) $codigo,
			'url'    => (string) $idioma['url'],
			'actual' => ! empty( $idioma['active'] ),
		);
	}
	return $enlaces;
}

/**
 * Dirección de la app web (plugin solera-zunbeltz-sync). En euskera lleva
 * `?lang=eu` para que la app abra en euskera.
 */
function zunbeltz_espacio_url_app( string $idioma = '' ): string {
	$url = function_exists( 'szs_url_app_web' ) ? szs_url_app_web() : home_url( '/app/' );
	return 'eu' === $idioma ? add_query_arg( 'lang', 'eu', $url ) : $url;
}

/** Descarga de la app Android que sirve el plugin. */
function zunbeltz_espacio_url_android(): string {
	return function_exists( 'szs_url_apk' ) ? szs_url_apk() : home_url( '/app/descargar/android' );
}

/** Oficina de coordinación (panel del plugin); pide iniciar sesión. */
function zunbeltz_espacio_url_oficina(): string {
	return admin_url( 'admin.php?page=solera-zunbeltz' );
}

function zunbeltz_espacio_imagen( string $fichero ): string {
	return get_theme_file_uri( 'assets/imagenes/' . $fichero );
}

function zunbeltz_espacio_contenido_patron( string $slug ): string {
	$patron = WP_Block_Patterns_Registry::get_instance()->get_registered( $slug );
	return is_array( $patron ) ? (string) $patron['content'] : '';
}

/**
 * Crea la portada en castellano y su traducción al euskera (si no existen),
 * las enlaza en WPML y las deja como página de inicio. Devuelve los ids.
 *
 * @return array{es: int, eu: int}
 */
function zunbeltz_espacio_crear_portadas(): array {
	$existente = (int) get_option( 'page_on_front' );
	if ( $existente > 0 && 'page' === get_option( 'show_on_front' ) && get_post( $existente ) ) {
		$traduccion = (int) apply_filters( 'wpml_object_id', $existente, 'page', false, 'eu' );
		return array( 'es' => $existente, 'eu' => $traduccion );
	}
	$es = wp_insert_post(
		array(
			'post_type'    => 'page',
			'post_status'  => 'publish',
			'post_title'   => 'Portada',
			'post_name'    => 'portada',
			'post_content' => zunbeltz_espacio_contenido_patron( 'zunbeltz-espacio/portada-es' ),
		)
	);
	$eu = wp_insert_post(
		array(
			'post_type'    => 'page',
			'post_status'  => 'publish',
			'post_title'   => 'Atarikoa',
			'post_name'    => 'atarikoa',
			'post_content' => zunbeltz_espacio_contenido_patron( 'zunbeltz-espacio/portada-eu' ),
		)
	);
	if ( has_action( 'wpml_set_element_language_details' ) ) {
		$tipo_elemento = apply_filters( 'wpml_element_type', 'page' );
		do_action( 'wpml_set_element_language_details', array( 'element_id' => $es, 'element_type' => $tipo_elemento, 'trid' => false, 'language_code' => 'es' ) );
		$trid = (int) apply_filters( 'wpml_element_trid', null, $es, $tipo_elemento );
		do_action( 'wpml_set_element_language_details', array( 'element_id' => $eu, 'element_type' => $tipo_elemento, 'trid' => $trid, 'language_code' => 'eu', 'source_language_code' => 'es' ) );
	}
	update_option( 'show_on_front', 'page' );
	update_option( 'page_on_front', $es );
	return array( 'es' => (int) $es, 'eu' => (int) $eu );
}

/**
 * Frases de versiones anteriores del patrón de portada: si la página
 * todavía las tiene, no se ha puesto al día con los textos nuevos.
 */
const ZUNBELTZ_ESPACIO_FRASES_PORTADA_VIEJA = array( 'Pide tu token', 'Oficina de coordinación', 'Eskatu zure tokena', 'Koordinazio-bulegoa' );

/** Ids de la portada (es) y su traducción (eu, 0 si no hay). */
function zunbeltz_espacio_ids_portadas(): array {
	$es = (int) get_option( 'page_on_front' );
	if ( $es <= 0 || 'page' !== get_option( 'show_on_front' ) || ! get_post( $es ) ) {
		return array( 'es' => 0, 'eu' => 0 );
	}
	$eu = (int) apply_filters( 'wpml_object_id', $es, 'page', false, 'eu' );
	return array( 'es' => $es, 'eu' => $eu === $es ? 0 : $eu );
}

/** `true` si alguna portada conserva textos de un patrón anterior. */
function zunbeltz_espacio_portadas_desactualizadas(): bool {
	foreach ( zunbeltz_espacio_ids_portadas() as $id ) {
		$pagina = $id > 0 ? get_post( $id ) : null;
		if ( ! $pagina ) {
			continue;
		}
		foreach ( ZUNBELTZ_ESPACIO_FRASES_PORTADA_VIEJA as $frase ) {
			if ( str_contains( (string) $pagina->post_content, $frase ) ) {
				return true;
			}
		}
	}
	return false;
}

/**
 * Vuelve a escribir el contenido de las portadas con los patrones actuales
 * del tema (`portada-es` y `portada-eu`). Pisa lo editado a mano en ellas.
 * También por WP-CLI: `wp eval 'zunbeltz_espacio_rehacer_portadas();'`.
 *
 * @return int Páginas reescritas.
 */
function zunbeltz_espacio_rehacer_portadas(): int {
	$ids    = zunbeltz_espacio_ids_portadas();
	$hechas = 0;
	foreach ( array( 'es' => 'zunbeltz-espacio/portada-es', 'eu' => 'zunbeltz-espacio/portada-eu' ) as $idioma => $slug ) {
		$contenido = zunbeltz_espacio_contenido_patron( $slug );
		if ( $ids[ $idioma ] <= 0 || '' === $contenido ) {
			continue;
		}
		$resultado = wp_update_post( array( 'ID' => $ids[ $idioma ], 'post_content' => $contenido ), true );
		if ( ! is_wp_error( $resultado ) ) {
			$hechas++;
		}
	}
	return $hechas;
}

/** Aviso en Escritorio y Apariencia → Temas, con el botón que las rehace. */
function zunbeltz_espacio_avisar_portadas_desactualizadas(): void {
	$pantalla = get_current_screen();
	if ( ! $pantalla || ! in_array( $pantalla->id, array( 'dashboard', 'themes' ), true ) || ! current_user_can( 'manage_options' ) ) {
		return;
	}
	if ( isset( $_GET['zunbeltz_portadas'] ) ) {
		$hechas = (int) $_GET['zunbeltz_portadas'];
		echo '<div class="notice notice-success is-dismissible"><p>' . esc_html( sprintf( 'Portadas actualizadas con los textos del tema: %d.', $hechas ) ) . '</p></div>';
		return;
	}
	if ( ! zunbeltz_espacio_portadas_desactualizadas() ) {
		return;
	}
	?>
	<div class="notice notice-warning">
		<p><strong>Zunbeltz Espacio:</strong> la portada conserva textos de una versión anterior del tema (botón «Oficina de coordinación», «token»). Actualizarla la reescribe con el patrón actual y <strong>pierde lo editado a mano</strong> en ella; si la habéis retocado en Gutenberg, mejor cambiar esos textos a mano.</p>
		<form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
			<input type="hidden" name="action" value="zunbeltz_espacio_rehacer_portadas">
			<?php wp_nonce_field( 'zunbeltz_espacio_rehacer_portadas' ); ?>
			<p><button type="submit" class="button button-primary">Actualizar las portadas con los textos nuevos</button></p>
		</form>
	</div>
	<?php
}

function zunbeltz_espacio_atender_rehacer_portadas(): void {
	if ( ! current_user_can( 'manage_options' ) ) {
		wp_die( 'Sin permiso.' );
	}
	check_admin_referer( 'zunbeltz_espacio_rehacer_portadas' );
	$hechas = zunbeltz_espacio_rehacer_portadas();
	wp_safe_redirect( add_query_arg( 'zunbeltz_portadas', $hechas, admin_url( 'themes.php' ) ) );
	exit;
}
