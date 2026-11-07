<?php
/**
 * Dónde guarda el servidor el estado de Concejo.
 *
 * - `concejo_personas`: personas con la huella de su código y, si
 *   quieren el resumen semanal, su correo. El correo no sale nunca en la
 *   vista que baja la app: solo lo usa el servidor para enviar.
 * - `concejo_documentos`: un JSON por pieza (`asunto:<uid>`,
 *   `debate:<asunto>`, `consentimiento:<asunto>`, `urna:<asunto>`,
 *   `compromiso:<uid>`, `acta:<asunto>`, `sesion:<uid>`). Un pueblo tiene decenas de
 *   asuntos: se carga todo en cada petición y se guarda lo que cambia.
 * - `concejo_papeletas`: las papeletas, aparte. Clave al azar, sin hora en
 *   el voto secreto y sin persona: ni la tabla ni su orden dicen de quién
 *   es cada una.
 * - `concejo_acciones`: las acciones recibidas (uid, persona, tipo y si se
 *   aceptó), para no aplicar dos veces la misma si la red se corta a mitad.
 *   **No guarda los datos**: de un voto queda que alguien votó, no qué.
 *
 * Las acciones se aplican de una en una con un cerrojo de MySQL
 * (`GET_LOCK`), así que dos personas que escriben a la vez no se pisan.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const CONCEJO_VERSION_ESQUEMA        = 2;
const CONCEJO_OPCION_ESQUEMA         = 'concejo_version_esquema';
const CONCEJO_OPCION_REVISION        = 'concejo_revision';
const CONCEJO_OPCION_NOMBRE_ESPACIO  = 'concejo_nombre_espacio';
const CONCEJO_CERROJO                = 'concejo_acciones';

// ------------------------------------------------- piezas (funciones puras)

/** Qué piezas guardadas salen del estado: clave => JSON. */
function concejo_documentos( array $estado ): array {
	$documentos = array();
	$piezas     = array(
		'asunto'         => 'asuntos',
		'debate'         => 'debates',
		'consentimiento' => 'consentimientos',
		'urna'           => 'urnas',
		'compromiso'     => 'compromisos',
		'acta'           => 'actas',
		'sesion'         => 'sesiones',
	);
	foreach ( $piezas as $prefijo => $mapa ) {
		foreach ( $estado[ $mapa ] ?? array() as $clave => $pieza ) {
			$documentos[ "{$prefijo}:{$clave}" ] = (string) json_encode( $pieza, JSON_UNESCAPED_UNICODE );
		}
	}
	return $documentos;
}

/** El estado a partir de las filas de documentos y de personas. */
function concejo_estado_desde_documentos( array $documentos, array $personas ): array {
	$estado = array(
		'personas'        => array(),
		'asuntos'         => array(),
		'debates'         => array(),
		'consentimientos' => array(),
		'urnas'           => array(),
		'compromisos'     => array(),
		'actas'           => array(),
		'sesiones'        => array(),
	);
	$mapas  = array(
		'asunto'         => 'asuntos',
		'debate'         => 'debates',
		'consentimiento' => 'consentimientos',
		'urna'           => 'urnas',
		'compromiso'     => 'compromisos',
		'acta'           => 'actas',
		'sesion'         => 'sesiones',
	);
	foreach ( $documentos as $clave => $json ) {
		[ $prefijo, $uid ] = explode( ':', (string) $clave, 2 );
		if ( isset( $mapas[ $prefijo ] ) ) {
			$estado[ $mapas[ $prefijo ] ][ $uid ] = json_decode( (string) $json, true );
		}
	}
	foreach ( $personas as $persona ) {
		$estado['personas'][ $persona['uid'] ] = array(
			'uid'           => $persona['uid'],
			'nombre'        => $persona['nombre'],
			'rol'           => $persona['rol'],
			'mandato_hasta' => '' === (string) ( $persona['mandato_hasta'] ?? '' ) ? null : $persona['mandato_hasta'],
		);
	}
	return $estado;
}

