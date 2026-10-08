<?php
/**
 * Panel de coordinación en el escritorio de WordPress: menú, permisos y
 * utilidades comunes a sus páginas (tareas, peticiones, avisos, proyectos,
 * actividad y personas).
 *
 * Quién entra: quien tenga la capacidad de WordPress
 * `gestionar_solera_zunbeltz` (los administradores la reciben al activar el
 * plugin; una persona de coordinación la recibe al enlazarla con su usuario
 * de WordPress en «Personas»). Así el dinamizador puede usar el panel sin
 * ser administrador del WordPress.
 *
 * Lo que se hace aquí queda en el registro de actividad con origen
 * `panel` y a nombre de la persona enlazada con el usuario (o del propio
 * usuario de WordPress si no está enlazado).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_CAPACIDAD_WP_PANEL = 'gestionar_solera_zunbeltz';
const SZS_PAGINA_TAREAS      = 'solera-zunbeltz';
const SZS_PAGINA_PETICIONES  = 'solera-zunbeltz-peticiones';
const SZS_PAGINA_AVISOS      = 'solera-zunbeltz-avisos';
const SZS_PAGINA_PROYECTOS   = 'solera-zunbeltz-proyectos';
const SZS_PAGINA_ACTIVIDAD   = 'solera-zunbeltz-actividad';
const SZS_PAGINA_PERSONAS    = 'solera-zunbeltz-personas';

add_action( 'admin_menu', 'szs_registrar_menu_panel' );

function szs_registrar_menu_panel(): void {
	$capacidad = SZS_CAPACIDAD_WP_PANEL;
	$pendientes = szs_contar_peticiones_pendientes();
	$burbuja    = $pendientes > 0 ? sprintf( ' <span class="awaiting-mod">%d</span>', $pendientes ) : '';

	add_menu_page( 'Solera Zunbeltz', 'Solera Zunbeltz' . $burbuja, $capacidad, SZS_PAGINA_TAREAS, 'szs_pagina_tareas', 'dashicons-location-alt', 80 );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Tareas', 'Tareas', $capacidad, SZS_PAGINA_TAREAS, 'szs_pagina_tareas' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Peticiones de tarea', 'Peticiones' . $burbuja, $capacidad, SZS_PAGINA_PETICIONES, 'szs_pagina_peticiones' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Avisos', 'Avisos', $capacidad, SZS_PAGINA_AVISOS, 'szs_pagina_avisos' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Proyectos de test', 'Proyectos', $capacidad, SZS_PAGINA_PROYECTOS, 'szs_pagina_proyectos' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Actividad del espacio', 'Actividad', $capacidad, SZS_PAGINA_ACTIVIDAD, 'szs_pagina_actividad' );
	add_submenu_page( SZS_PAGINA_TAREAS, 'Personas del espacio', 'Personas', $capacidad, SZS_PAGINA_PERSONAS, 'szs_pagina_admin' );
	// Acceso directo a la app web que sirve este mismo WordPress en /app/.
	add_submenu_page( SZS_PAGINA_TAREAS, 'App web', 'Abrir la app ↗', $capacidad, szs_url_app_web() );
}

/** Los administradores siempre pueden usar el panel. */
function szs_dar_capacidad_panel_a_administradores(): void {
	$rol = get_role( 'administrator' );
	if ( null !== $rol && ! $rol->has_cap( SZS_CAPACIDAD_WP_PANEL ) ) {
		$rol->add_cap( SZS_CAPACIDAD_WP_PANEL );
	}
}

function szs_puede_usar_panel(): bool {
	return current_user_can( SZS_CAPACIDAD_WP_PANEL );
}

/**
 * Persona en cuyo nombre actúa el panel: la enlazada con el usuario de
 * WordPress conectado o, si no hay, una persona de coordinación con el
 * nombre del usuario.
 */
function szs_persona_del_panel(): array {
	global $wpdb;
	$usuario = wp_get_current_user();
	$tabla   = szs_tabla_personas();
	$fila    = $wpdb->get_row(
		$wpdb->prepare( "SELECT uid, nombre, rol FROM {$tabla} WHERE wp_user_id = %d AND activo = 1", (int) $usuario->ID ),
		ARRAY_A
	);
	if ( is_array( $fila ) ) {
		return $fila;
	}
	return array(
		'uid'    => 'wp-' . (int) $usuario->ID,
		'nombre' => '' !== $usuario->display_name ? $usuario->display_name : $usuario->user_login,
		'rol'    => SZS_ROL_COORDINADOR,
	);
}

