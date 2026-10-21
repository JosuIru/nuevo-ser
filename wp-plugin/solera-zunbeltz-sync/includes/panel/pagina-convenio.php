<?php
/**
 * Panel · Convenio de un proyecto de test.
 *
 * Lo mismo que la pantalla «Convenio» de la app, editable desde la oficina:
 * condiciones (fechas del test, reparto del resultado, valoraciones),
 * balance, presupuesto previsto frente a lo gastado, fianza (depósitos,
 * devoluciones, retenciones), acompañamiento con los indicadores del anexo
 * IV e incidencias de cumplimiento. Lo que se guarda aquí llega a la app
 * de coordinación y de la persona tester al sincronizar, y lo que
 * coordinación apunta en la app aparece aquí. Los cálculos son los de
 * `logica.php` (probados en `tests/test_panel.php`).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PAGINA_CONVENIO = 'solera-zunbeltz-convenio';

const SZS_MODOS_PARTIDA = array(
	''         => 'A mano',
	'unidades' => 'Cantidad × precio',
	'racion'   => 'Ración × cabezas × días × precio',
);

const SZS_ASISTENCIAS = array(
	'propuesta'   => 'Propuesta',
	'asistida'    => 'Asistida',
	'no_asistida' => 'No asistida',
);

add_action( 'admin_menu', 'szs_registrar_pagina_convenio', 12 );

function szs_registrar_pagina_convenio(): void {
	add_submenu_page( SZS_PAGINA_INICIO, 'Convenio del proyecto', 'Convenio', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_CONVENIO, 'szs_pagina_convenio' );
}

function szs_url_convenio( string $proyecto_uid, array $argumentos = array() ): string {
	return szs_url_pagina( SZS_PAGINA_CONVENIO, array_merge( array( 'proyecto' => $proyecto_uid ), $argumentos ) );
}

/** Etiqueta de una partida: la del catálogo si es un código, o el texto propio. */
function szs_etiqueta_partida( string $bloque, string $partida ): string {
	return SZS_PARTIDAS_GASTO[ $bloque ][ $partida ] ?? $partida;
}

/** «0,15 × 300 × 90 × 0,35 €» para una partida con fórmula; vacío a mano. */
function szs_formula_partida( array $datos ): string {
	$numero = static fn( float $n ): string => szs_numero_legible( $n );
	$precio = number_format( (int) ( $datos['precio_unitario_centimos'] ?? 0 ) / 100, 2, ',', '.' ) . ' €';
	return match ( (string) ( $datos['modo_calculo'] ?? '' ) ) {
		'unidades' => $numero( (float) ( $datos['cantidad'] ?? 0 ) ) . ' × ' . $precio,
		'racion'   => $numero( (float) ( $datos['cantidad'] ?? 0 ) ) . ' × ' . $numero( (float) ( $datos['cabezas'] ?? 0 ) ) . ' × ' . $numero( (float) ( $datos['dias'] ?? 0 ) ) . ' × ' . $precio,
		default    => '',
	};
}

/** `0` → '' en un `<input>`; evita guardar «0 €» sin querer. */
function szs_euros_formulario( ?int $centimos ): string {
	return null === $centimos || 0 === $centimos ? '' : number_format( $centimos / 100, 2, ',', '.' );
}

function szs_fecha_formulario( ?int $ms ): string {
	return null === $ms || 0 === $ms ? '' : wp_date( 'Y-m-d', intdiv( $ms, 1000 ) );
}

/** Procesa el formulario enviado. Devuelve el aviso a mostrar, o null. */
function szs_procesar_convenio( array $proyecto ): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_convenio_' . $proyecto['uid'] );
	$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	$uid    = szs_campo_post( 'szs_uid' );
	$tipos  = array(
		'partida'        => 'partida_presupuesto',
		'fianza'         => 'movimiento_fianza',
		'acompanamiento' => 'acompanamiento',
		'incidencia'     => 'incidencia_cumplimiento',
	);

	if ( str_starts_with( $accion, 'borrar_' ) ) {
		$tipo = $tipos[ substr( $accion, 7 ) ] ?? '';
		if ( '' === $tipo || ! szs_entidad_es_del_proyecto( $tipo, $uid, $proyecto['uid'] ) ) {
			return null;
		}
		return szs_borrar_entidad_desde_panel( $tipo, $uid ) ? array( 'success', 'Borrado. La app lo retirará al sincronizar.' ) : null;
	}

	if ( 'guardar_condiciones' === $accion ) {
		$inicio = szs_ms_desde_fecha( szs_campo_post( 'szs_fecha_inicio' ) );
		$fin    = szs_ms_desde_fecha( szs_campo_post( 'szs_fecha_fin' ) );
		if ( null !== $inicio && null !== $fin && $fin < $inicio ) {
			return array( 'error', 'La fecha de fin es anterior a la de inicio.' );
		}
		$valoracion = static function ( string $clave ): ?int {
			$texto = szs_campo_post( $clave );
			return '' === $texto ? null : max( 0, min( 10, (int) $texto ) );
		};
		szs_guardar_entidad_desde_panel(
			'proyecto',
			$proyecto['uid'],
			array(
				'fecha_inicio_ms'               => $inicio,
				'fecha_fin_ms'                  => $fin,
				'porcentaje_beneficio_zunbeltz' => max( 0, min( 100, (int) szs_campo_post( 'szs_beneficio', '25' ) ) ),
				'porcentaje_perdida_zunbeltz'   => max( 0, min( 100, (int) szs_campo_post( 'szs_perdida', '50' ) ) ),
				'valoracion_zunbeltz'           => $valoracion( 'szs_valoracion_zunbeltz' ),
				'valoracion_tester'             => $valoracion( 'szs_valoracion_tester' ),
			)
		);
		return array( 'success', 'Condiciones guardadas. La app las verá al sincronizar.' );
	}

	$tipo = $tipos[ substr( $accion, 8 ) ] ?? '';
	if ( ! str_starts_with( $accion, 'guardar_' ) || '' === $tipo ) {
		return null;
	}
	if ( '' !== $uid && ! szs_entidad_es_del_proyecto( $tipo, $uid, $proyecto['uid'] ) ) {
		return array( 'error', 'Eso no es de este proyecto.' );
	}
	$datos = szs_datos_convenio_desde_formulario( $tipo );
	if ( is_string( $datos ) ) {
		return array( 'error', $datos );
	}
	szs_guardar_entidad_desde_panel( $tipo, '' === $uid ? szs_nuevo_uid() : $uid, $datos, $proyecto['uid'] );
	return array( 'success', 'Guardado. La app lo verá al sincronizar.' );
}

