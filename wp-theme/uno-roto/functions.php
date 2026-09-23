<?php
/**
 * Tema Uno Roto: casi todo vive en theme.json y en las plantillas. Aquí
 * sólo se carga style.css (los temas de bloques no lo cargan solos).
 *
 * @package UnoRoto
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action(
	'wp_enqueue_scripts',
	static function () {
		wp_enqueue_style( 'uno-roto', get_stylesheet_uri(), array(), wp_get_theme()->get( 'Version' ) );
	}
);
