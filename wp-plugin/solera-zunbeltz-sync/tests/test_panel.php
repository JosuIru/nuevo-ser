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
afirmar( "\"'=HYPERLINK(\"\"http://x\"\")\"", szs_campo_csv( '=HYPERLINK("http://x")' ), 'una fórmula no se ejecuta al abrir en Excel' );
afirmar( "'@SUMA(A1)", szs_campo_csv( '@SUMA(A1)' ), 'tampoco con @' );
afirmar( '-12,50', szs_campo_csv( '-12,50' ), 'un número negativo sigue siendo un número' );
afirmar( 'ñandú', szs_recortar( 'ñandú', 64 ), 'recortar no toca lo corto' );
afirmar( true, mb_check_encoding( szs_recortar( str_repeat( 'á', 300 ), 501 ), 'UTF-8' ), 'recortar no parte una letra con tilde' );

// --- tarea periódica: siguiente instancia al cerrarla ---
$periodica = szs_normalizar_tarea( array( 'uid' => 'p', 'titulo' => 'Limpiar abrevadero', 'estado' => 'pendiente', 'recurrencia_dias' => 7, 'fecha_objetivo_ms' => $hoy_ms - $dia_ms, 'responsable_uid' => 'ane' ) );
$siguiente = szs_siguiente_tarea_periodica( $periodica, $hoy_ms, 'nuevo' );
afirmar( 'nuevo', $siguiente['uid'], 'la siguiente instancia tiene uid propio' );
afirmar( 'pendiente', $siguiente['estado'], '… y empieza pendiente' );
afirmar( $hoy_ms + 7 * $dia_ms, $siguiente['fecha_objetivo_ms'], '… a 7 días de hoy (la fecha original ya pasó)' );
afirmar( 'ane', $siguiente['responsable_uid'], '… con la misma responsable' );
afirmar( null, szs_siguiente_tarea_periodica( $tareas[0], $hoy_ms, 'z' ), 'una tarea puntual no genera siguiente' );
afirmar( 'sig-a9993e364706816aba3e25717850', szs_uid_siguiente_periodica( 'abc' ), 'el uid de la siguiente coincide con el de la app' );
$madrid      = new DateTimeZone( 'Europe/Madrid' );
$dia_22_oct  = ( new DateTimeImmutable( '2026-10-22 00:00', $madrid ) )->getTimestamp() * 1000;
$antes_1_oct = ( new DateTimeImmutable( '2026-10-01 00:00', $madrid ) )->getTimestamp() * 1000;
$con_cambio  = szs_siguiente_tarea_periodica( szs_normalizar_tarea( array( 'uid' => 'h', 'recurrencia_dias' => 7, 'fecha_objetivo_ms' => $dia_22_oct ) ), $antes_1_oct, 'x', $madrid );
afirmar( '2026-10-29 00:00', ( new DateTimeImmutable( '@' . intdiv( $con_cambio['fecha_objetivo_ms'], 1000 ) ) )->setTimezone( $madrid )->format( 'Y-m-d H:i' ), 'con el cambio de hora del 25-oct la siguiente cae el 29 a medianoche, no el 28 a las 23:00' );

// --- correo de las 8:00 con el cambio de hora ---
$madrid = new DateTimeZone( 'Europe/Madrid' );
$a_las  = static fn( int $segundos ): string => ( new DateTimeImmutable( '@' . $segundos ) )->setTimezone( $madrid )->format( 'Y-m-d H:i' );
afirmar( '2026-10-26 08:00', $a_las( szs_proximas_8_de_la_manana( ( new DateTimeImmutable( '2026-10-25 09:00', $madrid ) )->getTimestamp(), $madrid ) ), 'tras el cambio de hora sigue llegando a las 8:00' );
afirmar( '2026-10-25 08:00', $a_las( szs_proximas_8_de_la_manana( ( new DateTimeImmutable( '2026-10-25 07:59', $madrid ) )->getTimestamp(), $madrid ) ), 'antes de las 8, hoy mismo' );

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

