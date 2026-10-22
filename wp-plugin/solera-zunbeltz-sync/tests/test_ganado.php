<?php
/**
 * Tests de la lógica pura del ganado en el panel: UGM, ubicación, cabezas,
 * supresión (con el plazo doble en ecológico) y límite de tratamientos.
 * Mismos casos que la app (test/carga_ganadera_test.dart,
 * test/ganado_ecologico_test.dart). Sin WordPress.
 *
 * Ejecutar: php tests/test_ganado.php
 */

define( 'ABSPATH', __DIR__ );

function register_activation_hook( $file, $callback ) {}
function register_deactivation_hook( $file, $callback ) {}
function add_action( $hook, $callback ) {}
function add_filter( $hook, $callback ) {}

require_once __DIR__ . '/../solera-zunbeltz-sync.php';

$fallos = 0;
function afirmar( $esperado, $real, string $titulo ): void {
	global $fallos;
	if ( $esperado !== $real ) {
		$fallos++;
		fprintf( STDERR, "FALLO: %s\n  esperado: %s\n  real:     %s\n", $titulo, var_export( $esperado, true ), var_export( $real, true ) );
	}
}

$zona  = 'Europe/Madrid';
$ms    = static fn( string $fecha ): int => ( new DateTimeImmutable( $fecha, new DateTimeZone( 'Europe/Madrid' ) ) )->getTimestamp() * 1000;
$ahora = $ms( '2026-10-22 10:00' );
$ent   = static fn( string $tipo, array $datos, int $actualizado = 1 ): array => array(
	'tipo'           => $tipo,
	'uid'            => $tipo . '-' . md5( serialize( $datos ) ),
	'datos'          => $datos,
	'actualizado_ms' => $actualizado,
);

// --- UGM ---
afirmar( 6, szs_meses_cumplidos( $ms( '2026-04-22' ), $ahora, $zona ), 'seis meses justos' );
afirmar( 5, szs_meses_cumplidos( $ms( '2026-04-23' ), $ahora, $zona ), 'un día antes de los seis' );
afirmar( 1.0, szs_ugm_por_cabeza( 'vacuno', '', null, $ahora, $zona ), 'vaca sin fecha: adulta' );
afirmar( 0.2, szs_ugm_por_cabeza( 'vacuno', '', $ms( '2026-06-01' ), $ahora, $zona ), 'ternero' );
afirmar( 0.6, szs_ugm_por_cabeza( 'vacuno', '', $ms( '2025-06-01' ), $ahora, $zona ), 'recría' );
afirmar( 0.05, szs_ugm_por_cabeza( 'ovino', '', $ms( '2026-08-01' ), $ahora, $zona ), 'cordero' );
afirmar( 0.10, szs_ugm_por_cabeza( 'caprino', '', $ms( '2026-03-01' ), $ahora, $zona ), 'chivo de recría' );
afirmar( 0.15, szs_ugm_por_cabeza( 'ovino', 'hembra', null, $ahora, $zona ), 'oveja' );
afirmar( 0.12, szs_ugm_por_cabeza( 'ovino', 'macho', null, $ahora, $zona ), 'carnero' );
afirmar( 0.30, szs_ugm_por_cabeza( 'porcino', 'macho', null, $ahora, $zona ), 'verraco' );
afirmar( 0.015, szs_ugm_por_cabeza( 'aves', '', null, $ahora, $zona ), 'aves' );
afirmar( 0.0, szs_ugm_por_cabeza( 'varias', '', null, $ahora, $zona ), 'sin coeficiente' );

$lote     = $ent( 'lote_ganado', array( 'especie' => 'ovino', 'cabezas_sin_identificar' => 10 ) );
$animales = array(
	$ent( 'animal', array( 'especie' => 'ovino', 'estado' => 'activo' ) ),
	$ent( 'animal', array( 'especie' => 'ovino', 'estado' => 'vendido' ) ),
);
afirmar( 11, szs_cabezas_de_lote( $lote, $animales ), 'cabezas: activas más sin crotal' );
afirmar( '1.65', number_format( szs_ugm_de_lote( $lote, $animales, $ahora, $zona ), 2 ), 'UGM del rebaño (como en la app)' );

