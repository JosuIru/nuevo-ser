<?php
/**
 * Panel · Personas: alta, rol, clave de usuario (token personal),
 * activar/desactivar y enlace con un usuario de WordPress y un correo. El
 * menú está en `panel/comun.php`.
 *
 * Enlazar con un usuario de WordPress (y con ello dar o quitar el acceso al
 * panel) es solo para quien tiene `manage_options`
 * (`szs_puede_dar_acceso_panel`); se comprueba en el servidor, no solo en
 * el formulario.
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
				return array( 'error', szs_t( 'Falta el nombre o el rol no es válido.' ), null, null );
			}
			return array( 'success', szs_t( 'Persona creada.' ), $token, $nombre );

		case 'regenerar':
			$token = szs_regenerar_token_persona( $uid );
			return array( 'success', szs_t( 'Clave de usuario regenerada. La anterior ya no funciona.' ), $token, szs_nombre_persona( $uid ) );

		case 'cambiar_rol':
			$acceso_al_dia = szs_cambiar_rol_persona( $uid, sanitize_key( wp_unslash( $_POST['szs_rol'] ?? '' ) ) );
			return szs_aviso_con_acceso_pendiente( szs_t( 'Rol actualizado. La app lo recoge en la próxima sincronización.' ), $acceso_al_dia );

		case 'enlazar':
			$enlace_permitido = szs_enlazar_persona_usuario( $uid, (int) ( $_POST['szs_wp_user_id'] ?? 0 ), sanitize_email( wp_unslash( $_POST['szs_correo'] ?? '' ) ) );
			if ( ! $enlace_permitido ) {
				return array( 'warning', szs_t( 'Correo guardado. El usuario de WordPress no ha cambiado: solo una persona administradora del WordPress puede enlazarlo y dar o quitar el acceso al panel.' ), null, null );
			}
			return array( 'success', szs_t( 'Enlace guardado.' ), null, null );

		case 'desactivar':
		case 'activar':
			$acceso_al_dia = szs_activar_persona( $uid, 'activar' === $accion );
			return szs_aviso_con_acceso_pendiente( 'activar' === $accion ? szs_t( 'Persona reactivada.' ) : szs_t( 'Persona desactivada: su clave de usuario deja de funcionar.' ), $acceso_al_dia );
	}
	return null;
}

/**
 * Aviso de éxito; si el acceso al panel que corresponde no se pudo dar
 * (quien actúa no administra el WordPress), lo dice.
 */
