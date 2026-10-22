<?php
/**
 * Panel · Inventario de amortizaciones.
 *
 * Como la hoja «Listado-amortización» de Zunbeltz: cada bien (aprisco,
 * corral móvil, abrevaderos…) con su precio, unidades, IVA y vida útil, y
 * qué bienes usa cada proyecto. La cuota (mensual × meses del test ×
 * parte imputada) se calcula sola (`szs_cuota_uso_bien`) y entra en el
 * balance del proyecto. Lo que se cambia aquí llega a la app al
 * sincronizar, y lo que coordinación apunta en la app aparece aquí.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PAGINA_INVENTARIO = 'solera-zunbeltz-inventario';
// SZS_ESPECIES_GANADO viene de includes/catalogos-ganado.php (generado desde la app).
const SZS_GRUPOS_BIEN       = array(
	'instalaciones'     => 'Instalaciones',
	'material_ganadero' => 'Material ganadero',
	'adecuaciones'      => 'Adecuaciones de finca',
);

add_action( 'admin_menu', 'szs_registrar_pagina_inventario', 16 );

function szs_registrar_pagina_inventario(): void {
	add_submenu_page( SZS_PAGINA_INICIO, 'Inventario de amortizaciones', 'Inventario', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_INVENTARIO, 'szs_pagina_inventario' );
}

/** `datos` de cada bien amortizable (no borrado) por uid. */
function szs_bienes_por_uid(): array {
	$bienes = array();
	foreach ( szs_listar_entidades_tipo( 'bien_amortizable' ) as $bien ) {
		$bienes[ $bien['uid'] ] = $bien['datos'];
	}
	return $bienes;
}

/** Lo que cuesta un bien con IVA, como en la app (`totalCentimos`). */
function szs_total_bien( array $bien ): int {
	return (int) round( (int) ( $bien['precio_unidad_centimos'] ?? 0 ) * (float) ( $bien['unidades'] ?? 1 ) * ( 100 + (int) ( $bien['iva_porcentaje'] ?? 21 ) ) / 100 );
}

/** «2» o «2,5». */
function szs_numero_legible( float $numero ): string {
	return floor( $numero ) === $numero ? (string) (int) $numero : rtrim( rtrim( number_format( $numero, 2, ',', '' ), '0' ), ',' );
}

