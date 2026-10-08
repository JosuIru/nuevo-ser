<?php
/**
 * Sincronización completa: `POST /solera-zunbeltz/v1/sync`.
 *
 * Una sola petición sube y baja todo:
 *
 * - **Entidades** (fincas, puntos, proyectos…, ver `entidades.php`) de
 *   forma **incremental**: el dispositivo manda `desde_revision` y recibe
 *   lo que ha cambiado después, más la revisión nueva para la próxima vez.
 *   Los borrados viajan como lápidas (`borrado: true`).
 * - **Tareas** como en `/tareas/sync`: lista completa de lo visible
 *   (`completo: true`), para que el dispositivo retire lo que ya no ve.
 * - **Actividad** (si la persona tiene `ver_actividad`) desde
 *   `desde_actividad`.
 *
 * Las entidades se procesan antes que las tareas, y por tipos en el orden
 * del catálogo (fincas antes que puntos, proyecto antes que sus apuntes),
 * para que lo nuevo de una misma petición se pueda referenciar.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'rest_api_init', 'szs_registrar_ruta_sync' );

function szs_registrar_ruta_sync(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/sync',
		array(
			'methods'             => 'POST',
			'callback'            => 'szs_endpoint_sync',
			'permission_callback' => 'szs_permiso_token',
		)
	);
}

function szs_tabla_entidades(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_ENTIDADES;
}

/**
 * Siguiente número de revisión (secuencia AUTO_INCREMENT). Se purgan las
 * filas viejas de la secuencia para que no crezca: solo importa el id.
 */
function szs_siguiente_revision(): int {
	global $wpdb;
	$tabla = $wpdb->prefix . SZS_TABLA_REVISIONES;
	$wpdb->query( "INSERT INTO {$tabla} () VALUES ()" );
	$revision = (int) $wpdb->insert_id;
	if ( 0 === $revision % 500 ) {
		$wpdb->query( $wpdb->prepare( "DELETE FROM {$tabla} WHERE id < %d", $revision ) );
	}
	return $revision;
}

function szs_revision_actual(): int {
	global $wpdb;
	$tabla = szs_tabla_entidades();
	return (int) $wpdb->get_var( "SELECT COALESCE(MAX(revision), 0) FROM {$tabla}" );
}

function szs_fila_a_entidad( array $fila ): array {
	$datos = json_decode( (string) $fila['datos'], true );
	return array_merge(
		szs_normalizar_entidad(
			array(
				'tipo'           => $fila['tipo'],
				'uid'            => $fila['uid'],
				'actualizado_ms' => $fila['actualizado_ms'],
				'borrado'        => (int) $fila['borrado'],
				'proyecto_uid'   => $fila['proyecto_uid'],
				'autor_uid'      => $fila['autor_uid'],
				'datos'          => is_array( $datos ) ? $datos : array(),
			)
		),
		array( 'revision' => (int) $fila['revision'] )
	);
}

function szs_obtener_entidad( string $tipo, string $uid ): ?array {
	global $wpdb;
	if ( '' === $uid ) {
		return null;
	}
	$tabla = szs_tabla_entidades();
	$fila  = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$tabla} WHERE tipo = %s AND uid = %s", $tipo, $uid ), ARRAY_A );
	return is_array( $fila ) ? szs_fila_a_entidad( $fila ) : null;
}

/**
 * Escribe una entidad ya aceptada con una revisión nueva. En una lápida se
 * conservan los datos anteriores: hacen falta para saber quién la ve (un
 * proyecto borrado tiene que llegar a su persona tester).
 */
