<?php
/**
 * Textos de la ayuda de la app, editables por coordinación en
 * **Solera Zunbeltz → Ayuda**.
 *
 * - Los de serie vienen de la app (`includes/textos-ayuda.php`, generado).
 * - Lo que coordinación cambia se guarda en la opción `szs_ayuda_textos`
 *   (idioma → clave → texto), solo las claves que difieren.
 * - La app los baja con `GET /solera-zunbeltz/v1/ayuda` (público) y los
 *   superpone por clave a los suyos.
 * - El manual imprimible se sirve en `/manual/` (castellano) y `/manual/eu/`
 *   con esos mismos textos, con las mismas marcas que la pantalla de ayuda:
 *   `1.` paso, `•` viñeta, `»` nota «Bueno saber», resto párrafo.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_OPCION_AYUDA_TEXTOS = 'szs_ayuda_textos';
const SZS_PAGINA_AYUDA        = 'solera-zunbeltz-ayuda';
const SZS_RUTA_MANUAL         = 'manual';
const SZS_IDIOMAS_AYUDA       = array( 'es', 'eu' );

add_action( 'rest_api_init', 'szs_registrar_ruta_ayuda' );
add_action( 'admin_menu', 'szs_registrar_pagina_ayuda', 13 );
add_action( 'init', 'szs_servir_manual', 0 );

// ============================================================
// Lógica pura (sin WordPress): probada en tests/test_ayuda.php
// ============================================================

/** Todas las claves de texto conocidas, en el orden del índice. */
function szs_claves_ayuda(): array {
	$claves = SZS_AYUDA_CLAVES_SUELTAS;
	foreach ( SZS_AYUDA_INDICE as $grupo => $apartados ) {
		$claves[] = $grupo;
		foreach ( $apartados as $apartado ) {
			$claves[] = $apartado . 'T';
			$claves[] = $apartado . 'B';
			if ( in_array( $apartado, SZS_AYUDA_CON_TESTER, true ) ) {
				$claves[] = $apartado . 'TesterT';
				$claves[] = $apartado . 'TesterB';
			}
		}
	}
	return $claves;
}

/**
 * Clave tal como llega (de la URL o del formulario), solo si es una clave
 * conocida de la ayuda o un apartado/grupo del índice. Las claves llevan
 * mayúsculas (`ayudaQueEsT`): no pasarlas por `sanitize_key`, que las
 * pondría en minúsculas y dejaría de reconocerlas.
 */
function szs_clave_ayuda_valida( string $clave ): string {
	$clave = trim( $clave );
	if ( 1 !== preg_match( '/^[A-Za-z0-9_]{1,80}$/', $clave ) ) {
		return '';
	}
	$apartados = array_merge( array_keys( SZS_AYUDA_INDICE ), ...array_values( SZS_AYUDA_INDICE ) );
	return in_array( $clave, szs_claves_ayuda(), true ) || in_array( $clave, $apartados, true ) ? $clave : '';
}

/**
 * Deja lo recibido (del formulario o de la opción) en forma: solo idiomas y
 * claves conocidas, texto recortado, y fuera lo vacío o igual al de serie.
 */
function szs_normalizar_textos_ayuda( array $recibidos ): array {
	$limpios  = array();
	$conocida = array_flip( szs_claves_ayuda() );
	foreach ( SZS_IDIOMAS_AYUDA as $idioma ) {
		$textos = $recibidos[ $idioma ] ?? null;
		if ( ! is_array( $textos ) ) {
			continue;
		}
		foreach ( $textos as $clave => $texto ) {
			if ( ! is_string( $texto ) || ! isset( $conocida[ $clave ] ) ) {
				continue;
			}
			$texto = trim( str_replace( "\r\n", "\n", $texto ) );
			if ( '' === $texto || $texto === ( SZS_AYUDA_TEXTOS_DE_SERIE[ $idioma ][ $clave ] ?? null ) ) {
				continue;
			}
			$limpios[ $idioma ][ $clave ] = $texto;
		}
	}
	return $limpios;
}

