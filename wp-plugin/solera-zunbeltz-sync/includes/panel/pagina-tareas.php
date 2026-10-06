<?php
/**
 * Panel · Tareas: el tablero de la oficina. Listado con filtros (finca,
 * estado, responsable, vencidas), alta y edición, cambio rápido de estado,
 * borrado y exportación a CSV. Al cerrar una tarea periódica se crea la
 * siguiente, como en la app.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'admin_init', 'szs_exportar_tareas_csv' );

/** Todas las tareas, normalizadas. */
function szs_listar_todas_las_tareas(): array {
	global $wpdb;
	$tabla = $wpdb->prefix . SZS_TABLA;
	return array_map( 'szs_normalizar_tarea', (array) $wpdb->get_results( "SELECT * FROM {$tabla}", ARRAY_A ) );
}

function szs_filtros_tareas_get(): array {
	return array(
		'finca'       => szs_campo_get( 'finca' ),
		'estado'      => szs_campo_get( 'estado', 'abiertas' ),
		'responsable' => szs_campo_get( 'responsable' ),
		'vencidas'    => '1' === szs_campo_get( 'vencidas' ),
	);
}

function szs_exportar_tareas_csv(): void {
	if ( SZS_PAGINA_TAREAS !== szs_campo_get( 'page' ) || 'csv' !== szs_campo_get( 'exportar' ) ) {
		return;
	}
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	check_admin_referer( 'szs_exportar_tareas' );
	$tareas = szs_ordenar_tareas_panel(
		szs_filtrar_tareas_panel( szs_listar_todas_las_tareas(), szs_filtros_tareas_get(), szs_inicio_de_hoy_ms() ),
		szs_inicio_de_hoy_ms()
	);
	nocache_headers();
	header( 'Content-Type: text/csv; charset=utf-8' );
	header( 'Content-Disposition: attachment; filename="tareas-zunbeltz-' . wp_date( 'Y-m-d' ) . '.csv"' );
	echo szs_tareas_a_csv( $tareas ); // phpcs:ignore WordPress.Security.EscapeOutput -- CSV, no HTML.
	exit;
}

/**
 * Guarda una tarea desde el panel (alta o cambio), deja huella y, si se
 * cierra una periódica, crea la siguiente.
 */
function szs_guardar_tarea_desde_panel( array $datos, ?array $existente ): array {
	global $wpdb;
	$tabla   = $wpdb->prefix . SZS_TABLA;
	$persona = szs_persona_del_panel();
	$ahora   = szs_ahora_ms();

	$datos['actualizado_ms'] = max( $ahora, null === $existente ? 0 : $existente['actualizado_ms'] + 1 );
	if ( null === $existente ) {
		$datos['creado_por_uid']    = (string) $persona['uid'];
		$datos['fecha_creacion_ms'] = $ahora;
	}
	$guardada = szs_guardar_tarea( $tabla, szs_normalizar_tarea( $datos ), null === $existente );
	szs_registrar_actividad_tarea( $persona, $existente, $guardada, 'panel' );

	$se_cierra = 'hecha' === $guardada['estado'] && ( null === $existente || 'hecha' !== $existente['estado'] );
	$siguiente = $se_cierra ? szs_siguiente_tarea_periodica( $guardada, $ahora, szs_nuevo_uid() ) : null;
	if ( null !== $siguiente ) {
		$nueva = szs_guardar_tarea( $tabla, $siguiente, true );
		szs_registrar_actividad_tarea( $persona, null, $nueva, 'panel' );
	}
	return $guardada;
}

function szs_obtener_tarea( string $uid ): ?array {
	global $wpdb;
	$tabla = $wpdb->prefix . SZS_TABLA;
	$fila  = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$tabla} WHERE uid = %s", $uid ), ARRAY_A );
	return is_array( $fila ) ? szs_normalizar_tarea( $fila ) : null;
}