function szs_procesar_inventario(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_inventario' );
	$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	$uid    = szs_campo_post( 'szs_uid' );

	if ( 'borrar_bien' === $accion ) {
		// Con el bien se van sus usos: sin bien no hay cuota que calcular,
		// y la app los borraría igual (cascada).
		foreach ( szs_listar_entidades_tipo( 'uso_bien' ) as $uso ) {
			if ( ( $uso['datos']['bien_uid'] ?? '' ) === $uid ) {
				szs_borrar_entidad_desde_panel( 'uso_bien', $uso['uid'] );
			}
		}
		return szs_borrar_entidad_desde_panel( 'bien_amortizable', $uid ) ? array( 'success', 'Bien borrado, y su uso en los proyectos.' ) : null;
	}
	if ( 'guardar_bien' === $accion ) {
		$nombre    = szs_campo_post( 'szs_nombre' );
		$precio    = szs_centimos_desde_texto( szs_campo_post( 'szs_precio' ) );
		$unidades  = (float) str_replace( ',', '.', szs_campo_post( 'szs_unidades', '1' ) );
		$vida_util = (int) szs_campo_post( 'szs_vida_util', '72' );
		$grupo     = szs_campo_post( 'szs_grupo', 'material_ganadero' );
		$especie   = szs_campo_post( 'szs_especie' );
		if ( '' === $nombre || null === $precio || $precio <= 0 || $unidades <= 0 || $vida_util < 1 || ! isset( SZS_GRUPOS_BIEN[ $grupo ] ) ) {
			return array( 'error', 'Faltan el nombre, el precio, las unidades o la vida útil (al menos un mes).' );
		}
		szs_guardar_entidad_desde_panel(
			'bien_amortizable',
			'' === $uid ? szs_nuevo_uid() : $uid,
			array(
				'nombre'                 => $nombre,
				'grupo'                  => $grupo,
				'especie'                => isset( SZS_ESPECIES_GANADO[ $especie ] ) ? $especie : '',
				'precio_unidad_centimos' => $precio,
				'unidades'               => $unidades,
				'iva_porcentaje'         => (int) szs_campo_post( 'szs_iva', '21' ),
				'vida_util_meses'        => $vida_util,
				'notas'                  => szs_texto_largo_post( 'szs_notas' ),
			)
		);
		return array( 'success', 'Guardado. La app lo verá al sincronizar.' );
	}
	if ( 'borrar_uso' === $accion ) {
		return szs_borrar_entidad_desde_panel( 'uso_bien', $uid ) ? array( 'success', 'Quitado del proyecto.' ) : null;
	}
	if ( 'guardar_uso' === $accion ) {
		$proyecto_uid = szs_campo_post( 'szs_proyecto_uid' );
		$bien_uid     = szs_campo_post( 'szs_bien_uid' );
		if ( null === szs_obtener_entidad( 'proyecto', $proyecto_uid ) || null === szs_obtener_entidad( 'bien_amortizable', $bien_uid ) ) {
			return array( 'error', 'Elige el proyecto y el bien.' );
		}
		$porcentaje = max( 1, min( 100, (int) szs_campo_post( 'szs_porcentaje', '100' ) ) );
		$meses      = max( 0.0, (float) str_replace( ',', '.', szs_campo_post( 'szs_meses', '0' ) ) );
		szs_guardar_entidad_desde_panel(
			'uso_bien',
			szs_nuevo_uid(),
			array(
				'bien_uid'              => $bien_uid,
				'imputacion_porcentaje' => $porcentaje,
				'duracion_meses'        => $meses,
				'notas'                 => '',
			),
			$proyecto_uid
		);
		return array( 'success', 'Añadido al proyecto.' );
	}
	return null;
}

