<?php
/**
 * Panel · Proyectos y Actividad.
 *
 * - Proyectos de test: cada uno con su persona tester, su estado y las
 *   cuentas del convenio (balance del test y del proyecto, reparto). Desde
 *   aquí se asigna la persona tester y se cierra o reabre el proyecto; el
 *   convenio se edita en `pagina-convenio.php`.
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
				$aviso = array( 'success', szs_t( 'Persona tester asignada. Verá el proyecto en su próxima sincronización.' ) );
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
				$aviso = array( 'success', 'cerrar' === $accion ? szs_t( 'Proyecto cerrado: la persona tester ya no puede apuntar en él.' ) : szs_t( 'Proyecto reabierto.' ) );
			}
		}
	}

	$proyectos = szs_listar_entidades_tipo( 'proyecto' );
	$bienes    = szs_bienes_por_uid();
	$personas  = array();
	foreach ( szs_listar_personas() as $persona ) {
		$personas[ $persona['uid'] ] = $persona['nombre'];
	}
	?>
	<div class="wrap">
		<h1><?php echo esc_html( szs_t( 'Proyectos de test' ) ); ?></h1>
		<p><?php echo szs_t( 'Las cuentas siguen el convenio tester (art. 7): el <strong>balance del test</strong> no incluye amortizaciones y es el que se reparte; el <strong>del proyecto</strong> las incluye (también las del <a href="%s">inventario</a>) y muestra el coste real. Orientativo, no es contabilidad. El convenio de cada proyecto (condiciones, presupuesto, fianza, acompañamiento, incidencias) se carga y edita en <strong>Convenio</strong>; la persona tester lo ve en la app.', esc_url( szs_url_pagina( SZS_PAGINA_INVENTARIO ) ) ); ?></p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<table class="widefat striped">
			<thead><tr><th><?php echo esc_html( szs_t( 'Proyecto' ) ); ?></th><th><?php echo esc_html( szs_t( 'Persona tester' ) ); ?></th><th><?php echo esc_html( szs_t( 'Estado' ) ); ?></th><th><?php echo esc_html( szs_t( 'Balance del test' ) ); ?></th><th><?php echo esc_html( szs_t( 'Balance del proyecto' ) ); ?></th><th><?php echo esc_html( szs_t( 'Reparto (Zunbeltz / tester)' ) ); ?></th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $proyectos ) ) : ?>
				<tr><td colspan="7"><?php echo esc_html( szs_t( 'Todavía no hay proyectos en el servidor. Se crean en la app de coordinación.' ) ); ?></td></tr>
			<?php endif; ?>
			<?php foreach ( $proyectos as $proyecto ) : ?>
				<?php
				$datos   = $proyecto['datos'];
				$hijas   = array_merge( szs_listar_entidades_tipo( 'venta', $proyecto['uid'] ), szs_listar_entidades_tipo( 'apunte', $proyecto['uid'] ), szs_listar_entidades_tipo( 'uso_bien', $proyecto['uid'] ) );
				$balance = szs_balance_convenio( $datos, $hijas, $bienes, szs_ahora_ms(), wp_timezone_string() );
				$cerrado = 'cerrado' === ( $datos['estado'] ?? 'abierto' );
				?>
				<tr>
					<td><strong><?php echo esc_html( szs_etiqueta_entidad( $proyecto ) ); ?></strong><br><small><?php echo esc_html( (string) ( $datos['actividad'] ?? '' ) ); ?></small></td>
					<td>
						<form method="post" style="display:flex;gap:4px;">
							<?php wp_nonce_field( 'szs_proyectos' ); ?>
							<input type="hidden" name="szs_accion" value="asignar">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $proyecto['uid'] ); ?>">
							<?php szs_selector( 'szs_persona_uid', $personas, (string) ( $datos['persona_uid'] ?? '' ), szs_t( 'Sin asignar' ) ); ?>
							<button class="button button-small"><?php echo esc_html( szs_t( 'Asignar' ) ); ?></button>
						</form>
					</td>
					<td><?php echo esc_html( $cerrado ? szs_t( 'Cerrado el %s', szs_fecha_ms( (int) ( $datos['cerrado_ms'] ?? 0 ) ) ) : szs_t( 'Abierto' ) ); ?></td>
					<td><?php echo esc_html( szs_euros( $balance['balance_test'] ) ); ?></td>
					<td><?php echo esc_html( szs_euros( $balance['balance_proyecto'] ) ); ?></td>
					<td><?php echo esc_html( szs_euros( $balance['parte_zunbeltz'] ) . ' / ' . szs_euros( $balance['parte_tester'] ) ); ?></td>
					<td>
						<a class="button button-small" href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) ); ?>"><?php echo esc_html( szs_t( 'Convenio' ) ); ?></a>
						<a class="button button-small" href="<?php echo esc_url( szs_url_alimentacion_csv( $proyecto['uid'] ) ); ?>"><?php echo esc_html( szs_t( 'Alimentación (Excel)' ) ); ?></a>
						<form method="post" style="margin-top:4px;">
							<?php wp_nonce_field( 'szs_proyectos' ); ?>
							<input type="hidden" name="szs_accion" value="<?php echo $cerrado ? 'reabrir' : 'cerrar'; ?>">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $proyecto['uid'] ); ?>">
							<button class="button button-small"<?php echo $cerrado ? '' : ' onclick="return confirm(\'' . esc_js( szs_t( '¿Cerrar el proyecto? La persona tester ya no podrá apuntar en él y los informes saldrán como versión definitiva.' ) ) . '\');"'; ?>><?php echo esc_html( $cerrado ? szs_t( 'Reabrir' ) : szs_t( 'Cerrar' ) ); ?></button>
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
		'tarea'                   => szs_t( 'la tarea' ),
		'punto'                   => szs_t( 'el punto' ),
		'finca'                   => szs_t( 'la finca' ),
		'zona'                    => szs_t( 'la zona' ),
		'proyecto'                => szs_t( 'el proyecto' ),
		'apunte'                  => szs_t( 'el apunte' ),
		'venta'                   => szs_t( 'la venta' ),
		'registro_actividad'      => szs_t( 'el registro' ),
		'validacion'              => szs_t( 'la prueba de producto' ),
		'peticion'                => szs_t( 'la petición' ),
		'aviso'                   => szs_t( 'el aviso' ),
		'partida_presupuesto'     => szs_t( 'la partida de presupuesto' ),
		'movimiento_fianza'       => szs_t( 'el movimiento de fianza' ),
		'acompanamiento'          => szs_t( 'la actividad de acompañamiento' ),
		'incidencia_cumplimiento' => szs_t( 'la incidencia' ),
		'bien_amortizable'        => szs_t( 'el bien del inventario' ),
		'uso_bien'                => szs_t( 'el uso de un bien' ),
		'lote_ganado'             => szs_t( 'el lote' ),
		'animal'                  => szs_t( 'el animal' ),
		'movimiento_ganado'       => szs_t( 'un movimiento de ganado' ),
		'evento_ganado'           => szs_t( 'un manejo de ganado' ),
	);
	$cosa = $tipos[ $entrada['tipo'] ] ?? szs_t( 'un dato' );
	if ( '' !== $entrada['etiqueta'] ) {
		// En euskera la etiqueta va delante: «Corral móvil» puntua.
		$cosa = szs_t( '%1$s «%2$s»', $cosa, $entrada['etiqueta'] );
	}
	$quien = '' === $entrada['persona_nombre'] ? szs_t( 'Alguien' ) : $entrada['persona_nombre'];
	$frase = match ( $entrada['accion'] ) {
		'crear'   => szs_t( '%1$s ha añadido %2$s', $quien, $cosa ),
		'borrar'  => szs_t( '%1$s ha borrado %2$s', $quien, $cosa ),
		'mover'   => szs_t( '%1$s ha movido %2$s', $quien, $cosa ),
		'estado'  => szs_t( '%1$s ha marcado %2$s como «%3$s»', $quien, $cosa, isset( SZS_ESTADOS_TAREA[ $entrada['detalle'] ] ) ? szs_t( SZS_ESTADOS_TAREA[ $entrada['detalle'] ] ) : $entrada['detalle'] ),
		'asignar' => '' === $entrada['detalle'] ? szs_t( '%1$s ha dejado sin asignar %2$s', $quien, $cosa ) : szs_t( '%1$s ha asignado %2$s a %3$s', $quien, $cosa, $entrada['detalle'] ),
		default   => szs_t( '%1$s ha cambiado %2$s', $quien, $cosa ),
	};
	return '' === $entrada['contexto'] ? $frase : szs_t( '%1$s en %2$s', $frase, $entrada['contexto'] );
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
		<h1><?php echo esc_html( szs_t( 'Actividad del espacio' ) ); ?></h1>
		<p><?php echo esc_html( szs_t( 'Lo que cada persona ha hecho, desde la app o desde esta oficina. Lo escribe el servidor al aceptar cada cambio.' ) ); ?></p>
		<table class="widefat striped">
			<thead><tr><th style="width:150px;"><?php echo esc_html( szs_t( 'Cuándo' ) ); ?></th><th><?php echo esc_html( szs_t( 'Qué' ) ); ?></th><th style="width:90px;"><?php echo esc_html( szs_t( 'Desde' ) ); ?></th></tr></thead>
			<tbody>
			<?php if ( empty( $filas ) ) : ?>
				<tr><td colspan="3"><?php echo esc_html( szs_t( 'Todavía no hay actividad.' ) ); ?></td></tr>
			<?php endif; ?>
			<?php foreach ( $filas as $fila ) : ?>
				<?php $entrada = szs_actividad_a_json( $fila ); ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( $entrada['momento_ms'], 'd/m/Y H:i' ) ); ?></td>
					<td><?php echo esc_html( szs_describir_actividad( $entrada ) ); ?></td>
					<td><?php echo esc_html( 'panel' === $entrada['origen'] ? szs_t( 'Oficina' ) : szs_t( 'App' ) ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php if ( $total > $por_pagina ) : ?>
			<p>
				<?php if ( $pagina > 1 ) : ?><a class="button" href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ACTIVIDAD, array( 'paged' => $pagina - 1 ) ) ); ?>"><?php echo esc_html( szs_t( '← Más recientes' ) ); ?></a><?php endif; ?>
				<?php if ( $pagina * $por_pagina < $total ) : ?><a class="button" href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ACTIVIDAD, array( 'paged' => $pagina + 1 ) ) ); ?>"><?php echo esc_html( szs_t( 'Más antiguas →' ) ); ?></a><?php endif; ?>
			</p>
		<?php endif; ?>
	</div>
	<?php
}
