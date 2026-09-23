<?php
/**
 * Smoke tests de solera-zunbeltz-sync. Sin WP cargado de verdad: solo
 * probamos las funciones puras (recorte, casteo, normalización, roles y
 * política de permisos sobre tareas), con
 * stubs mínimos de las funciones WP que se llaman a nivel de fichero
 * (`register_activation_hook`, `add_action`) para poder hacer el
 * `require` sin un WordPress real. Todo lo que toca `$wpdb` o
 * `sanitize_text_field` vive en pruebas manuales con WP cargado.
 *
 * Ejecutar: php tests/test_sync.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function apply_filters( $hook, $valor ) {
	return $valor;
}
function sanitize_text_field( $texto ) {
	return trim( (string) $texto );
}
function sanitize_textarea_field( $texto ) {
	return trim( (string) $texto );
}

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf(
			STDERR,
			"FALLO: %s\n  esperado: %s\n  real:     %s\n",
			$titulo,
			var_export( $esperado, true ),
			var_export( $real, true )
		);
	}
}

// --- szs_recortar ---
afirmar( 'Rellenar comederos', szs_recortar( 'Rellenar comederos', 500 ), 'szs_recortar deja pasar texto corto' );
afirmar( str_repeat( 'a', 5 ), szs_recortar( str_repeat( 'a', 10 ), 5 ), 'szs_recortar corta al máximo' );
afirmar( '', szs_recortar( null, 10 ), 'szs_recortar con null da cadena vacía' );

// --- szs_entero_o_null ---
afirmar( null, szs_entero_o_null( null ), 'szs_entero_o_null(null) es null' );
afirmar( null, szs_entero_o_null( '' ), 'szs_entero_o_null(\'\') es null' );
afirmar( 7, szs_entero_o_null( 7 ), 'szs_entero_o_null respeta un entero' );
afirmar( 7, szs_entero_o_null( '7' ), 'szs_entero_o_null castea un string numérico' );
afirmar( 0, szs_entero_o_null( 0 ), 'szs_entero_o_null(0) es 0, no null' );

// --- szs_normalizar_tarea ---
$fila = array(
	'uid'               => 'abc123',
	'finca_nombre'      => 'Zunbeltz',
	'titulo'            => 'Rellenar comederos',
	'descripcion'       => 'Comedero norte',
	'responsable'       => 'Maite',
	'prioridad'         => 'alta',
	'estado'            => 'pendiente',
	'fecha_objetivo_ms' => '1700000000000',
	'coste_centimos'    => null,
	'recurrencia_dias'  => '7',
	'fecha_creacion_ms' => '1600000000000',
	'actualizado_ms'    => '1600000000000',
	'recibido_en'       => '2026-09-22 10:00:00',
);
$json = szs_normalizar_tarea( $fila );
afirmar( 'abc123', $json['uid'], 'szs_normalizar_tarea conserva el uid' );
afirmar( 1700000000000, $json['fecha_objetivo_ms'], 'szs_normalizar_tarea castea fecha_objetivo_ms a int' );
afirmar( null, $json['coste_centimos'], 'szs_normalizar_tarea conserva null en coste_centimos' );
afirmar( 7, $json['recurrencia_dias'], 'szs_normalizar_tarea castea recurrencia_dias a int' );
afirmar( '', $json['responsable_uid'], 'szs_normalizar_tarea rellena responsable_uid ausente (tareas v0.1)' );
afirmar( false, array_key_exists( 'recibido_en', $json ), 'szs_normalizar_tarea descarta columnas internas' );

// --- roles ---
afirmar( true, szs_rol_existe( 'coordinador' ), 'existe el rol coordinador' );
afirmar( true, szs_rol_existe( 'tester' ), 'existe el rol tester' );
afirmar( false, szs_rol_existe( 'root' ), 'un rol inventado no existe' );
afirmar( array(), szs_capacidades_de_rol( 'root' ), 'un rol inventado no tiene capacidades' );
afirmar( true, in_array( 'asignar_tareas', szs_capacidades_de_rol( 'coordinador' ), true ), 'coordinación asigna' );
afirmar( false, in_array( 'asignar_tareas', szs_capacidades_de_rol( 'tester' ), true ), 'tester no asigna' );

// --- política de tareas ---
$coordinacion = szs_capacidades_de_rol( 'coordinador' );
$tester       = szs_capacidades_de_rol( 'tester' );

function tarea_base( array $cambios = array() ): array {
	return szs_normalizar_tarea(
		array_merge(
			array(
				'uid'             => 't1',
				'finca_nombre'    => 'Zunbeltz',
				'titulo'          => 'Reparar cierre',
				'responsable'     => 'Ane',
				'responsable_uid' => 'ane',
				'creado_por_uid'  => 'coord',
				'estado'          => 'pendiente',
				'actualizado_ms'  => 100,
			),
			$cambios
		)
	);
}

// Alta de tareas.
$r = szs_resolver_tarea_entrante( null, tarea_base( array( 'creado_por_uid' => 'ane', 'responsable_uid' => '' ) ), 'ane', $tester );
afirmar( 'insertar', $r['accion'], 'tester crea una tarea sin asignar' );
afirmar( false, $r['ajustada'], 'crear sin asignar no se ajusta' );

$r = szs_resolver_tarea_entrante( null, tarea_base( array( 'creado_por_uid' => 'ane', 'responsable_uid' => 'jon' ) ), 'ane', $tester );
afirmar( 'insertar', $r['accion'], 'tester crea una tarea asignada a otra persona: entra igual' );
afirmar( '', $r['datos']['responsable_uid'], '… pero sin asignar' );
afirmar( true, $r['ajustada'], '… y el dispositivo debe quedarse con la versión del servidor' );

$r = szs_resolver_tarea_entrante( null, tarea_base( array( 'creado_por_uid' => 'otra' ) ), 'coord', $coordinacion );
afirmar( 'coord', $r['datos']['creado_por_uid'], 'el creador lo fija el servidor, no el dispositivo' );
afirmar( 'ane', $r['datos']['responsable_uid'], 'coordinación asigna al crear' );

$r = szs_resolver_tarea_entrante( null, tarea_base(), 'x', array() );
afirmar( 'rechazar', $r['accion'], 'sin crear_tareas no se crea' );

// Ejecución de tareas existentes.
$existente = tarea_base();
$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'estado' => 'hecha', 'actualizado_ms' => 200 ) ), 'ane', $tester );
afirmar( 'actualizar', $r['accion'], 'la responsable marca su tarea como hecha' );
afirmar( 'hecha', $r['datos']['estado'], '… y queda hecha' );
afirmar( 200, $r['datos']['actualizado_ms'], '… con la marca de tiempo nueva' );

$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'estado' => 'hecha', 'actualizado_ms' => 200 ) ), 'jon', $tester );
afirmar( 'rechazar', $r['accion'], 'un tester no cambia el estado de una tarea ajena' );
afirmar( true, $r['ajustada'], '… y su dispositivo recupera la versión del servidor' );

$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'titulo' => 'Otro', 'estado' => 'en_curso', 'actualizado_ms' => 200 ) ), 'ane', $tester );
afirmar( 'actualizar', $r['accion'], 'la responsable no creadora: cambio parcial' );
afirmar( 'en_curso', $r['datos']['estado'], '… el estado sí entra' );
afirmar( 'Reparar cierre', $r['datos']['titulo'], '… el título no' );
afirmar( 'cambios_parciales', $r['motivo'], '… y se avisa' );

$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'titulo' => 'Otro', 'responsable_uid' => 'jon', 'actualizado_ms' => 200 ) ), 'coord', $coordinacion );
afirmar( 'actualizar', $r['accion'], 'coordinación edita y reasigna cualquier tarea' );
afirmar( 'jon', $r['datos']['responsable_uid'], '… reasignada' );

$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'estado' => 'hecha', 'actualizado_ms' => 50 ) ), 'coord', $coordinacion );
afirmar( 'ignorar', $r['accion'], 'una versión más antigua se ignora (last-write-wins)' );

// Coger y soltar tareas.
$libre = tarea_base( array( 'responsable_uid' => '', 'responsable' => '' ) );
$r = szs_resolver_tarea_entrante( $libre, tarea_base( array( 'responsable_uid' => 'jon', 'responsable' => 'Jon', 'actualizado_ms' => 200 ) ), 'jon', $tester );
afirmar( 'jon', $r['datos']['responsable_uid'] ?? null, 'un tester se coge una tarea libre' );

$r = szs_resolver_tarea_entrante( $libre, tarea_base( array( 'responsable_uid' => 'mikel', 'responsable' => 'Mikel', 'actualizado_ms' => 200 ) ), 'jon', $tester );
afirmar( 'rechazar', $r['accion'], 'un tester no asigna una tarea libre a otra persona' );

$r = szs_resolver_tarea_entrante( $existente, tarea_base( array( 'responsable_uid' => '', 'responsable' => '', 'actualizado_ms' => 200 ) ), 'ane', $tester );
afirmar( '', $r['datos']['responsable_uid'] ?? null, 'la responsable suelta su tarea' );

// Visibilidad.
afirmar( true, szs_tarea_visible( $existente, 'jon', $tester ), 'tester ve todas las tareas' );
afirmar( false, szs_tarea_visible( $existente, 'jon', array() ), 'sin ver_todas_tareas no ve ajenas' );
afirmar( true, szs_tarea_visible( $existente, 'ane', array() ), '… pero sí las suyas' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests de solera-zunbeltz-sync pasaron.\n";
