<?php
/**
 * Logos de las entidades que impulsan, apoyan y colaboran con el espacio
 * (los del pie de zunbeltz.com), editables por coordinación en
 * **Solera Zunbeltz → Entidades y logos**.
 *
 * - Se guardan en una opción (`szs_logos_entidades`): son pocas y no se
 *   sincronizan como entidades. Mientras nadie la edite, vale la lista de
 *   partida de [szs_logos_entidades_por_defecto].
 * - Cada entidad usa su logo de partida (`assets/logos/<clave>.png`, el
 *   mismo que lleva la app dentro) o uno subido a la biblioteca de medios.
 * - `GET /solera-zunbeltz/v1/entidades` es público: la app los baja de ahí
 *   (y la demo web, que no tiene sesión). Con `logo_propio = false` la app
 *   usa su copia empaquetada y los enseña sin cobertura.
 * - En la web los pinta el bloque «Entidades y logos»
 *   (`solera-zunbeltz/entidades`), que el pie del tema `zunbeltz-espacio`
 *   lleva puesto, o el shortcode `[solera_zunbeltz_entidades]` dentro de
 *   una página. El pie necesita el bloque: en un tema de bloques los
 *   shortcodes de las partes de plantilla no se procesan.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_OPCION_LOGOS_ENTIDADES = 'szs_logos_entidades';
const SZS_PAGINA_LOGOS_ENTIDADES = 'solera-zunbeltz-entidades';
/** Grupos del pie de zunbeltz.com, en su orden, con su rótulo es / eu. */
const SZS_GRUPOS_LOGOS = array(
	'financian'  => array( 'Financian el proyecto', 'Proiektuaren finantzatzaileak' ),
	'impulsan'   => array( 'Impulsan el proyecto', 'Proiektuaren bultzatzaileak' ),
	'apoyan'     => array( 'Apoyan el proyecto', 'Proiektuaren babesleak' ),
	'colaboran'  => array( 'Colaboran', 'Laguntzaileak' ),
	'miembro_de' => array( 'Miembro de', 'Sareko kide' ),
);

add_action( 'rest_api_init', 'szs_registrar_ruta_logos_entidades' );
add_action( 'admin_menu', 'szs_registrar_pagina_logos_entidades', 13 );
add_action( 'admin_enqueue_scripts', 'szs_cargar_selector_medios_logos' );
add_action( 'init', 'szs_registrar_bloque_logos_entidades' );
add_action( 'plugins_loaded', 'szs_mover_financiadoras_una_vez' );
// Al cargar el fichero y no en `init`: los patrones del tema se evalúan en
// `init` y comprueban si el shortcode existe.
if ( function_exists( 'add_shortcode' ) ) {
	add_shortcode( 'solera_zunbeltz_entidades', 'szs_shortcode_logos_entidades' );
}

// ============================================================
// Lógica pura (sin WordPress): probada en tests/test_logos_entidades.php
// ============================================================