/** Los textos de un idioma con lo cambiado encima de lo de serie. */
function szs_textos_ayuda_efectivos( string $idioma, array $cambiados ): array {
	$de_serie = SZS_AYUDA_TEXTOS_DE_SERIE[ $idioma ] ?? SZS_AYUDA_TEXTOS_DE_SERIE['es'];
	return array_merge( $de_serie, $cambiados[ $idioma ] ?? array() );
}

/** Escapa y resalta lo que va entre «» (nombres de botones de la app). */
function szs_manual_con_etiquetas( string $texto ): string {
	$escapado = htmlspecialchars( $texto, ENT_QUOTES, 'UTF-8' );
	return (string) preg_replace( '/«([^»]+)»/u', '<span class="ui">$1</span>', $escapado );
}

/**
 * El cuerpo de un apartado en HTML, con las marcas de la pantalla de
 * ayuda. Pasos y viñetas seguidos se agrupan en una sola lista.
 */
function szs_manual_cuerpo_apartado( string $cuerpo, string $etiqueta_nota ): string {
	$salida  = '';
	$abierta = null;
	$cerrar  = static function () use ( &$salida, &$abierta ): void {
		if ( null !== $abierta ) {
			$salida .= "</{$abierta}>\n";
		}
		$abierta = null;
	};
	$abrir = static function ( string $etiqueta, string $atributos = '' ) use ( &$salida, &$abierta, $cerrar ): void {
		if ( $abierta === $etiqueta ) {
			return;
		}
		$cerrar();
		$salida .= "<{$etiqueta}{$atributos}>\n";
		$abierta = $etiqueta;
	};
	foreach ( explode( "\n", $cuerpo ) as $linea ) {
		$texto = trim( $linea );
		if ( '' === $texto ) {
			continue;
		}
		if ( preg_match( '/^(\d+)\.\s+(.*)$/u', $texto, $paso ) ) {
			$abrir( 'ol', ' class="pasos"' );
			$salida .= '<li>' . szs_manual_con_etiquetas( $paso[2] ) . "</li>\n";
		} elseif ( str_starts_with( $texto, '•' ) ) {
			$abrir( 'ul' );
			$salida .= '<li>' . szs_manual_con_etiquetas( trim( mb_substr( $texto, 1 ) ) ) . "</li>\n";
		} elseif ( str_starts_with( $texto, '»' ) ) {
			$cerrar();
			$salida .= '<p class="nota"><b>' . htmlspecialchars( $etiqueta_nota, ENT_QUOTES, 'UTF-8' ) . '.</b> ' . szs_manual_con_etiquetas( trim( mb_substr( $texto, 1 ) ) ) . "</p>\n";
		} else {
			$cerrar();
			$salida .= '<p>' . szs_manual_con_etiquetas( $texto ) . "</p>\n";
		}
	}
	$cerrar();
	return rtrim( $salida );
}

/** Rótulos propios del manual (no están en la ayuda de la app). */
function szs_rotulos_manual( string $idioma ): array {
	if ( 'eu' === $idioma ) {
		return array(
			'titulo_pagina' => 'Larrea Zunbeltz — Erabilera-eskuliburua',
			'titulo'        => 'Erabilera-eskuliburua',
			'version'       => 'Larrea Zunbeltz · %s bertsioa',
			'imprimir'      => 'Inprimatu / Gorde PDF gisa',
			'otro_idioma'   => 'En castellano',
			'indice'        => 'Edukia',
			'aviso'         => 'Aurretiazko bertsioa',
			'pie'           => 'Eskuliburu hau app-aren laguntzatik sortzen da, koordinazioak egindako aldaketekin, beraz biek gauza bera diote.',
		);
	}
	return array(
		'titulo_pagina' => 'Larrea Zunbeltz — Manual de uso',
		'titulo'        => 'Manual de uso',
		'version'       => 'Larrea Zunbeltz · versión %s',
		'imprimir'      => 'Imprimir / Guardar PDF',
		'otro_idioma'   => 'Euskaraz',
		'indice'        => 'Contenido',
		'aviso'         => 'Versión preliminar',
		'pie'           => 'Este manual se genera a partir de la ayuda de la propia app, con los cambios hechos por coordinación, así que ambos dicen lo mismo.',
	);
}

/**
 * El manual entero en HTML. Pura: recibe los textos ya efectivos, la
 * versión que rotular y las direcciones de los dos idiomas.
 */
