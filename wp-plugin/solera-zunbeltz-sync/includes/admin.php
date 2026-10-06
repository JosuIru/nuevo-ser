<?php
/**
 * Panel · Personas: alta, rol, token personal, activar/desactivar y enlace
 * con un usuario de WordPress y un correo. El menú está en
 * `panel/comun.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Procesa la acción enviada (si la hay) y devuelve el aviso a mostrar:
 * `[tipo, mensaje, token_en_claro|null, nombre_persona|null]`.
 */
function szs_procesar_accion_admin(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_gestionar_personas' );

	$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	$uid    = sanitize_text_field( wp_unslash( $_POST['szs_uid'] ?? '' ) );

	switch ( $accion ) {
		case 'crear':
			$nombre = sanitize_text_field( wp_unslash( $_POST['szs_nombre'] ?? '' ) );
			$rol    = sanitize_key( wp_unslash( $_POST['szs_rol'] ?? '' ) );
			$token  = szs_crear_persona( $nombre, $rol );
			if ( null === $token ) {
				return array( 'error', 'Falta el nombre o el rol no es válido.', null, null );
			}
			return array( 'success', 'Persona creada.', $token, $nombre );

		case 'regenerar':
			$token = szs_regenerar_token_persona( $uid );
			return array( 'success', 'Token regenerado. El anterior ya no funciona.', $token, szs_nombre_persona( $uid ) );

		case 'cambiar_rol':
			szs_cambiar_rol_persona( $uid, sanitize_key( wp_unslash( $_POST['szs_rol'] ?? '' ) ) );
			return array( 'success', 'Rol actualizado. La app lo recoge en la próxima sincronización.', null, null );

		case 'enlazar':
			szs_enlazar_persona_usuario( $uid, (int) ( $_POST['szs_wp_user_id'] ?? 0 ), sanitize_email( wp_unslash( $_POST['szs_correo'] ?? '' ) ) );
			return array( 'success', 'Enlace guardado.', null, null );

		case 'desactivar':
		case 'activar':
			szs_activar_persona( $uid, 'activar' === $accion );
			return array( 'success', 'activar' === $accion ? 'Persona reactivada.' : 'Persona desactivada: su token deja de funcionar.', null, null );
	}
	return null;
}

