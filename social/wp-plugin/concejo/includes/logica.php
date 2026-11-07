<?php
/**
 * Reglas de Concejo en el servidor: las mismas comprobaciones que hace la
 * app en `lib/estado/estado_concejo.dart` y `lib/dominio/`, repetidas
 * aquí porque la app no es de fiar (cualquiera puede llamar a la API).
 *
 * Funciones puras sobre un array con el estado del espacio, sin WordPress:
 * se prueban con `php tests/test_logica.php`.
 *
 * Forma del estado (la misma que el JSON de la app, con mapas por uid):
 *
 *     personas         uid        => persona
 *     asuntos          uid        => asunto
 *     debates          asunto_uid => { asunto_uid, aportaciones[], resumen_mesa }
 *     consentimientos  asunto_uid => { ronda_actual, rondas_maximas, desenlace, objeciones[] }
 *     urnas            asunto_uid => { asunto_uid, participaciones[], conteos[] }
 *     compromisos      uid        => compromiso
 *     actas            asunto_uid => { asunto_uid, firmas[], compromisos_al_firmar_uids }
 *     sesiones         uid        => asamblea (fecha, lugar, puntos[], asistencia)
 *     anuncios         uid        => anuncio del tablón
 *     tareas           uid        => tarea en común (auzolan, turno)
 *
 * **Las papeletas no están en el estado**: votar devuelve la papeleta
 * aparte y el almacén la guarda en su propia tabla, sin persona (si el
 * voto es secreto), sin hora exacta y sin orden de llegada.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Acción rechazada: el motivo vuelve a la app. */
class Concejo_Rechazo extends RuntimeException {}

const CONCEJO_VOTO_SI         = 'si';
const CONCEJO_VOTO_NO         = 'no';
const CONCEJO_VOTO_ABSTENCION = 'abstencion';

function concejo_rechazar( string $motivo ): never {
	throw new Concejo_Rechazo( $motivo );
}

/** Momento en UTC con el formato de `DateTime.toIso8601String()` de Dart. */
function concejo_iso_utc( DateTimeImmutable $momento ): string {
	return $momento->setTimezone( new DateTimeZone( 'UTC' ) )->format( 'Y-m-d\TH:i:s.v\Z' );
}

/**
 * Fecha del JSON de la app. Las del calendario vienen sin zona: son hora
 * local del pueblo ([$zona]); los momentos traen `Z`.
 */
function concejo_leer_fecha( string $texto, DateTimeZone $zona ): DateTimeImmutable {
	try {
		return new DateTimeImmutable( $texto, $zona );
	} catch ( Exception $error ) {
		concejo_rechazar( 'Fecha no válida' );
	}
}

// ------------------------------------------------------------------ fases

function concejo_fase( array $asunto, DateTimeImmutable $ahora, DateTimeZone $zona ): string {
	if ( empty( $asunto['abierto'] ) ) {
		return 'borrador';
	}
	if ( $ahora < concejo_leer_fecha( $asunto['inicio_decision'], $zona ) ) {
		return 'debate';
	}
	if ( $ahora < concejo_leer_fecha( $asunto['fin_decision'], $zona ) ) {
		return 'decision';
	}
	return 'seguimiento';
}

/** Como `Persona.esMesaEn`: el cargo caduca al pasar la fecha de fin. */
function concejo_es_mesa( ?array $persona, DateTimeImmutable $ahora, DateTimeZone $zona ): bool {
	if ( null === $persona || 'vecina' === ( $persona['rol'] ?? 'vecina' ) ) {
		return false;
	}
	$hasta = $persona['mandato_hasta'] ?? null;
	return null === $hasta || '' === $hasta || $ahora <= concejo_leer_fecha( $hasta, $zona );
}

// ------------------------------------------------- piezas del estado

function concejo_asunto( array $estado, string $uid ): array {
	if ( ! isset( $estado['asuntos'][ $uid ] ) ) {
		concejo_rechazar( 'No existe el asunto' );
	}
	return $estado['asuntos'][ $uid ];
}

function concejo_debate( array $estado, string $asunto_uid ): array {
	return $estado['debates'][ $asunto_uid ] ?? array(
		'asunto_uid'   => $asunto_uid,
		'aportaciones' => array(),
		'resumen_mesa' => '',
	);
}

function concejo_urna( array $estado, string $asunto_uid ): array {
	return $estado['urnas'][ $asunto_uid ] ?? array(
		'asunto_uid'      => $asunto_uid,
		'participaciones' => array(),
		'conteos'         => array(),
	);
}

function concejo_consentimiento( array $estado, string $asunto_uid ): array {
	return $estado['consentimientos'][ $asunto_uid ] ?? array(
		'ronda_actual'   => 1,
		'rondas_maximas' => (int) ( $estado['asuntos'][ $asunto_uid ]['reglas']['rondas_consentimiento'] ?? 2 ),
		'desenlace'      => 'enCurso',
		'objeciones'     => array(),
	);
}

function concejo_acta( array $estado, string $asunto_uid ): array {
	return $estado['actas'][ $asunto_uid ] ?? array(
		'asunto_uid'                 => $asunto_uid,
		'firmas'                     => array(),
		'compromisos_al_firmar_uids' => null,
	);
}

function concejo_ha_participado( array $urna, string $persona_uid ): bool {
	foreach ( $urna['participaciones'] as $participacion ) {
		if ( $participacion['persona_uid'] === $persona_uid ) {
			return true;
		}
	}
	return false;
}

function concejo_acta_lista( array $estado, string $asunto_uid, DateTimeImmutable $ahora, DateTimeZone $zona ): bool {
	$asunto = concejo_asunto( $estado, $asunto_uid );
	if ( 'seguimiento' !== concejo_fase( $asunto, $ahora, $zona ) ) {
		return false;
	}
	return 'consentimiento' !== $asunto['reglas']['forma']
		|| 'enCurso' !== concejo_consentimiento( $estado, $asunto_uid )['desenlace'];
}

