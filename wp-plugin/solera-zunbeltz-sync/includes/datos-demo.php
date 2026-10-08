<?php
/**
 * Datos de demostración para desarrollo: rellena el espacio con personas,
 * puntos, zonas, tareas, proyectos con todo su seguimiento, peticiones,
 * avisos, contactos, rendimientos y actividad, para ver y probar todas las
 * pantallas del panel y de la app sin teclear nada. Y los retira de un
 * golpe.
 *
 * - Todo lo que se crea lleva un uid que empieza por `demo-`; así se
 *   encuentra para retirarlo aunque se pierda cualquier otra marca.
 * - Al retirar, las entidades quedan como **lápida** (no se borran de la
 *   tabla): así los móviles que ya se habían sincronizado también las
 *   quitan. Las tareas se borran (la app retira las que ya no recibe) y las
 *   personas, la actividad y sus entradas, también.
 * - Las fincas no se tocan si ya hay alguna. Si no hay ninguna se crean
 *   Zunbeltz y La Planilla con los mismos uid que siembra la app, y se
 *   conservan al retirar (son las del espacio, no datos de ejemplo).
 * - No manda correos ni avisos: escribe directamente, sin pasar por
 *   `szs_entidad_guardada`.
 *
 * Solo aparece fuera de producción (`wp_get_environment_type()`), salvo que
 * se fuerce con `define( 'SZS_DATOS_DEMO', true );` en wp-config.php
 * (o se oculte con `false`). También desde WP-CLI:
 * `wp solera-zunbeltz demo sembrar | vaciar | estado`.
 *
 * El plan (`szs_plan_datos_demo`) es una función pura, probada en
 * `tests/test_datos_demo.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PREFIJO_DEMO      = 'demo-';
const SZS_PAGINA_DATOS_DEMO = 'solera-zunbeltz-datos-demo';

/** Fincas que siembra la app (`uidsFincasSembradas` en `esquema_sincronizable.dart`). */
const SZS_FINCAS_DEL_ESPACIO = array(
	'finca-zunbeltz'    => array( 'nombre' => 'Zunbeltz', 'latitud' => 42.7872, 'longitud' => -1.9450, 'superficie_ha' => 231 ),
	'finca-la-planilla' => array( 'nombre' => 'La Planilla', 'latitud' => 42.8010, 'longitud' => -1.9720, 'superficie_ha' => 197 ),
);

add_action( 'admin_menu', 'szs_registrar_pagina_datos_demo', 20 );

function szs_herramientas_desarrollo_activas(): bool {
	if ( defined( 'SZS_DATOS_DEMO' ) ) {
		return (bool) SZS_DATOS_DEMO;
	}
	return 'production' !== wp_get_environment_type();
}

function szs_es_uid_demo( string $uid ): bool {
	return str_starts_with( $uid, SZS_PREFIJO_DEMO );
}

// ============================================================
// Plan (puro)
// ============================================================

/**
 * Todo lo que se va a crear, sin tocar la base de datos.
 *
 * @param int                  $ahora_ms Momento de referencia: las fechas se reparten alrededor.
 * @param string               $lote     Trozo aleatorio de los uid, para poder sembrar varias veces.
 * @param array<string, array> $fincas_existentes uid => datos de las fincas que ya hay (sin borrar).
 *
 * @return array{
 *   personas: array<int, array{uid: string, nombre: string, rol: string}>,
 *   entidades: array<int, array>,
 *   tareas: array<int, array>,
 *   actividad: array<int, array>
 * }
 */
