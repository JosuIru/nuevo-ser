<?php
/**
 * Roles y capacidades de Solera Zunbeltz.
 *
 * La app **no conoce los roles**: sólo recibe la lista de capacidades de la
 * persona conectada (ver `GET /yo`) y decide la interfaz a partir de ellas.
 * Así, añadir un rol nuevo (mentor, asesor veterinario, operario…) es tocar
 * este mapa o engancharse al filtro `szs_roles` desde otro plugin, sin
 * publicar una versión nueva de la app mientras las capacidades existan.
 *
 * Capacidades sobre tareas de mantenimiento:
 *
 * - `ver_todas_tareas`        ve las tareas de todo el espacio. Sin ella,
 *                             sólo las que tiene asignadas o ha creado y
 *                             las generales (sin responsable).
 * - `crear_tareas`            da de alta tareas nuevas.
 * - `editar_cualquier_tarea`  cambia cualquier campo de cualquier tarea.
 * - `asignar_tareas`          asigna tareas a otras personas.
 *
 * Capacidades sobre el resto de entidades (ver `entidades.php`):
 *
 * - `editar_espacio`          crea, edita y borra fincas, zonas y puntos.
 * - `anadir_puntos`           añade puntos y los mueve (corrales móviles,
 *                             bidones…) o cambia su estado; no los borra.
 * - `gestionar_proyectos`     ve todos los proyectos, edita sus fichas y lo
 *                             que solo lleva coordinación (presupuesto,
 *                             fianza, acompañamiento, incidencias de
 *                             cumplimiento) y escribe aunque estén cerrados.
 * - `enviar_peticiones`       pide tareas nuevas.
 * - `gestionar_peticiones`    ve todas las peticiones y las acepta o descarta.
 * - `crear_avisos`            da avisos de campo (animal enfermo, rotura…).
 * - `gestionar_avisos`        edita y resuelve cualquier aviso.
 * - `ver_actividad`           recibe el registro de actividad del espacio.
 * - `crear_contactos`         añade contactos a la agenda del espacio.
 * - `gestionar_contactos`     edita y borra cualquier contacto.
 *
 * Reparto acordado con Zunbeltz el 2026-10-06: sólo la coordinación crea y
 * asigna tareas; las personas tester ven las suyas y las generales, las
 * ejecutan y piden tareas nuevas mediante peticiones.
 *
 * Sin `editar_cualquier_tarea`, una persona puede ejecutar (estado, coste)
 * las tareas que tiene asignadas o que ha creado, editar el contenido de las
 * que ha creado, cogerse una tarea libre y soltar una suya. Ver
 * `politica-tareas.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_CAPACIDAD_VER_TODAS_TAREAS       = 'ver_todas_tareas';
const SZS_CAPACIDAD_CREAR_TAREAS           = 'crear_tareas';
const SZS_CAPACIDAD_EDITAR_CUALQUIER_TAREA = 'editar_cualquier_tarea';
const SZS_CAPACIDAD_ASIGNAR_TAREAS         = 'asignar_tareas';
const SZS_CAPACIDAD_EDITAR_ESPACIO         = 'editar_espacio';
const SZS_CAPACIDAD_ANADIR_PUNTOS          = 'anadir_puntos';
const SZS_CAPACIDAD_GESTIONAR_PROYECTOS    = 'gestionar_proyectos';
const SZS_CAPACIDAD_ENVIAR_PETICIONES      = 'enviar_peticiones';
const SZS_CAPACIDAD_GESTIONAR_PETICIONES   = 'gestionar_peticiones';
const SZS_CAPACIDAD_CREAR_AVISOS           = 'crear_avisos';
const SZS_CAPACIDAD_GESTIONAR_AVISOS       = 'gestionar_avisos';
const SZS_CAPACIDAD_VER_ACTIVIDAD          = 'ver_actividad';
const SZS_CAPACIDAD_CREAR_CONTACTOS        = 'crear_contactos';
const SZS_CAPACIDAD_GESTIONAR_CONTACTOS    = 'gestionar_contactos';

const SZS_ROL_COORDINADOR = 'coordinador';
const SZS_ROL_TESTER      = 'tester';

/**
 * Mapa rol → { etiqueta, capacidades }. Filtrable con `szs_roles` para
 * añadir o ajustar roles sin tocar el plugin.
 *
 * @return array<string, array{etiqueta: string, capacidades: string[]}>
 */
function szs_roles(): array {
	$roles = array(
		SZS_ROL_COORDINADOR => array(
			'etiqueta'    => 'Coordinación (admin)',
			'capacidades' => array(
				SZS_CAPACIDAD_VER_TODAS_TAREAS,
				SZS_CAPACIDAD_CREAR_TAREAS,
				SZS_CAPACIDAD_EDITAR_CUALQUIER_TAREA,
				SZS_CAPACIDAD_ASIGNAR_TAREAS,
				SZS_CAPACIDAD_EDITAR_ESPACIO,
				SZS_CAPACIDAD_ANADIR_PUNTOS,
				SZS_CAPACIDAD_GESTIONAR_PROYECTOS,
				SZS_CAPACIDAD_ENVIAR_PETICIONES,
				SZS_CAPACIDAD_GESTIONAR_PETICIONES,
				SZS_CAPACIDAD_CREAR_AVISOS,
				SZS_CAPACIDAD_GESTIONAR_AVISOS,
				SZS_CAPACIDAD_VER_ACTIVIDAD,
				SZS_CAPACIDAD_CREAR_CONTACTOS,
				SZS_CAPACIDAD_GESTIONAR_CONTACTOS,
			),
		),
		SZS_ROL_TESTER      => array(
			'etiqueta'    => 'Tester',
			'capacidades' => array(
				SZS_CAPACIDAD_ANADIR_PUNTOS,
				SZS_CAPACIDAD_ENVIAR_PETICIONES,
				SZS_CAPACIDAD_CREAR_AVISOS,
				SZS_CAPACIDAD_CREAR_CONTACTOS,
			),
		),
	);
	return apply_filters( 'szs_roles', $roles );
}

function szs_rol_existe( string $rol ): bool {
	return array_key_exists( $rol, szs_roles() );
}

/** @return string[] */
function szs_capacidades_de_rol( string $rol ): array {
	$roles = szs_roles();
	return isset( $roles[ $rol ] ) ? array_values( $roles[ $rol ]['capacidades'] ) : array();
}

function szs_etiqueta_rol( string $rol ): string {
	$roles = szs_roles();
	return isset( $roles[ $rol ] ) ? (string) $roles[ $rol ]['etiqueta'] : $rol;
}
