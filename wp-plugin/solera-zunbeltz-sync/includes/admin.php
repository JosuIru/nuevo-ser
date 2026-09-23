<?php
/**
 * Admin de WordPress: menú "Solera Zunbeltz" para gestionar las personas
 * del espacio (alta, rol, token personal, activar/desactivar).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'admin_menu', 'szs_registrar_menu_admin' );

function szs_registrar_menu_admin(): void {
	add_menu_page(
		'Solera Zunbeltz — Personas',
		'Solera Zunbeltz',
		'manage_options',
		'solera-zunbeltz-sync',
		'szs_pagina_admin',
		'dashicons-groups',
		80
	);
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

		case 'desactivar':
		case 'activar':
			szs_activar_persona( $uid, 'activar' === $accion );
			return array( 'success', 'activar' === $accion ? 'Persona reactivada.' : 'Persona desactivada: su token deja de funcionar.', null, null );
	}
	return null;
}

function szs_pagina_admin(): void {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}

	$aviso    = szs_procesar_accion_admin();
	$personas = szs_listar_personas( false );
	$roles    = szs_roles();
	?>
	<div class="wrap">
		<h1>Solera Zunbeltz — Personas del espacio</h1>
		<p>Cada persona que usa la app tiene su <strong>token personal</strong> y un <strong>rol</strong>. En la app, en <strong>Ajustes → Sincronización de tareas</strong>, se configura la dirección de este WordPress y el token de esa persona.</p>

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
				<tr><th>Nombre</th><th>Rol</th><th>Estado</th><th>Acciones</th></tr>
			</thead>
			<tbody>
			<?php if ( empty( $personas ) ) : ?>
				<tr><td colspan="4">Todavía no hay personas. Crea al menos una con rol de coordinación.</td></tr>
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
			<li><strong>Coordinación (admin)</strong>: crea, edita y asigna cualquier tarea.</li>
			<li><strong>Tester</strong>: ve todas las tareas del espacio y crea tareas. Ejecuta (estado y coste) las que tiene asignadas o ha creado, edita las que ha creado, puede cogerse una tarea libre y soltar una suya. No asigna tareas a otras personas.</li>
		</ul>
		<p style="color:#7d5a00;background:#fff8e5;border-left:4px solid #dba617;padding:8px 12px;max-width:720px;">
			<strong>Provisional:</strong> este reparto de permisos es un punto de partida para el piloto y está pendiente de revisarse con el equipo de Zunbeltz.
		</p>
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
