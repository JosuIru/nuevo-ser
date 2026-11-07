<?php
/**
 * El **resumen semanal por correo** (`docs/04-concejo.md` §4.5 y §4.7),
 * sobre todo para quien no usa la app: qué se decide ahora y hasta
 * cuándo, qué está en debate, qué se ha decidido esta semana y qué
 * compromisos vencen, y las asambleas de las dos próximas semanas. Cada
 * persona lo puede apagar con un enlace.
 *
 * Arriba, funciones puras (con `tests/test_correo.php`); abajo, el envío
 * con WP-Cron y `wp_mail`. Va en texto plano: se lee en cualquier
 * programa de correo y en móviles viejos.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const CONCEJO_OPCION_ULTIMO_RESUMEN = 'concejo_ultimo_resumen';
const CONCEJO_DIA_RESUMEN           = 1; // Lunes (ISO-8601: 1 = lunes … 7 = domingo).
const CONCEJO_EVENTO_DIARIO         = 'concejo_cada_dia';

// ----------------------------------------------------- funciones puras

/** «15 de noviembre», como la app (sin año: el correo es de esta semana). */
function concejo_fecha_legible( DateTimeImmutable $fecha ): string {
	$meses = array( 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' );
	return (int) $fecha->format( 'j' ) . ' de ' . $meses[ (int) $fecha->format( 'n' ) - 1 ];
}

/** Semana ISO («2026-W46»): para no mandar dos resúmenes la misma semana. */
function concejo_semana( DateTimeImmutable $momento ): string {
	return $momento->format( 'o-\WW' );
}

function concejo_toca_resumen( DateTimeImmutable $ahora, int $dia_semana, string $ultima_semana ): bool {
	return (int) $ahora->format( 'N' ) === $dia_semana && concejo_semana( $ahora ) !== $ultima_semana;
}

function concejo_firma_baja( string $persona_uid, string $clave ): string {
	return hash_hmac( 'sha256', 'baja|' . $persona_uid, $clave );
}

function concejo_firma_baja_valida( string $persona_uid, string $firma, string $clave ): bool {
	return hash_equals( concejo_firma_baja( $persona_uid, $clave ), $firma );
}

/**
 * El correo de una persona, o `null` si no hay nada que contarle (no se
 * manda un correo vacío) o la persona no existe.
 *
 * @return array{asunto: string, texto: string}|null
 */
function concejo_resumen_semanal(
	array $estado,
	string $persona_uid,
	string $nombre_espacio,
	DateTimeImmutable $ahora,
	DateTimeZone $zona,
	string $enlace_baja
): ?array {
	$persona = $estado['personas'][ $persona_uid ] ?? null;
	if ( null === $persona ) {
		return null;
	}
	$hace_una_semana = $ahora->modify( '-7 days' );
	$en_una_semana   = $ahora->modify( '+7 days' );

	$se_decide = array();
	$en_debate = array();
	$decidido  = array();
	$asuntos   = array_values( $estado['asuntos'] ?? array() );
	usort( $asuntos, fn( $a, $b ) => strcmp( (string) $a['fin_decision'], (string) $b['fin_decision'] ) );
	foreach ( $asuntos as $asunto ) {
		$fase              = concejo_fase( $asunto, $ahora, $zona );
		$es_consentimiento = 'consentimiento' === ( $asunto['reglas']['forma'] ?? '' );
		$titulo            = '- ' . $asunto['titulo'];
		$resumen           = '  ' . str_replace( "\n", "\n  ", trim( (string) $asunto['resumen'] ) );
		switch ( $fase ) {
			case 'decision':
				$cierre = concejo_fecha_legible( concejo_leer_fecha( $asunto['fin_decision'], $zona ) );
				if ( $es_consentimiento ) {
					$estado_persona = 'Se aprueba si nadie plantea una objeción razonada.';
				} else {
					$estado_persona = concejo_ha_participado( concejo_urna( $estado, $asunto['uid'] ), $persona_uid )
						? 'Ya has participado.'
						: 'Aún no has participado.';
				}
				$se_decide[] = "{$titulo} (cierra el {$cierre}). {$estado_persona}\n{$resumen}";
				break;
			case 'debate':
				$hasta       = concejo_fecha_legible( concejo_leer_fecha( $asunto['inicio_decision'], $zona ) );
				$en_debate[] = "{$titulo} (se debate hasta el {$hasta}).\n{$resumen}";
				break;
			case 'seguimiento':
				$fin             = concejo_leer_fecha( $asunto['fin_decision'], $zona );
				$consentimiento  = concejo_consentimiento( $estado, $asunto['uid'] );
				$esta_decidido   = ! $es_consentimiento || 'enCurso' !== $consentimiento['desenlace'];
				if ( $esta_decidido && $fin > $hace_una_semana ) {
					$decidido[] = $titulo;
				}
				break;
		}
	}

	$asambleas = array();
	$sesiones  = array_values( $estado['sesiones'] ?? array() );
	usort( $sesiones, fn( $a, $b ) => strcmp( (string) $a['inicio'], (string) $b['inicio'] ) );
	foreach ( $sesiones as $sesion ) {
		$inicio = concejo_leer_fecha( $sesion['inicio'], $zona );
		if ( $inicio <= $ahora || $inicio > $ahora->modify( '+14 days' ) ) {
			continue;
		}
		$cuando = concejo_fecha_legible( $inicio ) . ' a las ' . $inicio->format( 'H:i' );
		if ( ! empty( $sesion['anulada'] ) ) {
			$asambleas[] = '- ' . $sesion['titulo'] . " ({$cuando}): ANULADA. " . $sesion['motivo_anulacion'];
			continue;
		}
		$puntos = array();
		foreach ( $sesion['puntos'] as $indice => $punto ) {
			$puntos[] = '  ' . ( $indice + 1 ) . '. ' . $punto['texto'];
		}
		$asambleas[] = '- ' . $sesion['titulo'] . " ({$cuando}, {$sesion['lugar']}). Orden del día:\n" . implode( "\n", $puntos );
	}

	$compromisos = array();
	foreach ( $estado['compromisos'] ?? array() as $compromiso ) {
		if ( in_array( $compromiso['estado'], array( 'hecho', 'noSeHara' ), true ) ) {
			continue;
		}
		$limite = concejo_leer_fecha( $compromiso['fecha_limite'], $zona );
		// Como `Compromiso.vencidoEn`: el del 15 vence el 16.
		$vencido = $ahora >= $limite->modify( '+1 day' );
		if ( ! $vencido && $limite > $en_una_semana ) {
			continue;
		}
		$fecha         = concejo_fecha_legible( $limite );
		$compromisos[] = '- ' . $compromiso['que'] . ' (' . $compromiso['responsable'] . ', '
			. ( $vencido ? "venció el {$fecha}" : "para el {$fecha}" ) . ').';
	}

	// Tareas en común de las dos próximas semanas: si faltan manos y si
	// la persona va. Una anulada solo se cuenta a quien iba.
	$tareas_lista = array();
	$tareas       = array_values( $estado['tareas'] ?? array() );
	usort( $tareas, fn( $a, $b ) => strcmp( (string) $a['inicio'], (string) $b['inicio'] ) );
	foreach ( $tareas as $tarea ) {
		$inicio = concejo_leer_fecha( $tarea['inicio'], $zona );
		if ( $inicio <= $ahora || $inicio > $ahora->modify( '+14 days' ) || ! empty( $tarea['hecha'] ) ) {
			continue;
		}
		$voy    = in_array( $persona_uid, $tarea['apuntados_uids'] ?? array(), true );
		$cuando = concejo_fecha_legible( $inicio ) . ' a las ' . $inicio->format( 'H:i' )
			. ( '' !== (string) ( $tarea['lugar'] ?? '' ) ? ', ' . $tarea['lugar'] : '' );
		if ( ! empty( $tarea['anulada'] ) ) {
			if ( $voy ) {
				$tareas_lista[] = '- ' . $tarea['titulo'] . " ({$cuando}): ANULADA. " . $tarea['motivo_anulacion'];
			}
			continue;
		}
		$apuntadas = count( $tarea['apuntados_uids'] ?? array() );
		$plazas    = (int) ( $tarea['plazas'] ?? 0 );
		if ( $plazas > 0 ) {
			$faltan = max( 0, $plazas - $apuntadas );
			$cuenta = "Van {$apuntadas} de {$plazas}" . ( $faltan > 0 ? ": faltan {$faltan}." : '.' );
		} else {
			$cuenta = "Van {$apuntadas}.";
		}
		$tareas_lista[] = '- ' . $tarea['titulo'] . " ({$cuando}). {$cuenta}" . ( $voy ? ' Te has apuntado.' : '' );
	}

	// El tablón: lo fijado por la mesa y lo que otras personas han puesto
	// esta semana, si sigue vigente.
	$anuncios = array_values(
		array_filter(
			$estado['anuncios'] ?? array(),
			fn( $anuncio ) => concejo_anuncio_vigente( $anuncio, $ahora, $zona ) && (
				! empty( $anuncio['fijado'] ) || (
					$anuncio['autor_uid'] !== $persona_uid
					&& concejo_leer_fecha( (string) $anuncio['publicado'], $zona ) > $hace_una_semana
				)
			)
		)
	);
	usort(
		$anuncios,
		fn( $a, $b ) => array( empty( $a['fijado'] ), (string) $b['publicado'] ) <=> array( empty( $b['fijado'] ), (string) $a['publicado'] )
	);
	$tablon = array();
	foreach ( $anuncios as $anuncio ) {
		$autor   = $estado['personas'][ $anuncio['autor_uid'] ]['nombre'] ?? '';
		$linea   = '- ' . $anuncio['titulo'] . ( '' !== $autor ? " ({$autor})" : '' ) . '.';
		$cuerpo  = trim( (string) $anuncio['texto'] );
		$tablon[] = '' === $cuerpo ? $linea : $linea . "\n  " . str_replace( "\n", "\n  ", $cuerpo );
	}

	$mandato = array();
	$hasta   = $persona['mandato_hasta'] ?? null;
	if ( concejo_es_mesa( $persona, $ahora, $zona ) && null !== $hasta && '' !== $hasta ) {
		$fin_mandato = concejo_leer_fecha( $hasta, $zona );
		if ( $fin_mandato <= $ahora->modify( '+14 days' ) ) {
			$mandato[] = 'Tu cargo en la mesa acaba el ' . concejo_fecha_legible( $fin_mandato ) . '. Toca hablar de quién sigue.';
		}
	}

	if ( array() === $se_decide && array() === $en_debate && array() === $decidido && array() === $compromisos && array() === $mandato && array() === $asambleas && array() === $tablon && array() === $tareas_lista ) {
		return null;
	}

	$partes = array( 'Hola, ' . $persona['nombre'] . ":\n\nEsto es lo que hay esta semana en {$nombre_espacio}." );
	$seccion = function ( string $cabecera, array $lineas ) use ( &$partes ): void {
		if ( array() !== $lineas ) {
			$partes[] = $cabecera . "\n\n" . implode( "\n\n", $lineas );
		}
	};
	$seccion( 'PARA TI', $mandato );
	$seccion( 'PRÓXIMAS ASAMBLEAS', $asambleas );
	$seccion( 'TAREAS EN COMÚN', $tareas_lista );
	$seccion( 'SE DECIDE AHORA', $se_decide );
	$seccion( 'EN DEBATE', $en_debate );
	if ( array() !== $decidido ) {
		$decidido[] = 'El resultado y el acta están en la app; si no la usas, pídeselos a la mesa.';
	}
	$seccion( 'DECIDIDO ESTA SEMANA', $decidido );
	$seccion( 'TABLÓN', $tablon );
	$seccion( 'COMPROMISOS QUE VENCEN', $compromisos );
	$partes[] = 'Si no usas la app, también puedes opinar y votar en papel: habla con la mesa.';
	if ( '' !== $enlace_baja ) {
		$partes[] = "Si no quieres recibir este resumen:\n{$enlace_baja}";
	}

	return array(
		'asunto' => "{$nombre_espacio}: lo que hay esta semana",
		'texto'  => implode( "\n\n", $partes ) . "\n",
	);
}

// ------------------------------------------------------------- WordPress

if ( ! function_exists( 'add_action' ) ) {
	return; // En los tests sin WordPress, solo lo de arriba.
}

add_action( CONCEJO_EVENTO_DIARIO, 'concejo_enviar_resumen_si_toca' );
add_action( 'init', 'concejo_programar_evento_diario' );
add_action( 'admin_post_nopriv_concejo_baja', 'concejo_pagina_baja' );
add_action( 'admin_post_concejo_baja', 'concejo_pagina_baja' );

function concejo_programar_evento_diario(): void {
	if ( ! wp_next_scheduled( CONCEJO_EVENTO_DIARIO ) ) {
		wp_schedule_event( time(), 'daily', CONCEJO_EVENTO_DIARIO );
	}
}

function concejo_desprogramar_evento_diario(): void {
	wp_clear_scheduled_hook( CONCEJO_EVENTO_DIARIO );
}

function concejo_clave_baja(): string {
	return wp_salt( 'auth' );
}

function concejo_enlace_baja( string $persona_uid ): string {
	return add_query_arg(
		array(
			'action'  => 'concejo_baja',
			'persona' => $persona_uid,
			'firma'   => concejo_firma_baja( $persona_uid, concejo_clave_baja() ),
		),
		admin_url( 'admin-post.php' )
	);
}

/** @return array[] uid, nombre y correo de quien quiere el resumen. */
function concejo_destinatarios_resumen(): array {
	global $wpdb;
	return (array) $wpdb->get_results(
		'SELECT uid, nombre, correo FROM ' . concejo_tabla( 'personas' ) . " WHERE activa = 1 AND correo <> '' AND resumen = 'semanal'",
		ARRAY_A
	);
}

function concejo_enviar_resumen_si_toca(): void {
	$ahora = concejo_ahora();
	if ( ! concejo_toca_resumen( $ahora, CONCEJO_DIA_RESUMEN, (string) get_option( CONCEJO_OPCION_ULTIMO_RESUMEN, '' ) ) ) {
		return;
	}
	// Se apunta antes de enviar: si algo falla a mitad, mejor un resumen
	// de menos que uno repetido.
	update_option( CONCEJO_OPCION_ULTIMO_RESUMEN, concejo_semana( $ahora ), false );
	concejo_enviar_resumenes();
}

/** Manda el resumen a quien lo quiere. Devuelve cuántos se han enviado. */
function concejo_enviar_resumenes(): int {
	$estado   = concejo_cargar_estado();
	$ahora    = concejo_ahora();
	$enviados = 0;
	foreach ( concejo_destinatarios_resumen() as $destinatario ) {
		$correo = concejo_resumen_semanal( $estado, $destinatario['uid'], concejo_nombre_espacio(), $ahora, concejo_zona(), concejo_enlace_baja( $destinatario['uid'] ) );
		if ( null !== $correo && wp_mail( $destinatario['correo'], $correo['asunto'], $correo['texto'] ) ) {
			++$enviados;
		}
	}
	return $enviados;
}

/**
 * El enlace del correo enseña un botón; la baja se hace al pulsarlo (POST).
 * Así no la dispara un programa de correo que abre los enlaces solo.
 */
function concejo_pagina_baja(): void {
	$persona_uid = sanitize_text_field( wp_unslash( (string) ( $_REQUEST['persona'] ?? '' ) ) );
	$firma       = sanitize_text_field( wp_unslash( (string) ( $_REQUEST['firma'] ?? '' ) ) );
	if ( '' === $persona_uid || ! concejo_firma_baja_valida( $persona_uid, $firma, concejo_clave_baja() ) ) {
		wp_die( 'Este enlace no vale. Si quieres dejar de recibir el resumen, díselo a la mesa.', 'Concejo', array( 'response' => 400 ) );
	}
	$espacio = esc_html( concejo_nombre_espacio() );
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? 'GET' ) ) {
		global $wpdb;
		$wpdb->update( concejo_tabla( 'personas' ), array( 'resumen' => 'nunca' ), array( 'uid' => $persona_uid ) );
		wp_die( "Hecho: ya no recibirás el resumen semanal de {$espacio}. Si quieres volver a recibirlo, díselo a la mesa.", 'Concejo', array( 'response' => 200 ) );
	}
	$accion = esc_url( admin_url( 'admin-post.php' ) );
	wp_die(
		"<p>¿Dejar de recibir el resumen semanal de {$espacio}?</p>"
		. '<form method="post" action="' . $accion . '">'
		. '<input type="hidden" name="action" value="concejo_baja">'
		. '<input type="hidden" name="persona" value="' . esc_attr( $persona_uid ) . '">'
		. '<input type="hidden" name="firma" value="' . esc_attr( $firma ) . '">'
		. '<button type="submit">Sí, no quiero recibirlo</button></form>',
		'Concejo',
		array( 'response' => 200 )
	);
}
