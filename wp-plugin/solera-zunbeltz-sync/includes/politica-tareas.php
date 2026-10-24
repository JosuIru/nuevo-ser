<?php
/**
 * Política de permisos sobre tareas: decide qué hacer con cada tarea que
 * sube un dispositivo, según quién la sube y qué capacidades tiene.
 *
 * Funciones puras (sin `$wpdb`) para poder probarlas sin WordPress — ver
 * `tests/test_sync.php`. La app replica estas mismas reglas en
 * `lib/servicios/politica_tareas.dart` sólo para no ofrecer en la interfaz
 * lo que el servidor va a rechazar; **quien manda es el servidor**.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Campos que cambia quien ejecuta la tarea. Las fotos de antes y de
 * después las pone quien la hace (o quien la creó).
 */
const SZS_CAMPOS_EJECUCION = array( 'estado', 'coste_centimos', 'fotos_antes', 'fotos_despues' );

/**
 * Listas de hashes de fotos (ver `fotos.php`). `null` en una tarea recibida
 * = la app no las manda (anterior a las fotos): se conservan las guardadas.
 */
const SZS_CAMPOS_FOTOS_TAREA = array( 'fotos_antes', 'fotos_despues' );

/** Campos que describen la tarea. */
const SZS_CAMPOS_CONTENIDO = array(
	'finca_nombre',
	'finca_uid',
	'punto_uid',
	'zona_uid',
	'titulo',
	'descripcion',
	'prioridad',
	'fecha_objetivo_ms',
	'recurrencia_dias',
);

/**
 * A quién está asignada. Una tarea puede tener varias responsables
 * (`responsables_uids`, tarea compartida); `responsable_uid` es siempre la
 * primera de la lista y `responsable` sus nombres unidos («Ane, Mikel»),
 * que rellena el servidor a partir de las personas. Los dos campos de
 * siempre se mantienen para las apps anteriores a la lista, que funcionan
 * con la primera responsable.
 */
const SZS_CAMPOS_ASIGNACION = array( 'responsables_uids', 'responsable_uid', 'responsable' );

/**
 * Deja una tarea (fila de BD o JSON recibido) con los campos y tipos
 * canónicos, para poder comparar versiones campo a campo.
 */
function szs_normalizar_tarea( array $tarea ): array {
	$responsables = szs_lista_uids_o_null( $tarea['responsables_uids'] ?? null );
	$normalizada  = array(
		'uid'               => szs_recortar( $tarea['uid'] ?? '', 64 ),
		'finca_nombre'      => szs_recortar( $tarea['finca_nombre'] ?? '', 255 ),
		'finca_uid'         => szs_recortar( $tarea['finca_uid'] ?? '', 64 ),
		'punto_uid'         => szs_recortar( $tarea['punto_uid'] ?? '', 64 ),
		'zona_uid'          => szs_recortar( $tarea['zona_uid'] ?? '', 64 ),
		'titulo'            => szs_recortar( $tarea['titulo'] ?? '', 500 ),
		'descripcion'       => sanitize_textarea_field( (string) ( $tarea['descripcion'] ?? '' ) ),
		'responsable'       => szs_recortar( $tarea['responsable'] ?? '', 255 ),
		'responsable_uid'   => szs_recortar( $tarea['responsable_uid'] ?? '', 64 ),
		// `null` = no viene (app o fila anteriores a las responsables
		// múltiples): se deduce de `responsable_uid`, ver
		// `szs_responsables_de_tarea`.
		'responsables_uids' => $responsables,
		'creado_por_uid'    => szs_recortar( $tarea['creado_por_uid'] ?? '', 64 ),
		'prioridad'         => szs_recortar( $tarea['prioridad'] ?? 'media', 32 ),
		'estado'            => szs_recortar( $tarea['estado'] ?? 'pendiente', 32 ),
		'fecha_objetivo_ms' => szs_entero_o_null( $tarea['fecha_objetivo_ms'] ?? null ),
		'coste_centimos'    => szs_entero_o_null( $tarea['coste_centimos'] ?? null ),
		'recurrencia_dias'  => szs_entero_o_null( $tarea['recurrencia_dias'] ?? null ),
		'fotos_antes'       => szs_lista_fotos_o_null( $tarea['fotos_antes'] ?? null ),
		'fotos_despues'     => szs_lista_fotos_o_null( $tarea['fotos_despues'] ?? null ),
		'fecha_creacion_ms' => (int) ( $tarea['fecha_creacion_ms'] ?? 0 ),
		'actualizado_ms'    => (int) ( $tarea['actualizado_ms'] ?? 0 ),
	);
	if ( null !== $responsables ) {
		// La primera de la lista manda sobre lo que diga `responsable_uid`.
		$normalizada['responsable_uid'] = $responsables[0] ?? '';
	}
	return $normalizada;
}