function szs_manual_ayuda_html( string $idioma, array $textos, string $version, string $url_es, string $url_eu ): string {
	$r      = szs_rotulos_manual( $idioma );
	$e      = static fn( string $t ): string => htmlspecialchars( $t, ENT_QUOTES, 'UTF-8' );
	$indice = '';
	$cuerpo = '';
	$numero = 0;
	foreach ( SZS_AYUDA_INDICE as $grupo => $apartados ) {
		$titulo_grupo = $e( $textos[ $grupo ] ?? $grupo );
		$indice      .= "<li><span class=\"grupo-indice\">{$titulo_grupo}</span><ol>\n";
		$cuerpo      .= "<h2>{$titulo_grupo}</h2>\n";
		foreach ( $apartados as $clave ) {
			$numero++;
			$ancla   = "a{$numero}";
			$titulo  = $e( $textos[ $clave . 'T' ] ?? $clave );
			$indice .= "<li><a href=\"#{$ancla}\">{$titulo}</a></li>\n";
			$cuerpo .= "<section id=\"{$ancla}\">\n<h3><span class=\"n\">{$numero}</span>{$titulo}</h3>\n"
				. szs_manual_cuerpo_apartado( $textos[ $clave . 'B' ] ?? '', $textos['ayudaConsejo'] ?? '' ) . "\n";
			if ( in_array( $clave, SZS_AYUDA_CON_TESTER, true ) ) {
				$cuerpo .= '<h4>' . $e( $textos['ayudaManualTester'] ?? '' ) . ': ' . $e( $textos[ $clave . 'TesterT' ] ?? '' ) . "</h4>\n"
					. szs_manual_cuerpo_apartado( $textos[ $clave . 'TesterB' ] ?? '', $textos['ayudaConsejo'] ?? '' ) . "\n";
			}
			$cuerpo .= "</section>\n";
		}
		$indice .= "</ol></li>\n";
	}
	$intro     = explode( '.', (string) ( $textos['ayudaIntro'] ?? '' ) )[0];
	$otro_url  = 'eu' === $idioma ? $url_es : $url_eu;
	$estilos   = szs_estilos_manual();
	$version_r = $e( sprintf( $r['version'], $version ) );
	return <<<HTML
<!DOCTYPE html>
<html lang="{$idioma}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{$e( $r['titulo_pagina'] )}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@500;600;700&family=Spectral:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
<style>
{$estilos}
</style>
</head>
<body>
<div class="barra">
  <a href="{$e( $otro_url )}">{$e( $r['otro_idioma'] )} →</a>
  <button onclick="window.print()">{$e( $r['imprimir'] )}</button>
</div>
<main class="hoja">
  <header class="cab">
    <h1>{$e( $r['titulo'] )}</h1>
    <p class="sub">{$version_r}</p>
  </header>
  <div class="cuerpo">
    <p class="intro">{$e( $intro )}.</p>
    <nav class="indice">
      <h2>{$e( $r['indice'] )}</h2>
      <ol>
{$indice}
      </ol>
    </nav>
{$cuerpo}
    <aside class="aviso">
      <b>{$e( $r['aviso'] )}.</b> {$e( $textos['ajustesProvisional'] ?? '' )}
      {$e( $textos['meteoOrientativo'] ?? '' )}
    </aside>
    <p class="final">{$e( $textos['ayudaPie'] ?? '' )}</p>
  </div>
  <footer class="pie">{$e( $r['pie'] )}</footer>
</main>
</body>
</html>
HTML;
}

