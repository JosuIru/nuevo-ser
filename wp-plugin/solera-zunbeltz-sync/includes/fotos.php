<?php
/**
 * Fotos sincronizadas entre los móviles.
 *
 * La app reduce cada foto (1600 px, JPEG ~80) y la sube con su hash
 * SHA-256; en los datos de las entidades (`datos.fotos`) y de las tareas
 * (`fotos_antes`, `fotos_despues`) solo viajan hashes. El servidor guarda
 * cada foto una vez (el hash es el nombre: dos subidas iguales son la
 * misma) en una carpeta privada dentro de uploads:
 *
 * - con un sufijo aleatorio que se genera al instalar (no hay URL que
 *   adivinar), y además
 * - con `.htaccess` que lo niega todo e `index.php` vacío. En nginx el
 *   `.htaccess` no cuenta: por eso el sufijo (y el filtro
 *   `szs_fotos_directorio` para sacarla de la raíz web).
 *
 * Endpoints (misma auth que `/sync`, clave de usuario):
 *
 * - `POST /fotos/<hash>`: cuerpo en crudo (image/jpeg, png o webp). Se
 *   comprueba la cabecera real del fichero, el tamaño, que el hash
 *   corresponde a los bytes y el espacio total. Si ya estaba, 200 sin
 *   volver a escribirla.
 * - `GET /fotos/<hash>`: la foto, para cualquier persona activa del
 *   espacio (las fotos son de fincas, puntos y tareas, que ve todo el
 *   espacio).
 *
 * El panel enseña miniaturas por `admin-ajax.php?action=szs_foto_panel`,
 * con la sesión de WordPress y el permiso del panel.
 *
 * Las funciones de validación son puras y están en `tests/test_fotos.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Sufijo aleatorio de la carpeta de fotos (opción de WordPress). */
const SZS_OPCION_CARPETA_FOTOS = 'solera_zunbeltz_carpeta_fotos';

/** Tamaño máximo de una foto subida (bytes). Filtro `szs_fotos_tamano_maximo`. */
const SZS_FOTOS_TAMANO_MAXIMO = 2 * 1024 * 1024;

/** Espacio total para fotos (bytes). Filtro `szs_fotos_espacio_maximo`. */
const SZS_FOTOS_ESPACIO_MAXIMO = 1024 * 1024 * 1024;

/** Fotos como mucho en una lista (`fotos`, `fotos_antes`…). */
const SZS_FOTOS_MAXIMO_POR_LISTA = 50;

const SZS_FOTOS_EXTENSIONES = array(
	'image/jpeg' => 'jpg',
	'image/png'  => 'png',
	'image/webp' => 'webp',
);

add_action( 'rest_api_init', 'szs_registrar_rutas_fotos' );
add_action( 'wp_ajax_szs_foto_panel', 'szs_servir_foto_panel' );

function szs_registrar_rutas_fotos(): void {
	$ruta = '/fotos/(?P<hash>[0-9a-f]{64})';
	register_rest_route(
		'solera-zunbeltz/v1',
		$ruta,
		array(
			array(
				'methods'             => 'POST',
				'callback'            => 'szs_endpoint_subir_foto',
				'permission_callback' => 'szs_permiso_token',
			),
			array(
				'methods'             => 'GET',
				'callback'            => 'szs_endpoint_bajar_foto',
				'permission_callback' => 'szs_permiso_token',
			),
		)
	);
}

// ============================================================
// Funciones puras
// ============================================================

function szs_hash_foto_valido( $hash ): bool {
	return is_string( $hash ) && 1 === preg_match( '/^[0-9a-f]{64}$/', $hash );
}

/**
 * Tipo de imagen según los primeros bytes (no según lo que diga quien la
 * sube): JPEG, PNG o WebP; `null` para cualquier otra cosa.
 */
function szs_tipo_mime_imagen( string $bytes ): ?string {
	if ( str_starts_with( $bytes, "\xFF\xD8\xFF" ) ) {
		return 'image/jpeg';
	}
	if ( str_starts_with( $bytes, "\x89PNG\r\n\x1A\n" ) ) {
		return 'image/png';
	}
	if ( strlen( $bytes ) >= 12 && str_starts_with( $bytes, 'RIFF' ) && 'WEBP' === substr( $bytes, 8, 4 ) ) {
		return 'image/webp';
	}
	return null;
}

