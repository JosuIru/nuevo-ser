<?php
/**
 * Avisos por correo a coordinación (personas de coordinación con correo, o
 * el de su usuario de WordPress enlazado):
 *
 * - **Resumen diario** a las 8:00 (hora del WordPress): tareas vencidas,
 *   peticiones pendientes y alarmas abiertas. Si no hay nada, no se manda.
 * - **Al momento**: cuando entra una alarma de campo o una petición
 *   urgente.
 *
 * Usa `wp_mail`: el WordPress de Zunbeltz tiene que poder enviar correo
 * (SMTP configurado en el hosting o con un plugin de SMTP).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_EVENTO_CORREO_DIARIO = 'szs_correo_diario';
const SZS_HORA_CORREO_DIARIO   = 8;

add_action( 'init', 'szs_programar_correo_diario' );
add_action( SZS_EVENTO_CORREO_DIARIO, 'szs_enviar_correo_diario' );
add_action( 'szs_entidad_guardada', 'szs_avisar_por_correo_al_momento', 10, 3 );

function szs_programar_correo_diario(): void {
	if ( wp_next_scheduled( SZS_EVENTO_CORREO_DIARIO ) ) {
		return;
	}
	$proxima = new DateTimeImmutable( 'today ' . SZS_HORA_CORREO_DIARIO . ':00', wp_timezone() );
	if ( $proxima->getTimestamp() <= time() ) {
		$proxima = $proxima->modify( '+1 day' );
	}
	wp_schedule_event( $proxima->getTimestamp(), 'daily', SZS_EVENTO_CORREO_DIARIO );
}

function szs_desprogramar_correo_diario(): void {
	wp_clear_scheduled_hook( SZS_EVENTO_CORREO_DIARIO );
}

/**
 * @return bool true si se envió (había algo que contar y destinatarios).
 */
function szs_enviar_correo_diario(): bool {
	$destinatarios = szs_correos_coordinacion();
	if ( empty( $destinatarios ) ) {
		return false;
	}
	$peticiones = array();
	foreach ( szs_listar_entidades_tipo( 'peticion' ) as $peticion ) {
		if ( 'pendiente' === ( $peticion['datos']['estado'] ?? 'pendiente' ) ) {
			$peticiones[] = szs_etiqueta_entidad( $peticion );
		}
	}
	$alarmas = array();
	foreach ( szs_listar_entidades_tipo( 'aviso' ) as $aviso ) {
		if ( 'alarma' === ( $aviso['datos']['gravedad'] ?? '' ) && 'abierto' === ( $aviso['datos']['estado'] ?? 'abierto' ) ) {
			$alarmas[] = szs_etiqueta_entidad( $aviso );
		}
	}
	$resumen = szs_resumen_correo_diario( szs_listar_todas_las_tareas(), $peticiones, $alarmas, szs_inicio_de_hoy_ms() );
	if ( null === $resumen ) {
		return false;
	}
	$pie = "\n—\nPanel de coordinación: " . admin_url( 'admin.php?page=' . SZS_PAGINA_TAREAS ) . "\n";
	return wp_mail( $destinatarios, $resumen['asunto'], $resumen['cuerpo'] . $pie );
}

/**
 * Alarma de campo o petición urgente recién creadas: correo al momento.
 */
function szs_avisar_por_correo_al_momento( array $entidad, ?array $existente, array $persona ): void {
	if ( null !== $existente || $entidad['borrado'] ) {
		return;
	}
	$datos  = $entidad['datos'];
	$titulo = szs_etiqueta_entidad( $entidad );
	if ( 'aviso' === $entidad['tipo'] && 'alarma' === ( $datos['gravedad'] ?? '' ) ) {
		$asunto = "Solera Zunbeltz: alarma — {$titulo}";
	} elseif ( 'peticion' === $entidad['tipo'] && ! empty( $datos['urgente'] ) ) {
		$asunto = "Solera Zunbeltz: petición urgente — {$titulo}";
	} else {
		return;
	}
	$destinatarios = szs_correos_coordinacion();
	if ( empty( $destinatarios ) ) {
		return;
	}
	$cuerpo = sprintf(
		"%s\n\n%s\n\nLo envía: %s\n",
		$titulo,
		(string) ( $datos['descripcion'] ?? '' ),
		(string) ( $persona['nombre'] ?? '' )
	);
	wp_mail( $destinatarios, $asunto, $cuerpo );
}
