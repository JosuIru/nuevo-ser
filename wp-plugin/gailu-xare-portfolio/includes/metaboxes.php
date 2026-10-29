<?php
/**
 * Metaboxes de los CPTs gxare_proyecto y gxare_descarga.
 *
 * Cada CPT declara sus campos como un array de definiciones; un
 * renderer genérico los pinta en wp-admin y los persiste como
 * `post_meta`. Mismo patrón que cuadernos-de-campo theme.
 *
 * @package GailuXarePortfolio
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function gxare_metaboxes_defs(): array {
	return array(
		'gxare_proyecto' => array(
			'titulo' => 'Datos del proyecto',
			'campos' => array(
				array( 'key' => 'gxare_proyecto_subtitulo', 'label' => 'Subtítulo / claim', 'tipo' => 'text', 'desc' => 'Una frase corta. Ej. "Cuaderno de campo digital para adulto aficionado".' ),
				array( 'key' => 'gxare_proyecto_audiencia','label' => 'Audiencia', 'tipo' => 'text', 'desc' => 'Ej. "Adulto aficionado", "Niños 9-12", "B2B agro".' ),
				array( 'key' => 'gxare_proyecto_estado',   'label' => 'Estado', 'tipo' => 'select',
					'opciones' => array(
						'esqueleto'   => 'Esqueleto / prototipo',
						'mvp'         => 'MVP en pruebas',
						'produccion'  => 'En producción',
						'maduro'      => 'Maduro',
						'mantenimiento' => 'En mantenimiento',
					),
					'desc' => 'Aparece como chip en la tarjeta.' ),
				array( 'key' => 'gxare_proyecto_tipo',     'label' => 'Tipo de trabajo', 'tipo' => 'select',
					'opciones' => array(
						'app'      => 'App móvil / desktop',
						'plugin'   => 'Plugin WordPress',
						'theme'    => 'Tema WordPress',
						'servicio' => 'Servicio / SaaS',
						'libreria' => 'Librería / SDK',
					),
					'desc' => 'Categoriza el proyecto.' ),
				array( 'key' => 'gxare_proyecto_tech',     'label' => 'Tech stack (separado por comas)', 'tipo' => 'text', 'desc' => 'Ej. "Flutter, sqflite, IGME WMS"' ),
				array( 'key' => 'gxare_proyecto_marca',    'label' => 'Marca / línea', 'tipo' => 'text', 'desc' => 'Ej. "Cuadernos de Campo", "Larrea", "Flavor". Se usa como etiqueta superior.' ),
				array( 'key' => 'gxare_proyecto_url_web',  'label' => 'URL · landing / web', 'tipo' => 'url' ),
				array( 'key' => 'gxare_proyecto_url_repo', 'label' => 'URL · repositorio (GitHub, etc.)', 'tipo' => 'url' ),
				array( 'key' => 'gxare_proyecto_url_demo', 'label' => 'URL · demo / prototipo', 'tipo' => 'url' ),
				array( 'key' => 'gxare_proyecto_color',    'label' => 'Color de acento (hex o variable)', 'tipo' => 'text', 'desc' => 'Ej. #5E7D3A o var(--verde-olivo). Aplica al borde de la tarjeta.' ),
				array( 'key' => 'gxare_proyecto_destacado','label' => '¿Destacado?', 'tipo' => 'select',
					'opciones' => array( '0' => 'No', '1' => 'Sí' ),
					'desc' => 'Los destacados van en grande arriba del grid.' ),
				array( 'key' => 'gxare_proyecto_landing', 'label' => 'Landing custom', 'tipo' => 'select',
					'opciones' => array(
						''                => '— Página genérica del tema —',
						'cuadernos-de-campo' => 'Cuadernos de Campo (design system completo)',
						'flavor-chat-ia'  => 'Flavor Chat IA (plugin flavor-landing)',
					),
					'desc' => 'Si pones una landing custom, single-gxare_proyecto.php delega su render a esa landing en vez de la página genérica.' ),

				// ─── Contenido rico para la ficha de detalle ───
				array( 'key' => 'gxare_proyecto_que_hace_largo', 'label' => 'Qué hace (descripción larga)', 'tipo' => 'textarea',
					'desc' => 'Párrafo de 80-120 palabras. Explica qué hace el proyecto en concreto, mecánicas/funcionalidades clave, ventajas. Tono divulgativo para cliente / colaborador.' ),
				array( 'key' => 'gxare_proyecto_para_quien', 'label' => 'Para quién', 'tipo' => 'textarea',
					'desc' => 'Audiencia detallada: perfil, edad, problema que soluciona, contexto profesional o doméstico.' ),
				array( 'key' => 'gxare_proyecto_virtudes', 'label' => 'Virtudes (una por línea)', 'tipo' => 'textarea',
					'desc' => 'Lista de 4-6 virtudes, cada una en su línea. Aparecen como bullets en la ficha.' ),
				array( 'key' => 'gxare_proyecto_pedagogia', 'label' => 'Pedagogía (solo Kids)', 'tipo' => 'textarea',
					'desc' => 'Explicación pedagógica de por qué enseña lo que enseña y cómo. Dejar vacío si el proyecto no es un juego Kids.' ),
				array( 'key' => 'gxare_proyecto_estado_largo', 'label' => 'Estado detallado', 'tipo' => 'textarea',
					'desc' => '2-3 frases sobre la fase, lo que está cerrado, lo pendiente.' ),
				array( 'key' => 'gxare_proyecto_faq', 'label' => 'Preguntas frecuentes (formato Q :: A, una por línea)', 'tipo' => 'textarea',
					'desc' => 'Cada FAQ en una línea como "¿Pregunta? :: Respuesta". Aparecen como acordeón en la ficha.' ),
			),
		),
		'gxare_descarga' => array(
			'titulo' => 'Datos de la descarga',
			'campos' => array(
				array( 'key' => 'gxare_descarga_proyecto_slug', 'label' => 'Slug del proyecto asociado', 'tipo' => 'text', 'desc' => 'Ej. "cuadernos-de-campo-fosiles". Tiene que coincidir con el slug (`post_name`) de un proyecto existente.' ),
				array( 'key' => 'gxare_descarga_version',       'label' => 'Versión', 'tipo' => 'text', 'desc' => 'Ej. "1.0.14+15", "v0.16.6"' ),
				array( 'key' => 'gxare_descarga_fecha',         'label' => 'Fecha (YYYY-MM-DD)', 'tipo' => 'text' ),
				array( 'key' => 'gxare_descarga_plataforma',    'label' => 'Plataforma', 'tipo' => 'select',
					'opciones' => array(
						'android'   => 'Android (APK)',
						'wp'        => 'WordPress (plugin / theme zip)',
						'linux'     => 'Linux',
						'web'       => 'Web (ZIP estático)',
						'ios'       => 'iOS',
						'otros'     => 'Otros',
					) ),
				array( 'key' => 'gxare_descarga_url',           'label' => 'URL del binario', 'tipo' => 'url' ),
				array( 'key' => 'gxare_descarga_peso',          'label' => 'Peso legible', 'tipo' => 'text', 'desc' => 'Ej. "38 MB", "1.2 MB"' ),
				array( 'key' => 'gxare_descarga_sha256',        'label' => 'SHA-256 (verificación)', 'tipo' => 'text', 'desc' => 'Opcional. Si lo rellenas, aparece como código mono junto al botón.' ),
				array( 'key' => 'gxare_descarga_notas',         'label' => 'Notas de release (1-2 frases)', 'tipo' => 'textarea', 'desc' => 'Resumen corto del cambio principal.' ),
			),
		),
	);
}

function gxare_metaboxes_registrar(): void {
	foreach ( gxare_metaboxes_defs() as $cpt => $config ) {
		add_meta_box(
			$cpt . '_meta',
			$config['titulo'],
			'gxare_render_metabox',
			$cpt,
			'normal',
			'high',
			$config
		);
	}
}

function gxare_render_metabox( WP_Post $post, array $metabox ): void {
	$config = $metabox['args'];
	wp_nonce_field( 'gxare_guardar_meta', 'gxare_meta_nonce' );
	echo '<table class="form-table" role="presentation"><tbody>';
	foreach ( $config['campos'] as $campo ) {
		$valor = get_post_meta( $post->ID, $campo['key'], true );
		printf(
			'<tr><th scope="row"><label for="%s">%s</label></th><td>',
			esc_attr( $campo['key'] ),
			esc_html( $campo['label'] )
		);
		switch ( $campo['tipo'] ) {
			case 'textarea':
				printf(
					'<textarea name="%s" id="%s" rows="3" class="large-text">%s</textarea>',
					esc_attr( $campo['key'] ),
					esc_attr( $campo['key'] ),
					esc_textarea( (string) $valor )
				);
				break;
			case 'select':
				printf( '<select name="%s" id="%s">', esc_attr( $campo['key'] ), esc_attr( $campo['key'] ) );
				foreach ( ( $campo['opciones'] ?? array() ) as $v => $etiqueta ) {
					printf(
						'<option value="%s"%s>%s</option>',
						esc_attr( (string) $v ),
						selected( (string) $valor, (string) $v, false ),
						esc_html( (string) $etiqueta )
					);
				}
				echo '</select>';
				break;
			case 'url':
				printf(
					'<input type="url" name="%s" id="%s" value="%s" class="regular-text">',
					esc_attr( $campo['key'] ),
					esc_attr( $campo['key'] ),
					esc_attr( (string) $valor )
				);
				break;
			default:
				printf(
					'<input type="text" name="%s" id="%s" value="%s" class="regular-text">',
					esc_attr( $campo['key'] ),
					esc_attr( $campo['key'] ),
					esc_attr( (string) $valor )
				);
				break;
		}
		if ( ! empty( $campo['desc'] ) ) {
			printf( '<p class="description">%s</p>', esc_html( $campo['desc'] ) );
		}
		echo '</td></tr>';
	}
	echo '</tbody></table>';
}

function gxare_metaboxes_guardar( int $post_id, WP_Post $post ): void {
	if ( ! isset( $_POST['gxare_meta_nonce'] ) || ! wp_verify_nonce( (string) $_POST['gxare_meta_nonce'], 'gxare_guardar_meta' ) ) {
		return;
	}
	if ( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) {
		return;
	}
	if ( ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$defs = gxare_metaboxes_defs();
	if ( ! isset( $defs[ $post->post_type ] ) ) {
		return;
	}
	foreach ( $defs[ $post->post_type ]['campos'] as $campo ) {
		$key = $campo['key'];
		if ( ! isset( $_POST[ $key ] ) ) {
			continue;
		}
		$valor = wp_unslash( $_POST[ $key ] );
		if ( 'textarea' === $campo['tipo'] ) {
			$valor = sanitize_textarea_field( (string) $valor );
		} elseif ( 'url' === $campo['tipo'] ) {
			$valor = esc_url_raw( (string) $valor );
		} else {
			$valor = sanitize_text_field( (string) $valor );
		}
		update_post_meta( $post_id, $key, $valor );
	}
}