/** Como `ReglasDecision.marcasValidas`. */
function concejo_marcas_validas( array $reglas, array $marcadas ): bool {
	$marcadas = array_values( array_unique( array_map( 'strval', $marcadas ) ) );
	switch ( $reglas['forma'] ) {
		case 'votacion':
			return 1 === count( $marcadas )
				&& in_array( $marcadas[0], array( CONCEJO_VOTO_SI, CONCEJO_VOTO_NO, CONCEJO_VOTO_ABSTENCION ), true );
		case 'consentimiento':
			return false;
		default:
			$ids = array_map( fn( $opcion ) => (string) $opcion['id'], $reglas['opciones'] ?? array() );
			return array() === array_diff( $marcadas, $ids );
	}
}

/** Lo que falta para abrir un asunto (como `Asunto.problemasParaAbrir`). */
function concejo_problemas_para_abrir( array $asunto, DateTimeZone $zona ): array {
	$problemas = array();
	foreach ( array( 'titulo', 'resumen', 'efecto_entorno' ) as $campo ) {
		if ( '' === trim( (string) ( $asunto[ $campo ] ?? '' ) ) ) {
			$problemas[] = 'falta_' . $campo;
		}
	}
	if ( 'conCompromisoPrevio' === ( $asunto['tipo_decision'] ?? '' )
		&& '' === trim( (string) ( $asunto['compromiso_previo'] ?? '' ) ) ) {
		$problemas[] = 'falta_compromiso_previo';
	}
	$inicio_debate   = concejo_leer_fecha( (string) $asunto['inicio_debate'], $zona );
	$inicio_decision = concejo_leer_fecha( (string) $asunto['inicio_decision'], $zona );
	$fin_decision    = concejo_leer_fecha( (string) $asunto['fin_decision'], $zona );
	if ( ! ( $inicio_debate < $inicio_decision && $inicio_decision < $fin_decision ) ) {
		$problemas[] = 'fechas_desordenadas';
	}
	$reglas   = $asunto['reglas'];
	$opciones = $reglas['opciones'] ?? array();
	$ids      = array_map( fn( $opcion ) => (string) $opcion['id'], $opciones );
	if ( (int) ( $reglas['quorum_personas'] ?? 0 ) < 0 ) {
		$problemas[] = 'quorum_negativo';
	}
	if ( ( 'eleccionEntreOpciones' === $reglas['forma'] && count( $opciones ) < 2 )
		|| ( 'presupuesto' === $reglas['forma'] && 0 === count( $opciones ) ) ) {
		$problemas[] = 'faltan_opciones';
	}
	if ( count( array_unique( $ids ) ) !== count( $ids ) ) {
		$problemas[] = 'opciones_repetidas';
	}
	if ( 'presupuesto' === $reglas['forma'] ) {
		if ( ( $reglas['bolsa_euros'] ?? 0 ) <= 0 ) {
			$problemas[] = 'falta_bolsa';
		}
		foreach ( $opciones as $opcion ) {
			if ( ( $opcion['coste_euros'] ?? 0 ) <= 0 ) {
				$problemas[] = 'propuesta_sin_coste';
				break;
			}
		}
	}
	return $problemas;
}

// ------------------------------------------------------------- acciones

/**
 * Aplica una acción de la app. Devuelve el estado nuevo y, al votar en la
 * app, la papeleta para guardarla aparte; al dar de alta, la persona nueva.
 *
 * @return array{estado: array, papeleta: ?array, persona_nueva: ?array}
 * @throws Concejo_Rechazo si no se puede.
 */
