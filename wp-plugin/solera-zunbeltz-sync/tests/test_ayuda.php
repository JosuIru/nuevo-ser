<?php
/**
 * Tests de la lógica pura de la ayuda editable: claves, normalización de
 * lo cambiado, textos efectivos, marcas del manual y rutas. Sin WordPress.
 *
 * Ejecutar: php tests/test_ayuda.php
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

// --- claves ---
$claves = szs_claves_ayuda();
afirmar( true, in_array( 'ayudaZonasTesterB', $claves, true ), 'los apartados con versión tester tienen sus claves' );
afirmar( false, in_array( 'ayudaQueEsTesterB', $claves, true ), 'los demás no' );
afirmar( count( $claves ), count( array_unique( $claves ) ), 'sin claves repetidas' );
foreach ( array( 'es', 'eu' ) as $idioma ) {
	afirmar( array(), array_diff( $claves, array_keys( SZS_AYUDA_TEXTOS_DE_SERIE[ $idioma ] ) ), "todas las claves tienen texto de serie en {$idioma}" );
}

// --- clave válida (con mayúsculas, sin sanitize_key) ---
afirmar( 'ayudaQueEsT', szs_clave_ayuda_valida( 'ayudaQueEsT' ), 'una clave de texto vale tal cual' );
afirmar( 'ayudaZonas', szs_clave_ayuda_valida( 'ayudaZonas' ), 'un apartado del índice también' );
afirmar( 'ayudaGrupoFincas', szs_clave_ayuda_valida( 'ayudaGrupoFincas' ), 'y un grupo' );
afirmar( '', szs_clave_ayuda_valida( 'ayudaqueest' ), 'en minúsculas no es ninguna clave' );
afirmar( '', szs_clave_ayuda_valida( '<script>' ), 'basura fuera' );

// --- normalizar ---
$de_serie_es = SZS_AYUDA_TEXTOS_DE_SERIE['es']['ayudaQueEsT'];
$limpios     = szs_normalizar_textos_ayuda(
	array(
		'es' => array(
			'ayudaQueEsT' => "  Qué es Zunlanda \r\n",
			'ayudaPie'    => $de_serie_es === SZS_AYUDA_TEXTOS_DE_SERIE['es']['ayudaPie'] ? 'x' : SZS_AYUDA_TEXTOS_DE_SERIE['es']['ayudaPie'],
			'inventada'   => 'no',
			'ayudaIntro'  => '',
		),
		'fr' => array( 'ayudaQueEsT' => 'non' ),
		'eu' => 'mal',
	)
);
afirmar( array( 'es' => array( 'ayudaQueEsT' => 'Qué es Zunlanda' ) ), $limpios, 'solo claves conocidas, recortadas, distintas de serie y no vacías; solo es/eu' );
afirmar( array(), szs_normalizar_textos_ayuda( array() ), 'vacío sigue vacío' );

// --- efectivos ---
$efectivos = szs_textos_ayuda_efectivos( 'es', $limpios );
afirmar( 'Qué es Zunlanda', $efectivos['ayudaQueEsT'], 'lo cambiado pisa lo de serie' );
afirmar( SZS_AYUDA_TEXTOS_DE_SERIE['es']['ayudaPie'], $efectivos['ayudaPie'], 'lo no cambiado sigue de serie' );
afirmar( SZS_AYUDA_TEXTOS_DE_SERIE['eu']['ayudaQueEsT'], szs_textos_ayuda_efectivos( 'eu', $limpios )['ayudaQueEsT'], 'cada idioma lo suyo' );
afirmar( SZS_AYUDA_TEXTOS_DE_SERIE['es']['ayudaQueEsT'], szs_textos_ayuda_efectivos( 'fr', array() )['ayudaQueEsT'], 'idioma desconocido → castellano' );

// --- marcas del manual ---
$html = szs_manual_cuerpo_apartado( "Intro con <b>.\n1. Pulsa «Guardar».\n2. Listo\n• Una\n• Dos\n» Ojo con esto\n\nFin", 'Bueno saber' );
afirmar( true, str_contains( $html, '<p>Intro con &lt;b&gt;.</p>' ), 'párrafo escapado' );
afirmar( true, str_contains( $html, "<ol class=\"pasos\">\n<li>Pulsa <span class=\"ui\">Guardar</span>.</li>\n<li>Listo</li>\n</ol>" ), 'pasos seguidos en una lista, con «» resaltado' );
afirmar( true, str_contains( $html, "<ul>\n<li>Una</li>\n<li>Dos</li>\n</ul>" ), 'viñetas en una lista' );
afirmar( true, str_contains( $html, '<p class="nota"><b>Bueno saber.</b> Ojo con esto</p>' ), 'nota con su etiqueta' );
afirmar( true, str_ends_with( $html, '<p>Fin</p>' ), 'la línea vacía se salta y la última va sin salto' );

$manual = szs_manual_ayuda_html( 'es', szs_textos_ayuda_efectivos( 'es', $limpios ), '0.6.6', 'https://x/manual/', 'https://x/manual/eu/' );
afirmar( true, str_contains( $manual, '<h3><span class="n">1</span>Qué es Zunlanda</h3>' ), 'el manual usa el texto cambiado' );
afirmar( true, str_contains( $manual, 'Si eres persona tester: ' ), 'el manual imprime la versión para tester' );
afirmar( true, str_contains( $manual, 'versión 0.6.6' ), 'rotula la versión' );
afirmar( true, str_contains( $manual, 'href="https://x/manual/eu/"' ), 'enlaza al otro idioma' );
afirmar( true, str_contains( szs_manual_ayuda_html( 'eu', szs_textos_ayuda_efectivos( 'eu', array() ), '1', 'https://x/manual/', 'https://x/manual/eu/' ), 'Erabilera-eskuliburua' ), 'manual en euskera' );

// --- rutas ---
afirmar( array( 'servir', 'es' ), szs_accion_manual( '/manual/', '/manual' ), '/manual/ sirve el castellano' );
afirmar( array( 'servir', 'eu' ), szs_accion_manual( '/manual/eu/', '/manual' ), '/manual/eu/ el euskera' );
afirmar( array( 'redirigir', 'eu' ), szs_accion_manual( '/manual/eu', '/manual' ), 'sin barra final, redirige' );
afirmar( array( 'servir', 'es' ), szs_accion_manual( '/espacio/manual/index.html', '/espacio/manual' ), 'con WordPress en subcarpeta' );
afirmar( null, szs_accion_manual( '/manuales/', '/manual' ), 'otra ruta no es suya' );

if ( $fallos > 0 ) {
	fprintf( STDERR, "%d fallos\n", $fallos );
	exit( 1 );
}
echo "test_ayuda: OK\n";
