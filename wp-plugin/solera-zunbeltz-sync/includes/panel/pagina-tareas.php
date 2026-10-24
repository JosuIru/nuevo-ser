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

	szs_generar_siguiente_periodica_si_toca( $tabla, $persona, $existente, $guardada, 'panel' );
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
				return array( 'error', szs_t( 'La tarea ya no existe.' ) );
			}
			$estado = sanitize_key( szs_campo_post( 'szs_estado' ) );
			if ( ! isset( SZS_ESTADOS_TAREA[ $estado ] ) ) {
				return null;
			}
			szs_guardar_tarea_desde_panel( array_merge( $existente, array( 'estado' => $estado ) ), $existente );
			return array( 'success', szs_t( 'Estado cambiado.' ) );

		case 'borrar':
			if ( null === $existente ) {
				return null;
			}
			szs_borrar_tarea_con_lapida( $uid );
			szs_registrar_actividad( szs_persona_del_panel(), 'borrar', 'tarea', $uid, $existente['titulo'], $existente['finca_nombre'], '', 'panel' );
			return array( 'success', szs_t( 'Tarea borrada. Desaparecerá de los móviles al sincronizar.' ) );

		case 'guardar':
			$titulo = szs_campo_post( 'szs_titulo' );
			$fincas = szs_nombres_fincas();
			$finca  = szs_campo_post( 'szs_finca_uid' );
			if ( '' === $titulo || ! isset( $fincas[ $finca ] ) ) {
				return array( 'error', szs_t( 'Faltan el título o la finca.' ) );
			}
			$recurrencia  = (int) szs_campo_post( 'szs_recurrencia_dias' );
			$responsables = szs_ordenar_responsables_elegidas(
				null === $existente ? array() : szs_responsables_de_tarea( $existente ),
				szs_lista_uids_o_null( isset( $_POST['szs_responsables_uids'] ) ? array_map( 'sanitize_text_field', (array) wp_unslash( $_POST['szs_responsables_uids'] ) ) : array() ) ?? array() // phpcs:ignore WordPress.Security.NonceVerification
			);
			$datos        = array_merge(
				$existente ?? array( 'uid' => szs_nuevo_uid() ),
				array(
					'titulo'            => $titulo,
					'descripcion'       => szs_texto_largo_post( 'szs_descripcion' ),
					'finca_uid'         => $finca,
					'finca_nombre'      => $fincas[ $finca ],
					'punto_uid'         => szs_campo_post( 'szs_punto_uid' ),
					'zona_uid'          => szs_campo_post( 'szs_zona_uid' ),
					'responsables_uids' => $responsables,
					'responsable_uid'   => $responsables[0] ?? '',
					'prioridad'         => sanitize_key( szs_campo_post( 'szs_prioridad', 'media' ) ),
					'estado'            => sanitize_key( szs_campo_post( 'szs_estado', 'pendiente' ) ),
					'fecha_objetivo_ms' => szs_ms_desde_fecha( szs_campo_post( 'szs_fecha' ) ),
					'coste_centimos'    => szs_centimos_desde_texto( szs_campo_post( 'szs_coste' ) ),
					'recurrencia_dias'  => $recurrencia > 0 ? $recurrencia : null,
				)
			);
			if ( array() === $responsables ) {
				$datos['responsable'] = '';
			}
			// Alta con varias personas: una compartida o una para cada una.
			// Al editar, cambiar las personas deja la tarea compartida.
			$repartos = null === $existente && 'cada_persona' === szs_campo_post( 'szs_reparto' )
				? szs_tareas_para_cada_responsable( $datos, 'szs_nuevo_uid' )
				: array( $datos );
			$guardadas = array_map( static fn( array $reparto ): array => szs_guardar_tarea_desde_panel( $reparto, $existente ), $repartos );
			$guardada  = $guardadas[0];

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
			if ( count( $guardadas ) > 1 ) {
				return array( 'success', szs_t( 'Creadas %d tareas, una para cada persona. Llegarán a los móviles al sincronizar.', count( $guardadas ) ) );
			}
			return array( 'success', null === $existente ? szs_t( 'Tarea creada. Llegará a los móviles al sincronizar.' ) : szs_t( 'Tarea guardada.' ) );
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
		<h1 class="wp-heading-inline"><?php echo esc_html( szs_t( 'Tareas' ) ); ?></h1>
		<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vista' => 'formulario' ) ) ); ?>" class="page-title-action"><?php echo esc_html( szs_t( 'Nueva tarea' ) ); ?></a>
		<hr class="wp-header-end">
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<?php if ( $vencidas > 0 ) : ?>
			<div class="notice notice-warning"><p>
				<strong><?php echo esc_html( szs_tn( '1 tarea vencida.', '%d tareas vencidas.', $vencidas, $vencidas ) ); ?></strong>
				<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vencidas' => '1', 'estado' => 'abiertas' ) ) ); ?>"><?php echo esc_html( szs_t( 'Ver solo las vencidas' ) ); ?></a>
			</p></div>
		<?php endif; ?>

		<form method="get" style="margin:12px 0;display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
			<input type="hidden" name="page" value="<?php echo esc_attr( SZS_PAGINA_TAREAS ); ?>">
			<?php szs_selector( 'finca', array_combine( $fincas_tareas, $fincas_tareas ) ?: array(), $filtros['finca'], szs_t( 'Todas las fincas' ) ); ?>
			<?php szs_selector( 'estado', array_merge( array( 'abiertas' => szs_t( 'Abiertas (sin hacer)' ) ), szs_t_opciones( SZS_ESTADOS_TAREA ) ), $filtros['estado'], szs_t( 'Todos los estados' ) ); ?>
			<?php szs_selector( 'responsable', array_merge( array( 'sin_asignar' => szs_t( 'Sin asignar (generales)' ) ), $personas ), $filtros['responsable'], szs_t( 'Cualquier responsable' ) ); ?>
			<label><input type="checkbox" name="vencidas" value="1" <?php checked( $filtros['vencidas'] ); ?>> <?php echo esc_html( szs_t( 'Solo vencidas' ) ); ?></label>
			<button class="button"><?php echo esc_html( szs_t( 'Filtrar' ) ); ?></button>
			<a class="button" href="<?php echo esc_url( wp_nonce_url( add_query_arg( array_merge( array_map( 'strval', $filtros ), array( 'page' => SZS_PAGINA_TAREAS, 'exportar' => 'csv', 'vencidas' => $filtros['vencidas'] ? '1' : '' ) ), admin_url( 'admin.php' ) ), 'szs_exportar_tareas' ) ); ?>"><?php echo esc_html( szs_t( 'Exportar a Excel (CSV)' ) ); ?></a>
		</form>

		<table class="widefat striped">
			<thead><tr><th><?php echo esc_html( szs_t( 'Tarea' ) ); ?></th><th><?php echo esc_html( szs_t( 'Finca' ) ); ?></th><th><?php echo esc_html( szs_t( 'Responsables' ) ); ?></th><th><?php echo esc_html( szs_t( 'Prioridad' ) ); ?></th><th><?php echo esc_html( szs_t( 'Fecha' ) ); ?></th><th><?php echo esc_html( szs_t( 'Estado' ) ); ?></th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $tareas ) ) : ?>
				<tr><td colspan="7"><?php echo esc_html( szs_t( 'No hay tareas con estos filtros.' ) ); ?></td></tr>
			<?php endif; ?>
			<?php foreach ( $tareas as $tarea ) : ?>
				<?php $vencida = szs_tarea_vencida( $tarea, $hoy ); ?>
				<tr>
					<td>
						<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vista' => 'formulario', 'uid' => $tarea['uid'] ) ) ); ?>"><strong><?php echo esc_html( $tarea['titulo'] ); ?></strong></a>
						<?php if ( null !== $tarea['recurrencia_dias'] ) : ?>
							<br><small><?php echo esc_html( szs_t( 'Cada %d días', (int) $tarea['recurrencia_dias'] ) ); ?></small>
						<?php endif; ?>
					</td>
					<td><?php echo esc_html( $tarea['finca_nombre'] ); ?></td>
					<td><?php echo '' === $tarea['responsable'] ? '<em>' . esc_html( szs_t( 'Sin asignar' ) ) . '</em>' : esc_html( $tarea['responsable'] ); ?></td>
					<td><?php echo esc_html( isset( SZS_PRIORIDADES_TAREA[ $tarea['prioridad'] ] ) ? szs_t( SZS_PRIORIDADES_TAREA[ $tarea['prioridad'] ] ) : $tarea['prioridad'] ); ?></td>
					<td<?php echo $vencida ? ' style="color:#b8402a;font-weight:600;"' : ''; ?>><?php echo esc_html( szs_fecha_ms( $tarea['fecha_objetivo_ms'] ) ); ?><?php echo $vencida ? ' · ' . esc_html( szs_t( 'vencida' ) ) : ''; ?></td>
					<td>
						<form method="post" style="display:flex;gap:4px;">
							<?php wp_nonce_field( 'szs_tareas' ); ?>
							<input type="hidden" name="szs_accion" value="cambiar_estado">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ); ?>">
							<?php szs_selector( 'szs_estado', szs_t_opciones( SZS_ESTADOS_TAREA ), $tarea['estado'] ); ?>
							<button class="button button-small"><?php echo esc_html( szs_t( 'Cambiar' ) ); ?></button>
						</form>
					</td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_tareas' ); ?>
							<input type="hidden" name="szs_accion" value="borrar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ); ?>">
							<button class="button button-small button-link-delete" onclick="return confirm('<?php echo esc_js( szs_t( '¿Borrar la tarea? Desaparecerá también de los móviles.' ) ); ?>');"><?php echo esc_html( szs_t( 'Borrar' ) ); ?></button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<p class="description"><?php echo esc_html( szs_t( 'Lo que se cambia aquí llega a los móviles en su próxima sincronización (al abrir la app o cada pocos minutos).' ) ); ?></p>
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
	$zonas = array();
	foreach ( szs_listar_entidades_tipo( 'zona' ) as $zona ) {
		$finca                 = $fincas[ $zona['datos']['finca_uid'] ?? '' ] ?? '';
		$zonas[ $zona['uid'] ] = trim( $finca . ' — ' . szs_etiqueta_entidad( $zona ), ' —' );
	}
	asort( $zonas );

	// Desde una petición: el formulario llega relleno (también la pieza o el punto sobre los que se pidió).
	$peticion = '' === $peticion_uid ? null : szs_obtener_entidad( 'peticion', $peticion_uid );
	$valores  = $tarea ?? szs_normalizar_tarea(
		array(
			'titulo'      => $peticion['datos']['titulo'] ?? '',
			'descripcion' => $peticion['datos']['descripcion'] ?? '',
			'finca_uid'   => $peticion['datos']['finca_uid'] ?? '',
			'punto_uid'   => $peticion['datos']['punto_uid'] ?? '',
			'zona_uid'    => $peticion['datos']['zona_uid'] ?? '',
			'prioridad'   => ! empty( $peticion['datos']['urgente'] ) ? 'alta' : 'media',
		)
	);
	// Responsable ya desactivada: sin su casilla, al guardar la tarea la
	// perdería sin que nadie lo hubiera decidido.
	$elegidas = szs_responsables_de_tarea( $valores );
	foreach ( $elegidas as $uid_elegida ) {
		if ( ! isset( $personas[ $uid_elegida ] ) ) {
			$personas[ $uid_elegida ] = ( 1 === count( $elegidas ) && '' !== $valores['responsable'] ? $valores['responsable'] : $uid_elegida ) . ' (' . szs_t( 'desactivada' ) . ')';
		}
	}
	?>
	<div class="wrap">
		<h1><?php echo esc_html( null === $tarea ? szs_t( 'Nueva tarea' ) : szs_t( 'Editar tarea' ) ); ?></h1>
		<?php if ( null !== $peticion ) : ?>
			<div class="notice notice-info"><p><?php echo esc_html( szs_t( 'Desde la petición «%s». Al guardar, la petición queda aceptada.', szs_etiqueta_entidad( $peticion ) ) ); ?></p></div>
		<?php endif; ?>
		<?php if ( empty( $fincas ) ) : ?>
			<div class="notice notice-warning"><p><?php echo esc_html( szs_t( 'Todavía no hay fincas en el servidor. Sincroniza primero desde la app de coordinación para que lleguen.' ) ); ?></p></div>
		<?php endif; ?>
		<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS ) ); ?>">
			<?php wp_nonce_field( 'szs_tareas' ); ?>
			<input type="hidden" name="szs_accion" value="guardar">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $tarea['uid'] ?? '' ); ?>">
			<input type="hidden" name="szs_peticion_uid" value="<?php echo esc_attr( $peticion_uid ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_titulo"><?php echo esc_html( szs_t( 'Tarea' ) ); ?></label></th><td><input type="text" id="szs_titulo" name="szs_titulo" class="regular-text" required list="szs_plantillas_tarea" value="<?php echo esc_attr( $valores['titulo'] ); ?>">
					<datalist id="szs_plantillas_tarea">
						<?php foreach ( array_keys( SZS_PLANTILLAS_TAREA ) as $plantilla ) : ?>
							<option value="<?php echo esc_attr( $plantilla ); ?>"></option>
						<?php endforeach; ?>
					</datalist>
					<p class="description"><?php echo esc_html( szs_t( 'Empieza a escribir para elegir una tarea tipo (alimentación, revisión del vallado, compras…). La periodicidad sugerida se rellena sola si está vacía.' ) ); ?></p>
					<script>
					( function () {
						const periodicidades = <?php echo wp_json_encode( SZS_PLANTILLAS_TAREA ); ?>;
						const titulo = document.getElementById( 'szs_titulo' );
						titulo.addEventListener( 'change', function () {
							const dias = periodicidades[ titulo.value ];
							const repeticion = document.getElementById( 'szs_recurrencia_dias' );
							if ( dias && repeticion && '' === repeticion.value ) {
								repeticion.value = dias;
							}
						} );
					} )();
					</script></td></tr>
				<tr><th><label for="szs_descripcion"><?php echo esc_html( szs_t( 'Descripción' ) ); ?></label></th><td><textarea id="szs_descripcion" name="szs_descripcion" rows="3" class="large-text"><?php echo esc_textarea( $valores['descripcion'] ); ?></textarea></td></tr>
				<tr><th><label for="szs_finca_uid"><?php echo esc_html( szs_t( 'Finca' ) ); ?></label></th><td><?php szs_selector( 'szs_finca_uid', $fincas, $valores['finca_uid'], szs_t( '— Elige —' ) ); ?></td></tr>
				<tr><th><label for="szs_zona_uid"><?php echo esc_html( szs_t( 'Pieza (opcional)' ) ); ?></label></th><td><?php szs_selector( 'szs_zona_uid', $zonas, $valores['zona_uid'] ?? '', szs_t( 'Toda la finca' ) ); ?> <span class="description"><?php echo esc_html( szs_t( 'La parcela, el parque o el cercado donde se hace.' ) ); ?></span></td></tr>
				<tr><th><label for="szs_punto_uid"><?php echo esc_html( szs_t( 'Punto (opcional)' ) ); ?></label></th><td><?php szs_selector( 'szs_punto_uid', $puntos, $valores['punto_uid'], szs_t( 'Ninguno' ) ); ?></td></tr>
				<tr><th><?php echo esc_html( szs_t( 'Responsables' ) ); ?></th><td><?php szs_casillas_responsables( $personas, $elegidas, null === $tarea ); ?></td></tr>
				<tr><th><label for="szs_prioridad"><?php echo esc_html( szs_t( 'Prioridad' ) ); ?></label></th><td><?php szs_selector( 'szs_prioridad', szs_t_opciones( SZS_PRIORIDADES_TAREA ), $valores['prioridad'] ); ?></td></tr>
				<tr><th><label for="szs_estado"><?php echo esc_html( szs_t( 'Estado' ) ); ?></label></th><td><?php szs_selector( 'szs_estado', szs_t_opciones( SZS_ESTADOS_TAREA ), $valores['estado'] ); ?></td></tr>
				<tr><th><label for="szs_fecha"><?php echo esc_html( szs_t( 'Fecha objetivo' ) ); ?></label></th><td><input type="date" id="szs_fecha" name="szs_fecha" value="<?php echo esc_attr( null === $valores['fecha_objetivo_ms'] ? '' : wp_date( 'Y-m-d', intdiv( $valores['fecha_objetivo_ms'], 1000 ) ) ); ?>"></td></tr>
				<tr><th><label for="szs_recurrencia_dias"><?php echo esc_html( szs_t( 'Se repite cada (días)' ) ); ?></label></th><td><input type="number" min="0" id="szs_recurrencia_dias" name="szs_recurrencia_dias" class="small-text" value="<?php echo esc_attr( (string) ( $valores['recurrencia_dias'] ?? '' ) ); ?>"> <span class="description"><?php echo esc_html( szs_t( 'Vacío = tarea puntual. Al marcarla hecha se crea la siguiente.' ) ); ?></span></td></tr>
				<tr><th><label for="szs_coste"><?php echo esc_html( szs_t( 'Coste (€)' ) ); ?></label></th><td><input type="text" id="szs_coste" name="szs_coste" class="small-text" value="<?php echo esc_attr( null === $valores['coste_centimos'] ? '' : number_format( $valores['coste_centimos'] / 100, 2, ',', '' ) ); ?>"></td></tr>
				<?php if ( null !== $tarea ) : ?>
					<tr><th><?php echo esc_html( szs_t( 'Fotos de antes' ) ); ?></th><td><?php szs_pintar_fotos_panel( $tarea['fotos_antes'] ?? array() ); ?></td></tr>
					<tr><th><?php echo esc_html( szs_t( 'Fotos de después' ) ); ?></th><td><?php szs_pintar_fotos_panel( $tarea['fotos_despues'] ?? array() ); ?><p class="description"><?php echo esc_html( szs_t( 'Las fotos se añaden desde la app del móvil.' ) ); ?></p></td></tr>
				<?php endif; ?>
			</table>
			<?php submit_button( null === $tarea ? szs_t( 'Crear tarea' ) : szs_t( 'Guardar cambios' ) ); ?>
			<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS ) ); ?>"><?php echo esc_html( szs_t( 'Volver al listado' ) ); ?></a>
		</form>
	</div>
	<?php
}