function szs_guardar_entidad( array $entidad, ?array $existente, string $autor_uid ): array {
	global $wpdb;
	if ( $entidad['borrado'] && null !== $existente ) {
		$entidad['datos'] = $existente['datos'];
	}
	$entidad['autor_uid'] = $autor_uid;
	$entidad['revision']  = szs_siguiente_revision();
	$wpdb->replace(
		szs_tabla_entidades(),
		array(
			'tipo'           => $entidad['tipo'],
			'uid'            => $entidad['uid'],
			'proyecto_uid'   => $entidad['proyecto_uid'],
			'autor_uid'      => $autor_uid,
			'datos'          => wp_json_encode( $entidad['datos'] ),
			'borrado'        => $entidad['borrado'] ? 1 : 0,
			'actualizado_ms' => $entidad['actualizado_ms'],
			'revision'       => $entidad['revision'],
			'recibido_en'    => gmdate( 'Y-m-d H:i:s' ),
		)
	);
	return $entidad;
}

/**
 * uids de los proyectos (no borrados) que ve una persona.
 *
 * @return string[]
 */
function szs_proyectos_visibles( string $persona_uid, array $capacidades ): array {
	global $wpdb;
	$tabla = szs_tabla_entidades();
	$filas = (array) $wpdb->get_results( "SELECT * FROM {$tabla} WHERE tipo = 'proyecto' AND borrado = 0", ARRAY_A );
	$uids  = array();
	foreach ( $filas as $fila ) {
		$proyecto = szs_fila_a_entidad( $fila );
		if ( szs_entidad_visible( $proyecto, $persona_uid, $capacidades, array() ) ) {
			$uids[] = $proyecto['uid'];
		}
	}
	return $uids;
}

/**
 * Huella de lo que puede ver una persona: su rol, sus capacidades y los
 * proyectos que le tocan. El cursor de revisión solo trae lo que ha
 * cambiado, así que cuando cambia la visibilidad (se le asigna o se le
 * quita un proyecto, cambia de rol) no le llegaría el seguimiento antiguo
 * del proyecto nuevo, ni se le retiraría lo que deja de ver. Si la huella
 * cambia, la app hace una sincronización completa.
 *
 * Quien ve todos los proyectos no depende de cuáles haya: no cuenta la
 * lista, para no forzar una completa cada vez que se crea uno.
 *
 * @param string[] $capacidades
 * @param string[] $proyectos_visibles
 */
function szs_huella_visibilidad( string $rol, array $capacidades, array $proyectos_visibles ): string {
	sort( $capacidades );
	sort( $proyectos_visibles );
	$proyectos = szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS ) ? '*' : implode( ',', $proyectos_visibles );
	return substr( sha1( $rol . '|' . implode( ',', $capacidades ) . '|' . $proyectos ), 0, 12 );
}

/** Nombre de la finca o del proyecto en que ocurre algo, para la actividad. */
function szs_contexto_entidad( array $entidad ): string {
	$finca_uid = $entidad['datos']['finca_uid'] ?? '';
	if ( is_string( $finca_uid ) && '' !== $finca_uid ) {
		$finca = szs_obtener_entidad( 'finca', $finca_uid );
		if ( null !== $finca ) {
			return szs_etiqueta_entidad( $finca );
		}
	}
	if ( '' !== $entidad['proyecto_uid'] ) {
		$proyecto = szs_obtener_entidad( 'proyecto', $entidad['proyecto_uid'] );
		if ( null !== $proyecto ) {
			return szs_etiqueta_entidad( $proyecto );
		}
	}
	return '';
}

/**
 * Aplica las entidades que sube un dispositivo.
 *
 * @return array{0: array, 1: array} `forzar` (`[{tipo, uid}]`: el
 *   dispositivo debe quedarse con la versión del servidor, o borrar la suya
 *   si el servidor no tiene ninguna) y `rechazos` (`[{tipo, uid, motivo}]`).
 */
