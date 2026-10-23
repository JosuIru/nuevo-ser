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
 * Idioma: cada destinatario lo recibe en el de su usuario de WordPress
 * enlazado (o en el del sitio), con `szs_correos_coordinacion_por_idioma()`
 * y `szs_con_idioma()`: un correo por idioma.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_EVENTO_CORREO_DIARIO = 'szs_correo_diario';
const SZS_HORA_CORREO_DIARIO   = 8;
const SZS_MAXIMO_CORREOS_AL_MOMENTO_POR_HORA = 10;

add_action( 'init', 'szs_programar_correo_diario' );
add_action( SZS_EVENTO_CORREO_DIARIO, 'szs_enviar_correo_diario' );
add_action( 'szs_entidad_guardada', 'szs_avisar_por_correo_al_momento', 10, 3 );

/**
 * Programa el próximo resumen como evento único a las 8:00 de la hora
 * local. Un evento `daily` repite cada 86.400 s fijos y, con el cambio de
 * hora, pasaría a llegar a las 7:00 (o a las 9:00 en primavera). Cuando el
 * evento se ejecuta, WordPress lo quita y la siguiente petición programa
 * el del día siguiente.
 */
function szs_programar_correo_diario(): void {
	// Instalaciones anteriores lo tenían como `daily`.
	if ( 'daily' === wp_get_schedule( SZS_EVENTO_CORREO_DIARIO ) ) {
		wp_clear_scheduled_hook( SZS_EVENTO_CORREO_DIARIO );
	}
	if ( wp_next_scheduled( SZS_EVENTO_CORREO_DIARIO ) ) {
		return;
	}
	wp_schedule_single_event( szs_proximas_8_de_la_manana( time(), wp_timezone() ), SZS_EVENTO_CORREO_DIARIO );
}

/** Instante (s) de las próximas 8:00 locales después de `$ahora`. */
function szs_proximas_8_de_la_manana( int $ahora, DateTimeZone $zona ): int {
	$hoy     = ( new DateTimeImmutable( '@' . $ahora ) )->setTimezone( $zona );
	$proxima = $hoy->setTime( SZS_HORA_CORREO_DIARIO, 0 );
	if ( $proxima->getTimestamp() <= $ahora ) {
		$proxima = $hoy->modify( '+1 day' )->setTime( SZS_HORA_CORREO_DIARIO, 0 );
	}
	return $proxima->getTimestamp();
}

function szs_desprogramar_correo_diario(): void {
	wp_clear_scheduled_hook( SZS_EVENTO_CORREO_DIARIO );
}

/**
 * @return bool true si se envió (había algo que contar y destinatarios).
 */
function szs_enviar_correo_diario(): bool {
	$destinatarios_por_idioma = szs_correos_coordinacion_por_idioma();
	if ( empty( $destinatarios_por_idioma ) ) {
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
	$tareas  = szs_listar_todas_las_tareas();
	$enviado = false;
	foreach ( $destinatarios_por_idioma as $idioma => $destinatarios ) {
		$enviado = szs_con_idioma(
			$idioma,
			static function () use ( $tareas, $peticiones, $alarmas, $destinatarios, $idioma ): bool {
				$resumen = szs_resumen_correo_diario( $tareas, $peticiones, $alarmas, szs_inicio_de_hoy_ms() );
				if ( null === $resumen ) {
					return false;
				}
				$pie = "\n" . szs_t( 'Panel de coordinación: %s', admin_url( 'admin.php?page=' . SZS_PAGINA_TAREAS ) ) . "\n" . szs_pie_correo();
				return szs_enviar_correo( $destinatarios, $resumen['asunto'], $resumen['cuerpo'] . $pie, $idioma );
			}
		) || $enviado;
	}
	return $enviado;
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
		$asunto_en      = static fn() => szs_t( 'Larrea Zunbeltz: alarma — %s', $titulo );
		$introduccion_en = static fn() => szs_t( 'Han dado una alarma en el espacio.' );
		$pagina         = SZS_PAGINA_AVISOS;
	} elseif ( 'peticion' === $entidad['tipo'] && ! empty( $datos['urgente'] ) ) {
		$asunto_en      = static fn() => szs_t( 'Larrea Zunbeltz: petición urgente — %s', $titulo );
		$introduccion_en = static fn() => szs_t( 'Han pedido una tarea urgente.' );
		$pagina         = SZS_PAGINA_PETICIONES;
	} else {
		return;
	}
	$destinatarios_por_idioma = szs_correos_coordinacion_por_idioma();
	if ( empty( $destinatarios_por_idioma ) ) {
		return;
	}
	// Una sincronización con muchas urgentes de golpe no debe mandar
	// decenas de correos (y quemar el SMTP): pasado el límite, lo recoge
	// el resumen de la mañana.
	$enviados_esta_hora = (int) get_transient( 'szs_correos_al_momento' );
	if ( $enviados_esta_hora >= SZS_MAXIMO_CORREOS_AL_MOMENTO_POR_HORA ) {
		return;
	}
	set_transient( 'szs_correos_al_momento', $enviados_esta_hora + 1, HOUR_IN_SECONDS );
	foreach ( $destinatarios_por_idioma as $idioma => $destinatarios ) {
		szs_con_idioma(
			$idioma,
			static function () use ( $destinatarios, $asunto_en, $introduccion_en, $pagina, $titulo, $datos, $persona, $idioma ): void {
				$cuerpo = szs_cuerpo_correo_al_momento(
					$introduccion_en(),
					$titulo,
					(string) ( $datos['descripcion'] ?? '' ),
					(string) ( $persona['nombre'] ?? '' ),
					admin_url( 'admin.php?page=' . $pagina )
				);
				// Se envía al terminar la petición, ya soltado el candado del
				// espacio: un SMTP lento no debe dejar al resto de móviles esperando.
				szs_encolar_correo( $destinatarios, $asunto_en(), $cuerpo, $idioma );
			}
		);
	}
}