function szs_entidad_es_del_proyecto( string $tipo, string $uid, string $proyecto_uid ): bool {
	$entidad = szs_obtener_entidad( $tipo, $uid );
	return null !== $entidad && ! $entidad['borrado'] && $entidad['proyecto_uid'] === $proyecto_uid;
}

/**
 * Los `datos` de una entidad del convenio a partir del formulario, con las
 * mismas claves que guarda la app. Devuelve un texto si falta algo.
 *
 * @return array|string
 */
function szs_datos_convenio_desde_formulario( string $tipo ) {
	$fecha = szs_ms_desde_fecha( szs_campo_post( 'szs_fecha' ) );
	$notas = szs_texto_largo_post( 'szs_notas' );
	switch ( $tipo ) {
		case 'partida_presupuesto':
			$bloque = szs_campo_post( 'szs_bloque' );
			if ( ! isset( SZS_BLOQUES_GASTO[ $bloque ] ) ) {
				return 'Elige el bloque de gasto.';
			}
			$propia  = szs_campo_post( 'szs_partida_propia' );
			$partida = '' !== $propia ? $propia : szs_campo_post( 'szs_partida' );
			if ( '' !== $partida && '' === $propia && ! isset( SZS_PARTIDAS_GASTO[ $bloque ][ $partida ] ) ) {
				$partida = '';
			}
			$modo   = szs_campo_post( 'szs_modo' );
			$modo   = isset( SZS_MODOS_PARTIDA[ $modo ] ) ? $modo : '';
			$numero = static fn( string $clave ): float => max( 0.0, (float) str_replace( ',', '.', str_replace( '.', '', szs_campo_post( $clave, '0' ) ) ) );
			$precio = szs_centimos_desde_texto( szs_campo_post( 'szs_precio' ) ) ?? 0;
			$calculado = szs_importe_calculado_partida( $modo, $numero( 'szs_cantidad' ), $numero( 'szs_cabezas' ), $numero( 'szs_dias' ), $precio );
			$importe   = $calculado ?? szs_centimos_desde_texto( szs_campo_post( 'szs_importe' ) );
			if ( null === $importe || $importe < 0 ) {
				return 'Pon el importe previsto (o los datos de la fórmula).';
			}
			$asumido = szs_campo_post( 'szs_asumido_por' );
			return array(
				'categoria'                => $bloque,
				'partida'                  => $partida,
				'concepto'                 => szs_campo_post( 'szs_concepto' ),
				'asumido_por'              => isset( SZS_ASUMIDO_POR[ $asumido ] ) ? $asumido : 'tester',
				'es_amortizacion'          => 'amortizacion' === $bloque ? 1 : 0,
				'importe_centimos'         => $importe,
				'notas'                    => $notas,
				'modo_calculo'             => $modo,
				'cantidad'                 => $numero( 'szs_cantidad' ),
				'cabezas'                  => $numero( 'szs_cabezas' ),
				'dias'                     => $numero( 'szs_dias' ),
				'precio_unitario_centimos' => $precio,
			);
		case 'movimiento_fianza':
			$movimiento = szs_campo_post( 'szs_tipo' );
			$importe    = szs_centimos_desde_texto( szs_campo_post( 'szs_importe' ) );
			if ( ! isset( SZS_TIPOS_MOVIMIENTO_FIANZA[ $movimiento ] ) || null === $importe || $importe <= 0 || null === $fecha ) {
				return 'Faltan el tipo de movimiento, el importe o la fecha.';
			}
			return array(
				'tipo'             => $movimiento,
				'importe_centimos' => $importe,
				'fecha_ms'         => $fecha,
				'notas'            => $notas,
			);
		case 'acompanamiento':
			$actividad  = szs_campo_post( 'szs_tipo' );
			$asistencia = szs_campo_post( 'szs_asistencia', 'propuesta' );
			if ( ! isset( SZS_TIPOS_ACOMPANAMIENTO[ $actividad ] ) || null === $fecha ) {
				return 'Faltan el tipo de actividad o la fecha.';
			}
			$horas = str_replace( ',', '.', szs_campo_post( 'szs_horas' ) );
			return array(
				'tipo'        => $actividad,
				'fecha_ms'    => $fecha,
				'descripcion' => szs_campo_post( 'szs_descripcion' ),
				'asistencia'  => isset( SZS_ASISTENCIAS[ $asistencia ] ) ? $asistencia : 'propuesta',
				'horas'       => '' === $horas || ! is_numeric( $horas ) ? null : max( 0.0, (float) $horas ),
				'notas'       => $notas,
			);
		case 'incidencia_cumplimiento':
			$nivel       = szs_campo_post( 'szs_nivel' );
			$descripcion = szs_campo_post( 'szs_descripcion' );
			if ( ! isset( SZS_NIVELES_INCIDENCIA[ $nivel ] ) || null === $fecha || '' === $descripcion ) {
				return 'Faltan el nivel, la fecha o la descripción de la incidencia.';
			}
			return array(
				'nivel'              => $nivel,
				'fecha_ms'           => $fecha,
				'descripcion'        => $descripcion,
				'retencion_centimos' => max( 0, szs_centimos_desde_texto( szs_campo_post( 'szs_retencion' ) ) ?? 0 ),
				'notas'              => $notas,
			);
	}
	return 'Tipo desconocido.';
}

