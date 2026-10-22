<?php
/**
 * Panel · Inicio: la portada del menú «Solera Zunbeltz». De un vistazo, lo
 * que pide atención hoy (alarmas, peticiones pendientes, tareas vencidas),
 * las cifras del espacio (tareas, proyectos, personas, ganado) y quién ha
 * estado activo últimamente; y debajo, un índice con todos los apartados
 * del plugin y para qué sirve cada uno.
 *
 * La lógica de recuento (`szs_resumen_inicio`) no toca WordPress: recibe
 * listas ya cargadas y devuelve números, para poder probarla sin BD.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_DIAS_PROXIMAS_INICIO    = 7;
const SZS_DIAS_ACTIVIDAD_RECIENTE = 7;

/**
 * Cifras de la portada a partir de las listas del espacio.
 *
 * @param array $tareas     Tareas normalizadas (`szs_normalizar_tarea`).
 * @param array $peticiones Entidades `peticion`.
 * @param array $avisos     Entidades `aviso`.
 * @param array $proyectos  Entidades `proyecto`.
 * @param array $personas   Filas de personas (uid, nombre, rol, activo).
 * @param array $lotes      Entidades `lote_ganado`.
 * @param array $animales   Entidades `animal`.
 * @param array $actividad  Entradas de actividad (`szs_actividad_a_json`) de los últimos 7 días.
 * @param int   $inicio_de_hoy_ms Medianoche local de hoy.
 * @param int   $ahora_ms   Ahora.
 * @param array $ultima_por_persona Última huella (ms) por uid de persona, de toda la historia; si no se da, se saca de `$actividad`.
 */
