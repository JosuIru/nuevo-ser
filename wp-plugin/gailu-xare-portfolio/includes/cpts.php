<?php
/**
 * CPTs del plugin Gailu Xare Portfolio.
 *
 * - gxare_proyecto: un trabajo del operador (app, plugin, theme, servicio).
 * - gxare_descarga: un release descargable (APK, plugin zip, theme zip).
 *
 * @package GailuXarePortfolio
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function gxare_cpts_registrar(): void {

	// Taxonomía "colección" — agrupa los proyectos en líneas
	// editoriales (Cuadernos de Campo, Nuevo Ser Kids, Larrea, Flavor).
	register_taxonomy(
		'gxare_coleccion',
		array( 'gxare_proyecto' ),
		array(
			'public'             => true,
			'show_ui'            => true,
			'show_in_menu'       => true,
			'show_in_rest'       => false,
			'show_admin_column'  => true,
			'show_in_nav_menus'  => false,
			'hierarchical'       => true,
			'publicly_queryable' => false,
			'rewrite'            => false,
			'labels' => array(
				'name'          => 'Colecciones',
				'singular_name' => 'Colección',
				'add_new_item'  => 'Añadir colección',
				'edit_item'     => 'Editar colección',
				'menu_name'     => 'Colecciones',
			),
		)
	);

	$base = array(
		'public'              => false,
		'show_ui'             => true,
		'show_in_menu'        => true,
		'show_in_rest'        => false,
		'hierarchical'        => false,
		'exclude_from_search' => true,
		'publicly_queryable'  => false,
		'has_archive'         => false,
		'supports'            => array( 'title', 'editor', 'page-attributes', 'thumbnail', 'excerpt' ),
		'capability_type'     => 'page',
	);

	// Proyectos sí queremos servirlos como páginas públicas para que
	// cada tarjeta del home enlace a su URL (/p/<slug>/) con su
	// propia landing renderizada por single-gxare_proyecto.php. Las
	// descargas siguen siendo internas — solo el shortcode las
	// expone.
	register_post_type(
		'gxare_proyecto',
		array_merge(
			$base,
			array(
				'public'              => true,
				'publicly_queryable'  => true,
				'exclude_from_search' => false,
				'has_archive'         => false,
				'rewrite'             => array( 'slug' => 'p', 'with_front' => false ),
				'labels' => array(
					'name'          => 'Proyectos',
					'singular_name' => 'Proyecto',
					'add_new_item'  => 'Añadir proyecto',
					'edit_item'     => 'Editar proyecto',
					'menu_name'     => 'Gailu · Proyectos',
				),
				'menu_icon' => 'dashicons-portfolio',
				'menu_position' => 24,
			)
		)
	);

	register_post_type(
		'gxare_descarga',
		array_merge(
			$base,
			array(
				'labels' => array(
					'name'          => 'Descargas',
					'singular_name' => 'Descarga',
					'add_new_item'  => 'Añadir descarga',
					'edit_item'     => 'Editar descarga',
					'menu_name'     => 'Gailu · Descargas',
				),
				'menu_icon' => 'dashicons-download',
				'menu_position' => 25,
			)
		)
	);
}