/** Misma dirección visual que el manual generado por la app. */
function szs_estilos_manual(): string {
	return <<<CSS
:root{
  --papel:#E9EBE2; --papel-hundido:#DFE2D6; --monte:#1B2320; --senal:#B8402A;
  --pasto:#5E7D3A; --tinta:#171D19; --tinta-apagada:#6C7870; --linea:rgba(27,35,32,.17);
  --titular:"Archivo",system-ui,sans-serif; --texto:"Spectral",Georgia,serif;
}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--texto);font-size:17px;line-height:1.6;color:var(--tinta);background:#D3D7CB;padding:20px 16px 40px}
.barra{max-width:780px;margin:0 auto 12px;display:flex;justify-content:space-between;align-items:center;gap:12px;font-family:var(--titular);font-size:14px}
.barra a{color:var(--monte);font-weight:600}
.barra button{font:600 14px var(--titular);background:var(--monte);color:var(--papel);border:0;border-radius:4px;padding:9px 16px;cursor:pointer}
.hoja{max-width:780px;margin:0 auto;background:var(--papel);border:1px solid var(--linea);border-radius:4px;overflow:hidden}
.cab{background:var(--monte);color:var(--papel);padding:32px 40px 26px}
.cab h1{font:700 2rem/1.1 var(--titular);letter-spacing:-.02em;display:inline-block;padding-bottom:6px;border-bottom:3px solid var(--senal)}
.cab .sub{font-family:var(--titular);font-size:14px;opacity:.75;margin-top:10px}
.cuerpo{padding:28px 40px 12px}
.intro{font-size:1.08rem;color:var(--tinta)}
h2{font:700 1.3rem/1.2 var(--titular);letter-spacing:-.01em;color:var(--monte);margin:34px 0 4px;padding-bottom:6px;border-bottom:1px solid var(--linea)}
h3{font:600 1.08rem/1.3 var(--titular);color:var(--monte);margin:22px 0 4px;display:flex;align-items:baseline;gap:10px}
h3 .n{font-size:.85rem;color:var(--senal);min-width:1.4em}
h4{font:600 .95rem/1.3 var(--titular);color:var(--senal);margin:18px 0 2px}
section p{margin:6px 0}
section ul,section ol{margin:6px 0 6px 0;padding-left:1.4em}
section li{margin:5px 0}
ol.pasos{list-style:none;padding-left:0;counter-reset:paso}
ol.pasos li{counter-increment:paso;position:relative;padding-left:34px}
ol.pasos li::before{content:counter(paso);position:absolute;left:0;top:2px;width:22px;height:22px;display:grid;place-items:center;background:var(--monte);color:var(--papel);font:700 12px var(--titular);border-radius:4px}
section ul li::marker{color:var(--pasto)}
.ui{font-family:var(--titular);font-weight:600;font-size:.92em;white-space:nowrap;background:var(--papel-hundido);border:1px solid var(--linea);border-radius:4px;padding:0 5px}
.nota{background:var(--papel-hundido);border-left:3px solid var(--senal);padding:10px 14px;margin:10px 0!important;font-size:.95rem}
.nota b{font-family:var(--titular);color:var(--senal)}
.indice{margin-top:10px}
.indice>ol{list-style:none;columns:2;column-gap:32px;margin-top:10px}
.indice>ol>li{break-inside:avoid;margin-bottom:12px}
.grupo-indice{font:600 .95rem var(--titular);color:var(--monte)}
.indice ol ol{list-style:none;padding-left:0;margin-top:2px}
.indice ol ol li{font-size:.95rem;margin:1px 0}
.indice a{color:var(--tinta);text-decoration:none;border-bottom:1px solid var(--linea)}
.indice a:hover{color:var(--senal)}
.aviso{margin:36px 0 8px;padding:14px 16px;border:1px solid var(--linea);border-radius:4px;font-size:.93rem;color:var(--tinta-apagada)}
.aviso b{font-family:var(--titular);color:var(--monte)}
.final{margin:14px 0 18px;font-style:italic}
.pie{background:var(--monte);color:rgba(233,235,226,.72);font:13px/1.55 var(--titular);padding:16px 40px}
@media(max-width:640px){
  body{padding:12px 0 24px;font-size:16px}
  .barra{padding:0 16px}
  .hoja{border-left:0;border-right:0;border-radius:0}
  .cab,.cuerpo,.pie{padding-left:16px;padding-right:16px}
  .indice>ol{columns:1}
  .ui{white-space:normal}
}
@media print{
  body{background:#fff;padding:0;font-size:11pt}
  .barra{display:none}
  .hoja{border:0;max-width:none}
  .cab,.nota,ol.pasos li::before,.pie{-webkit-print-color-adjust:exact;print-color-adjust:exact}
  section{break-inside:avoid}
  h2{break-after:avoid}
  @page{margin:14mm}
}
CSS;
}

