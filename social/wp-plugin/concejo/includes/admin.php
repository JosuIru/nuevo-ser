<?php
/**
 * Ajustes → Concejo: lo mínimo para arrancar un pueblo desde el WordPress
 * (nombre del espacio, personas, rol de mesa con fin de mandato, códigos y
 * correo para el resumen semanal).
 * Todo lo demás se hace desde la app.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'admin_menu', 'concejo_menu_admin' );
add_action( 'admin_post_concejo_guardar', 'concejo_procesar_formulario' );

function concejo_menu_admin(): void {
	add_options_page( 'Concejo', 'Concejo', 'manage_options', 'concejo', 'concejo_pagina_admin' );
}

function concejo_url_pagina(): string {
	return add_query_arg( array( 'page' => 'concejo' ), admin_url( 'options-general.php' ) );
}

/** Lo cambiado desde aquí también lo tiene que bajar la app. */
function concejo_subir_revision(): void {
	update_option( CONCEJO_OPCION_REVISION, concejo_revision() + 1, false );
}

function concejo_procesar_formulario(): void {
	if ( ! current_user_can( 'manage_options' ) ) {
		wp_die( 'Sin permiso.', 403 );
	}
	check_admin_referer( 'concejo_guardar' );
	$que      = sanitize_key( (string) ( $_POST['que'] ?? '' ) );
	$uid      = sanitize_text_field( wp_unslash( (string) ( $_POST['uid'] ?? '' ) ) );
	$rol      = sanitize_key( (string) ( $_POST['rol'] ?? 'vecina' ) );
	$rol      = in_array( $rol, array( 'vecina', 'mesa', 'coordinacion' ), true ) ? $rol : 'vecina';
	$mandato  = sanitize_text_field( wp_unslash( (string) ( $_POST['mandato_hasta'] ?? '' ) ) );
	$mandato  = 1 === preg_match( '/^\d{4}-\d{2}-\d{2}$/', $mandato ) ? $mandato . 'T00:00:00.000' : '';
	$redirigir = array();

	switch ( $que ) {
		case 'espacio':
			update_option( CONCEJO_OPCION_NOMBRE_ESPACIO, sanitize_text_field( wp_unslash( (string) ( $_POST['nombre_espacio'] ?? '' ) ) ) );
			concejo_subir_revision();
			break;
		case 'anadir':
			$nombre = sanitize_text_field( wp_unslash( (string) ( $_POST['nombre'] ?? '' ) ) );
			if ( '' !== $nombre ) {
				$uid = 'pe-' . bin2hex( random_bytes( 6 ) );
				concejo_guardar_persona(
					array(
						'uid'           => $uid,
						'nombre'        => $nombre,
						'rol'           => $rol,
						'mandato_hasta' => $mandato,
					)
				);
				// Quien se añade desde aquí sale ya con su código.
				$redirigir = array(
					'codigo'  => concejo_nuevo_codigo( $uid ),
					'persona' => $nombre,
				);
				concejo_subir_revision();
			}
			break;
		case 'rol':
			global $wpdb;
			$wpdb->update(
				concejo_tabla( 'personas' ),
				array(
					'rol'           => $rol,
					'mandato_hasta' => $mandato,
				),
				array( 'uid' => $uid )
			);
			concejo_subir_revision();
			break;
		case 'codigo':
			$redirigir = array(
				'codigo'  => concejo_nuevo_codigo( $uid ),
				'persona' => sanitize_text_field( wp_unslash( (string) ( $_POST['nombre'] ?? '' ) ) ),
			);
			break;
		case 'correo':
			global $wpdb;
			$correo = sanitize_email( wp_unslash( (string) ( $_POST['correo'] ?? '' ) ) );
			$wpdb->update(
				concejo_tabla( 'personas' ),
				array(
					'correo'  => is_email( $correo ) ? $correo : '',
					'resumen' => 'nunca' === ( $_POST['resumen'] ?? '' ) ? 'nunca' : 'semanal',
				),
				array( 'uid' => $uid )
			);
			break;
		case 'enviar_resumen':
			set_transient( 'concejo_enviados_' . get_current_user_id(), concejo_enviar_resumenes(), MINUTE_IN_SECONDS );
			break;
		case 'baja':
		case 'alta':
			global $wpdb;
			$wpdb->update( concejo_tabla( 'personas' ), array( 'activa' => 'alta' === $que ? 1 : 0 ), array( 'uid' => $uid ) );
			break;
	}
	// El código se enseña una sola vez: va en un dato temporal de un
	// minuto (no en la URL, que queda en el historial y en los registros).
	if ( array() !== $redirigir ) {
		set_transient( 'concejo_codigo_' . get_current_user_id(), $redirigir, MINUTE_IN_SECONDS );
	}
	wp_safe_redirect( concejo_url_pagina() );
	exit;
}

