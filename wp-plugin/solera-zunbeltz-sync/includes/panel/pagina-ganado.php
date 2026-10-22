<?php
/**
 * Panel · Ganado: los rebaños tal como llegan de los móviles. Dónde está
 * cada uno, cabezas, UGM, supresión vigente y, en ecológico, cuántos
 * tratamientos lleva en 12 meses. Ficha de cada rebaño con sus animales,
 * movimientos y manejo; buscador por crotal; y el censo, los movimientos y
 * los tratamientos en Excel (CSV).
 *
 * Solo lectura: el ganado se apunta en la app (también sin cobertura).
 * Cálculos en `logica-ganado.php` (probados en tests/test_ganado.php).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PAGINA_GANADO = 'solera-zunbeltz-ganado';

add_action( 'admin_menu', 'szs_registrar_pagina_ganado', 12 );
add_action( 'admin_init', 'szs_exportar_ganado_csv' );

function szs_registrar_pagina_ganado(): void {
	add_submenu_page( SZS_PAGINA_INICIO, 'Ganado', 'Ganado', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_GANADO, 'szs_pagina_ganado' );
}

/**
 * Todo el ganado del servidor, agrupado.
 *
 * @return array{lotes: array, animales: array, movimientos: array, eventos: array, zonas: array<string,string>}
 */
function szs_datos_ganado(): array {
	$zonas = array();
	foreach ( szs_listar_entidades_tipo( 'zona' ) as $zona ) {
		$zonas[ $zona['uid'] ] = szs_etiqueta_entidad( $zona );
	}
	return array(
		'lotes'       => szs_listar_entidades_tipo( 'lote_ganado' ),
		'animales'    => szs_listar_entidades_tipo( 'animal' ),
		'movimientos' => szs_listar_entidades_tipo( 'movimiento_ganado' ),
		'eventos'     => szs_listar_entidades_tipo( 'evento_ganado' ),
		'zonas'       => $zonas,
	);
}

/** Superficie de cada pieza (la oficial si la hay), por uid. */
function szs_superficies_zonas(): array {
	$superficies = array();
	foreach ( szs_listar_entidades_tipo( 'zona' ) as $zona ) {
		$oficial = (float) ( $zona['datos']['superficie_ha_oficial'] ?? 0 );
		$superficies[ $zona['uid'] ] = $oficial > 0 ? $oficial : (float) ( $zona['datos']['superficie_ha_calculada'] ?? 0 );
	}
	return $superficies;
}

/** Los de un rebaño. */
function szs_del_lote( array $entidades, string $lote_uid ): array {
	return array_values( array_filter( $entidades, static fn( array $e ): bool => ( $e['datos']['lote_uid'] ?? '' ) === $lote_uid ) );
}

/** Eventos de un rebaño: los suyos y los de sus animales. */
function szs_eventos_del_lote( array $datos, string $lote_uid ): array {
	$animales = array_flip( array_column( szs_del_lote( $datos['animales'], $lote_uid ), 'uid' ) );
	return array_values(
		array_filter(
			$datos['eventos'],
			static fn( array $e ): bool => ( '' === (string) ( $e['datos']['animal_uid'] ?? '' ) && ( $e['datos']['lote_uid'] ?? '' ) === $lote_uid )
				|| isset( $animales[ $e['datos']['animal_uid'] ?? '' ] )
		)
	);
}

/** «Pasillo», «Fuera: Urbasa» o «—». */
function szs_texto_ubicacion( ?array $ubicacion, array $zonas ): string {
	if ( null === $ubicacion ) {
		return '—';
	}
	if ( isset( $ubicacion['fuera'] ) ) {
		return 'Fuera del espacio' . ( '' !== $ubicacion['fuera'] ? ': ' . $ubicacion['fuera'] : '' );
	}
	return $zonas[ $ubicacion['zona_uid'] ] ?? '—';
}

/** «hasta el 24/10 (carne)» o ''. */
function szs_texto_supresion( array $supresion ): string {
	$partes = array();
	foreach ( array( 'carne', 'leche' ) as $de ) {
		if ( null !== $supresion[ $de ] ) {
			$partes[] = $de . ': libre el ' . DateTimeImmutable::createFromFormat( 'Y-m-d', $supresion[ $de ] )->format( 'd/m/Y' );
		}
	}
	return implode( ' · ', $partes );
}