/**
 * Qué hacer con una ruta del manual: `['servir', idioma]`, `['redirigir',
 * idioma]` (sin barra final) o null si no es suya. Pura.
 */
function szs_accion_manual( string $ruta, string $base ): ?array {
	foreach ( array( 'es' => $base, 'eu' => $base . '/eu' ) as $idioma => $prefijo ) {
		if ( $ruta === $prefijo ) {
			return array( 'redirigir', $idioma );
		}
		if ( $ruta === $prefijo . '/' || $ruta === $prefijo . '/index.html' ) {
			return array( 'servir', $idioma );
		}
	}
	return null;
}

// ============================================================
// Con WordPress
// ============================================================

/** Lo cambiado en el panel (idioma → clave → texto). */
function szs_textos_ayuda_cambiados(): array {
	$guardado = get_option( SZS_OPCION_AYUDA_TEXTOS, null );
	return is_array( $guardado ) ? szs_normalizar_textos_ayuda( $guardado ) : array();
}

function szs_guardar_textos_ayuda( array $cambiados ): void {
	update_option( SZS_OPCION_AYUDA_TEXTOS, szs_normalizar_textos_ayuda( $cambiados ), false );
}

function szs_url_manual( string $idioma = 'es' ): string {
	return home_url( '/' . SZS_RUTA_MANUAL . ( 'eu' === $idioma ? '/eu/' : '/' ) );
}

function szs_registrar_ruta_ayuda(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/ayuda',
		array(
			'methods'             => 'GET',
			'callback'            => 'szs_endpoint_ayuda',
			// Público: es la ayuda que ya se lee en el manual.
			'permission_callback' => '__return_true',
		)
	);
}

function szs_endpoint_ayuda() {
	return new WP_REST_Response( array( 'textos' => (object) szs_textos_ayuda_cambiados() ), 200 );
}

function szs_servir_manual(): void {
	$ruta   = (string) wp_parse_url( (string) ( $_SERVER['REQUEST_URI'] ?? '' ), PHP_URL_PATH );
	$base   = rtrim( (string) wp_parse_url( home_url( '/' ), PHP_URL_PATH ), '/' ) . '/' . SZS_RUTA_MANUAL;
	$accion = szs_accion_manual( $ruta, $base );
	if ( null === $accion ) {
		return;
	}
	list( $que, $idioma ) = $accion;
	if ( 'redirigir' === $que ) {
		wp_safe_redirect( szs_url_manual( $idioma ), 301 );
		exit;
	}
	$html = szs_manual_ayuda_html( $idioma, szs_textos_ayuda_efectivos( $idioma, szs_textos_ayuda_cambiados() ), szs_version_app_web_rotulo(), szs_url_manual( 'es' ), szs_url_manual( 'eu' ) );
	status_header( 200 );
	header( 'Content-Type: text/html; charset=utf-8' );
	header( 'Cache-Control: no-cache' );
	header( 'X-Content-Type-Options: nosniff' );
	echo $html; // phpcs:ignore WordPress.Security.EscapeOutput -- HTML compuesto escapando cada texto.
	exit;
}

/** Versión que rotula el manual: la de la app web si está, si no la del plugin. */
function szs_version_app_web_rotulo(): string {
	if ( function_exists( 'szs_version_app_web' ) ) {
		$version = (string) szs_version_app_web();
		if ( '' !== $version ) {
			return $version;
		}
	}
	return SZS_VERSION;
}

// ============================================================
// Panel · Ayuda
// ============================================================

function szs_registrar_pagina_ayuda(): void {
	add_submenu_page( SZS_PAGINA_INICIO, szs_t( 'Ayuda de la app' ), szs_t( 'Ayuda de la app' ), SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_AYUDA, 'szs_pagina_ayuda' );
}