/**
 * Cuerpo del correo de una alarma o petición urgente: qué ha pasado, el
 * texto, quién lo manda y dónde verlo. Un cuerpo de dos líneas sin
 * contexto es de lo que los filtros de correo desconfían.
 */
function szs_cuerpo_correo_al_momento( string $introduccion, string $titulo, string $descripcion, string $nombre, string $enlace ): string {
	$lineas = array( $introduccion, '', '«' . $titulo . '»' );
	if ( '' !== trim( $descripcion ) ) {
		$lineas[] = trim( $descripcion );
	}
	$lineas[] = '';
	if ( '' !== trim( $nombre ) ) {
		$lineas[] = szs_t( 'Lo envía: %s', $nombre );
	}
	$lineas[] = szs_t( 'Para verlo y responder: %s', $enlace );
	return implode( "\n", $lineas ) . "\n" . szs_pie_correo();
}

/** Pie común: de dónde viene y por qué le llega. */
function szs_pie_correo(): string {
	return "\n—\nLarrea Zunbeltz · " . wp_parse_url( home_url(), PHP_URL_HOST ) . "\n"
		. szs_t( 'Te llega porque coordinas el espacio en Larrea Zunbeltz.' ) . "\n";
}

/**
 * Cabeceras de los correos: texto plano en UTF-8 y con su idioma (sin él,
 * Gmail tomaba por inglés un correo corto en castellano).
 *
 * @return string[]
 */
function szs_cabeceras_correo( string $idioma ): array {
	return array(
		'Content-Type: text/plain; charset=UTF-8',
		'Content-Language: ' . ( 'eu' === $idioma ? 'eu' : 'es' ),
	);
}

/** Nombre del remitente de los correos del plugin (no el de todo WordPress). */
function szs_nombre_remitente_correo(): string {
	return 'Larrea Zunbeltz';
}

/**
 * `wp_mail` con nuestras cabeceras y «Larrea Zunbeltz» como remitente en
 * lugar de «WordPress». La dirección la pone WordPress o el plugin de SMTP.
 */
function szs_enviar_correo( array $destinatarios, string $asunto, string $cuerpo, string $idioma ): bool {
	add_filter( 'wp_mail_from_name', 'szs_nombre_remitente_correo' );
	try {
		return wp_mail( $destinatarios, $asunto, $cuerpo, szs_cabeceras_correo( $idioma ) );
	} finally {
		remove_filter( 'wp_mail_from_name', 'szs_nombre_remitente_correo' );
	}
}

/** @var array<int, array{0: string[], 1: string, 2: string, 3: string}> */
$GLOBALS['szs_correos_pendientes'] = array();

function szs_encolar_correo( array $destinatarios, string $asunto, string $cuerpo, string $idioma = 'es' ): void {
	if ( empty( $GLOBALS['szs_correos_pendientes'] ) ) {
		add_action( 'shutdown', 'szs_enviar_correos_pendientes' );
	}
	$GLOBALS['szs_correos_pendientes'][] = array( $destinatarios, $asunto, $cuerpo, $idioma );
}

function szs_enviar_correos_pendientes(): void {
	$pendientes                        = $GLOBALS['szs_correos_pendientes'];
	$GLOBALS['szs_correos_pendientes'] = array();
	foreach ( $pendientes as list( $destinatarios, $asunto, $cuerpo, $idioma ) ) {
		szs_enviar_correo( $destinatarios, $asunto, $cuerpo, $idioma );
	}
}