/**
 * ¿Se acepta esta subida?
 *
 * @param string $hash          Hash que dice la app (el de la URL).
 * @param string $bytes         Cuerpo recibido.
 * @param int    $tamano_maximo Bytes como mucho por foto.
 * @param int    $usado         Bytes que ya ocupan las fotos.
 * @param int    $espacio_total Bytes como mucho entre todas.
 * @param bool   $ya_existe     El servidor ya tiene esa foto.
 * @return array{ok: bool, estado: int, codigo: string, mime: ?string}
 */
function szs_validar_subida_foto( string $hash, string $bytes, int $tamano_maximo, int $usado, int $espacio_total, bool $ya_existe ): array {
	$resultado = static fn( bool $ok, int $estado, string $codigo, ?string $mime = null ): array => array(
		'ok'     => $ok,
		'estado' => $estado,
		'codigo' => $codigo,
		'mime'   => $mime,
	);
	if ( ! szs_hash_foto_valido( $hash ) ) {
		return $resultado( false, 400, 'hash_invalido' );
	}
	if ( '' === $bytes ) {
		return $resultado( false, 400, 'vacia' );
	}
	if ( strlen( $bytes ) > $tamano_maximo ) {
		return $resultado( false, 413, 'demasiado_grande' );
	}
	$mime = szs_tipo_mime_imagen( $bytes );
	if ( null === $mime ) {
		return $resultado( false, 415, 'tipo_no_admitido' );
	}
	if ( ! hash_equals( $hash, hash( 'sha256', $bytes ) ) ) {
		return $resultado( false, 422, 'hash_no_coincide' );
	}
	if ( $ya_existe ) {
		return $resultado( true, 200, 'ya_estaba', $mime );
	}
	if ( $usado + strlen( $bytes ) > $espacio_total ) {
		return $resultado( false, 507, 'sin_espacio' );
	}
	return $resultado( true, 201, 'guardada', $mime );
}

/**
 * Lista de hashes saneada (lo que llega de la app o de la BD): solo hashes
 * válidos, sin repetir, en orden y como mucho `SZS_FOTOS_MAXIMO_POR_LISTA`.
 * Acepta un array o su JSON; cualquier otra cosa da lista vacía.
 *
 * @return string[]
 */
function szs_normalizar_lista_fotos( $valor ): array {
	if ( is_string( $valor ) ) {
		$valor = json_decode( $valor, true );
	}
	if ( ! is_array( $valor ) ) {
		return array();
	}
	$hashes = array();
	foreach ( $valor as $hash ) {
		if ( szs_hash_foto_valido( $hash ) && ! in_array( $hash, $hashes, true ) ) {
			$hashes[] = $hash;
		}
		if ( count( $hashes ) >= SZS_FOTOS_MAXIMO_POR_LISTA ) {
			break;
		}
	}
	return $hashes;
}

/**
 * Una app anterior a las fotos no manda `datos.fotos`: guardar sus datos
 * tal cual borraría las fotos que subió otro móvil. Se conservan.
 */
function szs_conservar_fotos_si_faltan( ?array $existente, array $entrante ): array {
	if ( null === $existente || $entrante['borrado'] || array_key_exists( 'fotos', $entrante['datos'] ) ) {
		return $entrante;
	}
	if ( isset( $existente['datos']['fotos'] ) && is_array( $existente['datos']['fotos'] ) ) {
		$entrante['datos']['fotos'] = $existente['datos']['fotos'];
	}
	return $entrante;
}

/** Ruta relativa (dentro de la carpeta de fotos) de una foto. */
function szs_ruta_relativa_foto( string $hash, string $mime ): string {
	return substr( $hash, 0, 2 ) . '/' . $hash . '.' . ( SZS_FOTOS_EXTENSIONES[ $mime ] ?? 'jpg' );
}

// ============================================================
// Carpeta
// ============================================================

/**
 * Dónde van las fotos: fuera de la raíz web si se puede escribir allí y de
 * verdad queda fuera; si no (o si ya hay fotos en uploads), en uploads.
 */
function szs_elegir_directorio_fotos( string $en_subidas, string $fuera_web, string $raiz_web, bool $ya_hay_en_subidas, bool $fuera_escribible ): string {
	if ( $ya_hay_en_subidas || ! $fuera_escribible ) {
		return $en_subidas;
	}
	$raiz_web = rtrim( $raiz_web, '/' );
	if ( '' !== $raiz_web && ( $fuera_web === $raiz_web || 0 === strpos( $fuera_web, $raiz_web . '/' ) ) ) {
		return $en_subidas;
	}
	return $fuera_web;
}