function szs_ahora_ms(): int {
	return (int) round( microtime( true ) * 1000 );
}

/** Medianoche de hoy en la zona horaria del WordPress, en ms. */
function szs_inicio_de_hoy_ms(): int {
	$hoy = new DateTimeImmutable( 'today', wp_timezone() );
	return $hoy->getTimestamp() * 1000;
}

function szs_fecha_ms( ?int $ms, string $formato = 'd/m/Y' ): string {
	if ( null === $ms || 0 === $ms ) {
		return '—';
	}
	return wp_date( $formato, intdiv( $ms, 1000 ) );
}

/** `Y-m-d` de un formulario → ms a mediodía local (evita saltos de día). */
function szs_ms_desde_fecha( string $fecha ): ?int {
	if ( ! preg_match( '/^\d{4}-\d{2}-\d{2}$/', $fecha ) ) {
		return null;
	}
	$momento = DateTimeImmutable::createFromFormat( 'Y-m-d H:i', $fecha . ' 12:00', wp_timezone() );
	return false === $momento ? null : $momento->getTimestamp() * 1000;
}

function szs_euros( ?int $centimos ): string {
	return null === $centimos ? '—' : number_format( $centimos / 100, 2, ',', '.' ) . ' €';
}

function szs_centimos_desde_texto( string $texto ): ?int {
	$texto = trim( str_replace( array( '.', ',' ), array( '', '.' ), $texto ) );
	return '' === $texto || ! is_numeric( $texto ) ? null : (int) round( (float) $texto * 100 );
}

function szs_url_pagina( string $pagina, array $argumentos = array() ): string {
	return add_query_arg( array_merge( array( 'page' => $pagina ), $argumentos ), admin_url( 'admin.php' ) );
}

function szs_campo_post( string $clave, string $por_defecto = '' ): string {
	return isset( $_POST[ $clave ] ) ? sanitize_text_field( wp_unslash( $_POST[ $clave ] ) ) : $por_defecto; // phpcs:ignore WordPress.Security.NonceVerification
}

function szs_texto_largo_post( string $clave ): string {
	return isset( $_POST[ $clave ] ) ? sanitize_textarea_field( wp_unslash( $_POST[ $clave ] ) ) : ''; // phpcs:ignore WordPress.Security.NonceVerification
}

function szs_campo_get( string $clave, string $por_defecto = '' ): string {
	return isset( $_GET[ $clave ] ) ? sanitize_text_field( wp_unslash( $_GET[ $clave ] ) ) : $por_defecto; // phpcs:ignore WordPress.Security.NonceVerification
}

function szs_mostrar_aviso_panel( ?array $aviso ): void {
	if ( null === $aviso ) {
		return;
	}
	printf( '<div class="notice notice-%s is-dismissible"><p>%s</p></div>', esc_attr( $aviso[0] ), esc_html( $aviso[1] ) );
}

/** Nombre de cada persona por uid (activas o no). */
function szs_nombres_personas(): array {
	$nombres = array();
	foreach ( szs_listar_personas( false ) as $persona ) {
		$nombres[ $persona['uid'] ] = $persona['nombre'];
	}
	return $nombres;
}

/**
 * Entidades de un tipo, normalizadas, sin las borradas.
 *
 * @return array<int, array>
 */
function szs_listar_entidades_tipo( string $tipo, string $proyecto_uid = '' ): array {
	global $wpdb;
	$tabla = szs_tabla_entidades();
	$sql   = '' === $proyecto_uid
		? $wpdb->prepare( "SELECT * FROM {$tabla} WHERE tipo = %s AND borrado = 0 ORDER BY actualizado_ms DESC", $tipo )
		: $wpdb->prepare( "SELECT * FROM {$tabla} WHERE tipo = %s AND proyecto_uid = %s AND borrado = 0 ORDER BY actualizado_ms DESC", $tipo, $proyecto_uid );
	return array_map( 'szs_fila_a_entidad', (array) $wpdb->get_results( $sql, ARRAY_A ) );
}