function szs_plan_datos_demo( int $ahora_ms, string $lote, array $fincas_existentes ): array {
	$dia  = 86_400_000;
	$hace = static fn( int $dias ): int => $ahora_ms - $dias * $dia;
	$en   = static fn( int $dias ): int => $ahora_ms + $dias * $dia;
	$uid  = static fn( string $nombre ): string => SZS_PREFIJO_DEMO . $lote . '-' . $nombre;

	$entidades = array();
	$anadir    = static function ( string $tipo, string $uid_entidad, array $datos, string $autor_uid, string $proyecto_uid = '' ) use ( &$entidades, $ahora_ms ): void {
		$entidades[] = array(
			'tipo'           => $tipo,
			'uid'            => $uid_entidad,
			'actualizado_ms' => $ahora_ms,
			'borrado'        => false,
			'proyecto_uid'   => $proyecto_uid,
			'autor_uid'      => $autor_uid,
			'datos'          => $datos,
		);
	};

	// ─── Personas ───
	$coordinacion = $uid( 'coordinacion' );
	$tester_queso = $uid( 'tester-maite' );
	$tester_huerta = $uid( 'tester-inaki' );
	$personas     = array(
		array( 'uid' => $coordinacion, 'nombre' => 'Elena (demo)', 'rol' => SZS_ROL_COORDINADOR ),
		array( 'uid' => $tester_queso, 'nombre' => 'Maite Etxeberria (demo)', 'rol' => SZS_ROL_TESTER ),
		array( 'uid' => $tester_huerta, 'nombre' => 'Iñaki Larrea (demo)', 'rol' => SZS_ROL_TESTER ),
	);
	$nombre_de = array_column( $personas, 'nombre', 'uid' );

	// ─── Fincas: las que haya; si no hay ninguna, las del espacio ───
	$fincas = $fincas_existentes;
	if ( empty( $fincas ) ) {
		foreach ( SZS_FINCAS_DEL_ESPACIO as $uid_finca => $finca ) {
			$datos_finca = array_merge(
				$finca,
				array(
					'recintos_sigpac' => '',
					'notas'           => 'Datos de ejemplo · superficie pública, centroide aproximado.',
				)
			);
			$anadir( 'finca', $uid_finca, $datos_finca, $coordinacion );
			$fincas[ $uid_finca ] = $datos_finca;
		}
	}
	$uids_fincas    = array_keys( $fincas );
	$finca_a        = $uids_fincas[0];
	$finca_b        = $uids_fincas[1] ?? $uids_fincas[0];
	$nombre_finca   = static fn( string $uid_finca ): string => (string) ( $fincas[ $uid_finca ]['nombre'] ?? '' );
	$centro         = static fn( string $uid_finca ): array => array(
		(float) ( $fincas[ $uid_finca ]['latitud'] ?? 42.7872 ),
		(float) ( $fincas[ $uid_finca ]['longitud'] ?? -1.9450 ),
	);
	list( $lat_a, $lon_a ) = $centro( $finca_a );
	list( $lat_b, $lon_b ) = $centro( $finca_b );

	// ─── Zonas ───
	$zona_pasto  = $uid( 'zona-pasto-alto' );
	$zona_vedada = $uid( 'zona-regenerado' );
	$poligono    = static fn( float $lat, float $lon, float $lado ): string => (string) json_encode(
		array( array( $lat, $lon ), array( $lat + $lado, $lon ), array( $lat + $lado, $lon + $lado ), array( $lat, $lon + $lado ) )
	);
	$anadir( 'zona', $zona_pasto, array( 'finca_uid' => $finca_a, 'tipo' => 'parcela_pasto', 'nombre' => 'Pasto alto (demo)', 'vertices_json' => $poligono( $lat_a + 0.002, $lon_a - 0.004, 0.003 ), 'superficie_ha_calculada' => 8.2, 'superficie_ha_oficial' => null, 'estado' => 'en_uso', 'recinto_sigpac' => '', 'notas' => '', 'fecha_creacion_ms' => $hace( 60 ) ), $coordinacion );
	$anadir( 'zona', $zona_vedada, array( 'finca_uid' => $finca_b, 'tipo' => 'vedado', 'nombre' => 'Regenerado del robledal (demo)', 'vertices_json' => $poligono( $lat_b - 0.003, $lon_b + 0.001, 0.002 ), 'superficie_ha_calculada' => 3.6, 'superficie_ha_oficial' => null, 'estado' => 'descanso', 'recinto_sigpac' => '', 'notas' => 'Sin ganado hasta primavera.', 'fecha_creacion_ms' => $hace( 45 ) ), $coordinacion );

	// ─── Puntos (todos los estados, fijos y móviles) ───
	$puntos = array(
		'abrevadero'     => array( $finca_a, 'abrevadero', 'Abrevadero de la borda (demo)', 0.0010, 0.0012, 'operativo', $coordinacion ),
		'manga'          => array( $finca_a, 'manga', 'Manga de manejo (demo)', -0.0015, 0.0020, 'revisar', $coordinacion ),
		'cierre'         => array( $finca_a, 'cierre', 'Cierre del camino (demo)', 0.0030, -0.0025, 'averiado', $coordinacion ),
		'refugio'        => array( $finca_a, 'refugio', 'Refugio de pastores (demo)', -0.0028, -0.0010, 'operativo', $coordinacion ),
		'balsa'          => array( $finca_b, 'balsa', 'Balsa de La Planilla (demo)', 0.0012, -0.0018, 'operativo', $coordinacion ),
		'comedero'       => array( $finca_b, 'comedero', 'Comedero de invierno (demo)', -0.0010, 0.0015, 'revisar', $coordinacion ),
		'corral_movil'   => array( $finca_a, 'corral_movil', 'Corral móvil de Maite (demo)', 0.0022, 0.0030, 'operativo', $tester_queso ),
		'deposito_movil' => array( $finca_b, 'deposito_movil', 'Bidón de agua 1000 l (demo)', 0.0005, 0.0028, 'operativo', $tester_huerta ),
	);
	$uid_punto = array();
	foreach ( $puntos as $clave => list( $uid_finca, $tipo, $nombre, $desvio_lat, $desvio_lon, $estado, $autor ) ) {
		list( $lat, $lon ) = $centro( $uid_finca );
		$uid_punto[ $clave ] = $uid( 'punto-' . $clave );
		$anadir( 'punto', $uid_punto[ $clave ], array( 'finca_uid' => $uid_finca, 'tipo' => $tipo, 'nombre' => $nombre, 'latitud' => round( $lat + $desvio_lat, 6 ), 'longitud' => round( $lon + $desvio_lon, 6 ), 'estado' => $estado, 'notas' => '', 'fecha_creacion_ms' => $hace( 50 ) ), $autor );
	}

	// ─── Tareas (todos los estados, prioridades, con y sin responsable) ───
	$tareas      = array();
	$nueva_tarea = static function ( string $clave, array $campos ) use ( &$tareas, $uid, $ahora_ms, $hace, $coordinacion, $nombre_de, $nombre_finca ): string {
		$uid_tarea = $uid( 'tarea-' . $clave );
		$tarea     = array_merge(
			array(
				'uid'               => $uid_tarea,
				'punto_uid'         => '',
				'zona_uid'          => '',
				'descripcion'       => '',
				'responsable_uid'   => '',
				'creado_por_uid'    => $coordinacion,
				'prioridad'         => 'media',
				'estado'            => 'pendiente',
				'fecha_objetivo_ms' => null,
				'coste_centimos'    => null,
				'recurrencia_dias'  => null,
				'fecha_creacion_ms' => $hace( 20 ),
				'actualizado_ms'    => $ahora_ms,
			),
			$campos
		);
		$tarea['finca_nombre'] = $nombre_finca( $tarea['finca_uid'] );
		$tarea['responsable']  = (string) ( $nombre_de[ $tarea['responsable_uid'] ] ?? '' );
		$tareas[]              = $tarea;
		return $uid_tarea;
	};
	$nueva_tarea( 'vallado', array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['cierre'], 'titulo' => 'Reparar el cierre del camino', 'descripcion' => 'Dos postes caídos junto a la portilla.', 'responsable_uid' => $tester_queso, 'prioridad' => 'alta', 'fecha_objetivo_ms' => $hace( 3 ) ) );
	$nueva_tarea( 'manga', array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['manga'], 'titulo' => 'Revisar la manga antes del saneamiento', 'responsable_uid' => $tester_huerta, 'estado' => 'en_curso', 'fecha_objetivo_ms' => $en( 2 ) ) );
	$nueva_tarea( 'desbroce', array( 'finca_uid' => $finca_a, 'zona_uid' => $zona_pasto, 'titulo' => 'Desbrozar helechos del pasto alto', 'descripcion' => 'Tarea general: la puede coger cualquiera.', 'prioridad' => 'baja', 'fecha_objetivo_ms' => $en( 10 ) ) );
	$nueva_tarea( 'balsa', array( 'finca_uid' => $finca_b, 'punto_uid' => $uid_punto['balsa'], 'titulo' => 'Limpiar la balsa', 'responsable_uid' => $tester_huerta, 'estado' => 'hecha', 'fecha_objetivo_ms' => $hace( 8 ), 'coste_centimos' => 4500 ) );
	$nueva_tarea( 'bomba', array( 'finca_uid' => $finca_b, 'punto_uid' => $uid_punto['comedero'], 'titulo' => 'Cambiar la bomba del comedero', 'descripcion' => 'Esperando la pieza del proveedor.', 'estado' => 'bloqueada', 'prioridad' => 'alta', 'fecha_objetivo_ms' => $en( 5 ) ) );
	$nueva_tarea( 'abrevadero', array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['abrevadero'], 'titulo' => 'Comprobar el nivel del abrevadero', 'responsable_uid' => $tester_queso, 'fecha_objetivo_ms' => $en( 1 ), 'recurrencia_dias' => 7 ) );
	$nueva_tarea( 'corral', array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['corral_movil'], 'titulo' => 'Mover el corral móvil a la parcela de arriba', 'responsable_uid' => $tester_queso, 'creado_por_uid' => $tester_queso, 'fecha_objetivo_ms' => $en( 4 ) ) );
	$tarea_aceptada = $nueva_tarea( 'refugio', array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['refugio'], 'titulo' => 'Arreglar la puerta del refugio', 'prioridad' => 'media', 'fecha_objetivo_ms' => $en( 14 ), 'recurrencia_dias' => 30 ) );

	// ─── Proyectos de test ───
	$proyecto_queso  = $uid( 'proyecto-queseria' );
	$proyecto_huerta = $uid( 'proyecto-huerta' );
	$proyecto_cerrado = $uid( 'proyecto-cordero' );
	$datos_proyecto  = static fn( array $campos ): array => array_merge(
		array(
			'persona_uid'                   => '',
			'persona'                       => '',
			'fecha_fin_ms'                  => null,
			'notas'                         => '',
			'fecha_creacion_ms'             => $hace( 200 ),
			'estado'                        => 'abierto',
			'cerrado_ms'                    => null,
			'porcentaje_beneficio_zunbeltz' => 25,
			'porcentaje_perdida_zunbeltz'   => 50,
			'valoracion_zunbeltz'           => null,
			'valoracion_tester'             => null,
		),
		$campos
	);
	$anadir( 'proyecto', $proyecto_queso, $datos_proyecto( array( 'nombre' => 'Quesería de prueba (demo)', 'persona' => $nombre_de[ $tester_queso ], 'persona_uid' => $tester_queso, 'actividad' => 'Ovino de leche · quesería', 'finca_uid' => $finca_a, 'fecha_inicio_ms' => $hace( 150 ), 'fecha_fin_ms' => $en( 215 ) ) ), $coordinacion );
	$anadir( 'proyecto', $proyecto_huerta, $datos_proyecto( array( 'nombre' => 'Huerta de prueba (demo)', 'persona' => $nombre_de[ $tester_huerta ], 'persona_uid' => $tester_huerta, 'actividad' => 'Horticultura ecológica', 'finca_uid' => $finca_b, 'fecha_inicio_ms' => $hace( 90 ), 'fecha_fin_ms' => $en( 275 ), 'porcentaje_perdida_zunbeltz' => 50 ) ), $coordinacion );
	$anadir( 'proyecto', $proyecto_cerrado, $datos_proyecto( array( 'nombre' => 'Cordero de pasto 2025 (demo)', 'persona' => $nombre_de[ $tester_queso ], 'persona_uid' => $tester_queso, 'actividad' => 'Ovino de carne', 'finca_uid' => $finca_a, 'fecha_inicio_ms' => $hace( 560 ), 'fecha_fin_ms' => $hace( 195 ), 'estado' => 'cerrado', 'cerrado_ms' => $hace( 190 ), 'valoracion_zunbeltz' => 4, 'valoracion_tester' => 5, 'notas' => 'Proyecto cerrado: sus informes salen sin marca de borrador.' ) ), $coordinacion );

	// Seguimiento: alimentación varios días (para el Excel por días),
	// pariciones y producto.
	$n = 0;
	$registro = static function ( string $proyecto, string $autor, string $uid_finca, string $tipo, float $cantidad, int $dias, string $lote_animales = '' ) use ( $anadir, $uid, $hace, &$n ): void {
		$anadir( 'registro_actividad', $uid( 'registro-' . ( ++$n ) ), array( 'finca_uid' => $uid_finca, 'tipo' => $tipo, 'cantidad' => $cantidad, 'fecha_ms' => $hace( $dias ), 'lote' => $lote_animales, 'notas' => '', 'fecha_creacion_ms' => $hace( $dias ) ), $autor, $proyecto );
	};
	foreach ( array( 14, 13, 12, 10, 9, 7, 6, 5, 3, 2, 1 ) as $indice => $dias ) {
		$registro( $proyecto_queso, $tester_queso, $finca_a, 'alimentacion', 38 + ( $indice % 4 ) * 3, $dias, 0 === $indice % 2 ? 'Rebaño A' : 'Corderas' );
	}
	$registro( $proyecto_queso, $tester_queso, $finca_a, 'paricion', 18, 100 );
	$registro( $proyecto_queso, $tester_queso, $finca_a, 'producto', 320, 40 );
	$registro( $proyecto_huerta, $tester_huerta, $finca_b, 'producto', 180, 20 );
	$registro( $proyecto_cerrado, $tester_queso, $finca_a, 'paricion', 26, 400 );

	$apunte = static function ( string $proyecto, string $autor, string $uid_finca, string $tipo, string $categoria, string $concepto, int $centimos, int $iva, int $dias, string $asumido_por = 'tester', int $amortizacion = 0 ) use ( $anadir, $uid, $hace, &$n ): void {
		$anadir( 'apunte', $uid( 'apunte-' . ( ++$n ) ), array( 'finca_uid' => $uid_finca, 'tipo' => $tipo, 'categoria' => $categoria, 'concepto' => $concepto, 'importe_centimos' => $centimos, 'iva_porcentaje' => $iva, 'fecha_ms' => $hace( $dias ), 'notas' => '', 'asumido_por' => $asumido_por, 'es_amortizacion' => $amortizacion, 'fecha_creacion_ms' => $hace( $dias ) ), $autor, $proyecto );
	};
	$apunte( $proyecto_queso, $tester_queso, $finca_a, 'gasto', 'alimentacion', 'Pienso y forraje', 42000, 10, 115 );
	$apunte( $proyecto_queso, $tester_queso, $finca_a, 'gasto', 'sanidad', 'Veterinario', 9000, 21, 80 );
	$apunte( $proyecto_queso, $tester_queso, $finca_a, 'gasto', 'insumos', 'Cuajo y sal', 6000, 21, 50, 'zunbeltz' );
	$apunte( $proyecto_queso, $coordinacion, $finca_a, 'gasto', 'infraestructuras', 'Amortización de la sala de quesería', 25000, 0, 30, 'zunbeltz', 1 );
	$apunte( $proyecto_queso, $tester_queso, $finca_a, 'ingreso', 'ayuda', 'Prima PAC / ecorégimen', 28000, 0, 90 );
	$apunte( $proyecto_huerta, $tester_huerta, $finca_b, 'gasto', 'insumos', 'Semillas y plantel', 31000, 10, 85 );
	$apunte( $proyecto_huerta, $tester_huerta, $finca_b, 'gasto', 'maquinaria', 'Gasoil de la motoazada', 9500, 21, 40 );
	$apunte( $proyecto_huerta, $tester_huerta, $finca_b, 'gasto', 'mano_obra', 'Jornales de recogida', 42000, 0, 15 );
	$apunte( $proyecto_cerrado, $tester_queso, $finca_a, 'gasto', 'ganado', 'Compra de ovejas', 180000, 10, 540 );
	$apunte( $proyecto_cerrado, $tester_queso, $finca_a, 'ingreso', 'venta', 'Venta de corderos a carnicería', 265000, 10, 220 );

	$venta = static function ( string $proyecto, string $autor, string $producto, string $canal, float $cantidad, string $unidad, int $precio, int $iva, int $dias ) use ( $anadir, $uid, $hace, &$n ): void {
		$anadir( 'venta', $uid( 'venta-' . ( ++$n ) ), array( 'fecha_ms' => $hace( $dias ), 'producto' => $producto, 'canal' => $canal, 'cantidad' => $cantidad, 'unidad' => $unidad, 'precio_unitario_centimos' => $precio, 'ingreso_centimos' => (int) round( $cantidad * $precio ), 'iva_porcentaje' => $iva, 'notas' => '', 'fecha_creacion_ms' => $hace( $dias ) ), $autor, $proyecto );
	};
	$venta( $proyecto_queso, $tester_queso, 'Queso curado', 'directa', 40, 'uds', 1200, 10, 60 );
	$venta( $proyecto_queso, $tester_queso, 'Queso curado', 'mercado', 55, 'uds', 1300, 10, 30 );
	$venta( $proyecto_queso, $tester_queso, 'Requesón', 'tienda', 30, 'uds', 450, 4, 10 );
	$venta( $proyecto_huerta, $tester_huerta, 'Cesta de verdura', 'grupo_consumo', 25, 'uds', 1500, 4, 35 );
	$venta( $proyecto_huerta, $tester_huerta, 'Tomate', 'hosteleria', 60, 'kg', 280, 4, 12 );

	$validacion = static function ( string $proyecto, string $autor, string $descripcion, string $resultado, int $valoracion, int $dias ) use ( $anadir, $uid, $hace, &$n ): void {
		$anadir( 'validacion', $uid( 'validacion-' . ( ++$n ) ), array( 'fecha_ms' => $hace( $dias ), 'descripcion' => $descripcion, 'resultado' => $resultado, 'valoracion' => $valoracion, 'notas' => '', 'fecha_creacion_ms' => $hace( $dias ) ), $autor, $proyecto );
	};
	$validacion( $proyecto_queso, $tester_queso, 'Curación a 60 días', 'validado', 4, 70 );
	$validacion( $proyecto_queso, $tester_queso, 'Formato cuña 250 g', 'ajustar', 3, 20 );
	$validacion( $proyecto_huerta, $tester_huerta, 'Cesta de 5 kg para grupos de consumo', 'descartar', 2, 25 );

	// Convenio: presupuesto, fianza, acompañamiento, incidencias (coordinación).
	foreach ( array(
		array( $proyecto_queso, 'alimentacion', 'Pienso y forraje del año', 'tester', 0, 90000 ),
		array( $proyecto_queso, 'sanidad', 'Saneamiento y veterinario', 'tester', 0, 20000 ),
		array( $proyecto_queso, 'infraestructuras', 'Sala de quesería', 'zunbeltz', 1, 60000 ),
		array( $proyecto_huerta, 'insumos', 'Semillas, plantel y abono', 'tester', 0, 50000 ),
		array( $proyecto_huerta, 'maquinaria', 'Motoazada y combustible', 'zunbeltz', 1, 30000 ),
	) as list( $proyecto, $categoria, $concepto, $asumido_por, $amortizacion, $centimos ) ) {
		$anadir( 'partida_presupuesto', $uid( 'partida-' . ( ++$n ) ), array( 'categoria' => $categoria, 'concepto' => $concepto, 'asumido_por' => $asumido_por, 'es_amortizacion' => $amortizacion, 'importe_centimos' => $centimos, 'notas' => '' ), $coordinacion, $proyecto );
	}
	foreach ( array(
		array( $proyecto_queso, 'deposito', 50000, 150 ),
		array( $proyecto_huerta, 'deposito', 50000, 90 ),
		array( $proyecto_cerrado, 'deposito', 50000, 560 ),
		array( $proyecto_cerrado, 'retencion', 10000, 190 ),
		array( $proyecto_cerrado, 'devolucion', 40000, 185 ),
	) as list( $proyecto, $tipo, $centimos, $dias ) ) {
		$anadir( 'movimiento_fianza', $uid( 'fianza-' . ( ++$n ) ), array( 'tipo' => $tipo, 'importe_centimos' => $centimos, 'fecha_ms' => $hace( $dias ), 'notas' => '' ), $coordinacion, $proyecto );
	}
	foreach ( array(
		array( $proyecto_queso, 'formacion', 'Curso de elaboración de queso de oveja', 'asistida', 8.0, 120 ),
		array( $proyecto_queso, 'asesoramiento', 'Visita de ganadera experta: ordeño', 'asistida', 3.0, 60 ),
		array( $proyecto_queso, 'reunion', 'Reunión de seguimiento trimestral', 'propuesta', null, -7 ),
		array( $proyecto_huerta, 'visita_referencia', 'Visita a huerta ecológica de referencia', 'no_asistida', 4.0, 40 ),
		array( $proyecto_huerta, 'busqueda_canales', 'Contacto con grupos de consumo de Estella', 'asistida', 2.0, 30 ),
	) as list( $proyecto, $tipo, $descripcion, $asistencia, $horas, $dias ) ) {
		$anadir( 'acompanamiento', $uid( 'acompanamiento-' . ( ++$n ) ), array( 'tipo' => $tipo, 'fecha_ms' => $hace( $dias ), 'descripcion' => $descripcion, 'asistencia' => $asistencia, 'horas' => $horas, 'notas' => '' ), $coordinacion, $proyecto );
	}
	$anadir( 'incidencia_cumplimiento', $uid( 'incidencia-' . ( ++$n ) ), array( 'nivel' => 'leve', 'fecha_ms' => $hace( 45 ), 'descripcion' => 'Retraso en la entrega del registro de alimentación', 'retencion_centimos' => 0, 'notas' => '' ), $coordinacion, $proyecto_huerta );
	$anadir( 'incidencia_cumplimiento', $uid( 'incidencia-' . ( ++$n ) ), array( 'nivel' => 'grave', 'fecha_ms' => $hace( 200 ), 'descripcion' => 'Cierre dañado sin avisar', 'retencion_centimos' => 10000, 'notas' => '' ), $coordinacion, $proyecto_cerrado );

	// Calculadora de transformación: dos caminos para comparar.
	$anadir( 'escenario_transformacion', $uid( 'escenario-canal' ), array( 'nombre' => 'Cordero en canal a carnicería', 'peso_vivo_kg' => 24.0, 'animales' => 20, 'rendimiento_canal' => 48.0, 'rendimiento_producto' => 100.0, 'precio_kg_centimos' => 950, 'coste_sacrificio_centimos' => 1800, 'coste_transformacion_kg_centimos' => 0, 'otros_costes_centimos' => 6000, 'notas' => 'Ejemplo inventado para probar la pantalla.', 'fecha_ms' => $hace( 12 ) ), $tester_queso, $proyecto_queso );
	$anadir( 'escenario_transformacion', $uid( 'escenario-despiece' ), array( 'nombre' => 'Despiece y venta directa en cajas', 'peso_vivo_kg' => 24.0, 'animales' => 20, 'rendimiento_canal' => 48.0, 'rendimiento_producto' => 85.0, 'precio_kg_centimos' => 1600, 'coste_sacrificio_centimos' => 1800, 'coste_transformacion_kg_centimos' => 250, 'otros_costes_centimos' => 15000, 'notas' => 'Ejemplo inventado para probar la pantalla.', 'fecha_ms' => $hace( 11 ) ), $tester_queso, $proyecto_queso );

	// ─── Peticiones (todos los estados) ───
	$peticion = static function ( string $clave, string $autor, array $campos ) use ( $anadir, $uid, $hace ): void {
		$anadir( 'peticion', $uid( 'peticion-' . $clave ), array_merge( array( 'finca_uid' => '', 'punto_uid' => '', 'descripcion' => '', 'urgente' => 0, 'estado' => 'pendiente', 'respuesta' => '', 'tarea_uid' => '', 'fecha_creacion_ms' => $hace( 2 ) ), $campos ), $autor );
	};
	$peticion( 'agua', $tester_huerta, array( 'finca_uid' => $finca_b, 'punto_uid' => $uid_punto['deposito_movil'], 'titulo' => 'El bidón pierde agua por la llave', 'urgente' => 1, 'fecha_creacion_ms' => $hace( 0 ) ) );
	$peticion( 'sombra', $tester_queso, array( 'finca_uid' => $finca_a, 'titulo' => 'Malla de sombra para el corral', 'descripcion' => 'En agosto las ovejas no tienen sombra en la parcela de arriba.' ) );
	$peticion( 'refugio', $tester_queso, array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['refugio'], 'titulo' => 'La puerta del refugio no cierra', 'estado' => 'aceptada', 'tarea_uid' => $tarea_aceptada, 'respuesta' => 'Hecha tarea; la arreglamos este mes.', 'fecha_creacion_ms' => $hace( 9 ) ) );
	$peticion( 'tractor', $tester_huerta, array( 'finca_uid' => $finca_b, 'titulo' => 'Tractor para labrar la huerta', 'estado' => 'descartada', 'respuesta' => 'No hay tractor disponible; os conseguimos la motoazada.', 'fecha_creacion_ms' => $hace( 30 ) ) );

	// ─── Avisos (las cuatro categorías, alarma y aviso, abiertos y resueltos) ───
	$aviso = static function ( string $clave, string $autor, array $campos ) use ( $anadir, $uid, $hace ): void {
		$anadir( 'aviso', $uid( 'aviso-' . $clave ), array_merge( array( 'finca_uid' => '', 'punto_uid' => '', 'gravedad' => 'aviso', 'descripcion' => '', 'estado' => 'abierto', 'fecha_ms' => $hace( 1 ) ), $campos ), $autor );
	};
	$aviso( 'oveja', $tester_queso, array( 'finca_uid' => $finca_a, 'categoria' => 'ganado', 'gravedad' => 'alarma', 'titulo' => 'Oveja coja en el pasto alto', 'descripcion' => 'No apoya la pata trasera derecha.', 'fecha_ms' => $hace( 0 ) ) );
	$aviso( 'cierre', $tester_huerta, array( 'finca_uid' => $finca_a, 'punto_uid' => $uid_punto['cierre'], 'categoria' => 'instalaciones', 'titulo' => 'Portilla del camino abierta' ) );
	$aviso( 'reunion', $coordinacion, array( 'categoria' => 'seguimiento', 'titulo' => 'Revisión de cuentas del trimestre', 'descripcion' => 'Traed los tickets de gastos.', 'fecha_ms' => $hace( 3 ) ) );
	$aviso( 'feria', $coordinacion, array( 'categoria' => 'noticias', 'titulo' => 'Feria de ganado de Estella el día 25', 'fecha_ms' => $hace( 5 ) ) );
	$aviso( 'agua', $coordinacion, array( 'finca_uid' => $finca_b, 'punto_uid' => $uid_punto['balsa'], 'categoria' => 'instalaciones', 'gravedad' => 'alarma', 'titulo' => 'Balsa sin agua', 'estado' => 'resuelto', 'fecha_ms' => $hace( 12 ) ) );

	// ─── Agenda y referencias (inventados, teléfonos y correos falsos) ───
	foreach ( array(
		array( 'matadero', 'Matadero comarcal (demo)', '600 000 001', 'matadero@example.org', 'Estella-Lizarra', $coordinacion ),
		array( 'veterinaria', 'Clínica veterinaria (demo)', '600 000 002', 'veterinaria@example.org', 'Abárzuza', $coordinacion ),
		array( 'experto', 'Ganadera experta en ovino (demo)', '600 000 003', '', 'Lezaun', $coordinacion ),
		array( 'comprador', 'Grupo de consumo (demo)', '600 000 004', 'grupo@example.org', 'Pamplona', $tester_huerta ),
	) as list( $tipo, $nombre, $telefono, $correo, $localidad, $autor ) ) {
		$anadir( 'contacto', $uid( 'contacto-' . ( ++$n ) ), array( 'nombre' => $nombre, 'tipo' => $tipo, 'telefono' => $telefono, 'correo' => $correo, 'localidad' => $localidad, 'notas' => '' ), $autor );
	}
	$fuente_inventada = 'Inventado para pruebas: no es un dato de referencia.';
	$anadir( 'rendimiento', $uid( 'rendimiento-cordero' ), array( 'nombre' => 'Cordero lechal (demo)', 'rendimiento_canal' => 50.0, 'rendimiento_producto' => 100.0, 'fuente' => $fuente_inventada ), $coordinacion );
	$anadir( 'rendimiento', $uid( 'rendimiento-ternera' ), array( 'nombre' => 'Ternera (demo)', 'rendimiento_canal' => 55.0, 'rendimiento_producto' => 75.0, 'fuente' => $fuente_inventada ), $coordinacion );

	// ─── Actividad del espacio ───
	$actividad = array();
	foreach ( array(
		array( 26, $tester_huerta, 'estado', 'tarea', $uid( 'tarea-balsa' ), 'Limpiar la balsa', $nombre_finca( $finca_b ), 'hecha', 'app' ),
		array( 20, $tester_queso, 'crear', 'punto', $uid_punto['corral_movil'], 'Corral móvil de Maite (demo)', $nombre_finca( $finca_a ), '', 'app' ),
		array( 12, $tester_queso, 'mover', 'punto', $uid_punto['corral_movil'], 'Corral móvil de Maite (demo)', $nombre_finca( $finca_a ), '', 'app' ),
		array( 6, $coordinacion, 'asignar', 'tarea', $uid( 'tarea-manga' ), 'Revisar la manga antes del saneamiento', $nombre_finca( $finca_a ), $nombre_de[ $tester_huerta ], 'panel' ),
		array( 3, $tester_queso, 'crear', 'aviso', $uid( 'aviso-oveja' ), 'Oveja coja en el pasto alto', $nombre_finca( $finca_a ), '', 'app' ),
		array( 1, $tester_huerta, 'crear', 'peticion', $uid( 'peticion-agua' ), 'El bidón pierde agua por la llave', $nombre_finca( $finca_b ), '', 'app' ),
	) as list( $horas, $persona, $accion, $tipo, $uid_objeto, $etiqueta, $contexto, $detalle, $origen ) ) {
		$actividad[] = array(
			'momento_ms'     => $ahora_ms - $horas * 3_600_000,
			'persona_uid'    => $persona,
			'persona_nombre' => $nombre_de[ $persona ],
			'accion'         => $accion,
			'tipo'           => $tipo,
			'uid'            => $uid_objeto,
			'etiqueta'       => $etiqueta,
			'contexto'       => $contexto,
			'detalle'        => $detalle,
			'origen'         => $origen,
		);
	}

	return array(
		'personas'  => $personas,
		'entidades' => $entidades,
		'tareas'    => array_map( 'szs_normalizar_tarea', $tareas ),
		'actividad' => $actividad,
	);
}

