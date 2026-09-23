<?php
/**
 * Plugin Name: Solera Zunbeltz — Sincronización de tareas
 * Plugin URI:  https://coleccion-nuevo-ser.com/
 * Description: Sincroniza las tareas de mantenimiento de la app Solera Zunbeltz
 *              entre los dispositivos del Espacio Test, usando el WordPress
 *              propio de Zunbeltz Elkartea como backend. Gestiona las
 *              personas del espacio, sus roles y sus tokens personales.
 * Version:     0.2.0
 * Author:      Equipo Colección Nuevo Ser
 * Author URI:  https://coleccion-nuevo-ser.com/
 * License:     GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: solera-zunbeltz-sync
 * Requires PHP: 8.1
 * Requires at least: 6.4
 *
 * ============================================================
 * ALCANCE Y LIMITACIONES (léase antes de instalar en producción)
 * ============================================================
 *
 * **Solo sincroniza tareas de mantenimiento**, no fincas, puntos, zonas,
 * ni el cuaderno ganadero (que todavía no existe — ver FZ-4 en el roadmap).
 *
 * Auth (v0.2): **un token personal por persona**, creado desde el admin de
 * WordPress (menú "Solera Zunbeltz"). Cada persona tiene un rol y cada rol
 * un conjunto de capacidades (`includes/roles.php`); el servidor aplica los
 * permisos al sincronizar (`includes/politica-tareas.php`), la app sólo
 * adapta la interfaz. Roles de partida: coordinación (admin) y tester. El
 * reparto concreto de permisos está pendiente de co-diseño con Zunbeltz —
 * ver `apps/solera-zunbeltz/BLOQUEOS-PENDIENTES.md` §C en el monorepo.
 *
 * Multi-espacio: cada Espacio Test instala el plugin en su propio
 * WordPress, así que cada instalación es un espacio aislado.
 *
 * Fincas/puntos/zonas no viajan por id (son locales a cada dispositivo);
 * el cliente empareja por **nombre de finca**. Una tarea anclada a un
 * punto o zona concreto pierde ese anclaje al llegar a otro dispositivo.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'SZS_VERSION', '0.2.0' );
define( 'SZS_VERSION_ESQUEMA', 2 );
define( 'SZS_TABLA', 'solera_zunbeltz_tareas' );
define( 'SZS_TABLA_PERSONAS', 'solera_zunbeltz_personas' );
define( 'SZS_OPCION_VERSION_ESQUEMA', 'solera_zunbeltz_sync_esquema' );
/** Token compartido de la v0.1, retirado en la v0.2. */
define( 'SZS_OPCION_TOKEN_COMPARTIDO_V1', 'solera_zunbeltz_sync_token' );

require_once __DIR__ . '/includes/roles.php';
require_once __DIR__ . '/includes/politica-tareas.php';
require_once __DIR__ . '/includes/personas.php';
require_once __DIR__ . '/includes/admin.php';

// ============================================================
// Esquema: se crea al activar y se actualiza al cargar si cambió
// de versión (actualizar el plugin no dispara la activación).
// ============================================================

register_activation_hook( __FILE__, 'szs_instalar_esquema' );
add_action( 'plugins_loaded', 'szs_actualizar_esquema_si_hace_falta' );

function szs_actualizar_esquema_si_hace_falta(): void {
	if ( (int) get_option( SZS_OPCION_VERSION_ESQUEMA, 0 ) < SZS_VERSION_ESQUEMA ) {
		szs_instalar_esquema();
	}
}