/** La lista de partida: la del pie de zunbeltz.com el 2026-10-13. */
function szs_logos_entidades_por_defecto(): array {
	$por_grupo = array(
		// Las que financian (Zunbeltz, 2026-10-16), con su logo oficial.
		'financian'  => array(
			'carasso'          => 'Fundación Daniel y Nina Carasso',
			'gobierno_navarra' => 'Gobierno de Navarra',
		),
		'impulsan'   => array(
			'andia'    => 'Mancomunidad de Andía',
			'abarzuza' => 'Ayuntamiento de Abárzuza',
			'lezaun'   => 'Ayuntamiento de Lezaun',
			'guesalaz' => 'Ayuntamiento de Guesálaz',
			'yerri'    => 'Ayuntamiento de Yerri',
			'salinas'  => 'Ayuntamiento de Salinas de Oro',
		),
		'apoyan'     => array(
			'ue_feader'              => 'Unión Europea · FEADER',
			'miteco'                 => 'Ministerio para la Transición Ecológica y el Reto Demográfico',
			'innova'                 => 'Innova',
			'fundacion_la_caixa'     => 'Fundación «la Caixa»',
			'fundacion_caja_navarra' => 'Fundación Caja Navarra',
		),
		'colaboran'  => array(
			'cpaen'           => 'CPAEN / NNPEK',
			'upna'            => 'Universidad Pública de Navarra',
			'ci_agroforestal' => 'CI Agroforestal',
		),
		'miembro_de' => array(
			'reta'              => 'Red de Espacios Test Agrarios',
			'kalaska'           => 'Kalaska',
			'deierriko_ostatua' => 'Deierriko Ostatua',
		),
	);
	$lista = array();
	foreach ( $por_grupo as $grupo => $entidades ) {
		$orden = 0;
		foreach ( $entidades as $clave => $nombre ) {
			$orden  += 10;
			$lista[] = array(
				'clave'      => $clave,
				'nombre'     => $nombre,
				'grupo'      => $grupo,
				'enlace'     => '',
				'adjunto_id' => 0,
				'orden'      => $orden,
				'activo'     => true,
			);
		}
	}
	return $lista;
}

/** Entidades que financian el proyecto: van en su grupo. */
const SZS_CLAVES_FINANCIADORAS = array( 'carasso', 'gobierno_navarra' );

/**
 * Una lista guardada antes de que hubiera grupo «financian», con las
 * financiadoras ya en él. Lo demás (nombre, logo, orden) no se toca.
 */
function szs_logos_con_financiadoras( array $lista ): array {
	foreach ( $lista as &$entidad ) {
		if ( in_array( $entidad['clave'] ?? '', SZS_CLAVES_FINANCIADORAS, true ) ) {
			$entidad['grupo'] = 'financian';
		}
	}
	return $lista;
}

/** Minúsculas, sin tildes y con guiones bajos: `Fundación «la Caixa»` → `fundacion_la_caixa`. */
function szs_clave_logo_desde_nombre( string $nombre ): string {
	$sin_tildes = strtr(
		mb_strtolower( $nombre, 'UTF-8' ),
		array(
			'á' => 'a',
			'é' => 'e',
			'í' => 'i',
			'ó' => 'o',
			'ú' => 'u',
			'ü' => 'u',
			'ñ' => 'n',
			'ç' => 'c',
		)
	);
	$clave = trim( preg_replace( '/[^a-z0-9]+/', '_', $sin_tildes ) ?? '', '_' );
	return '' === $clave ? 'entidad' : substr( $clave, 0, 48 );
}

/** `$clave`, o `$clave_2`, `$clave_3`… si ya está cogida. */
function szs_clave_logo_libre( string $clave, array $claves_usadas ): string {
	$candidata = $clave;
	for ( $numero = 2; in_array( $candidata, $claves_usadas, true ); $numero++ ) {
		$candidata = $clave . '_' . $numero;
	}
	return $candidata;
}

/**
 * Deja una lista guardada (o recibida del formulario) en forma: claves
 * únicas, grupo conocido, enlace solo si es web, nombre obligatorio.
 */
function szs_normalizar_logos_entidades( array $lista ): array {
	$normalizada   = array();
	$claves_usadas = array();
	foreach ( $lista as $entidad ) {
		if ( ! is_array( $entidad ) ) {
			continue;
		}
		$nombre = trim( (string) ( $entidad['nombre'] ?? '' ) );
		if ( '' === $nombre ) {
			continue;
		}
		$clave_recibida  = trim( (string) ( $entidad['clave'] ?? '' ) );
		$clave           = szs_clave_logo_desde_nombre( '' !== $clave_recibida ? $clave_recibida : $nombre );
		$clave           = szs_clave_logo_libre( $clave, $claves_usadas );
		$claves_usadas[] = $clave;
		$grupo           = (string) ( $entidad['grupo'] ?? '' );
		$enlace          = trim( (string) ( $entidad['enlace'] ?? '' ) );
		$normalizada[]   = array(
			'clave'      => $clave,
			'nombre'     => mb_substr( $nombre, 0, 200, 'UTF-8' ),
			'grupo'      => isset( SZS_GRUPOS_LOGOS[ $grupo ] ) ? $grupo : 'colaboran',
			'enlace'     => szs_enlace_web_valido( $enlace ) ? $enlace : '',
			'adjunto_id' => max( 0, (int) ( $entidad['adjunto_id'] ?? 0 ) ),
			'orden'      => (int) ( $entidad['orden'] ?? 0 ),
			'activo'     => ! empty( $entidad['activo'] ),
		);
	}
	return $normalizada;
}