function szs_aviso_con_acceso_pendiente( string $mensaje, bool $acceso_al_dia ): array {
	if ( $acceso_al_dia ) {
		return array( 'success', $mensaje, null, null );
	}
	return array( 'warning', $mensaje . ' ' . szs_t( 'Su usuario de WordPress aún no tiene acceso al panel: tiene que dárselo una persona administradora del WordPress (volviendo a guardar el enlace).' ), null, null );
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
	$personas         = szs_listar_personas( false );
	$roles            = szs_roles();
	$puede_dar_acceso = szs_puede_dar_acceso_panel();
	?>
	<div class="wrap">
		<h1><?php echo esc_html( szs_t( 'Larrea Zunbeltz — Personas del espacio' ) ); ?></h1>
		<p><?php echo szs_t( 'Cada persona que usa la app tiene su <strong>clave de usuario</strong> personal y un <strong>rol</strong>. En la app, en <strong>Ajustes → Sincronización</strong>, se configura la dirección de este WordPress y la clave de usuario de esa persona.' ); // phpcs:ignore WordPress.Security.EscapeOutput ?></p>
		<p><?php echo szs_t( 'Una persona de coordinación enlazada con su <strong>usuario de WordPress</strong> puede entrar a este panel aunque no sea administradora del WordPress, y lo que haga aquí queda a su nombre. Su <strong>correo</strong> recibe el resumen diario y las alarmas.' ); // phpcs:ignore WordPress.Security.EscapeOutput ?></p>
		<?php if ( ! $puede_dar_acceso ) : ?>
			<p class="description"><?php echo esc_html( szs_t( 'Solo una persona administradora del WordPress puede enlazar a alguien con un usuario de WordPress, cambiar ese enlace o dar y quitar el acceso al panel. Tú puedes dar de alta personas, cambiar su rol y su correo, generar su clave de usuario y desactivarlas.' ) ); ?></p>
		<?php endif; ?>

		<?php if ( null !== $aviso ) : ?>
			<div class="notice notice-<?php echo esc_attr( $aviso[0] ); ?>">
				<p><?php echo esc_html( $aviso[1] ); ?></p>
				<?php if ( null !== $aviso[2] ) : ?>
					<p><?php echo szs_t( 'Clave de usuario de <strong>%s</strong> — cópiala ahora, <strong>no se vuelve a mostrar</strong>:', esc_html( (string) $aviso[3] ) ); // phpcs:ignore WordPress.Security.EscapeOutput ?></p>
					<p><code style="user-select:all;font-size:14px;"><?php echo esc_html( $aviso[2] ); ?></code></p>
				<?php endif; ?>
			</div>
		<?php endif; ?>

		<table class="form-table" role="presentation">
			<tr>
				<th scope="row"><?php echo esc_html( szs_t( 'Dirección para la app' ) ); ?></th>
				<td><code style="user-select:all;"><?php echo esc_html( home_url() ); ?></code></td>
			</tr>
		</table>

		<h2><?php echo esc_html( szs_t( 'Personas' ) ); ?></h2>
		<table class="widefat striped" style="max-width:960px;">
			<thead>
				<tr><th><?php echo esc_html( szs_t( 'Nombre' ) ); ?></th><th><?php echo esc_html( szs_t( 'Rol' ) ); ?></th><th><?php echo esc_html( szs_t( 'Usuario de WordPress y correo' ) ); ?></th><th><?php echo esc_html( szs_t( 'Estado' ) ); ?></th><th><?php echo esc_html( szs_t( 'Acciones' ) ); ?></th></tr>
			</thead>
			<tbody>
			<?php if ( empty( $personas ) ) : ?>
				<tr><td colspan="5"><?php echo esc_html( szs_t( 'Todavía no hay personas. Crea al menos una con rol de coordinación.' ) ); ?></td></tr>
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
							<button type="submit" class="button button-small"><?php echo esc_html( szs_t( 'Guardar' ) ); ?></button>
						</form>
					</td>
					<td>
						<form method="post" style="display:flex;gap:6px;flex-wrap:wrap;">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="enlazar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<?php if ( $puede_dar_acceso ) : ?>
								<?php szs_selector( 'szs_wp_user_id', $usuarios, (string) $persona['wp_user_id'], szs_t( 'Sin usuario' ) ); ?>
							<?php else : ?>
								<?php // Deshabilitado no se envía: el valor actual va oculto y el servidor no deja cambiarlo. ?>
								<input type="hidden" name="szs_wp_user_id" value="<?php echo esc_attr( (string) (int) $persona['wp_user_id'] ); ?>">
								<select disabled title="<?php echo esc_attr( szs_t( 'Solo una persona administradora del WordPress puede cambiarlo.' ) ); ?>">
									<option><?php echo esc_html( $usuarios[ (int) $persona['wp_user_id'] ] ?? szs_t( 'Sin usuario' ) ); ?></option>
								</select>
							<?php endif; ?>
							<input type="email" name="szs_correo" placeholder="<?php echo esc_attr( szs_t( 'correo@ejemplo.org' ) ); ?>" value="<?php echo esc_attr( (string) $persona['correo'] ); ?>">
							<button type="submit" class="button button-small"><?php echo esc_html( szs_t( 'Guardar' ) ); ?></button>
							<?php if ( ! $puede_dar_acceso ) : ?>
								<span class="description" style="flex-basis:100%;"><?php echo esc_html( szs_t( 'El usuario de WordPress (y con él el acceso al panel) solo lo cambia una persona administradora del WordPress.' ) ); ?></span>
							<?php endif; ?>
						</form>
					</td>
					<td><?php echo $activa ? esc_html( szs_t( 'Activa' ) ) : '<em>' . esc_html( szs_t( 'Desactivada' ) ) . '</em>'; ?></td>
					<td style="display:flex;gap:6px;">
						<form method="post">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="regenerar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<button type="submit" class="button button-small" onclick="return confirm('<?php echo esc_js( szs_t( '¿Generar una clave de usuario nueva? La actual dejará de funcionar en su dispositivo.' ) ); ?>');"><?php echo esc_html( szs_t( 'Nueva clave de usuario' ) ); ?></button>
						</form>
						<form method="post">
							<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
							<input type="hidden" name="szs_accion" value="<?php echo $activa ? 'desactivar' : 'activar'; ?>">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $persona['uid'] ); ?>">
							<button type="submit" class="button button-small"><?php echo esc_html( $activa ? szs_t( 'Desactivar' ) : szs_t( 'Reactivar' ) ); ?></button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2><?php echo esc_html( szs_t( 'Añadir persona' ) ); ?></h2>
		<form method="post">
			<?php wp_nonce_field( 'szs_gestionar_personas' ); ?>
			<input type="hidden" name="szs_accion" value="crear">
			<table class="form-table" role="presentation">
				<tr>
					<th scope="row"><label for="szs_nombre"><?php echo esc_html( szs_t( 'Nombre' ) ); ?></label></th>
					<td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" required></td>
				</tr>
				<tr>
					<th scope="row"><label for="szs_rol"><?php echo esc_html( szs_t( 'Rol' ) ); ?></label></th>
					<td><?php szs_selector_rol( $roles, SZS_ROL_TESTER ); ?></td>
				</tr>
			</table>
			<?php submit_button( szs_t( 'Crear persona y generar su clave de usuario' ) ); ?>
		</form>

		<h2><?php echo esc_html( szs_t( 'Qué puede hacer cada rol' ) ); ?></h2>
		<ul style="list-style:disc;padding-left:20px;max-width:720px;">
			<li><?php echo szs_t( '<strong>Coordinación (admin)</strong>: crea, edita, asigna y borra tareas; gestiona fincas, zonas y puntos, todos los proyectos (presupuesto, fianza, acompañamiento, incidencias, cierre), las peticiones y los avisos; ve la actividad del espacio.' ); // phpcs:ignore WordPress.Security.EscapeOutput ?></li>
			<li><?php echo szs_t( '<strong>Tester</strong>: ve sus tareas y las generales (sin responsable), cambia su estado, se coge una general y suelta una suya. No crea tareas: las pide. Añade y mueve puntos (corrales móviles, bidones), da avisos y apunta el seguimiento de su proyecto mientras esté abierto. No ve los proyectos ni las peticiones de otras personas.' ); // phpcs:ignore WordPress.Security.EscapeOutput ?></li>
		</ul>
		<p class="description" style="max-width:720px;"><?php echo esc_html( szs_t( 'Reparto acordado con Zunbeltz el 6 de octubre de 2026.' ) ); ?></p>
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
			esc_html( szs_t( $rol['etiqueta'] ) )
		);
	}
	echo '</select>';
}
