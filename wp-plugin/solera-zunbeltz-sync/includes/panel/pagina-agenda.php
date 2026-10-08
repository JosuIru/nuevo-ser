<?php
/**
 * Panel · Contactos y Rendimientos de referencia, y descarga de la
 * alimentación por días de cada proyecto (Excel).
 *
 * - Contactos: la agenda compartida del espacio (mataderos, veterinaria,
 *   personas expertas…). Lo que se cambia aquí llega a los móviles al
 *   sincronizar, y lo que se añade en la app aparece aquí.
 * - Rendimientos de referencia: los porcentajes que la calculadora de
 *   transformación de la app ofrece como punto de partida. Solo los pone
 *   coordinación: la app no trae ninguno de serie.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PAGINA_CONTACTOS     = 'solera-zunbeltz-contactos';
const SZS_PAGINA_RENDIMIENTOS  = 'solera-zunbeltz-rendimientos';
const SZS_TIPOS_CONTACTO       = array(
	'matadero'       => 'Matadero',
	'veterinaria'    => 'Veterinaria',
	'experto'        => 'Persona experta',
	'comprador'      => 'Comprador / tienda',
	'proveedor'      => 'Proveedor',
	'administracion' => 'Administración',
	'otro'           => 'Otro',
);

add_action( 'admin_menu', 'szs_registrar_paginas_agenda', 15 );
add_action( 'admin_init', 'szs_exportar_alimentacion_csv' );

function szs_registrar_paginas_agenda(): void {
	add_submenu_page( SZS_PAGINA_TAREAS, 'Contactos', 'Contactos', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_CONTACTOS, 'szs_pagina_contactos' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Rendimientos de referencia', 'Rendimientos', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_RENDIMIENTOS, 'szs_pagina_rendimientos' );
}

/** Lápida de una entidad desde el panel (llega como borrado a los móviles). */
function szs_borrar_entidad_desde_panel( string $tipo, string $uid ): bool {
	// Sin candado no se escribe: es la carrera que el candado evita.
	if ( ! szs_tomar_candado_espacio() ) {
		wp_die( 'El espacio está ocupado sincronizando con los móviles. Vuelve atrás e inténtalo de nuevo en unos segundos.', 'Solera Zunbeltz', array( 'back_link' => true ) );
	}
	try {
		return szs_borrar_entidad_desde_panel_con_candado( $tipo, $uid );
	} finally {
		szs_soltar_candado_espacio();
	}
}

function szs_borrar_entidad_desde_panel_con_candado( string $tipo, string $uid ): bool {
	$existente = szs_obtener_entidad( $tipo, $uid );
	if ( null === $existente || $existente['borrado'] ) {
		return false;
	}
	$persona  = szs_persona_del_panel();
	$lapida   = array_merge(
		$existente,
		array(
			'borrado'        => true,
			'actualizado_ms' => max( szs_ahora_ms(), $existente['actualizado_ms'] + 1 ),
		)
	);
	$guardada = szs_guardar_entidad( $lapida, $existente, $existente['autor_uid'] );
	szs_registrar_actividad( $persona, 'borrar', $tipo, $uid, szs_etiqueta_entidad( $existente ), szs_contexto_entidad( $existente ), '', 'panel' );
	do_action( 'szs_entidad_guardada', $guardada, $existente, $persona );
	return true;
}

// ─── Contactos ───