// ============================================================
// Escritura
// ============================================================

/**
 * Siembra el plan en la base de datos.
 *
 * @return array<string, string> nombre de persona => token en claro (para
 *                               entrar en la app como ella).
 */
function szs_sembrar_datos_demo(): array {
	global $wpdb;

	$fincas_existentes = array();
	foreach ( szs_listar_entidades_tipo( 'finca' ) as $finca ) {
		$fincas_existentes[ $finca['uid'] ] = $finca['datos'];
	}
	$plan = szs_plan_datos_demo( (int) round( microtime( true ) * 1000 ), bin2hex( random_bytes( 3 ) ), $fincas_existentes );

	$tokens = array();
	foreach ( $plan['personas'] as $persona ) {
		$token = szs_generar_token();
		$wpdb->insert(
			szs_tabla_personas(),
			array(
				'uid'        => $persona['uid'],
				'nombre'     => $persona['nombre'],
				'rol'        => $persona['rol'],
				'token_hash' => szs_hash_token( $token ),
				'activo'     => 1,
				'creado_en'  => gmdate( 'Y-m-d H:i:s' ),
			)
		);
		$tokens[ $persona['nombre'] ] = $token;
	}
	foreach ( $plan['entidades'] as $entidad ) {
		$normalizada = szs_normalizar_entidad( $entidad );
		szs_guardar_entidad( $normalizada, szs_obtener_entidad( $normalizada['tipo'], $normalizada['uid'] ), $normalizada['autor_uid'] );
	}
	foreach ( $plan['tareas'] as $tarea ) {
		szs_guardar_tarea( $wpdb->prefix . SZS_TABLA, $tarea, true );
	}
	foreach ( $plan['actividad'] as $entrada ) {
		$wpdb->insert( $wpdb->prefix . SZS_TABLA_ACTIVIDAD, $entrada );
	}
	return $tokens;
}

