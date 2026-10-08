<?php
/**
 * Noticias del sector: canales RSS/Atom que coordinación da de alta en el
 * panel y que el servidor lee cada pocas horas, para que la app las muestre
 * en la sección de Noticias junto a las que publica el propio espacio.
 *
 * - Lee el servidor, no la app: la app web no podría (CORS) y así el móvil
 *   solo baja una lista corta ya filtrada.
 * - Se guarda solo título, entradilla corta, fecha y enlace al original;
 *   nunca el texto completo del artículo.
 * - No son entidades sincronizadas: van por `GET /noticias`, sin revisiones
 *   ni lápidas, y no generan notificaciones en los móviles.
 * - `GET /noticias` es público (sin token): son titulares públicos de
 *   medios públicos, y así la demo web para testers, que no tiene sesión,
 *   también los enseña. Si se retira el extra, basta con quitar este
 *   fichero del `require`.
 * - Coordinación puede ocultar o fijar cada noticia, y filtrar un canal por
 *   palabras clave (para medios generalistas).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_TABLA_CANALES             = 'solera_zunbeltz_canales';
const SZS_TABLA_NOTICIAS            = 'solera_zunbeltz_noticias';
const SZS_PAGINA_NOTICIAS           = 'solera-zunbeltz-noticias';
const SZS_EVENTO_LEER_CANALES       = 'szs_leer_canales';
const SZS_INTERVALO_LEER_CANALES    = 'szs_cada_tres_horas';
const SZS_DIAS_NOTICIAS_EN_APP      = 90;
const SZS_MAXIMO_NOTICIAS_EN_APP    = 60;
/** Para que un canal que publica mucho no tape a los que publican poco. */
const SZS_MAXIMO_POR_CANAL_EN_APP   = 10;
const SZS_DIAS_CONSERVAR_NOTICIAS   = 90;
const SZS_MAXIMO_ITEMS_POR_LECTURA  = 30;
const SZS_LONGITUD_ENTRADILLA       = 280;
const SZS_IDIOMAS_CANAL             = array(
	'es'    => 'Castellano',
	'eu'    => 'Euskera',
	'mixto' => 'Los dos',
);

add_filter( 'cron_schedules', 'szs_intervalo_lectura_canales' );
add_action( 'init', 'szs_programar_lectura_canales' );
add_action( SZS_EVENTO_LEER_CANALES, 'szs_leer_todos_los_canales' );
add_action( 'rest_api_init', 'szs_registrar_ruta_noticias' );
add_action( 'admin_menu', 'szs_registrar_pagina_noticias', 12 );

// ============================================================
// Lógica pura (sin WordPress): probada en tests/test_noticias.php
// ============================================================

/** Texto plano de un fragmento HTML de feed, en una línea y recortado. */
function szs_texto_plano_noticia( string $html, int $limite ): string {
	$sin_bloques = preg_replace( '#<(script|style)[^>]*>.*?</\1>#is', ' ', $html ) ?? $html;
	$texto       = html_entity_decode( strip_tags( $sin_bloques ), ENT_QUOTES | ENT_HTML5, 'UTF-8' );
	// Control chars y el carácter de reemplazo que dejan los feeds mal codificados.
	$texto = str_replace( "\u{FFFD}", '', $texto );
	$texto = preg_replace( '/[\x{0000}-\x{001F}\x{00A0}]/u', ' ', $texto ) ?? $texto;
	$texto = trim( preg_replace( '/\s+/u', ' ', $texto ) ?? $texto );
	if ( mb_strlen( $texto, 'UTF-8' ) <= $limite ) {
		return $texto;
	}
	$recortado      = mb_substr( $texto, 0, $limite, 'UTF-8' );
	$ultimo_espacio = mb_strrpos( $recortado, ' ', 0, 'UTF-8' );
	if ( false !== $ultimo_espacio && $ultimo_espacio > $limite * 0.6 ) {
		$recortado = mb_substr( $recortado, 0, $ultimo_espacio, 'UTF-8' );
	}
	return rtrim( $recortado, " .,;:-" ) . '…';
}