/**
 * @return array{guardar: array<string, string>, borrar: string[]}
 */
function concejo_cambios_documentos( array $antes, array $despues ): array {
	$guardar = array();
	foreach ( $despues as $clave => $json ) {
		if ( ( $antes[ $clave ] ?? null ) !== $json ) {
			$guardar[ $clave ] = $json;
		}
	}
	return array(
		'guardar' => $guardar,
		'borrar'  => array_values( array_diff( array_keys( $antes ), array_keys( $despues ) ) ),
	);
}

// ------------------------------------------------------------- WordPress

function concejo_tabla( string $nombre ): string {
	global $wpdb;
	return $wpdb->prefix . 'concejo_' . $nombre;
}

function concejo_instalar_esquema(): void {
	global $wpdb;
	$cotejamiento = $wpdb->get_charset_collate();
	require_once ABSPATH . 'wp-admin/includes/upgrade.php';
	dbDelta(
		'CREATE TABLE ' . concejo_tabla( 'personas' ) . " (
		uid VARCHAR(64) NOT NULL,
		nombre VARCHAR(255) NOT NULL DEFAULT '',
		rol VARCHAR(20) NOT NULL DEFAULT 'vecina',
		mandato_hasta VARCHAR(32) NOT NULL DEFAULT '',
		huella_codigo CHAR(64) NULL,
		correo VARCHAR(190) NOT NULL DEFAULT '',
		resumen VARCHAR(10) NOT NULL DEFAULT 'semanal',
		activa TINYINT(1) NOT NULL DEFAULT 1,
		creada_en DATETIME NOT NULL,
		PRIMARY KEY  (uid),
		UNIQUE KEY huella_codigo (huella_codigo)
	) {$cotejamiento};"
	);
	dbDelta(
		'CREATE TABLE ' . concejo_tabla( 'documentos' ) . " (
		clave VARCHAR(140) NOT NULL,
		datos LONGTEXT NOT NULL,
		PRIMARY KEY  (clave)
	) {$cotejamiento};"
	);
	dbDelta(
		'CREATE TABLE ' . concejo_tabla( 'papeletas' ) . " (
		uid CHAR(32) NOT NULL,
		asunto_uid VARCHAR(64) NOT NULL,
		opciones TEXT NOT NULL,
		hora VARCHAR(32) NULL,
		persona_uid VARCHAR(64) NULL,
		PRIMARY KEY  (uid),
		KEY asunto_uid (asunto_uid)
	) {$cotejamiento};"
	);
	dbDelta(
		'CREATE TABLE ' . concejo_tabla( 'acciones' ) . " (
		uid VARCHAR(140) NOT NULL,
		persona_uid VARCHAR(64) NOT NULL,
		tipo VARCHAR(40) NOT NULL,
		aceptada TINYINT(1) NOT NULL,
		motivo VARCHAR(255) NOT NULL DEFAULT '',
		recibida_en DATETIME NOT NULL,
		PRIMARY KEY  (uid)
	) {$cotejamiento};"
	);
	update_option( CONCEJO_OPCION_ESQUEMA, CONCEJO_VERSION_ESQUEMA );
}

function concejo_actualizar_esquema_si_hace_falta(): void {
	if ( (int) get_option( CONCEJO_OPCION_ESQUEMA, 0 ) < CONCEJO_VERSION_ESQUEMA ) {
		concejo_instalar_esquema();
	}
}

function concejo_zona(): DateTimeZone {
	return wp_timezone();
}

function concejo_ahora(): DateTimeImmutable {
	return new DateTimeImmutable( 'now', concejo_zona() );
}

function concejo_revision(): int {
	return (int) get_option( CONCEJO_OPCION_REVISION, 0 );
}

function concejo_nombre_espacio(): string {
	return (string) get_option( CONCEJO_OPCION_NOMBRE_ESPACIO, get_bloginfo( 'name' ) );
}

