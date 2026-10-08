<?php
/**
 * Lógica pura del panel de coordinación (sin `$wpdb` ni funciones de
 * WordPress más allá del saneado): filtros y orden del listado de tareas,
 * exportación CSV, siguiente instancia de una tarea periódica, balance del
 * convenio y resumen del correo diario. Probada en `tests/test_panel.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_MS_DIA = 86_400_000;

/** Fecha objetivo pasada (antes de hoy) y sin hacer. */
function szs_tarea_vencida( array $tarea, int $inicio_de_hoy_ms ): bool {
	return null !== $tarea['fecha_objetivo_ms']
		&& $tarea['fecha_objetivo_ms'] < $inicio_de_hoy_ms
		&& 'hecha' !== $tarea['estado'];
}

/**
 * Filtros del listado: `finca` (nombre), `estado` (código, o `abiertas`),
 * `responsable` (uid, o `sin_asignar`) y `vencidas` (bool).
 *
 * @return array<int, array>
 */
function szs_filtrar_tareas_panel( array $tareas, array $filtros, int $inicio_de_hoy_ms ): array {
	$finca       = (string) ( $filtros['finca'] ?? '' );
	$estado      = (string) ( $filtros['estado'] ?? '' );
	$responsable = (string) ( $filtros['responsable'] ?? '' );
	$vencidas    = ! empty( $filtros['vencidas'] );

	return array_values(
		array_filter(
			$tareas,
			static function ( array $tarea ) use ( $finca, $estado, $responsable, $vencidas, $inicio_de_hoy_ms ): bool {
				if ( '' !== $finca && $tarea['finca_nombre'] !== $finca ) {
					return false;
				}
				if ( 'abiertas' === $estado && 'hecha' === $tarea['estado'] ) {
					return false;
				}
				if ( '' !== $estado && 'abiertas' !== $estado && $tarea['estado'] !== $estado ) {
					return false;
				}
				if ( 'sin_asignar' === $responsable && '' !== $tarea['responsable_uid'] ) {
					return false;
				}
				if ( '' !== $responsable && 'sin_asignar' !== $responsable && $tarea['responsable_uid'] !== $responsable ) {
					return false;
				}
				return ! $vencidas || szs_tarea_vencida( $tarea, $inicio_de_hoy_ms );
			}
		)
	);
}

/**
 * Vencidas primero; luego por fecha objetivo; sin fecha al final; hechas
 * siempre detrás.
 */
function szs_ordenar_tareas_panel( array $tareas, int $inicio_de_hoy_ms ): array {
	usort(
		$tareas,
		static function ( array $a, array $b ) use ( $inicio_de_hoy_ms ): int {
			$clave = static fn( array $tarea ): array => array(
				'hecha' === $tarea['estado'] ? 1 : 0,
				szs_tarea_vencida( $tarea, $inicio_de_hoy_ms ) ? 0 : 1,
				null === $tarea['fecha_objetivo_ms'] ? 1 : 0,
				$tarea['fecha_objetivo_ms'] ?? 0,
			);
			return $clave( $a ) <=> $clave( $b );
		}
	);
	return $tareas;
}

/**
 * Fecha en la hora del espacio. La app guarda las fechas a medianoche
 * local, que en UTC es la víspera: con `gmdate` la tarea del 8 salía del 7.
 */
function szs_fecha_local( int $ms, string $formato = 'd/m/Y' ): string {
	$segundos = intdiv( $ms, 1000 );
	return function_exists( 'wp_date' ) ? (string) wp_date( $formato, $segundos ) : gmdate( $formato, $segundos );
}

function szs_campo_csv( $valor ): string {
	$texto = (string) $valor;
	// Excel ejecuta como fórmula lo que empieza por = + - @: un lote o un
	// título escrito en la app como `=HYPERLINK(...)` se ejecutaría al
	// abrir la exportación. Los números negativos se dejan como están.
	if ( preg_match( '/^[=+\-@\t\r]/', $texto ) && ! preg_match( '/^-?\d[\d.,]*$/', $texto ) ) {
		$texto = "'" . $texto;
	}
	if ( preg_match( '/[;"\r\n]/', $texto ) ) {
		return '"' . str_replace( '"', '""', $texto ) . '"';
	}
	return $texto;
}

/**
 * CSV para Excel (UTF-8 con BOM, separador `;`).
 */
function szs_tareas_a_csv( array $tareas ): string {
	$lineas = array( 'Tarea;Finca;Responsable;Prioridad;Estado;Fecha objetivo;Coste (€);Cada (días)' );
	foreach ( $tareas as $tarea ) {
		$lineas[] = implode(
			';',
			array_map(
				'szs_campo_csv',
				array(
					$tarea['titulo'],
					$tarea['finca_nombre'],
					$tarea['responsable'],
					$tarea['prioridad'],
					$tarea['estado'],
					null === $tarea['fecha_objetivo_ms'] ? '' : szs_fecha_local( (int) $tarea['fecha_objetivo_ms'] ),
					null === $tarea['coste_centimos'] ? '' : number_format( $tarea['coste_centimos'] / 100, 2, ',', '' ),
					$tarea['recurrencia_dias'] ?? '',
				)
			)
		);
	}
	return "\u{FEFF}" . implode( "\r\n", $lineas ) . "\r\n";
}