function szs_pagina_contactos(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = null;
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_contactos' );
		$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
		$uid    = szs_campo_post( 'szs_uid' );
		if ( 'borrar' === $accion && szs_borrar_entidad_desde_panel( 'contacto', $uid ) ) {
			$aviso = array( 'success', 'Contacto borrado.' );
		}
		if ( 'guardar' === $accion ) {
			$nombre = szs_campo_post( 'szs_nombre' );
			if ( '' === $nombre ) {
				$aviso = array( 'error', 'Falta el nombre.' );
			} else {
				$tipo = sanitize_key( szs_campo_post( 'szs_tipo', 'otro' ) );
				szs_guardar_entidad_desde_panel(
					'contacto',
					'' === $uid ? szs_nuevo_uid() : $uid,
					array(
						'nombre'    => $nombre,
						'tipo'      => isset( SZS_TIPOS_CONTACTO[ $tipo ] ) ? $tipo : 'otro',
						'telefono'  => szs_campo_post( 'szs_telefono' ),
						'correo'    => sanitize_email( szs_campo_post( 'szs_correo' ) ),
						'localidad' => szs_campo_post( 'szs_localidad' ),
						'notas'     => szs_texto_largo_post( 'szs_notas' ),
					)
				);
				$aviso = array( 'success', 'Contacto guardado. Llegará a los móviles al sincronizar.' );
			}
		}
	}

	$filtro    = sanitize_key( szs_campo_get( 'tipo' ) );
	$contactos = array_values(
		array_filter(
			szs_listar_entidades_tipo( 'contacto' ),
			static fn( array $contacto ): bool => '' === $filtro || ( $contacto['datos']['tipo'] ?? '' ) === $filtro
		)
	);
	usort( $contactos, static fn( array $a, array $b ): int => strcasecmp( (string) ( $a['datos']['nombre'] ?? '' ), (string) ( $b['datos']['nombre'] ?? '' ) ) );
	$editando = szs_obtener_entidad( 'contacto', szs_campo_get( 'uid' ) );
	$valores  = $editando['datos'] ?? array();
	$nombres  = szs_nombres_personas();
	?>
	<div class="wrap">
		<h1>Contactos del espacio</h1>
		<p>La agenda compartida: mataderos, veterinaria, personas expertas, compradores… La ve todo el equipo en la app. Cualquiera puede añadir contactos; aquí se editan todos.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<form method="get" style="margin:12px 0;display:flex;gap:8px;align-items:center;">
			<input type="hidden" name="page" value="<?php echo esc_attr( SZS_PAGINA_CONTACTOS ); ?>">
			<?php szs_selector( 'tipo', SZS_TIPOS_CONTACTO, $filtro, 'Todos los tipos' ); ?>
			<button class="button">Filtrar</button>
		</form>
		<table class="widefat striped">
			<thead><tr><th>Nombre</th><th>Tipo</th><th>Teléfono</th><th>Correo</th><th>Localidad</th><th>Añadido por</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $contactos ) ) : ?>
				<tr><td colspan="7">Todavía no hay contactos.</td></tr>
			<?php endif; ?>
			<?php foreach ( $contactos as $contacto ) : ?>
				<?php $datos = $contacto['datos']; ?>
				<tr>
					<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_CONTACTOS, array( 'uid' => $contacto['uid'] ) ) ); ?>"><strong><?php echo esc_html( (string) ( $datos['nombre'] ?? '' ) ); ?></strong></a>
						<?php if ( '' !== (string) ( $datos['notas'] ?? '' ) ) : ?><br><small><?php echo esc_html( (string) $datos['notas'] ); ?></small><?php endif; ?></td>
					<td><?php echo esc_html( SZS_TIPOS_CONTACTO[ $datos['tipo'] ?? '' ] ?? '—' ); ?></td>
					<td><?php echo esc_html( (string) ( $datos['telefono'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $datos['correo'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $datos['localidad'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( $nombres[ $contacto['autor_uid'] ] ?? '—' ); ?></td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_contactos' ); ?>
							<input type="hidden" name="szs_accion" value="borrar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $contacto['uid'] ); ?>">
							<button class="button button-small button-link-delete" onclick="return confirm('¿Borrar el contacto? Desaparecerá también de los móviles.');">Borrar</button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2><?php echo null === $editando ? 'Añadir contacto' : 'Editar contacto'; ?></h2>
		<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_CONTACTOS ) ); ?>">
			<?php wp_nonce_field( 'szs_contactos' ); ?>
			<input type="hidden" name="szs_accion" value="guardar">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $editando['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nombre">Nombre</label></th><td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" required value="<?php echo esc_attr( (string) ( $valores['nombre'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_tipo">Tipo</label></th><td><?php szs_selector( 'szs_tipo', SZS_TIPOS_CONTACTO, (string) ( $valores['tipo'] ?? 'otro' ) ); ?></td></tr>
				<tr><th><label for="szs_telefono">Teléfono</label></th><td><input type="tel" id="szs_telefono" name="szs_telefono" value="<?php echo esc_attr( (string) ( $valores['telefono'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_correo">Correo</label></th><td><input type="email" id="szs_correo" name="szs_correo" class="regular-text" value="<?php echo esc_attr( (string) ( $valores['correo'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_localidad">Localidad</label></th><td><input type="text" id="szs_localidad" name="szs_localidad" value="<?php echo esc_attr( (string) ( $valores['localidad'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_notas">Notas</label></th><td><textarea id="szs_notas" name="szs_notas" rows="2" class="large-text"><?php echo esc_textarea( (string) ( $valores['notas'] ?? '' ) ); ?></textarea></td></tr>
			</table>
			<?php submit_button( null === $editando ? 'Añadir' : 'Guardar cambios' ); ?>
		</form>
	</div>
	<?php
}

// ─── Rendimientos de referencia ───

function szs_pagina_rendimientos(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = null;
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_rendimientos' );
		$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
		$uid    = szs_campo_post( 'szs_uid' );
		if ( 'borrar' === $accion && szs_borrar_entidad_desde_panel( 'rendimiento', $uid ) ) {
			$aviso = array( 'success', 'Rendimiento borrado.' );
		}
		if ( 'guardar' === $accion ) {
			$nombre   = szs_campo_post( 'szs_nombre' );
			$canal    = (float) str_replace( ',', '.', szs_campo_post( 'szs_rendimiento_canal' ) );
			$producto = (float) str_replace( ',', '.', szs_campo_post( 'szs_rendimiento_producto', '100' ) );
			if ( '' === $nombre || $canal <= 0 || $canal > 100 || $producto <= 0 || $producto > 100 ) {
				$aviso = array( 'error', 'Faltan el nombre o los porcentajes (entre 0 y 100).' );
			} else {
				szs_guardar_entidad_desde_panel(
					'rendimiento',
					'' === $uid ? szs_nuevo_uid() : $uid,
					array(
						'nombre'               => $nombre,
						'rendimiento_canal'    => $canal,
						'rendimiento_producto' => $producto,
						'fuente'               => szs_texto_largo_post( 'szs_fuente' ),
					)
				);
				$aviso = array( 'success', 'Guardado. La calculadora de la app lo ofrecerá al sincronizar.' );
			}
		}
	}
	$rendimientos = szs_listar_entidades_tipo( 'rendimiento' );
	usort( $rendimientos, static fn( array $a, array $b ): int => strcasecmp( (string) ( $a['datos']['nombre'] ?? '' ), (string) ( $b['datos']['nombre'] ?? '' ) ) );
	$editando = szs_obtener_entidad( 'rendimiento', szs_campo_get( 'uid' ) );
	$valores  = $editando['datos'] ?? array();
	?>
	<div class="wrap">
		<h1>Rendimientos de referencia</h1>
		<p>Los porcentajes que la <strong>calculadora de transformación</strong> de la app ofrece como punto de partida (cada proyecto puede ajustarlos). La app no trae ninguno de serie: los pone coordinación, con su fuente.</p>
		<ul style="list-style:disc;padding-left:20px;max-width:760px;">
			<li><strong>Rendimiento a canal</strong>: kg de canal por cada 100 kg de peso vivo.</li>
			<li><strong>Producto vendible</strong>: kg de producto (piezas, carne envasada…) por cada 100 kg de canal. 100 % si se vende la canal entera.</li>
		</ul>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<table class="widefat striped" style="max-width:960px;">
			<thead><tr><th>Nombre</th><th>A canal</th><th>Producto vendible</th><th>Fuente</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $rendimientos ) ) : ?>
				<tr><td colspan="5">Todavía no hay ninguno.</td></tr>
			<?php endif; ?>
			<?php foreach ( $rendimientos as $rendimiento ) : ?>
				<?php $datos = $rendimiento['datos']; ?>
				<tr>
					<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_RENDIMIENTOS, array( 'uid' => $rendimiento['uid'] ) ) ); ?>"><strong><?php echo esc_html( (string) ( $datos['nombre'] ?? '' ) ); ?></strong></a></td>
					<td><?php echo esc_html( (string) ( $datos['rendimiento_canal'] ?? '' ) ); ?> %</td>
					<td><?php echo esc_html( (string) ( $datos['rendimiento_producto'] ?? '' ) ); ?> %</td>
					<td><?php echo esc_html( (string) ( $datos['fuente'] ?? '' ) ); ?></td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_rendimientos' ); ?>
							<input type="hidden" name="szs_accion" value="borrar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $rendimiento['uid'] ); ?>">
							<button class="button button-small button-link-delete">Borrar</button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2><?php echo null === $editando ? 'Añadir rendimiento' : 'Editar rendimiento'; ?></h2>
		<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_RENDIMIENTOS ) ); ?>">
			<?php wp_nonce_field( 'szs_rendimientos' ); ?>
			<input type="hidden" name="szs_accion" value="guardar">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $editando['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nombre">Nombre</label></th><td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" required placeholder="Cordero lechal — despiece" value="<?php echo esc_attr( (string) ( $valores['nombre'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_rendimiento_canal">Rendimiento a canal (%)</label></th><td><input type="text" id="szs_rendimiento_canal" name="szs_rendimiento_canal" class="small-text" required value="<?php echo esc_attr( (string) ( $valores['rendimiento_canal'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_rendimiento_producto">Producto vendible sobre canal (%)</label></th><td><input type="text" id="szs_rendimiento_producto" name="szs_rendimiento_producto" class="small-text" value="<?php echo esc_attr( (string) ( $valores['rendimiento_producto'] ?? '100' ) ); ?>"></td></tr>
				<tr><th><label for="szs_fuente">Fuente</label></th><td><textarea id="szs_fuente" name="szs_fuente" rows="2" class="large-text" placeholder="De dónde sale el dato (matadero, asesoría, datos propios…)"><?php echo esc_textarea( (string) ( $valores['fuente'] ?? '' ) ); ?></textarea></td></tr>
			</table>
			<?php submit_button( null === $editando ? 'Añadir' : 'Guardar cambios' ); ?>
		</form>
	</div>
	<?php
}