function szs_procesar_accion_tareas(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_tareas' );
	global $wpdb;
	$accion    = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	$uid       = szs_campo_post( 'szs_uid' );
	$existente = '' === $uid ? null : szs_obtener_tarea( $uid );

	switch ( $accion ) {
		case 'cambiar_estado':
			if ( null === $existente ) {
				return array( 'error', 'La tarea ya no existe.' );
			}
			$estado = sanitize_key( szs_campo_post( 'szs_estado' ) );
			if ( ! isset( SZS_ESTADOS_TAREA[ $estado ] ) ) {
				return null;
			}
			szs_guardar_tarea_desde_panel( array_merge( $existente, array( 'estado' => $estado ) ), $existente );
			return array( 'success', 'Estado cambiado.' );

		case 'borrar':
			if ( null === $existente ) {
				return null;
			}
			$wpdb->delete( $wpdb->prefix . SZS_TABLA, array( 'uid' => $uid ) );
			szs_registrar_actividad( szs_persona_del_panel(), 'borrar', 'tarea', $uid, $existente['titulo'], $existente['finca_nombre'], '', 'panel' );
			return array( 'success', 'Tarea borrada. Desaparecerá de los móviles al sincronizar.' );

		case 'guardar':
			$titulo = szs_campo_post( 'szs_titulo' );
			$fincas = szs_nombres_fincas();
			$finca  = szs_campo_post( 'szs_finca_uid' );
			if ( '' === $titulo || ! isset( $fincas[ $finca ] ) ) {
				return array( 'error', 'Faltan el título o la finca.' );
			}
			$recurrencia = (int) szs_campo_post( 'szs_recurrencia_dias' );
			$datos       = array_merge(
				$existente ?? array( 'uid' => szs_nuevo_uid() ),
				array(
					'titulo'            => $titulo,
					'descripcion'       => szs_texto_largo_post( 'szs_descripcion' ),
					'finca_uid'         => $finca,
					'finca_nombre'      => $fincas[ $finca ],
					'punto_uid'         => szs_campo_post( 'szs_punto_uid' ),
					'responsable_uid'   => szs_campo_post( 'szs_responsable_uid' ),
					'prioridad'         => sanitize_key( szs_campo_post( 'szs_prioridad', 'media' ) ),
					'estado'            => sanitize_key( szs_campo_post( 'szs_estado', 'pendiente' ) ),
					'fecha_objetivo_ms' => szs_ms_desde_fecha( szs_campo_post( 'szs_fecha' ) ),
					'coste_centimos'    => szs_centimos_desde_texto( szs_campo_post( 'szs_coste' ) ),
					'recurrencia_dias'  => $recurrencia > 0 ? $recurrencia : null,
				)
			);
			if ( '' === $datos['responsable_uid'] ) {
				$datos['responsable'] = '';
			}
			$guardada = szs_guardar_tarea_desde_panel( $datos, $existente );

			// Si viene de una petición, la petición queda aceptada y enlazada.
			$peticion_uid = szs_campo_post( 'szs_peticion_uid' );
			if ( '' !== $peticion_uid && null === $existente ) {
				szs_guardar_entidad_desde_panel(
					'peticion',
					$peticion_uid,
					array(
						'estado'    => 'aceptada',
						'tarea_uid' => $guardada['uid'],
					)
				);
			}
			return array( 'success', null === $existente ? 'Tarea creada. Llegará a los móviles al sincronizar.' : 'Tarea guardada.' );
	}
	return null;
}