/**
 * Retira todo lo de demostración: lo creado con uid `demo-` y lo que
 * cuelga de ello (seguimiento apuntado en un proyecto demo, tareas de
 * personas demo o ancladas a puntos y zonas demo).
 *
 * @return array{entidades: int, tareas: int, personas: int, actividad: int}
 */
function szs_vaciar_datos_demo(): array {
	global $wpdb;
	$patron = $wpdb->esc_like( SZS_PREFIJO_DEMO ) . '%';

	$tabla_entidades = szs_tabla_entidades();
	$filas           = (array) $wpdb->get_results(
		$wpdb->prepare( "SELECT * FROM {$tabla_entidades} WHERE borrado = 0 AND ( uid LIKE %s OR proyecto_uid LIKE %s OR autor_uid LIKE %s )", $patron, $patron, $patron ),
		ARRAY_A
	);
	$ahora = (int) round( microtime( true ) * 1000 );
	foreach ( $filas as $fila ) {
		$existente = szs_fila_a_entidad( $fila );
		$lapida    = array_merge(
			$existente,
			array(
				'borrado'        => true,
				'actualizado_ms' => max( $ahora, $existente['actualizado_ms'] + 1 ),
			)
		);
		szs_guardar_entidad( $lapida, $existente, $existente['autor_uid'] );
	}

	$tabla_tareas = $wpdb->prefix . SZS_TABLA;
	$tareas       = (int) $wpdb->query(
		$wpdb->prepare(
			"DELETE FROM {$tabla_tareas} WHERE uid LIKE %s OR punto_uid LIKE %s OR zona_uid LIKE %s OR responsable_uid LIKE %s OR creado_por_uid LIKE %s",
			$patron,
			$patron,
			$patron,
			$patron,
			$patron
		)
	);
	$tabla_actividad = $wpdb->prefix . SZS_TABLA_ACTIVIDAD;
	$actividad       = (int) $wpdb->query( $wpdb->prepare( "DELETE FROM {$tabla_actividad} WHERE persona_uid LIKE %s OR uid LIKE %s", $patron, $patron ) );
	$tabla_personas  = szs_tabla_personas();
	$personas        = (int) $wpdb->query( $wpdb->prepare( "DELETE FROM {$tabla_personas} WHERE uid LIKE %s", $patron ) );

	return array(
		'entidades' => count( $filas ),
		'tareas'    => $tareas,
		'personas'  => $personas,
		'actividad' => $actividad,
	);
}