function szs_pagina_inventario(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso  = szs_procesar_inventario();
	$bienes = szs_listar_entidades_tipo( 'bien_amortizable' );
	usort(
		$bienes,
		static fn( array $a, array $b ): int => array( $a['datos']['grupo'] ?? '', strtolower( (string) ( $a['datos']['nombre'] ?? '' ) ) ) <=> array( $b['datos']['grupo'] ?? '', strtolower( (string) ( $b['datos']['nombre'] ?? '' ) ) )
	);
	$bienes_por_uid = array();
	foreach ( $bienes as $bien ) {
		$bienes_por_uid[ $bien['uid'] ] = $bien['datos'];
	}
	$proyectos = szs_listar_entidades_tipo( 'proyecto' );
	$editando  = szs_obtener_entidad( 'bien_amortizable', szs_campo_get( 'uid' ) );
	$valores   = $editando['datos'] ?? array();
	$ahora_ms  = szs_ahora_ms();
	$zona      = wp_timezone_string();
	?>
	<div class="wrap">
		<h1>Inventario de amortizaciones</h1>
		<p style="max-width:760px;">Los bienes que se amortizan y qué parte carga cada proyecto. La cuota mensual es el total con IVA entre la vida útil; a cada proyecto se le imputa <strong>cuota mensual × meses del test × parte</strong>. Cuenta en el balance del proyecto (coste real), no en el del test, y la asume Zunbeltz. Orientativo, no es contabilidad.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<h2>Bienes</h2>
		<table class="widefat striped">
			<thead><tr><th>Bien</th><th>Grupo</th><th>Especie</th><th>Precio/ud</th><th>Uds</th><th>IVA</th><th>Total</th><th>Vida útil</th><th>Cuota mensual</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $bienes ) ) : ?>
				<tr><td colspan="10">Todavía no hay bienes en el inventario.</td></tr>
			<?php endif; ?>
			<?php foreach ( $bienes as $bien ) : ?>
				<?php
				$datos = $bien['datos'];
				$total = szs_total_bien( $datos );
				$vida  = (int) ( $datos['vida_util_meses'] ?? 0 );
				?>
				<tr>
					<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_INVENTARIO, array( 'uid' => $bien['uid'] ) ) ); ?>"><strong><?php echo esc_html( (string) ( $datos['nombre'] ?? '' ) ); ?></strong></a></td>
					<td><?php echo esc_html( SZS_GRUPOS_BIEN[ $datos['grupo'] ?? '' ] ?? (string) ( $datos['grupo'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( SZS_ESPECIES_GANADO[ $datos['especie'] ?? '' ] ?? 'Común' ); ?></td>
					<td><?php echo esc_html( szs_euros( (int) ( $datos['precio_unidad_centimos'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( szs_numero_legible( (float) ( $datos['unidades'] ?? 1 ) ) ); ?></td>
					<td><?php echo esc_html( (string) (int) ( $datos['iva_porcentaje'] ?? 21 ) ); ?> %</td>
					<td><?php echo esc_html( szs_euros( $total ) ); ?></td>
					<td><?php echo esc_html( (string) $vida ); ?> meses</td>
					<td><?php echo esc_html( szs_euros( $vida > 0 ? (int) round( $total / $vida ) : 0 ) ); ?></td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_inventario' ); ?>
							<input type="hidden" name="szs_accion" value="borrar_bien">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $bien['uid'] ); ?>">
							<button class="button button-small button-link-delete" onclick="return confirm('¿Borrar el bien? También se quita de los proyectos que lo usan.');">Borrar</button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2><?php echo null === $editando ? 'Añadir bien' : 'Editar bien'; ?></h2>
		<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_INVENTARIO ) ); ?>">
			<?php wp_nonce_field( 'szs_inventario' ); ?>
			<input type="hidden" name="szs_accion" value="guardar_bien">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $editando['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nombre">Nombre</label></th><td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" required placeholder="Corral móvil" value="<?php echo esc_attr( (string) ( $valores['nombre'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_grupo">Grupo</label></th><td><?php szs_selector( 'szs_grupo', SZS_GRUPOS_BIEN, (string) ( $valores['grupo'] ?? 'material_ganadero' ) ); ?></td></tr>
				<tr><th><label for="szs_especie">Especie</label></th><td><?php szs_selector( 'szs_especie', SZS_ESPECIES_GANADO, (string) ( $valores['especie'] ?? '' ), 'Cualquiera (común)' ); ?></td></tr>
				<tr><th><label for="szs_precio">Precio por unidad, sin IVA (€)</label></th><td><input type="text" id="szs_precio" name="szs_precio" class="small-text" required placeholder="1.392,00" value="<?php echo esc_attr( isset( $valores['precio_unidad_centimos'] ) ? number_format( (int) $valores['precio_unidad_centimos'] / 100, 2, ',', '.' ) : '' ); ?>"></td></tr>
				<tr><th><label for="szs_unidades">Unidades</label></th><td><input type="text" id="szs_unidades" name="szs_unidades" class="small-text" value="<?php echo esc_attr( szs_numero_legible( (float) ( $valores['unidades'] ?? 1 ) ) ); ?>"></td></tr>
				<tr><th><label for="szs_iva">IVA</label></th><td><?php szs_selector( 'szs_iva', array( 0 => '0 %', 4 => '4 %', 10 => '10 %', 21 => '21 %' ), (string) (int) ( $valores['iva_porcentaje'] ?? 21 ) ); ?> <span class="description">La hoja de Zunbeltz amortiza con el IVA incluido; con 0 % se amortiza la base.</span></td></tr>
				<tr><th><label for="szs_vida_util">Vida útil (meses)</label></th><td><input type="number" min="1" id="szs_vida_util" name="szs_vida_util" class="small-text" value="<?php echo esc_attr( (string) (int) ( $valores['vida_util_meses'] ?? 72 ) ); ?>"> <span class="description">Hacienda: edificaciones 240, instalaciones 120, material ganadero 72.</span></td></tr>
				<tr><th><label for="szs_notas">Notas</label></th><td><textarea id="szs_notas" name="szs_notas" rows="2" class="large-text"><?php echo esc_textarea( (string) ( $valores['notas'] ?? '' ) ); ?></textarea></td></tr>
			</table>
			<?php submit_button( null === $editando ? 'Añadir' : 'Guardar cambios' ); ?>
		</form>

		<h2>Uso por proyecto</h2>
		<?php foreach ( $proyectos as $proyecto ) : ?>
			<?php
			$usos = szs_listar_entidades_tipo( 'uso_bien', $proyecto['uid'] );
			if ( empty( $usos ) ) {
				continue;
			}
			$total_proyecto = 0;
			?>
			<h3><?php echo esc_html( szs_etiqueta_entidad( $proyecto ) ); ?></h3>
			<table class="widefat striped" style="max-width:960px;">
				<thead><tr><th>Bien</th><th>Parte</th><th>Meses</th><th>Cuota imputada</th><th></th></tr></thead>
				<tbody>
				<?php foreach ( $usos as $uso ) : ?>
					<?php
					$bien = $bienes_por_uid[ $uso['datos']['bien_uid'] ?? '' ] ?? null;
					if ( null === $bien ) {
						continue;
					}
					$cuota           = szs_cuota_uso_bien( $bien, $uso['datos'], $proyecto['datos'], $ahora_ms, $zona );
					$total_proyecto += $cuota;
					$meses_propios   = (float) ( $uso['datos']['duracion_meses'] ?? 0 );
					?>
					<tr>
						<td><?php echo esc_html( (string) ( $bien['nombre'] ?? '' ) ); ?></td>
						<td><?php echo esc_html( (string) (int) ( $uso['datos']['imputacion_porcentaje'] ?? 100 ) ); ?> %</td>
						<td><?php echo $meses_propios > 0 ? esc_html( szs_numero_legible( $meses_propios ) ) : 'Los del test'; ?></td>
						<td><?php echo esc_html( szs_euros( $cuota ) ); ?></td>
						<td>
							<form method="post">
								<?php wp_nonce_field( 'szs_inventario' ); ?>
								<input type="hidden" name="szs_accion" value="borrar_uso">
								<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $uso['uid'] ); ?>">
								<button class="button button-small button-link-delete">Quitar</button>
							</form>
						</td>
					</tr>
				<?php endforeach; ?>
				<tr><td colspan="3"><strong>Total imputado</strong></td><td><strong><?php echo esc_html( szs_euros( $total_proyecto ) ); ?></strong></td><td></td></tr>
				</tbody>
			</table>
		<?php endforeach; ?>

		<?php if ( ! empty( $bienes ) && ! empty( $proyectos ) ) : ?>
			<h3>Añadir un bien a un proyecto</h3>
			<form method="post" action="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_INVENTARIO ) ); ?>">
				<?php wp_nonce_field( 'szs_inventario' ); ?>
				<input type="hidden" name="szs_accion" value="guardar_uso">
				<table class="form-table" role="presentation">
					<tr><th><label for="szs_proyecto_uid">Proyecto</label></th><td><?php szs_selector( 'szs_proyecto_uid', array_combine( array_column( $proyectos, 'uid' ), array_map( 'szs_etiqueta_entidad', $proyectos ) ), '' ); ?></td></tr>
					<tr><th><label for="szs_bien_uid">Bien</label></th><td><?php szs_selector( 'szs_bien_uid', array_combine( array_column( $bienes, 'uid' ), array_map( 'szs_etiqueta_entidad', $bienes ) ), '' ); ?></td></tr>
					<tr><th><label for="szs_porcentaje">Parte que se imputa (%)</label></th><td><input type="number" min="1" max="100" id="szs_porcentaje" name="szs_porcentaje" class="small-text" value="100"> <span class="description">Uno de dos corrales móviles: 50 %.</span></td></tr>
					<tr><th><label for="szs_meses">Meses</label></th><td><input type="text" id="szs_meses" name="szs_meses" class="small-text" placeholder="0"> <span class="description">Vacío o 0: lo que dura el test (fechas del proyecto).</span></td></tr>
				</table>
				<?php submit_button( 'Añadir al proyecto' ); ?>
			</form>
		<?php endif; ?>
	</div>
	<?php
}