/**
 * uid de la instancia que sigue a una tarea periódica: el mismo que calcula
 * la app (`uidSiguientePeriodica`). Así, si la genera el servidor y también
 * el móvil que la cerró, o la cierran dos móviles, es una sola tarea.
 */
function szs_uid_siguiente_periodica( string $uid ): string {
	return 'sig-' . substr( sha1( $uid ), 0, 28 );
}

/**
 * Siguiente instancia de una tarea periódica al marcarla hecha (lo mismo
 * que hace la app en `marcarTareaHecha`): pendiente, a `recurrencia_dias`
 * de hoy o de su fecha si aún no ha llegado. `null` si no es periódica.
 *
 * Se suman días de calendario en la zona horaria del espacio, no tandas
 * de 24 h: con el cambio de hora, una fecha a medianoche caería la víspera.
 */
function szs_siguiente_tarea_periodica( array $tarea, int $ahora_ms, string $uid_nuevo, ?DateTimeZone $zona = null ): ?array {
	$dias = $tarea['recurrencia_dias'];
	if ( null === $dias || $dias <= 0 ) {
		return null;
	}
	$zona     = $zona ?? ( function_exists( 'wp_timezone' ) ? wp_timezone() : new DateTimeZone( 'UTC' ) );
	$base_ms  = ( null !== $tarea['fecha_objetivo_ms'] && $tarea['fecha_objetivo_ms'] > $ahora_ms )
		? $tarea['fecha_objetivo_ms']
		: $ahora_ms;
	$base     = ( new DateTimeImmutable( '@' . intdiv( $base_ms, 1000 ) ) )->setTimezone( $zona );
	$objetivo = $base->modify( '+' . (int) $dias . ' days' );
	return array_merge(
		$tarea,
		array(
			'uid'               => $uid_nuevo,
			'estado'            => 'pendiente',
			'coste_centimos'    => null,
			'fecha_objetivo_ms' => $objetivo->getTimestamp() * 1000 + $base_ms % 1000,
			'fecha_creacion_ms' => $ahora_ms,
			'actualizado_ms'    => $ahora_ms,
		)
	);
}

/**
 * Balance del convenio tester (art. 7) a partir de las entidades de un
 * proyecto (`venta` y `apunte`). Mismo cálculo que `BalanceConvenio` en la
 * app.
 *
 * @param array $proyecto_datos `datos` del proyecto (porcentajes).
 * @param array $entidades      Entidades hijas del proyecto (no borradas).
 * @return array<string, int>
 */
function szs_balance_convenio( array $proyecto_datos, array $entidades ): array {
	$ingresos         = 0;
	$gastos_test      = 0;
	$amortizaciones   = 0;
	$asumido_tester   = 0;
	$asumido_zunbeltz = 0;
	foreach ( $entidades as $entidad ) {
		$datos = $entidad['datos'] ?? array();
		if ( 'venta' === $entidad['tipo'] ) {
			$ingresos += (int) ( $datos['ingreso_centimos'] ?? 0 );
			continue;
		}
		if ( 'apunte' !== $entidad['tipo'] ) {
			continue;
		}
		$importe = (int) ( $datos['importe_centimos'] ?? 0 );
		if ( 'ingreso' === ( $datos['tipo'] ?? 'gasto' ) ) {
			$ingresos += $importe;
			continue;
		}
		if ( ! empty( $datos['es_amortizacion'] ) ) {
			$amortizaciones += $importe;
		} else {
			$gastos_test += $importe;
		}
		if ( 'zunbeltz' === ( $datos['asumido_por'] ?? 'tester' ) ) {
			$asumido_zunbeltz += $importe;
		} else {
			$asumido_tester += $importe;
		}
	}
	$balance_test = $ingresos - $gastos_test;
	$porcentaje   = $balance_test >= 0
		? (int) ( $proyecto_datos['porcentaje_beneficio_zunbeltz'] ?? 25 )
		: (int) ( $proyecto_datos['porcentaje_perdida_zunbeltz'] ?? 50 );
	$parte        = (int) round( $balance_test * $porcentaje / 100 );
	return array(
		'ingresos'         => $ingresos,
		'gastos_test'      => $gastos_test,
		'amortizaciones'   => $amortizaciones,
		'balance_test'     => $balance_test,
		'balance_proyecto' => $balance_test - $amortizaciones,
		'asumido_tester'   => $asumido_tester,
		'asumido_zunbeltz' => $asumido_zunbeltz,
		'parte_zunbeltz'   => $parte,
		'parte_tester'     => $balance_test - $parte,
	);
}