function szs_pagina_admin(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}

	$aviso    = szs_procesar_accion_admin();
	$usuarios = array();
	foreach ( get_users( array( 'fields' => array( 'ID', 'display_name', 'user_login' ) ) ) as $usuario ) {
		$usuarios[ (int) $usuario->ID ] = $usuario->display_name . ' (' . $usuario->user_login . ')';
	}
	$personas = szs_listar_personas( false );
	$roles    = szs_roles();
	?>
	<div class="wrap">
		<h1>Solera Zunbeltz — Personas del espacio</h1>
		<p>Cada persona que usa la app tiene su <strong>token personal</strong> y un <strong>rol</strong>. En la app, en <strong>Ajustes → Sincronización</strong>, se configura la dirección de este WordPress y el token de esa persona.</p>
		<p>Una persona de coordinación enlazada con su <strong>usuario de WordPress</strong> puede entrar a este panel aunque no sea administradora del WordPress, y lo que haga aquí queda a su nombre. Su <strong>correo</strong> recibe el resumen diario y las alarmas.</p>

		<?php if ( null !== $aviso ) : ?>
			<div class="notice notice-<?php echo esc_attr( $aviso[0] ); ?>">
				<p><?php echo esc_html( $aviso[1] ); ?></p>
				<?php if ( null !== $aviso[2] ) : ?>
					<p>Token de <strong><?php echo esc_html( (string) $aviso[3] ); ?></strong> — cópialo ahora, <strong>no se vuelve a mostrar</strong>:</p>
					<p><code style="user-select:all;font-size:14px;"><?php echo esc_html( $aviso[2] ); ?></code></p>
				<?php endif; ?>
			</div>
		<?php endif; ?>

		<table class="form-table" role="presentation">
			<tr>
				<th scope="row">Dirección para la app</th>
				<td><code style="user-select:all;"><?php echo esc_html( home_url() ); ?></code></td>
			</tr>
		</table>

		<h2>Personas</h2>
		<table class="widefat striped" style="max-width:960px;">
			<thead>
				<tr><th>Nombre</th><th>Rol</th><th>Usuario de WordPress y correo</th><th>Estado</th><th>Acciones</th></tr>
			</thead>
			<tbody>
			<?php if ( empty( $personas ) ) : ?>
				<tr><td colspan="5">Todavía no hay personas. Crea al menos una con rol de coordinación.</td></tr>
			<?php endif; ?>
			<?php foreach ( $personas as $persona ) : ?>
				<?php $activa = '1' === (string) $persona['activo']; ?>
				<tr>
					<td><?php echo esc_html( $persona['nombre'] ); ?></td>
					<td>
						<form method="post" style="display:flex;gap:6px;">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="cambiar_rol">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<?php szs_selector_rol( $roles, (string) $persona['rol'] ); ?>
							<button type="submit" class="button button-small">Guardar</button>
						</form>
					</td>
					<td>
						<form method="post" style="display:flex;gap:6px;flex-wrap:wrap;">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="enlazar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<?php szs_selector( 'szs_wp_user_id', $usuarios, (string) $persona['wp_user_id'], 'Sin usuario' ); ?>
							<input type="email" name="szs_correo" placeholder="correo@ejemplo.org" value="<?php echo esc_attr( (string) $persona['correo'] ); ?>">
							<button type="submit" class="button button-small">Guardar</button>
						</form>
					</td>
					<td><?php echo $activa ? 'Activa' : '<em>Desactivada</em>'; ?></td>
					<td style="display:flex;gap:6px;">
						<form method="post">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="regenerar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<button type="submit" class="button button-small" onclick="return confirm('¿Generar un token nuevo? El actual dejará de funcionar en su dispositivo.');">Nuevo token</button>
						</form>
						<form method="post">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="<?php echo $activa ? 'desactivar' : 'activar'; ?>">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<button type="submit" class="button button-small"><?php echo $activa ? 'Desactivar' : 'Reactivar'; ?></button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2>Añadir persona</h2>
		<form method="post">
			<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
			<input type="hidden" name="szs_accion" value="crear">
			<table class="form-table" role="presentation">
				<tr>
					<th scope="row"><label for="szs_nombre">Nombre</label></th>
					<td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" required></td>
				</tr>
				<tr>
					<th scope="row"><label for="szs_rol">Rol</label></th>
					<td><?php szs_selector_rol( $roles, SZS_ROL_TESTER ); ?></td>
				</tr>
			</table>
			<?php submit_button( 'Crear persona y generar token' ); ?>
		</form>

		<h2>Qué puede hacer cada rol</h2>
		<ul style="list-style:disc;padding-left:20px;max-width:720px;">
			<li><strong>Coordinación (admin)</strong>: crea, edita, asigna y borra tareas; gestiona fincas, zonas y puntos, todos los proyectos (presupuesto, fianza, acompañamiento, incidencias, cierre), las peticiones y los avisos; ve la actividad del espacio.</li>
			<li><strong>Tester</strong>: ve sus tareas y las generales (sin responsable), cambia su estado, se coge una general y suelta una suya. No crea tareas: las pide. Añade y mueve puntos (corrales móviles, bidones), da avisos y apunta el seguimiento de su proyecto mientras esté abierto. No ve los proyectos ni las peticiones de otras personas.</li>
		</ul>
		<p class="description" style="max-width:720px;">Reparto acordado con Zunbeltz el 6 de octubre de 2026.</p>
	</div>
	<?php
}

function szs_selector_rol( array $roles, string $seleccionado ): void {
	echo '<select name="szs_rol">';
	foreach ( $roles as $codigo => $rol ) {
		printf(
			'<option value="%s"%s>%s</option>',
			esc_attr( $codigo ),
			selected( $codigo, $seleccionado, false ),
			esc_html( $rol['etiqueta'] )
		);
	}
	echo '</select>';
}
