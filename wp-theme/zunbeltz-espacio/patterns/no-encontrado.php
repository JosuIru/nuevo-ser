<?php
/**
 * Title: No encontrado
 * Slug: zunbeltz-espacio/no-encontrado
 * Categories: zunbeltz-espacio
 * Inserter: no
 *
 * @package ZunbeltzEspacio
 */
?>
<!-- wp:group {"tagName":"main","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|60"}}},"layout":{"type":"constrained"}} -->
<main class="wp-block-group" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--60)"><!-- wp:heading {"level":1} -->
<h1 class="wp-block-heading"><?php echo esc_html( zunbeltz_espacio_texto( 'No encontrado', 'Ez da aurkitu' ) ); ?></h1>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><a href="<?php echo esc_url( apply_filters( 'wpml_home_url', home_url( '/' ) ) ); ?>"><?php echo esc_html( zunbeltz_espacio_texto( 'Volver a la entrada', 'Sarrerara itzuli' ) ); ?></a></p>
<!-- /wp:paragraph --></main>
<!-- /wp:group -->