/** @return array[] Todas las personas (también las dadas de baja, por sus nombres). */
function concejo_filas_personas(): array {
	global $wpdb;
	return (array) $wpdb->get_results(
		'SELECT uid, nombre, rol, mandato_hasta, activa, correo, resumen, huella_codigo IS NOT NULL AS tiene_codigo FROM ' . concejo_tabla( 'personas' ) . ' ORDER BY nombre',
		ARRAY_A
	);
}

/** @return array<string, string> clave => JSON */
function concejo_filas_documentos(): array {
	global $wpdb;
	$documentos = array();
	foreach ( (array) $wpdb->get_results( 'SELECT clave, datos FROM ' . concejo_tabla( 'documentos' ), ARRAY_A ) as $fila ) {
		$documentos[ $fila['clave'] ] = $fila['datos'];
	}
	return $documentos;
}

function concejo_cargar_estado(): array {
	return concejo_estado_desde_documentos( concejo_filas_documentos(), concejo_filas_personas() );
}

/** @return array<string, array[]> asunto_uid => papeletas */
function concejo_cargar_papeletas(): array {
	global $wpdb;
	$papeletas = array();
	foreach ( (array) $wpdb->get_results( 'SELECT asunto_uid, opciones, hora, persona_uid FROM ' . concejo_tabla( 'papeletas' ), ARRAY_A ) as $fila ) {
		$papeletas[ $fila['asunto_uid'] ][] = array(
			'asunto_uid'  => $fila['asunto_uid'],
			'opciones'    => json_decode( (string) $fila['opciones'], true ),
			'hora'        => $fila['hora'],
			'persona_uid' => $fila['persona_uid'],
		);
	}
	return $papeletas;
}

function concejo_persona_por_codigo( string $codigo ): ?array {
	global $wpdb;
	if ( '' === concejo_normalizar_codigo( $codigo ) ) {
		return null;
	}
	$fila = $wpdb->get_row(
		$wpdb->prepare(
			'SELECT uid, nombre, rol FROM ' . concejo_tabla( 'personas' ) . ' WHERE huella_codigo = %s AND activa = 1',
			concejo_huella_codigo( $codigo )
		),
		ARRAY_A
	);
	return is_array( $fila ) ? $fila : null;
}

/** Código nuevo para una persona (anula el anterior). Se enseña una vez. */
function concejo_nuevo_codigo( string $persona_uid ): string {
	global $wpdb;
	$codigo = concejo_generar_codigo();
	$wpdb->update(
		concejo_tabla( 'personas' ),
		array( 'huella_codigo' => concejo_huella_codigo( $codigo ) ),
		array( 'uid' => $persona_uid )
	);
	return $codigo;
}

function concejo_guardar_persona( array $persona ): void {
	global $wpdb;
	$tabla     = concejo_tabla( 'personas' );
	$existente = $wpdb->get_var( $wpdb->prepare( "SELECT uid FROM {$tabla} WHERE uid = %s", $persona['uid'] ) );
	$datos     = array(
		'nombre'        => $persona['nombre'],
		'rol'           => $persona['rol'] ?? 'vecina',
		'mandato_hasta' => (string) ( $persona['mandato_hasta'] ?? '' ),
	);
	if ( null === $existente ) {
		$wpdb->insert(
			$tabla,
			$datos + array(
				'uid'       => $persona['uid'],
				'activa'    => 1,
				'creada_en' => gmdate( 'Y-m-d H:i:s' ),
			)
		);
	} else {
		$wpdb->update( $tabla, $datos, array( 'uid' => $persona['uid'] ) );
	}
}

/**
 * Aplica las acciones de una persona, en orden y con el cerrojo puesto.
 * Una acción ya recibida devuelve lo que se decidió entonces.
 *
 * @return array{resultados: array[], revision: int}
 */