function szs_numero_es( float $numero, int $decimales = 2 ): string {
	return number_format( $numero, $decimales, ',', '.' );
}

/** «Pasillo → Los Avellanos». */
function szs_trayecto_movimiento( array $movimiento, array $zonas ): string {
	$datos   = $movimiento['datos'];
	$externo = '' !== (string) ( $datos['destino_externo'] ?? '' ) ? (string) $datos['destino_externo'] : 'fuera del espacio';
	$origen  = 'entrada' === ( $datos['tipo'] ?? '' ) ? $externo : ( $zonas[ $datos['zona_origen_uid'] ?? '' ] ?? '—' );
	$destino = 'salida' === ( $datos['tipo'] ?? '' ) ? $externo : ( $zonas[ $datos['zona_destino_uid'] ?? '' ] ?? '—' );
	return $origen . ' → ' . $destino;
}

// ============================================================
// Excel (CSV)
// ============================================================

function szs_exportar_ganado_csv(): void {
	if ( SZS_PAGINA_GANADO !== szs_campo_get( 'page' ) || '' === szs_campo_get( 'exportar' ) ) {
		return;
	}
	if ( ! szs_puede_usar_panel() ) {
		wp_die( 'Sin permiso.' );
	}
	check_admin_referer( 'szs_exportar_ganado' );
	$que   = sanitize_key( szs_campo_get( 'exportar' ) );
	$datos = szs_datos_ganado();
	$ahora = szs_ahora_ms();
	$zona  = wp_timezone_string();
	$lotes = array();
	foreach ( $datos['lotes'] as $lote ) {
		$lotes[ $lote['uid'] ] = $lote;
	}
	$animales = array();
	foreach ( $datos['animales'] as $animal ) {
		$animales[ $animal['uid'] ] = $animal;
	}
	$nombre_lote = static fn( string $uid ): string => isset( $lotes[ $uid ] ) ? szs_etiqueta_entidad( $lotes[ $uid ] ) : '';
	$dia         = static fn( $ms ): string => empty( $ms ) ? '' : wp_date( 'd/m/Y', intdiv( (int) $ms, 1000 ) );

	switch ( $que ) {
		case 'censo':
			$cabecera = array( 'Crotal', 'Nombre', 'Especie', 'Raza', 'Sexo', 'Nacimiento', 'Madre', 'Rebaño', 'Estado', 'Fecha de baja', 'UGM' );
			$filas    = array();
			foreach ( $datos['animales'] as $animal ) {
				$a       = $animal['datos'];
				$especie = (string) ( $a['especie'] ?? '' );
				if ( '' === $especie ) {
					$especie = (string) ( $lotes[ $a['lote_uid'] ?? '' ]['datos']['especie'] ?? '' );
				}
				$filas[] = array(
					(string) ( $a['identificacion'] ?? '' ),
					(string) ( $a['nombre'] ?? '' ),
					SZS_ESPECIES_GANADO[ $especie ] ?? $especie,
					(string) ( $a['raza'] ?? '' ),
					SZS_SEXOS_ANIMAL[ $a['sexo'] ?? '' ] ?? '',
					$dia( $a['fecha_nacimiento_ms'] ?? null ),
					(string) ( $a['madre'] ?? '' ),
					$nombre_lote( (string) ( $a['lote_uid'] ?? '' ) ),
					SZS_ESTADOS_ANIMAL[ $a['estado'] ?? 'activo' ] ?? '',
					$dia( $a['fecha_baja_ms'] ?? null ),
					szs_animal_activo( $animal ) ? szs_numero_es( szs_ugm_por_cabeza( $especie, (string) ( $a['sexo'] ?? '' ), isset( $a['fecha_nacimiento_ms'] ) ? (int) $a['fecha_nacimiento_ms'] : null, $ahora, $zona ) ) : '',
				);
			}
			break;

		case 'movimientos':
			$cabecera = array( 'Fecha', 'Rebaño', 'Tipo', 'Origen → destino', 'Cabezas', 'Guía', 'Notas' );
			$filas    = array();
			$lista    = $datos['movimientos'];
			usort( $lista, static fn( array $a, array $b ): int => ( $a['datos']['fecha_ms'] ?? 0 ) <=> ( $b['datos']['fecha_ms'] ?? 0 ) );
			foreach ( $lista as $movimiento ) {
				$m       = $movimiento['datos'];
				$filas[] = array(
					$dia( $m['fecha_ms'] ?? null ),
					$nombre_lote( (string) ( $m['lote_uid'] ?? '' ) ),
					SZS_TIPOS_MOVIMIENTO_GANADO[ $m['tipo'] ?? '' ] ?? '',
					szs_trayecto_movimiento( $movimiento, $datos['zonas'] ),
					(string) ( $m['cabezas'] ?? '' ),
					(string) ( $m['guia'] ?? '' ),
					(string) ( $m['notas'] ?? '' ),
				);
			}
			break;

		case 'tratamientos':
			$cabecera = array( 'Fecha', 'Animal / rebaño', 'Tipo', 'Sustancia activa', 'Clase', 'Dosis', 'Espera carne (días)', 'Espera leche (días)', 'Espera eco carne', 'Espera eco leche', 'Veterinario/a', 'Receta' );
			$filas    = array();
			$lista    = array_values( array_filter( $datos['eventos'], static fn( array $e ): bool => in_array( $e['datos']['tipo'] ?? '', SZS_TIPOS_EVENTO_CON_MEDICAMENTO, true ) ) );
			usort( $lista, static fn( array $a, array $b ): int => ( $a['datos']['fecha_ms'] ?? 0 ) <=> ( $b['datos']['fecha_ms'] ?? 0 ) );
			foreach ( $lista as $evento ) {
				$e         = $evento['datos'];
				$animal    = $animales[ $e['animal_uid'] ?? '' ] ?? null;
				$lote_uid  = null !== $animal ? (string) ( $animal['datos']['lote_uid'] ?? '' ) : (string) ( $e['lote_uid'] ?? '' );
				$ecologico = ! empty( $lotes[ $lote_uid ]['datos']['ecologico'] );
				$clase     = (string) ( $e['clase_medicamento'] ?? '' );
				$carne     = (int) ( $e['plazo_supresion_carne_dias'] ?? 0 );
				$leche     = (int) ( $e['plazo_supresion_leche_dias'] ?? 0 );
				$filas[]   = array(
					$dia( $e['fecha_ms'] ?? null ),
					null !== $animal ? (string) ( $animal['datos']['identificacion'] ?? '' ) : $nombre_lote( $lote_uid ),
					SZS_TIPOS_EVENTO_GANADO[ $e['tipo'] ?? '' ] ?? '',
					(string) ( $e['sustancia_activa'] ?? '' ),
					SZS_CLASES_MEDICAMENTO[ $clase ] ?? '',
					(string) ( $e['dosis'] ?? '' ),
					(string) $carne,
					(string) $leche,
					$ecologico ? (string) szs_plazo_efectivo_dias( $carne, true, $clase ) : '',
					$ecologico ? (string) szs_plazo_efectivo_dias( $leche, true, $clase ) : '',
					(string) ( $e['veterinario'] ?? '' ),
					(string) ( $e['receta'] ?? '' ),
				);
			}
			break;

		default:
			return;
	}
	nocache_headers();
	header( 'Content-Type: text/csv; charset=utf-8' );
	header( 'Content-Disposition: attachment; filename="ganado-' . $que . '-' . wp_date( 'Y-m-d' ) . '.csv"' );
	echo szs_filas_a_csv( $cabecera, $filas ); // phpcs:ignore WordPress.Security.EscapeOutput -- CSV, no HTML.
	exit;
}