function szs_instalar_esquema(): void {
	global $wpdb;
	$tabla_tareas    = $wpdb->prefix . SZS_TABLA;
	$tabla_personas  = $wpdb->prefix . SZS_TABLA_PERSONAS;
	$charset_collate = $wpdb->get_charset_collate();

	require_once ABSPATH . 'wp-admin/includes/upgrade.php';
	dbDelta(
		"CREATE TABLE {$tabla_tareas} (
		uid VARCHAR(64) NOT NULL,
		finca_nombre VARCHAR(255) NOT NULL DEFAULT '',
		titulo VARCHAR(500) NOT NULL DEFAULT '',
		descripcion TEXT NULL,
		responsable VARCHAR(255) NOT NULL DEFAULT '',
		responsable_uid VARCHAR(64) NOT NULL DEFAULT '',
		creado_por_uid VARCHAR(64) NOT NULL DEFAULT '',
		prioridad VARCHAR(32) NOT NULL DEFAULT 'media',
		estado VARCHAR(32) NOT NULL DEFAULT 'pendiente',
		fecha_objetivo_ms BIGINT NULL,
		coste_centimos BIGINT NULL,
		recurrencia_dias INT NULL,
		fecha_creacion_ms BIGINT NOT NULL DEFAULT 0,
		actualizado_ms BIGINT NOT NULL DEFAULT 0,
		recibido_en DATETIME NOT NULL,
		PRIMARY KEY  (uid),
		KEY responsable_uid (responsable_uid),
		KEY creado_por_uid (creado_por_uid)
	) {$charset_collate};"
	);
	dbDelta(
		"CREATE TABLE {$tabla_personas} (
		uid VARCHAR(64) NOT NULL,
		nombre VARCHAR(255) NOT NULL DEFAULT '',
		rol VARCHAR(64) NOT NULL DEFAULT 'tester',
		token_hash CHAR(64) NOT NULL,
		activo TINYINT(1) NOT NULL DEFAULT 1,
		creado_en DATETIME NOT NULL,
		PRIMARY KEY  (uid),
		UNIQUE KEY token_hash (token_hash)
	) {$charset_collate};"
	);

	// El token compartido de la v0.1 daba acceso total sin identificar a
	// nadie: se retira para que no quede un secreto huérfano.
	delete_option( SZS_OPCION_TOKEN_COMPARTIDO_V1 );
	update_option( SZS_OPCION_VERSION_ESQUEMA, SZS_VERSION_ESQUEMA );
}

// ============================================================
// REST
//   GET  /solera-zunbeltz/v1/yo           quién soy + personas del espacio
//   POST /solera-zunbeltz/v1/tareas/sync  sube y baja tareas
// ============================================================

add_action( 'rest_api_init', 'szs_registrar_rutas' );

function szs_registrar_rutas(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/yo',
		array(
			'methods'             => 'GET',
			'callback'            => 'szs_endpoint_yo',
			'permission_callback' => 'szs_permiso_token',
		)
	);
	register_rest_route(
		'solera-zunbeltz/v1',
		'/tareas/sync',
		array(
			'methods'             => 'POST',
			'callback'            => 'szs_sincronizar_tareas',
			'permission_callback' => 'szs_permiso_token',
		)
	);
}

/**
 * Identifica a la persona por su token personal, en la cabecera
 * `X-Zunbeltz-Token` o, si no está, en `Authorization: Bearer <token>`
 * (por si el hosting normaliza cabeceras custom). La deja en el parámetro
 * `szs_persona` de la petición para el callback.
 */
function szs_permiso_token( WP_REST_Request $request ) {
	$token_recibido = (string) $request->get_header( 'X-Zunbeltz-Token' );
	if ( '' === $token_recibido ) {
		$auth = (string) $request->get_header( 'Authorization' );
		if ( str_starts_with( $auth, 'Bearer ' ) ) {
			$token_recibido = substr( $auth, 7 );
		}
	}

	$persona = szs_persona_por_token( trim( $token_recibido ) );
	if ( null === $persona ) {
		return new WP_Error(
			'szs_token_invalido',
			'Token personal incorrecto o persona desactivada.',
			array( 'status' => 401 )
		);
	}

	$request->set_param( 'szs_persona', $persona );
	return true;
}

function szs_respuesta_sesion( array $persona ): array {
	return array(
		'yo'       => szs_persona_a_json_yo( $persona ),
		'personas' => array_map( 'szs_persona_a_json', szs_listar_personas() ),
	);
}

function szs_endpoint_yo( WP_REST_Request $request ) {
	return new WP_REST_Response( szs_respuesta_sesion( $request->get_param( 'szs_persona' ) ), 200 );
}