/**
 * Las que se enseñan, en el orden de los grupos y, dentro de cada uno, por
 * orden y nombre.
 */
function szs_logos_entidades_visibles( array $lista ): array {
	$posicion_grupo = array_flip( array_keys( SZS_GRUPOS_LOGOS ) );
	$visibles       = array_values( array_filter( $lista, static fn( array $entidad ): bool => ! empty( $entidad['activo'] ) ) );
	usort(
		$visibles,
		static fn( array $a, array $b ): int => array( $posicion_grupo[ $a['grupo'] ] ?? 99, (int) $a['orden'], $a['nombre'] )
			<=> array( $posicion_grupo[ $b['grupo'] ] ?? 99, (int) $b['orden'], $b['nombre'] )
	);
	return $visibles;
}

/**
 * La respuesta de `GET /entidades`. `$url_logo` da la dirección del logo
 * de una entidad, o '' si no tiene.
 *
 * @param callable(array): string $url_logo
 */
function szs_logos_entidades_para_app( array $lista, callable $url_logo ): array {
	$entidades = array();
	foreach ( szs_logos_entidades_visibles( $lista ) as $entidad ) {
		$entidades[] = array(
			'clave'       => $entidad['clave'],
			'nombre'      => $entidad['nombre'],
			'grupo'       => $entidad['grupo'],
			'enlace'      => $entidad['enlace'],
			'logo_url'    => $url_logo( $entidad ),
			// Con el logo de partida, la app usa el suyo (va sin cobertura).
			'logo_propio' => $entidad['adjunto_id'] > 0,
		);
	}
	return $entidades;
}

// ============================================================
// Guardado
// ============================================================

function szs_listar_logos_entidades(): array {
	$guardada = get_option( SZS_OPCION_LOGOS_ENTIDADES, null );
	return is_array( $guardada ) ? szs_normalizar_logos_entidades( $guardada ) : szs_logos_entidades_por_defecto();
}

/** Una sola vez: en una lista ya guardada, las financiadoras a su grupo. */
function szs_mover_financiadoras_una_vez(): void {
	if ( get_option( 'szs_logos_financiadoras_movidas' ) ) {
		return;
	}
	$guardada = get_option( SZS_OPCION_LOGOS_ENTIDADES, null );
	if ( is_array( $guardada ) ) {
		szs_guardar_logos_entidades( szs_logos_con_financiadoras( $guardada ) );
	}
	update_option( 'szs_logos_financiadoras_movidas', 1, false );
}

function szs_guardar_logos_entidades( array $lista ): void {
	update_option( SZS_OPCION_LOGOS_ENTIDADES, szs_normalizar_logos_entidades( $lista ), false );
}

/** Si la entidad tiene logo de partida en el plugin. */
function szs_hay_logo_de_partida( string $clave ): bool {
	return 1 === preg_match( '/^[a-z0-9_]+$/', $clave ) && is_file( dirname( __DIR__ ) . "/assets/logos/{$clave}.png" );
}