/** Nombre de cada finca por uid. */
function szs_nombres_fincas(): array {
	$nombres = array();
	foreach ( szs_listar_entidades_tipo( 'finca' ) as $finca ) {
		$nombres[ $finca['uid'] ] = szs_etiqueta_entidad( $finca );
	}
	asort( $nombres );
	return $nombres;
}

/**
 * Crea o cambia una entidad desde el panel con la marca de tiempo de ahora,
 * deja huella en la actividad y avisa (correo inmediato, etc.).
 *
 * Si mientras tanto alguien la ha borrado (un formulario abierto de antes),
 * no se toca: guardarla la resucitaría en todos los móviles.
 */
function szs_guardar_entidad_desde_panel( string $tipo, string $uid, array $datos, string $proyecto_uid = '' ): array {
	// Sin candado no se escribe: es la carrera que el candado evita.
	if ( ! szs_tomar_candado_espacio() ) {
		wp_die( 'El espacio está ocupado sincronizando con los móviles. Vuelve atrás e inténtalo de nuevo en unos segundos.', 'Solera Zunbeltz', array( 'back_link' => true ) );
	}
	try {
		return szs_guardar_entidad_desde_panel_con_candado( $tipo, $uid, $datos, $proyecto_uid );
	} finally {
		szs_soltar_candado_espacio();
	}
}

function szs_guardar_entidad_desde_panel_con_candado( string $tipo, string $uid, array $datos, string $proyecto_uid ): array {
	$persona   = szs_persona_del_panel();
	$existente = szs_obtener_entidad( $tipo, $uid );
	if ( null !== $existente && $existente['borrado'] ) {
		return $existente;
	}
	$entidad   = szs_normalizar_entidad(
		array(
			'tipo'           => $tipo,
			'uid'            => $uid,
			'actualizado_ms' => max( szs_ahora_ms(), null === $existente ? 0 : $existente['actualizado_ms'] + 1 ),
			'borrado'        => false,
			'proyecto_uid'   => '' !== $proyecto_uid ? $proyecto_uid : ( null === $existente ? '' : $existente['proyecto_uid'] ),
			'datos'          => null === $existente ? $datos : array_merge( $existente['datos'], $datos ),
		)
	);
	$guardada = szs_guardar_entidad( $entidad, $existente, null === $existente ? (string) $persona['uid'] : $existente['autor_uid'] );
	szs_registrar_actividad( $persona, szs_accion_entidad( $existente, $guardada ), $tipo, $uid, szs_etiqueta_entidad( $guardada ), szs_contexto_entidad( $guardada ), '', 'panel' );
	do_action( 'szs_entidad_guardada', $guardada, $existente, $persona );
	return $guardada;
}

function szs_nuevo_uid(): string {
	return bin2hex( random_bytes( 16 ) );
}

function szs_contar_peticiones_pendientes(): int {
	$pendientes = 0;
	foreach ( szs_listar_entidades_tipo( 'peticion' ) as $peticion ) {
		if ( 'pendiente' === ( $peticion['datos']['estado'] ?? 'pendiente' ) ) {
			$pendientes++;
		}
	}
	return $pendientes;
}

/** `<select>` con las opciones dadas (`valor => etiqueta`). */
function szs_selector( string $nombre, array $opciones, string $seleccionado, string $vacio = '' ): void {
	printf( '<select name="%s" id="%s">', esc_attr( $nombre ), esc_attr( $nombre ) );
	if ( '' !== $vacio ) {
		printf( '<option value="">%s</option>', esc_html( $vacio ) );
	}
	foreach ( $opciones as $valor => $etiqueta ) {
		printf( '<option value="%s"%s>%s</option>', esc_attr( (string) $valor ), selected( (string) $valor, $seleccionado, false ), esc_html( (string) $etiqueta ) );
	}
	echo '</select>';
}

/** Estados, prioridades… como los muestra la app. */
const SZS_ESTADOS_TAREA = array(
	'pendiente' => 'Pendiente',
	'en_curso'  => 'En curso',
	'hecha'     => 'Hecha',
	'bloqueada' => 'Bloqueada',
);
const SZS_PRIORIDADES_TAREA = array(
	'baja'  => 'Baja',
	'media' => 'Media',
	'alta'  => 'Alta',
);
const SZS_CATEGORIAS_AVISO = array(
	'ganado'        => 'Ganado',
	'instalaciones' => 'Instalaciones',
	'seguimiento'   => 'Seguimiento individual',
	'noticias'      => 'Noticias',
);
