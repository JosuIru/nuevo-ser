<?php
/**
 * Paso entre la instantánea de la app (listas, como en
 * `lib/datos/instantanea.dart`) y el estado del servidor (mapas por uid,
 * papeletas aparte). Sirve para cargar un pueblo de ejemplo o una copia de
 * seguridad hecha desde la app, y para el test de paridad.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * @return array{estado: array, papeletas: array<string, array[]>}
 */
function concejo_estado_desde_instantanea( array $instantanea ): array {
	$por = function ( array $lista, string $clave ): array {
		$mapa = array();
		foreach ( $lista as $elemento ) {
			$mapa[ (string) $elemento[ $clave ] ] = $elemento;
		}
		return $mapa;
	};
	$urnas     = array();
	$papeletas = array();
	foreach ( $instantanea['urnas'] ?? array() as $urna ) {
		$asunto_uid               = (string) $urna['asunto_uid'];
		$urnas[ $asunto_uid ]     = array(
			'asunto_uid'      => $asunto_uid,
			'participaciones' => $urna['participaciones'] ?? array(),
			'conteos'         => $urna['conteos'] ?? array(),
		);
		$papeletas[ $asunto_uid ] = array_map(
			fn( $papeleta ) => array_merge( $papeleta, array( 'asunto_uid' => $asunto_uid ) ),
			$urna['papeletas'] ?? array()
		);
	}
	return array(
		'estado'    => array(
			'personas'        => $por( $instantanea['personas'] ?? array(), 'uid' ),
			'asuntos'         => $por( $instantanea['asuntos'] ?? array(), 'uid' ),
			'debates'         => $por( $instantanea['debates'] ?? array(), 'asunto_uid' ),
			'consentimientos' => (array) ( $instantanea['consentimientos'] ?? array() ),
			'urnas'           => $urnas,
			'compromisos'     => $por( $instantanea['compromisos'] ?? array(), 'uid' ),
			'actas'           => $por( $instantanea['actas'] ?? array(), 'asunto_uid' ),
			'sesiones'        => $por( $instantanea['sesiones'] ?? array(), 'uid' ),
			'anuncios'        => $por( $instantanea['anuncios'] ?? array(), 'uid' ),
			'tareas'          => $por( $instantanea['tareas'] ?? array(), 'uid' ),
		),
		'papeletas' => $papeletas,
	);
}