/** Minúsculas y sin tildes, para comparar palabras clave. */
function szs_texto_comparable( string $texto ): string {
	return strtr(
		mb_strtolower( $texto, 'UTF-8' ),
		array(
			'á' => 'a',
			'é' => 'e',
			'í' => 'i',
			'ó' => 'o',
			'ú' => 'u',
			'ü' => 'u',
			'à' => 'a',
			'è' => 'e',
			'ò' => 'o',
		)
	);
}

/**
 * Palabras clave de un canal, separadas por comas o saltos de línea. Un
 * canal sin palabras clave deja pasar todo.
 *
 * @return string[]
 */
function szs_palabras_clave( string $texto ): array {
	$palabras = array_map( 'trim', preg_split( '/[,\n]+/u', $texto ) ?: array() );
	return array_values( array_filter( $palabras, static fn( string $palabra ): bool => '' !== $palabra ) );
}

/**
 * Si la noticia contiene alguna de las palabras clave (o no hay ninguna).
 * Cada palabra tiene que estar al principio de una palabra del texto:
 * «ganader» encuentra «ganadería» y «ganaderos», pero «PAC» no encuentra
 * «impacto».
 */
function szs_noticia_pasa_filtro( string $titulo, string $entradilla, string $palabras_clave ): bool {
	$palabras = szs_palabras_clave( $palabras_clave );
	if ( empty( $palabras ) ) {
		return true;
	}
	$texto = szs_texto_comparable( $titulo . ' ' . $entradilla );
	foreach ( $palabras as $palabra ) {
		$patron = '/(?<![\p{L}\p{N}])' . preg_quote( szs_texto_comparable( $palabra ), '/' ) . '/u';
		if ( 1 === preg_match( $patron, $texto ) ) {
			return true;
		}
	}
	return false;
}

/** Solo enlaces web: un `javascript:` o un `file:` no llegan a la app. */
function szs_enlace_web_valido( string $enlace ): bool {
	$esquema = strtolower( (string) parse_url( $enlace, PHP_URL_SCHEME ) );
	return in_array( $esquema, array( 'http', 'https' ), true ) && '' !== (string) parse_url( $enlace, PHP_URL_HOST );
}

/**
 * Convierte un elemento leído del feed en la fila que se guarda, o `null`
 * si no sirve (sin título, sin enlace web o fuera del filtro del canal).
 *
 * @param array{titulo?: string, descripcion?: string, contenido?: string, enlace?: string, guid?: string, fecha_s?: ?int} $item
 */
function szs_normalizar_item_noticia( array $item, array $canal, int $ahora_ms ): ?array {
	$titulo = szs_texto_plano_noticia( (string) ( $item['titulo'] ?? '' ), 300 );
	$enlace = trim( (string) ( $item['enlace'] ?? '' ) );
	if ( '' === $titulo || ! szs_enlace_web_valido( $enlace ) ) {
		return null;
	}
	$fuente_entradilla = trim( (string) ( $item['descripcion'] ?? '' ) );
	if ( '' === trim( strip_tags( $fuente_entradilla ) ) ) {
		$fuente_entradilla = (string) ( $item['contenido'] ?? '' );
	}
	$entradilla = szs_texto_plano_noticia( $fuente_entradilla, SZS_LONGITUD_ENTRADILLA );
	if ( ! szs_noticia_pasa_filtro( $titulo, $entradilla, (string) ( $canal['palabras_clave'] ?? '' ) ) ) {
		return null;
	}
	$fecha_s = $item['fecha_s'] ?? null;
	// Sin fecha, o con una fecha futura (feeds mal configurados): la de ahora.
	$fecha_ms = null === $fecha_s ? $ahora_ms : min( (int) $fecha_s * 1000, $ahora_ms );
	// Lo que ya se borraría por viejo no entra: si no, cada lectura lo
	// volvería a meter y la limpieza a borrar.
	if ( $fecha_ms < $ahora_ms - SZS_DIAS_CONSERVAR_NOTICIAS * 86_400_000 ) {
		return null;
	}
	$guid     = trim( (string) ( $item['guid'] ?? '' ) );
	return array(
		'canal_id'   => (int) ( $canal['id'] ?? 0 ),
		'guid_hash'  => sha1( (int) ( $canal['id'] ?? 0 ) . '|' . ( '' !== $guid ? $guid : $enlace ) ),
		'titulo'     => $titulo,
		'entradilla' => $entradilla,
		'enlace'     => mb_substr( $enlace, 0, 1000, 'UTF-8' ),
		'fecha_ms'   => $fecha_ms,
	);
}