function szs_url_exportar_ganado( string $que ): string {
	return wp_nonce_url( add_query_arg( array( 'page' => SZS_PAGINA_GANADO, 'exportar' => $que ), admin_url( 'admin.php' ) ), 'szs_exportar_ganado' );
}

// ============================================================
// Páginas
// ============================================================

function szs_pagina_ganado(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$datos = szs_datos_ganado();
	$lote  = szs_campo_get( 'lote' );
	if ( '' !== $lote ) {
		foreach ( $datos['lotes'] as $candidato ) {
			if ( $candidato['uid'] === $lote ) {
				szs_ficha_lote_panel( $candidato, $datos );
				return;
			}
		}
	}
	szs_listado_ganado( $datos );
}

function szs_listado_ganado( array $datos ): void {
	$ahora       = szs_ahora_ms();
	$zona        = wp_timezone_string();
	$ver_todos   = '1' === szs_campo_get( 'cerrados' );
	$personas    = szs_nombres_personas();
	$superficies = szs_superficies_zonas();
	$crotal      = strtoupper( preg_replace( '/[\s\-.]/', '', szs_campo_get( 'crotal' ) ) ?? '' );

	$filas         = array();
	$total_cabezas = 0;
	$total_ugm     = 0.0;
	$ugm_por_zona  = array();
	foreach ( $datos['lotes'] as $lote ) {
		$activo = 'cerrado' !== ( $lote['datos']['estado'] ?? 'activo' );
		if ( ! $activo && ! $ver_todos ) {
			continue;
		}
		$animales  = szs_del_lote( $datos['animales'], $lote['uid'] );
		$ubicacion = szs_ubicacion_lote( szs_del_lote( $datos['movimientos'], $lote['uid'] ) );
		$eventos   = szs_eventos_del_lote( $datos, $lote['uid'] );
		$ecologico = ! empty( $lote['datos']['ecologico'] );
		$cabezas   = szs_cabezas_de_lote( $lote, $animales );
		$ugm       = szs_ugm_de_lote( $lote, $animales, $ahora, $zona );
		if ( $activo ) {
			$total_cabezas += $cabezas;
			$total_ugm     += $ugm;
			if ( isset( $ubicacion['zona_uid'] ) ) {
				$ugm_por_zona[ $ubicacion['zona_uid'] ] = ( $ugm_por_zona[ $ubicacion['zona_uid'] ] ?? 0 ) + $ugm;
			}
		}
		$filas[] = array(
			'lote'      => $lote,
			'activo'    => $activo,
			'ubicacion' => szs_texto_ubicacion( $ubicacion, $datos['zonas'] ),
			'cabezas'   => $cabezas,
			'ugm'       => $ugm,
			'supresion' => szs_texto_supresion( szs_supresion_vigente( $eventos, $ahora, $zona, $ecologico ) ),
			'eco'       => $ecologico ? szs_estado_tratamientos_ecologico( $eventos, $ahora, $zona, ! empty( $lote['datos']['ciclo_corto'] ) ) : null,
			'ultimo'    => szs_ultimo_movimiento( szs_del_lote( $datos['movimientos'], $lote['uid'] ) ),
		);
	}
	usort( $filas, static fn( array $a, array $b ): int => array( $a['activo'] ? 0 : 1, szs_etiqueta_entidad( $a['lote'] ) ) <=> array( $b['activo'] ? 0 : 1, szs_etiqueta_entidad( $b['lote'] ) ) );
	?>
	<div class="wrap">
		<h1>Ganado</h1>
		<p>Los rebaños tal como llegan de los móviles: el ganado se apunta en la app (pestaña Ganado), también sin cobertura. Aquí se consulta y se saca a Excel. Las UGM son orientativas (<?php echo esc_html( SZS_FUENTE_UGM ); ?>); las reglas de ecológico, PROVISIONALES hasta que las revise CPAEN/NNPEK.</p>
		<p>
			<a class="button" href="<?php echo esc_url( szs_url_exportar_ganado( 'censo' ) ); ?>">Censo (Excel)</a>
			<a class="button" href="<?php echo esc_url( szs_url_exportar_ganado( 'movimientos' ) ); ?>">Movimientos (Excel)</a>
			<a class="button" href="<?php echo esc_url( szs_url_exportar_ganado( 'tratamientos' ) ); ?>">Tratamientos (Excel)</a>
		</p>
		<form method="get" style="margin:12px 0;">
			<input type="hidden" name="page" value="<?php echo esc_attr( SZS_PAGINA_GANADO ); ?>">
			<label for="szs_crotal">Buscar un animal por crotal</label>
			<input type="search" id="szs_crotal" name="crotal" value="<?php echo esc_attr( $crotal ); ?>" placeholder="ES0123…">
			<button class="button">Buscar</button>
			<label style="margin-left:16px;"><input type="checkbox" name="cerrados" value="1" <?php checked( $ver_todos ); ?> onchange="this.form.submit()"> Ver también los rebaños cerrados</label>
		</form>

		<?php if ( '' !== $crotal ) : ?>
			<?php
			$encontrados = array_filter( $datos['animales'], static fn( array $a ): bool => str_contains( strtoupper( (string) ( $a['datos']['identificacion'] ?? '' ) ), $crotal ) );
			$lotes       = array();
			foreach ( $datos['lotes'] as $l ) {
				$lotes[ $l['uid'] ] = $l;
			}
			?>
			<h2>Animales con «<?php echo esc_html( $crotal ); ?>»</h2>
			<?php if ( empty( $encontrados ) ) : ?>
				<p>Ninguno.</p>
			<?php else : ?>
				<table class="widefat striped" style="max-width:900px;">
					<thead><tr><th>Crotal</th><th>Nombre</th><th>Rebaño</th><th>Estado</th></tr></thead>
					<tbody>
					<?php foreach ( $encontrados as $animal ) : ?>
						<?php $lote_uid = (string) ( $animal['datos']['lote_uid'] ?? '' ); ?>
						<tr>
							<td><?php echo esc_html( (string) ( $animal['datos']['identificacion'] ?? '' ) ); ?></td>
							<td><?php echo esc_html( (string) ( $animal['datos']['nombre'] ?? '' ) ); ?></td>
							<td><?php if ( isset( $lotes[ $lote_uid ] ) ) : ?><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_GANADO, array( 'lote' => $lote_uid ) ) ); ?>"><?php echo esc_html( szs_etiqueta_entidad( $lotes[ $lote_uid ] ) ); ?></a><?php else : ?>—<?php endif; ?></td>
							<td><?php echo esc_html( SZS_ESTADOS_ANIMAL[ $animal['datos']['estado'] ?? 'activo' ] ?? '' ); ?></td>
						</tr>
					<?php endforeach; ?>
					</tbody>
				</table>
			<?php endif; ?>
		<?php endif; ?>

		<h2>Rebaños</h2>
		<p><?php echo esc_html( sprintf( '%d cabezas · %s UGM en el espacio.', $total_cabezas, szs_numero_es( $total_ugm ) ) ); ?></p>
		<table class="widefat striped">
			<thead><tr><th>Rebaño</th><th>Especie</th><th>De quién</th><th>Dónde está</th><th>Cabezas</th><th>UGM</th><th>Supresión</th><th>Ecológico</th><th>Último movimiento</th></tr></thead>
			<tbody>
			<?php if ( empty( $filas ) ) : ?>
				<tr><td colspan="9">Todavía no ha llegado ningún rebaño de los móviles.</td></tr>
			<?php endif; ?>
			<?php foreach ( $filas as $fila ) : ?>
				<?php
				$d   = $fila['lote']['datos'];
				$eco = $fila['eco'];
				?>
				<tr<?php echo $fila['activo'] ? '' : ' style="opacity:.6"'; ?>>
					<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_GANADO, array( 'lote' => $fila['lote']['uid'] ) ) ); ?>"><strong><?php echo esc_html( szs_etiqueta_entidad( $fila['lote'] ) ); ?></strong></a><?php echo $fila['activo'] ? '' : ' (cerrado)'; ?></td>
					<td><?php echo esc_html( SZS_ESPECIES_GANADO[ $d['especie'] ?? '' ] ?? '' ); ?></td>
					<td><?php echo esc_html( '' === (string) ( $d['titular_uid'] ?? '' ) ? 'Del espacio' : ( $personas[ $d['titular_uid'] ] ?? '—' ) ); ?></td>
					<td><?php echo esc_html( $fila['ubicacion'] ); ?></td>
					<td><?php echo esc_html( (string) $fila['cabezas'] ); ?></td>
					<td><?php echo esc_html( szs_numero_es( $fila['ugm'] ) ); ?></td>
					<td><?php echo '' === $fila['supresion'] ? '' : '<strong style="color:#b8402a;">' . esc_html( $fila['supresion'] ) . '</strong>'; ?></td>
					<td>
						<?php if ( null === $eco ) : ?>
							—
						<?php else : ?>
							<span style="<?php echo $eco['superado'] ? 'color:#b8402a;font-weight:600;' : ( $eco['en_limite'] ? 'color:#a36a00;font-weight:600;' : '' ); ?>"><?php echo esc_html( sprintf( '%d de %d tratamientos', $eco['tratamientos'], $eco['limite'] ) . ( $eco['superado'] ? ' · superado' : ( $eco['en_limite'] ? ' · en el límite' : '' ) ) ); ?></span>
						<?php endif; ?>
					</td>
					<td><?php echo null === $fila['ultimo'] ? '—' : esc_html( szs_fecha_ms( (int) ( $fila['ultimo']['datos']['fecha_ms'] ?? 0 ) ) ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<?php if ( ! empty( $ugm_por_zona ) ) : ?>
			<h2>Carga por pieza</h2>
			<table class="widefat striped" style="max-width:700px;">
				<thead><tr><th>Pieza</th><th>Superficie</th><th>UGM</th><th>UGM/ha</th></tr></thead>
				<tbody>
				<?php
				arsort( $ugm_por_zona );
				foreach ( $ugm_por_zona as $zona_uid => $ugm ) :
					$ha = $superficies[ $zona_uid ] ?? 0;
					?>
					<tr>
						<td><?php echo esc_html( $datos['zonas'][ $zona_uid ] ?? '—' ); ?></td>
						<td><?php echo $ha > 0 ? esc_html( szs_numero_es( $ha ) . ' ha' ) : '—'; ?></td>
						<td><?php echo esc_html( szs_numero_es( $ugm ) ); ?></td>
						<td><?php echo $ha > 0 ? esc_html( szs_numero_es( $ugm / $ha ) ) : '—'; ?></td>
					</tr>
				<?php endforeach; ?>
				</tbody>
			</table>
		<?php endif; ?>
	</div>
	<?php
}