function concejo_aplicar_accion( array $estado, array $accion, string $autor_uid, DateTimeImmutable $ahora, DateTimeZone $zona ): array {
	$autor = $estado['personas'][ $autor_uid ] ?? null;
	if ( null === $autor ) {
		concejo_rechazar( 'Persona desconocida' );
	}
	$es_mesa = concejo_es_mesa( $autor, $ahora, $zona );
	$datos   = is_array( $accion['datos'] ?? null ) ? $accion['datos'] : array();
	$texto   = fn( string $clave ): string => trim( (string) ( $datos[ $clave ] ?? '' ) );
	$solo_mesa = function () use ( $es_mesa ): void {
		if ( ! $es_mesa ) {
			concejo_rechazar( 'Esto lo hace la mesa' );
		}
	};
	$en_fase = function ( string $asunto_uid, array $fases ) use ( &$estado, $ahora, $zona ): array {
		$asunto = concejo_asunto( $estado, $asunto_uid );
		if ( ! in_array( concejo_fase( $asunto, $ahora, $zona ), $fases, true ) ) {
			concejo_rechazar( 'No toca en esta fase del asunto' );
		}
		return $asunto;
	};
	$sin_firmas = function ( string $asunto_uid ) use ( &$estado ): void {
		if ( array() !== concejo_acta( $estado, $asunto_uid )['firmas'] ) {
			concejo_rechazar( 'El acta ya tiene firmas: retírala para corregir' );
		}
	};
	$papeleta      = null;
	$persona_nueva = null;
	$asunto_uid    = $texto( 'asunto_uid' );

	switch ( (string) ( $accion['tipo'] ?? '' ) ) {
		case 'votar':
			$asunto = $en_fase( $asunto_uid, array( 'decision' ) );
			$marcas = array_values( array_unique( array_map( 'strval', (array) ( $datos['opciones'] ?? array() ) ) ) );
			if ( ! concejo_marcas_validas( $asunto['reglas'], $marcas ) ) {
				concejo_rechazar( 'Papeleta no válida para este asunto' );
			}
			$urna = concejo_urna( $estado, $asunto_uid );
			if ( concejo_ha_participado( $urna, $autor_uid ) ) {
				concejo_rechazar( 'Ya has participado en este asunto' );
			}
			$urna['participaciones'][]        = array(
				'persona_uid'     => $autor_uid,
				'canal'           => 'app',
				'anotada_por_uid' => '',
			);
			$estado['urnas'][ $asunto_uid ] = $urna;
			$secreta = ( $asunto['reglas']['secreta'] ?? true ) && 'consentimiento' !== $asunto['reglas']['forma'];
			$papeleta = array(
				'asunto_uid' => $asunto_uid,
				'opciones'   => $marcas,
				// Sin hora en el voto secreto: con pocas personas votando, hasta
				// la hora en punto puede decir de quién es una papeleta.
				'hora'       => $secreta ? null : concejo_iso_utc( $ahora ),
				'persona_uid' => $secreta ? null : $autor_uid,
			);
			break;

		case 'aportar':
			$en_nombre = $texto( 'en_nombre_de_uid' );
			if ( '' !== $en_nombre ) {
				$solo_mesa();
				if ( ! isset( $estado['personas'][ $en_nombre ] ) ) {
					concejo_rechazar( 'Persona desconocida' );
				}
			}
			$en_fase( $asunto_uid, array( 'debate', 'decision' ) );
			if ( '' === $texto( 'texto' ) ) {
				concejo_rechazar( 'Una aportación vacía no aporta' );
			}
			$tipo = $texto( 'tipo' );
			if ( ! in_array( $tipo, array( 'aFavor', 'enContra', 'duda', 'propuestaDeCambio' ), true ) ) {
				concejo_rechazar( 'Tipo de aportación desconocido' );
			}
			$debate = concejo_debate( $estado, $asunto_uid );
			$uid    = $texto( 'uid' );
			$responde_a = $texto( 'responde_a_uid' );
			$original   = null;
			if ( '' === $uid ) {
				concejo_rechazar( 'Falta el identificador' );
			}
			foreach ( $debate['aportaciones'] as $existente ) {
				if ( $existente['uid'] === $uid ) {
					concejo_rechazar( 'Identificador de aportación repetido' );
				}
				if ( $existente['uid'] === $responde_a ) {
					$original = $existente;
				}
			}
			if ( '' !== $responde_a ) {
				if ( null === $original ) {
					concejo_rechazar( 'No existe la aportación a la que responde' );
				}
				if ( ! empty( $original['responde_a_uid'] ) ) {
					concejo_rechazar( 'Solo un nivel de respuestas' );
				}
			}
			$anonima = ! empty( $datos['anonima'] );
			$debate['aportaciones'][]         = array(
				'uid'             => $uid,
				'asunto_uid'      => $asunto_uid,
				'autor_uid'       => '' !== $en_nombre ? $en_nombre : $autor_uid,
				'tipo'            => $tipo,
				'texto'           => $texto( 'texto' ),
				'creada'          => concejo_iso_utc( $ahora ),
				'responde_a_uid'  => '' !== $responde_a ? $responde_a : null,
				'anonima'         => $anonima,
				'estado'          => $anonima ? 'pendiente' : 'visible',
				'motivo_retirada' => '',
			);
			$estado['debates'][ $asunto_uid ] = $debate;
			break;

		case 'objetar':
			$en_nombre = $texto( 'en_nombre_de_uid' );
			if ( '' !== $en_nombre ) {
				$solo_mesa();
				if ( ! isset( $estado['personas'][ $en_nombre ] ) ) {
					concejo_rechazar( 'Persona desconocida' );
				}
			}
			$asunto = $en_fase( $asunto_uid, array( 'debate', 'decision' ) );
			if ( 'consentimiento' !== $asunto['reglas']['forma'] ) {
				concejo_rechazar( 'Este asunto no se decide por consentimiento' );
			}
			$consentimiento = concejo_consentimiento( $estado, $asunto_uid );
			if ( 'enCurso' !== $consentimiento['desenlace'] ) {
				concejo_rechazar( 'El consentimiento ya está decidido' );
			}
			if ( '' === $texto( 'motivo' ) ) {
				concejo_rechazar( 'Una objeción explica qué daño causa la propuesta' );
			}
			$uid = $texto( 'uid' );
			foreach ( $consentimiento['objeciones'] as $existente ) {
				if ( $existente['uid'] === $uid ) {
					concejo_rechazar( 'Identificador de objeción repetido' );
				}
			}
			if ( '' === $uid ) {
				concejo_rechazar( 'Falta el identificador' );
			}
			$consentimiento['objeciones'][]           = array(
				'uid'       => $uid,
				'autor_uid' => '' !== $en_nombre ? $en_nombre : $autor_uid,
				'ronda'     => $consentimiento['ronda_actual'],
				'motivo'    => $texto( 'motivo' ),
				'estado'    => 'viva',
				'respuesta' => '',
			);
			$estado['consentimientos'][ $asunto_uid ] = $consentimiento;
			break;

		case 'resolverObjecion':
			concejo_asunto( $estado, $asunto_uid );
			$consentimiento = concejo_consentimiento( $estado, $asunto_uid );
			if ( 'enCurso' !== $consentimiento['desenlace'] ) {
				concejo_rechazar( 'El consentimiento ya está decidido' );
			}
			$nuevo     = $texto( 'estado' );
			$respuesta = $texto( 'respuesta' );
			if ( ! in_array( $nuevo, array( 'integrada', 'retirada', 'noEsObjecion' ), true ) ) {
				concejo_rechazar( 'Resolver es pasarla a otro estado' );
			}
			if ( 'retirada' !== $nuevo && '' === $respuesta ) {
				concejo_rechazar( 'Hay que decir cómo se ha resuelto' );
			}
			$encontrada = false;
			foreach ( $consentimiento['objeciones'] as $indice => $objecion ) {
				if ( $objecion['uid'] !== $texto( 'objecion_uid' ) ) {
					continue;
				}
				$encontrada = true;
				if ( 'retirada' === $nuevo ) {
					if ( $objecion['autor_uid'] !== $autor_uid ) {
						concejo_rechazar( 'Una objeción solo la retira quien la planteó' );
					}
				} else {
					$solo_mesa();
				}
				$consentimiento['objeciones'][ $indice ]['estado']    = $nuevo;
				$consentimiento['objeciones'][ $indice ]['respuesta'] = $respuesta;
			}
			if ( ! $encontrada ) {
				concejo_rechazar( 'No existe la objeción' );
			}
			$estado['consentimientos'][ $asunto_uid ] = $consentimiento;
			break;

		case 'cerrarRondaConsentimiento':
			$solo_mesa();
			concejo_asunto( $estado, $asunto_uid );
			$sin_firmas( $asunto_uid );
			$consentimiento = concejo_consentimiento( $estado, $asunto_uid );
			if ( 'enCurso' !== $consentimiento['desenlace'] ) {
				concejo_rechazar( 'El consentimiento ya está decidido' );
			}
			$vivas = array_filter( $consentimiento['objeciones'], fn( $o ) => 'viva' === $o['estado'] );
			if ( array() === $vivas ) {
				$consentimiento['desenlace'] = 'aprobada';
			} elseif ( $consentimiento['ronda_actual'] >= $consentimiento['rondas_maximas'] ) {
				$consentimiento['desenlace'] = 'pasaAVotacionOAsamblea';
			} else {
				++$consentimiento['ronda_actual'];
			}
			$estado['consentimientos'][ $asunto_uid ] = $consentimiento;
			break;

		case 'guardarBorrador':
			$solo_mesa();
			$borrador = is_array( $datos['asunto'] ?? null ) ? $datos['asunto'] : array();
			$uid      = trim( (string) ( $borrador['uid'] ?? '' ) );
			if ( '' === $uid || ! is_array( $borrador['reglas'] ?? null ) ) {
				concejo_rechazar( 'Borrador incompleto' );
			}
			if ( ! empty( $borrador['abierto'] ) ) {
				concejo_rechazar( 'Un borrador no puede venir abierto' );
			}
			$existente = $estado['asuntos'][ $uid ] ?? null;
			if ( null !== $existente && ! empty( $existente['abierto'] ) ) {
				concejo_rechazar( 'Un asunto abierto no se edita' );
			}
			foreach ( array( 'inicio_debate', 'inicio_decision', 'fin_decision' ) as $campo ) {
				concejo_leer_fecha( (string) ( $borrador[ $campo ] ?? '' ), $zona );
			}
			$borrador['creado_por_uid'] = null !== $existente ? $existente['creado_por_uid'] : $autor_uid;
			$borrador['abierto']        = false;
			$estado['asuntos'][ $uid ]  = $borrador;
			break;

		case 'abrirAsunto':
			$solo_mesa();
			$asunto = concejo_asunto( $estado, $asunto_uid );
			if ( ! empty( $asunto['abierto'] ) ) {
				concejo_rechazar( 'El asunto ya está abierto' );
			}
			if ( array() !== concejo_problemas_para_abrir( $asunto, $zona ) ) {
				concejo_rechazar( 'No se puede abrir: ' . implode( ', ', concejo_problemas_para_abrir( $asunto, $zona ) ) );
			}
			$estado['asuntos'][ $asunto_uid ]['abierto'] = true;
			break;

		case 'borrarBorrador':
			$solo_mesa();
			$asunto = concejo_asunto( $estado, $asunto_uid );
			if ( ! empty( $asunto['abierto'] ) ) {
				concejo_rechazar( 'Un asunto abierto no se borra' );
			}
			unset( $estado['asuntos'][ $asunto_uid ] );
			break;

		case 'moderar':
			$solo_mesa();
			concejo_asunto( $estado, $asunto_uid );
			$nuevo  = $texto( 'estado' );
			$motivo = $texto( 'motivo' );
			if ( ! in_array( $nuevo, array( 'visible', 'retirada' ), true ) ) {
				concejo_rechazar( 'Moderar es publicar o retirar' );
			}
			if ( 'retirada' === $nuevo && '' === $motivo ) {
				concejo_rechazar( 'Para retirar una aportación hay que decir por qué' );
			}
			$debate     = concejo_debate( $estado, $asunto_uid );
			$encontrada = false;
			foreach ( $debate['aportaciones'] as $indice => $aportacion ) {
				if ( $aportacion['uid'] === $texto( 'aportacion_uid' ) ) {
					$encontrada = true;
					$debate['aportaciones'][ $indice ]['estado']          = $nuevo;
					$debate['aportaciones'][ $indice ]['motivo_retirada'] = 'retirada' === $nuevo ? $motivo : '';
				}
			}
			if ( ! $encontrada ) {
				concejo_rechazar( 'No existe la aportación' );
			}
			$estado['debates'][ $asunto_uid ] = $debate;
			break;

		case 'resumirDebate':
			$solo_mesa();
			concejo_asunto( $estado, $asunto_uid );
			$sin_firmas( $asunto_uid );
			$debate                           = concejo_debate( $estado, $asunto_uid );
			$debate['resumen_mesa']           = $texto( 'resumen' );
			$estado['debates'][ $asunto_uid ] = $debate;
			break;

		case 'anadirCompromiso':
			$solo_mesa();
			concejo_asunto( $estado, $asunto_uid );
			$uid = $texto( 'uid' );
			if ( '' === $texto( 'que' ) || '' === $texto( 'responsable' ) ) {
				concejo_rechazar( 'Un compromiso dice qué y quién' );
			}
			if ( '' === $uid || isset( $estado['compromisos'][ $uid ] ) ) {
				concejo_rechazar( 'Identificador de compromiso repetido' );
			}
			concejo_leer_fecha( $texto( 'fecha_limite' ), $zona );
			$estado['compromisos'][ $uid ] = array(
				'uid'          => $uid,
				'asunto_uid'   => $asunto_uid,
				'que'          => $texto( 'que' ),
				'responsable'  => $texto( 'responsable' ),
				'fecha_limite' => $texto( 'fecha_limite' ),
				'estado'       => 'pendiente',
				'nota'         => '',
			);
			break;

		case 'cambiarEstadoCompromiso':
			$solo_mesa();
			$uid = $texto( 'compromiso_uid' );
			if ( ! isset( $estado['compromisos'][ $uid ] ) ) {
				concejo_rechazar( 'No existe el compromiso' );
			}
			$nuevo = $texto( 'estado' );
			$nota  = $texto( 'nota' );
			if ( ! in_array( $nuevo, array( 'pendiente', 'enMarcha', 'hecho', 'noSeHara' ), true ) ) {
				concejo_rechazar( 'Estado de compromiso desconocido' );
			}
			if ( 'noSeHara' === $nuevo && '' === $nota ) {
				concejo_rechazar( 'Si no se hará, hay que decir por qué' );
			}
			$estado['compromisos'][ $uid ]['estado'] = $nuevo;
			if ( '' !== $nota ) {
				$estado['compromisos'][ $uid ]['nota'] = $nota;
			}
			break;

		case 'darDeAlta':
			$solo_mesa();
			$uid = $texto( 'uid' );
			if ( '' === $texto( 'nombre' ) ) {
				concejo_rechazar( 'Falta el nombre' );
			}
			if ( '' === $uid || isset( $estado['personas'][ $uid ] ) ) {
				concejo_rechazar( 'Identificador de persona repetido' );
			}
			$persona_nueva               = array(
				'uid'           => $uid,
				'nombre'        => $texto( 'nombre' ),
				'rol'           => 'vecina',
				'mandato_hasta' => null,
			);
			$estado['personas'][ $uid ] = $persona_nueva;
			break;

		case 'anotarVotoPresencial':
			$solo_mesa();
			$en_fase( $asunto_uid, array( 'decision' ) );
			$persona_uid = $texto( 'persona_uid' );
			if ( ! isset( $estado['personas'][ $persona_uid ] ) ) {
				concejo_rechazar( 'Persona desconocida' );
			}
			$urna = concejo_urna( $estado, $asunto_uid );
			if ( concejo_ha_participado( $urna, $persona_uid ) ) {
				concejo_rechazar( 'Esa persona ya ha participado' );
			}
			$urna['participaciones'][]        = array(
				'persona_uid'     => $persona_uid,
				'canal'           => 'presencial',
				'anotada_por_uid' => $autor_uid,
			);
			$estado['urnas'][ $asunto_uid ] = $urna;
			break;

		case 'registrarConteoPresencial':
			$solo_mesa();
			// Las papeletas en papel se cuentan al cerrar.
			$asunto = $en_fase( $asunto_uid, array( 'decision', 'seguimiento' ) );
			$sin_firmas( $asunto_uid );
			$segunda = $texto( 'segunda_firma_uid' );
			if ( $segunda === $autor_uid || ! concejo_es_mesa( $estado['personas'][ $segunda ] ?? null, $ahora, $zona ) ) {
				concejo_rechazar( 'El conteo lo firma otra persona de la mesa' );
			}
			$totales = (int) ( $datos['papeletas_totales'] ?? -1 );
			$marcas  = array();
			foreach ( (array) ( $datos['marcas'] ?? array() ) as $opcion => $cantidad ) {
				$marcas[ (string) $opcion ] = (int) $cantidad;
			}
			if ( $totales < 0 || array() !== array_filter( $marcas, fn( $n ) => $n < 0 ) ) {
				concejo_rechazar( 'Las cifras no pueden ser negativas' );
			}
			if ( 'consentimiento' === $asunto['reglas']['forma'] ) {
				concejo_rechazar( 'En consentimiento no hay papeletas' );
			}
			$urna              = concejo_urna( $estado, $asunto_uid );
			$urna['conteos'][] = array(
				'papeletas_totales' => $totales,
				'marcas'            => (object) $marcas,
				'firmado_por_uids'  => array( $autor_uid, $segunda ),
			);
			$estado['urnas'][ $asunto_uid ] = $urna;
			break;

		case 'firmarActa':
			$solo_mesa();
			if ( ! concejo_acta_lista( $estado, $asunto_uid, $ahora, $zona ) ) {
				concejo_rechazar( 'El acta se firma con el asunto decidido' );
			}
			$acta = concejo_acta( $estado, $asunto_uid );
			if ( count( $acta['firmas'] ) >= 2 ) {
				concejo_rechazar( 'El acta ya está firmada' );
			}
			foreach ( $acta['firmas'] as $firma ) {
				if ( $firma['persona_uid'] === $autor_uid ) {
					concejo_rechazar( 'La misma persona no firma dos veces' );
				}
			}
			$acta['firmas'][] = array(
				'persona_uid' => $autor_uid,
				'firmada'     => concejo_iso_utc( $ahora ),
			);
			if ( count( $acta['firmas'] ) >= 2 ) {
				$acta['compromisos_al_firmar_uids'] = array_values(
					array_map(
						fn( $c ) => $c['uid'],
						array_filter( $estado['compromisos'] ?? array(), fn( $c ) => $c['asunto_uid'] === $asunto_uid )
					)
				);
			}
			$estado['actas'][ $asunto_uid ] = $acta;
			break;

		case 'retirarFirmaActa':
			$solo_mesa();
			$acta = concejo_acta( $estado, $asunto_uid );
			if ( count( $acta['firmas'] ) >= 2 ) {
				concejo_rechazar( 'Un acta firmada ya no se toca' );
			}
			$restantes = array_values( array_filter( $acta['firmas'], fn( $f ) => $f['persona_uid'] !== $autor_uid ) );
			if ( count( $restantes ) === count( $acta['firmas'] ) ) {
				concejo_rechazar( 'No la habías firmado' );
			}
			$acta['firmas']                  = $restantes;
			$estado['actas'][ $asunto_uid ] = $acta;
			break;

		case 'convocarSesion':
			$solo_mesa();
			$nueva = concejo_sesion_convocada( $estado, (array) ( $datos['sesion'] ?? array() ) );
			$uid   = $nueva['uid'];
			if ( isset( $estado['sesiones'][ $uid ] ) ) {
				$anterior = $estado['sesiones'][ $uid ];
				concejo_sesion_antes_de_empezar( $anterior, $ahora, $zona );
				$nueva['convocada_por_uid'] = $anterior['convocada_por_uid'];
			} else {
				$nueva['convocada_por_uid'] = $autor_uid;
			}
			$estado['sesiones'][ $uid ] = $nueva;
			break;

		case 'anularSesion':
			$solo_mesa();
			$sesion = concejo_sesion( $estado, $texto( 'sesion_uid' ) );
			concejo_sesion_antes_de_empezar( $sesion, $ahora, $zona );
			if ( '' === $texto( 'motivo' ) ) {
				concejo_rechazar( 'Para anular una asamblea hay que decir por qué' );
			}
			$sesion['anulada']          = true;
			$sesion['motivo_anulacion'] = $texto( 'motivo' );
			$estado['sesiones'][ $sesion['uid'] ] = $sesion;
			break;

		case 'anotarAsistencia':
			$persona_uid = $texto( 'persona_uid' );
			if ( ! isset( $estado['personas'][ $persona_uid ] ) ) {
				concejo_rechazar( 'No existe esa persona' );
			}
			$solo_mesa();
			$sesion = concejo_sesion_con_asistencia( $estado, $texto( 'sesion_uid' ), $ahora, $zona );
			$asistentes = array_values( array_diff( $sesion['asistentes_uids'] ?? array(), array( $persona_uid ) ) );
			if ( true === ( $datos['presente'] ?? false ) ) {
				$asistentes[] = $persona_uid;
			}
			sort( $asistentes );
			$sesion['asistentes_uids']            = $asistentes;
			$estado['sesiones'][ $sesion['uid'] ] = $sesion;
			break;

		case 'anotarAsistentesSinApp':
			$solo_mesa();
			$sesion   = concejo_sesion_con_asistencia( $estado, $texto( 'sesion_uid' ), $ahora, $zona );
			$cantidad = $datos['cantidad'] ?? null;
			if ( ! is_numeric( $cantidad ) || (int) $cantidad < 0 ) {
				concejo_rechazar( 'No puede venir gente en negativo' );
			}
			$sesion['asistentes_sin_app']         = (int) $cantidad;
			$estado['sesiones'][ $sesion['uid'] ] = $sesion;
			break;

		case 'anotarNotasPunto':
			$solo_mesa();
			$sesion     = concejo_sesion_con_asistencia( $estado, $texto( 'sesion_uid' ), $ahora, $zona );
			$punto_uid  = $texto( 'punto_uid' );
			$encontrado = false;
			foreach ( $sesion['puntos'] as $indice => $punto ) {
				if ( $punto['uid'] === $punto_uid ) {
					$sesion['puntos'][ $indice ]['notas'] = $texto( 'notas' );
					$encontrado                           = true;
				}
			}
			if ( ! $encontrado ) {
				concejo_rechazar( 'No existe ese punto del orden del día' );
			}
			$estado['sesiones'][ $sesion['uid'] ] = $sesion;
			break;

		case 'publicarAnuncio':
			$nuevo = concejo_anuncio_publicado( (array) ( $datos['anuncio'] ?? array() ), $ahora, $zona );
			if ( isset( $estado['anuncios'][ $nuevo['uid'] ] ) ) {
				concejo_rechazar( 'Identificador de anuncio repetido' );
			}
			$nuevo['autor_uid']                  = $autor_uid;
			$estado['anuncios'][ $nuevo['uid'] ] = $nuevo;
			break;

		case 'retirarAnuncio':
			$anuncio = concejo_anuncio( $estado, $texto( 'anuncio_uid' ) );
			if ( $anuncio['autor_uid'] !== $autor_uid ) {
				$solo_mesa();
				if ( '' === $texto( 'motivo' ) ) {
					concejo_rechazar( 'Para retirar el anuncio de otra persona, di por qué' );
				}
			}
			$anuncio['retirado']        = true;
			$anuncio['fijado']          = false;
			$anuncio['motivo_retirada'] = $texto( 'motivo' );
			$estado['anuncios'][ $anuncio['uid'] ] = $anuncio;
			break;

		case 'fijarAnuncio':
			$solo_mesa();
			$anuncio           = concejo_anuncio( $estado, $texto( 'anuncio_uid' ) );
			$anuncio['fijado'] = true === ( $datos['fijado'] ?? false );
			$estado['anuncios'][ $anuncio['uid'] ] = $anuncio;
			break;

		case 'crearTarea':
			$solo_mesa();
			$nueva = concejo_tarea_creada( (array) ( $datos['tarea'] ?? array() ), $ahora, $zona );
			if ( isset( $estado['tareas'][ $nueva['uid'] ] ) ) {
				concejo_rechazar( 'Identificador de tarea repetido' );
			}
			$nueva['creada_por_uid']           = $autor_uid;
			$estado['tareas'][ $nueva['uid'] ] = $nueva;
			break;

		case 'apuntarTarea':
			$persona_uid = $texto( 'persona_uid' );
			if ( $persona_uid !== $autor_uid ) {
				$solo_mesa();
			}
			if ( ! isset( $estado['personas'][ $persona_uid ] ) ) {
				concejo_rechazar( 'No existe esa persona' );
			}
			$tarea      = concejo_tarea_antes_de_empezar( $estado, $texto( 'tarea_uid' ), $ahora, $zona );
			$apuntados  = array_values( array_diff( $tarea['apuntados_uids'] ?? array(), array( $persona_uid ) ) );
			$ya_estaba  = count( $apuntados ) !== count( $tarea['apuntados_uids'] ?? array() );
			if ( true === ( $datos['apuntado'] ?? false ) ) {
				$plazas = (int) ( $tarea['plazas'] ?? 0 );
				if ( ! $ya_estaba && $plazas > 0 && count( $apuntados ) >= $plazas ) {
					concejo_rechazar( 'No quedan plazas' );
				}
				$apuntados[] = $persona_uid;
			}
			sort( $apuntados );
			$tarea['apuntados_uids']          = $apuntados;
			$estado['tareas'][ $tarea['uid'] ] = $tarea;
			break;

		case 'anularTarea':
			$solo_mesa();
			$tarea = concejo_tarea_antes_de_empezar( $estado, $texto( 'tarea_uid' ), $ahora, $zona );
			if ( '' === $texto( 'motivo' ) ) {
				concejo_rechazar( 'Para anular una tarea hay que decir por qué' );
			}
			$tarea['anulada']                  = true;
			$tarea['motivo_anulacion']         = $texto( 'motivo' );
			$estado['tareas'][ $tarea['uid'] ] = $tarea;
			break;

		case 'marcarTareaHecha':
			$solo_mesa();
			$tarea = concejo_tarea( $estado, $texto( 'tarea_uid' ) );
			if ( ! empty( $tarea['anulada'] ) ) {
				concejo_rechazar( 'La tarea está anulada' );
			}
			if ( $ahora < concejo_leer_fecha( $tarea['inicio'], $zona )->setTime( 0, 0 ) ) {
				concejo_rechazar( 'Se da por hecha desde el día de la tarea' );
			}
			$tarea['hecha']                    = true;
			$tarea['nota_hecha']               = $texto( 'nota' );
			$estado['tareas'][ $tarea['uid'] ] = $tarea;
			break;

		default:
			concejo_rechazar( 'Acción desconocida' );
	}

	return array(
		'estado'        => $estado,
		'papeleta'      => $papeleta,
		'persona_nueva' => $persona_nueva,
	);
}