/**
 * Lo que baja la app: sin las ocultas, solo los últimos días (las fijadas
 * siempre), como mucho [SZS_MAXIMO_POR_CANAL_EN_APP] de cada canal (sin
 * contar las fijadas), fijadas primero y luego de la más reciente a la más
 * antigua.
 *
 * @param array<int, array> $filas    Noticias con `canal_nombre` y `canal_idioma`.
 * @return array<int, array>
 */
function szs_noticias_para_app( array $filas, int $ahora_ms, int $dias = SZS_DIAS_NOTICIAS_EN_APP, int $limite = SZS_MAXIMO_NOTICIAS_EN_APP ): array {
	$desde_ms = $ahora_ms - $dias * 86_400_000;
	$visibles = array_filter(
		$filas,
		static fn( array $fila ): bool => empty( $fila['oculta'] )
			&& ( ! empty( $fila['fijada'] ) || (int) $fila['fecha_ms'] >= $desde_ms )
	);
	usort(
		$visibles,
		static fn( array $a, array $b ): int => array( empty( $a['fijada'] ) ? 1 : 0, -(int) $a['fecha_ms'] )
			<=> array( empty( $b['fijada'] ) ? 1 : 0, -(int) $b['fecha_ms'] )
	);
	$por_canal  = array();
	$repartidas = array();
	foreach ( $visibles as $fila ) {
		$canal_id = (int) ( $fila['canal_id'] ?? 0 );
		if ( empty( $fila['fijada'] ) ) {
			$por_canal[ $canal_id ] = ( $por_canal[ $canal_id ] ?? 0 ) + 1;
			if ( $por_canal[ $canal_id ] > SZS_MAXIMO_POR_CANAL_EN_APP ) {
				continue;
			}
		}
		$repartidas[] = $fila;
	}
	return array_map(
		static fn( array $fila ): array => array(
			'id'         => (int) $fila['id'],
			'titulo'     => (string) $fila['titulo'],
			'entradilla' => (string) $fila['entradilla'],
			'enlace'     => (string) $fila['enlace'],
			'fecha_ms'   => (int) $fila['fecha_ms'],
			'fuente'     => (string) ( $fila['canal_nombre'] ?? '' ),
			'idioma'     => (string) ( $fila['canal_idioma'] ?? 'es' ),
			'fijada'     => ! empty( $fila['fijada'] ),
		),
		array_slice( $repartidas, 0, $limite )
	);
}

// ============================================================
// Esquema
// ============================================================

/** Llamada desde `szs_instalar_esquema` (con `upgrade.php` ya cargado). */
function szs_instalar_esquema_noticias( string $charset_collate ): void {
	global $wpdb;
	$tabla_canales  = $wpdb->prefix . SZS_TABLA_CANALES;
	$tabla_noticias = $wpdb->prefix . SZS_TABLA_NOTICIAS;
	dbDelta(
		"CREATE TABLE {$tabla_canales} (
		id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(255) NOT NULL DEFAULT '',
		url VARCHAR(1000) NOT NULL DEFAULT '',
		idioma VARCHAR(10) NOT NULL DEFAULT 'es',
		palabras_clave TEXT NULL,
		activo TINYINT(1) NOT NULL DEFAULT 1,
		ultima_lectura_ms BIGINT NOT NULL DEFAULT 0,
		ultimo_error VARCHAR(500) NOT NULL DEFAULT '',
		ultimas_nuevas INT NOT NULL DEFAULT 0,
		PRIMARY KEY  (id)
	) {$charset_collate};"
	);
	dbDelta(
		"CREATE TABLE {$tabla_noticias} (
		id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
		canal_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
		guid_hash CHAR(40) NOT NULL,
		titulo VARCHAR(500) NOT NULL DEFAULT '',
		entradilla TEXT NULL,
		enlace VARCHAR(1000) NOT NULL DEFAULT '',
		fecha_ms BIGINT NOT NULL DEFAULT 0,
		oculta TINYINT(1) NOT NULL DEFAULT 0,
		fijada TINYINT(1) NOT NULL DEFAULT 0,
		recibido_en DATETIME NOT NULL,
		PRIMARY KEY  (id),
		UNIQUE KEY guid_hash (guid_hash),
		KEY fecha_ms (fecha_ms),
		KEY canal_id (canal_id)
	) {$charset_collate};"
	);
}