/**
 * Lista de uids de personas (array o JSON), sin vacíos ni repetidas y en
 * su orden; `null` si no viene.
 *
 * @return string[]|null
 */
function szs_lista_uids_o_null( $valor ): ?array {
	if ( is_string( $valor ) ) {
		$valor = '' === trim( $valor ) ? null : json_decode( $valor, true );
	}
	if ( ! is_array( $valor ) ) {
		return null;
	}
	$uids = array();
	foreach ( $valor as $uid ) {
		if ( ! is_string( $uid ) && ! is_int( $uid ) ) {
			continue;
		}
		$uid = szs_recortar( $uid, 64 );
		if ( '' !== $uid && ! in_array( $uid, $uids, true ) ) {
			$uids[] = $uid;
		}
	}
	return $uids;
}

/**
 * Responsables de una tarea normalizada: su lista o, si no la tiene (datos
 * anteriores a las responsables múltiples), la de `responsable_uid`.
 *
 * @return string[]
 */
function szs_responsables_de_tarea( array $tarea ): array {
	if ( isset( $tarea['responsables_uids'] ) && is_array( $tarea['responsables_uids'] ) ) {
		return $tarea['responsables_uids'];
	}
	$uid = (string) ( $tarea['responsable_uid'] ?? '' );
	return '' === $uid ? array() : array( $uid );
}

/**
 * Nombres de las responsables tal como se guardan en `responsable` (lo que
 * enseñan las apps antiguas, el correo y el CSV). La app une igual
 * (`unirNombresResponsables`).
 *
 * @param string[] $nombres
 */
function szs_unir_nombres_responsables( array $nombres ): string {
	return szs_recortar( implode( ', ', $nombres ), 255 );
}

/** La tarea con su lista de responsables siempre presente. */
function szs_completar_responsables( array $tarea ): array {
	$tarea['responsables_uids'] = szs_responsables_de_tarea( $tarea );
	$tarea['responsable_uid']   = $tarea['responsables_uids'][0] ?? '';
	return $tarea;
}

/**
 * Lista de responsables de una tarea que sube una app anterior a la lista
 * (`responsables_uids` = null): solo conoce la primera responsable, así que
 * lo que cambie en `responsable_uid` se aplica a la lista guardada sin
 * perder a las demás. Cogerse una tarea general la añade; soltarla quita
 * solo a la primera; cambiarla, la sustituye.
 *
 * @return string[]
 */
function szs_responsables_desde_app_antigua( ?array $existente, array $entrante ): array {
	$nueva = $entrante['responsable_uid'];
	if ( null === $existente ) {
		return '' === $nueva ? array() : array( $nueva );
	}
	$lista   = szs_responsables_de_tarea( $existente );
	$antigua = $existente['responsable_uid'];
	if ( $nueva === $antigua ) {
		return $lista;
	}
	$sin_antigua = array_values( array_filter( $lista, static fn( string $uid ): bool => $uid !== $antigua ) );
	if ( '' === $nueva ) {
		return $sin_antigua;
	}
	return array_values( array_unique( array_merge( array( $nueva ), $sin_antigua ) ) );
}

