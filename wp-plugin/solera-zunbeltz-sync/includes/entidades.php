<?php
/**
 * Entidades sincronizadas que no son tareas: fincas, zonas, puntos,
 * proyectos y todo su seguimiento, peticiones y avisos de campo.
 *
 * Todas viajan con el mismo sobre — `{tipo, uid, actualizado_ms, borrado,
 * proyecto_uid, datos}` — y se guardan en una tabla genérica
 * (`wp_solera_zunbeltz_entidades`, ver `sync-entidades.php`) con los datos
 * en JSON. Las referencias entre entidades van por `uid` dentro de `datos`
 * (`finca_uid`, `punto_uid`…); el servidor no las resuelve, solo las
 * guarda. Las tareas tienen tabla propia porque el panel de coordinación
 * trabaja sobre ellas (ver `politica-tareas.php`).
 *
 * Aquí solo hay funciones puras (sin `$wpdb`), probadas en
 * `tests/test_entidades.php`. La app replica las mismas reglas para no
 * ofrecer lo que el servidor va a rechazar; **quien manda es el servidor**.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Fincas, zonas y puntos: visibles para todas las personas del espacio. */
const SZS_AMBITO_ESPACIO = 'espacio';
/** La ficha del proyecto de test. */
const SZS_AMBITO_PROYECTO = 'proyecto';
/** Lo que cuelga de un proyecto (`proyecto_uid`). */
const SZS_AMBITO_HIJO_PROYECTO = 'hijo_proyecto';
const SZS_AMBITO_PETICION      = 'peticion';
const SZS_AMBITO_AVISO         = 'aviso';
/** Agenda compartida: cualquiera añade, cada cual edita lo suyo. */
const SZS_AMBITO_CONTACTO = 'contacto';
/** Datos de referencia del espacio (rendimientos…): solo coordinación. */
const SZS_AMBITO_REFERENCIA = 'referencia';

/** Campos de un punto que puede cambiar quien solo tiene `anadir_puntos`. */
const SZS_CAMPOS_PUNTO_MOVIBLES = array( 'latitud', 'longitud', 'estado', 'notas' );

/**
 * Catálogo de tipos. `tester_registra`: en los hijos de proyecto, si la
 * persona tester dueña del proyecto puede crear y editar ese tipo
 * (mientras el proyecto esté abierto).
 *
 * @return array<string, array{ambito: string, tester_registra?: bool}>
 */
function szs_tipos_entidad(): array {
	return array(
		'finca'                   => array( 'ambito' => SZS_AMBITO_ESPACIO ),
		'zona'                    => array( 'ambito' => SZS_AMBITO_ESPACIO ),
		'punto'                   => array( 'ambito' => SZS_AMBITO_ESPACIO ),
		'proyecto'                => array( 'ambito' => SZS_AMBITO_PROYECTO ),
		'registro_actividad'      => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => true ),
		'apunte'                  => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => true ),
		'venta'                   => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => true ),
		'validacion'              => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => true ),
		'partida_presupuesto'     => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => false ),
		'movimiento_fianza'       => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => false ),
		'acompanamiento'          => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => false ),
		'incidencia_cumplimiento' => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => false ),
		'escenario_transformacion' => array( 'ambito' => SZS_AMBITO_HIJO_PROYECTO, 'tester_registra' => true ),
		'peticion'                => array( 'ambito' => SZS_AMBITO_PETICION ),
		'aviso'                   => array( 'ambito' => SZS_AMBITO_AVISO ),
		'contacto'                => array( 'ambito' => SZS_AMBITO_CONTACTO ),
		'rendimiento'             => array( 'ambito' => SZS_AMBITO_REFERENCIA ),
	);
}

function szs_tipo_entidad_existe( string $tipo ): bool {
	return array_key_exists( $tipo, szs_tipos_entidad() );
}

/**
 * Deja una entidad (JSON recibido o fila decodificada) con sus campos y
 * tipos canónicos.
 */
function szs_normalizar_entidad( array $entidad ): array {
	$datos = $entidad['datos'] ?? array();
	return array(
		'tipo'           => szs_recortar( $entidad['tipo'] ?? '', 40 ),
		'uid'            => szs_recortar( $entidad['uid'] ?? '', 64 ),
		'actualizado_ms' => (int) ( $entidad['actualizado_ms'] ?? 0 ),
		'borrado'        => ! empty( $entidad['borrado'] ),
		'proyecto_uid'   => szs_recortar( $entidad['proyecto_uid'] ?? '', 64 ),
		'autor_uid'      => szs_recortar( $entidad['autor_uid'] ?? '', 64 ),
		'datos'          => szs_sanear_datos_entidad( is_array( $datos ) ? $datos : array() ),
	);
}

