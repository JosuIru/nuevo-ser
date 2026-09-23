<?php
/**
 * Juegos de la Colección en versión web (build de Flutter web)
 * incrustados en una página con shortcode:
 *
 *   [uno_roto]
 *   [nuevo_ser_juego juego="uno-roto" alto="100vh"]
 *
 * El build NO va dentro del plugin (pesa ~50 MB y muchos WordPress
 * limitan la subida de zips): se despliega aparte en
 * `wp-content/uploads/juegos/<juego>/` con el script
 * `apps/<juego>/scripts/web/desplegar.sh` del monorepo. El juego habla
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
		'uno-roto' => 'Uno Roto',
	);

	public static function registrar(): void {
		add_shortcode( 'nuevo_ser_juego', array( __CLASS__, 'shortcode' ) );
		add_shortcode(
			'uno_roto',
			static function ( $atributos ) {
				$atributos           = is_array( $atributos ) ? $atributos : array();
				$atributos['juego'] = 'uno-roto';
				return self::shortcode( $atributos );
			}
		);
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

	/**
	 * @param array|string $atributos juego (id) y alto (px, vh o %).
	 */
	public static function shortcode( $atributos ): string {
		$atributos = shortcode_atts(
			array(
				'juego' => 'uno-roto',
				'alto'  => '100vh',
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
					. esc_html( $juego ) . '/</code> (script <code>scripts/web/desplegar.sh</code>).</p>';
			}
			return '';
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
}