function szs_tabla_canales(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_CANALES;
}

function szs_tabla_noticias(): string {
	global $wpdb;
	return $wpdb->prefix . SZS_TABLA_NOTICIAS;
}

// ============================================================
// Lectura de los canales (cron)
// ============================================================

function szs_intervalo_lectura_canales( array $intervalos ): array {
	$intervalos[ SZS_INTERVALO_LEER_CANALES ] = array(
		'interval' => 3 * HOUR_IN_SECONDS,
		'display'  => 'Cada tres horas (Solera Zunbeltz)',
	);
	return $intervalos;
}

function szs_programar_lectura_canales(): void {
	if ( ! wp_next_scheduled( SZS_EVENTO_LEER_CANALES ) ) {
		wp_schedule_event( time() + 5 * MINUTE_IN_SECONDS, SZS_INTERVALO_LEER_CANALES, SZS_EVENTO_LEER_CANALES );
	}
}

function szs_desprogramar_lectura_canales(): void {
	wp_clear_scheduled_hook( SZS_EVENTO_LEER_CANALES );
}

/** @return array<int, array> */
function szs_listar_canales( bool $solo_activos = false ): array {
	global $wpdb;
	$tabla = szs_tabla_canales();
	$donde = $solo_activos ? 'WHERE activo = 1' : '';
	return (array) $wpdb->get_results( "SELECT * FROM {$tabla} {$donde} ORDER BY nombre", ARRAY_A );
}

function szs_obtener_canal( int $id ): ?array {
	global $wpdb;
	$tabla = szs_tabla_canales();
	$fila  = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$tabla} WHERE id = %d", $id ), ARRAY_A );
	return is_array( $fila ) ? $fila : null;
}

/** Lee todos los canales activos y borra las noticias viejas no fijadas. */
function szs_leer_todos_los_canales(): void {
	global $wpdb;
	foreach ( szs_listar_canales( true ) as $canal ) {
		szs_leer_canal( $canal );
	}
	$tabla_noticias = szs_tabla_noticias();
	$limite_ms      = szs_ahora_ms() - SZS_DIAS_CONSERVAR_NOTICIAS * 86_400_000;
	$wpdb->query( $wpdb->prepare( "DELETE FROM {$tabla_noticias} WHERE fijada = 0 AND fecha_ms < %d", $limite_ms ) );
}

/**
 * Descarga y guarda un canal. Deja en el canal la hora, el error (si lo
 * hubo) y cuántas noticias nuevas entraron.
 *
 * @return array{nuevas: int, error: string}
 */
function szs_leer_canal( array $canal ): array {
	global $wpdb;
	$ahora_ms  = szs_ahora_ms();
	$resultado = array(
		'nuevas' => 0,
		'error'  => '',
	);

	$items = szs_descargar_items_feed( (string) $canal['url'] );
	if ( is_string( $items ) ) {
		$resultado['error'] = $items;
	} else {
		$tabla_noticias = szs_tabla_noticias();
		foreach ( $items as $item ) {
			$noticia = szs_normalizar_item_noticia( $item, $canal, $ahora_ms );
			if ( null === $noticia ) {
				continue;
			}
			$noticia['recibido_en'] = gmdate( 'Y-m-d H:i:s' );
			// La clave única guid_hash descarta las ya guardadas.
			$insertadas = $wpdb->query(
				$wpdb->prepare(
					"INSERT IGNORE INTO {$tabla_noticias} (canal_id, guid_hash, titulo, entradilla, enlace, fecha_ms, recibido_en) VALUES (%d, %s, %s, %s, %s, %d, %s)",
					$noticia['canal_id'],
					$noticia['guid_hash'],
					$noticia['titulo'],
					$noticia['entradilla'],
					$noticia['enlace'],
					$noticia['fecha_ms'],
					$noticia['recibido_en']
				)
			);
			$resultado['nuevas'] += (int) $insertadas;
		}
	}

	$wpdb->update(
		szs_tabla_canales(),
		array(
			'ultima_lectura_ms' => $ahora_ms,
			'ultimo_error'      => mb_substr( $resultado['error'], 0, 500, 'UTF-8' ),
			'ultimas_nuevas'    => $resultado['nuevas'],
		),
		array( 'id' => (int) $canal['id'] )
	);
	return $resultado;
}