/**
 * Cuánto hay ahora de demostración (sin contar lápidas).
 *
 * @return array{entidades: int, tareas: int, personas: int}
 */
function szs_contar_datos_demo(): array {
	global $wpdb;
	$patron          = $wpdb->esc_like( SZS_PREFIJO_DEMO ) . '%';
	$tabla_entidades = szs_tabla_entidades();
	$tabla_tareas    = $wpdb->prefix . SZS_TABLA;
	$tabla_personas  = szs_tabla_personas();
	return array(
		'entidades' => (int) $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$tabla_entidades} WHERE borrado = 0 AND uid LIKE %s", $patron ) ),
		'tareas'    => (int) $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$tabla_tareas} WHERE uid LIKE %s", $patron ) ),
		'personas'  => (int) $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$tabla_personas} WHERE uid LIKE %s", $patron ) ),
	);
}

// ============================================================
// Panel · Datos de demostración
// ============================================================

function szs_registrar_pagina_datos_demo(): void {
	if ( ! szs_herramientas_desarrollo_activas() ) {
		return;
	}
	add_submenu_page( SZS_PAGINA_TAREAS, 'Datos de demostración', 'Datos demo', 'manage_options', SZS_PAGINA_DATOS_DEMO, 'szs_pagina_datos_demo' );
}