/** El logo subido a la biblioteca o, si no hay, el de partida; '' si ninguno. */
function szs_url_logo_entidad( array $entidad ): string {
	if ( $entidad['adjunto_id'] > 0 ) {
		$url = wp_get_attachment_image_url( (int) $entidad['adjunto_id'], 'medium' );
		if ( is_string( $url ) && '' !== $url ) {
			return $url;
		}
	}
	if ( szs_hay_logo_de_partida( $entidad['clave'] ) ) {
		return plugins_url( "assets/logos/{$entidad['clave']}.png", dirname( __DIR__ ) . '/solera-zunbeltz-sync.php' );
	}
	return '';
}

// ============================================================
// REST: GET /solera-zunbeltz/v1/entidades
// ============================================================

function szs_registrar_ruta_logos_entidades(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/entidades',
		array(
			'methods'             => 'GET',
			'callback'            => 'szs_endpoint_logos_entidades',
			// Público: son los logos que ya salen en la web.
			'permission_callback' => '__return_true',
		)
	);
}

function szs_endpoint_logos_entidades() {
	return new WP_REST_Response(
		array( 'entidades' => szs_logos_entidades_para_app( szs_listar_logos_entidades(), 'szs_url_logo_entidad' ) ),
		200
	);
}

// ============================================================
// Web: [solera_zunbeltz_entidades]
// ============================================================

function szs_idioma_web(): string {
	if ( function_exists( 'zunbeltz_espacio_idioma' ) ) {
		return zunbeltz_espacio_idioma();
	}
	return str_starts_with( determine_locale(), 'eu' ) ? 'eu' : 'es';
}

function szs_registrar_bloque_logos_entidades(): void {
	wp_register_script(
		'szs-bloque-entidades',
		plugins_url( 'assets/bloque-entidades.js', dirname( __DIR__ ) . '/solera-zunbeltz-sync.php' ),
		array( 'wp-blocks', 'wp-element', 'wp-server-side-render' ),
		SZS_VERSION,
		true
	);
	register_block_type(
		'solera-zunbeltz/entidades',
		array(
			'api_version'     => 3,
			'title'           => 'Entidades y logos',
			'description'     => 'Los logos de las entidades que impulsan, apoyan y colaboran (Solera Zunbeltz → Entidades y logos).',
			'category'        => 'widgets',
			'icon'            => 'groups',
			'editor_script'   => 'szs-bloque-entidades',
			'render_callback' => 'szs_shortcode_logos_entidades',
			'supports'        => array( 'html' => false ),
		)
	);
}

function szs_shortcode_logos_entidades(): string {
	$idioma    = szs_idioma_web();
	$por_grupo = array();
	foreach ( szs_logos_entidades_visibles( szs_listar_logos_entidades() ) as $entidad ) {
		$url_logo = szs_url_logo_entidad( $entidad );
		if ( '' !== $url_logo ) {
			$por_grupo[ $entidad['grupo'] ][] = array( $entidad, $url_logo );
		}
	}
	if ( empty( $por_grupo ) ) {
		return '';
	}

	ob_start();
	?>
	<style>
		.szs-entidades{display:flex;flex-wrap:wrap;gap:2rem 3rem;margin:0}
		.szs-entidades__grupo{flex:1 1 220px;min-width:0}
		.szs-entidades__titulo{margin:0 0 .75rem;font-size:.8125rem;font-weight:600;letter-spacing:.02em;opacity:.75}
		.szs-entidades__logos{display:flex;flex-wrap:wrap;align-items:center;gap:1rem 1.5rem;margin:0;padding:0;list-style:none}
		.szs-entidades__logos img{display:block;height:44px;width:auto;max-width:150px;object-fit:contain}
	</style>
	<div class="szs-entidades">
		<?php foreach ( SZS_GRUPOS_LOGOS as $grupo => $rotulos ) : ?>
			<?php
			if ( empty( $por_grupo[ $grupo ] ) ) {
				continue;
			}
			?>
			<div class="szs-entidades__grupo">
				<p class="szs-entidades__titulo"><?php echo esc_html( 'eu' === $idioma ? $rotulos[1] : $rotulos[0] ); ?></p>
				<ul class="szs-entidades__logos">
					<?php foreach ( $por_grupo[ $grupo ] as list( $entidad, $url_logo ) ) : ?>
						<?php $imagen = sprintf( '<img src="%s" alt="%s" title="%2$s" loading="lazy">', esc_url( $url_logo ), esc_attr( $entidad['nombre'] ) ); ?>
						<li>
							<?php if ( '' !== $entidad['enlace'] ) : ?>
								<a href="<?php echo esc_url( $entidad['enlace'] ); ?>" target="_blank" rel="noopener"><?php echo $imagen; // phpcs:ignore WordPress.Security.EscapeOutput ?></a>
							<?php else : ?>
								<?php echo $imagen; // phpcs:ignore WordPress.Security.EscapeOutput ?>
							<?php endif; ?>
						</li>
					<?php endforeach; ?>
				</ul>
			</div>
		<?php endforeach; ?>
	</div>
	<?php
	return (string) ob_get_clean();
}