/**
 * Descarga un feed RSS/Atom y devuelve sus elementos, o un mensaje de error
 * legible para el panel.
 *
 * `wp_safe_remote_get` rechaza direcciones internas: la URL la escribe una
 * persona en el panel y no debe servir para que el servidor consulte su
 * propia red.
 *
 * @return array<int, array>|string
 */
function szs_descargar_items_feed( string $url ) {
	if ( ! szs_enlace_web_valido( $url ) ) {
		return 'La dirección no es una URL web (http/https).';
	}
	$respuesta = wp_safe_remote_get(
		$url,
		array(
			'timeout'     => 15,
			'redirection' => 3,
			'user-agent'  => 'SoleraZunbeltz/' . SZS_VERSION . ' (lector de noticias; ' . home_url() . ')',
		)
	);
	if ( is_wp_error( $respuesta ) ) {
		// WordPress dice «URL no válida» también cuando el nombre no resuelve
		// o apunta a una red interna.
		return 'No se pudo descargar (¿está bien escrita la dirección?): ' . $respuesta->get_error_message();
	}
	$codigo = (int) wp_remote_retrieve_response_code( $respuesta );
	if ( 200 !== $codigo ) {
		return "El servidor del canal respondió con el código {$codigo}.";
	}

	// WordPress carga SimplePie solo cuando alguien llama a fetch_feed();
	// desde el cron no está cargado.
	if ( ! class_exists( 'SimplePie', false ) ) {
		require_once ABSPATH . WPINC . '/class-simplepie.php';
	}
	$feed = new SimplePie();
	$feed->set_raw_data( (string) wp_remote_retrieve_body( $respuesta ) );
	$feed->enable_cache( false );
	$feed->init();
	if ( $feed->error() ) {
		return 'La dirección no parece un canal RSS o Atom.';
	}

	$items = array();
	foreach ( (array) $feed->get_items( 0, SZS_MAXIMO_ITEMS_POR_LECTURA ) as $item ) {
		$fecha_s = $item->get_date( 'U' );
		$items[] = array(
			'titulo'      => (string) $item->get_title(),
			'descripcion' => (string) $item->get_description(),
			'contenido'   => (string) $item->get_content(),
			'enlace'      => (string) $item->get_permalink(),
			'guid'        => (string) $item->get_id(),
			'fecha_s'     => is_numeric( $fecha_s ) ? (int) $fecha_s : null,
		);
	}
	return $items;
}

// ============================================================
// REST: GET /solera-zunbeltz/v1/noticias
// ============================================================

function szs_registrar_ruta_noticias(): void {
	register_rest_route(
		'solera-zunbeltz/v1',
		'/noticias',
		array(
			'methods'             => 'GET',
			'callback'            => 'szs_endpoint_noticias',
			// Público a propósito: ver la cabecera del fichero.
			'permission_callback' => '__return_true',
		)
	);
}

/** Las noticias del sector que muestra la app (y la demo web, sin sesión). */
function szs_endpoint_noticias( WP_REST_Request $request ) {
	return new WP_REST_Response(
		array(
			'noticias'    => szs_noticias_para_app( szs_listar_noticias_con_canal( SZS_DIAS_CONSERVAR_NOTICIAS ), szs_ahora_ms() ),
			'generado_ms' => szs_ahora_ms(),
		),
		200
	);
}

