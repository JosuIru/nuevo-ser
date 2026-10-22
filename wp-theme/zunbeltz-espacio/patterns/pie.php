<?php
/**
 * Title: Pie
 * Slug: zunbeltz-espacio/pie
 * Categories: zunbeltz-espacio
 * Inserter: no
 *
 * @package ZunbeltzEspacio
 */
?>
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40"}}},"backgroundColor":"pasto-claro","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-pasto-claro-background-color has-background" style="padding-top:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40)"><?php if ( WP_Block_Type_Registry::get_instance()->is_registered( 'solera-zunbeltz/entidades' ) ) : ?><!-- wp:group {"align":"wide","style":{"spacing":{"margin":{"bottom":"var:preset|spacing|40"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group alignwide" style="margin-bottom:var(--wp--preset--spacing--40)"><!-- wp:solera-zunbeltz/entidades /--></div>
<!-- /wp:group -->

<!-- wp:separator {"align":"wide","backgroundColor":"monte","className":"is-style-wide"} -->
<hr class="wp-block-separator alignwide has-text-color has-monte-color has-alpha-channel-opacity has-monte-background-color has-background is-style-wide" style="opacity:.15"/>
<!-- /wp:separator -->

<?php endif; ?><!-- wp:group {"align":"wide","layout":{"type":"flex","justifyContent":"space-between","flexWrap":"wrap"}} -->
<div class="wp-block-group alignwide"><!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size"><strong>Zunbeltz Landa Garapenerako Elkartea</strong> · Arizala (<?php echo esc_html( zunbeltz_espacio_texto( 'Valle de Yerri', 'Deierri' ) ); ?>) · <a href="https://zunbeltz.com/">zunbeltz.com</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size"><?php echo esc_html( zunbeltz_espacio_texto( 'Larrea Zunbeltz', 'Larrea Zunbeltz' ) ); ?> · <?php if ( function_exists( 'szs_hay_presentacion' ) && szs_hay_presentacion() ) : ?><a href="<?php echo esc_url( szs_url_presentacion() ); ?>"><?php echo esc_html( zunbeltz_espacio_texto( 'Sobre el proyecto', 'Proiektuari buruz' ) ); ?></a> · <?php endif; ?><a href="<?php echo esc_url( admin_url() ); ?>"><?php echo esc_html( zunbeltz_espacio_texto( 'Acceder', 'Sartu' ) ); ?></a></p>
<!-- /wp:paragraph --></div>
<!-- /wp:group --></div>
<!-- /wp:group -->