// ============================================================
// Panel · Entidades y logos
// ============================================================

function szs_registrar_pagina_logos_entidades(): void {
	add_submenu_page( SZS_PAGINA_TAREAS, 'Entidades y logos', 'Entidades y logos', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_LOGOS_ENTIDADES, 'szs_pagina_logos_entidades' );
}

function szs_cargar_selector_medios_logos( string $pantalla ): void {
	if ( str_ends_with( $pantalla, SZS_PAGINA_LOGOS_ENTIDADES ) ) {
		wp_enqueue_media();
	}
}

/** Procesa los formularios de la página y devuelve el aviso a mostrar. */
function szs_procesar_formulario_logos_entidades(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_logos_entidades' );
	$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );

	switch ( $accion ) {
		case 'guardar':
			$recibidas = isset( $_POST['szs_entidad'] ) && is_array( $_POST['szs_entidad'] ) ? wp_unslash( $_POST['szs_entidad'] ) : array(); // phpcs:ignore WordPress.Security.ValidatedSanitizedInput
			$lista     = array();
			foreach ( $recibidas as $clave => $campos ) {
				if ( ! is_array( $campos ) || ! empty( $campos['borrar'] ) ) {
					continue;
				}
				$lista[] = array(
					'clave'      => sanitize_key( (string) $clave ),
					'nombre'     => sanitize_text_field( (string) ( $campos['nombre'] ?? '' ) ),
					'grupo'      => sanitize_key( (string) ( $campos['grupo'] ?? '' ) ),
					'enlace'     => esc_url_raw( (string) ( $campos['enlace'] ?? '' ) ),
					'adjunto_id' => (int) ( $campos['adjunto_id'] ?? 0 ),
					'orden'      => (int) ( $campos['orden'] ?? 0 ),
					'activo'     => ! empty( $campos['activo'] ),
				);
			}
			szs_guardar_logos_entidades( $lista );
			return array( 'success', 'Guardado. La web lo enseña ya; la app, la próxima vez que se abra con conexión.' );

		case 'anadir':
			$nombre = szs_campo_post( 'szs_nombre' );
			if ( '' === $nombre ) {
				return array( 'error', 'Hace falta el nombre de la entidad.' );
			}
			$lista       = szs_listar_logos_entidades();
			$mismo_grupo = array_filter( $lista, static fn( array $entidad ): bool => $entidad['grupo'] === szs_campo_post( 'szs_grupo' ) );
			$lista[]     = array(
				'clave'      => szs_clave_logo_libre( szs_clave_logo_desde_nombre( $nombre ), array_column( $lista, 'clave' ) ),
				'nombre'     => $nombre,
				'grupo'      => sanitize_key( szs_campo_post( 'szs_grupo' ) ),
				'enlace'     => esc_url_raw( szs_campo_post( 'szs_enlace' ) ),
				'adjunto_id' => (int) szs_campo_post( 'szs_adjunto_id', '0' ),
				'orden'      => ( empty( $mismo_grupo ) ? 0 : max( array_column( $mismo_grupo, 'orden' ) ) ) + 10,
				'activo'     => true,
			);
			szs_guardar_logos_entidades( $lista );
			return array( 'success', 'Entidad añadida al final de su grupo.' );

		case 'restaurar':
			delete_option( SZS_OPCION_LOGOS_ENTIDADES );
			return array( 'success', 'Vuelve a estar la lista original, con sus logos de partida.' );
	}
	return null;
}