/**
 * Noticias de canales activos de los últimos días (más las fijadas), con el
 * nombre y el idioma del canal.
 *
 * @return array<int, array>
 */
function szs_listar_noticias_con_canal( int $dias, bool $incluir_canales_inactivos = false ): array {
	global $wpdb;
	$tabla_noticias = szs_tabla_noticias();
	$tabla_canales  = szs_tabla_canales();
	$desde_ms       = szs_ahora_ms() - $dias * 86_400_000;
	$solo_activos   = $incluir_canales_inactivos ? '' : 'AND c.activo = 1';
	return (array) $wpdb->get_results(
		$wpdb->prepare(
			"SELECT n.*, c.nombre AS canal_nombre, c.idioma AS canal_idioma
			FROM {$tabla_noticias} n JOIN {$tabla_canales} c ON c.id = n.canal_id
			WHERE ( n.fecha_ms >= %d OR n.fijada = 1 ) {$solo_activos}
			ORDER BY n.fijada DESC, n.fecha_ms DESC",
			$desde_ms
		),
		ARRAY_A
	);
}

// ============================================================
// Panel · Noticias del sector
// ============================================================

function szs_registrar_pagina_noticias(): void {
	add_submenu_page( SZS_PAGINA_TAREAS, 'Noticias del sector', 'Noticias del sector', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_NOTICIAS, 'szs_pagina_noticias' );
}

/** Procesa los formularios de la página y devuelve el aviso a mostrar. */
function szs_procesar_formulario_noticias(): ?array {
	global $wpdb;
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_noticias' );
	$accion   = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
	$id       = (int) szs_campo_post( 'szs_id', '0' );
	$canales  = szs_tabla_canales();
	$noticias = szs_tabla_noticias();

	switch ( $accion ) {
		case 'anadir_canal':
			$nombre = szs_campo_post( 'szs_nombre' );
			$url    = esc_url_raw( szs_campo_post( 'szs_url' ) );
			$idioma = sanitize_key( szs_campo_post( 'szs_idioma', 'es' ) );
			if ( '' === $nombre || ! szs_enlace_web_valido( $url ) ) {
				return array( 'error', 'Hacen falta un nombre y la dirección (http/https) del canal RSS.' );
			}
			$wpdb->insert(
				$canales,
				array(
					'nombre'         => $nombre,
					'url'            => $url,
					'idioma'         => isset( SZS_IDIOMAS_CANAL[ $idioma ] ) ? $idioma : 'es',
					'palabras_clave' => szs_texto_largo_post( 'szs_palabras_clave' ),
					'activo'         => 1,
				)
			);
			$canal     = szs_obtener_canal( (int) $wpdb->insert_id );
			$resultado = null === $canal ? array( 'error' => 'No se pudo guardar.' ) : szs_leer_canal( $canal );
			return '' === $resultado['error']
				? array( 'success', sprintf( 'Canal añadido. Primera lectura: %d noticias.', $resultado['nuevas'] ) )
				: array( 'warning', 'Canal añadido, pero la primera lectura ha fallado: ' . $resultado['error'] );

		case 'editar_palabras':
			$wpdb->update( $canales, array( 'palabras_clave' => szs_texto_largo_post( 'szs_palabras_clave' ) ), array( 'id' => $id ) );
			return array( 'success', 'Palabras clave guardadas. Se aplican a las noticias que entren a partir de ahora.' );

		case 'alternar_canal':
			$canal = szs_obtener_canal( $id );
			if ( null !== $canal ) {
				$wpdb->update( $canales, array( 'activo' => $canal['activo'] ? 0 : 1 ), array( 'id' => $id ) );
			}
			return array( 'success', 'Canal actualizado.' );

		case 'borrar_canal':
			$wpdb->delete( $noticias, array( 'canal_id' => $id ) );
			$wpdb->delete( $canales, array( 'id' => $id ) );
			return array( 'success', 'Canal y sus noticias borrados.' );

		case 'leer_ahora':
			szs_leer_todos_los_canales();
			return array( 'success', 'Canales leídos. Mira la columna «Última lectura» por si alguno ha fallado.' );

		case 'ocultar':
		case 'mostrar':
			$wpdb->update( $noticias, array( 'oculta' => 'ocultar' === $accion ? 1 : 0 ), array( 'id' => $id ) );
			return array( 'success', 'ocultar' === $accion ? 'Noticia oculta: desaparece de la app.' : 'Noticia visible de nuevo.' );

		case 'fijar':
		case 'desfijar':
			$wpdb->update( $noticias, array( 'fijada' => 'fijar' === $accion ? 1 : 0 ), array( 'id' => $id ) );
			return array( 'success', 'fijar' === $accion ? 'Noticia fijada arriba en la app.' : 'Noticia desfijada.' );
	}
	return null;
}