// --- inventario de amortizaciones (mismos casos que test/amortizacion_test.dart) ---
$ms = static fn( string $fecha ): int => ( new DateTimeImmutable( $fecha, new DateTimeZone( 'Europe/Madrid' ) ) )->getTimestamp() * 1000;
afirmar( 4.0, szs_meses_entre( $ms( '2026-06-01' ), $ms( '2026-10-01' ) ), 'del 1-jun al 1-oct, 4 meses' );
afirmar( 0.5, szs_meses_entre( $ms( '2026-06-01' ), $ms( '2026-06-16' ) ), '15 días, medio mes' );
afirmar( 1.03, szs_meses_entre( $ms( '2026-01-31' ), $ms( '2026-03-01' ) ), 'del 31-ene: un mes llega al 28-feb' );
afirmar( 0.0, szs_meses_entre( $ms( '2026-06-01' ), $ms( '2026-05-01' ) ), 'al revés, 0' );
$bebedero = array( 'precio_unidad_centimos' => 2094, 'unidades' => 10, 'iva_porcentaje' => 21, 'vida_util_meses' => 72 );
$pollos   = array( 'fecha_inicio_ms' => $ms( '2026-06-01' ), 'fecha_fin_ms' => $ms( '2026-10-01' ) );
afirmar( 1408, szs_cuota_uso_bien( $bebedero, array(), $pollos, $hoy_ms ), 'cuota: mensual × meses del test' );
afirmar( 528, szs_cuota_uso_bien( $bebedero, array( 'imputacion_porcentaje' => 50, 'duracion_meses' => 3 ), $pollos, $hoy_ms ), 'con meses propios y la mitad' );
afirmar( 0, szs_cuota_uso_bien( array_merge( $bebedero, array( 'vida_util_meses' => 0 ) ), array(), $pollos, $hoy_ms ), 'sin vida útil no se amortiza' );
$con_inventario = szs_balance_convenio(
	$pollos,
	array(
		array( 'tipo' => 'uso_bien', 'datos' => array( 'bien_uid' => 'bebedero' ) ),
		array( 'tipo' => 'uso_bien', 'datos' => array( 'bien_uid' => 'borrado' ) ),
	),
	array( 'bebedero' => $bebedero ),
	$hoy_ms
);
afirmar( array( 1408, 0, -1408, 1408 ), array( $con_inventario['amortizaciones'], $con_inventario['balance_test'], $con_inventario['balance_proyecto'], $con_inventario['asumido_zunbeltz'] ), 'las cuotas del inventario son amortizaciones que asume Zunbeltz' );

// --- resumen del correo diario ---
$resumen = szs_resumen_correo_diario( $tareas, array( 'Falta pienso' ), array( 'Oveja coja' ), $hoy_ms );
afirmar( true, str_contains( $resumen['cuerpo'], 'Vencida' ), 'el correo lista las tareas vencidas' );
afirmar( true, str_contains( $resumen['cuerpo'], 'Falta pienso' ), '… las peticiones pendientes' );
afirmar( true, str_contains( $resumen['cuerpo'], 'Oveja coja' ), '… y las alarmas abiertas' );
afirmar( true, str_contains( $resumen['asunto'], '1 tarea vencida' ), 'el asunto resume' );
afirmar( null, szs_resumen_correo_diario( array( $tareas[2] ), array(), array(), $hoy_ms ), 'sin nada pendiente no se manda correo' );

// --- alimentación por días ---
$dia = static fn( int $d ): int => ( $hoy_ms + $d * $dia_ms ) + 9 * 3_600_000;
$registros = array(
	array( 'tipo' => 'registro_actividad', 'datos' => array( 'tipo' => 'alimentacion', 'cantidad' => 120, 'fecha_ms' => $dia( 0 ), 'lote' => 'Rebaño A' ) ),
	array( 'tipo' => 'registro_actividad', 'datos' => array( 'tipo' => 'alimentacion', 'cantidad' => 30.5, 'fecha_ms' => $dia( 0 ) + 3_600_000, 'lote' => 'Rebaño A' ) ),
	array( 'tipo' => 'registro_actividad', 'datos' => array( 'tipo' => 'alimentacion', 'cantidad' => 80, 'fecha_ms' => $dia( -1 ), 'lote' => 'Rebaño B' ) ),
	array( 'tipo' => 'registro_actividad', 'datos' => array( 'tipo' => 'paricion', 'cantidad' => 3, 'fecha_ms' => $dia( 0 ) ) ),
);
$filas = szs_alimentacion_por_dias( $registros, 'UTC' );
afirmar( 2, count( $filas ), 'una fila por día y lote; las pariciones no cuentan' );
afirmar( array( '2026-10-05', 'Rebaño B', 80.0 ), array( $filas[0]['dia'], $filas[0]['lote'], $filas[0]['kg'] ), 'ordenado por día' );
afirmar( 150.5, $filas[1]['kg'], 'los kg del mismo día y lote se suman' );
$csv = szs_alimentacion_a_csv( $filas );
afirmar( true, str_contains( $csv, "06/10/2026;Rebaño A;150,5" ), 'fecha y decimales a la española' );
afirmar( true, str_contains( $csv, 'Total;;230,5' ), 'fila de total' );

