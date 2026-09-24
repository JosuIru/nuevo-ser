<?php
/**
 * Juegos de la Colección en versión web (build de Flutter web)
 * incrustados en una página con shortcode:
 *
 *   [uno_roto]
 *   [las_versiones]
 *   [nuevo_ser_juego juego="uno-roto" alto="100vh"]
 *
 * El build NO va dentro del plugin (pesa ~50 MB y muchos WordPress
 * limitan la subida de zips): se despliega aparte en
 * `wp-content/uploads/juegos/<juego>/` con el script
 * `scripts/web/desplegar.sh <juego>` del monorepo. El juego habla
 * con el backend de este mismo WordPress (mismo origen, sin CORS).
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Juegos_Web {

	/** Juegos con versión web desplegable. */
	const JUEGOS = array(
		'uno-roto'      => 'Uno Roto',
		'las-versiones' => 'Las Versiones',
	);

	public static function registrar(): void {
		add_filter( 'body_class', array( __CLASS__, 'clase_de_pagina' ) );
		add_shortcode( 'nuevo_ser_juego', array( __CLASS__, 'shortcode' ) );
		add_shortcode(
			'uno_roto',
			static function ( $atributos ) {
				$atributos           = is_array( $atributos ) ? $atributos : array();
				$atributos['juego'] = 'uno-roto';
				if ( ! isset( $atributos['portada'] ) ) {
					$atributos['portada'] = 'si';
				}
				return self::shortcode( $atributos );
			}
		);
		add_shortcode(
			'las_versiones',
			static function ( $atributos ) {
				$atributos          = is_array( $atributos ) ? $atributos : array();
				$atributos['juego'] = 'las-versiones';
				return self::shortcode( $atributos );
			}
		);
	}

	/** Marca la página que lleva [uno_roto] para vestir de noche el tema. */
	public static function clase_de_pagina( array $clases ): array {
		$entrada = is_singular() ? get_post() : null;
		if ( $entrada && has_shortcode( $entrada->post_content, 'uno_roto' ) ) {
			$clases[] = 'ns-ur-pagina';
			// La hoja se necesita ya para la cabecera, antes del contenido.
			wp_enqueue_style( 'ns-portada-juegos', NS_CORE_URL . 'assets/juegos-web/portada.css', array(), NS_CORE_VERSION );
		}
		return $clases;
	}

	/** Carpeta y URL del build desplegado de [juego], o null si no está. */
	public static function ubicacion( string $juego ): ?array {
		$subidas = wp_upload_dir();
		$carpeta = trailingslashit( $subidas['basedir'] ) . 'juegos/' . $juego;
		if ( ! file_exists( $carpeta . '/index.html' ) ) {
			return null;
		}
		return array(
			'carpeta' => $carpeta,
			'url'     => trailingslashit( $subidas['baseurl'] ) . 'juegos/' . $juego . '/',
		);
	}

	/** Las máquinas de Rexán que enseña la portada (id del arte, nombre, qué se hace). */
	const MAQUINAS_UNO_ROTO = array(
		array( 'puentes', 'Puentes', 'Cubre el hueco con tablones. El carro sólo cruza si la medida es exacta.' ),
		array( 'encaje', 'Encaje', 'Caen trozos de fracción. Cada fila completa es una unidad entera.' ),
		array( 'canales', 'Canales', 'Recorre el laberinto y cómete sólo los números que cumplen la regla.' ),
		array( 'parejas', 'Parejas', 'Dos cartas que valen lo mismo aunque estén escritas distinto.' ),
		array( 'minas', 'Minas', 'Abre las casillas seguras y marca las minas. La regla dice cuáles son.' ),
		array( 'serpiente', 'Serpiente', 'Lleva la serpiente hasta el resultado, entre muros y números que se mueven.' ),
		array( 'balanza', 'Balanza', 'Prueba un valor para la x y mira hacia dónde se inclina.' ),
		array( 'flota', 'La flota', 'Rexán canta las coordenadas en cálculo. Tú apuntas.' ),
		array( 'salto', 'Salto', 'Corre, salta y elige la puerta del resultado: arriba o abajo.' ),
	);

	/**
	 * @param array|string $atributos juego (id), alto (px, vh o %) y
	 *                                portada ("si" para la página completa,
	 *                                sólo en Uno Roto; "no" para el juego solo).
	 */
	public static function shortcode( $atributos ): string {
		$atributos = shortcode_atts(
			array(
				'juego'   => 'uno-roto',
				'alto'    => '100vh',
				'portada' => '',
			),
			is_array( $atributos ) ? $atributos : array(),
			'nuevo_ser_juego'
		);
		$juego = sanitize_key( $atributos['juego'] );
		if ( ! isset( self::JUEGOS[ $juego ] ) ) {
			return '';
		}
		$alto = preg_match( '/^\d{2,4}(px|vh|%)$/', $atributos['alto'] ) ? $atributos['alto'] : '100vh';

		$ubicacion = self::ubicacion( $juego );
		if ( null === $ubicacion ) {
			// Sólo quien administra ve el aviso; los visitantes, nada.
			if ( current_user_can( 'manage_options' ) ) {
				return '<p><strong>Nuevo Ser:</strong> falta desplegar la versión web de '
					. esc_html( self::JUEGOS[ $juego ] ) . ' en <code>wp-content/uploads/juegos/'
					. esc_html( $juego ) . '/</code> (script <code>scripts/web/desplegar.sh ' . esc_html( $juego ) . '</code>).</p>';
			}
			return '';
		}

		// [uno_roto] trae la portada completa salvo portada="no";
		// [nuevo_ser_juego] sólo el juego salvo portada="si".
		if ( 'uno-roto' === $juego && 'si' === $atributos['portada'] ) {
			return self::portada_uno_roto( $ubicacion['url'] );
		}

		$titulo = self::JUEGOS[ $juego ];
		// Formato de móvil también en escritorio: el juego es vertical.
		return sprintf(
			'<div class="ns-juego-web" style="width:100%%;max-width:480px;margin:0 auto;height:%1$s;">'
			. '<iframe src="%2$s" title="%3$s" style="border:0;width:100%%;height:100%%;display:block;" '
			. 'allow="fullscreen; autoplay" allowfullscreen></iframe>'
			. '<p style="text-align:center;font-size:.85em;margin:.5em 0 0;">'
			. '<a href="%2$s" target="_blank" rel="noopener">%4$s</a></p></div>',
			esc_attr( $alto ),
			esc_url( $ubicacion['url'] . 'index.html' ),
			esc_attr( $titulo ),
			esc_html__( 'Abrir a pantalla completa', 'nuevo-ser-core' )
		);
	}

	/** Página completa de Uno Roto: portada con el juego, máquinas y principios. */
	private static function portada_uno_roto( string $url_juego ): string {
		$recursos = NS_CORE_URL . 'assets/juegos-web/';
		wp_enqueue_style( 'ns-portada-juegos', $recursos . 'portada.css', array(), NS_CORE_VERSION );
		wp_enqueue_script( 'ns-portada-juegos', $recursos . 'portada.js', array(), NS_CORE_VERSION, true );

		$arte  = $url_juego . 'assets/assets/';
		$fuentes = $arte . 'fonts/';
		wp_add_inline_style(
			'ns-portada-juegos',
			'@font-face{font-family:"UR Roboto";src:url("' . esc_url( $fuentes . 'Roboto-Light.ttf' ) . '") format("truetype");font-weight:300;font-display:swap}'
			. '@font-face{font-family:"UR Roboto";src:url("' . esc_url( $fuentes . 'Roboto-Regular.ttf' ) . '") format("truetype");font-weight:400;font-display:swap}'
			. '@font-face{font-family:"UR Cormorant";src:url("' . esc_url( $fuentes . 'CormorantGaramond-Italic-Variable.ttf' ) . '") format("truetype");font-style:italic;font-display:swap}'
		);

		$juego    = esc_url( $url_juego . 'index.html' );
		$skyline  = esc_url( $arte . 'escenarios/canales_on.webp' );
		$id       = 'ns-ur-consola-' . wp_unique_id();
		$icono_pc = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"/></svg>';

		$maquinas = '';
		foreach ( self::MAQUINAS_UNO_ROTO as list( $clave, $nombre, $descripcion ) ) {
			$maquinas .= sprintf(
				'<li class="ns-ur-maquina"><div class="ns-ur-maquina-imagen">'
				. '<img src="%1$s" alt="%2$s" loading="lazy" width="400" height="528"></div>'
				. '<h3>%3$s</h3><p>%4$s</p></li>',
				esc_url( $arte . 'maquinas/' . $clave . '_on.png' ),
				/* translators: %s: nombre de la máquina */
				esc_attr( sprintf( __( 'Máquina recreativa %s encendida', 'nuevo-ser-core' ), $nombre ) ),
				esc_html( $nombre ),
				esc_html( $descripcion )
			);
		}

		ob_start();
		?>
<div class="ns-ur alignfull">
	<section class="ns-ur-portada" style="--ur-skyline:url('<?php echo $skyline; // phpcs:ignore WordPress.Security.EscapeOutput -- ya escapado ?>')">
		<div class="ns-ur-skyline" aria-hidden="true"></div>
		<div class="ns-ur-portada-rejilla">
			<div class="ns-ur-portada-texto">
				<h1 class="ns-ur-titulo">UNO ROTO</h1>
				<p class="ns-ur-subtitulo ns-ur-serif"><?php esc_html_e( 'Una ciudad a oscuras que se enciende pensando.', 'nuevo-ser-core' ); ?></p>
				<p class="ns-ur-entrada">
					<?php
					echo wp_kses(
						__( 'Kai y Oryn recorren los siete distritos de una ciudad que se ha quedado sin luz. Cada cuenta bien pensada devuelve una farola, un puente, una calle. En los recreativos, <strong>Rexán</strong> guarda nueve máquinas donde las matemáticas se juegan. Para chicas y chicos de <strong>9 a 12 años</strong>.', 'nuevo-ser-core' ),
						array( 'strong' => array() )
					);
					?>
				</p>
				<div class="ns-ur-acciones">
					<button type="button" class="ns-ur-boton" data-ns-ur-pantalla-completa="<?php echo esc_attr( $id ); ?>" data-ns-ur-url="<?php echo $juego; // phpcs:ignore WordPress.Security.EscapeOutput ?>">
						<?php echo $icono_pc; // phpcs:ignore WordPress.Security.EscapeOutput -- SVG fijo ?>
						<?php esc_html_e( 'Jugar a pantalla completa', 'nuevo-ser-core' ); ?>
					</button>
					<a class="ns-ur-enlace" href="<?php echo $juego; // phpcs:ignore WordPress.Security.EscapeOutput ?>" target="_blank" rel="noopener"><?php esc_html_e( 'Abrir en otra pestaña', 'nuevo-ser-core' ); ?></a>
				</div>
				<ul class="ns-ur-datos">
					<li><?php esc_html_e( 'Sin puntos ni «game over»', 'nuevo-ser-core' ); ?></li>
					<li><?php esc_html_e( 'Funciona sin conexión', 'nuevo-ser-core' ); ?></li>
					<li><?php esc_html_e( 'Castellano, euskara y català', 'nuevo-ser-core' ); ?></li>
				</ul>
			</div>
			<div class="ns-ur-consola" id="<?php echo esc_attr( $id ); ?>">
				<iframe src="<?php echo $juego; // phpcs:ignore WordPress.Security.EscapeOutput ?>" title="Uno Roto" allow="fullscreen; autoplay" allowfullscreen></iframe>
			</div>
		</div>
	</section>

	<section class="ns-ur-seccion">
		<div class="ns-ur-seccion-interior">
			<h2><?php esc_html_e( 'Las nueve máquinas de Rexán', 'nuevo-ser-core' ); ?></h2>
			<p class="ns-ur-seccion-entrada"><?php esc_html_e( 'Recreativos viejos que sólo funcionan con matemáticas: fracciones, porcentajes, divisibilidad, ecuaciones. Cada ronda sube un poco la dificultad, y si alguien se atasca, Rexán le enseña un ejemplo parecido resuelto paso a paso.', 'nuevo-ser-core' ); ?></p>
			<ul class="ns-ur-maquinas"><?php echo $maquinas; // phpcs:ignore WordPress.Security.EscapeOutput -- escapado arriba ?></ul>
		</div>
	</section>

	<section class="ns-ur-seccion">
		<div class="ns-ur-seccion-interior">
			<h2><?php esc_html_e( 'Para familias y docentes', 'nuevo-ser-core' ); ?></h2>
			<p class="ns-ur-seccion-entrada"><?php esc_html_e( 'Uno Roto forma parte de la Colección Nuevo Ser Kids: juegos que tratan a quien juega como alguien capaz de pensar.', 'nuevo-ser-core' ); ?></p>
			<div class="ns-ur-principios">
				<div class="ns-ur-principio">
					<h3 class="ns-ur-serif"><?php esc_html_e( 'Progreso honesto', 'nuevo-ser-core' ); ?></h3>
					<p><?php esc_html_e( 'El juego sólo apunta que algo se domina cuando se ha decidido bien y sin que nadie haya dado la respuesta. Equivocarse no resta: se vuelve a intentar.', 'nuevo-ser-core' ); ?></p>
				</div>
				<div class="ns-ur-principio">
					<h3 class="ns-ur-serif"><?php esc_html_e( 'Sin anuncios ni trucos', 'nuevo-ser-core' ); ?></h3>
					<p><?php esc_html_e( 'No hay anuncios, compras, rankings ni contadores de vidas. Tampoco rastreadores: la página no pide nada a servidores de terceros.', 'nuevo-ser-core' ); ?></p>
				</div>
				<div class="ns-ur-principio">
					<h3 class="ns-ur-serif"><?php esc_html_e( 'Instálalo en el móvil', 'nuevo-ser-core' ); ?></h3>
					<p><?php esc_html_e( 'Abre el juego en su pestaña y elige «Añadir a la pantalla de inicio». Después se abre como una aplicación y funciona sin conexión.', 'nuevo-ser-core' ); ?></p>
				</div>
			</div>
		</div>
	</section>

</div>
		<?php
		return (string) ob_get_clean();
	}
}
