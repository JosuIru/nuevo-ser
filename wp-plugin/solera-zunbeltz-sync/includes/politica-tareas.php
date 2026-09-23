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

/** Campos que cambia quien ejecuta la tarea. */
const SZS_CAMPOS_EJECUCION = array( 'estado', 'coste_centimos' );

/** Campos que describen la tarea. */
const SZS_CAMPOS_CONTENIDO = array(
	'finca_nombre',
	'titulo',
	'descripcion',
	'prioridad',
	'fecha_objetivo_ms',
	'recurrencia_dias',
);

/**
 * A quién está asignada. `responsable` (nombre) acompaña a
 * `responsable_uid` y lo rellena el servidor a partir de la persona.
 */
const SZS_CAMPOS_ASIGNACION = array( 'responsable_uid', 'responsable' );

/**
 * Deja una tarea (fila de BD o JSON recibido) con los campos y tipos
 * canónicos, para poder comparar versiones campo a campo.
 */
function szs_normalizar_tarea( array $tarea ): array {
	return array(
		'uid'               => szs_recortar( $tarea['uid'] ?? '', 64 ),
		'finca_nombre'      => szs_recortar( $tarea['finca_nombre'] ?? '', 255 ),
		'titulo'            => szs_recortar( $tarea['titulo'] ?? '', 500 ),
		'descripcion'       => sanitize_textarea_field( (string) ( $tarea['descripcion'] ?? '' ) ),
		'responsable'       => szs_recortar( $tarea['responsable'] ?? '', 255 ),
		'responsable_uid'   => szs_recortar( $tarea['responsable_uid'] ?? '', 64 ),
		'creado_por_uid'    => szs_recortar( $tarea['creado_por_uid'] ?? '', 64 ),
		'prioridad'         => szs_recortar( $tarea['prioridad'] ?? 'media', 32 ),
		'estado'            => szs_recortar( $tarea['estado'] ?? 'pendiente', 32 ),
		'fecha_objetivo_ms' => szs_entero_o_null( $tarea['fecha_objetivo_ms'] ?? null ),
		'coste_centimos'    => szs_entero_o_null( $tarea['coste_centimos'] ?? null ),
		'recurrencia_dias'  => szs_entero_o_null( $tarea['recurrencia_dias'] ?? null ),
		'fecha_creacion_ms' => (int) ( $tarea['fecha_creacion_ms'] ?? 0 ),
		'actualizado_ms'    => (int) ( $tarea['actualizado_ms'] ?? 0 ),
	);
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

	if ( null === $existente ) {
		if ( ! $puede( SZS_CAPACIDAD_CREAR_TAREAS ) ) {
			return szs_resolucion( 'rechazar', array(), true, 'sin_permiso_crear' );
		}
		$datos                   = $entrante;
		$datos['creado_por_uid'] = $persona_uid;
		$ajustada                = $entrante['creado_por_uid'] !== $persona_uid;
		$motivo                  = '';
		$responsable_valido      = in_array( $datos['responsable_uid'], array( '', $persona_uid ), true );
		if ( ! $puede( SZS_CAPACIDAD_ASIGNAR_TAREAS ) && ! $responsable_valido ) {
			// Sin permiso para asignar a otras personas: la tarea entra sin
			// asignar y la coordinación decide.
			$datos['responsable_uid'] = '';
			$datos['responsable']     = '';
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

	$es_responsable = '' !== $persona_uid && $existente['responsable_uid'] === $persona_uid;
	$es_creador     = '' !== $persona_uid && $existente['creado_por_uid'] === $persona_uid;

	$campos = array();
	if ( $es_responsable || $es_creador ) {
		$campos = array_merge( $campos, SZS_CAMPOS_EJECUCION );
	}
	if ( $es_creador ) {
		$campos = array_merge( $campos, SZS_CAMPOS_CONTENIDO );
	}

	$puede_asignar = in_array( SZS_CAPACIDAD_ASIGNAR_TAREAS, $capacidades, true );
	$se_la_coge    = '' === $existente['responsable_uid'] && $entrante['responsable_uid'] === $persona_uid;
	$la_suelta     = $es_responsable && '' === $entrante['responsable_uid'];
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
 * ¿Puede esta persona ver esta tarea?
 */
function szs_tarea_visible( array $tarea, string $persona_uid, array $capacidades ): bool {
	if ( in_array( SZS_CAPACIDAD_VER_TODAS_TAREAS, $capacidades, true ) ) {
		return true;
	}
	return $tarea['responsable_uid'] === $persona_uid || $tarea['creado_por_uid'] === $persona_uid;
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
		$texto = substr( $texto, 0, $max );
	}
	return $texto;
}
