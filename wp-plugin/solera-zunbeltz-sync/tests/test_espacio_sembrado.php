<?php
/**
 * Tests del plan que pone al día en el servidor las zonas y puntos que
 * sembró la app (`szs_plan_espacio_sembrado`): corrige lo que nadie ha
 * tocado, añade lo nuevo si su finca está, retira lo que ya no se siembra
 * y no pisa nunca lo editado por una persona. Sin WordPress.
 *
 * Ejecutar: php tests/test_espacio_sembrado.php
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

$ahora_ms = 1_792_108_800_000; // 2026-10-16 00:00 UTC

function zona_sembrada( string $uid, string $nombre ): array {
	return array(
		'tipo'  => 'zona',
		'uid'   => $uid,
		'datos' => array( 'nombre' => $nombre, 'color' => 'violeta', 'finca_uid' => 'finca-zunbeltz' ),
	);
}

function en_servidor( string $uid, string $nombre, int $actualizado_ms, bool $borrado = false ): array {
	return array(
		'tipo'           => 'zona',
		'uid'            => $uid,
		'actualizado_ms' => $actualizado_ms,
		'borrado'        => $borrado,
		'proyecto_uid'   => '',
		'autor_uid'      => 'persona-josu',
		'datos'          => array( 'nombre' => $nombre, 'color' => 'violeta', 'finca_uid' => 'finca-zunbeltz', 'fecha_creacion_ms' => 123 ),
	);
}

$sembrado = array(
	'entidades' => array(
		zona_sembrada( 'zona-intacta', 'Parque de cerdos 1' ),
		zona_sembrada( 'zona-editada', 'Los Avellanos' ),
		zona_sembrada( 'zona-corregida-antes', 'Pasillo' ),
		zona_sembrada( 'zona-igual', 'Enfermería' ),
		zona_sembrada( 'zona-nueva', 'Parque de cerdos 2' ),
		zona_sembrada( 'zona-borrada', 'Pieza sin nombre A (norte)' ),
		array(
			'tipo'  => 'zona',
			'uid'   => 'zona-de-otra-finca',
			'datos' => array( 'nombre' => 'Prado', 'finca_uid' => 'finca-la-planilla' ),
		),
	),
	'retiradas' => array(
		array( 'tipo' => 'zona', 'uid' => 'zona-monte-intacta' ),
		array( 'tipo' => 'zona', 'uid' => 'zona-monte-editada' ),
		array( 'tipo' => 'zona', 'uid' => 'zona-que-no-esta' ),
	),
);
$existentes = array(
	'zona:zona-intacta'         => en_servidor( 'zona-intacta', 'Parques (por confirmar)', 1 ),
	'zona:zona-editada'         => en_servidor( 'zona-editada', 'Mis avellanos', 1_792_000_000_000 ),
	'zona:zona-corregida-antes' => en_servidor( 'zona-corregida-antes', 'Zona verde', 1_791_900_000_000 ),
	'zona:zona-igual'           => en_servidor( 'zona-igual', 'Enfermería', 1 ),
	'zona:zona-borrada'         => en_servidor( 'zona-borrada', 'Monte', 1_792_000_000_000, true ),
	'zona:zona-monte-intacta'   => en_servidor( 'zona-monte-intacta', 'Monte (norte)', 1 ),
	'zona:zona-monte-editada'   => en_servidor( 'zona-monte-editada', 'Monte (sur)', 1_792_000_000_000 ),
);
$marcas = array( 'zona-corregida-antes' => 1_791_900_000_000 );

$plan    = szs_plan_espacio_sembrado( $sembrado, $existentes, array( 'finca-zunbeltz' ), $marcas, $ahora_ms );
$por_uid = array();
foreach ( $plan as $paso ) {
	$por_uid[ $paso['entidad']['uid'] ] = $paso;
}

afirmar(
	array( 'zona-intacta', 'zona-corregida-antes', 'zona-nueva', 'zona-monte-intacta' ),
	array_keys( $por_uid ),
	'solo lo intacto, lo corregido por el plugin, lo nuevo con finca y lo retirado intacto'
);

$intacta = $por_uid['zona-intacta']['entidad'];
afirmar( 'Parque de cerdos 1', $intacta['datos']['nombre'], 'lo intacto toma los datos sembrados' );
afirmar( 123, $intacta['datos']['fecha_creacion_ms'], 'conserva la fecha de alta del servidor' );
afirmar( $ahora_ms, $intacta['actualizado_ms'], 'con marca de ahora, para que llegue a los móviles' );
afirmar( false, $intacta['borrado'], 'no se borra' );
afirmar( 'persona-josu', $intacta['autor_uid'], 'conserva quién la creó' );
afirmar( $existentes['zona:zona-intacta'], $por_uid['zona-intacta']['existente'], 'lleva la versión anterior para guardarla' );

afirmar( 'Pasillo', $por_uid['zona-corregida-antes']['entidad']['datos']['nombre'], 'lo que corrigió antes el plugin se sigue corrigiendo' );

$nueva = $por_uid['zona-nueva'];
afirmar( null, $nueva['existente'], 'lo nuevo se crea' );
afirmar( 'Parque de cerdos 2', $nueva['entidad']['datos']['nombre'], 'con sus datos' );
afirmar( '', $nueva['entidad']['autor_uid'], 'sin autor' );
afirmar( $ahora_ms, $nueva['entidad']['datos']['fecha_creacion_ms'], 'con fecha de alta de ahora' );

$retirada = $por_uid['zona-monte-intacta']['entidad'];
afirmar( true, $retirada['borrado'], 'lo retirado e intacto queda como lápida' );
afirmar( $ahora_ms, $retirada['actualizado_ms'], 'lápida con marca de ahora' );

afirmar( false, isset( $por_uid['zona-editada'] ), 'lo editado por una persona no se toca' );
afirmar( false, isset( $por_uid['zona-igual'] ), 'si ya está igual no se reescribe' );
afirmar( false, isset( $por_uid['zona-borrada'] ), 'lo borrado no resucita' );
afirmar( false, isset( $por_uid['zona-de-otra-finca'] ), 'sin su finca en el servidor no se crea' );
afirmar( false, isset( $por_uid['zona-monte-editada'] ), 'lo retirado pero editado se queda' );

// Las marcas que deja: las de lo que ha escrito.
afirmar(
	array(
		'zona-corregida-antes' => $ahora_ms,
		'zona-intacta'         => $ahora_ms,
		'zona-nueva'           => $ahora_ms,
		'zona-monte-intacta'   => $ahora_ms,
	),
	szs_marcas_tras_plan( $marcas, $plan ),
	'recuerda la marca de cada cosa que escribe'
);

// Lo que lleva el plugin, generado por la app.
$espacio = json_decode( szs_espacio_sembrado_json(), true );
afirmar( true, is_array( $espacio ) && count( $espacio['entidades'] ) > 20, 'el fichero generado se lee' );
$nombres = array_column( array_column( $espacio['entidades'], 'datos' ), 'nombre' );
afirmar( true, in_array( 'Parque de cerdos 1', $nombres, true ) && in_array( 'Los Avellanos', $nombres, true ), 'lleva los nombres de Zunbeltz' );
afirmar( false, in_array( 'Monte (norte)', $nombres, true ), 'no siembra lo retirado' );
afirmar( true, in_array( 'zona-zunbeltz-monte-norte', array_column( $espacio['retiradas'], 'uid' ), true ), 'retira el monte antiguo' );
// Con todo intacto y sin nada en el servidor salvo las fincas, se crea todo.
$plan_vacio = szs_plan_espacio_sembrado( $espacio, array(), array( 'finca-zunbeltz', 'finca-la-planilla' ), array(), $ahora_ms );
afirmar( count( $espacio['entidades'] ), count( $plan_vacio ), 'en un servidor con las fincas y nada más, crea todo lo sembrado' );
afirmar( array(), szs_plan_espacio_sembrado( $espacio, array(), array(), array(), $ahora_ms ), 'sin las fincas, nada' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallo(s)\n", $fallos );
	exit( 1 );
}
echo "test_espacio_sembrado: OK\n";