// ------------------------------------------------------------- asambleas

function concejo_sesion( array $estado, string $uid ): array {
	if ( ! isset( $estado['sesiones'][ $uid ] ) ) {
		concejo_rechazar( 'No existe la asamblea' );
	}
	return $estado['sesiones'][ $uid ];
}

/** Como `Sesion._soloAntesDeEmpezar`: se cambia o anula antes de empezar. */
function concejo_sesion_antes_de_empezar( array $sesion, DateTimeImmutable $ahora, DateTimeZone $zona ): void {
	if ( ! empty( $sesion['anulada'] ) ) {
		concejo_rechazar( 'La asamblea está anulada' );
	}
	if ( $ahora >= concejo_leer_fecha( $sesion['inicio'], $zona ) ) {
		concejo_rechazar( 'La asamblea ya ha empezado' );
	}
}

/** Como `Sesion.admiteAsistenciaEn`: desde el día de la asamblea. */
function concejo_sesion_con_asistencia( array $estado, string $uid, DateTimeImmutable $ahora, DateTimeZone $zona ): array {
	$sesion = concejo_sesion( $estado, $uid );
	if ( ! empty( $sesion['anulada'] ) ) {
		concejo_rechazar( 'La asamblea está anulada' );
	}
	if ( $ahora < concejo_leer_fecha( $sesion['inicio'], $zona )->setTime( 0, 0 ) ) {
		concejo_rechazar( 'La asistencia se apunta desde el día de la asamblea' );
	}
	return $sesion;
}

