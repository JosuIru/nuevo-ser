<?php
/**
 * Plugin Name: Concejo
 * Description: Servidor de la app Concejo para un pueblo, barrio o
 *              colectivo: asuntos, debate ordenado, votaciones (también en
 *              papel), consentimiento, actas y compromisos. Cada pueblo
 *              instala el plugin en su propio WordPress.
 * Version:     0.1.0
 * Author:      Gailu Sare
 * Author URI:  https://gailu.net/
 * License:     AGPL-3.0-or-later
 * License URI: https://www.gnu.org/licenses/agpl-3.0.html
 * Text Domain: concejo
 * Requires PHP: 8.1
 * Requires at least: 6.4
 *
 * Qué hay dentro:
 *
 * - `includes/logica.php`: las reglas (las mismas que la app; ver
 *   `tests/test_paridad.php`).
 * - `includes/vista.php`: lo que ve cada persona.
 * - `includes/almacen.php`: tablas, cerrojo y acciones recibidas.
 * - `includes/api.php`: `/wp-json/concejo/v1/…`.
 * - `includes/admin.php`: Ajustes → Concejo.
 *
 * Es aparte del plugin de Zunbeltz a propósito: no comparte código con un
 * servidor que está en producción. Cuando los dos estén estables se verá
 * qué base común sacar.
 *
 * @package Concejo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

require_once __DIR__ . '/includes/logica.php';
require_once __DIR__ . '/includes/vista.php';
require_once __DIR__ . '/includes/instantanea.php';
require_once __DIR__ . '/includes/codigos.php';
require_once __DIR__ . '/includes/almacen.php';
require_once __DIR__ . '/includes/api.php';
require_once __DIR__ . '/includes/admin.php';

register_activation_hook( __FILE__, 'concejo_instalar_esquema' );
add_action( 'plugins_loaded', 'concejo_actualizar_esquema_si_hace_falta' );