function concejo_campo_oculto( string $que, string $uid = '', string $nombre = '' ): void {
	wp_nonce_field( 'concejo_guardar' );
	echo '<input type="hidden" name="action" value="concejo_guardar">';
	echo '<input type="hidden" name="que" value="' . esc_attr( $que ) . '">';
	if ( '' !== $uid ) {
		echo '<input type="hidden" name="uid" value="' . esc_attr( $uid ) . '">';
	}
	if ( '' !== $nombre ) {
		echo '<input type="hidden" name="nombre" value="' . esc_attr( $nombre ) . '">';
	}
}

function concejo_selector_rol( string $actual ): void {
	echo '<select name="rol">';
	foreach ( array( 'vecina' => 'Participante', 'mesa' => 'Mesa', 'coordinacion' => 'Coordinación' ) as $valor => $etiqueta ) {
		echo '<option value="' . esc_attr( $valor ) . '"' . selected( $actual, $valor, false ) . '>' . esc_html( $etiqueta ) . '</option>';
	}
	echo '</select>';
}

function concejo_pagina_admin(): void {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}
	$accion  = esc_url( admin_url( 'admin-post.php' ) );
	$recien  = get_transient( 'concejo_codigo_' . get_current_user_id() );
	delete_transient( 'concejo_codigo_' . get_current_user_id() );
	$enviados = get_transient( 'concejo_enviados_' . get_current_user_id() );
	delete_transient( 'concejo_enviados_' . get_current_user_id() );
	$codigo  = is_array( $recien ) ? (string) $recien['codigo'] : '';
	$persona = is_array( $recien ) ? (string) $recien['persona'] : '';
	echo '<div class="wrap"><h1>Concejo</h1>';
	if ( '' !== $codigo ) {
		echo '<div class="notice notice-success"><p>Código de <strong>' . esc_html( $persona ) . '</strong>: '
			. '<code style="font-size:1.4em">' . esc_html( $codigo ) . '</code><br>'
			. 'Apúntalo y dáselo en papel: no se vuelve a enseñar. Si se pierde, se genera otro.</p></div>';
	}
	if ( false !== $enviados ) {
		echo '<div class="notice notice-success"><p>Resumen enviado a ' . (int) $enviados . ' personas.</p></div>';
	}
	echo '<p>La app se conecta a <code>' . esc_html( rest_url( 'concejo/v1/' ) ) . '</code> con el código personal de cada persona.</p>';

	echo '<h2>Espacio</h2><form method="post" action="' . $accion . '">';
	concejo_campo_oculto( 'espacio' );
	echo '<input type="text" name="nombre_espacio" class="regular-text" value="' . esc_attr( concejo_nombre_espacio() ) . '"> ';
	submit_button( 'Guardar', 'secondary', 'submit', false );
	echo '</form>';

	echo '<h2>Personas</h2><table class="widefat striped"><thead><tr><th>Nombre</th><th>Rol y fin de mandato</th><th>Código</th><th>Resumen semanal por correo</th><th></th></tr></thead><tbody>';
	foreach ( concejo_filas_personas() as $fila ) {
		$fecha = substr( (string) $fila['mandato_hasta'], 0, 10 );
		echo '<tr' . ( '1' === (string) $fila['activa'] ? '' : ' style="opacity:.5"' ) . '><td>' . esc_html( $fila['nombre'] ) . '</td><td>';
		echo '<form method="post" action="' . $accion . '">';
		concejo_campo_oculto( 'rol', $fila['uid'] );
		concejo_selector_rol( $fila['rol'] );
		echo ' <input type="date" name="mandato_hasta" value="' . esc_attr( $fecha ) . '"> ';
		submit_button( 'Cambiar', 'small', 'submit', false );
		echo '</form></td><td>' . ( '1' === (string) $fila['tiene_codigo'] ? 'Tiene' : '—' ) . '</td><td>';
		echo '<form method="post" action="' . $accion . '">';
		concejo_campo_oculto( 'correo', $fila['uid'] );
		echo '<input type="email" name="correo" placeholder="Sin correo" value="' . esc_attr( (string) $fila['correo'] ) . '"> ';
		echo '<select name="resumen"><option value="semanal"' . selected( $fila['resumen'], 'semanal', false ) . '>Semanal</option>'
			. '<option value="nunca"' . selected( $fila['resumen'], 'nunca', false ) . '>Nunca</option></select> ';
		submit_button( 'Guardar', 'small', 'submit', false );
		echo '</form></td><td>';
		echo '<form method="post" action="' . $accion . '" style="display:inline">';
		concejo_campo_oculto( 'codigo', $fila['uid'], $fila['nombre'] );
		submit_button( 'Código nuevo', 'small', 'submit', false );
		echo '</form> <form method="post" action="' . $accion . '" style="display:inline">';
		concejo_campo_oculto( '1' === (string) $fila['activa'] ? 'baja' : 'alta', $fila['uid'] );
		submit_button( '1' === (string) $fila['activa'] ? 'Dar de baja' : 'Volver a dar de alta', 'small', 'submit', false );
		echo '</form></td></tr>';
	}
	echo '</tbody></table>';

	echo '<h2>Añadir persona</h2><form method="post" action="' . $accion . '">';
	concejo_campo_oculto( 'anadir' );
	echo '<input type="text" name="nombre" placeholder="Nombre" required> ';
	concejo_selector_rol( 'vecina' );
	echo ' <label>Mesa hasta <input type="date" name="mandato_hasta"></label> ';
	submit_button( 'Añadir y sacar su código', 'primary', 'submit', false );
	echo '</form>';

	concejo_seccion_resumen( $accion );
	echo '</div>';
}

