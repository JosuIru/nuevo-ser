<?php
/**
 * Lo que ve cada persona: el estado del espacio filtrado para ella, con la
 * forma que lee la app (`lib/datos/instantanea.dart`).
 *
 * - Los **borradores** solo los ve la mesa.
 * - Las **aportaciones anónimas** llegan sin autor a todo el mundo (la mesa
 *   incluida) salvo a quien la escribió; las pendientes de moderación,
 *   solo a la mesa y a quien la escribió; de las retiradas, fuera de la
 *   mesa, queda el hueco con el motivo y sin el texto.
 * - Las **papeletas** solo salen cuando se ha cerrado la votación, todas a
 *   la vez y ordenadas por contenido (no por llegada): mientras se vota,
 *   nadie (ni la mesa) ve cómo va.
 * - De las personas, solo nombre, rol y fin de mandato.
 *
 * Función pura: se prueba con `php tests/test_vista.php`.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * @param array<string, array[]> $papeletas_por_asunto asunto_uid => papeletas.
 */
function concejo_vista(
	array $estado,
	array $papeletas_por_asunto,
	string $persona_uid,
	string $nombre_espacio,
	int $revision,
	DateTimeImmutable $ahora,
	DateTimeZone $zona
): array {
	$es_mesa = concejo_es_mesa( $estado['personas'][ $persona_uid ] ?? null, $ahora, $zona );

	$asuntos = array();
	foreach ( $estado['asuntos'] ?? array() as $uid => $asunto ) {
		if ( ! empty( $asunto['abierto'] ) || $es_mesa ) {
			$asuntos[ $uid ] = $asunto;
		}
	}

	$debates = array();
	foreach ( $estado['debates'] ?? array() as $asunto_uid => $debate ) {
		if ( ! isset( $asuntos[ $asunto_uid ] ) ) {
			continue;
		}
		$aportaciones = array();
		foreach ( $debate['aportaciones'] as $aportacion ) {
			$es_mia = $aportacion['autor_uid'] === $persona_uid;
			if ( 'pendiente' === $aportacion['estado'] && ! $es_mia && ! $es_mesa ) {
				continue;
			}
			if ( ! empty( $aportacion['anonima'] ) && ! $es_mia ) {
				$aportacion['autor_uid'] = '';
			}
			if ( 'retirada' === $aportacion['estado'] && ! $es_mesa ) {
				$aportacion['texto'] = '';
			}
			$aportaciones[] = $aportacion;
		}
		$debate['aportaciones'] = $aportaciones;
		$debates[]              = $debate;
	}

	$urnas = array();
	foreach ( $asuntos as $asunto_uid => $asunto ) {
		$urna       = concejo_urna( $estado, $asunto_uid );
		$papeletas  = array();
		if ( 'seguimiento' === concejo_fase( $asunto, $ahora, $zona ) ) {
			// Ordenadas por lo que dicen: el orden no cuenta nada de la
			// llegada y la vista sale igual en cada petición (su huella no
			// cambia si nada ha cambiado).
			$papeletas = array_values( $papeletas_por_asunto[ $asunto_uid ] ?? array() );
			usort(
				$papeletas,
				fn( $a, $b ) => strcmp(
					(string) json_encode( array( $a['opciones'], $a['persona_uid'], $a['hora'] ) ),
					(string) json_encode( array( $b['opciones'], $b['persona_uid'], $b['hora'] ) )
				)
			);
		}
		if ( array() === $urna['participaciones'] && array() === $urna['conteos'] && array() === $papeletas ) {
			continue;
		}
		$urnas[] = array(
			'asunto_uid'      => $asunto_uid,
			'participaciones' => $urna['participaciones'],
			'papeletas'       => array_map(
				fn( $papeleta ) => array(
					'opciones'    => array_values( $papeleta['opciones'] ),
					'hora'        => $papeleta['hora'],
					'persona_uid' => $papeleta['persona_uid'],
				),
				$papeletas
			),
			'conteos'         => array_map(
				function ( $conteo ) {
					$conteo['marcas'] = (object) (array) $conteo['marcas'];
					return $conteo;
				},
				$urna['conteos']
			),
		);
	}

	$consentimientos = array();
	foreach ( $estado['consentimientos'] ?? array() as $asunto_uid => $consentimiento ) {
		if ( isset( $asuntos[ $asunto_uid ] ) ) {
			$consentimientos[ $asunto_uid ] = $consentimiento;
		}
	}

	return array(
		'nombre_espacio'  => $nombre_espacio,
		'revision'        => $revision,
		'yo'              => $persona_uid,
		'personas'        => array_values(
			array_map(
				fn( $persona ) => array(
					'uid'           => $persona['uid'],
					'nombre'        => $persona['nombre'],
					'rol'           => $persona['rol'],
					'mandato_hasta' => $persona['mandato_hasta'] ?? null,
				),
				$estado['personas'] ?? array()
			)
		),
		'asuntos'         => array_values( $asuntos ),
		'urnas'           => $urnas,
		'debates'         => $debates,
		'consentimientos' => (object) $consentimientos,
		'compromisos'     => array_values(
			array_filter( $estado['compromisos'] ?? array(), fn( $c ) => isset( $asuntos[ $c['asunto_uid'] ] ) )
		),
		'actas'           => array_values(
			array_filter( $estado['actas'] ?? array(), fn( $a ) => isset( $asuntos[ $a['asunto_uid'] ] ) )
		),
	);
}
