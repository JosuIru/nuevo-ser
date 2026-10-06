<?php
/**
 * Title: Atarikoa — tresnarako sarrera
 * Slug: zunbeltz-espacio/portada-eu
 * Categories: zunbeltz-espacio
 * Description: Test Gunearen aurkezpena euskaraz: web aplikaziorako eta bulegorako botoiak, nola hasi eta zer dagoen barruan.
 *
 * Euskera: borrador pendiente de revisión nativa (como el de la app).
 *
 * @package ZunbeltzEspacio
 */

$zunbeltz_url_app     = zunbeltz_espacio_url_app( 'eu' );
$zunbeltz_url_oficina = zunbeltz_espacio_url_oficina();
$zunbeltz_url_android = zunbeltz_espacio_url_android();
?>
<!-- wp:group {"align":"wide","style":{"border":{"radius":"28px"},"spacing":{"padding":{"top":"var:preset|spacing|50","bottom":"var:preset|spacing|50","left":"var:preset|spacing|50","right":"var:preset|spacing|50"}}},"backgroundColor":"pasto-claro","layout":{"type":"default"}} -->
<div class="wp-block-group alignwide has-pasto-claro-background-color has-background" style="border-radius:28px;padding-top:var(--wp--preset--spacing--50);padding-right:var(--wp--preset--spacing--50);padding-bottom:var(--wp--preset--spacing--50);padding-left:var(--wp--preset--spacing--50)"><!-- wp:columns {"verticalAlignment":"center","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|50"}}}} -->
<div class="wp-block-columns are-vertically-aligned-center"><!-- wp:column {"verticalAlignment":"center","width":"55%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:55%"><!-- wp:paragraph {"textColor":"pasto","fontSize":"pequeno","style":{"typography":{"fontWeight":"600"}}} -->
<p class="has-pasto-color has-text-color has-pequeno-font-size" style="font-weight:600">Nekazaritzako Test Gunea</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":1} -->
<h1 class="wp-block-heading">Zunbeltzeko taldearen tresna</h1>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"medio"} -->
<p class="has-medio-font-size">Finkak, zereginak, abisuak eta test-proiektu bakoitzaren jarraipena, mugikorrean eta bulegoan. Estaldurarik gabe ere badabil.</p>
<!-- /wp:paragraph -->

<!-- wp:buttons {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"}}}} -->
<div class="wp-block-buttons" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_app ); ?>">Aplikazioa ireki</a></div>
<!-- /wp:button -->

<!-- wp:button {"className":"is-style-outline"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_android ); ?>">Androiderako deskargatu</a></div>
<!-- /wp:button -->

<!-- wp:button {"className":"is-style-outline"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $zunbeltz_url_oficina ); ?>">Koordinazio-bulegoa</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons --></div>
<!-- /wp:column -->

<!-- wp:column {"verticalAlignment":"center","width":"45%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:45%"><!-- wp:image {"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'tester-ovino.jpg' ) ); ?>" alt="Ardi-taldea larrean, Zunbeltz Test Guneko finka batean"/></figure>
<!-- /wp:image --></div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->

<!-- wp:group {"align":"wide","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|40"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group alignwide" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--40)"><!-- wp:heading -->
<h2 class="wp-block-heading">Nola hasi</h2>
<!-- /wp:heading -->

<!-- wp:columns {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"},"blockGap":{"left":"var:preset|spacing|40"}}}} -->
<div class="wp-block-columns" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">1</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Eskatu zure tokena</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Koordinazioak alta ematen dizu eta zure token pertsonala ematen dizu: zure giltza da eta ez da partekatzen.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">2</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Ireki aplikazioa</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Nabigatzailetik, «Aplikazioa ireki» botoiarekin, edo zure Android mugikorrean «Androiderako deskargatu» botoiarekin.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph {"textColor":"pasto","fontSize":"grande","style":{"typography":{"fontWeight":"700"}},"fontFamily":"titulos"} -->
<p class="has-pasto-color has-text-color has-titulos-font-family has-grande-font-size" style="font-weight:700">3</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Jarri zure tokena</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Ezarpenak → Sinkronizazioa atalean, itsatsi zure tokena. Hortik aurrera aplikazioa bera eguneratzen da.</p>
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
<h2 class="wp-block-heading">Zer dago barruan</h2>
<!-- /wp:heading -->

<!-- wp:columns {"style":{"spacing":{"margin":{"top":"var:preset|spacing|40"},"blockGap":{"left":"var:preset|spacing|30"}}}} -->
<div class="wp-block-columns" style="margin-top:var(--wp--preset--spacing--40)"><!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Finkak eta zereginak</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Finken mapa, askak, hesiak eta kortak barne, eta bakoitzaren mantentze-zereginak.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Abisuak eta alarmak</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Animalia gaixo bat, matxura bat, pentsua falta dela: abisatu eta taldeari iristen zaio.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Zure test-proiektua</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Ekoizpena, salmentak, produktu-probak eta gastuak, zenbakiak egunean.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column -->

<!-- wp:column {"style":{"border":{"radius":"18px"},"spacing":{"padding":{"top":"var:preset|spacing|40","bottom":"var:preset|spacing|40","left":"var:preset|spacing|40","right":"var:preset|spacing|40"}}},"backgroundColor":"blanco"} -->
<div class="wp-block-column has-blanco-background-color has-background" style="border-radius:18px;padding-top:var(--wp--preset--spacing--40);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--40);padding-left:var(--wp--preset--spacing--40)"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Hitzarmena</h3>
<!-- /wp:heading -->

<!-- wp:paragraph {"fontSize":"pequeno"} -->
<p class="has-pequeno-font-size">Testaren eta proiektuaren balantzea, fidantza eta laguntza, tester-hitzarmenak jasotzen duen bezala.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->

<!-- wp:group {"align":"wide","style":{"border":{"radius":"28px"},"spacing":{"padding":{"top":"var:preset|spacing|50","bottom":"var:preset|spacing|50","left":"var:preset|spacing|50","right":"var:preset|spacing|50"},"margin":{"bottom":"var:preset|spacing|60"}}},"backgroundColor":"monte","textColor":"blanco","layout":{"type":"default"}} -->
<div class="wp-block-group alignwide has-blanco-color has-monte-background-color has-text-color has-background" style="border-radius:28px;margin-bottom:var(--wp--preset--spacing--60);padding-top:var(--wp--preset--spacing--50);padding-right:var(--wp--preset--spacing--50);padding-bottom:var(--wp--preset--spacing--50);padding-left:var(--wp--preset--spacing--50)"><!-- wp:columns {"verticalAlignment":"center","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|50"}}}} -->
<div class="wp-block-columns are-vertically-aligned-center"><!-- wp:column {"verticalAlignment":"center","width":"40%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:40%"><!-- wp:image {"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="<?php echo esc_url( zunbeltz_espacio_imagen( 'proyecto-vacuno.jpg' ) ); ?>" alt="Tester-proiektu bateko behiak zuhaitzen azpian"/></figure>
<!-- /wp:image --></div>
<!-- /wp:column -->

<!-- wp:column {"verticalAlignment":"center","width":"60%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:60%"><!-- wp:heading {"textColor":"blanco"} -->
<h2 class="wp-block-heading has-blanco-color has-text-color">Mendirako pentsatua</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Estaldurarik gabe, aplikazioak dena mugikorrean gordetzen du eta konexioa itzultzean taldearekin partekatzen du. Bakoitzak berea eta guztiena ikusten du; bulegoak dena.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:group -->