function szs_ficha_lote_panel( array $lote, array $datos ): void {
	$ahora       = szs_ahora_ms();
	$zona        = wp_timezone_string();
	$d           = $lote['datos'];
	$animales    = szs_del_lote( $datos['animales'], $lote['uid'] );
	$movimientos = szs_del_lote( $datos['movimientos'], $lote['uid'] );
	$eventos     = szs_eventos_del_lote( $datos, $lote['uid'] );
	$ecologico   = ! empty( $d['ecologico'] );
	$supresion   = szs_texto_supresion( szs_supresion_vigente( $eventos, $ahora, $zona, $ecologico ) );
	$personas    = szs_nombres_personas();
	$por_animal  = array();
	foreach ( $animales as $animal ) {
		$por_animal[ $animal['uid'] ] = $animal;
	}
	usort( $movimientos, static fn( array $a, array $b ): int => ( $b['datos']['fecha_ms'] ?? 0 ) <=> ( $a['datos']['fecha_ms'] ?? 0 ) );
	usort( $eventos, static fn( array $a, array $b ): int => ( $b['datos']['fecha_ms'] ?? 0 ) <=> ( $a['datos']['fecha_ms'] ?? 0 ) );
	?>
	<div class="wrap">
		<p><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_GANADO ) ); ?>">← Todo el ganado</a></p>
		<h1><?php echo esc_html( szs_etiqueta_entidad( $lote ) ); ?></h1>
		<p>
			<?php
			echo esc_html(
				implode(
					' · ',
					array_filter(
						array(
							SZS_ESPECIES_GANADO[ $d['especie'] ?? '' ] ?? '',
							'' === (string) ( $d['titular_uid'] ?? '' ) ? 'Del espacio' : ( $personas[ $d['titular_uid'] ] ?? '' ),
							szs_texto_ubicacion( szs_ubicacion_lote( $movimientos ), $datos['zonas'] ),
							szs_cabezas_de_lote( $lote, $animales ) . ' cabezas',
							(int) ( $d['cabezas_sin_identificar'] ?? 0 ) > 0 ? (int) $d['cabezas_sin_identificar'] . ' sin crotal' : '',
							szs_numero_es( szs_ugm_de_lote( $lote, $animales, $ahora, $zona ) ) . ' UGM',
							$ecologico ? 'Ecológico' . ( ! empty( $d['ciclo_corto'] ) ? ' (vida productiva menor de un año)' : '' ) : '',
							'cerrado' === ( $d['estado'] ?? 'activo' ) ? 'Cerrado' : '',
						)
					)
				)
			);
			?>
		</p>
		<?php if ( '' !== $supresion ) : ?>
			<div class="notice notice-error inline"><p><strong>En plazo de supresión</strong> — <?php echo esc_html( $supresion ); ?><?php echo $ecologico ? esc_html( ' (plazo doble por ser ecológico)' ) : ''; ?></p></div>
		<?php endif; ?>
		<?php if ( $ecologico ) : ?>
			<?php $eco = szs_estado_tratamientos_ecologico( array_filter( $eventos, static fn( array $e ): bool => '' === (string) ( $e['datos']['animal_uid'] ?? '' ) ), $ahora, $zona, ! empty( $d['ciclo_corto'] ) ); ?>
			<div class="notice <?php echo $eco['superado'] ? 'notice-error' : ( $eco['en_limite'] ? 'notice-warning' : 'notice-info' ); ?> inline">
				<p><strong><?php echo esc_html( sprintf( 'Ecológico: %d de %d tratamientos alopáticos en 12 meses (los del rebaño entero).', $eco['tratamientos'], $eco['limite'] ) ); ?></strong>
				<?php if ( $eco['superado'] ) : ?>Ha superado el límite: no se puede vender como ecológico y vuelve a conversión. Hay que comunicarlo a CPAEN/NNPEK.<?php elseif ( $eco['en_limite'] ) : ?>Está en el límite: uno más y pierde la condición ecológica.<?php endif; ?>
				No cuentan vacunas, antiparasitarios ni saneamiento. Los animales con tratamientos propios se cuentan aparte, abajo.</p>
			</div>
		<?php endif; ?>
		<?php if ( '' !== (string) ( $d['notas'] ?? '' ) ) : ?>
			<p><em><?php echo esc_html( (string) $d['notas'] ); ?></em></p>
		<?php endif; ?>

		<h2>Animales con crotal</h2>
		<table class="widefat striped">
			<thead><tr><th>Crotal</th><th>Nombre</th><th>Raza</th><th>Sexo</th><th>Nacimiento</th><th>Madre</th><th>Estado</th><th>UGM</th><?php echo $ecologico ? '<th>Tratamientos (eco)</th>' : ''; ?></tr></thead>
			<tbody>
			<?php if ( empty( $animales ) ) : ?>
				<tr><td colspan="9">Ninguno.</td></tr>
			<?php endif; ?>
			<?php foreach ( $animales as $animal ) : ?>
				<?php
				$a       = $animal['datos'];
				$especie = '' !== (string) ( $a['especie'] ?? '' ) ? (string) $a['especie'] : (string) ( $d['especie'] ?? '' );
				$activo  = szs_animal_activo( $animal );
				?>
				<tr<?php echo $activo ? '' : ' style="opacity:.6"'; ?>>
					<td><?php echo esc_html( (string) ( $a['identificacion'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $a['nombre'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $a['raza'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( SZS_SEXOS_ANIMAL[ $a['sexo'] ?? '' ] ?? '' ); ?></td>
					<td><?php echo esc_html( szs_fecha_ms( isset( $a['fecha_nacimiento_ms'] ) ? (int) $a['fecha_nacimiento_ms'] : null ) ); ?></td>
					<td><?php echo esc_html( (string) ( $a['madre'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( ( SZS_ESTADOS_ANIMAL[ $a['estado'] ?? 'activo' ] ?? '' ) . ( $activo ? '' : ' ' . szs_fecha_ms( isset( $a['fecha_baja_ms'] ) ? (int) $a['fecha_baja_ms'] : null ) ) ); ?></td>
					<td><?php echo $activo ? esc_html( szs_numero_es( szs_ugm_por_cabeza( $especie, (string) ( $a['sexo'] ?? '' ), isset( $a['fecha_nacimiento_ms'] ) ? (int) $a['fecha_nacimiento_ms'] : null, $ahora, $zona ) ) ) : ''; ?></td>
					<?php if ( $ecologico ) : ?>
						<?php
						$propios = array_filter( $eventos, static fn( array $e ): bool => '' === (string) ( $e['datos']['animal_uid'] ?? '' ) || ( $e['datos']['animal_uid'] ?? '' ) === $animal['uid'] );
						$eco_a   = szs_estado_tratamientos_ecologico( $propios, $ahora, $zona, ! empty( $d['ciclo_corto'] ) );
						?>
						<td style="<?php echo $eco_a['superado'] ? 'color:#b8402a;font-weight:600;' : ''; ?>"><?php echo esc_html( $eco_a['tratamientos'] . ' de ' . $eco_a['limite'] . ( $eco_a['superado'] ? ' · superado' : '' ) ); ?></td>
					<?php endif; ?>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2>Movimientos</h2>
		<table class="widefat striped">
			<thead><tr><th>Fecha</th><th>Tipo</th><th>Origen → destino</th><th>Cabezas</th><th>Guía</th><th>Notas</th></tr></thead>
			<tbody>
			<?php if ( empty( $movimientos ) ) : ?>
				<tr><td colspan="6">Ninguno.</td></tr>
			<?php endif; ?>
			<?php foreach ( $movimientos as $movimiento ) : ?>
				<?php $m = $movimiento['datos']; ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $m['fecha_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( SZS_TIPOS_MOVIMIENTO_GANADO[ $m['tipo'] ?? '' ] ?? '' ); ?></td>
					<td><?php echo esc_html( szs_trayecto_movimiento( $movimiento, $datos['zonas'] ) ); ?></td>
					<td><?php echo esc_html( (string) ( $m['cabezas'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $m['guia'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $m['notas'] ?? '' ) ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>

		<h2>Curas, tratamientos y manejo</h2>
		<table class="widefat striped">
			<thead><tr><th>Fecha</th><th>A quién</th><th>Tipo</th><th>Sustancia · clase · dosis</th><th>Espera carne / leche (días)</th><th>Veterinario/a · receta</th><th>Notas</th></tr></thead>
			<tbody>
			<?php if ( empty( $eventos ) ) : ?>
				<tr><td colspan="7">Ninguno.</td></tr>
			<?php endif; ?>
			<?php foreach ( $eventos as $evento ) : ?>
				<?php
				$e      = $evento['datos'];
				$animal = $por_animal[ $e['animal_uid'] ?? '' ] ?? null;
				$clase  = (string) ( $e['clase_medicamento'] ?? '' );
				$med    = in_array( $e['tipo'] ?? '', SZS_TIPOS_EVENTO_CON_MEDICAMENTO, true );
				$espera = static function ( string $de ) use ( $e, $clase, $ecologico ): string {
					$legal    = (int) ( $e[ "plazo_supresion_{$de}_dias" ] ?? 0 );
					$efectiva = szs_plazo_efectivo_dias( $legal, $ecologico, $clase );
					return $efectiva === $legal ? (string) $legal : "{$legal} (eco {$efectiva})";
				};
				?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $e['fecha_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( null !== $animal ? (string) ( $animal['datos']['identificacion'] ?? '' ) : 'Todo el rebaño' . ( (int) ( $e['cabezas'] ?? 0 ) > 0 ? ' (' . (int) $e['cabezas'] . ' cab.)' : '' ) ); ?></td>
					<td><?php echo esc_html( SZS_TIPOS_EVENTO_GANADO[ $e['tipo'] ?? '' ] ?? '' ); ?></td>
					<td><?php echo $med ? esc_html( implode( ' · ', array_filter( array( (string) ( $e['sustancia_activa'] ?? '' ), SZS_CLASES_MEDICAMENTO[ $clase ] ?? '', (string) ( $e['dosis'] ?? '' ) ) ) ) ) : ''; ?></td>
					<td><?php echo $med ? esc_html( $espera( 'carne' ) . ' / ' . $espera( 'leche' ) ) : ''; ?></td>
					<td><?php echo $med ? esc_html( implode( ' · ', array_filter( array( (string) ( $e['veterinario'] ?? '' ), (string) ( $e['receta'] ?? '' ) ) ) ) ) : ''; ?></td>
					<td><?php echo esc_html( implode( ' · ', array_filter( array( (string) ( $e['descripcion'] ?? '' ), isset( $e['peso_kg'] ) && (float) $e['peso_kg'] > 0 ? szs_numero_es( (float) $e['peso_kg'], 1 ) . ' kg' : '', (int) ( $e['crias'] ?? 0 ) > 0 ? (int) $e['crias'] . ' crías' : '' ) ) ) ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
	</div>
	<?php
}