/**
 * Tipos de los campos de `datos` que el servidor y el panel usan para
 * calcular o como clave: fechas e importes, números; uids y códigos, texto.
 * Un móvil roto o malintencionado podría mandar `fecha_ms: "x"` o
 * `categoria: []`, y el panel fallaría con un error de PHP al pintarlo.
 */
function szs_sanear_datos_entidad( array $datos ): array {
	$campos_texto = array( 'categoria', 'tipo', 'estado', 'gravedad', 'nivel', 'asumido_por', 'asistencia', 'canal', 'titulo', 'nombre', 'concepto', 'producto', 'descripcion' );
	foreach ( $datos as $clave => $valor ) {
		if ( null === $valor ) {
			continue;
		}
		if ( preg_match( '/(_ms|_centimos|_porcentaje|_dias)$/', (string) $clave ) ) {
			$datos[ $clave ] = is_numeric( $valor ) ? $valor + 0 : 0;
		} elseif ( str_ends_with( (string) $clave, '_uid' ) || in_array( $clave, $campos_texto, true ) ) {
			$datos[ $clave ] = is_scalar( $valor ) ? (string) $valor : '';
		}
	}
	return $datos;
}

function szs_puede( array $capacidades, string $capacidad ): bool {
	return in_array( $capacidad, $capacidades, true );
}

/**
 * Decide qué hacer con una entidad entrante.
 *
 * @param array|null $existente   Versión guardada (normalizada, con `autor_uid`) o null.
 * @param array      $entrante    Versión recibida (normalizada).
 * @param string     $persona_uid Quién sincroniza.
 * @param string[]   $capacidades Sus capacidades.
 * @param array|null $proyecto    Para hijos de proyecto: el proyecto al que
 *                                pertenecen (normalizado), o null si no existe.
 *
 * @return array{accion: string, motivo: string, autor_uid: string}
 *   `accion`: `insertar` | `actualizar` | `ignorar` | `rechazar`. Un
 *   borrado aceptado es un `actualizar` con `borrado = true` (se guarda la
 *   lápida para que llegue al resto de dispositivos).
 */
function szs_resolver_entidad_entrante( ?array $existente, array $entrante, string $persona_uid, array $capacidades, ?array $proyecto ): array {
	$tipos = szs_tipos_entidad();
	$tipo  = $entrante['tipo'];
	if ( ! isset( $tipos[ $tipo ] ) || '' === $entrante['uid'] ) {
		return szs_resolucion_entidad( 'rechazar', 'tipo_desconocido', '' );
	}
	if ( null === $existente && $entrante['borrado'] ) {
		return szs_resolucion_entidad( 'ignorar', '', '' );
	}
	if ( null !== $existente && $entrante['actualizado_ms'] <= $existente['actualizado_ms'] ) {
		return szs_resolucion_entidad( 'ignorar', '', '' );
	}

	$autor     = null === $existente ? $persona_uid : $existente['autor_uid'];
	$permitido = szs_entidad_permitida( $tipos[ $tipo ], $existente, $entrante, $persona_uid, $capacidades, $proyecto );
	if ( ! $permitido ) {
		return szs_resolucion_entidad( 'rechazar', 'sin_permiso', $autor );
	}
	return szs_resolucion_entidad( null === $existente ? 'insertar' : 'actualizar', '', $autor );
}