// ─── Alimentación por días (Excel) ───

function szs_url_alimentacion_csv( string $proyecto_uid ): string {
	return wp_nonce_url(
		add_query_arg(
			array(
				'page'     => SZS_PAGINA_PROYECTOS,
				'exportar' => 'alimentacion',
				'proyecto' => $proyecto_uid,
			),
			admin_url( 'admin.php' )
		),
		'szs_exportar_alimentacion'
	);
}

function szs_exportar_alimentacion_csv(): void {
	if ( SZS_PAGINA_PROYECTOS !== szs_campo_get( 'page' ) || 'alimentacion' !== szs_campo_get( 'exportar' ) || ! szs_puede_usar_panel() ) {
		return;
	}
	check_admin_referer( 'szs_exportar_alimentacion' );
	$proyecto = szs_obtener_entidad( 'proyecto', szs_campo_get( 'proyecto' ) );
	if ( null === $proyecto ) {
		wp_die( 'Proyecto no encontrado.' );
	}
	$filas  = szs_alimentacion_por_dias( szs_listar_entidades_tipo( 'registro_actividad', $proyecto['uid'] ), wp_timezone_string() );
	$nombre = sanitize_file_name( 'alimentacion-' . szs_etiqueta_entidad( $proyecto ) . '-' . wp_date( 'Y-m-d' ) . '.csv' );
	nocache_headers();
	header( 'Content-Type: text/csv; charset=utf-8' );
	header( 'Content-Disposition: attachment; filename="' . $nombre . '"' );
	echo szs_alimentacion_a_csv( $filas ); // phpcs:ignore WordPress.Security.EscapeOutput -- CSV, no HTML.
	exit;
}
