<?php
/**
 * Title: Portada — entrada a la herramienta (castellano)
 * Slug: zunbeltz-espacio/portada-es
 * Categories: zunbeltz-espacio
 * Description: Presentación del Espacio Test, botones a la app web y a la oficina, cómo empezar y qué hay dentro. En castellano.
 *
 *
 * @package ZunbeltzEspacio
 */

$zunbeltz_url_app     = zunbeltz_espacio_url_app();
$zunbeltz_url_oficina = zunbeltz_espacio_url_oficina();
$zunbeltz_url_android = zunbeltz_espacio_url_android();
?>
<!-- wp:group {"align":"wide","style":{"border":{"radius":"28px"},"spacing":{"padding":{"top":"var:preset|spacing|50","bottom":"var:preset|spacing|50","left":"var:preset|spacing|50","right":"var:preset|spacing|50"}}},"backgroundColor":"pasto-claro","layout":{"type":"default"}} -->
<div class="wp-block-group alignwide has-pasto-claro-background-color has-background" style="border-radius:28px;padding-top:var(--wp--preset--spacing--50);padding-right:var(--wp--preset--spacing--50);padding-bottom:var(--wp--preset--spacing--50);padding-left:var(--wp--preset--spacing--50)"><!-- wp:columns {"verticalAlignment":"center","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|50"}}}} -->
<div class="wp-block-columns are-vertically-aligned-center"><!-- wp:column {"verticalAlignment":"center","width":"55%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:55%"><!-- wp:paragraph {"textColor":"pasto","fontSize":"pequeno","style":{"typography":{"fontWeight":"600"}}} -->
<p class="has-pasto-color has-text-color has-pequeno-font-size" style="font-weight:600">Espacio Test Agrario</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":1} -->
<h1 class="wp-block-heading">La herramienta del equipo de Zunbeltz</h1>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"medio"} -->
<p class="has-medio-font-size">Fincas, tareas, avisos y el seguimiento de cada proyecto de test, en el móvil y en la oficina. Funciona también sin cobertura.</p>
<!-- /wp:paragraph -->

<!-- wp:buttons {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"}}}} -->
<div class="wp-block-buttons" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_app ); ?>">Abrir la app</a></div>
<!-- /wp:button -->

<!-- wp:button {"className":"is-style-outline"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_android ); ?>">Descargar para Android</a></div>
<!-- /wp:button -->

<!-- wp:button {"className":"is-style-outline"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_oficina ); ?>">Oficina de coordinación</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons --></div>
<!-- /wp:column -->

<!-- wp:column {"verticalAlignment":"center","width":"45%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:45%"><!-- wp:image {"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'tester-ovino.jpg' ) ); ?>" alt="Rebaño de ovejas pastando en una finca del Espacio Test Zunbeltz"/></figure>
<!-- /wp:image --></div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->

<!-- wp:group {"align":"wide","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|40"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group alignwide" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--40)"><!-- wp:heading -->
<h2 class="wp-block-heading">Cómo empezar</h2>
<!-- /wp:heading -->

<!-- wp:columns {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"},"blockGap":{"left":"var:preset|spacing|40"}}}} -->
<div class="wp-block-columns" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">1</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Pide tu token</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Coordinación te da de alta y te entrega tu token personal: es tu llave y no se comparte.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">2</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Abre la app</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Desde el navegador, con el botón «Abrir la app», o en tu móvil Android con «Descargar para Android».</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">3</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Pon tu token</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>En Ajustes → Sincronización, pega tu token. A partir de ahí la app se pone al día sola.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->

<!-- wp:separator {"align":"wide","className":"is-style-wide"} -->
<hr class="wp-block-separator alignwide has-alpha-channel-opacity is-style-wide"/>
<!-- /wp:separator -->

<!-- wp:group {"align":"wide","style":{"spacing":{"padding":{"top":"var:preset|spacing|50","bottom":"var:preset|spacing|50"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group alignwide" style="padding-top:var(--wp--preset--spacing--50);padding-bottom:var(--wp--preset--spacing--50)"><!-- wp:heading -->
<h2 class="wp-block-heading">Qué hay dentro</h2>
<!-- /wp:heading -->

<!-- wp:columns {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"},"blockGap":{"left":"var:preset|spacing|30"}}}} -->
<div class="wp-block-columns" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Fincas y tareas</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">El mapa de las fincas con sus abrevaderos, cierres y corrales, y las tareas de mantenimiento de cada uno.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Avisos y alarmas</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Un animal enfermo, una rotura, que falta pienso: avísalo y le llega al equipo.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Tu proyecto de test</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Producción, ventas, pruebas de producto y gastos, con sus números al día.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">El convenio</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Balance del test y del proyecto, fianza y acompañamiento, como recoge el convenio tester.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->

<!-- wp:group {"align":"wide","style":{"border":{"radius":"28px"},"spacing":{"padding":{"top":"var:preset|spacing|50","bottom":"var:preset|spacing|50","left":"var:preset|spacing|50","right":"var:preset|spacing|50"},"margin":{"bottom":"var:preset|spacing|60"}}},"backgroundColor":"monte","textColor":"blanco","layout":{"type":"default"}} -->
<div class="wp-block-group alignwide has-blanco-color has-monte-background-color has-text-color has-background" style="border-radius:28px;margin-bottom:var(--wp--preset--spacing--60);padding-top:var(--wp--preset--spacing--50);padding-right:var(--wp--preset--spacing--50);padding-bottom:var(--wp--preset--spacing--50);padding-left:var(--wp--preset--spacing--50)"><!-- wp:columns {"verticalAlignment":"center","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|50"}}}} -->
<div class="wp-block-columns are-vertically-aligned-center"><!-- wp:column {"verticalAlignment":"center","width":"40%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:40%"><!-- wp:image {"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'proyecto-vacuno.jpg' ) ); ?>" alt="Vacas de un proyecto tester bajo los árboles"/></figure>
<!-- /wp:image --></div>
<!-- /wp:column -->

<!-- wp:column {"verticalAlignment":"center","width":"60%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:60%"><!-- wp:heading {"textColor":"blanco"} -->
<h2 class="wp-block-heading has-blanco-color has-text-color">Pensada para el monte</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Sin cobertura, la app lo guarda todo en el móvil y lo comparte con el equipo en cuanto vuelve la conexión. Cada persona ve lo suyo y lo que es de todos; la oficina lo ve todo.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->