/** Quién lo recibe, cómo queda y un botón para mandarlo ya. */
function concejo_seccion_resumen( string $accion ): void {
	$destinatarios = concejo_destinatarios_resumen();
	echo '<h2>Resumen semanal</h2>';
	echo '<p>Sale los lunes a quien tiene correo y lo quiere (ahora, ' . count( $destinatarios ) . ' personas). '
		. 'Cada correo lleva un enlace para darse de baja. Si una semana no hay nada que contar, no se manda.</p>';
	$ejemplo = $destinatarios[0] ?? ( concejo_filas_personas()[0] ?? null );
	if ( null === $ejemplo ) {
		return;
	}
	$correo = concejo_resumen_semanal( concejo_cargar_estado(), $ejemplo['uid'], concejo_nombre_espacio(), concejo_ahora(), concejo_zona(), '(enlace para darse de baja)' );
	echo '<p>Así le llegaría hoy a <strong>' . esc_html( $ejemplo['nombre'] ) . '</strong>:</p>';
	echo '<pre style="background:#fff;border:1px solid #ccd0d4;padding:12px;white-space:pre-wrap;max-width:44em">'
		. esc_html( null === $correo ? '(Nada que contar esta semana: no se le mandaría.)' : 'Asunto: ' . $correo['asunto'] . "\n\n" . $correo['texto'] )
		. '</pre>';
	echo '<form method="post" action="' . $accion . '">';
	concejo_campo_oculto( 'enviar_resumen' );
	submit_button( 'Enviarlo ahora', 'secondary', 'submit', false );
	echo '</form>';
}