function szs_boton_noticias( string $accion, int $id, string $texto, string $clase = 'button button-small' ): void {
	?>
	<form method="post" style="display:inline;">
		<?php wp_nonce_field( 'szs_noticias' ); ?>
		<input type="hidden" name="szs_accion" value="<?php echo esc_attr( $accion ); ?>">
		<input type="hidden" name="szs_id" value="<?php echo esc_attr( (string) $id ); ?>">
		<button class="<?php echo esc_attr( $clase ); ?>"><?php echo esc_html( $texto ); ?></button>
	</form>
	<?php
}

function szs_pagina_noticias(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso    = szs_procesar_formulario_noticias();
	$canales  = szs_listar_canales();
	$noticias = szs_listar_noticias_con_canal( SZS_DIAS_NOTICIAS_EN_APP, true );
	?>
	<div class="wrap">
		<h1>Noticias del sector</h1>
		<p>Canales RSS de fuera (administración, sindicatos agrarios, prensa del sector…) que el servidor lee cada tres horas. Sus noticias aparecen en la app, en Hoy → Noticias, debajo de las que publicáis vosotras en <a href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_AVISOS ) ); ?>">Avisos</a>. Solo se guarda el titular, una entradilla corta y el enlace al original; no avisan con notificación.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<h2>Canales</h2>
		<table class="widefat striped">
			<thead><tr><th>Canal</th><th>Idioma</th><th>Palabras clave</th><th>Última lectura</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $canales ) ) : ?>
				<tr><td colspan="5">Todavía no hay canales. Añadid el primero abajo.</td></tr>
			<?php endif; ?>
			<?php foreach ( $canales as $canal ) : ?>
				<?php $id = (int) $canal['id']; ?>
				<tr<?php echo $canal['activo'] ? '' : ' style="opacity:.6"'; ?>>
					<td>
						<strong><?php echo esc_html( (string) $canal['nombre'] ); ?></strong><?php echo $canal['activo'] ? '' : ' (pausado)'; ?>
						<br><code style="font-size:11px;"><?php echo esc_html( (string) $canal['url'] ); ?></code>
					</td>
					<td><?php echo esc_html( SZS_IDIOMAS_CANAL[ $canal['idioma'] ] ?? (string) $canal['idioma'] ); ?></td>
					<td>
						<form method="post" style="display:flex;gap:4px;align-items:flex-start;">
							<?php wp_nonce_field( 'szs_noticias' ); ?>
							<input type="hidden" name="szs_accion" value="editar_palabras">
							<input type="hidden" name="szs_id" value="<?php echo esc_attr( (string) $id ); ?>">
							<input type="text" name="szs_palabras_clave" value="<?php echo esc_attr( (string) $canal['palabras_clave'] ); ?>" placeholder="(todas)" style="width:220px;">
							<button class="button button-small">Guardar</button>
						</form>
					</td>
					<td>
						<?php if ( 0 === (int) $canal['ultima_lectura_ms'] ) : ?>
							—
						<?php else : ?>
							<?php echo esc_html( szs_fecha_ms( (int) $canal['ultima_lectura_ms'], 'd/m H:i' ) ); ?>
							<?php if ( '' !== (string) $canal['ultimo_error'] ) : ?>
								<br><strong style="color:#b8402a;"><?php echo esc_html( (string) $canal['ultimo_error'] ); ?></strong>
							<?php else : ?>
								· <?php echo esc_html( sprintf( '%d nuevas', (int) $canal['ultimas_nuevas'] ) ); ?>
							<?php endif; ?>
						<?php endif; ?>
					</td>
					<td>
						<?php szs_boton_noticias( 'alternar_canal', $id, $canal['activo'] ? 'Pausar' : 'Reanudar' ); ?>
						<?php szs_boton_noticias( 'borrar_canal', $id, 'Borrar', 'button button-small button-link-delete' ); ?>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
		<?php if ( ! empty( $canales ) ) : ?>
			<p><?php szs_boton_noticias( 'leer_ahora', 0, 'Leer los canales ahora', 'button' ); ?></p>
		<?php endif; ?>

		<h2>Añadir un canal</h2>
		<form method="post" style="max-width:720px;">
			<?php wp_nonce_field( 'szs_noticias' ); ?>
			<input type="hidden" name="szs_accion" value="anadir_canal">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_nombre">Nombre</label></th><td><input type="text" id="szs_nombre" name="szs_nombre" class="regular-text" placeholder="INTIA"></td></tr>
				<tr><th><label for="szs_url">Dirección del RSS</label></th><td><input type="url" id="szs_url" name="szs_url" class="large-text" placeholder="https://…/feed/"><p class="description">La del canal RSS o Atom, no la de la portada. En un WordPress suele ser la portada seguida de <code>/feed/</code>.</p></td></tr>
				<tr><th><label for="szs_idioma">Idioma</label></th><td><?php szs_selector( 'szs_idioma', SZS_IDIOMAS_CANAL, 'es' ); ?></td></tr>
				<tr><th><label for="szs_palabras_clave">Palabras clave</label></th><td><textarea id="szs_palabras_clave" name="szs_palabras_clave" rows="2" class="large-text" placeholder="ganader, ovino, vacuno, bovino, ecológic, PAC, abeltzaintza"></textarea><p class="description">Opcional, separadas por comas. Si las ponéis, solo entran las noticias que contengan alguna, sin distinguir mayúsculas ni tildes. Basta con el principio de la palabra: «ganader» encuentra «ganadería» y «ganaderos». Útil para periódicos generalistas.</p></td></tr>
			</table>
			<?php submit_button( 'Añadir y leer' ); ?>
		</form>

		<h2>Últimas noticias (<?php echo esc_html( (string) SZS_DIAS_NOTICIAS_EN_APP ); ?> días)</h2>
		<table class="widefat striped">
			<thead><tr><th>Noticia</th><th>Canal</th><th>Fecha</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $noticias ) ) : ?>
				<tr><td colspan="4">Sin noticias.</td></tr>
			<?php endif; ?>
			<?php foreach ( $noticias as $noticia ) : ?>
				<?php $id = (int) $noticia['id']; ?>
				<tr<?php echo $noticia['oculta'] ? ' style="opacity:.5"' : ''; ?>>
					<td>
						<?php if ( $noticia['fijada'] ) : ?><strong style="color:#b8402a;">Fijada · </strong><?php endif; ?>
						<a href="<?php echo esc_url( (string) $noticia['enlace'] ); ?>" target="_blank" rel="noopener noreferrer"><strong><?php echo esc_html( (string) $noticia['titulo'] ); ?></strong></a>
						<?php if ( '' !== (string) $noticia['entradilla'] ) : ?><br><?php echo esc_html( (string) $noticia['entradilla'] ); ?><?php endif; ?>
					</td>
					<td><?php echo esc_html( (string) $noticia['canal_nombre'] ); ?></td>
					<td><?php echo esc_html( szs_fecha_ms( (int) $noticia['fecha_ms'] ) ); ?></td>
					<td style="white-space:nowrap;">
						<?php szs_boton_noticias( $noticia['fijada'] ? 'desfijar' : 'fijar', $id, $noticia['fijada'] ? 'Desfijar' : 'Fijar' ); ?>
						<?php szs_boton_noticias( $noticia['oculta'] ? 'mostrar' : 'ocultar', $id, $noticia['oculta'] ? 'Mostrar' : 'Ocultar' ); ?>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
	</div>
	<?php
}