/**
 * La convocatoria que manda la app, comprobada y limpia (como
 * `Sesion.problemas` y `EstadoConcejo._convocarSesion`). Sale sin
 * asistencia: se convoca antes de empezar.
 */
function concejo_sesion_convocada( array $estado, array $datos ): array {
	$uid    = trim( (string) ( $datos['uid'] ?? '' ) );
	$titulo = trim( (string) ( $datos['titulo'] ?? '' ) );
	$lugar  = trim( (string) ( $datos['lugar'] ?? '' ) );
	$inicio = (string) ( $datos['inicio'] ?? '' );
	if ( '' === $uid || '' === $titulo || '' === $lugar || '' === $inicio ) {
		concejo_rechazar( 'A la convocatoria le falta título, lugar o fecha' );
	}
	concejo_leer_fecha( $inicio, new DateTimeZone( 'UTC' ) );
	$puntos = array();
	$textos = array();
	$uids   = array();
	foreach ( (array) ( $datos['puntos'] ?? array() ) as $punto ) {
		$texto_punto = trim( (string) ( $punto['texto'] ?? '' ) );
		if ( '' === $texto_punto ) {
			concejo_rechazar( 'Un punto del orden del día está vacío' );
		}
		$asunto_uid = $punto['asunto_uid'] ?? null;
		if ( null !== $asunto_uid && empty( $estado['asuntos'][ (string) $asunto_uid ]['abierto'] ) ) {
			concejo_rechazar( 'Un punto apunta a un asunto que no está abierto' );
		}
		$textos[] = mb_strtolower( $texto_punto );
		$uids[]   = (string) ( $punto['uid'] ?? '' );
		$puntos[] = array(
			'uid'        => (string) ( $punto['uid'] ?? '' ),
			'texto'      => (string) $punto['texto'],
			'asunto_uid' => null === $asunto_uid ? null : (string) $asunto_uid,
			'notas'      => (string) ( $punto['notas'] ?? '' ),
		);
	}
	if ( array() === $puntos ) {
		concejo_rechazar( 'La asamblea necesita algún punto en el orden del día' );
	}
	if ( count( array_unique( $textos ) ) !== count( $textos ) || count( array_unique( $uids ) ) !== count( $uids ) ) {
		concejo_rechazar( 'Hay puntos repetidos en el orden del día' );
	}
	return array(
		'uid'                => $uid,
		'titulo'             => $titulo,
		'inicio'             => $inicio,
		'lugar'              => $lugar,
		'puntos'             => $puntos,
		'convocada_por_uid'  => '',
		'asistentes_uids'    => array(),
		'asistentes_sin_app' => 0,
		'anulada'            => false,
		'motivo_anulacion'   => '',
	);
}

