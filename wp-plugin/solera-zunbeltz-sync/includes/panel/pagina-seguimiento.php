<?php
/**
 * Panel · Proyectos y Actividad.
 *
 * - Proyectos de test: cada uno con su persona tester, su estado y las
 *   cuentas del convenio (balance del test y del proyecto, reparto). Desde
 *   aquí se asigna la persona tester y se cierra o reabre el proyecto.
 * - Actividad: la huella de quién ha hecho qué en el espacio.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function szs_pagina_proyectos(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = null;
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_proyectos' );
		$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
		$uid    = szs_campo_post( 'szs_uid' );
		if ( null !== szs_obtener_entidad( 'proyecto', $uid ) ) {
			if ( 'asignar' === $accion ) {
				$persona_uid = szs_campo_post( 'szs_persona_uid' );
				$nombres     = szs_nombres_personas();
				szs_guardar_entidad_desde_panel(
					'proyecto',
					$uid,
					array(
						'persona_uid' => $persona_uid,
						'persona'     => $nombres[ $persona_uid ] ?? '',
					)
				);
				$aviso = array( 'success', 'Persona tester asignada. Verá el proyecto en su próxima sincronización.' );
			}
			if ( in_array( $accion, array( 'cerrar', 'reabrir' ), true ) ) {
				szs_guardar_entidad_desde_panel(
					'proyecto',
					$uid,
					array(
						'estado'     => 'cerrar' === $accion ? 'cerrado' : 'abierto',
						'cerrado_ms' => 'cerrar' === $accion ? szs_ahora_ms() : null,
					)
				);
				$aviso = array( 'success', 'cerrar' === $accion ? 'Proyecto cerrado: la persona tester ya no puede apuntar en él.' : 'Proyecto reabierto.' );
			}
		}
	}

	$proyectos = szs_listar_entidades_tipo( 'proyecto' );
	$personas  = array();
	foreach ( szs_listar_personas() as $persona ) {
		$personas[ $persona['uid'] ] = $persona['nombre'];
	}
	?>
	<div class="wrap">
		<h1>Proyectos de test</h1>
		<p>Las cuentas siguen el convenio tester (art. 7): el <strong>balance del test</strong> no incluye amortizaciones y es el que se reparte; el <strong>del proyecto</strong> las incluye y muestra el coste real. Orientativo, no es contabilidad. El detalle (presupuesto, fianza, acompañamiento, incidencias) está en la app, en la pantalla «Convenio» de cada proyecto.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<table class="widefat striped">
			<thead><tr><th>Proyecto</th><th>Persona tester</th><th>Estado</th><th>Balance del test</th><th>Balance del proyecto</th><th>Reparto (Zunbeltz / tester)</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $proyectos ) ) : ?>
				<tr><td colspan="7">Todavía no hay proyectos en el servidor. Se crean en la app de coordinación.</td></tr>
			<?php endif; ?>
			<?php foreach ( $proyectos as $proyecto ) : ?>
				<?php
				$datos   = $proyecto['datos'];
				$hijas   = array_merge( szs_listar_entidades_tipo( 'venta', $proyecto['uid'] ), szs_listar_entidades_tipo( 'apunte', $proyecto['uid'] ) );
				$balance = szs_balance_convenio( $datos, $hijas );
				$cerrado = 'cerrado' === ( $datos['estado'] ?? 'abierto' );
				?>
				<tr>
					<td><strong><?php echo esc_html( szs_etiqueta_entidad( $proyecto ) ); ?></strong><br><small><?php echo esc_html( (string) ( $datos['actividad'] ?? '' ) ); ?></small></td>
					<td>
						<form method="post" style="display:flex;gap:4px;">
							<?php wp_nonce_field( 'szs_proyectos' ); ?>
							<input type="hidden" name="szs_accion" value="asignar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $proyecto['uid'] ); ?>">
							<?php szs_selector( 'szs_persona_uid', $personas, (string) ( $datos['persona_uid'] ?? '' ), 'Sin asignar' ); ?>
							<button class="button button-small">Asignar</button>
						</form>
					</td>
					<td><?php echo $cerrado ? 'Cerrado el ' . esc_html( szs_fecha_ms( (int) ( $datos['cerrado_ms'] ?? 0 ) ) ) : 'Abierto'; ?></td>
					<td><?php echo esc_html( szs_euros( $balance['balance_test'] ) ); ?></td>
					<td><?php echo esc_html( szs_euros( $balance['balance_proyecto'] ) ); ?></td>
					<td><?php echo esc_html( szs_euros( $balance['parte_zunbeltz'] ) . ' / ' . szs_euros( $balance['parte_tester'] ) ); ?></td>
					<td>
						<a class="button button-small" href="<?php echo esc_url( szs_url_alimentacion_csv( $proyecto['uid'] ) ); ?>">Alimentación (Excel)</a>
						<form method="post" style="margin-top:4px;">
							<?php wp_nonce_field( 'szs_proyectos' ); ?>
							<input type="hidden" name="szs_accion" value="<?php echo $cerrado ? 'reabrir' : 'cerrar'; ?>">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $proyecto['uid'] ); ?>">
							<button class="button button-small"<?php echo $cerrado ? '' : " onclick=\"return confirm('¿Cerrar el proyecto? La persona tester ya no podrá apuntar en él y los informes saldrán como versión definitiva.');\""; ?>><?php echo $cerrado ? 'Reabrir' : 'Cerrar'; ?></button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
	</div>
	<?php
}

/** «Ane ha movido el punto "Corral móvil" en Zunbeltz». */
function szs_describir_actividad( array $entrada ): string {
	$tipos  = array(
		'tarea'                   => 'la tarea',
		'punto'                   => 'el punto',
		'finca'                   => 'la finca',
		'zona'                    => 'la zona',
		'proyecto'                => 'el proyecto',
		'apunte'                  => 'el apunte',
		'venta'                   => 'la venta',
		'registro_actividad'      => 'el registro',
		'validacion'              => 'la prueba de producto',
		'peticion'                => 'la petición',
		'aviso'                   => 'el aviso',
		'partida_presupuesto'     => 'la partida de presupuesto',
		'movimiento_fianza'       => 'el movimiento de fianza',
		'acompanamiento'          => 'la actividad de acompañamiento',
		'incidencia_cumplimiento' => 'la incidencia',
	);
	$cosa   = ( $tipos[ $entrada['tipo'] ] ?? 'un dato' ) . ( '' === $entrada['etiqueta'] ? '' : ' «' . $entrada['etiqueta'] . '»' );
	$quien  = '' === $entrada['persona_nombre'] ? 'Alguien' : $entrada['persona_nombre'];
	$frase  = match ( $entrada['accion'] ) {
		'crear'   => "{$quien} ha añadido {$cosa}",
		'borrar'  => "{$quien} ha borrado {$cosa}",
		'mover'   => "{$quien} ha movido {$cosa}",
		'estado'  => "{$quien} ha marcado {$cosa} como «" . ( SZS_ESTADOS_TAREA[ $entrada['detalle'] ] ?? $entrada['detalle'] ) . '»',
		'asignar' => '' === $entrada['detalle'] ? "{$quien} ha dejado sin asignar {$cosa}" : "{$quien} ha asignado {$cosa} a {$entrada['detalle']}",
		default   => "{$quien} ha cambiado {$cosa}",
	};
	return $frase . ( '' === $entrada['contexto'] ? '' : " en {$entrada['contexto']}" );
}