function szs_entidad_permitida( array $definicion, ?array $existente, array $entrante, string $persona_uid, array $capacidades, ?array $proyecto ): bool {
	$tipo   = $entrante['tipo'];
	$es_alta = null === $existente;

	switch ( $definicion['ambito'] ) {
		case SZS_AMBITO_ESPACIO:
			if ( szs_puede( $capacidades, SZS_CAPACIDAD_EDITAR_ESPACIO ) ) {
				return true;
			}
			if ( 'punto' !== $tipo || ! szs_puede( $capacidades, SZS_CAPACIDAD_ANADIR_PUNTOS ) || $entrante['borrado'] ) {
				return false;
			}
			return $es_alta || szs_solo_cambian( $existente['datos'], $entrante['datos'], SZS_CAMPOS_PUNTO_MOVIBLES );

		case SZS_AMBITO_PROYECTO:
			return szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS );

		case SZS_AMBITO_HIJO_PROYECTO:
			if ( szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS ) ) {
				return true;
			}
			if ( empty( $definicion['tester_registra'] ) || null === $proyecto ) {
				return false;
			}
			$es_suyo = ( $proyecto['datos']['persona_uid'] ?? '' ) === $persona_uid && '' !== $persona_uid;
			$abierto = 'cerrado' !== ( $proyecto['datos']['estado'] ?? 'abierto' );
			$mismo   = $es_alta || $existente['proyecto_uid'] === $entrante['proyecto_uid'];
			return $es_suyo && $abierto && $mismo && $entrante['proyecto_uid'] === $proyecto['uid'];

		case SZS_AMBITO_PETICION:
			if ( szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PETICIONES ) ) {
				return true;
			}
			if ( $es_alta ) {
				return szs_puede( $capacidades, SZS_CAPACIDAD_ENVIAR_PETICIONES );
			}
			$pendiente_antes   = 'pendiente' === ( $existente['datos']['estado'] ?? 'pendiente' );
			$pendiente_despues = 'pendiente' === ( $entrante['datos']['estado'] ?? 'pendiente' );
			return $existente['autor_uid'] === $persona_uid && $pendiente_antes && $pendiente_despues;

		case SZS_AMBITO_AVISO:
			if ( szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_AVISOS ) ) {
				return true;
			}
			return $es_alta
				? szs_puede( $capacidades, SZS_CAPACIDAD_CREAR_AVISOS )
				: $existente['autor_uid'] === $persona_uid;

		case SZS_AMBITO_CONTACTO:
			if ( szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_CONTACTOS ) ) {
				return true;
			}
			return $es_alta
				? szs_puede( $capacidades, SZS_CAPACIDAD_CREAR_CONTACTOS )
				: $existente['autor_uid'] === $persona_uid;

		case SZS_AMBITO_REFERENCIA:
			return szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS );
	}
	return false;
}

/**
 * ¿Solo cambian (respecto a `$antes`) los campos de `$permitidos`?
 */
function szs_solo_cambian( array $antes, array $despues, array $permitidos ): bool {
	$claves = array_unique( array_merge( array_keys( $antes ), array_keys( $despues ) ) );
	foreach ( $claves as $clave ) {
		if ( in_array( $clave, $permitidos, true ) ) {
			continue;
		}
		if ( ( $antes[ $clave ] ?? null ) !== ( $despues[ $clave ] ?? null ) ) {
			return false;
		}
	}
	return true;
}

function szs_resolucion_entidad( string $accion, string $motivo, string $autor_uid ): array {
	return array(
		'accion'    => $accion,
		'motivo'    => $motivo,
		'autor_uid' => $autor_uid,
	);
}

/**
 * ¿Puede esta persona ver esta entidad?
 *
 * @param string[] $proyectos_visibles uids de los proyectos que ve (para
 *                                     los hijos de proyecto).
 */
function szs_entidad_visible( array $entidad, string $persona_uid, array $capacidades, array $proyectos_visibles ): bool {
	$tipos = szs_tipos_entidad();
	if ( ! isset( $tipos[ $entidad['tipo'] ] ) ) {
		return false;
	}
	switch ( $tipos[ $entidad['tipo'] ]['ambito'] ) {
		case SZS_AMBITO_ESPACIO:
		case SZS_AMBITO_AVISO:
		case SZS_AMBITO_CONTACTO:
		case SZS_AMBITO_REFERENCIA:
			return true;
		case SZS_AMBITO_PROYECTO:
			return szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS )
				|| ( '' !== $persona_uid && ( $entidad['datos']['persona_uid'] ?? '' ) === $persona_uid );
		case SZS_AMBITO_HIJO_PROYECTO:
			return szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PROYECTOS )
				|| in_array( $entidad['proyecto_uid'], $proyectos_visibles, true );
		case SZS_AMBITO_PETICION:
			return szs_puede( $capacidades, SZS_CAPACIDAD_GESTIONAR_PETICIONES )
				|| $entidad['autor_uid'] === $persona_uid;
	}
	return false;
}

/**
 * Nombre legible de una entidad para el registro de actividad.
 */
function szs_etiqueta_entidad( array $entidad ): string {
	foreach ( array( 'nombre', 'titulo', 'concepto', 'producto', 'descripcion' ) as $campo ) {
		$valor = $entidad['datos'][ $campo ] ?? '';
		if ( is_string( $valor ) && '' !== trim( $valor ) ) {
			return szs_recortar( $valor, 255 );
		}
	}
	return '';
}