/** Carpeta privada de fotos, creada y protegida si aún no lo está. */
function szs_directorio_fotos(): string {
	$sufijo = (string) get_option( SZS_OPCION_CARPETA_FOTOS, '' );
	if ( 1 !== preg_match( '/^[0-9a-f]{32}$/', $sufijo ) ) {
		$sufijo = bin2hex( random_bytes( 16 ) );
		update_option( SZS_OPCION_CARPETA_FOTOS, $sufijo, false );
	}
	$nombre     = 'solera-zunbeltz-fotos-' . $sufijo;
	$subidas    = wp_upload_dir( null, false );
	$en_subidas = trailingslashit( $subidas['basedir'] ) . $nombre;
	$fuera_web  = dirname( untrailingslashit( ABSPATH ) ) . '/' . $nombre;
	$raiz_web   = isset( $_SERVER['DOCUMENT_ROOT'] ) ? (string) realpath( (string) $_SERVER['DOCUMENT_ROOT'] ) : '';
	// Con nginx el `.htaccess` no cuenta: por eso, si se puede, la carpeta va
	// al lado de WordPress y fuera de la raíz web. Si ya hay una en uploads (o
	// fuera no se puede escribir), se sigue usando la de uploads.
	$directorio = szs_elegir_directorio_fotos( $en_subidas, $fuera_web, $raiz_web, is_dir( $en_subidas ), is_dir( $fuera_web ) || is_writable( dirname( $fuera_web ) ) );
	// Una ruta absoluta escribible, para quien quiera otra.
	$directorio = untrailingslashit( (string) apply_filters( 'szs_fotos_directorio', $directorio ) );
	if ( ! is_dir( $directorio ) ) {
		wp_mkdir_p( $directorio );
	}
	szs_proteger_directorio_fotos( $directorio );
	return $directorio;
}

/** `.htaccess` que lo niega todo (Apache 2.2 y 2.4) e `index.php` vacío. */
function szs_proteger_directorio_fotos( string $directorio ): void {
	$htaccess = $directorio . '/.htaccess';
	if ( ! file_exists( $htaccess ) ) {
		file_put_contents( $htaccess, "# Solera Zunbeltz: fotos privadas, solo por la API.\n<IfModule mod_authz_core.c>\n\tRequire all denied\n</IfModule>\n<IfModule !mod_authz_core.c>\n\tOrder allow,deny\n\tDeny from all\n</IfModule>\n" );
	}
	$indice = $directorio . '/index.php';
	if ( ! file_exists( $indice ) ) {
		file_put_contents( $indice, "<?php\n// Silence is golden.\n" );
	}
}

/**
 * La foto guardada con ese hash, si la hay.
 *
 * @return array{ruta: string, mime: string}|null
 */
function szs_buscar_foto( string $hash ): ?array {
	if ( ! szs_hash_foto_valido( $hash ) ) {
		return null;
	}
	$directorio = szs_directorio_fotos();
	foreach ( array_keys( SZS_FOTOS_EXTENSIONES ) as $mime ) {
		$ruta = $directorio . '/' . szs_ruta_relativa_foto( $hash, $mime );
		if ( is_file( $ruta ) ) {
			return array(
				'ruta' => $ruta,
				'mime' => $mime,
			);
		}
	}
	return null;
}

/** Bytes que ocupan las fotos guardadas. */
function szs_bytes_fotos_usados(): int {
	$total     = 0;
	$iterador  = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( szs_directorio_fotos(), FilesystemIterator::SKIP_DOTS ) );
	foreach ( $iterador as $fichero ) {
		if ( $fichero->isFile() && in_array( strtolower( $fichero->getExtension() ), SZS_FOTOS_EXTENSIONES, true ) ) {
			$total += (int) $fichero->getSize();
		}
	}
	return $total;
}

// ============================================================
// Endpoints
// ============================================================