/**
 * Decide qué hacer con una tarea entrante.
 *
 * @param array|null $existente   Versión guardada (normalizada) o null si es nueva.
 * @param array      $entrante    Versión recibida (normalizada).
 * @param string     $persona_uid Quién sincroniza.
 * @param string[]   $capacidades Sus capacidades.
 *
 * @return array{accion: string, datos: array, ajustada: bool, motivo: string}
 *   - `accion`: `insertar` | `actualizar` | `ignorar` | `rechazar`.
 *   - `datos`: la versión a guardar (sólo para insertar/actualizar).
 *   - `ajustada`: el servidor guarda algo distinto de lo que mandó el
 *     dispositivo (o lo rechaza), así que el dispositivo debe quedarse con
 *     la versión del servidor aunque la suya tenga `actualizado_ms` mayor.
 *   - `motivo`: código legible cuando se rechaza o ajusta algo.
 */
function szs_resolver_tarea_entrante( ?array $existente, array $entrante, string $persona_uid, array $capacidades ): array {
	$puede = static fn( string $capacidad ): bool => in_array( $capacidad, $capacidades, true );

	// Una app sin fotos no las manda: valen las guardadas (o ninguna).
	foreach ( SZS_CAMPOS_FOTOS_TAREA as $campo ) {
		if ( null === $entrante[ $campo ] ) {
			$entrante[ $campo ] = null === $existente ? array() : ( $existente[ $campo ] ?? array() );
		}
		if ( null !== $existente && null === $existente[ $campo ] ) {
			$existente[ $campo ] = array();
		}
	}

	if ( null !== $existente ) {
		$existente = szs_completar_responsables( $existente );
	}
	if ( null === $entrante['responsables_uids'] ) {
		$entrante['responsables_uids'] = szs_responsables_desde_app_antigua( $existente, $entrante );
	}
	$entrante['responsable_uid'] = $entrante['responsables_uids'][0] ?? '';
	if ( null !== $existente && $entrante['responsables_uids'] === $existente['responsables_uids'] ) {
		// Los nombres los pone el servidor: con las mismas personas no son
		// un cambio aunque el dispositivo los escriba de otra manera.
		$entrante['responsable'] = $existente['responsable'];
	}

	if ( null === $existente ) {
		if ( ! $puede( SZS_CAPACIDAD_CREAR_TAREAS ) ) {
			return szs_resolucion( 'rechazar', array(), true, 'sin_permiso_crear' );
		}
		$datos                   = $entrante;
		$datos['creado_por_uid'] = $persona_uid;
		$ajustada                = $entrante['creado_por_uid'] !== $persona_uid;
		$motivo                  = '';
		$responsable_valido      = array() === $datos['responsables_uids'] || array( $persona_uid ) === $datos['responsables_uids'];
		if ( ! $puede( SZS_CAPACIDAD_ASIGNAR_TAREAS ) && ! $responsable_valido ) {
			// Sin permiso para asignar a otras personas: la tarea entra sin
			// asignar y la coordinación decide.
			$datos['responsables_uids'] = array();
			$datos['responsable_uid']   = '';
			$datos['responsable']       = '';
			$ajustada                 = true;
			$motivo                   = 'sin_permiso_asignar';
		}
		return szs_resolucion( 'insertar', $datos, $ajustada, $motivo );
	}

	if ( $entrante['actualizado_ms'] <= $existente['actualizado_ms'] ) {
		// Lo guardado es igual o más reciente: el dispositivo lo recibirá
		// en la respuesta y lo fusionará por last-write-wins.
		return szs_resolucion( 'ignorar', array(), false, '' );
	}

	$campos_permitidos = szs_campos_editables( $existente, $entrante, $persona_uid, $capacidades );

	$datos             = $existente;
	$hay_permitidos    = false;
	$hay_no_permitidos = false;
	foreach ( array_merge( SZS_CAMPOS_EJECUCION, SZS_CAMPOS_CONTENIDO, SZS_CAMPOS_ASIGNACION ) as $campo ) {
		if ( $entrante[ $campo ] === $existente[ $campo ] ) {
			continue;
		}
		if ( in_array( $campo, $campos_permitidos, true ) ) {
			$datos[ $campo ] = $entrante[ $campo ];
			$hay_permitidos  = true;
		} else {
			$hay_no_permitidos = true;
		}
	}

	if ( ! $hay_permitidos ) {
		return szs_resolucion(
			$hay_no_permitidos ? 'rechazar' : 'ignorar',
			array(),
			$hay_no_permitidos,
			$hay_no_permitidos ? 'sin_permiso_editar' : ''
		);
	}

	$datos['actualizado_ms'] = $entrante['actualizado_ms'];
	return szs_resolucion(
		'actualizar',
		$datos,
		$hay_no_permitidos,
		$hay_no_permitidos ? 'cambios_parciales' : ''
	);
}