/**
 * POST /tareas/sync
 *
 * Body: `{ tareas: [ {uid, finca_nombre, titulo, descripcion, responsable,
 *                      responsable_uid, creado_por_uid, prioridad, estado,
 *                      fecha_objetivo_ms, coste_centimos, recurrencia_dias,
 *                      fecha_creacion_ms, actualizado_ms} ] }`
 *
 * Cada tarea pasa por `szs_resolver_tarea_entrante` (permisos + last-write-
 * wins). Respuesta:
 *
 * - `tareas`: las que esta persona puede ver (hasta 1000, las más recientes).
 * - `forzar`: uids en los que el dispositivo debe quedarse con la versión
 *   del servidor aunque la suya sea más reciente (cambio rechazado o
 *   ajustado por permisos).
 * - `rechazos`: `[{uid, motivo}]`, para avisar en la app.
 * - `yo`, `personas`: como `GET /yo`, para refrescar la sesión de paso.
 */
function szs_sincronizar_tareas( WP_REST_Request $request ) {
	global $wpdb;
	$tabla       = $wpdb->prefix . SZS_TABLA;
	$persona     = $request->get_param( 'szs_persona' );
	$persona_uid = (string) $persona['uid'];
	$capacidades = szs_capacidades_de_rol( (string) $persona['rol'] );

	$body = $request->get_json_params();
	if ( ! is_array( $body ) || ! isset( $body['tareas'] ) || ! is_array( $body['tareas'] ) ) {
		return new WP_REST_Response(
			array(
				'error'   => 'body_invalido',
				'mensaje' => 'Falta el array `tareas` en el body.',
			),
			400
		);
	}

	$forzar   = array();
	$rechazos = array();
	foreach ( $body['tareas'] as $item ) {
		if ( ! is_array( $item ) ) {
			continue;
		}
		$entrante = szs_normalizar_tarea( $item );
		if ( '' === $entrante['uid'] ) {
			continue;
		}
		$fila       = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$tabla} WHERE uid = %s", $entrante['uid'] ), ARRAY_A );
		$existente  = is_array( $fila ) ? szs_normalizar_tarea( $fila ) : null;
		$resolucion = szs_resolver_tarea_entrante( $existente, $entrante, $persona_uid, $capacidades );

		$ajustada = $resolucion['ajustada'];
		if ( in_array( $resolucion['accion'], array( 'insertar', 'actualizar' ), true ) ) {
			$guardada = szs_guardar_tarea( $tabla, $resolucion['datos'], 'insertar' === $resolucion['accion'] );
			$ajustada = $ajustada || $guardada['responsable'] !== $entrante['responsable'];
		}
		if ( $ajustada ) {
			$forzar[] = $entrante['uid'];
		}
		if ( '' !== $resolucion['motivo'] ) {
			$rechazos[] = array(
				'uid'    => $entrante['uid'],
				'motivo' => $resolucion['motivo'],
			);
		}
	}

	$filas = (array) $wpdb->get_results(
		"SELECT * FROM {$tabla} ORDER BY actualizado_ms DESC LIMIT 1000",
		ARRAY_A
	);

	$tareas = array();
	foreach ( $filas as $fila ) {
		$tarea = szs_normalizar_tarea( $fila );
		if ( szs_tarea_visible( $tarea, $persona_uid, $capacidades ) ) {
			$tareas[] = $tarea;
		}
	}

	return new WP_REST_Response(
		array_merge(
			array(
				'tareas'   => $tareas,
				'forzar'   => $forzar,
				'rechazos' => $rechazos,
			),
			szs_respuesta_sesion( $persona )
		),
		200
	);
}

/**
 * Escribe una tarea ya resuelta y devuelve lo que ha quedado guardado. El
 * nombre del responsable lo pone el servidor a partir de la persona, para
 * que no dependa de lo que escriba cada dispositivo.
 */
function szs_guardar_tarea( string $tabla, array $datos, bool $es_nueva ): array {
	global $wpdb;

	if ( '' !== $datos['responsable_uid'] ) {
		$nombre = szs_nombre_persona( $datos['responsable_uid'] );
		if ( null === $nombre ) {
			// Persona inexistente: la tarea queda sin asignar.
			$datos['responsable_uid'] = '';
			$datos['responsable']     = '';
		} else {
			$datos['responsable'] = $nombre;
		}
	}

	$fila                = $datos;
	$fila['recibido_en'] = gmdate( 'Y-m-d H:i:s' );
	if ( $es_nueva ) {
		$wpdb->insert( $tabla, $fila );
	} else {
		unset( $fila['uid'] );
		$wpdb->update( $tabla, $fila, array( 'uid' => $datos['uid'] ) );
	}
	return $datos;
}