function szs_pagina_datos_demo(): void {
	if ( ! szs_herramientas_desarrollo_activas() || ! current_user_can( 'manage_options' ) ) {
		return;
	}
	$aviso  = null;
	$tokens = array();
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_datos_demo' );
		$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
		if ( 'sembrar' === $accion ) {
			$tokens = szs_sembrar_datos_demo();
			$aviso  = array( 'success', 'Datos de demostración creados. Los móviles los reciben en la próxima sincronización.' );
		}
		if ( 'vaciar' === $accion ) {
			$retirado = szs_vaciar_datos_demo();
			$aviso    = array( 'success', sprintf( 'Retirados: %d entidades, %d tareas, %d personas y %d entradas de actividad.', $retirado['entidades'], $retirado['tareas'], $retirado['personas'], $retirado['actividad'] ) );
		}
	}
	$cuenta = szs_contar_datos_demo();
	?>
	<div class="wrap">
		<h1>Datos de demostración</h1>
		<p style="max-width:720px;">Herramienta de desarrollo: rellena el espacio con datos de ejemplo para ver y probar todas las pantallas del panel y de la app (tareas en todos los estados, tareas periódicas, puntos fijos y móviles, zonas, tres proyectos — uno cerrado — con seguimiento, ventas, validaciones, convenio y escenarios de transformación, peticiones, avisos y alarmas, contactos, rendimientos y actividad). Solo se ve fuera de producción.</p>
		<p style="max-width:720px;">Todo lo creado lleva un identificador que empieza por <code>demo-</code> y se retira de un golpe. Las fincas existentes se reutilizan; si no hay ninguna se crean Zunbeltz y La Planilla, que se conservan al retirar. No se envían correos.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<?php if ( ! empty( $tokens ) ) : ?>
			<div class="notice notice-info">
				<p>Tokens de las personas de demostración — cópialos ahora, <strong>no se vuelven a mostrar</strong>. En la app: <strong>Ajustes → Sincronización</strong>, dirección <code><?php echo esc_html( home_url() ); ?></code>.</p>
				<table class="widefat striped" style="max-width:720px;">
					<?php foreach ( $tokens as $nombre => $token ) : ?>
						<tr><td><?php echo esc_html( $nombre ); ?></td><td><code style="user-select:all;"><?php echo esc_html( $token ); ?></code></td></tr>
					<?php endforeach; ?>
				</table>
			</div>
		<?php endif; ?>

		<p>Ahora hay <strong><?php echo (int) $cuenta['entidades']; ?></strong> entidades, <strong><?php echo (int) $cuenta['tareas']; ?></strong> tareas y <strong><?php echo (int) $cuenta['personas']; ?></strong> personas de demostración.</p>

		<form method="post" style="display:inline-block;margin-right:8px;">
			<?php wp_nonce_field( 'szs_datos_demo' ); ?>
			<input type="hidden" name="szs_accion" value="sembrar">
			<button type="submit" class="button button-primary">Crear datos de demostración</button>
		</form>
		<form method="post" style="display:inline-block;">
			<?php wp_nonce_field( 'szs_datos_demo' ); ?>
			<input type="hidden" name="szs_accion" value="vaciar">
			<button type="submit" class="button" onclick="return confirm('¿Retirar todos los datos de demostración?');">Retirar datos de demostración</button>
		</form>
		<p class="description" style="max-width:720px;margin-top:12px;">Al retirar, las entidades quedan como borradas para que también desaparezcan de los móviles ya sincronizados. Se retira además lo que alguien haya apuntado en un proyecto de demostración y las tareas asignadas a personas de demostración o ancladas a sus puntos y zonas.</p>
		<p class="description">Desde la consola: <code>wp solera-zunbeltz demo sembrar | vaciar | estado</code></p>
	</div>
	<?php
}