function szs_endpoint_subir_foto( WP_REST_Request $request ) {
	$hash       = (string) $request->get_param( 'hash' );
	$bytes      = (string) $request->get_body();
	$existente  = szs_buscar_foto( $hash );
	$tamano_max = (int) apply_filters( 'szs_fotos_tamano_maximo', SZS_FOTOS_TAMANO_MAXIMO );
	$total_max  = (int) apply_filters( 'szs_fotos_espacio_maximo', SZS_FOTOS_ESPACIO_MAXIMO );
	// Contar lo usado solo hace falta para una foto nueva que pasaría el resto.
	$usado      = null === $existente && strlen( $bytes ) <= $tamano_max ? szs_bytes_fotos_usados() : 0;
	$validacion = szs_validar_subida_foto( $hash, $bytes, $tamano_max, $usado, $total_max, null !== $existente );
	if ( ! $validacion['ok'] ) {
		return new WP_REST_Response(
			array(
				'error' => $validacion['codigo'],
				'hash'  => $hash,
			),
			$validacion['estado']
		);
	}
	if ( null === $existente ) {
		$ruta = szs_directorio_fotos() . '/' . szs_ruta_relativa_foto( $hash, $validacion['mime'] );
		wp_mkdir_p( dirname( $ruta ) );
		// Primero a un temporal y luego se renombra: una subida cortada no
		// deja a medias un fichero que ya contaría como «ya estaba».
		$temporal = $ruta . '.' . bin2hex( random_bytes( 4 ) ) . '.tmp';
		if ( false === file_put_contents( $temporal, $bytes ) || ! rename( $temporal, $ruta ) ) {
			if ( file_exists( $temporal ) ) {
				unlink( $temporal );
			}
			return new WP_REST_Response(
				array(
					'error' => 'no_se_pudo_guardar',
					'hash'  => $hash,
				),
				500
			);
		}
	}
	return new WP_REST_Response(
		array(
			'hash'      => $hash,
			'ya_estaba' => null !== $existente,
		),
		$validacion['estado']
	);
}

function szs_endpoint_bajar_foto( WP_REST_Request $request ) {
	$foto = szs_buscar_foto( (string) $request->get_param( 'hash' ) );
	if ( null === $foto ) {
		return new WP_REST_Response( array( 'error' => 'foto_no_encontrada' ), 404 );
	}
	szs_enviar_fichero_foto( $foto['ruta'], $foto['mime'] );
}

/** Manda la foto tal cual y termina (la API REST solo sabe JSON). */
function szs_enviar_fichero_foto( string $ruta, string $mime ): void {
	nocache_headers();
	header( 'Content-Type: ' . $mime );
	header( 'Content-Length: ' . (string) filesize( $ruta ) );
	header( 'X-Content-Type-Options: nosniff' );
	// El contenido de un hash no cambia nunca: que el navegador del panel
	// la guarde, pero solo para esa sesión (privada).
	header( 'Cache-Control: private, max-age=31536000, immutable' );
	header( 'Content-Disposition: inline; filename="' . basename( $ruta ) . '"' );
	readfile( $ruta );
	exit;
}

/** Miniaturas del panel: sesión de WordPress con permiso de panel. */
function szs_servir_foto_panel(): void {
	if ( ! szs_puede_usar_panel() ) {
		status_header( 403 );
		exit;
	}
	check_ajax_referer( 'szs_foto_panel' );
	$foto = szs_buscar_foto( isset( $_GET['hash'] ) ? sanitize_key( wp_unslash( $_GET['hash'] ) ) : '' );
	if ( null === $foto ) {
		status_header( 404 );
		exit;
	}
	szs_enviar_fichero_foto( $foto['ruta'], $foto['mime'] );
}

/** URL de una miniatura para el panel (lleva el nonce de la sesión). */
function szs_url_foto_panel( string $hash ): string {
	return add_query_arg(
		array(
			'action'   => 'szs_foto_panel',
			'hash'     => $hash,
			'_wpnonce' => wp_create_nonce( 'szs_foto_panel' ),
		),
		admin_url( 'admin-ajax.php' )
	);
}

/**
 * Tira de miniaturas para el panel. Las que el servidor aún no tiene (el
 * móvil las sube con wifi) salen como hueco con su texto.
 *
 * @param string[] $hashes
 */
function szs_pintar_fotos_panel( array $hashes ): void {
	if ( empty( $hashes ) ) {
		echo '<span class="description">' . esc_html( szs_t( 'Sin fotos.' ) ) . '</span>';
		return;
	}
	echo '<div class="szs-fotos" style="display:flex;flex-wrap:wrap;gap:8px">';
	foreach ( $hashes as $hash ) {
		if ( null === szs_buscar_foto( $hash ) ) {
			echo '<span class="szs-foto-pendiente" style="display:inline-flex;align-items:center;justify-content:center;width:120px;height:120px;background:#f0f0f1;color:#646970;text-align:center;font-size:12px;padding:4px;box-sizing:border-box">' . esc_html( szs_t( 'Aún no ha llegado (se sube con wifi)' ) ) . '</span>';
			continue;
		}
		$url = szs_url_foto_panel( $hash );
		printf(
			'<a href="%1$s" target="_blank" rel="noopener"><img src="%1$s" alt="%2$s" loading="lazy" style="width:120px;height:120px;object-fit:cover;border:1px solid #dcdcde"></a>',
			esc_url( $url ),
			esc_attr( szs_t( 'Foto' ) )
		);
	}
	echo '</div>';
}