function szs_pagina_tareas(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = szs_procesar_accion_tareas();
	$vista = szs_campo_get( 'vista' );
	if ( 'formulario' === $vista && null === $aviso ) {
		szs_formulario_tarea( szs_obtener_tarea( szs_campo_get( 'uid' ) ), szs_campo_get( 'peticion' ) );
		return;
	}

	$hoy      = szs_inicio_de_hoy_ms();
	$filtros  = szs_filtros_tareas_get();
	$todas    = szs_listar_todas_las_tareas();
	$tareas   = szs_ordenar_tareas_panel( szs_filtrar_tareas_panel( $todas, $filtros, $hoy ), $hoy );
	$vencidas = count( szs_filtrar_tareas_panel( $todas, array( 'vencidas' => true ), $hoy ) );
	$personas = array();
	foreach ( szs_listar_personas() as $persona ) {
		$personas[ $persona['uid'] ] = $persona['nombre'];
	}
	$fincas_tareas = array_unique( array_filter( array_column( $todas, 'finca_nombre' ) ) );
	sort( $fincas_tareas );
	?>
	<div class="wrap">
		<h1 class="wp-heading-inline">Tareas</h1>
		<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vista' => 'formulario' ) ) ); ?>" class="page-title-action">Nueva tarea</a>
		<hr class="wp-header-end">
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<?php if ( $vencidas > 0 ) : ?>
			<div class="notice notice-warning"><p>
				<strong><?php echo esc_html( 1 === $vencidas ? '1 tarea vencida.' : "{$vencidas} tareas vencidas." ); ?></strong>
				<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vencidas' => '1', 'estado' => 'abiertas' ) ) ); ?>">Ver solo las vencidas</a>
			</p></div>
		<?php endif; ?>

		<form method="get" style="margin:12px 0;display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
			<input type="hidden" name="page" value="<?php echo esc_attr( SZS_PAGINA_TAREAS ); ?>">
			<?php szs_selector( 'finca', array_combine( $fincas_tareas, $fincas_tareas ) ?: array(), $filtros['finca'], 'Todas las fincas' ); ?>
			<?php szs_selector( 'estado', array_merge( array( 'abiertas' => 'Abiertas (sin hacer)' ), SZS_ESTADOS_TAREA ), $filtros['estado'], 'Todos los estados' ); ?>
			<?php szs_selector( 'responsable', array_merge( array( 'sin_asignar' => 'Sin asignar (generales)' ), $personas ), $filtros['responsable'], 'Cualquier responsable' ); ?>
			<label><input type="checkbox" name="vencidas" value="1" <?php checked( $filtros['vencidas'] ); ?>> Solo vencidas</label>
			<button class="button">Filtrar</button>
			<a class="button" href="<?php echo esc_url( wp_nonce_url( add_query_arg( array_merge( array_map( 'strval', $filtros ), array( 'page' => SZS_PAGINA_TAREAS, 'exportar' => 'csv', 'vencidas' => $filtros['vencidas'] ? '1' : '' ) ), admin_url( 'admin.php' ) ), 'szs_exportar_tareas' ) ); ?>">Exportar a Excel (CSV)</a>
		</form>

		<table class="widefat striped">
			<thead><tr><th>Tarea</th><th>Finca</th><th>Responsable</th><th>Prioridad</th><th>Fecha</th><th>Estado</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $tareas ) ) : ?>
				<tr><td colspan="7">No hay tareas con estos filtros.</td></tr>
			<?php endif; ?>
			<?php foreach ( $tareas as $tarea ) : ?>
				<?php $vencida = szs_tarea_vencida( $tarea, $hoy ); ?>
				<tr>
					<td>
						<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vista' => 'formulario', 'uid' => $tarea['uid'] ) ) ); ?>"><strong><?php echo esc_html( $tarea['titulo'] ); ?></strong></a>
						<?php if ( null !== $tarea['recurrencia_dias'] ) : ?>
							<br><small>Cada <?php echo esc_html( (string) $tarea['recurrencia_dias'] ); ?> días</small>
						<?php endif; ?>
					</td>
					<td><?php echo esc_html( $tarea['finca_nombre'] ); ?></td>
					<td><?php echo '' === $tarea['responsable'] ? '<em>Sin asignar</em>' : esc_html( $tarea['responsable'] ); ?></td>
					<td><?php echo esc_html( SZS_PRIORIDADES_TAREA[ $tarea['prioridad'] ] ?? $tarea['prioridad'] ); ?></td>
					<td<?php echo $vencida ? ' style="color:#b8402a;font-weight:600;"' : ''; ?>><?php echo esc_html( szs_fecha_ms( $tarea['fecha_objetivo_ms'] ) ); ?><?php echo $vencida ? ' · vencida' : ''; ?></td>
					<td>
						<form method="post" style="display:flex;gap:4px;">
							<?php wp_nonce_field( 'szs_tareas' ); ?>
							<input type="hidden" name="szs_accion" value="cambiar_estado">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ); ?>">
							<?php szs_selector( 'szs_estado', SZS_ESTADOS_TAREA, $tarea['estado'] ); ?>
							<button class="button button-small">Cambiar</button>
						</form>
					</td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_tareas' ); ?>
							<input type="hidden" name="szs_accion" value="borrar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ); ?>">
							<button class="button button-small button-link-delete" onclick="return confirm('¿Borrar la tarea? Desaparecerá también de los móviles.');">Borrar</button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<p class="description">Lo que se cambia aquí llega a los móviles en su próxima sincronización (al abrir la app o cada pocos minutos).</p>
	</div>
	<?php
}