function szs_procesar_formulario_ayuda(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_ayuda' );
	$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	if ( 'restaurar_todo' === $accion ) {
		delete_option( SZS_OPCION_AYUDA_TEXTOS );
		return array( 'success', szs_t( 'Vuelven todos los textos de serie de la app.' ) );
	}
	if ( 'guardar' !== $accion ) {
		return null;
	}
	$recibidos = isset( $_POST['szs_texto'] ) && is_array( $_POST['szs_texto'] ) ? wp_unslash( $_POST['szs_texto'] ) : array(); // phpcs:ignore WordPress.Security.ValidatedSanitizedInput -- se normaliza clave a clave.
	$cambiados = szs_textos_ayuda_cambiados();
	foreach ( SZS_IDIOMAS_AYUDA as $idioma ) {
		foreach ( (array) ( $recibidos[ $idioma ] ?? array() ) as $clave => $texto ) {
			$clave = szs_clave_ayuda_valida( (string) $clave );
			if ( '' === $clave ) {
				continue;
			}
			$cambiados[ $idioma ][ $clave ] = sanitize_textarea_field( (string) $texto );
		}
	}
	szs_guardar_textos_ayuda( $cambiados );
	return array( 'success', szs_t( 'Guardado. El manual lo enseña ya; la app, la próxima vez que se abra con conexión (como mucho en 6 horas).' ) );
}

