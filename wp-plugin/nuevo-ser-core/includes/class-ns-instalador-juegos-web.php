<?php
/**
 * Instala y actualiza desde el wp-admin la versión web de los juegos
 * (Nuevo Ser Core → Juegos web), sin subir nada por FTP.
 *
 * El build lo publica `scripts/web/publicar_web.sh <juego>` en GitHub
 * Releases del monorepo:
 *   tag     web-<juego>-<versión>            p. ej. web-uno-roto-1.0.0+20
 *   assets  <juego>-web-<versión>.zip        el contenido de build/web en la raíz
 *           <juego>-web-<versión>.zip.sha256
 *
 * El servidor descarga el zip, comprueba el sha256, lo descomprime al
 * lado y sólo entonces lo cambia por la carpeta
 * `wp-content/uploads/juegos/<juego>/` que lee el shortcode: si algo
 * falla a medias, el juego que había sigue funcionando.
 *
 * La misma pantalla crea la página del juego (`/jugar/` con
 * [uno_roto]) con la plantilla «Página del juego» del tema Uno Roto.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Instalador_Juegos_Web {

	private const SLUG           = 'nuevo-ser-core-juegos';
	private const NONCE          = 'ns_juegos_web';
	private const OPCION_PREFIJO = 'ns_juego_web_version_';

	/** Página de cada juego: slug, título y shortcode con portada. */
	const PAGINAS = array(
		'uno-roto'      => array( 'jugar', 'Uno Roto', 'uno_roto' ),
		'las-versiones' => array( 'las-versiones', 'Las Versiones', 'las_versiones' ),
	);

	/** Plantilla del tema Uno Roto que deja la portada a todo el ancho. */
	const PLANTILLA = 'pagina-juego';

	public static function registrar(): void {
		add_action( 'admin_menu', array( __CLASS__, 'anadir_menu' ), 20 );
		add_action( 'admin_post_ns_instalar_juego_web', array( __CLASS__, 'manejar_instalar' ) );
		add_action( 'admin_post_ns_crear_pagina_juego', array( __CLASS__, 'manejar_crear_pagina' ) );
	}

	public static function anadir_menu(): void {
		add_submenu_page(
			'nuevo-ser-core',
			'Juegos web',
			'Juegos web',
			'manage_options',
			self::SLUG,
			array( __CLASS__, 'pintar' )
		);
	}

	/** URL de esta pantalla del admin. */
	public static function url_admin(): string {
		return admin_url( 'admin.php?page=' . self::SLUG );
	}

	// =================================================================
	// Lógica pura (cubierta por tests/test_instalador_juegos_web.php)
	// =================================================================

	/**
	 * El build web más reciente de [juego] entre los releases (el más
	 * nuevo primero, como los devuelve la API de GitHub).
	 *
	 * @return array|null url, url_sha256, version, tamano, fecha; o null.
	 */
	public static function elegir_build( array $releases, string $juego ): ?array {
		$prefijo = 'web-' . $juego . '-';
		foreach ( $releases as $release ) {
			if ( ! is_array( $release ) || ! empty( $release['draft'] ) || ! empty( $release['prerelease'] ) ) {
				continue;
			}
			$tag = (string) ( $release['tag_name'] ?? '' );
			// La versión empieza por dígito: «web-uno-roto-…» no vale para otro juego con ese prefijo.
			if ( 0 !== strpos( $tag, $prefijo ) || ! ctype_digit( substr( $tag, strlen( $prefijo ), 1 ) ) ) {
				continue;
			}
			$zip    = null;
			$sha256 = null;
			foreach ( (array) ( $release['assets'] ?? array() ) as $asset ) {
				$nombre = (string) ( $asset['name'] ?? '' );
				$url    = (string) ( $asset['browser_download_url'] ?? '' );
				if ( '' === $url ) {
					continue;
				}
				if ( '.zip' === substr( $nombre, -4 ) ) {
					$zip = $asset;
				} elseif ( '.zip.sha256' === substr( $nombre, -11 ) ) {
					$sha256 = $url;
				}
			}
			// Sin sha256 no se instala: es lo que garantiza que el zip llegó entero.
			if ( null !== $zip && null !== $sha256 ) {
				return array(
					'url'        => (string) $zip['browser_download_url'],
					'url_sha256' => $sha256,
					'version'    => substr( $tag, strlen( $prefijo ) ),
					'tamano'     => (int) ( $zip['size'] ?? 0 ),
					'fecha'      => (string) ( $release['published_at'] ?? '' ),
				);
			}
		}
		return null;
	}

	/** Primer hash sha256 (64 hex) de un fichero `.sha256` («<hash>  <nombre>»), o null. */
	public static function leer_sha256( string $contenido ): ?string {
		return preg_match( '/\b([0-9a-f]{64})\b/i', $contenido, $coincidencia ) ? strtolower( $coincidencia[1] ) : null;
	}

	/** Si una entrada del zip se queda dentro de la carpeta destino (nada de «../» ni rutas absolutas). */
	public static function ruta_segura_en_zip( string $nombre ): bool {
		if ( '' === $nombre || false !== strpos( $nombre, "\0" ) || false !== strpos( $nombre, '\\' ) ) {
			return false;
		}
		if ( '/' === $nombre[0] || preg_match( '/^[a-z]:/i', $nombre ) ) {
			return false;
		}
		return ! in_array( '..', explode( '/', $nombre ), true );
	}

	// =================================================================
	// Instalación
	// =================================================================

	/** Versión instalada desde aquí; '' si se subió a mano o no hay. */
	public static function version_instalada( string $juego ): string {
		return (string) get_option( self::OPCION_PREFIJO . $juego, '' );
	}

	/**
	 * Descarga, comprueba e instala el último build web de [juego].
	 *
	 * @return string|WP_Error La versión instalada.
	 */
	public static function instalar( string $juego ) {
		$build = self::elegir_build( NS_Descargas_Apk::releases( true ), $juego );
		if ( null === $build ) {
			return new WP_Error( 'sin_build', 'No hay ninguna versión web publicada en GitHub (o GitHub no responde).' );
		}

		$respuesta_sha = wp_remote_get( $build['url_sha256'], array( 'timeout' => 15 ) );
		$esperado      = is_wp_error( $respuesta_sha ) ? null : self::leer_sha256( wp_remote_retrieve_body( $respuesta_sha ) );
		if ( null === $esperado ) {
			return new WP_Error( 'sin_sha256', 'No se pudo leer el sha256 del build.' );
		}

		if ( function_exists( 'set_time_limit' ) ) {
			@set_time_limit( 900 ); // phpcs:ignore WordPress.PHP.NoSilencedErrors -- hay hostings que lo prohíben.
		}
		require_once ABSPATH . 'wp-admin/includes/file.php';
		$zip_temporal = download_url( $build['url'], 900 );
		if ( is_wp_error( $zip_temporal ) ) {
			return new WP_Error( 'descarga', 'La descarga falló: ' . $zip_temporal->get_error_message() );
		}

		try {
			if ( ! hash_equals( $esperado, (string) hash_file( 'sha256', $zip_temporal ) ) ) {
				return new WP_Error( 'sha256', 'El zip descargado no coincide con su sha256. Prueba otra vez.' );
			}
			$resultado = self::sustituir_carpeta( $juego, $zip_temporal );
			if ( is_wp_error( $resultado ) ) {
				return $resultado;
			}
		} finally {
			wp_delete_file( $zip_temporal );
		}

		update_option( self::OPCION_PREFIJO . $juego, $build['version'], false );
		return $build['version'];
	}

	/**
	 * Descomprime [zip] junto a la carpeta del juego y la cambia por la
	 * actual en dos renombrados.
	 *
	 * @return true|WP_Error
	 */
	private static function sustituir_carpeta( string $juego, string $zip ) {
		if ( ! class_exists( 'ZipArchive' ) ) {
			return new WP_Error( 'sin_zip', 'El PHP del servidor no tiene la extensión zip.' );
		}
		$subidas = wp_upload_dir();
		$base    = trailingslashit( $subidas['basedir'] ) . 'juegos';
		$destino = $base . '/' . $juego;
		$nueva   = $base . '/.' . $juego . '-nueva';
		$vieja   = $base . '/.' . $juego . '-vieja';

		if ( ! wp_mkdir_p( $base ) ) {
			return new WP_Error( 'permisos', 'No se puede escribir en ' . $base . '.' );
		}
		self::borrar_carpeta( $nueva );
		self::borrar_carpeta( $vieja );

		$archivo = new ZipArchive();
		if ( true !== $archivo->open( $zip ) ) {
			return new WP_Error( 'zip', 'El zip descargado está dañado.' );
		}
		for ( $indice = 0; $indice < $archivo->numFiles; $indice++ ) {
			if ( ! self::ruta_segura_en_zip( (string) $archivo->getNameIndex( $indice ) ) ) {
				$archivo->close();
				return new WP_Error( 'zip', 'El zip trae rutas fuera de su carpeta: no se instala.' );
			}
		}
		$extraido = wp_mkdir_p( $nueva ) && $archivo->extractTo( $nueva );
		$archivo->close();
		if ( ! $extraido || ! file_exists( $nueva . '/index.html' ) ) {
			self::borrar_carpeta( $nueva );
			return new WP_Error( 'zip', 'No se pudo descomprimir el juego (¿falta espacio o permisos?).' );
		}

		if ( is_dir( $destino ) && ! rename( $destino, $vieja ) ) {
			self::borrar_carpeta( $nueva );
			return new WP_Error( 'permisos', 'No se pudo apartar la versión anterior.' );
		}
		if ( ! rename( $nueva, $destino ) ) {
			// Se devuelve la anterior a su sitio para no dejar el juego sin carpeta.
			if ( is_dir( $vieja ) ) {
				rename( $vieja, $destino );
			}
			self::borrar_carpeta( $nueva );
			return new WP_Error( 'permisos', 'No se pudo colocar la versión nueva.' );
		}
		self::borrar_carpeta( $vieja );
		return true;
	}

	private static function borrar_carpeta( string $carpeta ): void {
		if ( ! is_dir( $carpeta ) ) {
			return;
		}
		$elementos = new RecursiveIteratorIterator(
			new RecursiveDirectoryIterator( $carpeta, FilesystemIterator::SKIP_DOTS ),
			RecursiveIteratorIterator::CHILD_FIRST
		);
		foreach ( $elementos as $elemento ) {
			$elemento->isDir() ? rmdir( $elemento->getPathname() ) : unlink( $elemento->getPathname() );
		}
		rmdir( $carpeta );
	}

	// =================================================================
	// Página del juego
	// =================================================================

	/** Página publicada (o en borrador) que ya lleva el shortcode de [juego], o null. */
	public static function pagina_del_juego( string $juego ): ?WP_Post {
		if ( ! isset( self::PAGINAS[ $juego ] ) ) {
			return null;
		}
		$shortcode = self::PAGINAS[ $juego ][2];
		$paginas   = get_posts(
			array(
				'post_type'      => 'page',
				'post_status'    => array( 'publish', 'draft', 'private' ),
				'posts_per_page' => 50,
				's'              => '[' . $shortcode,
			)
		);
		foreach ( $paginas as $pagina ) {
			if ( has_shortcode( $pagina->post_content, $shortcode ) ) {
				return $pagina;
			}
		}
		return null;
	}

	/** @return int|WP_Error Id de la página creada. */
	public static function crear_pagina( string $juego ) {
		if ( ! isset( self::PAGINAS[ $juego ] ) ) {
			return new WP_Error( 'juego', 'Juego desconocido.' );
		}
		$existente = self::pagina_del_juego( $juego );
		if ( null !== $existente ) {
			return $existente->ID;
		}
		list( $slug, $titulo, $shortcode ) = self::PAGINAS[ $juego ];
		$id = wp_insert_post(
			array(
				'post_type'    => 'page',
				'post_status'  => 'publish',
				'post_title'   => $titulo,
				'post_name'    => $slug,
				'post_content' => '<!-- wp:shortcode -->[' . $shortcode . ']<!-- /wp:shortcode -->',
			),
			true
		);
		if ( is_wp_error( $id ) ) {
			return $id;
		}
		// La plantilla sólo existe con el tema Uno Roto; con otro tema se queda la de por defecto.
		$plantillas = wp_get_theme()->get_page_templates( get_post( $id ) );
		if ( isset( $plantillas[ self::PLANTILLA ] ) ) {
			update_post_meta( $id, '_wp_page_template', self::PLANTILLA );
		}
		return $id;
	}

	// =================================================================
	// Pantalla
	// =================================================================

	public static function pintar(): void {
		if ( ! current_user_can( 'manage_options' ) ) {
			wp_die( esc_html__( 'No tienes permiso para ver esta página.' ) );
		}
		$releases = NS_Descargas_Apk::releases();
		?>
		<div class="wrap">
			<h1>Juegos web</h1>
			<?php self::pintar_aviso(); ?>
			<p>
				Instala la versión web de cada juego desde GitHub Releases en
				<code>wp-content/uploads/juegos/</code> y crea su página. Descargar
				un juego tarda uno o dos minutos (unos 50 MB): no cierres la pestaña.
			</p>
			<table class="widefat striped">
				<thead>
					<tr>
						<th>Juego</th>
						<th>Instalado</th>
						<th>Última publicada</th>
						<th></th>
						<th>Página</th>
					</tr>
				</thead>
				<tbody>
				<?php foreach ( NS_Juegos_Web::JUEGOS as $juego => $nombre ) : ?>
					<?php
					$instalada = self::version_instalada( $juego );
					$hay_build = null !== NS_Juegos_Web::ubicacion( $juego );
					$ultima    = self::elegir_build( $releases, $juego );
					$pagina    = self::pagina_del_juego( $juego );
					?>
					<tr>
						<td><strong><?php echo esc_html( $nombre ); ?></strong></td>
						<td>
							<?php
							if ( ! $hay_build ) {
								echo '<span style="color:#b32d2e;">✗ no instalado</span>';
							} elseif ( '' === $instalada ) {
								echo 'subido a mano';
							} else {
								echo '<code>' . esc_html( $instalada ) . '</code>';
							}
							?>
						</td>
						<td>
							<?php
							if ( null === $ultima ) {
								echo '—';
							} else {
								echo '<code>' . esc_html( $ultima['version'] ) . '</code>';
								if ( $ultima['tamano'] > 0 ) {
									echo ' · ' . esc_html( size_format( $ultima['tamano'] ) );
								}
							}
							?>
						</td>
						<td>
							<?php if ( null !== $ultima ) : ?>
								<form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
									<?php wp_nonce_field( self::NONCE ); ?>
									<input type="hidden" name="action" value="ns_instalar_juego_web">
									<input type="hidden" name="juego" value="<?php echo esc_attr( $juego ); ?>">
									<?php
									$al_dia = $hay_build && $instalada === $ultima['version'];
									submit_button( $al_dia ? 'Reinstalar' : ( $hay_build ? 'Actualizar' : 'Instalar' ), $al_dia ? 'secondary' : 'primary', 'submit', false );
									?>
								</form>
							<?php endif; ?>
						</td>
						<td>
							<?php if ( null !== $pagina ) : ?>
								<a href="<?php echo esc_url( get_permalink( $pagina ) ); ?>"><?php echo esc_html( wp_make_link_relative( get_permalink( $pagina ) ) ); ?></a>
								<?php echo 'publish' === $pagina->post_status ? '' : ' (' . esc_html( $pagina->post_status ) . ')'; ?>
							<?php elseif ( isset( self::PAGINAS[ $juego ] ) ) : ?>
								<form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
									<?php wp_nonce_field( self::NONCE ); ?>
									<input type="hidden" name="action" value="ns_crear_pagina_juego">
									<input type="hidden" name="juego" value="<?php echo esc_attr( $juego ); ?>">
									<?php submit_button( 'Crear /' . self::PAGINAS[ $juego ][0] . '/', 'secondary', 'submit', false ); ?>
								</form>
							<?php endif; ?>
						</td>
					</tr>
				<?php endforeach; ?>
				</tbody>
			</table>
		</div>
		<?php
	}

	public static function manejar_instalar(): void {
		$juego = self::juego_de_la_peticion();
		@ignore_user_abort( true ); // phpcs:ignore WordPress.PHP.NoSilencedErrors -- que no se corte a medias si se cierra la pestaña.
		$resultado = self::instalar( $juego );
		if ( is_wp_error( $resultado ) ) {
			self::redirigir( 'error', $resultado->get_error_message() );
		}
		self::redirigir( 'ok', NS_Juegos_Web::JUEGOS[ $juego ] . ' ' . $resultado . ' instalado.' );
	}

	public static function manejar_crear_pagina(): void {
		$juego     = self::juego_de_la_peticion();
		$resultado = self::crear_pagina( $juego );
		if ( is_wp_error( $resultado ) ) {
			self::redirigir( 'error', $resultado->get_error_message() );
		}
		self::redirigir( 'ok', 'Página creada: ' . wp_make_link_relative( (string) get_permalink( $resultado ) ) );
	}

	/** Comprueba permiso y nonce y devuelve el juego pedido (o corta). */
	private static function juego_de_la_peticion(): string {
		if ( ! current_user_can( 'manage_options' ) ) {
			wp_die( esc_html__( 'No tienes permiso.' ) );
		}
		check_admin_referer( self::NONCE );
		$juego = sanitize_key( wp_unslash( $_POST['juego'] ?? '' ) );
		if ( ! isset( NS_Juegos_Web::JUEGOS[ $juego ] ) ) {
			wp_die( 'Juego desconocido.' );
		}
		return $juego;
	}

	/** El mensaje viaja en un transient del usuario: no cabe bien en la URL. */
	private static function redirigir( string $tipo, string $texto ): void {
		set_transient( 'ns_juegos_web_aviso_' . get_current_user_id(), array( $tipo, $texto ), MINUTE_IN_SECONDS );
		wp_safe_redirect( self::url_admin() );
		exit;
	}

	private static function pintar_aviso(): void {
		$clave = 'ns_juegos_web_aviso_' . get_current_user_id();
		$aviso = get_transient( $clave );
		if ( ! is_array( $aviso ) ) {
			return;
		}
		delete_transient( $clave );
		printf(
			'<div class="notice notice-%s is-dismissible"><p>%s</p></div>',
			'ok' === $aviso[0] ? 'success' : 'error',
			esc_html( $aviso[1] )
		);
	}
}