function szs_procesar_entidades_entrantes( array $persona, array $items, string $origen ): array {
	$persona_uid = (string) $persona['uid'];
	$capacidades = szs_capacidades_de_rol( (string) $persona['rol'] );
	$orden       = array_flip( array_keys( szs_tipos_entidad() ) );

	$entrantes = array();
	foreach ( $items as $item ) {
		if ( is_array( $item ) ) {
			$entrantes[] = szs_normalizar_entidad( $item );
		}
	}
	usort(
		$entrantes,
		static fn( array $a, array $b ): int => ( $orden[ $a['tipo'] ] ?? 999 ) <=> ( $orden[ $b['tipo'] ] ?? 999 )
	);

	$forzar   = array();
	$rechazos = array();
	foreach ( $entrantes as $entrante ) {
		$existente  = szs_obtener_entidad( $entrante['tipo'], $entrante['uid'] );
		$proyecto   = 'proyecto' === $entrante['tipo'] ? null : szs_obtener_entidad( 'proyecto', $entrante['proyecto_uid'] );
		$proyecto   = ( null !== $proyecto && ! $proyecto['borrado'] ) ? $proyecto : null;
		$resolucion = szs_resolver_entidad_entrante( $existente, $entrante, $persona_uid, $capacidades, $proyecto );

		if ( 'rechazar' === $resolucion['accion'] ) {
			$forzar[]   = array(
				'tipo' => $entrante['tipo'],
				'uid'  => $entrante['uid'],
			);
			$rechazos[] = array(
				'tipo'   => $entrante['tipo'],
				'uid'    => $entrante['uid'],
				'motivo' => $resolucion['motivo'],
			);
			continue;
		}
		if ( 'ignorar' === $resolucion['accion'] ) {
			// El móvil manda una versión distinta pero no más reciente (reloj
			// atrasado, o la misma marca de tiempo): que se quede con la del
			// servidor, que por el cursor quizá no le volvería a llegar.
			if ( null !== $existente
				&& ( $existente['datos'] != $entrante['datos'] || $existente['borrado'] !== $entrante['borrado'] ) ) {
				$forzar[] = array(
					'tipo' => $entrante['tipo'],
					'uid'  => $entrante['uid'],
				);
			}
			continue;
		}
		$guardada = szs_guardar_entidad( $entrante, $existente, $resolucion['autor_uid'] );
		do_action( 'szs_entidad_guardada', $guardada, $existente, $persona );
		szs_registrar_actividad(
			$persona,
			szs_accion_entidad( $existente, $guardada ),
			$guardada['tipo'],
			$guardada['uid'],
			szs_etiqueta_entidad( $guardada ),
			szs_contexto_entidad( $guardada ),
			'',
			$origen
		);
	}
	return array( $forzar, $rechazos );
}

/**
 * Entidades visibles con revisión en (`$desde`, `$hasta`].
 *
 * @return array<int, array>
 */
function szs_listar_entidades_cambiadas( string $persona_uid, array $capacidades, int $desde, int $hasta ): array {
	global $wpdb;
	$tabla      = szs_tabla_entidades();
	$filas      = (array) $wpdb->get_results(
		$wpdb->prepare( "SELECT * FROM {$tabla} WHERE revision > %d AND revision <= %d ORDER BY revision ASC", $desde, $hasta ),
		ARRAY_A
	);
	$proyectos  = szs_proyectos_visibles( $persona_uid, $capacidades );
	$visibles   = array();
	foreach ( $filas as $fila ) {
		$entidad = szs_fila_a_entidad( $fila );
		// Un proyecto borrado ya no está entre los visibles, pero su lápida
		// sí tiene que llegar a su persona tester.
		if ( szs_entidad_visible( $entidad, $persona_uid, $capacidades, $proyectos ) ) {
			$visibles[] = $entidad;
		}
	}
	return $visibles;
}

/**
 * Candado de escritura del espacio. La revisión se reserva antes de
 * escribir la fila: sin candado, otra sincronización podría leer una
 * revisión mayor ya escrita, avanzar su cursor y no recibir nunca la fila
 * que aún se estaba escribiendo. Los candados de MySQL son reentrantes en
 * la misma conexión, así que el panel puede tomarlo dentro de otro.
 */
function szs_tomar_candado_espacio(): bool {
	global $wpdb;
	return '1' === (string) $wpdb->get_var( $wpdb->prepare( 'SELECT GET_LOCK(%s, 15)', $wpdb->prefix . 'szs_espacio' ) );
}