function szs_pagina_ayuda(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso     = szs_procesar_formulario_ayuda();
	$cambiados = szs_textos_ayuda_cambiados();
	$apartado  = szs_clave_ayuda_valida( szs_campo_get( 'apartado' ) );
	$n_cambiados = count( $cambiados['es'] ?? array() ) + count( $cambiados['eu'] ?? array() );
	?>
	<div class="wrap">
		<h1><?php echo esc_html( szs_t( 'Ayuda de la app' ) ); ?></h1>
		<p><?php echo szs_t( 'Los textos de la pantalla de Ayuda de la app y del manual imprimible. Lo que cambies aquí lo bajan los móviles al abrir la app y lo enseña el manual al momento. Las marcas al principio de cada línea mandan en cómo se pinta: <code>1.</code> paso numerado, <code>•</code> viñeta, <code>»</code> nota «Bueno saber»; lo demás, párrafo. Lo que va entre «comillas latinas» se resalta como nombre de botón.' ); ?></p>
		<p>
			<a class="button" href="<?php echo esc_url( szs_url_manual( 'es' ) ); ?>" target="_blank"><?php echo esc_html( szs_t( 'Ver el manual (castellano)' ) ); ?></a>
			<a class="button" href="<?php echo esc_url( szs_url_manual( 'eu' ) ); ?>" target="_blank">Eskuliburua (euskaraz)</a>
			<?php if ( $n_cambiados > 0 ) : ?>
				<span class="description"><?php echo esc_html( szs_t( 'Textos cambiados respecto a la app: %d.', $n_cambiados ) ); ?></span>
			<?php endif; ?>
		</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<?php if ( '' === $apartado ) : ?>
			<table class="widefat striped" style="max-width:900px;">
				<thead><tr><th><?php echo esc_html( szs_t( 'Apartado' ) ); ?></th><th><?php echo esc_html( szs_t( 'Cambiado' ) ); ?></th><th></th></tr></thead>
				<tbody>
				<?php foreach ( SZS_AYUDA_INDICE as $grupo => $apartados ) : ?>
					<tr>
						<td><strong><?php echo esc_html( szs_textos_ayuda_efectivos( szs_idioma_panel(), $cambiados )[ $grupo ] ?? $grupo ); ?></strong></td>
						<td><?php echo isset( $cambiados['es'][ $grupo ] ) || isset( $cambiados['eu'][ $grupo ] ) ? esc_html( szs_t( 'sí' ) ) : ''; ?></td>
						<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_AYUDA, array( 'apartado' => $grupo ) ) ); ?>"><?php echo esc_html( szs_t( 'Editar el nombre del grupo' ) ); ?></a></td>
					</tr>
					<?php foreach ( $apartados as $clave ) : ?>
						<?php
						$tocado = false;
						foreach ( array( 'T', 'B', 'TesterT', 'TesterB' ) as $sufijo ) {
							$tocado = $tocado || isset( $cambiados['es'][ $clave . $sufijo ] ) || isset( $cambiados['eu'][ $clave . $sufijo ] );
						}
						?>
						<tr>
							<td style="padding-left:28px;"><?php echo esc_html( szs_textos_ayuda_efectivos( szs_idioma_panel(), $cambiados )[ $clave . 'T' ] ?? $clave ); ?></td>
							<td><?php echo $tocado ? esc_html( szs_t( 'sí' ) ) : ''; ?></td>
							<td><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_AYUDA, array( 'apartado' => $clave ) ) ); ?>"><?php echo esc_html( szs_t( 'Editar' ) ); ?></a></td>
						</tr>
					<?php endforeach; ?>
				<?php endforeach; ?>
				</tbody>
			</table>
			<form method="post" style="margin-top:16px;" onsubmit="return confirm('<?php echo esc_js( szs_t( '¿Volver a los textos de serie de la app en todos los apartados?' ) ); ?>');">
				<?php wp_nonce_field( 'szs_ayuda' ); ?>
				<input type="hidden" name="szs_accion" value="restaurar_todo">
				<?php submit_button( szs_t( 'Volver a los textos de serie en todo' ), 'secondary', 'submit', false ); ?>
			</form>
		<?php else : ?>
			<?php
			$es_grupo = isset( SZS_AYUDA_INDICE[ $apartado ] );
			$campos   = $es_grupo
				? array( '' => szs_t( 'Nombre del grupo' ) )
				: array( 'T' => szs_t( 'Título' ), 'B' => szs_t( 'Texto' ) );
			if ( ! $es_grupo && in_array( $apartado, SZS_AYUDA_CON_TESTER, true ) ) {
				$campos['TesterT'] = szs_t( 'Título para personas tester' );
				$campos['TesterB'] = szs_t( 'Texto para personas tester' );
			}
			?>
			<p><a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_AYUDA ) ); ?>"><?php echo esc_html( szs_t( '← Todos los apartados' ) ); ?></a></p>
			<form method="post">
				<?php wp_nonce_field( 'szs_ayuda' ); ?>
				<input type="hidden" name="szs_accion" value="guardar">
				<?php foreach ( SZS_IDIOMAS_AYUDA as $idioma ) : ?>
					<h2><?php echo esc_html( 'eu' === $idioma ? szs_t( 'Euskera' ) : szs_t( 'Castellano' ) ); ?></h2>
					<table class="form-table" role="presentation">
						<?php foreach ( $campos as $sufijo => $rotulo ) : ?>
							<?php
							$clave    = $apartado . $sufijo;
							$de_serie = SZS_AYUDA_TEXTOS_DE_SERIE[ $idioma ][ $clave ] ?? '';
							$actual   = $cambiados[ $idioma ][ $clave ] ?? $de_serie;
							$id       = 'szs_' . $idioma . '_' . $clave;
							$largo    = str_ends_with( $sufijo, 'B' );
							?>
							<tr>
								<th><label for="<?php echo esc_attr( $id ); ?>"><?php echo esc_html( $rotulo ); ?></label></th>
								<td>
									<?php if ( $largo ) : ?>
										<textarea id="<?php echo esc_attr( $id ); ?>" name="szs_texto[<?php echo esc_attr( $idioma ); ?>][<?php echo esc_attr( $clave ); ?>]" rows="12" class="large-text" style="font-family:monospace;"><?php echo esc_textarea( $actual ); ?></textarea>
									<?php else : ?>
										<input type="text" id="<?php echo esc_attr( $id ); ?>" name="szs_texto[<?php echo esc_attr( $idioma ); ?>][<?php echo esc_attr( $clave ); ?>]" class="large-text" value="<?php echo esc_attr( $actual ); ?>">
									<?php endif; ?>
									<?php if ( isset( $cambiados[ $idioma ][ $clave ] ) ) : ?>
										<p class="description"><?php echo esc_html( szs_t( 'Cambiado respecto a la app. Para volver al de serie, déjalo vacío y guarda.' ) ); ?></p>
										<details><summary><?php echo esc_html( szs_t( 'Texto de serie' ) ); ?></summary><pre style="white-space:pre-wrap;"><?php echo esc_html( $de_serie ); ?></pre></details>
									<?php endif; ?>
								</td>
							</tr>
						<?php endforeach; ?>
					</table>
				<?php endforeach; ?>
				<?php submit_button( szs_t( 'Guardar' ) ); ?>
			</form>
		<?php endif; ?>
	</div>
	<?php
}