/**
 * Casillas para elegir una o varias responsables. En un alta, con dos o
 * más marcadas aparece la pregunta: una tarea compartida o una para cada
 * persona.
 *
 * @param array<string, string> $personas uid => nombre.
 * @param string[]              $elegidas
 */
function szs_casillas_responsables( array $personas, array $elegidas, bool $es_alta ): void {
	?>
	<fieldset id="szs_responsables">
		<?php if ( empty( $personas ) ) : ?>
			<em><?php echo esc_html( szs_t( 'Todavía no hay personas en el espacio.' ) ); ?></em>
		<?php endif; ?>
		<?php foreach ( $personas as $uid => $nombre ) : ?>
			<label style="display:inline-block;margin:0 16px 6px 0;"><input type="checkbox" name="szs_responsables_uids[]" value="<?php echo esc_attr( (string) $uid ); ?>" <?php checked( in_array( (string) $uid, $elegidas, true ) ); ?>> <?php echo esc_html( $nombre ); ?></label>
		<?php endforeach; ?>
	</fieldset>
	<p class="description"><?php echo esc_html( szs_t( 'Sin marcar a nadie, la tarea es general: la ven todas las testers y cualquiera se la puede coger.' ) ); ?></p>
	<?php if ( $es_alta ) : ?>
		<fieldset id="szs_reparto" style="margin-top:10px;padding:8px 12px;border-left:4px solid #b8402a;background:#f6f7f7;">
			<p style="margin:0 0 6px;"><strong><?php echo esc_html( szs_t( 'Has elegido varias personas. ¿Cómo la creo?' ) ); ?></strong></p>
			<label><input type="radio" name="szs_reparto" value="compartida" checked> <?php echo esc_html( szs_t( 'Una tarea compartida' ) ); ?></label>
			<p class="description" style="margin:0 0 6px 24px;"><?php echo esc_html( szs_t( 'Una sola tarea: la ven todas en «Mis tareas», cualquiera puede cambiar el estado y, cuando una la marca hecha, queda hecha para todas.' ) ); ?></p>
			<label><input type="radio" name="szs_reparto" value="cada_persona"> <?php echo esc_html( szs_t( 'Una para cada persona' ) ); ?></label>
			<p class="description" style="margin:0 0 0 24px;"><?php echo esc_html( szs_t( 'Una tarea igual para cada una (mismo sitio, fecha, prioridad y periodicidad), cada una con su propio estado.' ) ); ?></p>
		</fieldset>
		<script>
		( function () {
			const reparto = document.getElementById( 'szs_reparto' );
			const casillas = document.querySelectorAll( '#szs_responsables input[type=checkbox]' );
			const actualizar = function () {
				reparto.style.display = Array.from( casillas ).filter( ( casilla ) => casilla.checked ).length >= 2 ? '' : 'none';
			};
			casillas.forEach( ( casilla ) => casilla.addEventListener( 'change', actualizar ) );
			actualizar();
		} )();
		</script>
	<?php else : ?>
		<p class="description"><?php echo esc_html( szs_t( 'Con varias personas marcadas la tarea es compartida: una sola, con un único estado para todas.' ) ); ?></p>
	<?php endif; ?>
	<?php
}