/** Miniatura + botones para elegir o quitar el logo de la biblioteca. */
function szs_campo_logo_entidad( string $nombre_campo, array $entidad ): void {
	$url_logo = '' === $entidad['clave'] ? '' : szs_url_logo_entidad( $entidad );
	?>
	<div class="szs-campo-logo" style="display:flex;align-items:center;gap:8px;">
		<span class="szs-vista-logo" style="display:inline-flex;align-items:center;justify-content:center;width:110px;height:52px;background:#E6EEEA;border-radius:4px;">
			<?php if ( '' !== $url_logo ) : ?>
				<img src="<?php echo esc_url( $url_logo ); ?>" alt="" style="max-width:100px;max-height:44px;">
			<?php else : ?>
				<em style="color:#666;">sin logo</em>
			<?php endif; ?>
		</span>
		<input type="hidden" name="<?php echo esc_attr( $nombre_campo ); ?>" value="<?php echo esc_attr( (string) $entidad['adjunto_id'] ); ?>">
		<span>
			<button type="button" class="button button-small szs-elegir-logo">Cambiar…</button>
			<?php if ( $entidad['adjunto_id'] > 0 ) : ?>
				<br><button type="button" class="button-link szs-quitar-logo" style="font-size:12px;"><?php echo szs_hay_logo_de_partida( $entidad['clave'] ) ? 'Volver al original' : 'Quitar'; ?></button>
			<?php endif; ?>
		</span>
	</div>
	<?php
}