function szs_resumen_inicio( array $tareas, array $peticiones, array $avisos, array $proyectos, array $personas, array $lotes, array $animales, array $actividad, int $inicio_de_hoy_ms, int $ahora_ms, array $ultima_por_persona = array() ): array {
	$dia_ms          = 86_400_000;
	$fin_de_hoy_ms   = $inicio_de_hoy_ms + $dia_ms;
	$limite_proximas = $inicio_de_hoy_ms + SZS_DIAS_PROXIMAS_INICIO * $dia_ms;
	$hace_30_dias_ms = $inicio_de_hoy_ms - 30 * $dia_ms;

	$resumen = array(
		'tareas' => array( 'abiertas' => 0, 'vencidas' => 0, 'hoy' => 0, 'proximas' => 0, 'sin_asignar' => 0, 'bloqueadas' => 0, 'hechas_30_dias' => 0, 'periodicas' => 0 ),
		'peticiones' => array( 'pendientes' => 0, 'urgentes' => 0 ),
		'avisos' => array( 'abiertos' => 0, 'alarmas' => 0 ),
		'proyectos' => array( 'abiertos' => 0, 'cerrados' => 0, 'sin_tester' => 0 ),
		'personas' => array( 'activas' => 0, 'coordinacion' => 0, 'testers' => 0, 'sin_token_usado' => 0 ),
		'ganado' => array( 'lotes' => 0, 'animales_en_alta' => 0, 'cabezas_sin_identificar' => 0 ),
		'actividad' => array( 'ultimos_7_dias' => 0, 'desde_app' => 0, 'desde_oficina' => 0 ),
		'ultima_actividad_por_persona' => array_map( 'intval', $ultima_por_persona ),
	);

	foreach ( $tareas as $tarea ) {
		$hecha = 'hecha' === $tarea['estado'];
		if ( $hecha ) {
			if ( ( $tarea['actualizado_ms'] ?? 0 ) >= $hace_30_dias_ms ) {
				$resumen['tareas']['hechas_30_dias']++;
			}
			continue;
		}
		$resumen['tareas']['abiertas']++;
		if ( '' === $tarea['responsable_uid'] ) {
			$resumen['tareas']['sin_asignar']++;
		}
		if ( 'bloqueada' === $tarea['estado'] ) {
			$resumen['tareas']['bloqueadas']++;
		}
		if ( null !== $tarea['recurrencia_dias'] && $tarea['recurrencia_dias'] > 0 ) {
			$resumen['tareas']['periodicas']++;
		}
		$fecha = $tarea['fecha_objetivo_ms'];
		if ( null === $fecha ) {
			continue;
		}
		if ( $fecha < $inicio_de_hoy_ms ) {
			$resumen['tareas']['vencidas']++;
		} elseif ( $fecha < $fin_de_hoy_ms ) {
			$resumen['tareas']['hoy']++;
		} elseif ( $fecha < $limite_proximas ) {
			$resumen['tareas']['proximas']++;
		}
	}

	foreach ( $peticiones as $peticion ) {
		if ( 'pendiente' === ( $peticion['datos']['estado'] ?? 'pendiente' ) ) {
			$resumen['peticiones']['pendientes']++;
			if ( ! empty( $peticion['datos']['urgente'] ) ) {
				$resumen['peticiones']['urgentes']++;
			}
		}
	}

	foreach ( $avisos as $aviso ) {
		if ( 'abierto' === ( $aviso['datos']['estado'] ?? 'abierto' ) ) {
			$resumen['avisos']['abiertos']++;
			if ( 'alarma' === ( $aviso['datos']['gravedad'] ?? '' ) ) {
				$resumen['avisos']['alarmas']++;
			}
		}
	}

	foreach ( $proyectos as $proyecto ) {
		if ( 'cerrado' === ( $proyecto['datos']['estado'] ?? 'abierto' ) ) {
			$resumen['proyectos']['cerrados']++;
			continue;
		}
		$resumen['proyectos']['abiertos']++;
		if ( '' === (string) ( $proyecto['datos']['persona_uid'] ?? '' ) ) {
			$resumen['proyectos']['sin_tester']++;
		}
	}

	// Última vez que cada persona dejó huella (desde la app o la oficina).
	foreach ( $actividad as $entrada ) {
		$uid = (string) ( $entrada['persona_uid'] ?? '' );
		if ( '' !== $uid ) {
			$momento = (int) ( $entrada['momento_ms'] ?? 0 );
			if ( $momento > ( $resumen['ultima_actividad_por_persona'][ $uid ] ?? 0 ) ) {
				$resumen['ultima_actividad_por_persona'][ $uid ] = $momento;
			}
		}
		if ( (int) ( $entrada['momento_ms'] ?? 0 ) >= $ahora_ms - SZS_DIAS_ACTIVIDAD_RECIENTE * $dia_ms ) {
			$resumen['actividad']['ultimos_7_dias']++;
			if ( 'panel' === ( $entrada['origen'] ?? 'app' ) ) {
				$resumen['actividad']['desde_oficina']++;
			} else {
				$resumen['actividad']['desde_app']++;
			}
		}
	}

	foreach ( $personas as $persona ) {
		if ( empty( $persona['activo'] ) && isset( $persona['activo'] ) ) {
			continue;
		}
		$resumen['personas']['activas']++;
		if ( SZS_ROL_COORDINADOR === ( $persona['rol'] ?? '' ) ) {
			$resumen['personas']['coordinacion']++;
		} elseif ( SZS_ROL_TESTER === ( $persona['rol'] ?? '' ) ) {
			$resumen['personas']['testers']++;
		}
		if ( ! isset( $resumen['ultima_actividad_por_persona'][ (string) $persona['uid'] ] ) ) {
			$resumen['personas']['sin_token_usado']++;
		}
	}

	$resumen['ganado']['lotes'] = count( $lotes );
	foreach ( $lotes as $lote ) {
		$resumen['ganado']['cabezas_sin_identificar'] += (int) ( $lote['datos']['cabezas_sin_identificar'] ?? 0 );
	}
	foreach ( $animales as $animal ) {
		if ( empty( $animal['datos']['fecha_baja_ms'] ) ) {
			$resumen['ganado']['animales_en_alta']++;
		}
	}

	return $resumen;
}

/**
 * Lo que pide atención, ordenado de más a menos urgente, con el enlace al
 * apartado donde se resuelve. Vacío si todo está en orden.
 *
 * @return array<int, array{texto: string, pagina: string, argumentos: array, nivel: string}>
 */