/** Ordena entidades por `fecha_ms` descendente (sin fecha, al final). */
function szs_ordenar_por_fecha( array $entidades ): array {
	usort( $entidades, static fn( array $a, array $b ): int => (int) ( $b['datos']['fecha_ms'] ?? 0 ) <=> (int) ( $a['datos']['fecha_ms'] ?? 0 ) );
	return $entidades;
}

function szs_pagina_convenio(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$proyectos = szs_listar_entidades_tipo( 'proyecto' );
	$proyecto  = szs_obtener_entidad( 'proyecto', szs_campo_get( 'proyecto' ) );
	if ( null === $proyecto || $proyecto['borrado'] ) {
		szs_pantalla_elegir_proyecto( $proyectos );
		return;
	}
	$aviso    = szs_procesar_convenio( $proyecto );
	$proyecto = szs_obtener_entidad( 'proyecto', $proyecto['uid'] ); // Recargado tras guardar.
	$datos    = $proyecto['datos'];
	$ahora_ms = szs_ahora_ms();
	$zona     = wp_timezone_string();
	$bienes   = szs_bienes_por_uid();
	$personas = szs_nombres_personas();

	$partidas        = szs_listar_entidades_tipo( 'partida_presupuesto', $proyecto['uid'] );
	$fianzas         = szs_ordenar_por_fecha( szs_listar_entidades_tipo( 'movimiento_fianza', $proyecto['uid'] ) );
	$acompanamientos = szs_ordenar_por_fecha( szs_listar_entidades_tipo( 'acompanamiento', $proyecto['uid'] ) );
	$incidencias     = szs_ordenar_por_fecha( szs_listar_entidades_tipo( 'incidencia_cumplimiento', $proyecto['uid'] ) );
	$gastos          = array_merge( szs_listar_entidades_tipo( 'apunte', $proyecto['uid'] ), szs_listar_entidades_tipo( 'uso_bien', $proyecto['uid'] ) );
	$balance         = szs_balance_convenio( $datos, array_merge( szs_listar_entidades_tipo( 'venta', $proyecto['uid'] ), $gastos ), $bienes, $ahora_ms, $zona );
	$presupuesto     = szs_presupuesto_comparado( $partidas, $gastos, $datos, $bienes, $ahora_ms, $zona );
	$fianza          = szs_estado_fianza( $fianzas, $incidencias );
	$inicio_ms       = (int) ( $datos['fecha_inicio_ms'] ?? 0 );
	$fin_ms          = (int) ( $datos['fecha_fin_ms'] ?? 0 );
	$indicadores     = szs_indicadores_acompanamiento( $acompanamientos, 0 === $inicio_ms ? (int) ( $datos['fecha_creacion_ms'] ?? $ahora_ms ) : $inicio_ms, 0 === $fin_ms ? $ahora_ms : $fin_ms, $ahora_ms, $zona );
	$cerrado         = 'cerrado' === ( $datos['estado'] ?? 'abierto' );

	// Qué se está editando (enlace «Editar» de una fila).
	$editar_tipo = szs_campo_get( 'editar' );
	$editando    = '' === $editar_tipo ? null : szs_obtener_entidad( $editar_tipo, szs_campo_get( 'uid' ) );
	if ( null !== $editando && ( $editando['borrado'] || $editando['proyecto_uid'] !== $proyecto['uid'] ) ) {
		$editando = null;
	}
	$en_edicion = static fn( string $tipo ): ?array => null !== $editando && $editando['tipo'] === $tipo ? $editando : null;
	$nonce      = static function () use ( $proyecto ): void {
		wp_nonce_field( 'szs_convenio_' . $proyecto['uid'] );
	};
	$boton_borrar = static function ( string $que, string $uid, string $pregunta ) use ( $nonce ): void {
		?>
		<form method="post" style="display:inline;">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="borrar_<?php echo esc_attr( $que ); ?>">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $uid ); ?>">
			<button class="button button-small button-link-delete" onclick="return confirm('<?php echo esc_js( $pregunta ); ?>');">Borrar</button>
		</form>
		<?php
	};
	$enlace_editar = static function ( string $tipo, string $uid, string $ancla ) use ( $proyecto ): void {
		printf( '<a class="button button-small" href="%s">Editar</a> ', esc_url( szs_url_convenio( $proyecto['uid'], array( 'editar' => $tipo, 'uid' => $uid ) ) . '#' . $ancla ) );
	};
	$si_no = static fn( bool $cumple ): string => $cumple ? '<span style="color:#1a7f37;">✔ se cumple</span>' : '<span style="color:#9a6700;">✘ todavía no</span>';
	?>
	<div class="wrap">
		<h1>Convenio · <?php echo esc_html( szs_etiqueta_entidad( $proyecto ) ); ?></h1>
		<p>
			<a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_PROYECTOS ) ); ?>">← Proyectos</a>
			&nbsp;·&nbsp; Persona tester: <strong><?php echo esc_html( $personas[ (string) ( $datos['persona_uid'] ?? '' ) ] ?? ( '' === (string) ( $datos['persona'] ?? '' ) ? 'sin asignar' : (string) $datos['persona'] ) ); ?></strong>
			&nbsp;·&nbsp; <?php echo $cerrado ? 'Cerrado el ' . esc_html( szs_fecha_ms( (int) ( $datos['cerrado_ms'] ?? 0 ) ) ) : 'Abierto'; ?>
			<?php if ( count( $proyectos ) > 1 ) : ?>
				&nbsp;·&nbsp; Otro proyecto:
				<?php foreach ( $proyectos as $otro ) : ?>
					<?php if ( $otro['uid'] !== $proyecto['uid'] ) : ?>
						<a href="<?php echo esc_url( szs_url_convenio( $otro['uid'] ) ); ?>"><?php echo esc_html( szs_etiqueta_entidad( $otro ) ); ?></a>
					<?php endif; ?>
				<?php endforeach; ?>
			<?php endif; ?>
		</p>
		<p style="max-width:760px;">Lo que aquí se guarda lo ven coordinación y la persona tester en la pantalla «Convenio» de su proyecto en la app, al sincronizar. Las cuentas son orientativas, no contabilidad: cada proyecto tiene las condiciones que se pacten en su convenio.</p>
		<p>
			<a href="#condiciones">Condiciones</a> · <a href="#balance">Balance</a> · <a href="#presupuesto">Presupuesto</a> · <a href="#fianza">Fianza</a> · <a href="#acompanamiento">Acompañamiento</a> · <a href="#incidencias">Incidencias</a>
		</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<h2 id="condiciones">Condiciones del test</h2>
		<form method="post" action="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#condiciones' ); ?>">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="guardar_condiciones">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_fecha_inicio">Inicio del test</label></th><td><input type="date" id="szs_fecha_inicio" name="szs_fecha_inicio" value="<?php echo esc_attr( szs_fecha_formulario( $inicio_ms ) ); ?>"> <span class="description">De las fechas salen los meses del test: las cuotas de amortización y las reuniones que pide el anexo IV.</span></td></tr>
				<tr><th><label for="szs_fecha_fin">Fin previsto</label></th><td><input type="date" id="szs_fecha_fin" name="szs_fecha_fin" value="<?php echo esc_attr( szs_fecha_formulario( $fin_ms ) ); ?>"></td></tr>
				<tr><th><label for="szs_beneficio">Reparto si hay beneficio</label></th><td><input type="number" min="0" max="100" id="szs_beneficio" name="szs_beneficio" class="small-text" value="<?php echo esc_attr( (string) (int) ( $datos['porcentaje_beneficio_zunbeltz'] ?? 25 ) ); ?>"> % para Zunbeltz; el resto, para la persona tester <span class="description">(art. 7: 25 / 75 de partida)</span></td></tr>
				<tr><th><label for="szs_perdida">Reparto si hay pérdida</label></th><td><input type="number" min="0" max="100" id="szs_perdida" name="szs_perdida" class="small-text" value="<?php echo esc_attr( (string) (int) ( $datos['porcentaje_perdida_zunbeltz'] ?? 50 ) ); ?>"> % para Zunbeltz <span class="description">(50 / 50 de partida)</span></td></tr>
				<tr><th>Valoración de la implicación (anexo IV, 0-10)</th><td>
					Zunbeltz: <?php szs_selector( 'szs_valoracion_zunbeltz', array_combine( range( 0, 10 ), range( 0, 10 ) ), isset( $datos['valoracion_zunbeltz'] ) ? (string) (int) $datos['valoracion_zunbeltz'] : '', 'Sin valorar' ); ?>
					&nbsp; Persona tester: <?php szs_selector( 'szs_valoracion_tester', array_combine( range( 0, 10 ), range( 0, 10 ) ), isset( $datos['valoracion_tester'] ) ? (string) (int) $datos['valoracion_tester'] : '', 'Sin valorar' ); ?>
				</td></tr>
			</table>
			<?php submit_button( 'Guardar condiciones' ); ?>
		</form>

		<h2 id="balance">Balance</h2>
		<table class="widefat striped" style="max-width:720px;">
			<tbody>
				<tr><td>Ingresos</td><td style="text-align:right;"><?php echo esc_html( szs_euros( $balance['ingresos'] ) ); ?></td></tr>
				<tr><td>Gastos del test (sin amortizaciones)</td><td style="text-align:right;"><?php echo esc_html( szs_euros( $balance['gastos_test'] ) ); ?></td></tr>
				<tr><td><strong>Balance del test</strong> (el que se reparte)</td><td style="text-align:right;"><strong><?php echo esc_html( szs_euros( $balance['balance_test'] ) ); ?></strong></td></tr>
				<tr><td>Amortizaciones (apuntes del bloque VI y <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_INVENTARIO ) ); ?>">inventario</a>)</td><td style="text-align:right;"><?php echo esc_html( szs_euros( $balance['amortizaciones'] ) ); ?></td></tr>
				<tr><td><strong>Balance del proyecto</strong> (coste real)</td><td style="text-align:right;"><strong><?php echo esc_html( szs_euros( $balance['balance_proyecto'] ) ); ?></strong></td></tr>
				<tr><td>Gastos asumidos por la persona tester / por Zunbeltz</td><td style="text-align:right;"><?php echo esc_html( szs_euros( $balance['asumido_tester'] ) . ' / ' . szs_euros( $balance['asumido_zunbeltz'] ) ); ?></td></tr>
				<tr><td>Reparto del balance del test: Zunbeltz / persona tester</td><td style="text-align:right;"><?php echo esc_html( szs_euros( $balance['parte_zunbeltz'] ) . ' / ' . szs_euros( $balance['parte_tester'] ) ); ?></td></tr>
			</tbody>
		</table>
		<p class="description">Los ingresos y gastos reales se apuntan en la app (la persona tester en su proyecto, coordinación en cualquiera). Aquí se fija lo previsto.</p>

		<h2 id="presupuesto">Presupuesto (anexo II)</h2>
		<?php if ( ! empty( $presupuesto['previsto'] ) || ! empty( $presupuesto['real'] ) ) : ?>
			<table class="widefat striped" style="max-width:720px;">
				<thead><tr><th>Bloque</th><th style="text-align:right;">Previsto</th><th style="text-align:right;">Gastado</th><th style="text-align:right;">Diferencia</th></tr></thead>
				<tbody>
				<?php foreach ( SZS_BLOQUES_GASTO as $codigo => $nombre ) : ?>
					<?php
					$previsto_bloque = (int) ( $presupuesto['previsto'][ $codigo ] ?? 0 );
					$real_bloque     = (int) ( $presupuesto['real'][ $codigo ] ?? 0 );
					if ( 0 === $previsto_bloque && 0 === $real_bloque ) {
						continue;
					}
					?>
					<tr><td><?php echo esc_html( $nombre ); ?></td><td style="text-align:right;"><?php echo esc_html( szs_euros( $previsto_bloque ) ); ?></td><td style="text-align:right;"><?php echo esc_html( szs_euros( $real_bloque ) ); ?></td><td style="text-align:right;<?php echo $real_bloque > $previsto_bloque ? 'color:#b32d2e;' : ''; ?>"><?php echo esc_html( szs_euros( $previsto_bloque - $real_bloque ) ); ?></td></tr>
				<?php endforeach; ?>
				<tr><td><strong>Total</strong></td><td style="text-align:right;"><strong><?php echo esc_html( szs_euros( $presupuesto['total_previsto'] ) ); ?></strong></td><td style="text-align:right;"><strong><?php echo esc_html( szs_euros( $presupuesto['total_real'] ) ); ?></strong></td><td style="text-align:right;"><strong><?php echo esc_html( szs_euros( $presupuesto['total_previsto'] - $presupuesto['total_real'] ) ); ?></strong></td></tr>
				</tbody>
			</table>
		<?php endif; ?>
		<h3>Partidas previstas</h3>
		<table class="widefat striped">
			<thead><tr><th>Bloque</th><th>Partida</th><th>Concepto</th><th>Asume</th><th>Cálculo</th><th style="text-align:right;">Importe</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $partidas ) ) : ?>
				<tr><td colspan="7">Todavía no hay presupuesto. Añade las partidas abajo.</td></tr>
			<?php endif; ?>
			<?php foreach ( $partidas as $partida ) : ?>
				<?php $pd = $partida['datos']; ?>
				<tr>
					<td><?php echo esc_html( SZS_BLOQUES_GASTO[ $pd['categoria'] ?? '' ] ?? (string) ( $pd['categoria'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( szs_etiqueta_partida( (string) ( $pd['categoria'] ?? '' ), (string) ( $pd['partida'] ?? '' ) ) ); ?></td>
					<td><?php echo esc_html( (string) ( $pd['concepto'] ?? '' ) ); ?><?php echo '' === (string) ( $pd['notas'] ?? '' ) ? '' : '<br><small>' . esc_html( (string) $pd['notas'] ) . '</small>'; ?></td>
					<td><?php echo esc_html( SZS_ASUMIDO_POR[ $pd['asumido_por'] ?? 'tester' ] ?? 'Persona tester' ); ?></td>
					<td><small><?php echo esc_html( szs_formula_partida( $pd ) ); ?></small></td>
					<td style="text-align:right;"><?php echo esc_html( szs_euros( (int) ( $pd['importe_centimos'] ?? 0 ) ) ); ?></td>
					<td><?php $enlace_editar( 'partida_presupuesto', $partida['uid'], 'formulario-partida' ); $boton_borrar( 'partida', $partida['uid'], '¿Borrar esta partida del presupuesto?' ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php $partida_edicion = $en_edicion( 'partida_presupuesto' ); $pv = $partida_edicion['datos'] ?? array(); ?>
		<h3 id="formulario-partida"><?php echo null === $partida_edicion ? 'Añadir partida' : 'Editar partida'; ?></h3>
		<form method="post" action="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#presupuesto' ); ?>">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="guardar_partida">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $partida_edicion['uid'] ?? '' ); ?>">
			<?php
			$bloque_actual  = (string) ( $pv['categoria'] ?? 'directos' );
			$partida_actual = (string) ( $pv['partida'] ?? '' );
			$partida_propia = '' !== $partida_actual && ! isset( SZS_PARTIDAS_GASTO[ $bloque_actual ][ $partida_actual ] ) ? $partida_actual : '';
			?>
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_bloque">Bloque</label></th><td><?php szs_selector( 'szs_bloque', SZS_BLOQUES_GASTO, $bloque_actual ); ?></td></tr>
				<tr><th><label for="szs_partida">Partida</label></th><td>
					<select name="szs_partida" id="szs_partida">
						<option value="">— elige una del bloque —</option>
						<?php foreach ( SZS_PARTIDAS_GASTO as $bloque => $opciones ) : ?>
							<?php foreach ( $opciones as $codigo => $nombre ) : ?>
								<option value="<?php echo esc_attr( $codigo ); ?>" data-bloque="<?php echo esc_attr( $bloque ); ?>"<?php selected( $bloque === $bloque_actual && $codigo === $partida_actual ); ?>><?php echo esc_html( $nombre ); ?></option>
							<?php endforeach; ?>
						<?php endforeach; ?>
					</select>
					&nbsp; o escribe otra: <input type="text" name="szs_partida_propia" id="szs_partida_propia" class="regular-text" placeholder="Partida propia" value="<?php echo esc_attr( $partida_propia ); ?>">
				</td></tr>
				<tr><th><label for="szs_concepto">Concepto</label></th><td><input type="text" id="szs_concepto" name="szs_concepto" class="regular-text" placeholder="Pienso y forraje del año" value="<?php echo esc_attr( (string) ( $pv['concepto'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_asumido_por">Quién lo asume</label></th><td><?php szs_selector( 'szs_asumido_por', SZS_ASUMIDO_POR, (string) ( $pv['asumido_por'] ?? 'tester' ) ); ?> <span class="description">De partida, la persona tester asume animales, alimentación y sanidad; Zunbeltz, el resto (art. 7).</span></td></tr>
				<tr><th><label for="szs_modo">Cómo se calcula</label></th><td><?php szs_selector( 'szs_modo', SZS_MODOS_PARTIDA, (string) ( $pv['modo_calculo'] ?? '' ) ); ?></td></tr>
				<tr class="szs-formula"><th>Datos de la fórmula</th><td>
					Cantidad / ración: <input type="text" name="szs_cantidad" class="small-text" value="<?php echo esc_attr( empty( $pv['cantidad'] ) ? '' : szs_numero_legible( (float) $pv['cantidad'] ) ); ?>">
					&nbsp; Cabezas: <input type="text" name="szs_cabezas" class="small-text" value="<?php echo esc_attr( empty( $pv['cabezas'] ) ? '' : szs_numero_legible( (float) $pv['cabezas'] ) ); ?>">
					&nbsp; Días: <input type="text" name="szs_dias" class="small-text" value="<?php echo esc_attr( empty( $pv['dias'] ) ? '' : szs_numero_legible( (float) $pv['dias'] ) ); ?>">
					&nbsp; Precio unitario (€): <input type="text" name="szs_precio" class="small-text" value="<?php echo esc_attr( szs_euros_formulario( (int) ( $pv['precio_unitario_centimos'] ?? 0 ) ) ); ?>">
					<p class="description">Ración por animal y día (kg) × cabezas × días × €/kg; o cantidad × precio (km × €/km, cabezas × €/cabeza). El importe sale solo.</p>
				</td></tr>
				<tr><th><label for="szs_importe">Importe previsto (€)</label></th><td><input type="text" id="szs_importe" name="szs_importe" class="small-text" placeholder="1.200,00" value="<?php echo esc_attr( szs_euros_formulario( (int) ( $pv['importe_centimos'] ?? 0 ) ) ); ?>"> <span class="description">Solo si se calcula a mano.</span></td></tr>
				<tr><th><label for="szs_notas">Notas</label></th><td><textarea id="szs_notas" name="szs_notas" rows="2" class="large-text"><?php echo esc_textarea( (string) ( $pv['notas'] ?? '' ) ); ?></textarea></td></tr>
			</table>
			<?php submit_button( null === $partida_edicion ? 'Añadir partida' : 'Guardar cambios' ); ?>
			<?php if ( null !== $partida_edicion ) : ?><a href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#presupuesto' ); ?>">Cancelar</a><?php endif; ?>
		</form>

		<h2 id="fianza">Fianza</h2>
		<p>Depositado <strong><?php echo esc_html( szs_euros( $fianza['depositado'] ) ); ?></strong> · devuelto <?php echo esc_html( szs_euros( $fianza['devuelto'] ) ); ?> · retenido <?php echo esc_html( szs_euros( $fianza['retenido'] ) ); ?> (con las retenciones de las incidencias) · <strong>pendiente de devolver <?php echo esc_html( szs_euros( $fianza['pendiente'] ) ); ?></strong>.
			<br><span class="description">Referencia del anexo I: el 10 % de lo que el presupuesto prevé que asuma Zunbeltz, <?php echo esc_html( szs_euros( $presupuesto['fianza_referencia'] ) ); ?>. Orientativa: la cuantía se pacta.</span></p>
		<table class="widefat striped" style="max-width:720px;">
			<thead><tr><th>Fecha</th><th>Movimiento</th><th style="text-align:right;">Importe</th><th>Notas</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $fianzas ) ) : ?>
				<tr><td colspan="5">Sin movimientos de fianza.</td></tr>
			<?php endif; ?>
			<?php foreach ( $fianzas as $movimiento ) : ?>
				<?php $md = $movimiento['datos']; ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $md['fecha_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( SZS_TIPOS_MOVIMIENTO_FIANZA[ $md['tipo'] ?? '' ] ?? (string) ( $md['tipo'] ?? '' ) ); ?></td>
					<td style="text-align:right;"><?php echo esc_html( szs_euros( (int) ( $md['importe_centimos'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( (string) ( $md['notas'] ?? '' ) ); ?></td>
					<td><?php $enlace_editar( 'movimiento_fianza', $movimiento['uid'], 'formulario-fianza' ); $boton_borrar( 'fianza', $movimiento['uid'], '¿Borrar este movimiento de la fianza?' ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php $fianza_edicion = $en_edicion( 'movimiento_fianza' ); $fv = $fianza_edicion['datos'] ?? array(); ?>
		<h3 id="formulario-fianza"><?php echo null === $fianza_edicion ? 'Apuntar un movimiento' : 'Editar movimiento'; ?></h3>
		<form method="post" action="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#fianza' ); ?>">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="guardar_fianza">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $fianza_edicion['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_tipo">Movimiento</label></th><td><?php szs_selector( 'szs_tipo', SZS_TIPOS_MOVIMIENTO_FIANZA, (string) ( $fv['tipo'] ?? 'deposito' ) ); ?></td></tr>
				<tr><th><label for="szs_importe_fianza">Importe (€)</label></th><td><input type="text" id="szs_importe_fianza" name="szs_importe" class="small-text" required placeholder="500,00" value="<?php echo esc_attr( szs_euros_formulario( (int) ( $fv['importe_centimos'] ?? 0 ) ) ); ?>"></td></tr>
				<tr><th><label for="szs_fecha_fianza">Fecha</label></th><td><input type="date" id="szs_fecha_fianza" name="szs_fecha" required value="<?php echo esc_attr( szs_fecha_formulario( isset( $fv['fecha_ms'] ) ? (int) $fv['fecha_ms'] : $ahora_ms ) ); ?>"></td></tr>
				<tr><th><label for="szs_notas_fianza">Notas</label></th><td><input type="text" id="szs_notas_fianza" name="szs_notas" class="regular-text" value="<?php echo esc_attr( (string) ( $fv['notas'] ?? '' ) ); ?>"></td></tr>
			</table>
			<?php submit_button( null === $fianza_edicion ? 'Apuntar' : 'Guardar cambios' ); ?>
			<?php if ( null !== $fianza_edicion ) : ?><a href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#fianza' ); ?>">Cancelar</a><?php endif; ?>
		</form>

		<h2 id="acompanamiento">Acompañamiento (anexo IV)</h2>
		<table class="widefat striped" style="max-width:720px;">
			<tbody>
				<tr><td>Soporte integral (formación, visita a explotación de referencia y asesoramiento)</td><td><?php echo $si_no( $indicadores['soporte_integral'] ); ?></td></tr>
				<tr><td>Seguimiento (una reunión y una visita a la finca al mes: <?php echo esc_html( (string) $indicadores['meses'] ); ?> mes(es) hasta hoy)</td><td><?php echo $si_no( $indicadores['seguimiento'] ); ?></td></tr>
				<tr><td>Difusión (visita recibida, mercado y medio de difusión)</td><td><?php echo $si_no( $indicadores['difusion'] ); ?></td></tr>
				<tr><td>Venta y transformación (búsqueda de canales o mercado)</td><td><?php echo $si_no( $indicadores['venta'] ); ?></td></tr>
				<tr><td>Horas de acompañamiento</td><td><?php echo esc_html( szs_numero_legible( (float) $indicadores['horas'] ) ); ?> h</td></tr>
			</tbody>
		</table>
		<table class="widefat striped">
			<thead><tr><th>Fecha</th><th>Actividad</th><th>Descripción</th><th>Asistencia</th><th>Horas</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $acompanamientos ) ) : ?>
				<tr><td colspan="6">Sin actividades de acompañamiento apuntadas.</td></tr>
			<?php endif; ?>
			<?php foreach ( $acompanamientos as $actividad ) : ?>
				<?php $ad = $actividad['datos']; ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $ad['fecha_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( SZS_TIPOS_ACOMPANAMIENTO[ $ad['tipo'] ?? '' ] ?? (string) ( $ad['tipo'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $ad['descripcion'] ?? '' ) ); ?><?php echo '' === (string) ( $ad['notas'] ?? '' ) ? '' : '<br><small>' . esc_html( (string) $ad['notas'] ) . '</small>'; ?></td>
					<td><?php echo esc_html( SZS_ASISTENCIAS[ $ad['asistencia'] ?? 'propuesta' ] ?? 'Propuesta' ); ?></td>
					<td><?php echo isset( $ad['horas'] ) && null !== $ad['horas'] ? esc_html( szs_numero_legible( (float) $ad['horas'] ) ) : '—'; ?></td>
					<td><?php $enlace_editar( 'acompanamiento', $actividad['uid'], 'formulario-acompanamiento' ); $boton_borrar( 'acompanamiento', $actividad['uid'], '¿Borrar esta actividad de acompañamiento?' ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php $acompanamiento_edicion = $en_edicion( 'acompanamiento' ); $av = $acompanamiento_edicion['datos'] ?? array(); ?>
		<h3 id="formulario-acompanamiento"><?php echo null === $acompanamiento_edicion ? 'Apuntar una actividad' : 'Editar actividad'; ?></h3>
		<form method="post" action="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#acompanamiento' ); ?>">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="guardar_acompanamiento">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $acompanamiento_edicion['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_tipo_acompanamiento">Actividad</label></th><td><?php szs_selector( 'szs_tipo', SZS_TIPOS_ACOMPANAMIENTO, (string) ( $av['tipo'] ?? 'reunion' ) ); ?></td></tr>
				<tr><th><label for="szs_fecha_acompanamiento">Fecha</label></th><td><input type="date" id="szs_fecha_acompanamiento" name="szs_fecha" required value="<?php echo esc_attr( szs_fecha_formulario( isset( $av['fecha_ms'] ) ? (int) $av['fecha_ms'] : $ahora_ms ) ); ?>"></td></tr>
				<tr><th><label for="szs_descripcion_acompanamiento">Descripción</label></th><td><input type="text" id="szs_descripcion_acompanamiento" name="szs_descripcion" class="regular-text" placeholder="Curso de elaboración de queso de oveja" value="<?php echo esc_attr( (string) ( $av['descripcion'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_asistencia">Asistencia</label></th><td><?php szs_selector( 'szs_asistencia', SZS_ASISTENCIAS, (string) ( $av['asistencia'] ?? 'propuesta' ) ); ?> <span class="description">Solo las asistidas cuentan para los indicadores.</span></td></tr>
				<tr><th><label for="szs_horas">Horas</label></th><td><input type="text" id="szs_horas" name="szs_horas" class="small-text" placeholder="2,5" value="<?php echo esc_attr( isset( $av['horas'] ) && null !== $av['horas'] ? szs_numero_legible( (float) $av['horas'] ) : '' ); ?>"></td></tr>
				<tr><th><label for="szs_notas_acompanamiento">Notas</label></th><td><input type="text" id="szs_notas_acompanamiento" name="szs_notas" class="regular-text" value="<?php echo esc_attr( (string) ( $av['notas'] ?? '' ) ); ?>"></td></tr>
			</table>
			<?php submit_button( null === $acompanamiento_edicion ? 'Apuntar' : 'Guardar cambios' ); ?>
			<?php if ( null !== $acompanamiento_edicion ) : ?><a href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#acompanamiento' ); ?>">Cancelar</a><?php endif; ?>
		</form>

		<h2 id="incidencias">Incidencias de cumplimiento (art. 8)</h2>
		<p class="description">Dato personal delicado: en la app solo las ven coordinación y la persona tester del proyecto.</p>
		<table class="widefat striped">
			<thead><tr><th>Fecha</th><th>Nivel</th><th>Descripción</th><th style="text-align:right;">Retención de fianza</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $incidencias ) ) : ?>
				<tr><td colspan="5">Sin incidencias.</td></tr>
			<?php endif; ?>
			<?php foreach ( $incidencias as $incidencia ) : ?>
				<?php $id = $incidencia['datos']; ?>
				<tr>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $id['fecha_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( SZS_NIVELES_INCIDENCIA[ $id['nivel'] ?? '' ] ?? (string) ( $id['nivel'] ?? '' ) ); ?></td>
					<td><?php echo esc_html( (string) ( $id['descripcion'] ?? '' ) ); ?><?php echo '' === (string) ( $id['notas'] ?? '' ) ? '' : '<br><small>' . esc_html( (string) $id['notas'] ) . '</small>'; ?></td>
					<td style="text-align:right;"><?php echo esc_html( szs_euros( (int) ( $id['retencion_centimos'] ?? 0 ) ) ); ?></td>
					<td><?php $enlace_editar( 'incidencia_cumplimiento', $incidencia['uid'], 'formulario-incidencia' ); $boton_borrar( 'incidencia', $incidencia['uid'], '¿Borrar esta incidencia?' ); ?></td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php $incidencia_edicion = $en_edicion( 'incidencia_cumplimiento' ); $iv = $incidencia_edicion['datos'] ?? array(); ?>
		<h3 id="formulario-incidencia"><?php echo null === $incidencia_edicion ? 'Apuntar una incidencia' : 'Editar incidencia'; ?></h3>
		<form method="post" action="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#incidencias' ); ?>">
			<?php $nonce(); ?>
			<input type="hidden" name="szs_accion" value="guardar_incidencia">
			<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $incidencia_edicion['uid'] ?? '' ); ?>">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nivel">Nivel</label></th><td><?php szs_selector( 'szs_nivel', SZS_NIVELES_INCIDENCIA, (string) ( $iv['nivel'] ?? 'leve' ) ); ?></td></tr>
				<tr><th><label for="szs_fecha_incidencia">Fecha</label></th><td><input type="date" id="szs_fecha_incidencia" name="szs_fecha" required value="<?php echo esc_attr( szs_fecha_formulario( isset( $iv['fecha_ms'] ) ? (int) $iv['fecha_ms'] : $ahora_ms ) ); ?>"></td></tr>
				<tr><th><label for="szs_descripcion_incidencia">Descripción</label></th><td><input type="text" id="szs_descripcion_incidencia" name="szs_descripcion" class="regular-text" required value="<?php echo esc_attr( (string) ( $iv['descripcion'] ?? '' ) ); ?>"></td></tr>
				<tr><th><label for="szs_retencion">Retención de fianza (€)</label></th><td><input type="text" id="szs_retencion" name="szs_retencion" class="small-text" placeholder="0,00" value="<?php echo esc_attr( szs_euros_formulario( (int) ( $iv['retencion_centimos'] ?? 0 ) ) ); ?>"> <span class="description">Si la incidencia conlleva retener parte de la fianza.</span></td></tr>
				<tr><th><label for="szs_notas_incidencia">Notas</label></th><td><input type="text" id="szs_notas_incidencia" name="szs_notas" class="regular-text" value="<?php echo esc_attr( (string) ( $iv['notas'] ?? '' ) ); ?>"></td></tr>
			</table>
			<?php submit_button( null === $incidencia_edicion ? 'Apuntar' : 'Guardar cambios' ); ?>
			<?php if ( null !== $incidencia_edicion ) : ?><a href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) . '#incidencias' ); ?>">Cancelar</a><?php endif; ?>
		</form>
	</div>
	<script>
	( function () {
		// El desplegable de partidas solo enseña las del bloque elegido, y los
		// datos de la fórmula solo si la partida se calcula.
		var bloque = document.getElementById( 'szs_bloque' );
		var partida = document.getElementById( 'szs_partida' );
		var modo = document.getElementById( 'szs_modo' );
		var filaFormula = document.querySelector( 'tr.szs-formula' );
		var importe = document.getElementById( 'szs_importe' );
		if ( ! bloque || ! partida || ! modo ) {
			return;
		}
		function filtrarPartidas() {
			var elegida = partida.value;
			Array.prototype.forEach.call( partida.options, function ( opcion ) {
				var visible = '' === opcion.value || opcion.getAttribute( 'data-bloque' ) === bloque.value;
				opcion.hidden = ! visible;
				opcion.disabled = ! visible;
			} );
			var actual = partida.options[ partida.selectedIndex ];
			if ( actual && actual.disabled ) {
				partida.value = '';
			} else if ( elegida ) {
				partida.value = elegida;
			}
		}
		function mostrarFormula() {
			var calcula = '' !== modo.value;
			filaFormula.style.display = calcula ? '' : 'none';
			importe.disabled = calcula;
		}
		bloque.addEventListener( 'change', filtrarPartidas );
		modo.addEventListener( 'change', mostrarFormula );
		filtrarPartidas();
		mostrarFormula();
	} )();
	</script>
	<?php
}

/** Sin proyecto en la URL: lista para elegir uno. */
function szs_pantalla_elegir_proyecto( array $proyectos ): void {
	?>
	<div class="wrap">
		<h1>Convenio del proyecto</h1>
		<p>Elige el proyecto cuyo convenio quieres cargar o revisar: condiciones, presupuesto, fianza, acompañamiento e incidencias.</p>
		<?php if ( empty( $proyectos ) ) : ?>
			<p>Todavía no hay proyectos en el servidor. Se crean en la app de coordinación.</p>
		<?php else : ?>
			<ul>
				<?php foreach ( $proyectos as $proyecto ) : ?>
					<li><a href="<?php echo esc_url( szs_url_convenio( $proyecto['uid'] ) ); ?>"><?php echo esc_html( szs_etiqueta_entidad( $proyecto ) ); ?></a><?php echo 'cerrado' === ( $proyecto['datos']['estado'] ?? 'abierto' ) ? ' <small>(cerrado)</small>' : ''; ?></li>
				<?php endforeach; ?>
			</ul>
		<?php endif; ?>
	</div>
	<?php
}