function szs_soltar_candado_espacio(): void {
	global $wpdb;
	$wpdb->query( $wpdb->prepare( 'SELECT RELEASE_LOCK(%s)', $wpdb->prefix . 'szs_espacio' ) );
}

function szs_endpoint_sync( WP_REST_Request $request ) {
	if ( ! szs_tomar_candado_espacio() ) {
		return new WP_REST_Response(
			array(
				'error'   => 'ocupado',
				'mensaje' => 'Hay otra sincronización en curso. Se reintentará.',
			),
			503
		);
	}
	try {
		return szs_endpoint_sync_con_candado( $request );
	} finally {
		szs_soltar_candado_espacio();
	}
}

function szs_endpoint_sync_con_candado( WP_REST_Request $request ) {
	$persona     = $request->get_param( 'szs_persona' );
	$persona_uid = (string) $persona['uid'];
	$capacidades = szs_capacidades_de_rol( (string) $persona['rol'] );

	$body = $request->get_json_params();
	if ( ! is_array( $body ) ) {
		return new WP_REST_Response(
			array(
				'error'   => 'body_invalido',
				'mensaje' => 'El body tiene que ser un objeto JSON.',
			),
			400
		);
	}
	$lista = static fn( string $clave ): array => isset( $body[ $clave ] ) && is_array( $body[ $clave ] ) ? $body[ $clave ] : array();

	list( $forzar_entidades, $rechazos_entidades ) = szs_procesar_entidades_entrantes( $persona, $lista( 'entidades' ), 'app' );
	list( $forzar_tareas, $rechazos_tareas )       = szs_procesar_tareas_entrantes( $persona, $lista( 'tareas' ), $lista( 'tareas_borradas' ), 'app' );

	$desde_revision = max( 0, (int) ( $body['desde_revision'] ?? 0 ) );
	$revision       = szs_revision_actual();
	$entidades      = szs_listar_entidades_cambiadas( $persona_uid, $capacidades, $desde_revision, $revision );

	// Lo forzado viaja siempre, aunque sea anterior al cursor del
	// dispositivo, para que deshaga su cambio rechazado.
	$ya_incluidas = array();
	foreach ( $entidades as $entidad ) {
		$ya_incluidas[ $entidad['tipo'] . '|' . $entidad['uid'] ] = true;
	}
	// Solo si esta persona puede verla: si no, subir un uid ajeno con
	// una fecha imposible bastaría para leer el proyecto de otra tester. Sin
	// ella en la respuesta, el móvil borra su copia rechazada.
	$proyectos_visibles = szs_proyectos_visibles( $persona_uid, $capacidades );
	foreach ( $forzar_entidades as $clave ) {
		$actual = szs_obtener_entidad( $clave['tipo'], $clave['uid'] );
		if ( null !== $actual
			&& ! isset( $ya_incluidas[ $clave['tipo'] . '|' . $clave['uid'] ] )
			&& szs_entidad_visible( $actual, $persona_uid, $capacidades, $proyectos_visibles ) ) {
			$entidades[] = $actual;
		}
	}

	$desde_actividad = max( 0, (int) ( $body['desde_actividad'] ?? 0 ) );
	$actividad       = szs_puede( $capacidades, SZS_CAPACIDAD_VER_ACTIVIDAD ) ? szs_listar_actividad( $desde_actividad ) : array();

	return new WP_REST_Response(
		array_merge(
			array(
				'entidades'          => $entidades,
				'revision'           => $revision,
				'forzar_entidades'   => $forzar_entidades,
				'rechazos_entidades' => $rechazos_entidades,
				'tareas'             => szs_listar_tareas_visibles( $persona_uid, $capacidades ),
				'completo'           => true,
				'forzar'             => $forzar_tareas,
				'rechazos'           => $rechazos_tareas,
				'actividad'          => $actividad,
				'huella_visibilidad' => szs_huella_visibilidad( (string) $persona['rol'], $capacidades, $proyectos_visibles ),
			),
			szs_respuesta_sesion( $persona )
		),
		200
	);
}