// ---------------------------------------------------------------- tablón

const CONCEJO_LARGO_TITULO_ANUNCIO = 120;
const CONCEJO_LARGO_TEXTO_ANUNCIO  = 2000;

/** Un anuncio sin retirar (los retirados ya no se tocan). */
function concejo_anuncio( array $estado, string $uid ): array {
	if ( ! isset( $estado['anuncios'][ $uid ] ) ) {
		concejo_rechazar( 'No existe el anuncio' );
	}
	$anuncio = $estado['anuncios'][ $uid ];
	if ( ! empty( $anuncio['retirado'] ) ) {
		concejo_rechazar( 'El anuncio ya está retirado' );
	}
	return $anuncio;
}

/**
 * El anuncio que manda la app, comprobado y limpio (como
 * `Anuncio.problemas` y `EstadoConcejo._publicarAnuncio`). Quién y cuándo
 * los pone el servidor; sale sin fijar.
 */
function concejo_anuncio_publicado( array $datos, DateTimeImmutable $ahora, DateTimeZone $zona ): array {
	$uid    = trim( (string) ( $datos['uid'] ?? '' ) );
	$titulo = trim( (string) ( $datos['titulo'] ?? '' ) );
	$texto  = trim( (string) ( $datos['texto'] ?? '' ) );
	if ( '' === $uid || '' === $titulo ) {
		concejo_rechazar( 'Al anuncio le falta el título' );
	}
	if ( mb_strlen( $titulo ) > CONCEJO_LARGO_TITULO_ANUNCIO || mb_strlen( $texto ) > CONCEJO_LARGO_TEXTO_ANUNCIO ) {
		concejo_rechazar( 'El anuncio es demasiado largo' );
	}
	$hasta = $datos['hasta'] ?? null;
	if ( null !== $hasta ) {
		$hasta = (string) $hasta;
		$dia   = concejo_leer_fecha( $hasta, $zona )->format( 'Y-m-d' );
		if ( $dia < $ahora->setTimezone( $zona )->format( 'Y-m-d' ) ) {
			concejo_rechazar( 'La fecha hasta la que se ve el anuncio ya ha pasado' );
		}
	}
	return array(
		'uid'             => $uid,
		'titulo'          => $titulo,
		'texto'           => $texto,
		'autor_uid'       => '',
		'publicado'       => concejo_iso_utc( $ahora ),
		'hasta'           => $hasta,
		'fijado'          => false,
		'retirado'        => false,
		'motivo_retirada' => '',
	);
}

