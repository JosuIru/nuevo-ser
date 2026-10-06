<?php
/**
 * Tests de la lógica pura del panel de coordinación: filtros del listado de
 * tareas, exportación CSV, balance del convenio y resumen del correo
 * diario. Sin WordPress.
 *
 * Ejecutar: php tests/test_panel.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
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

$hoy_ms  = 1_791_244_800_000; // 2026-10-06 00:00 UTC
$dia_ms  = 86_400_000;
$tareas  = array(
	szs_normalizar_tarea( array( 'uid' => 'a', 'titulo' => 'Vencida', 'estado' => 'pendiente', 'fecha_objetivo_ms' => $hoy_ms - $dia_ms, 'finca_nombre' => 'Zunbeltz', 'responsable_uid' => 'ane' ) ),
	szs_normalizar_tarea( array( 'uid' => 'b', 'titulo' => 'Hecha', 'estado' => 'hecha', 'fecha_objetivo_ms' => $hoy_ms - $dia_ms, 'finca_nombre' => 'Zunbeltz' ) ),
	szs_normalizar_tarea( array( 'uid' => 'c', 'titulo' => 'Futura', 'estado' => 'en_curso', 'fecha_objetivo_ms' => $hoy_ms + $dia_ms, 'finca_nombre' => 'La Planilla' ) ),
	szs_normalizar_tarea( array( 'uid' => 'd', 'titulo' => 'Sin fecha', 'estado' => 'pendiente', 'finca_nombre' => 'La Planilla' ) ),
);
$uids = static fn( array $lista ): array => array_column( $lista, 'uid' );

// --- filtros del listado ---
afirmar( array( 'a' ), $uids( szs_filtrar_tareas_panel( $tareas, array( 'vencidas' => true ), $hoy_ms ) ), 'vencidas: con fecha pasada y sin hacer' );
afirmar( array( 'c', 'd' ), $uids( szs_filtrar_tareas_panel( $tareas, array( 'finca' => 'La Planilla' ), $hoy_ms ) ), 'filtro por finca' );
afirmar( array( 'a', 'c', 'd' ), $uids( szs_filtrar_tareas_panel( $tareas, array( 'estado' => 'abiertas' ), $hoy_ms ) ), '«abiertas» = todo lo que no está hecho' );
afirmar( array( 'd' ), $uids( szs_filtrar_tareas_panel( $tareas, array( 'responsable' => 'sin_asignar', 'finca' => 'La Planilla', 'estado' => 'pendiente' ), $hoy_ms ) ), 'filtros combinados y sin asignar' );
afirmar( array( 'a' ), $uids( szs_filtrar_tareas_panel( $tareas, array( 'responsable' => 'ane' ), $hoy_ms ) ), 'por responsable' );
afirmar( true, szs_tarea_vencida( $tareas[0], $hoy_ms ), 'una tarea de ayer sin hacer está vencida' );
afirmar( false, szs_tarea_vencida( $tareas[3], $hoy_ms ), 'sin fecha no vence' );

// --- orden: vencidas primero, luego por fecha, sin fecha al final ---
$ordenadas = szs_ordenar_tareas_panel( array( $tareas[3], $tareas[2], $tareas[0] ), $hoy_ms );
afirmar( array( 'a', 'c', 'd' ), $uids( $ordenadas ), 'orden del panel' );

// --- CSV ---
$csv = szs_tareas_a_csv( array( $tareas[0] ) );
afirmar( true, str_starts_with( $csv, "\u{FEFF}" ), 'el CSV lleva BOM para Excel' );
afirmar( true, str_contains( $csv, 'Vencida;Zunbeltz' ), 'campos separados por punto y coma' );
afirmar( true, str_contains( szs_tareas_a_csv( array( szs_normalizar_tarea( array( 'uid' => 'x', 'titulo' => 'Con ; y "comillas"' ) ) ) ), '"Con ; y ""comillas"""' ), 'los campos con ; o comillas se escapan' );

// --- tarea periódica: siguiente instancia al cerrarla ---
$periodica = szs_normalizar_tarea( array( 'uid' => 'p', 'titulo' => 'Limpiar abrevadero', 'estado' => 'pendiente', 'recurrencia_dias' => 7, 'fecha_objetivo_ms' => $hoy_ms - $dia_ms, 'responsable_uid' => 'ane' ) );
$siguiente = szs_siguiente_tarea_periodica( $periodica, $hoy_ms, 'nuevo' );
afirmar( 'nuevo', $siguiente['uid'], 'la siguiente instancia tiene uid propio' );
afirmar( 'pendiente', $siguiente['estado'], '… y empieza pendiente' );
afirmar( $hoy_ms + 7 * $dia_ms, $siguiente['fecha_objetivo_ms'], '… a 7 días de hoy (la fecha original ya pasó)' );
afirmar( 'ane', $siguiente['responsable_uid'], '… con la misma responsable' );
afirmar( null, szs_siguiente_tarea_periodica( $tareas[0], $hoy_ms, 'z' ), 'una tarea puntual no genera siguiente' );

// --- balance del convenio (mismo cálculo que la app) ---
$entidades = array(
	array( 'tipo' => 'venta', 'datos' => array( 'ingreso_centimos' => 300000 ) ),
	array( 'tipo' => 'apunte', 'datos' => array( 'tipo' => 'gasto', 'importe_centimos' => 100000, 'asumido_por' => 'tester', 'es_amortizacion' => 0 ) ),
	array( 'tipo' => 'apunte', 'datos' => array( 'tipo' => 'gasto', 'importe_centimos' => 40000, 'asumido_por' => 'zunbeltz', 'es_amortizacion' => 1 ) ),
	array( 'tipo' => 'apunte', 'datos' => array( 'tipo' => 'ingreso', 'importe_centimos' => 20000 ) ),
);
$balance = szs_balance_convenio( array( 'porcentaje_beneficio_zunbeltz' => 25, 'porcentaje_perdida_zunbeltz' => 50 ), $entidades );
afirmar( 220000, $balance['balance_test'], 'balance del test sin amortizaciones' );
afirmar( 180000, $balance['balance_proyecto'], 'balance del proyecto con amortizaciones' );
afirmar( 55000, $balance['parte_zunbeltz'], 'reparto 25 % del beneficio' );
afirmar( 40000, $balance['asumido_zunbeltz'], 'gasto que asume Zunbeltz' );
$perdida = szs_balance_convenio( array(), array( array( 'tipo' => 'apunte', 'datos' => array( 'tipo' => 'gasto', 'importe_centimos' => 20000 ) ) ) );
afirmar( -10000, $perdida['parte_zunbeltz'], 'pérdida: 50 % por defecto' );

// --- resumen del correo diario ---
$resumen = szs_resumen_correo_diario( $tareas, array( 'Falta pienso' ), array( 'Oveja coja' ), $hoy_ms );
afirmar( true, str_contains( $resumen['cuerpo'], 'Vencida' ), 'el correo lista las tareas vencidas' );
afirmar( true, str_contains( $resumen['cuerpo'], 'Falta pienso' ), '… las peticiones pendientes' );
afirmar( true, str_contains( $resumen['cuerpo'], 'Oveja coja' ), '… y las alarmas abiertas' );
afirmar( true, str_contains( $resumen['asunto'], '1 tarea vencida' ), 'el asunto resume' );
afirmar( null, szs_resumen_correo_diario( array( $tareas[2] ), array(), array(), $hoy_ms ), 'sin nada pendiente no se manda correo' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests del panel pasaron.\n";