function szs_pagina_actividad(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	global $wpdb;
	$tabla     = $wpdb->prefix . SZS_TABLA_ACTIVIDAD;
	$por_pagina = 100;
	$pagina    = max( 1, (int) szs_campo_get( 'paged', '1' ) );
	$total     = (int) $wpdb->get_var( "SELECT COUNT(*) FROM {$tabla}" );
	$filas     = (array) $wpdb->get_results(
		$wpdb->prepare( "SELECT * FROM {$tabla} ORDER BY id DESC LIMIT %d OFFSET %d", $por_pagina, ( $pagina - 1 ) * $por_pagina ),
		ARRAY_A
	);
	?>
	<div class="wrap">
		<h1>Actividad del espacio</h1>
		<p>Lo que cada persona ha hecho, desde la app o desde esta oficina. Lo escribe el servidor al aceptar cada cambio.</p>
		<table class="widefat striped">
			<thead><tr><th style="width:150px;">Cuándo</th><th>Qué</th><th style="width:90px;">Desde</th></tr></thead>
			<tbody>
			<?php if ( empty( $filas ) ) : ?>
				<tr><td colspan="3">Todavía no hay actividad.</td></tr>
			<?php endif; ?>
			<?php foreach ( $filas as $fila ) : ?>
				<?php $entrada = szs_actividad_a_json( $fila ); ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( $entrada['momento_ms'], 'd/m/Y H:i' ) ); ?></td>
					<td><?php echo esc_html( szs_describir_actividad( $entrada ) ); ?></td>
					<td><?php echo 'panel' === $entrada['origen'] ? 'Oficina' : 'App'; ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php if ( $total > $por_pagina ) : ?>
			<p>
				<?php if ( $pagina > 1 ) : ?><a class="button" href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ACTIVIDAD, array( 'paged' => $pagina - 1 ) ) ); ?>">← Más recientes</a><?php endif; ?>
				<?php if ( $pagina * $por_pagina < $total ) : ?><a class="button" href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ACTIVIDAD, array( 'paged' => $pagina + 1 ) ) ); ?>">Más antiguas →</a><?php endif; ?>
			</p>
		<?php endif; ?>
	</div>
	<?php
}