/** Como `Anuncio.vigenteEn`: sin retirar y sin pasar del día «hasta». */
function concejo_anuncio_vigente( array $anuncio, DateTimeImmutable $ahora, DateTimeZone $zona ): bool {
	if ( ! empty( $anuncio['retirado'] ) ) {
		return false;
	}
	if ( empty( $anuncio['hasta'] ) ) {
		return true;
	}
	return $ahora < concejo_leer_fecha( (string) $anuncio['hasta'], $zona )->setTime( 0, 0 )->modify( '+1 day' );
}

// ------------------------------------------------------- tareas en común

function concejo_tarea( array $estado, string $uid ): array {
	if ( ! isset( $estado['tareas'][ $uid ] ) ) {
		concejo_rechazar( 'No existe la tarea' );
	}
	return $estado['tareas'][ $uid ];
}

/** Como `Tarea._soloAntesDeEmpezar`: apuntarse y anular, antes de empezar. */
function concejo_tarea_antes_de_empezar( array $estado, string $uid, DateTimeImmutable $ahora, DateTimeZone $zona ): array {
	$tarea = concejo_tarea( $estado, $uid );
	if ( ! empty( $tarea['anulada'] ) ) {
		concejo_rechazar( 'La tarea está anulada' );
	}
	if ( ! empty( $tarea['hecha'] ) ) {
		concejo_rechazar( 'La tarea ya está hecha' );
	}
	if ( $ahora >= concejo_leer_fecha( $tarea['inicio'], $zona ) ) {
		concejo_rechazar( 'La tarea ya ha empezado' );
	}
	return $tarea;
}

