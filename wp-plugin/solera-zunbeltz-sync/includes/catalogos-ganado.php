<?php
/**
 * Catálogos del ganado (castellano) para el panel.
 *
 * GENERADO desde apps/solera-zunbeltz/lib/modelos/ (constantes.dart,
 * ganado.dart, ganado_ecologico.dart) con
 * `dart run tool/generar_plantillas_php.dart`. No editar a mano.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_ESPECIES_GANADO = array(
	'vacuno' => 'Vacuno',
	'ovino' => 'Ovino',
	'caprino' => 'Caprino',
	'porcino' => 'Porcino',
	'aves' => 'Aves',
	'equino' => 'Equino',
	'varias' => 'Varias / sin ganado',
);

const SZS_SEXOS_ANIMAL = array(
	'hembra' => 'Hembra',
	'macho' => 'Macho',
	'castrado' => 'Castrado',
);

const SZS_ESTADOS_ANIMAL = array(
	'activo' => 'En el espacio',
	'vendido' => 'Vendido',
	'sacrificado' => 'Sacrificado',
	'muerto' => 'Muerto',
	'baja' => 'Baja por otro motivo',
);

const SZS_TIPOS_MOVIMIENTO_GANADO = array(
	'traslado' => 'Cambio de pieza',
	'entrada' => 'Entrada en el espacio',
	'salida' => 'Salida del espacio',
);

const SZS_TIPOS_EVENTO_GANADO = array(
	'tratamiento' => 'Cura o tratamiento',
	'saneamiento' => 'Saneamiento / vacunación',
	'pesaje' => 'Pesaje',
	'parto' => 'Parto',
	'incidencia' => 'Incidencia (cojera, herida, ataque…)',
	'otro' => 'Otro manejo',
);

const SZS_CLASES_MEDICAMENTO = array(
	'alopatico' => 'Alopático de síntesis química (antibióticos incluidos)',
	'antiparasitario' => 'Antiparasitario',
	'vacuna' => 'Vacuna',
	'natural' => 'Fitoterapia, homeopatía u oligoelementos',
);

const SZS_TIPOS_EVENTO_CON_MEDICAMENTO = array(
	'tratamiento',
	'saneamiento',
);
