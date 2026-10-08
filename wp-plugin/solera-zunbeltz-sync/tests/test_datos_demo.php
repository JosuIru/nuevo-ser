<?php
/**
 * Tests del plan de datos de demostración (`szs_plan_datos_demo`): que todo
 * lleva el prefijo que permite retirarlo, que las referencias entre
 * entidades se resuelven, que cubre los estados y categorías que hay que
 * probar y que cada persona tester ve lo suyo. Sin WordPress.
 *
 * Ejecutar: php tests/test_datos_demo.php
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

$ahora_ms = 1_791_244_800_000; // 2026-10-06 00:00 UTC
$plan     = szs_plan_datos_demo( $ahora_ms, 'abc123', array() );

// ─── Prefijo: todo se puede retirar ───
$uids_personas = array_column( $plan['personas'], 'uid' );
$sin_prefijo   = array();
foreach ( $plan['entidades'] as $entidad ) {
	if ( 'finca' !== $entidad['tipo'] && ! szs_es_uid_demo( $entidad['uid'] ) ) {
		$sin_prefijo[] = $entidad['tipo'] . ':' . $entidad['uid'];
	}
}
foreach ( array_merge( $plan['tareas'], $plan['personas'] ) as $fila ) {
	if ( ! szs_es_uid_demo( $fila['uid'] ) ) {
		$sin_prefijo[] = $fila['uid'];
	}
}
afirmar( array(), $sin_prefijo, 'todo salvo las fincas lleva el prefijo demo-' );

// ─── Sin espacio previo: crea las fincas con los uid de la app ───
$fincas = array_values( array_filter( $plan['entidades'], static fn( $entidad ) => 'finca' === $entidad['tipo'] ) );
afirmar( array( 'finca-zunbeltz', 'finca-la-planilla' ), array_column( $fincas, 'uid' ), 'crea Zunbeltz y La Planilla con los uid de la app' );

// ─── Con fincas existentes: las reutiliza ───
$con_fincas = szs_plan_datos_demo( $ahora_ms, 'abc123', array( 'finca-real' => array( 'nombre' => 'Finca real', 'latitud' => 42.0, 'longitud' => -2.0 ) ) );
afirmar( 0, count( array_filter( $con_fincas['entidades'], static fn( $entidad ) => 'finca' === $entidad['tipo'] ) ), 'no crea fincas si ya hay' );
afirmar( array( 'finca-real' ), array_values( array_unique( array_column( $con_fincas['tareas'], 'finca_uid' ) ) ), 'cuelga las tareas de la finca existente' );
afirmar( array( 'Finca real' ), array_values( array_unique( array_column( $con_fincas['tareas'], 'finca_nombre' ) ) ), 'y pone su nombre en las tareas' );

// ─── Uids únicos y distintos entre dos siembras ───
$claves = array_map( static fn( $entidad ) => $entidad['tipo'] . ':' . $entidad['uid'], $plan['entidades'] );
afirmar( count( $claves ), count( array_unique( $claves ) ), 'sin uids repetidos en las entidades' );
$otro_lote = szs_plan_datos_demo( $ahora_ms, 'def456', array() );
afirmar(
	array(),
	array_values( array_intersect( array_column( $plan['tareas'], 'uid' ), array_column( $otro_lote['tareas'], 'uid' ) ) ),
	'dos siembras no chocan'
);

// ─── Tipos conocidos y referencias resueltas ───
$uids_por_tipo = array();
foreach ( $plan['entidades'] as $entidad ) {
	$uids_por_tipo[ $entidad['tipo'] ][] = $entidad['uid'];
}
afirmar( array(), array_values( array_filter( array_keys( $uids_por_tipo ), static fn( $tipo ) => ! szs_tipo_entidad_existe( $tipo ) ) ), 'todos los tipos existen' );
afirmar( array(), array_values( array_diff( array_keys( szs_tipos_entidad() ), array_keys( $uids_por_tipo ) ) ), 'hay al menos una entidad de cada tipo' );

$rotas = array();
$existe = static fn( string $tipo, string $uid ): bool => in_array( $uid, $uids_por_tipo[ $tipo ] ?? array(), true );
foreach ( $plan['entidades'] as $entidad ) {
	$datos = $entidad['datos'];
	foreach ( array( 'finca_uid' => 'finca', 'punto_uid' => 'punto' ) as $campo => $tipo_destino ) {
		if ( '' !== ( $datos[ $campo ] ?? '' ) && ! $existe( $tipo_destino, $datos[ $campo ] ) ) {
			$rotas[] = "{$entidad['uid']}.{$campo}";
		}
	}
	$ambito = szs_tipos_entidad()[ $entidad['tipo'] ]['ambito'];
	if ( SZS_AMBITO_HIJO_PROYECTO === $ambito && ! $existe( 'proyecto', $entidad['proyecto_uid'] ) ) {
		$rotas[] = "{$entidad['uid']}.proyecto_uid";
	}
	if ( 'proyecto' === $entidad['tipo'] && ! in_array( $datos['persona_uid'], $uids_personas, true ) ) {
		$rotas[] = "{$entidad['uid']}.persona_uid";
	}
	if ( ! in_array( $entidad['autor_uid'], $uids_personas, true ) ) {
		$rotas[] = "{$entidad['uid']}.autor_uid";
	}
}
$uids_tareas = array_column( $plan['tareas'], 'uid' );
foreach ( $uids_por_tipo['peticion'] as $indice => $uid_peticion ) {
	$peticion = array_values( array_filter( $plan['entidades'], static fn( $e ) => $e['uid'] === $uid_peticion ) )[0];
	if ( '' !== $peticion['datos']['tarea_uid'] && ! in_array( $peticion['datos']['tarea_uid'], $uids_tareas, true ) ) {
		$rotas[] = "{$uid_peticion}.tarea_uid";
	}
}
foreach ( $plan['tareas'] as $tarea ) {
	if ( '' !== $tarea['punto_uid'] && ! $existe( 'punto', $tarea['punto_uid'] ) ) {
		$rotas[] = "{$tarea['uid']}.punto_uid";
	}
	if ( '' !== $tarea['zona_uid'] && ! $existe( 'zona', $tarea['zona_uid'] ) ) {
		$rotas[] = "{$tarea['uid']}.zona_uid";
	}
	if ( ! $existe( 'finca', $tarea['finca_uid'] ) ) {
		$rotas[] = "{$tarea['uid']}.finca_uid";
	}
	if ( '' !== $tarea['responsable_uid'] && ! in_array( $tarea['responsable_uid'], $uids_personas, true ) ) {
		$rotas[] = "{$tarea['uid']}.responsable_uid";
	}
}
afirmar( array(), $rotas, 'todas las referencias apuntan a algo del plan' );

// ─── Cobertura de lo que hay que poder probar ───
$valores = static function ( string $tipo, string $campo ) use ( $plan ): array {
	$encontrados = array();
	foreach ( $plan['entidades'] as $entidad ) {
		if ( $tipo === $entidad['tipo'] ) {
			$encontrados[] = $entidad['datos'][ $campo ];
		}
	}
	$encontrados = array_values( array_unique( $encontrados ) );
	sort( $encontrados );
	return $encontrados;
};
$estados_tarea = array_values( array_unique( array_column( $plan['tareas'], 'estado' ) ) );
sort( $estados_tarea );
afirmar( array( 'bloqueada', 'en_curso', 'hecha', 'pendiente' ), $estados_tarea, 'tareas en los cuatro estados' );
afirmar( true, count( array_filter( $plan['tareas'], static fn( $t ) => null !== $t['recurrencia_dias'] ) ) > 0, 'hay tareas periódicas' );
afirmar( true, count( array_filter( $plan['tareas'], static fn( $t ) => '' === $t['responsable_uid'] ) ) > 0, 'hay tareas generales' );
afirmar( true, count( array_filter( $plan['tareas'], static fn( $t ) => 'hecha' !== $t['estado'] && null !== $t['fecha_objetivo_ms'] && $t['fecha_objetivo_ms'] < $ahora_ms ) ) > 0, 'hay tareas vencidas' );
afirmar( array( 'ganado', 'instalaciones', 'noticias', 'seguimiento' ), $valores( 'aviso', 'categoria' ), 'avisos de las cuatro categorías' );
afirmar( array( 'alarma', 'aviso' ), $valores( 'aviso', 'gravedad' ), 'alarmas y avisos' );
afirmar( array( 'aceptada', 'descartada', 'pendiente' ), $valores( 'peticion', 'estado' ), 'peticiones en los tres estados' );
afirmar( array( 'abierto', 'cerrado' ), $valores( 'proyecto', 'estado' ), 'proyectos abiertos y cerrados' );
afirmar( array( 'averiado', 'operativo', 'revisar' ), $valores( 'punto', 'estado' ), 'puntos en los tres estados' );
afirmar( true, in_array( 'corral_movil', $valores( 'punto', 'tipo' ), true ) && in_array( 'deposito_movil', $valores( 'punto', 'tipo' ), true ), 'hay infraestructuras móviles' );

// ─── Cada persona tester ve sus tareas y las generales, y su proyecto ───
$testers   = array_values( array_filter( $plan['personas'], static fn( $p ) => SZS_ROL_TESTER === $p['rol'] ) );
afirmar( 2, count( $testers ), 'dos personas tester' );
$proyectos = array_values( array_filter( $plan['entidades'], static fn( $e ) => 'proyecto' === $e['tipo'] ) );
foreach ( $testers as $tester ) {
	$capacidades = szs_capacidades_de_rol( SZS_ROL_TESTER );
	$suyas       = array_filter( $plan['tareas'], static fn( $t ) => $t['responsable_uid'] === $tester['uid'] );
	$visibles    = array_filter( $plan['tareas'], static fn( $t ) => szs_tarea_visible( $t, $tester['uid'], $capacidades ) );
	afirmar( true, count( $suyas ) > 0, "{$tester['nombre']} tiene tareas asignadas" );
	afirmar( true, count( $visibles ) > count( $suyas ), "{$tester['nombre']} ve además tareas generales" );
	$suyos = array_column( array_filter( $proyectos, static fn( $p ) => $p['datos']['persona_uid'] === $tester['uid'] ), 'uid' );
	afirmar( true, count( $suyos ) > 0, "{$tester['nombre']} tiene proyecto" );
	foreach ( $proyectos as $proyecto ) {
		$es_suyo = in_array( $proyecto['uid'], $suyos, true );
		afirmar( $es_suyo, szs_entidad_visible( szs_normalizar_entidad( $proyecto ), $tester['uid'], $capacidades, $suyos ), "{$tester['nombre']} ve solo sus proyectos ({$proyecto['datos']['nombre']})" );
	}
}

// ─── El nombre del responsable sale de la persona ───
foreach ( $plan['tareas'] as $tarea ) {
	if ( '' !== $tarea['responsable_uid'] ) {
		afirmar( array_column( $plan['personas'], 'nombre', 'uid' )[ $tarea['responsable_uid'] ], $tarea['responsable'], "responsable de {$tarea['titulo']}" );
	}
}

if ( $fallos > 0 ) {
	fwrite( STDERR, "\n{$fallos} test(s) fallidos.\n" );
	exit( 1 );
}
echo "Todos los tests de datos de demostración pasaron.\n";