// ============================================================
// WP-CLI
// ============================================================

if ( defined( 'WP_CLI' ) && WP_CLI ) {
	WP_CLI::add_command(
		'solera-zunbeltz demo',
		/**
		 * Datos de demostración de Solera Zunbeltz.
		 *
		 * ## OPTIONS
		 *
		 * <accion>
		 * : sembrar | vaciar | estado
		 */
		static function ( array $argumentos ): void {
			if ( ! szs_herramientas_desarrollo_activas() ) {
				WP_CLI::error( "Desactivado en producción. Para forzarlo: define( 'SZS_DATOS_DEMO', true ); en wp-config.php." );
			}
			switch ( $argumentos[0] ?? 'estado' ) {
				case 'sembrar':
					foreach ( szs_sembrar_datos_demo() as $nombre => $token ) {
						WP_CLI::log( "{$nombre}: {$token}" );
					}
					WP_CLI::success( 'Datos de demostración creados.' );
					break;
				case 'vaciar':
					$retirado = szs_vaciar_datos_demo();
					WP_CLI::success( sprintf( 'Retirados: %d entidades, %d tareas, %d personas y %d entradas de actividad.', $retirado['entidades'], $retirado['tareas'], $retirado['personas'], $retirado['actividad'] ) );
					break;
				default:
					$cuenta = szs_contar_datos_demo();
					WP_CLI::log( sprintf( '%d entidades, %d tareas y %d personas de demostración.', $cuenta['entidades'], $cuenta['tareas'], $cuenta['personas'] ) );
			}
		}
	);
}
