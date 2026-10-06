<?php
/**
 * Title: Cabecera
 * Slug: zunbeltz-espacio/cabecera
 * Categories: zunbeltz-espacio
 * Inserter: no
 *
 * Logo, selector de idioma (con WPML) y acceso a la oficina, en el idioma
 * de la página.
 *
 * @package ZunbeltzEspacio
 */

$zunbeltz_idiomas = zunbeltz_espacio_idiomas();
$zunbeltz_enlaces = array();
foreach ( $zunbeltz_idiomas as $zunbeltz_idioma ) {
	$zunbeltz_etiqueta  = strtoupper( $zunbeltz_idioma['codigo'] );
	$zunbeltz_enlaces[] = $zunbeltz_idioma['actual']
		? '<strong>' . esc_html( $zunbeltz_etiqueta ) . '</strong>'
		: '<a href="' . esc_url( $zunbeltz_idioma['url'] ) . '" hreflang="' . esc_attr( $zunbeltz_idioma['codigo'] ) . '">' . esc_html( $zunbeltz_etiqueta ) . '</a>';
}
?>
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|30","bottom":"var:preset|spacing|30"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--30);padding-bottom:var(--wp--preset--spacing--30)"><!-- wp:group {"align":"wide","layout":{"type":"flex","justifyContent":"space-between","flexWrap":"nowrap"}} -->
<div class="wp-block-group alignwide"><!-- wp:image {"width":"150px","sizeSlug":"full","linkDestination":"custom","style":{"border":{"radius":"0px"}}} -->
<figure class="wp-block-image size-full is-resized has-custom-border"><a href="<?php echo esc_url( apply_filters( 'wpml_home_url', home_url( '/' ) ) ); ?>"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'zunbeltz_logo.svg' ) ); ?>" alt="Zunbeltz" style="border-radius:0px;width:150px"/></a></figure>
<!-- /wp:image -->

<!-- wp:group {"layout":{"type":"flex","flexWrap":"nowrap"}} -->
<div class="wp-block-group"><?php if ( count( $zunbeltz_enlaces ) > 1 ) : ?><!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size"><?php echo wp_kses( implode( ' · ', $zunbeltz_enlaces ), array( 'a' => array( 'href' => true, 'hreflang' => true ), 'strong' => array() ) ); ?></p>
<!-- /wp:paragraph -->

<?php endif; ?><!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button {"className":"is-style-outline","fontSize":"pequeno"} -->
<div class="wp-block-button has-custom-font-size is-style-outline has-pequeno-font-size"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( zunbeltz_espacio_url_oficina() ); ?>"><?php echo esc_html( zunbeltz_espacio_texto( 'Oficina', 'Bulegoa' ) ); ?></a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons --></div>
<!-- /wp:group --></div>
<!-- /wp:group --></div>
<!-- /wp:group -->