function szs_pendientes_inicio( array $resumen ): array {
	$pendientes = array();
	if ( $resumen['avisos']['alarmas'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d alarma(s) abierta(s)', $resumen['avisos']['alarmas'] ), 'pagina' => SZS_PAGINA_AVISOS, 'argumentos' => array(), 'nivel' => 'alarma' );
	}
	if ( $resumen['peticiones']['urgentes'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d petición(es) urgente(s) sin responder', $resumen['peticiones']['urgentes'] ), 'pagina' => SZS_PAGINA_PETICIONES, 'argumentos' => array(), 'nivel' => 'alarma' );
	}
	if ( $resumen['tareas']['vencidas'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d tarea(s) vencida(s)', $resumen['tareas']['vencidas'] ), 'pagina' => SZS_PAGINA_TAREAS, 'argumentos' => array( 'vencidas' => '1' ), 'nivel' => 'aviso' );
	}
	$peticiones_normales = $resumen['peticiones']['pendientes'] - $resumen['peticiones']['urgentes'];
	if ( $peticiones_normales > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d petición(es) de tarea pendiente(s)', $peticiones_normales ), 'pagina' => SZS_PAGINA_PETICIONES, 'argumentos' => array(), 'nivel' => 'aviso' );
	}
	if ( $resumen['tareas']['bloqueadas'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d tarea(s) bloqueada(s)', $resumen['tareas']['bloqueadas'] ), 'pagina' => SZS_PAGINA_TAREAS, 'argumentos' => array( 'estado' => 'bloqueada' ), 'nivel' => 'aviso' );
	}
	if ( $resumen['tareas']['sin_asignar'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d tarea(s) abierta(s) sin responsable', $resumen['tareas']['sin_asignar'] ), 'pagina' => SZS_PAGINA_TAREAS, 'argumentos' => array( 'responsable' => 'sin_asignar' ), 'nivel' => 'info' );
	}
	if ( $resumen['proyectos']['sin_tester'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d proyecto(s) abierto(s) sin persona tester', $resumen['proyectos']['sin_tester'] ), 'pagina' => SZS_PAGINA_PROYECTOS, 'argumentos' => array(), 'nivel' => 'info' );
	}
	if ( $resumen['avisos']['abiertos'] - $resumen['avisos']['alarmas'] > 0 ) {
		$pendientes[] = array( 'texto' => sprintf( '%d aviso(s) abierto(s)', $resumen['avisos']['abiertos'] - $resumen['avisos']['alarmas'] ), 'pagina' => SZS_PAGINA_AVISOS, 'argumentos' => array(), 'nivel' => 'info' );
	}
	return $pendientes;
}

/**
 * Índice de apartados del plugin: slug, nombre y para qué sirve. Es lo que
 * la portada pinta como tarjetas de enlace, agrupado por bloques.
 *
 * @return array<string, array<int, array{pagina: string, nombre: string, para_que: string, url?: string}>>
 */
function szs_apartados_inicio(): array {
	$apartados = array(
		'El día a día' => array(
			array( 'pagina' => SZS_PAGINA_TAREAS, 'nombre' => 'Tareas', 'para_que' => 'El tablero de la oficina: alta, edición, filtros por finca y responsable, exportación a Excel.' ),
			array( 'pagina' => SZS_PAGINA_PETICIONES, 'nombre' => 'Peticiones', 'para_que' => 'Lo que las testers piden que se haga. Se convierten en tarea o se descartan con un motivo.' ),
			array( 'pagina' => SZS_PAGINA_AVISOS, 'nombre' => 'Avisos', 'para_que' => 'Alarmas e incidencias del espacio y noticias que coordinación publica para todos los móviles.' ),
			array( 'pagina' => SZS_PAGINA_ACTIVIDAD, 'nombre' => 'Actividad', 'para_que' => 'Registro de lo que cada persona ha hecho, desde la app o desde esta oficina.' ),
		),
		'Proyectos de test' => array(
			array( 'pagina' => SZS_PAGINA_PROYECTOS, 'nombre' => 'Proyectos', 'para_que' => 'Asignar tester, cerrar o reabrir, ver las cuentas y bajar la alimentación por días.' ),
			array( 'pagina' => SZS_PAGINA_GANADO, 'nombre' => 'Ganado', 'para_que' => 'Los rebaños que apuntan los móviles: dónde está cada uno, cabezas, UGM, supresión y tratamientos en ecológico; censo, movimientos y tratamientos en Excel.' ),
			array( 'pagina' => SZS_PAGINA_CONVENIO, 'nombre' => 'Convenio', 'para_que' => 'Cargar y editar el convenio de cada proyecto: fechas y reparto, presupuesto, fianza, acompañamiento e incidencias.' ),
			array( 'pagina' => SZS_PAGINA_INVENTARIO, 'nombre' => 'Inventario', 'para_que' => 'Bienes amortizables del espacio y qué parte de su cuota se imputa a cada proyecto.' ),
			array( 'pagina' => SZS_PAGINA_RENDIMIENTOS, 'nombre' => 'Rendimientos', 'para_que' => 'Rendimientos de referencia (peso vivo → canal → producto) para la calculadora de transformación, con su fuente.' ),
			array( 'pagina' => SZS_PAGINA_CONTACTOS, 'nombre' => 'Contactos', 'para_que' => 'Agenda compartida: mataderos, veterinarias, clientes, proveedores.' ),
		),
		'Personas y acceso' => array(
			array( 'pagina' => SZS_PAGINA_PERSONAS, 'nombre' => 'Personas', 'para_que' => 'Quién entra en el espacio, con qué rol y con qué token; enlazar con usuarios de WordPress.' ),
			array( 'pagina' => SZS_PAGINA_ANDROID, 'nombre' => 'App Android', 'para_que' => 'Dónde descargar la app y, si hace falta, subir un APK a mano.' ),
			array( 'pagina' => '', 'url' => szs_url_app_web(), 'nombre' => 'Abrir la app web ↗', 'para_que' => 'La misma app, en el navegador, para la oficina y para probarla sin instalar nada.' ),
		),
		'Comunicación y web' => array(
			array( 'pagina' => SZS_PAGINA_NOTICIAS, 'nombre' => 'Noticias del sector', 'para_que' => 'Canales RSS que el servidor lee cada 3 horas y la app enseña en Hoy.' ),
			array( 'pagina' => SZS_PAGINA_AYUDA, 'nombre' => 'Ayuda de la app', 'para_que' => 'Cambiar los textos de la ayuda de la app y del manual imprimible (/manual/), en castellano y euskera.' ),
			array( 'pagina' => SZS_PAGINA_LOGOS_ENTIDADES, 'nombre' => 'Entidades y logos', 'para_que' => 'Quién impulsa, apoya, colabora y financia: los logos del pie de la web, de la app y de Acerca de.' ),
		),
	);
	if ( current_user_can( 'manage_options' ) ) {
		$apartados['Comunicación y web'][] = array( 'pagina' => SZS_PAGINA_DATOS_DEMO, 'nombre' => 'Datos demo', 'para_que' => 'Sembrar o retirar datos de ejemplo. Solo para administración de WordPress.' );
	}
	return $apartados;
}

function szs_url_apartado_inicio( array $apartado ): string {
	return isset( $apartado['url'] ) ? (string) $apartado['url'] : szs_url_pagina( $apartado['pagina'] );
}

/** «hace 3 h», «ayer», «hace 12 días»… para la lista de personas. */
function szs_hace_cuanto( int $momento_ms, int $ahora_ms ): string {
	$segundos = max( 0, intdiv( $ahora_ms - $momento_ms, 1000 ) );
	if ( $segundos < 3600 ) {
		return sprintf( 'hace %d min', max( 1, intdiv( $segundos, 60 ) ) );
	}
	if ( $segundos < 86400 ) {
		return sprintf( 'hace %d h', intdiv( $segundos, 3600 ) );
	}
	$dias = intdiv( $segundos, 86400 );
	return 1 === $dias ? 'ayer' : sprintf( 'hace %d días', $dias );
}

function szs_pagina_inicio(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	global $wpdb;
	$ahora_ms      = szs_ahora_ms();
	$inicio_hoy_ms = szs_inicio_de_hoy_ms();
	$tabla_actividad = $wpdb->prefix . SZS_TABLA_ACTIVIDAD;
	// Los 7 días completos para los recuentos, y la última huella de cada
	// persona de toda la historia (no solo de lo reciente).
	$actividad = array_map(
		'szs_actividad_a_json',
		(array) $wpdb->get_results(
			$wpdb->prepare( "SELECT * FROM {$tabla_actividad} WHERE momento_ms >= %d ORDER BY id DESC", $ahora_ms - SZS_DIAS_ACTIVIDAD_RECIENTE * 86_400_000 ),
			ARRAY_A
		)
	);
	$ultima_por_persona = array();
	foreach ( (array) $wpdb->get_results( "SELECT persona_uid, MAX(momento_ms) AS ultimo_ms FROM {$tabla_actividad} WHERE persona_uid <> '' GROUP BY persona_uid", ARRAY_A ) as $fila ) {
		$ultima_por_persona[ (string) $fila['persona_uid'] ] = (int) $fila['ultimo_ms'];
	}
	$personas = szs_listar_personas();
	$resumen  = szs_resumen_inicio(
		szs_listar_todas_las_tareas(),
		szs_listar_entidades_tipo( 'peticion' ),
		szs_listar_entidades_tipo( 'aviso' ),
		szs_listar_entidades_tipo( 'proyecto' ),
		$personas,
		szs_listar_entidades_tipo( 'lote_ganado' ),
		szs_listar_entidades_tipo( 'animal' ),
		$actividad,
		$inicio_hoy_ms,
		$ahora_ms,
		$ultima_por_persona
	);
	$pendientes = szs_pendientes_inicio( $resumen );
	$fincas     = szs_nombres_fincas();
	$puntos     = count( szs_listar_entidades_tipo( 'punto' ) );
	$zonas      = count( szs_listar_entidades_tipo( 'zona' ) );
	$canales    = function_exists( 'szs_listar_canales' ) ? szs_listar_canales( true ) : array();
	$apk        = szs_apk_publicado();
	// Las últimas entradas de verdad, aunque sean de hace más de 7 días.
	$ultimas = array_map(
		'szs_actividad_a_json',
		(array) $wpdb->get_results( "SELECT * FROM {$tabla_actividad} ORDER BY id DESC LIMIT 8", ARRAY_A )
	);
	usort( $personas, static fn( array $a, array $b ): int => ( $resumen['ultima_actividad_por_persona'][ $b['uid'] ] ?? 0 ) <=> ( $resumen['ultima_actividad_por_persona'][ $a['uid'] ] ?? 0 ) );

	$cifra = static function ( string $etiqueta, $valor, string $pagina = '', array $argumentos = array(), string $clase = '' ): void {
		$texto = sprintf( '<span class="szs-cifra-valor">%s</span><span class="szs-cifra-etiqueta">%s</span>', esc_html( (string) $valor ), esc_html( $etiqueta ) );
		if ( '' !== $pagina ) {
			printf( '<a class="szs-cifra %s" href="%s">%s</a>', esc_attr( $clase ), esc_url( szs_url_pagina( $pagina, $argumentos ) ), $texto ); // phpcs:ignore WordPress.Security.EscapeOutput -- ya escapado.
		} else {
			printf( '<div class="szs-cifra %s">%s</div>', esc_attr( $clase ), $texto ); // phpcs:ignore WordPress.Security.EscapeOutput -- ya escapado.
		}
	};
	?>
	<style>
		.szs-inicio .szs-bloques { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; margin-top: 16px; }
		.szs-inicio .szs-bloque { background: #fff; border: 1px solid #c3c4c7; padding: 12px 16px 16px; }
		.szs-inicio .szs-bloque h2 { margin: 0 0 10px; font-size: 15px; display: flex; justify-content: space-between; align-items: baseline; }
		.szs-inicio .szs-bloque h2 a { font-weight: normal; font-size: 13px; }
		.szs-inicio .szs-cifras { display: flex; flex-wrap: wrap; gap: 8px; }
		.szs-inicio .szs-cifra { display: flex; flex-direction: column; min-width: 92px; flex: 1; padding: 8px 10px; background: #f6f7f7; border: 1px solid #dcdcde; text-decoration: none; color: #1d2327; }
		.szs-inicio a.szs-cifra:hover { border-color: #2271b1; }
		.szs-inicio .szs-cifra-valor { font-size: 24px; line-height: 1.1; font-weight: 600; }
		.szs-inicio .szs-cifra-etiqueta { font-size: 12px; color: #50575e; margin-top: 2px; }
		.szs-inicio .szs-cifra.szs-mal .szs-cifra-valor { color: #b32d2e; }
		.szs-inicio .szs-cifra.szs-ojo .szs-cifra-valor { color: #996800; }
		.szs-inicio .szs-pendientes { margin: 0; }
		.szs-inicio .szs-pendientes li { margin: 0 0 6px; padding-left: 10px; border-left: 4px solid #dcdcde; }
		.szs-inicio .szs-pendientes li.szs-alarma { border-color: #b32d2e; }
		.szs-inicio .szs-pendientes li.szs-aviso { border-color: #dba617; }
		.szs-inicio .szs-pendientes li.szs-info { border-color: #2271b1; }
		.szs-inicio .szs-todo-en-orden { color: #007017; margin: 0; }
		.szs-inicio table.szs-tabla-compacta { width: 100%; border-collapse: collapse; }
		.szs-inicio table.szs-tabla-compacta td { padding: 4px 6px 4px 0; border-bottom: 1px solid #f0f0f1; vertical-align: top; }
		.szs-inicio table.szs-tabla-compacta td.szs-cuando { white-space: nowrap; color: #50575e; width: 110px; }
		.szs-inicio .szs-apartados { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 10px; }
		.szs-inicio .szs-apartado { display: block; padding: 10px 12px; background: #fff; border: 1px solid #c3c4c7; text-decoration: none; color: #1d2327; }
		.szs-inicio .szs-apartado:hover { border-color: #2271b1; }
		.szs-inicio .szs-apartado strong { display: block; color: #2271b1; margin-bottom: 3px; }
		.szs-inicio .szs-apartado span { font-size: 12px; color: #50575e; }
		.szs-inicio h2.szs-grupo { font-size: 14px; margin: 18px 0 8px; color: #50575e; }
		.szs-inicio .szs-pie { color: #50575e; font-size: 12px; margin-top: 18px; }
	</style>
	<div class="wrap szs-inicio">
		<h1>Solera Zunbeltz · Inicio</h1>
		<p>Resumen del espacio a <?php echo esc_html( szs_fecha_ms( $ahora_ms, 'd/m/Y H:i' ) ); ?>. Cada cifra lleva a su apartado.</p>

		<div class="szs-bloques">
			<div class="szs-bloque">
				<h2>Pide atención</h2>
				<?php if ( empty( $pendientes ) ) : ?>
					<p class="szs-todo-en-orden">Nada urgente: sin alarmas, sin peticiones pendientes y sin tareas vencidas.</p>
				<?php else : ?>
					<ul class="szs-pendientes">
						<?php foreach ( $pendientes as $pendiente ) : ?>
							<li class="szs-<?php echo esc_attr( $pendiente['nivel'] ); ?>"><a href="<?php echo esc_url( szs_url_pagina( $pendiente['pagina'], $pendiente['argumentos'] ) ); ?>"><?php echo esc_html( $pendiente['texto'] ); ?></a></li>
						<?php endforeach; ?>
					</ul>
				<?php endif; ?>
			</div>

			<div class="szs-bloque">
				<h2>Tareas <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS ) ); ?>">ver tablero →</a></h2>
				<div class="szs-cifras">
					<?php
					$cifra( 'abiertas', $resumen['tareas']['abiertas'], SZS_PAGINA_TAREAS );
					$cifra( 'vencidas', $resumen['tareas']['vencidas'], SZS_PAGINA_TAREAS, array( 'vencidas' => '1' ), $resumen['tareas']['vencidas'] > 0 ? 'szs-mal' : '' );
					$cifra( 'para hoy', $resumen['tareas']['hoy'], SZS_PAGINA_TAREAS );
					$cifra( 'próximos 7 días', $resumen['tareas']['proximas'], SZS_PAGINA_TAREAS );
					$cifra( 'sin responsable', $resumen['tareas']['sin_asignar'], SZS_PAGINA_TAREAS, array( 'responsable' => 'sin_asignar' ), $resumen['tareas']['sin_asignar'] > 0 ? 'szs-ojo' : '' );
					$cifra( 'periódicas', $resumen['tareas']['periodicas'], SZS_PAGINA_TAREAS );
					$cifra( 'hechas en 30 días', $resumen['tareas']['hechas_30_dias'], SZS_PAGINA_TAREAS, array( 'estado' => 'hecha' ) );
					?>
				</div>
			</div>

			<div class="szs-bloque">
				<h2>Peticiones y avisos</h2>
				<div class="szs-cifras">
					<?php
					$cifra( 'peticiones pendientes', $resumen['peticiones']['pendientes'], SZS_PAGINA_PETICIONES, array(), $resumen['peticiones']['pendientes'] > 0 ? 'szs-ojo' : '' );
					$cifra( 'urgentes', $resumen['peticiones']['urgentes'], SZS_PAGINA_PETICIONES, array(), $resumen['peticiones']['urgentes'] > 0 ? 'szs-mal' : '' );
					$cifra( 'avisos abiertos', $resumen['avisos']['abiertos'], SZS_PAGINA_AVISOS );
					$cifra( 'alarmas', $resumen['avisos']['alarmas'], SZS_PAGINA_AVISOS, array(), $resumen['avisos']['alarmas'] > 0 ? 'szs-mal' : '' );
					?>
				</div>
			</div>

			<div class="szs-bloque">
				<h2>Proyectos de test <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_PROYECTOS ) ); ?>">ver →</a></h2>
				<div class="szs-cifras">
					<?php
					$cifra( 'abiertos', $resumen['proyectos']['abiertos'], SZS_PAGINA_PROYECTOS );
					$cifra( 'sin tester', $resumen['proyectos']['sin_tester'], SZS_PAGINA_PROYECTOS, array(), $resumen['proyectos']['sin_tester'] > 0 ? 'szs-ojo' : '' );
					$cifra( 'cerrados', $resumen['proyectos']['cerrados'], SZS_PAGINA_PROYECTOS );
					?>
				</div>
			</div>

			<div class="szs-bloque">
				<h2>Espacio y ganado</h2>
				<div class="szs-cifras">
					<?php
					$cifra( 'fincas', count( $fincas ) );
					$cifra( 'zonas', $zonas );
					$cifra( 'puntos', $puntos );
					$cifra( 'lotes', $resumen['ganado']['lotes'] );
					$cifra( 'animales en alta', $resumen['ganado']['animales_en_alta'] );
					$cifra( 'cabezas sin crotal', $resumen['ganado']['cabezas_sin_identificar'] );
					?>
				</div>
				<p class="description" style="margin-top:8px;">Fincas, zonas, puntos y ganado se editan desde la app; aquí solo se cuentan.</p>
			</div>

			<div class="szs-bloque">
				<h2>Personas <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_PERSONAS ) ); ?>">gestionar →</a></h2>
				<div class="szs-cifras" style="margin-bottom:10px;">
					<?php
					$cifra( 'activas', $resumen['personas']['activas'], SZS_PAGINA_PERSONAS );
					$cifra( 'coordinación', $resumen['personas']['coordinacion'], SZS_PAGINA_PERSONAS );
					$cifra( 'testers', $resumen['personas']['testers'], SZS_PAGINA_PERSONAS );
					$cifra( 'sin actividad aún', $resumen['personas']['sin_token_usado'], SZS_PAGINA_PERSONAS, array(), $resumen['personas']['sin_token_usado'] > 0 ? 'szs-ojo' : '' );
					?>
				</div>
				<?php if ( ! empty( $personas ) ) : ?>
				<table class="szs-tabla-compacta">
					<?php foreach ( $personas as $persona ) : ?>
						<?php $ultima = $resumen['ultima_actividad_por_persona'][ $persona['uid'] ] ?? 0; ?>
						<tr>
							<td><?php echo esc_html( $persona['nombre'] ); ?> <span class="description">· <?php echo esc_html( szs_etiqueta_rol( (string) $persona['rol'] ) ); ?></span></td>
							<td class="szs-cuando"><?php echo 0 === $ultima ? 'sin actividad' : esc_html( szs_hace_cuanto( $ultima, $ahora_ms ) ); ?></td>
						</tr>
					<?php endforeach; ?>
				</table>
				<?php endif; ?>
			</div>

			<div class="szs-bloque">
				<h2>Actividad reciente <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ACTIVIDAD ) ); ?>">todo →</a></h2>
				<div class="szs-cifras" style="margin-bottom:10px;">
					<?php
					$cifra( 'cambios en 7 días', $resumen['actividad']['ultimos_7_dias'], SZS_PAGINA_ACTIVIDAD );
					$cifra( 'desde la app', $resumen['actividad']['desde_app'], SZS_PAGINA_ACTIVIDAD );
					$cifra( 'desde la oficina', $resumen['actividad']['desde_oficina'], SZS_PAGINA_ACTIVIDAD );
					?>
				</div>
				<?php if ( empty( $ultimas ) ) : ?>
					<p class="description">Todavía no hay actividad.</p>
				<?php else : ?>
				<table class="szs-tabla-compacta">
					<?php foreach ( $ultimas as $entrada ) : ?>
						<tr>
							<td class="szs-cuando"><?php echo esc_html( szs_fecha_ms( $entrada['momento_ms'], 'd/m H:i' ) ); ?></td>
							<td><?php echo esc_html( szs_describir_actividad( $entrada ) ); ?></td>
						</tr>
					<?php endforeach; ?>
				</table>
				<?php endif; ?>
			</div>

			<div class="szs-bloque">
				<h2>La app y el servidor</h2>
				<table class="szs-tabla-compacta">
					<tr><td>Plugin</td><td><?php echo esc_html( SZS_VERSION ); ?> · esquema <?php echo esc_html( (string) SZS_VERSION_ESQUEMA ); ?></td></tr>
					<tr><td>App web</td><td><a href="<?php echo esc_url( szs_url_app_web() ); ?>" target="_blank" rel="noopener"><?php echo esc_html( szs_url_app_web() ); ?></a></td></tr>
					<tr><td>APK en el panel</td><td><?php echo null === $apk ? 'ninguno subido (se sirve el de la última release de GitHub)' : esc_html( ( '' === $apk['version'] ? 'sin versión' : 'versión ' . $apk['version'] ) . ', subido el ' . wp_date( 'd/m/Y', $apk['fecha'] ) ); ?> · <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_ANDROID ) ); ?>">App Android</a></td></tr>
					<tr><td>Sincronización</td><td>revisión <?php echo esc_html( (string) szs_revision_actual() ); ?> · <code><?php echo esc_html( rest_url( 'solera-zunbeltz/v1/sync' ) ); ?></code></td></tr>
					<tr><td>Noticias del sector</td><td><?php echo esc_html( (string) count( $canales ) ); ?> canal(es) activo(s) · <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_NOTICIAS ) ); ?>">gestionar</a></td></tr>
				</table>
			</div>
		</div>

		<?php foreach ( szs_apartados_inicio() as $grupo => $apartados ) : ?>
			<h2 class="szs-grupo"><?php echo esc_html( $grupo ); ?></h2>
			<div class="szs-apartados">
				<?php foreach ( $apartados as $apartado ) : ?>
					<a class="szs-apartado" href="<?php echo esc_url( szs_url_apartado_inicio( $apartado ) ); ?>"<?php echo isset( $apartado['url'] ) ? ' target="_blank" rel="noopener"' : ''; ?>>
						<strong><?php echo esc_html( $apartado['nombre'] ); ?></strong>
						<span><?php echo esc_html( $apartado['para_que'] ); ?></span>
					</a>
				<?php endforeach; ?>
			</div>
		<?php endforeach; ?>

		<p class="szs-pie">Las cifras salen de lo que el servidor tiene ahora; lo que haya en un móvil sin sincronizar no cuenta hasta que sincronice. La actividad «por persona» es la última huella que dejó al sincronizar o al usar esta oficina.</p>
	</div>
	<?php
}
