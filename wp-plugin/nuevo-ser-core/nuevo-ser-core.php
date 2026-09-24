<?php
/**
 * Plugin Name: Nuevo Ser Core
 * Plugin URI:  https://coleccion-nuevo-ser.com/
 * Description: Backend compartido de la Colección Nuevo Ser Kids: sync, auth y tutor IA
 *              para Uno Roto y futuros juegos. Expone /wp-json/nuevo-ser/v1/* (canónico)
 *              y /wp-json/uno-roto/v1/* (alias deprecado, vivo hasta v1.5) con JWT propios.
 * Version:     0.18.1
 * Author:      Equipo Colección Nuevo Ser
 * Author URI:  https://coleccion-nuevo-ser.com/
 * License:     GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: nuevo-ser-core
 * Requires PHP: 8.1
 * Requires at least: 6.4
 * Replaces: uno-roto-core
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'NS_CORE_VERSION', '0.18.1' );
define( 'NS_CORE_DIR', plugin_dir_path( __FILE__ ) );
define( 'NS_CORE_URL', plugin_dir_url( __FILE__ ) );

/*
 * Aliases retro-compatibles. El plugin antiguo `uno-roto-core` definía estas
 * tres constantes; algunas instalaciones de testers o código de terceros
 * pueden depender de ellas. Mantenerlas evita romper imports y permite la
 * desactivación silenciosa del plugin antiguo en la activación.
 *
 * Se eliminan cuando todos los testers hayan migrado (no antes de v1.5).
 */
if ( ! defined( 'UROTO_CORE_VERSION' ) ) {
	define( 'UROTO_CORE_VERSION', NS_CORE_VERSION );
}
if ( ! defined( 'UROTO_CORE_DIR' ) ) {
	define( 'UROTO_CORE_DIR', NS_CORE_DIR );
}
if ( ! defined( 'UROTO_CORE_URL' ) ) {
	define( 'UROTO_CORE_URL', NS_CORE_URL );
}

require_once NS_CORE_DIR . 'includes/class-ns-esquema.php';
require_once NS_CORE_DIR . 'includes/class-ns-activacion.php';
require_once NS_CORE_DIR . 'includes/class-ns-jwt.php';
require_once NS_CORE_DIR . 'includes/class-ns-repositorio.php';
require_once NS_CORE_DIR . 'includes/class-ns-sincronizador.php';
require_once NS_CORE_DIR . 'includes/class-ns-filtro-tutor.php';
require_once NS_CORE_DIR . 'includes/class-ns-anthropic.php';
require_once NS_CORE_DIR . 'includes/class-ns-tutor.php';
require_once NS_CORE_DIR . 'includes/class-ns-mastery.php';
require_once NS_CORE_DIR . 'includes/class-ns-perfil-p5.php';
require_once NS_CORE_DIR . 'includes/class-ns-reset-password.php';
require_once NS_CORE_DIR . 'includes/class-ns-companion-cuaderno.php';
require_once NS_CORE_DIR . 'includes/class-ns-companion-mosaicos.php';
require_once NS_CORE_DIR . 'includes/class-ns-companion-aulas.php';
require_once NS_CORE_DIR . 'includes/class-ns-companion-agregados.php';
require_once NS_CORE_DIR . 'includes/class-ns-auth-adulto.php';
require_once NS_CORE_DIR . 'includes/class-ns-caregivers.php';
require_once NS_CORE_DIR . 'includes/class-ns-el-cuaderno.php';
require_once NS_CORE_DIR . 'includes/class-ns-fosiles-comunidad.php';
require_once NS_CORE_DIR . 'includes/class-ns-endpoints.php';
require_once NS_CORE_DIR . 'includes/class-ns-admin.php';
require_once NS_CORE_DIR . 'includes/class-ns-fosiles-admin.php';
require_once NS_CORE_DIR . 'includes/class-ns-juegos-web.php';
require_once NS_CORE_DIR . 'includes/class-ns-descargas-apk.php';

register_activation_hook( __FILE__, array( 'NS_Activacion', 'activar' ) );
register_deactivation_hook( __FILE__, array( 'NS_Activacion', 'desactivar' ) );

add_action( 'plugins_loaded', array( 'NS_Activacion', 'migrar_si_hace_falta' ) );
add_action( 'rest_api_init', array( 'NS_Endpoints', 'registrar' ) );
add_action( 'init', array( 'NS_Juegos_Web', 'registrar' ) );
add_action( 'init', array( 'NS_Descargas_Apk', 'registrar' ) );
add_action( 'uroto_cron_purga_tutor', array( 'NS_Activacion', 'ejecutar_purga_tutor' ) );

if ( is_admin() ) {
	NS_Admin::registrar();
	NS_Fosiles_Admin::registrar();
}

/**
 * Secreto para firmar JWTs. Se espera definir en wp-config.php:
 *   define( 'NS_JWT_SECRET', 'cadena-aleatoria-64-chars-minimo' );
 *
 * Backward-compat: si solo está definido el antiguo `UROTO_JWT_SECRET`,
 * se promueve automáticamente a `NS_JWT_SECRET` para que los testers no
 * tengan que tocar wp-config.php al actualizar el plugin.
 */
if ( ! defined( 'NS_JWT_SECRET' ) && defined( 'UROTO_JWT_SECRET' ) ) {
	define( 'NS_JWT_SECRET', UROTO_JWT_SECRET );
}
if ( ! defined( 'NS_JWT_SECRET' ) ) {
	add_action(
		'admin_notices',
		static function () {
			echo '<div class="notice notice-error"><p><strong>Nuevo Ser Core:</strong> ';
			echo 'define <code>NS_JWT_SECRET</code> en <code>wp-config.php</code> ';
			echo 'antes de usar el plugin en producción.</p></div>';
		}
	);
}

/**
 * API key de Anthropic para el tutor IA. Se espera en wp-config.php:
 *   define( 'NS_ANTHROPIC_KEY', 'sk-ant-...' );
 *
 * Backward-compat: si solo está definido el antiguo `UROTO_ANTHROPIC_KEY`,
 * se promueve automáticamente.
 */
if ( ! defined( 'NS_ANTHROPIC_KEY' ) && defined( 'UROTO_ANTHROPIC_KEY' ) ) {
	define( 'NS_ANTHROPIC_KEY', UROTO_ANTHROPIC_KEY );
}
if ( ! defined( 'NS_ANTHROPIC_KEY' ) ) {
	add_action(
		'admin_notices',
		static function () {
			echo '<div class="notice notice-warning"><p><strong>Nuevo Ser Core:</strong> ';
			echo 'define <code>NS_ANTHROPIC_KEY</code> en <code>wp-config.php</code> ';
			echo 'para que el tutor IA pueda responder. Sin esto, /tutor/explicar ';
			echo 'devolverá error.</p></div>';
		}
	);
}