/**
 * Correo diario a coordinación: tareas vencidas, peticiones pendientes y
 * alarmas abiertas. `null` si no hay nada que contar.
 *
 * @param string[] $peticiones Títulos de las peticiones pendientes.
 * @param string[] $alarmas    Títulos de las alarmas abiertas.
 * @return array{asunto: string, cuerpo: string}|null
 */
function szs_resumen_correo_diario( array $tareas, array $peticiones, array $alarmas, int $inicio_de_hoy_ms ): ?array {
	$vencidas = array_values( array_filter( $tareas, static fn( array $tarea ): bool => szs_tarea_vencida( $tarea, $inicio_de_hoy_ms ) ) );
	if ( empty( $vencidas ) && empty( $peticiones ) && empty( $alarmas ) ) {
		return null;
	}
	$partes_asunto = array();
	$cuerpo        = array();
	if ( ! empty( $alarmas ) ) {
		$partes_asunto[] = count( $alarmas ) . ( 1 === count( $alarmas ) ? ' alarma abierta' : ' alarmas abiertas' );
		$cuerpo[]        = "Alarmas abiertas:\n" . implode( "\n", array_map( static fn( $titulo ) => "  - {$titulo}", $alarmas ) );
	}
	if ( ! empty( $vencidas ) ) {
		$partes_asunto[] = count( $vencidas ) . ( 1 === count( $vencidas ) ? ' tarea vencida' : ' tareas vencidas' );
		$lineas          = array();
		foreach ( $vencidas as $tarea ) {
			$quien    = '' === $tarea['responsable'] ? 'sin asignar' : $tarea['responsable'];
			$fecha    = szs_fecha_local( (int) $tarea['fecha_objetivo_ms'] );
			$lineas[] = "  - {$tarea['titulo']} ({$tarea['finca_nombre']}, {$quien}, desde el {$fecha})";
		}
		$cuerpo[] = "Tareas vencidas:\n" . implode( "\n", $lineas );
	}
	if ( ! empty( $peticiones ) ) {
		$partes_asunto[] = count( $peticiones ) . ( 1 === count( $peticiones ) ? ' petición pendiente' : ' peticiones pendientes' );
		$cuerpo[]        = "Peticiones de tarea pendientes:\n" . implode( "\n", array_map( static fn( $titulo ) => "  - {$titulo}", $peticiones ) );
	}
	return array(
		'asunto' => 'Solera Zunbeltz: ' . implode( ', ', $partes_asunto ),
		'cuerpo' => implode( "\n\n", $cuerpo ) . "\n",
	);
}

/**
 * Alimentación por días a partir de los registros de actividad de un
 * proyecto: una fila por día (en la zona horaria dada) y lote, con los kg
 * sumados, ordenadas por día y lote. Pura.
 *
 * @return array<int, array{dia: string, lote: string, kg: float}>
 */
function szs_alimentacion_por_dias( array $registros, string $zona_horaria ): array {
	$zona  = new DateTimeZone( $zona_horaria );
	$suma  = array();
	foreach ( $registros as $registro ) {
		$datos = $registro['datos'] ?? array();
		if ( 'registro_actividad' !== ( $registro['tipo'] ?? '' ) || 'alimentacion' !== ( $datos['tipo'] ?? '' ) ) {
			continue;
		}
		$dia   = ( new DateTimeImmutable( '@' . intdiv( (int) ( $datos['fecha_ms'] ?? 0 ), 1000 ) ) )->setTimezone( $zona )->format( 'Y-m-d' );
		$lote  = trim( (string) ( $datos['lote'] ?? '' ) );
		$clave = $dia . "\0" . $lote;
		$suma[ $clave ] = ( $suma[ $clave ] ?? 0.0 ) + (float) ( $datos['cantidad'] ?? 0 );
	}
	ksort( $suma );
	$filas = array();
	foreach ( $suma as $clave => $kg ) {
		list( $dia, $lote ) = explode( "\0", $clave );
		$filas[] = array(
			'dia'  => $dia,
			'lote' => $lote,
			'kg'   => round( $kg, 3 ),
		);
	}
	return $filas;
}

/** CSV para Excel (BOM, `;`, coma decimal) con fila de total. Pura. */
function szs_alimentacion_a_csv( array $filas ): string {
	$numero = static fn( float $kg ): string => rtrim( rtrim( number_format( $kg, 3, ',', '' ), '0' ), ',' );
	$lineas = array( 'Fecha;Lote;Kg' );
	$total  = 0.0;
	foreach ( $filas as $fila ) {
		$fecha    = DateTimeImmutable::createFromFormat( 'Y-m-d', $fila['dia'] );
		$lineas[] = implode( ';', array( false === $fecha ? $fila['dia'] : $fecha->format( 'd/m/Y' ), szs_campo_csv( $fila['lote'] ), $numero( $fila['kg'] ) ) );
		$total   += $fila['kg'];
	}
	$lineas[] = 'Total;;' . $numero( $total );
	return "\u{FEFF}" . implode( "\r\n", $lineas ) . "\r\n";
}