function concejo_recibir_acciones( array $persona, array $acciones ): array {
	global $wpdb;
	$resultados = array();
	// En MySQL/MariaDB, GET_LOCK da 1 (cerrojo puesto) o 0 (otra petición
	// lo tiene más de 15 s). Si la base no lo conoce (SQLite, que ya
	// escribe de una en una) da null y se sigue sin cerrojo.
	$cerrojo = $wpdb->get_var( $wpdb->prepare( 'SELECT GET_LOCK(%s, 15)', CONCEJO_CERROJO ) );
	if ( '0' === (string) $cerrojo && null !== $cerrojo ) {
		return array(
			'resultados' => array(),
			'revision'   => concejo_revision(),
			'ocupado'    => true,
		);
	}
	try {
		$estado     = concejo_cargar_estado();
		$documentos = concejo_documentos( $estado );
		$cambios    = 0;
		foreach ( $acciones as $accion ) {
			$uid = substr( (string) ( $accion['uid'] ?? '' ), 0, 140 );
			if ( '' === $uid ) {
				continue;
			}
			$anterior = $wpdb->get_row(
				$wpdb->prepare( 'SELECT aceptada, motivo FROM ' . concejo_tabla( 'acciones' ) . ' WHERE uid = %s', $uid ),
				ARRAY_A
			);
			if ( is_array( $anterior ) ) {
				$resultados[] = array(
					'uid'      => $uid,
					'aceptada' => '1' === (string) $anterior['aceptada'],
					'motivo'   => $anterior['motivo'],
				);
				continue;
			}
			$aceptada = false;
			$motivo   = '';
			if ( ( $accion['autor_uid'] ?? '' ) !== $persona['uid'] ) {
				$motivo = 'La acción es de otra persona';
			} else {
				try {
					$resultado = concejo_aplicar_accion( $estado, $accion, $persona['uid'], concejo_ahora(), concejo_zona() );
					$estado    = $resultado['estado'];
					$aceptada  = true;
					++$cambios;
					if ( null !== $resultado['papeleta'] ) {
						$papeleta = $resultado['papeleta'];
						$wpdb->insert(
							concejo_tabla( 'papeletas' ),
							array(
								'uid'         => bin2hex( random_bytes( 16 ) ),
								'asunto_uid'  => $papeleta['asunto_uid'],
								'opciones'    => (string) json_encode( $papeleta['opciones'] ),
								'hora'        => $papeleta['hora'],
								'persona_uid' => $papeleta['persona_uid'],
							)
						);
					}
					if ( null !== $resultado['persona_nueva'] ) {
						concejo_guardar_persona( $resultado['persona_nueva'] );
					}
				} catch ( Concejo_Rechazo $rechazo ) {
					$motivo = $rechazo->getMessage();
				}
			}
			$wpdb->insert(
				concejo_tabla( 'acciones' ),
				array(
					'uid'         => $uid,
					'persona_uid' => $persona['uid'],
					'tipo'        => substr( (string) ( $accion['tipo'] ?? '' ), 0, 40 ),
					'aceptada'    => $aceptada ? 1 : 0,
					'motivo'      => substr( $motivo, 0, 255 ),
					'recibida_en' => gmdate( 'Y-m-d H:i:s' ),
				)
			);
			$resultados[] = array(
				'uid'      => $uid,
				'aceptada' => $aceptada,
				'motivo'   => $motivo,
			);
		}
		if ( $cambios > 0 ) {
			$diferencia = concejo_cambios_documentos( $documentos, concejo_documentos( $estado ) );
			foreach ( $diferencia['guardar'] as $clave => $json ) {
				$wpdb->replace(
					concejo_tabla( 'documentos' ),
					array(
						'clave' => $clave,
						'datos' => $json,
					)
				);
			}
			foreach ( $diferencia['borrar'] as $clave ) {
				$wpdb->delete( concejo_tabla( 'documentos' ), array( 'clave' => $clave ) );
			}
			update_option( CONCEJO_OPCION_REVISION, concejo_revision() + 1, false );
		}
	} finally {
		if ( null !== $cerrojo ) {
			$wpdb->query( $wpdb->prepare( 'SELECT RELEASE_LOCK(%s)', CONCEJO_CERROJO ) );
		}
	}
	return array(
		'resultados' => $resultados,
		'revision'   => concejo_revision(),
	);
}