// --- ubicación ---
$movimientos = array(
	$ent( 'movimiento_ganado', array( 'tipo' => 'entrada', 'fecha_ms' => $ms( '2026-09-01' ), 'zona_destino_uid' => 'pasillo' ) ),
	$ent( 'movimiento_ganado', array( 'tipo' => 'traslado', 'fecha_ms' => $ms( '2026-10-01' ), 'zona_destino_uid' => 'avellanos' ), 5 ),
	$ent( 'movimiento_ganado', array( 'tipo' => 'traslado', 'fecha_ms' => $ms( '2026-10-01' ), 'zona_destino_uid' => 'cañada' ), 9 ),
);
afirmar( array( 'zona_uid' => 'cañada' ), szs_ubicacion_lote( $movimientos ), 'a igual fecha, el último apuntado' );
$movimientos[] = $ent( 'movimiento_ganado', array( 'tipo' => 'salida', 'fecha_ms' => $ms( '2026-10-10' ), 'destino_externo' => 'Urbasa' ) );
afirmar( array( 'fuera' => 'Urbasa' ), szs_ubicacion_lote( $movimientos ), 'tras una salida, fuera' );
afirmar( null, szs_ubicacion_lote( array() ), 'sin movimientos, sin ubicar' );

// --- ecológico ---
afirmar( 56, szs_plazo_efectivo_dias( 28, true, 'alopatico' ), 'doble' );
afirmar( 2, szs_plazo_efectivo_dias( 0, true, 'alopatico' ), 'mínimo 48 horas' );
afirmar( 2, szs_plazo_efectivo_dias( 0, true, '' ), 'sin indicar, lo prudente' );
afirmar( 10, szs_plazo_efectivo_dias( 10, true, 'vacuna' ), 'la vacuna no se dobla' );
afirmar( 28, szs_plazo_efectivo_dias( 28, false, 'alopatico' ), 'fuera de ecológico, el legal' );

$tratamiento = $ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'alopatico', 'fecha_ms' => $ms( '2026-10-10 09:00' ), 'plazo_supresion_carne_dias' => 7 ) );
afirmar( array( 'carne' => null, 'leche' => null ), szs_supresion_vigente( array( $tratamiento ), $ahora, $zona, false ), '7 días: libre desde el 17' );
afirmar( array( 'carne' => '2026-10-24', 'leche' => null ), szs_supresion_vigente( array( $tratamiento ), $ahora, $zona, true ), 'en ecológico, 14 días: libre el 24; la leche (0 → 2 días) ya pasó' );

$eventos = array(
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'alopatico', 'fecha_ms' => $ms( '2025-10-21 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'alopatico', 'fecha_ms' => $ms( '2025-10-22 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'alopatico', 'fecha_ms' => $ms( '2026-03-01 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'vacuna', 'fecha_ms' => $ms( '2026-05-01 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => 'antiparasitario', 'fecha_ms' => $ms( '2026-06-01 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'saneamiento', 'clase_medicamento' => 'alopatico', 'fecha_ms' => $ms( '2026-07-01 09:00' ) ) ),
	$ent( 'evento_ganado', array( 'tipo' => 'tratamiento', 'clase_medicamento' => '', 'fecha_ms' => $ms( '2026-09-01 09:00' ) ) ),
);
afirmar( array( 'tratamientos' => 3, 'limite' => 3, 'superado' => false, 'en_limite' => true ), szs_estado_tratamientos_ecologico( $eventos, $ahora, $zona, false ), 'tres en 12 meses: en el límite (como en la app)' );
afirmar( true, szs_estado_tratamientos_ecologico( $eventos, $ahora, $zona, true )['superado'], 'ciclo corto: más de uno lo supera' );

// --- CSV ---
$csv = szs_filas_a_csv( array( 'Crotal', 'Nombre' ), array( array( 'ES012345678901', '=MAL()' ) ) );
afirmar( true, str_starts_with( $csv, "\u{FEFF}Crotal;Nombre\r\n" ), 'CSV con BOM y cabecera' );
afirmar( true, str_contains( $csv, "'=MAL()" ), 'sin fórmulas' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallos\n", $fallos );
	exit( 1 );
}
echo "test_ganado: OK\n";
