<?php
/**
 * Códigos personales en papel (`docs/04-concejo.md` §4.1): la mesa da a
 * cada vecina un código que entra en la app y la identifica. Es el token
 * de la API; el servidor solo guarda su huella (sha256).
 *
 * Doce caracteres sin los que se confunden al copiarlos (0/O, 1/I/L), en
 * tres grupos: `K7PM-3QXD-9TRA`. 31^12 ≈ 7,9·10^17 combinaciones: no se
 * pueden adivinar probando.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const CONCEJO_ALFABETO_CODIGO = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

function concejo_generar_codigo(): string {
	$alfabeto   = CONCEJO_ALFABETO_CODIGO;
	$caracteres = '';
	for ( $posicion = 0; $posicion < 12; $posicion++ ) {
		$caracteres .= $alfabeto[ random_int( 0, strlen( $alfabeto ) - 1 ) ];
	}
	return implode( '-', str_split( $caracteres, 4 ) );
}

/** Como lo teclee la persona: minúsculas, espacios o sin guiones. */
function concejo_normalizar_codigo( string $codigo ): string {
	return preg_replace( '/[^A-Z0-9]/', '', strtoupper( $codigo ) ) ?? '';
}

function concejo_huella_codigo( string $codigo ): string {
	return hash( 'sha256', concejo_normalizar_codigo( $codigo ) );
}