/**
 * Qué campos de una tarea existente puede cambiar esta persona.
 *
 * @return string[]
 */
function szs_campos_editables( array $existente, array $entrante, string $persona_uid, array $capacidades ): array {
	if ( in_array( SZS_CAPACIDAD_EDITAR_CUALQUIER_TAREA, $capacidades, true ) ) {
		return array_merge( SZS_CAMPOS_EJECUCION, SZS_CAMPOS_CONTENIDO, SZS_CAMPOS_ASIGNACION );
	}

	$responsables   = szs_responsables_de_tarea( $existente );
	$es_responsable = '' !== $persona_uid && in_array( $persona_uid, $responsables, true );
	$es_creador     = '' !== $persona_uid && $existente['creado_por_uid'] === $persona_uid;

	$campos = array();
	if ( $es_responsable || $es_creador ) {
		$campos = array_merge( $campos, SZS_CAMPOS_EJECUCION );
	}
	if ( $es_creador ) {
		$campos = array_merge( $campos, SZS_CAMPOS_CONTENIDO );
	}

	$puede_asignar = in_array( SZS_CAPACIDAD_ASIGNAR_TAREAS, $capacidades, true );
	$entrantes     = szs_responsables_de_tarea( $entrante );
	// Cogerse una general: queda solo ella. Soltar: sale solo quien suelta
	// y las demás responsables siguen.
	$se_la_coge = array() === $responsables && array( $persona_uid ) === $entrantes;
	$la_suelta  = $es_responsable
		&& array_values( array_filter( $responsables, static fn( string $uid ): bool => $uid !== $persona_uid ) ) === $entrantes;
	if ( $puede_asignar || $se_la_coge || $la_suelta ) {
		$campos = array_merge( $campos, SZS_CAMPOS_ASIGNACION );
	}
	return $campos;
}

function szs_resolucion( string $accion, array $datos, bool $ajustada, string $motivo ): array {
	return array(
		'accion'   => $accion,
		'datos'    => $datos,
		'ajustada' => $ajustada,
		'motivo'   => $motivo,
	);
}

/**
 * ¿Puede esta persona ver esta tarea? Sin `ver_todas_tareas`: las que
 * tiene asignadas (sola o con otras), las que creó y las generales (sin
 * responsable). La aplica `szs_listar_tareas_visibles`.
 */
function szs_tarea_visible( array $tarea, string $persona_uid, array $capacidades ): bool {
	if ( in_array( SZS_CAPACIDAD_VER_TODAS_TAREAS, $capacidades, true ) ) {
		return true;
	}
	$responsables = szs_responsables_de_tarea( $tarea );
	return array() === $responsables
		|| in_array( $persona_uid, $responsables, true )
		|| $tarea['creado_por_uid'] === $persona_uid;
}

/**
 * Lista de hashes de fotos de una tarea, o `null` si no viene (columna sin
 * valor o app anterior a las fotos).
 *
 * @return string[]|null
 */
function szs_lista_fotos_o_null( $valor ): ?array {
	if ( null === $valor ) {
		return null;
	}
	return function_exists( 'szs_normalizar_lista_fotos' ) ? szs_normalizar_lista_fotos( $valor ) : array();
}

function szs_entero_o_null( $valor ): ?int {
	if ( null === $valor || '' === $valor ) {
		return null;
	}
	return (int) $valor;
}

function szs_recortar( $valor, int $max ): string {
	$texto = is_string( $valor ) ? $valor : (string) $valor;
	$texto = sanitize_text_field( $texto );
	if ( strlen( $texto ) > $max ) {
		// Por bytes pero sin partir una letra con tilde: un UTF-8 roto hace
		// fallar el insert sin que nadie se entere.
		$texto = mb_strcut( $texto, 0, $max, 'UTF-8' );
	}
	return $texto;
}