/**
 * La tarea que manda la app, comprobada y limpia (como `Tarea.problemas`
 * y `EstadoConcejo._crearTarea`). Sale sin nadie apuntado.
 */
function concejo_tarea_creada( array $datos, DateTimeImmutable $ahora, DateTimeZone $zona ): array {
	$uid    = trim( (string) ( $datos['uid'] ?? '' ) );
	$titulo = trim( (string) ( $datos['titulo'] ?? '' ) );
	$inicio = (string) ( $datos['inicio'] ?? '' );
	$plazas = $datos['plazas'] ?? 0;
	if ( '' === $uid || '' === $titulo || '' === $inicio ) {
		concejo_rechazar( 'A la tarea le falta título o fecha' );
	}
	if ( ! is_numeric( $plazas ) || (int) $plazas < 0 ) {
		concejo_rechazar( 'Las plazas no pueden ser negativas' );
	}
	if ( $ahora >= concejo_leer_fecha( $inicio, $zona ) ) {
		concejo_rechazar( 'La tarea ya ha empezado' );
	}
	return array(
		'uid'              => $uid,
		'titulo'           => $titulo,
		'inicio'           => $inicio,
		'lugar'            => trim( (string) ( $datos['lugar'] ?? '' ) ),
		'descripcion'      => trim( (string) ( $datos['descripcion'] ?? '' ) ),
		'plazas'           => (int) $plazas,
		'creada_por_uid'   => '',
		'apuntados_uids'   => array(),
		'anulada'          => false,
		'motivo_anulacion' => '',
		'hecha'            => false,
		'nota_hecha'       => '',
	);
}
