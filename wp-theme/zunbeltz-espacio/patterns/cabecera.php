<?php
/**
 * Title: Cabecera
 * Slug: zunbeltz-espacio/cabecera
 * Categories: zunbeltz-espacio
 * Inserter: no
 *
 * @package ZunbeltzEspacio
 */
?>
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|30","bottom":"var:preset|spacing|30"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--30);padding-bottom:var(--wp--preset--spacing--30)"><!-- wp:group {"align":"wide","layout":{"type":"flex","justifyContent":"space-between","flexWrap":"nowrap"}} -->
<div class="wp-block-group alignwide"><!-- wp:image {"width":"150px","sizeSlug":"full","linkDestination":"custom","style":{"border":{"radius":"0px"}}} -->
<figure class="wp-block-image size-full is-resized has-custom-border"><a href="<?php echo esc_url( home_url( '/' ) ); ?>"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'zunbeltz_logo.svg' ) ); ?>" alt="Zunbeltz" style="border-radius:0px;width:150px"/></a></figure>
<!-- /wp:image -->

<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button {"className":"is-style-outline","fontSize":"pequeno"} -->
<div class="wp-block-button has-custom-font-size is-style-outline has-pequeno-font-size"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( zunbeltz_espacio_url_oficina() ); ?>">Oficina · Bulegoa</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons --></div>
<!-- /wp:group --></div>
<!-- /wp:group -->