function szs_pagina_logos_entidades(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = szs_procesar_formulario_logos_entidades();
	$lista = szs_listar_logos_entidades();
	usort(
		$lista,
		static fn( array $a, array $b ): int => array( array_search( $a['grupo'], array_keys( SZS_GRUPOS_LOGOS ), true ), $a['orden'], $a['nombre'] )
			<=> array( array_search( $b['grupo'], array_keys( SZS_GRUPOS_LOGOS ), true ), $b['orden'], $b['nombre'] )
	);
	$grupos = array_map( static fn( array $rotulos ): string => $rotulos[0], SZS_GRUPOS_LOGOS );
	?>
	<div class="wrap">
		<h1>Entidades y logos</h1>
		<p>Las entidades que impulsan, apoyan y colaboran con el espacio. Salen en el pie de la web y en la app (Hoy, abajo del todo, y Ajustes → Entidades). Los logos de partida son los del pie de zunbeltz.com; para poner otro, «Cambiar…» y elegidlo o subidlo a la biblioteca de medios (PNG o SVG con fondo transparente se ven mejor).</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<form method="post">
			<?php wp_nonce_field( 'szs_logos_entidades' ); ?>
			<input type="hidden" name="szs_accion" value="guardar">
			<table class="widefat striped">
				<thead><tr><th>Logo</th><th>Nombre</th><th>Grupo</th><th>Enlace</th><th style="width:70px;">Orden</th><th>Visible</th><th>Borrar</th></tr></thead>
				<tbody>
				<?php foreach ( $lista as $entidad ) : ?>
					<?php $prefijo = 'szs_entidad[' . $entidad['clave'] . ']'; ?>
					<tr>
						<td><?php szs_campo_logo_entidad( $prefijo . '[adjunto_id]', $entidad ); ?></td>
						<td><input type="text" name="<?php echo esc_attr( $prefijo ); ?>[nombre]" value="<?php echo esc_attr( $entidad['nombre'] ); ?>" class="regular-text"></td>
						<td><?php szs_selector( $prefijo . '[grupo]', $grupos, $entidad['grupo'] ); ?></td>
						<td><input type="url" name="<?php echo esc_attr( $prefijo ); ?>[enlace]" value="<?php echo esc_attr( $entidad['enlace'] ); ?>" placeholder="https://…" style="width:200px;"></td>
						<td><input type="number" name="<?php echo esc_attr( $prefijo ); ?>[orden]" value="<?php echo esc_attr( (string) $entidad['orden'] ); ?>" step="1" style="width:64px;"></td>
						<td><input type="checkbox" name="<?php echo esc_attr( $prefijo ); ?>[activo]" value="1" <?php checked( $entidad['activo'] ); ?>></td>
						<td><input type="checkbox" name="<?php echo esc_attr( $prefijo ); ?>[borrar]" value="1"></td>
					</tr>
				<?php endforeach; ?>
				</tbody>
			</table>
			<p class="description">El orden va de menor a mayor dentro de cada grupo. Quitar «Visible» la esconde sin borrarla.</p>
			<?php submit_button( 'Guardar cambios' ); ?>
		</form>

		<h2>Añadir una entidad</h2>
		<form method="post" style="max-width:720px;">
			<?php wp_nonce_field( 'szs_logos_entidades' ); ?>
			<input type="hidden" name="szs_accion" value="anadir">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nombre">Nombre</label></th><td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text"></td></tr>
				<tr><th><label for="szs_grupo">Grupo</label></th><td><?php szs_selector( 'szs_grupo', $grupos, 'colaboran' ); ?></td></tr>
				<tr><th><label for="szs_enlace">Enlace</label></th><td><input type="url" id="szs_enlace" name="szs_enlace" class="regular-text" placeholder="https://…"></td></tr>
				<tr><th>Logo</th><td>
					<?php
					szs_campo_logo_entidad(
						'szs_adjunto_id',
						array(
							'clave'      => '',
							'adjunto_id' => 0,
						)
					);
					?>
				</td></tr>
			</table>
			<?php submit_button( 'Añadir' ); ?>
		</form>

		<h2>Volver a empezar</h2>
		<form method="post" onsubmit="return confirm('¿Volver a la lista original? Se pierden los cambios hechos aquí.');">
			<?php wp_nonce_field( 'szs_logos_entidades' ); ?>
			<input type="hidden" name="szs_accion" value="restaurar">
			<p>Recupera las 19 entidades del pie de zunbeltz.com con sus logos de partida. <button class="button button-link-delete">Restaurar la lista original</button></p>
		</form>
	</div>
	<script>
	( function () {
		document.querySelectorAll( '.szs-campo-logo' ).forEach( function ( campo ) {
			var entrada = campo.querySelector( 'input[type=hidden]' );
			var vista = campo.querySelector( '.szs-vista-logo' );
			campo.querySelector( '.szs-elegir-logo' ).addEventListener( 'click', function () {
				var selector = wp.media( { title: 'Logo de la entidad', button: { text: 'Usar este logo' }, library: { type: 'image' }, multiple: false } );
				selector.on( 'select', function () {
					var adjunto = selector.state().get( 'selection' ).first().toJSON();
					var tamano = ( adjunto.sizes && adjunto.sizes.medium ) || adjunto;
					entrada.value = adjunto.id;
					vista.innerHTML = '';
					var imagen = document.createElement( 'img' );
					imagen.src = tamano.url;
					imagen.style.maxWidth = '100px';
					imagen.style.maxHeight = '44px';
					vista.appendChild( imagen );
				} );
				selector.open();
			} );
			var quitar = campo.querySelector( '.szs-quitar-logo' );
			if ( quitar ) {
				quitar.addEventListener( 'click', function () {
					entrada.value = '0';
					vista.innerHTML = '<em style="color:#666;">se guarda al pulsar «Guardar cambios»</em>';
				} );
			}
		} );
	} )();
	</script>
	<?php
}