function szs_formulario_tarea( ?array $tarea, string $peticion_uid ): void {
	$fincas   = szs_nombres_fincas();
	$personas = array();
	foreach ( szs_listar_personas() as $persona ) {
		$personas[ $persona['uid'] ] = $persona['nombre'] . ' (' . szs_etiqueta_rol( $persona['rol'] ) . ')';
	}
	$puntos = array();
	foreach ( szs_listar_entidades_tipo( 'punto' ) as $punto ) {
		$finca                   = $fincas[ $punto['datos']['finca_uid'] ?? '' ] ?? '';
		$puntos[ $punto['uid'] ] = trim( $finca . ' — ' . szs_etiqueta_entidad( $punto ), ' —' );
	}
	asort( $puntos );

	// Desde una petición: el formulario llega relleno.
	$peticion = '' === $peticion_uid ? null : szs_obtener_entidad( 'peticion', $peticion_uid );
	$valores  = $tarea ?? szs_normalizar_tarea(
		array(
			'titulo'      => $peticion['datos']['titulo'] ?? '',
			'descripcion' => $peticion['datos']['descripcion'] ?? '',
			'finca_uid'   => $peticion['datos']['finca_uid'] ?? '',
			'punto_uid'   => $peticion['datos']['punto_uid'] ?? '',
			'prioridad'   => ! empty( $peticion['datos']['urgente'] ) ? 'alta' : 'media',
		)
	);
	?>
	<div class="wrap">
		<h1><?php echo null === $tarea ? 'Nueva tarea' : 'Editar tarea'; ?></h1>
		<?php if ( null !== $peticion ) : ?>
			<div class="notice notice-info"><p>Desde la petición «<?php echo esc_html( szs_etiqueta_entidad( $peticion ) ); ?>». Al guardar, la petición queda aceptada.</p></div>
		<?php endif; ?>
		<?php if ( empty( $fincas ) ) : ?>
			<div class="notice notice-warning"><p>Todavía no hay fincas en el servidor. Sincroniza primero desde la app de coordinación para que lleguen.</p></div>
		<?php endif; ?>
		<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS ) ); ?>">
			<?php wp_nonce_field( 'szs_tareas' ); ?>
			<input type="hidden" name="szs_accion" value="guardar">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ?? '' ); ?>">
			<input type="hidden" name="szs_peticion_uid" value="<?php echo esc_attr( $peticion_uid ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_titulo">Tarea</label></th><td><input type="text" id="szs_titulo" name="szs_titulo" class="regular-text" required value="<?php echo esc_attr( $valores['titulo'] ); ?>"></td></tr>
				<tr><th><label for="szs_descripcion">Descripción</label></th><td><textarea id="szs_descripcion" name="szs_descripcion" rows="3" class="large-text"><?php echo esc_textarea( $valores['descripcion'] ); ?></textarea></td></tr>
				<tr><th><label for="szs_finca_uid">Finca</label></th><td><?php szs_selector( 'szs_finca_uid', $fincas, $valores['finca_uid'], '— Elige —' ); ?></td></tr>
				<tr><th><label for="szs_punto_uid">Punto (opcional)</label></th><td><?php szs_selector( 'szs_punto_uid', $puntos, $valores['punto_uid'], 'Toda la finca' ); ?></td></tr>
				<tr><th><label for="szs_responsable_uid">Responsable</label></th><td><?php szs_selector( 'szs_responsable_uid', $personas, $valores['responsable_uid'], 'Sin asignar (tarea general)' ); ?></td></tr>
				<tr><th><label for="szs_prioridad">Prioridad</label></th><td><?php szs_selector( 'szs_prioridad', SZS_PRIORIDADES_TAREA, $valores['prioridad'] ); ?></td></tr>
				<tr><th><label for="szs_estado">Estado</label></th><td><?php szs_selector( 'szs_estado', SZS_ESTADOS_TAREA, $valores['estado'] ); ?></td></tr>
				<tr><th><label for="szs_fecha">Fecha objetivo</label></th><td><input type="date" id="szs_fecha" name="szs_fecha" value="<?php echo esc_attr( null === $valores['fecha_objetivo_ms'] ? '' : wp_date( 'Y-m-d', intdiv( $valores['fecha_objetivo_ms'], 1000 ) ) ); ?>"></td></tr>
				<tr><th><label for="szs_recurrencia_dias">Se repite cada (días)</label></th><td><input type="number" min="0" id="szs_recurrencia_dias" name="szs_recurrencia_dias" class="small-text" value="<?php echo esc_attr( (string) ( $valores['recurrencia_dias'] ?? '' ) ); ?>"> <span class="description">Vacío = tarea puntual. Al marcarla hecha se crea la siguiente.</span></td></tr>
				<tr><th><label for="szs_coste">Coste (€)</label></th><td><input type="text" id="szs_coste" name="szs_coste" class="small-text" value="<?php echo esc_attr( null === $valores['coste_centimos'] ? '' : number_format( $valores['coste_centimos'] / 100, 2, ',', '' ) ); ?>"></td></tr>
			</table>
			<?php submit_button( null === $tarea ? 'Crear tarea' : 'Guardar cambios' ); ?>
			<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS ) ); ?>">Volver al listado</a>
		</form>
	</div>
	<?php
}
