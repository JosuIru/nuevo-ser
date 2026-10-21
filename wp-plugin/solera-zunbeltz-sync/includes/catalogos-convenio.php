<?php
/**
 * Catálogos del convenio tester (castellano) para el panel: bloques y
 * partidas de gasto, quién asume, movimientos de fianza, niveles de
 * incidencia y tipos de acompañamiento.
 *
 * GENERADO desde apps/solera-zunbeltz/lib/modelos/constantes.dart
 * con `dart run tool/generar_plantillas_php.dart`. No editar a mano.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_BLOQUES_GASTO = array(
	'directos' => 'I. Costes directos',
	'maquinaria' => 'II. Costes de maquinaria',
	'transformacion' => 'III. Coste de transformación',
	'mano_obra' => 'IV. Costes de mano de obra',
	'indirectos' => 'V. Costes indirectos',
	'amortizacion' => 'VI. Amortización',
);

const SZS_PARTIDAS_GASTO = array(
	'directos' => array(
		'animales' => 'Animales',
		'compra_alimento' => 'Compra de alimento',
		'forraje' => 'Forraje',
		'concentrados' => 'Concentrados',
		'transporte_concentrados' => 'Transporte de concentrados',
		'zoosanitarios' => 'Productos zoosanitarios y otros suministros',
		'inseminacion' => 'Inseminación',
		'vacunas_veterinario' => 'Vacunas y veterinario',
		'tasas_cpaen' => 'Tasas CPAEN',
		'cama_limpieza' => 'Cama, limpieza y desinfección',
		'agua_luz' => 'Agua, luz y calefacción',
		'transporte' => 'Transporte',
		'semillas_pastizales' => 'Semillas y manejo de pastizales',
		'canon_arrendamiento' => 'Canon de arrendamiento',
	),
	'maquinaria' => array(
		'trabajos_realizados' => 'Trabajos realizados',
		'combustibles' => 'Combustibles',
		'reparaciones_cercados' => 'Reparaciones y repuestos de cercados',
	),
	'transformacion' => array(
		'transporte_matadero' => 'Transporte',
		'tasa_sanitaria' => 'Tasa sanitaria',
		'sacrificio' => 'Sacrificio',
		'despiece' => 'Deshuese y despiece',
		'obrador' => 'Trabajos de elaboración (obrador)',
		'envasado' => 'Envasado y bolsas',
		'transporte_venta' => 'Transporte de venta',
		'comercializacion' => 'Comercialización',
	),
	'mano_obra' => array(
		'asalariada' => 'Asalariada',
		'no_asalariada' => 'No asalariada',
	),
	'indirectos' => array(
		'financieros_impuestos' => 'Intereses, gastos financieros e impuestos',
		'mano_obra_familiar' => 'Mano de obra familiar',
	),
	'amortizacion' => array(
		'instalaciones' => 'Instalaciones',
		'material_ganadero' => 'Material ganadero',
		'adecuaciones' => 'Adecuaciones de finca',
	),
);

const SZS_PARTIDAS_ASUMIDAS_POR_TESTER = array(
	'animales',
	'compra_alimento',
	'forraje',
	'concentrados',
	'transporte_concentrados',
	'zoosanitarios',
	'inseminacion',
	'vacunas_veterinario',
);

const SZS_ASUMIDO_POR = array(
	'tester' => 'Persona tester',
	'zunbeltz' => 'Zunbeltz',
);

const SZS_TIPOS_MOVIMIENTO_FIANZA = array(
	'deposito' => 'Depósito',
	'devolucion' => 'Devolución',
	'retencion' => 'Retención',
);

const SZS_NIVELES_INCIDENCIA = array(
	'leve' => 'Leve',
	'grave' => 'Grave',
	'muy_grave' => 'Muy grave',
);

const SZS_TIPOS_ACOMPANAMIENTO = array(
	'formacion' => 'Formación',
	'visita_referencia' => 'Visita a explotación de referencia',
	'asesoramiento' => 'Asesoramiento de ganadería experta',
	'reunion' => 'Reunión de seguimiento',
	'visita_finca' => 'Visita del equipo a la finca',
	'visita_recibida' => 'Visita recibida en el espacio',
	'mercado' => 'Mercado o feria',
	'difusion' => 'Medio de difusión',
	'busqueda_canales' => 'Búsqueda de canales de venta',
	'apoyo_tareas' => 'Apoyo en tareas generales',
);