// --- portada (Inicio): recuentos y lo que pide atención ---
if ( ! function_exists( 'current_user_can' ) ) {
	function current_user_can( $capacidad ) {
		return false;
	}
}
$entidad = static fn( string $tipo, string $uid, array $datos ): array => szs_normalizar_entidad( array( 'tipo' => $tipo, 'uid' => $uid, 'datos' => $datos ) );
$tareas_inicio = array_merge(
	$tareas,
	array(
		szs_normalizar_tarea( array( 'uid' => 'e', 'titulo' => 'Hoy', 'estado' => 'pendiente', 'fecha_objetivo_ms' => $hoy_ms + 3_600_000, 'responsable_uid' => 'ane' ) ),
		szs_normalizar_tarea( array( 'uid' => 'f', 'titulo' => 'Bloqueada', 'estado' => 'bloqueada', 'fecha_objetivo_ms' => $hoy_ms + 20 * $dia_ms, 'responsable_uid' => 'ane', 'recurrencia_dias' => 7 ) ),
		szs_normalizar_tarea( array( 'uid' => 'g', 'titulo' => 'Hecha hace mucho', 'estado' => 'hecha', 'actualizado_ms' => $hoy_ms - 40 * $dia_ms ) ),
	)
);
$tareas_inicio[1]['actualizado_ms'] = $hoy_ms - $dia_ms; // la hecha de ayer cuenta en los 30 días.
$resumen = szs_resumen_inicio(
	$tareas_inicio,
	array( $entidad( 'peticion', 'p1', array( 'estado' => 'pendiente', 'urgente' => true ) ), $entidad( 'peticion', 'p2', array( 'estado' => 'pendiente' ) ), $entidad( 'peticion', 'p3', array( 'estado' => 'aceptada' ) ) ),
	array( $entidad( 'aviso', 'v1', array( 'estado' => 'abierto', 'gravedad' => 'alarma' ) ), $entidad( 'aviso', 'v2', array( 'estado' => 'abierto', 'gravedad' => 'aviso' ) ), $entidad( 'aviso', 'v3', array( 'estado' => 'resuelto', 'gravedad' => 'alarma' ) ) ),
	array( $entidad( 'proyecto', 'y1', array( 'estado' => 'abierto', 'persona_uid' => 'ane' ) ), $entidad( 'proyecto', 'y2', array( 'estado' => 'abierto', 'persona_uid' => '' ) ), $entidad( 'proyecto', 'y3', array( 'estado' => 'cerrado' ) ) ),
	array(
		array( 'uid' => 'ane', 'nombre' => 'Ane', 'rol' => 'tester', 'activo' => 1 ),
		array( 'uid' => 'pablo', 'nombre' => 'Pablo', 'rol' => 'coordinador', 'activo' => 1 ),
		array( 'uid' => 'baja', 'nombre' => 'Baja', 'rol' => 'tester', 'activo' => 0 ),
	),
	array( $entidad( 'lote_ganado', 'l1', array( 'cabezas_sin_identificar' => 12 ) ), $entidad( 'lote_ganado', 'l2', array() ) ),
	array( $entidad( 'animal', 'a1', array( 'fecha_baja_ms' => null ) ), $entidad( 'animal', 'a2', array( 'fecha_baja_ms' => $hoy_ms ) ) ),
	array(
		array( 'persona_uid' => 'ane', 'momento_ms' => $hoy_ms - 2 * $dia_ms, 'origen' => 'app' ),
		array( 'persona_uid' => 'ane', 'momento_ms' => $hoy_ms - 10 * $dia_ms, 'origen' => 'app' ),
		array( 'persona_uid' => 'pablo', 'momento_ms' => $hoy_ms + 3_600_000, 'origen' => 'panel' ),
	),
	$hoy_ms,
	$hoy_ms + 2 * 3_600_000
);
afirmar( array( 'abiertas' => 5, 'vencidas' => 1, 'hoy' => 1, 'proximas' => 1, 'sin_asignar' => 2, 'bloqueadas' => 1, 'hechas_30_dias' => 1, 'periodicas' => 1 ), $resumen['tareas'], 'inicio: recuento de tareas' );
afirmar( array( 'pendientes' => 2, 'urgentes' => 1 ), $resumen['peticiones'], 'inicio: peticiones' );
afirmar( array( 'abiertos' => 2, 'alarmas' => 1 ), $resumen['avisos'], 'inicio: avisos (las resueltas no cuentan)' );
afirmar( array( 'abiertos' => 2, 'cerrados' => 1, 'sin_tester' => 1 ), $resumen['proyectos'], 'inicio: proyectos' );
afirmar( array( 'activas' => 2, 'coordinacion' => 1, 'testers' => 1, 'sin_token_usado' => 0 ), $resumen['personas'], 'inicio: personas activas por rol' );
afirmar( array( 'lotes' => 2, 'animales_en_alta' => 1, 'cabezas_sin_identificar' => 12 ), $resumen['ganado'], 'inicio: ganado' );
afirmar( array( 'ultimos_7_dias' => 2, 'desde_app' => 1, 'desde_oficina' => 1 ), $resumen['actividad'], 'inicio: actividad de la semana' );
afirmar( $hoy_ms - 2 * $dia_ms, $resumen['ultima_actividad_por_persona']['ane'], 'inicio: la última huella de cada persona es la más reciente' );
$con_historia = szs_resumen_inicio( array(), array(), array(), array(), array( array( 'uid' => 'vieja', 'nombre' => 'Vieja', 'rol' => 'tester', 'activo' => 1 ) ), array(), array(), array(), $hoy_ms, $hoy_ms, array( 'vieja' => $hoy_ms - 400 * $dia_ms ) );
afirmar( 0, $con_historia['personas']['sin_token_usado'], 'inicio: una huella antigua (fuera de los 7 días) cuenta como actividad de la persona' );
afirmar( $hoy_ms - 400 * $dia_ms, $con_historia['ultima_actividad_por_persona']['vieja'], 'inicio: … y se conserva su fecha' );
$pendientes = szs_pendientes_inicio( $resumen );
afirmar( array( 'alarma', 'alarma', 'aviso', 'aviso', 'aviso', 'info', 'info', 'info' ), array_column( $pendientes, 'nivel' ), 'inicio: lo que pide atención va de más a menos urgente' );
afirmar( '1 alarma(s) abierta(s)', $pendientes[0]['texto'], 'inicio: la alarma va primero' );
afirmar( array( 'vencidas' => '1' ), $pendientes[2]['argumentos'], 'inicio: las vencidas enlazan al tablero filtrado' );
$vacio = szs_resumen_inicio( array(), array(), array(), array(), array(), array(), array(), array(), $hoy_ms, $hoy_ms );
afirmar( array(), szs_pendientes_inicio( $vacio ), 'inicio: sin datos no hay nada que pida atención' );
afirmar( 'hace 1 min', szs_hace_cuanto( $hoy_ms, $hoy_ms + 10_000 ), 'hace cuánto: menos de un minuto redondea a 1' );
afirmar( 'hace 3 h', szs_hace_cuanto( $hoy_ms, $hoy_ms + 3 * 3_600_000 ), 'hace cuánto: horas' );
afirmar( 'ayer', szs_hace_cuanto( $hoy_ms, $hoy_ms + $dia_ms ), 'hace cuánto: un día es «ayer»' );
afirmar( 'hace 12 días', szs_hace_cuanto( $hoy_ms, $hoy_ms + 12 * $dia_ms ), 'hace cuánto: días' );

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests del panel pasaron.\n";
