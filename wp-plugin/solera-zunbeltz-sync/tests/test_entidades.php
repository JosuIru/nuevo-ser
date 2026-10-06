<?php
/**
 * Tests de la política de entidades sincronizadas (fincas, puntos, zonas,
 * proyectos y su seguimiento, peticiones, avisos…). Funciones puras: sin
 * WordPress, con los mismos stubs que `test_sync.php`.
 *
 * Ejecutar: php tests/test_entidades.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}
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
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

$coordinacion = szs_capacidades_de_rol( 'coordinador' );
$tester       = szs_capacidades_de_rol( 'tester' );

function entidad( string $tipo, array $datos = array(), array $extra = array() ): array {
	return szs_normalizar_entidad(
		array_merge(
			array(
				'tipo'           => $tipo,
				'uid'            => $tipo . '-1',
				'actualizado_ms' => 100,
				'borrado'        => false,
				'proyecto_uid'   => '',
				'datos'          => $datos,
			),
			$extra
		)
	);
}

function accion( ?array $existente, array $entrante, string $persona, array $capacidades, ?array $proyecto = null ): string {
	return szs_resolver_entidad_entrante( $existente, $entrante, $persona, $capacidades, $proyecto )['accion'];
}

// --- normalización ---
$n = szs_normalizar_entidad( array( 'tipo' => 'finca', 'uid' => 'f1', 'datos' => 'no es objeto', 'actualizado_ms' => '7' ) );
afirmar( array(), $n['datos'], 'datos que no son objeto quedan vacíos' );
afirmar( 7, $n['actualizado_ms'], 'actualizado_ms se castea a entero' );
afirmar( false, $n['borrado'], 'borrado por defecto es false' );
afirmar( false, szs_tipo_entidad_existe( 'cohete' ), 'un tipo inventado no existe' );
afirmar( 'rechazar', accion( null, entidad( 'cohete' ), 'coord', $coordinacion ), 'un tipo inventado se rechaza' );

// --- last-write-wins ---
$finca = entidad( 'finca', array( 'nombre' => 'Zunbeltz' ) );
afirmar( 'ignorar', accion( $finca, entidad( 'finca', array( 'nombre' => 'Otra' ), array( 'actualizado_ms' => 50 ) ), 'coord', $coordinacion ), 'versión más antigua se ignora' );
afirmar( 'ignorar', accion( null, entidad( 'finca', array(), array( 'borrado' => true ) ), 'coord', $coordinacion ), 'borrar algo que el servidor no tiene se ignora' );

// --- espacio: fincas y zonas solo coordinación ---
afirmar( 'insertar', accion( null, $finca, 'coord', $coordinacion ), 'coordinación crea fincas' );
afirmar( 'rechazar', accion( null, $finca, 'ane', $tester ), 'tester no crea fincas' );
afirmar( 'rechazar', accion( null, entidad( 'zona' ), 'ane', $tester ), 'tester no crea zonas' );
afirmar( 'actualizar', accion( $finca, entidad( 'finca', array(), array( 'borrado' => true, 'actualizado_ms' => 200 ) ), 'coord', $coordinacion ), 'coordinación borra una finca' );

// --- puntos: tester añade y mueve, no borra ni cambia el tipo ---
$punto = entidad( 'punto', array( 'tipo' => 'corral_movil', 'nombre' => 'Corral', 'latitud' => 42.0, 'longitud' => -1.9, 'finca_uid' => 'f1' ) );
afirmar( 'insertar', accion( null, $punto, 'ane', $tester ), 'tester añade un punto' );
$movido = entidad( 'punto', array( 'tipo' => 'corral_movil', 'nombre' => 'Corral', 'latitud' => 42.1, 'longitud' => -1.8, 'finca_uid' => 'f1' ), array( 'actualizado_ms' => 200 ) );
afirmar( 'actualizar', accion( $punto, $movido, 'ane', $tester ), 'tester mueve un punto' );
$retipado = entidad( 'punto', array( 'tipo' => 'cuadra', 'nombre' => 'Corral', 'latitud' => 42.0, 'longitud' => -1.9, 'finca_uid' => 'f1' ), array( 'actualizado_ms' => 200 ) );
afirmar( 'rechazar', accion( $punto, $retipado, 'ane', $tester ), 'tester no cambia el tipo de un punto' );
afirmar( 'rechazar', accion( $punto, entidad( 'punto', array(), array( 'borrado' => true, 'actualizado_ms' => 200 ) ), 'ane', $tester ), 'tester no borra puntos' );
afirmar( 'actualizar', accion( $punto, $retipado, 'coord', $coordinacion ), 'coordinación edita cualquier campo de un punto' );

// --- proyectos: solo coordinación; cada uno de una persona tester ---
$proyecto_ane = entidad( 'proyecto', array( 'nombre' => 'Quesería', 'persona_uid' => 'ane', 'estado' => 'abierto' ), array( 'uid' => 'p1' ) );
afirmar( 'insertar', accion( null, $proyecto_ane, 'coord', $coordinacion ), 'coordinación crea proyectos' );
afirmar( 'rechazar', accion( null, $proyecto_ane, 'ane', $tester ), 'tester no crea proyectos' );
afirmar( 'rechazar', accion( $proyecto_ane, entidad( 'proyecto', array( 'nombre' => 'X', 'persona_uid' => 'ane' ), array( 'uid' => 'p1', 'actualizado_ms' => 200 ) ), 'ane', $tester ), 'tester no edita la ficha de su proyecto' );

// --- seguimiento del proyecto ---
$apunte = entidad( 'apunte', array( 'concepto' => 'Cencerro', 'importe_centimos' => 1500 ), array( 'proyecto_uid' => 'p1' ) );
afirmar( 'insertar', accion( null, $apunte, 'ane', $tester, $proyecto_ane ), 'tester apunta un gasto en su proyecto' );
afirmar( 'rechazar', accion( null, $apunte, 'jon', $tester, $proyecto_ane ), 'tester no apunta en un proyecto ajeno' );
afirmar( 'rechazar', accion( null, $apunte, 'ane', $tester, null ), 'sin proyecto conocido no entra' );
$cerrado = entidad( 'proyecto', array( 'persona_uid' => 'ane', 'estado' => 'cerrado' ), array( 'uid' => 'p1' ) );
afirmar( 'rechazar', accion( null, $apunte, 'ane', $tester, $cerrado ), 'proyecto cerrado: tester ya no apunta' );
afirmar( 'insertar', accion( null, $apunte, 'coord', $coordinacion, $cerrado ), 'coordinación apunta aunque esté cerrado' );
$mudado = entidad( 'apunte', array( 'concepto' => 'Cencerro' ), array( 'proyecto_uid' => 'p2', 'actualizado_ms' => 200 ) );
afirmar( 'rechazar', accion( $apunte, $mudado, 'ane', $tester, $proyecto_ane ), 'tester no mueve un apunte a otro proyecto' );
afirmar( 'actualizar', accion( $apunte, entidad( 'apunte', array( 'concepto' => 'Cencerro grande' ), array( 'proyecto_uid' => 'p1', 'actualizado_ms' => 200 ) ), 'ane', $tester, $proyecto_ane ), 'tester corrige un apunte suyo' );
foreach ( array( 'partida_presupuesto', 'movimiento_fianza', 'incidencia_cumplimiento', 'acompanamiento' ) as $solo_coordinacion ) {
	afirmar( 'rechazar', accion( null, entidad( $solo_coordinacion, array(), array( 'proyecto_uid' => 'p1' ) ), 'ane', $tester, $proyecto_ane ), "tester no crea {$solo_coordinacion}" );
	afirmar( 'insertar', accion( null, entidad( $solo_coordinacion, array(), array( 'proyecto_uid' => 'p1' ) ), 'coord', $coordinacion, $proyecto_ane ), "coordinación crea {$solo_coordinacion}" );
}

// --- peticiones ---
$peticion = entidad( 'peticion', array( 'titulo' => 'Falta pienso', 'estado' => 'pendiente' ) );
afirmar( 'insertar', accion( null, $peticion, 'ane', $tester ), 'tester envía una petición' );
$peticion_guardada = array_merge( $peticion, array( 'autor_uid' => 'ane' ) );
$aceptada = entidad( 'peticion', array( 'titulo' => 'Falta pienso', 'estado' => 'aceptada' ), array( 'actualizado_ms' => 200 ) );
afirmar( 'rechazar', accion( $peticion_guardada, $aceptada, 'ane', $tester ), 'tester no acepta su propia petición' );
afirmar( 'actualizar', accion( $peticion_guardada, $aceptada, 'coord', $coordinacion ), 'coordinación acepta una petición' );
afirmar( 'actualizar', accion( $peticion_guardada, entidad( 'peticion', array( 'titulo' => 'Falta pienso en el almacén', 'estado' => 'pendiente' ), array( 'actualizado_ms' => 200 ) ), 'ane', $tester ), 'la autora corrige su petición pendiente' );
afirmar( 'rechazar', accion( $peticion_guardada, entidad( 'peticion', array( 'titulo' => 'x', 'estado' => 'pendiente' ), array( 'actualizado_ms' => 200 ) ), 'jon', $tester ), 'otra persona no toca una petición ajena' );

// --- avisos de campo ---
$aviso = entidad( 'aviso', array( 'titulo' => 'Oveja coja', 'gravedad' => 'alarma' ) );
afirmar( 'insertar', accion( null, $aviso, 'ane', $tester ), 'tester crea un aviso' );
$aviso_guardado = array_merge( $aviso, array( 'autor_uid' => 'ane' ) );
$resuelto       = entidad( 'aviso', array( 'titulo' => 'Oveja coja', 'estado' => 'resuelto' ), array( 'actualizado_ms' => 200 ) );
afirmar( 'actualizar', accion( $aviso_guardado, $resuelto, 'ane', $tester ), 'la autora resuelve su aviso' );
afirmar( 'rechazar', accion( $aviso_guardado, $resuelto, 'jon', $tester ), 'otra persona tester no resuelve un aviso ajeno' );
afirmar( 'actualizar', accion( $aviso_guardado, $resuelto, 'coord', $coordinacion ), 'coordinación resuelve cualquier aviso' );

// --- autoría: la fija el servidor ---
$r = szs_resolver_entidad_entrante( null, array_merge( $aviso, array( 'autor_uid' => 'suplantada' ) ), 'ane', $tester, null );
afirmar( 'ane', $r['autor_uid'], 'al crear, la autoría es de quien sincroniza' );
$r = szs_resolver_entidad_entrante( $aviso_guardado, $resuelto, 'coord', $coordinacion, null );
afirmar( 'ane', $r['autor_uid'], 'al editar, se conserva la autoría original' );

// --- visibilidad ---
afirmar( true, szs_entidad_visible( $finca, 'ane', $tester, array() ), 'todas ven las fincas' );
afirmar( true, szs_entidad_visible( $aviso_guardado, 'jon', $tester, array() ), 'todas ven los avisos' );
afirmar( true, szs_entidad_visible( $proyecto_ane, 'ane', $tester, array() ), 'la tester ve su proyecto' );
afirmar( false, szs_entidad_visible( $proyecto_ane, 'jon', $tester, array() ), 'otra tester no ve un proyecto ajeno' );
afirmar( true, szs_entidad_visible( $proyecto_ane, 'coord', $coordinacion, array() ), 'coordinación ve todos los proyectos' );
afirmar( true, szs_entidad_visible( $apunte, 'ane', $tester, array( 'p1' ) ), 'la tester ve el seguimiento de su proyecto' );
afirmar( false, szs_entidad_visible( $apunte, 'jon', $tester, array() ), 'otra tester no ve el seguimiento ajeno' );
afirmar( true, szs_entidad_visible( $peticion_guardada, 'ane', $tester, array() ), 'la autora ve su petición' );
afirmar( false, szs_entidad_visible( $peticion_guardada, 'jon', $tester, array() ), 'otra tester no ve peticiones ajenas' );
afirmar( true, szs_entidad_visible( $peticion_guardada, 'coord', $coordinacion, array() ), 'coordinación ve todas las peticiones' );

// --- etiqueta para la actividad ---
afirmar( 'Corral', szs_etiqueta_entidad( $punto ), 'la etiqueta de un punto es su nombre' );
afirmar( 'Cencerro', szs_etiqueta_entidad( $apunte ), 'la etiqueta de un apunte es su concepto' );
afirmar( 'Falta pienso', szs_etiqueta_entidad( $peticion ), 'la etiqueta de una petición es su título' );

// --- acción para el registro de actividad ---
afirmar( 'crear', szs_accion_entidad( null, $punto ), 'alta' );
afirmar( 'mover', szs_accion_entidad( $punto, entidad( 'punto', array_merge( $punto['datos'], array( 'latitud' => 42.5 ) ) ) ), 'solo cambia la posición: mover' );
afirmar( 'editar', szs_accion_entidad( $punto, $retipado ), 'cambia otra cosa: editar' );
afirmar( 'borrar', szs_accion_entidad( $punto, entidad( 'punto', array(), array( 'borrado' => true ) ) ), 'lápida: borrar' );
$tarea = szs_normalizar_tarea( array( 'uid' => 't', 'estado' => 'pendiente', 'responsable_uid' => '' ) );
afirmar( array( 'crear', '' ), szs_accion_tarea( null, $tarea ), 'tarea nueva' );
afirmar( array( 'estado', 'hecha' ), szs_accion_tarea( $tarea, array_merge( $tarea, array( 'estado' => 'hecha' ) ) ), 'cambio de estado' );
afirmar( array( 'asignar', 'Ane' ), szs_accion_tarea( $tarea, array_merge( $tarea, array( 'responsable_uid' => 'ane', 'responsable' => 'Ane' ) ) ), 'asignación' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests de entidades pasaron.\n";
