<?php
/**
 * Panel · App Android: subir el APK que se descarga desde la portada
 * (`/app/descargar/android`). Ver `includes/app-web.php`.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

const SZS_PAGINA_ANDROID = 'solera-zunbeltz-android';

add_action( 'admin_menu', 'szs_registrar_pagina_android', 20 );

function szs_registrar_pagina_android(): void {
	add_submenu_page( SZS_PAGINA_TAREAS, 'App Android', 'App Android', SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_ANDROID, 'szs_pagina_android' );
}

function szs_procesar_subida_apk(): ?array {
	if ( 'POST' !== ( $_SERVER['REQUEST_METHOD'] ?? '' ) || ! isset( $_POST['szs_accion'] ) ) {
		return null;
	}
	check_admin_referer( 'szs_android' );
	$fichero = $_FILES['szs_apk'] ?? null;
	if ( ! is_array( $fichero ) || UPLOAD_ERR_OK !== (int) $fichero['error'] ) {
		$codigo = is_array( $fichero ) ? (int) $fichero['error'] : UPLOAD_ERR_NO_FILE;
		return array(
			'error',
			in_array( $codigo, array( UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE ), true )
				? 'El APK supera el límite de subida de este servidor. Súbelo por SFTP (ver abajo).'
				: 'No llegó ningún fichero.',
		);
	}
	$error = szs_publicar_apk( (string) $fichero['tmp_name'], szs_campo_post( 'szs_version' ) );
	if ( null !== $error ) {
		return array( 'error', $error );
	}
	szs_registrar_actividad( szs_persona_del_panel(), 'crear', 'app_android', '', 'App Android ' . szs_campo_post( 'szs_version' ), '', '', 'panel' );
	return array( 'success', 'App Android publicada. Ya se descarga desde la portada.' );
}

function szs_pagina_android(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso  = szs_procesar_subida_apk();
	$apk    = szs_apk_publicado();
	$limite = (int) wp_max_upload_size();
	?>
	<div class="wrap">
		<h1>App Android</h1>
		<p>La app para móviles Android se descarga desde la portada de este WordPress («Descargar para Android») o directamente en:</p>
		<p><code style="user-select:all;"><?php echo esc_html( szs_url_apk() ); ?></code></p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<h2>Versión publicada</h2>
		<?php if ( null === $apk ) : ?>
			<p><em>Todavía no hay ninguna. La portada no muestra el botón de descarga hasta que se publique.</em></p>
		<?php else : ?>
			<p>
				<strong><?php echo esc_html( '' === $apk['version'] ? 'Sin número de versión' : 'Versión ' . $apk['version'] ); ?></strong>
				· <?php echo esc_html( size_format( $apk['tamano'] ) ); ?>
				· subida el <?php echo esc_html( wp_date( 'd/m/Y H:i', $apk['fecha'] ) ); ?>
			</p>
		<?php endif; ?>

		<h2>Publicar una versión nueva</h2>
		<form method="post" enctype="multipart/form-data">
			<?php wp_nonce_field( 'szs_android' ); ?>
			<input type="hidden" name="szs_accion" value="subir">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_apk">Fichero APK</label></th><td><input type="file" id="szs_apk" name="szs_apk" accept=".apk,application/vnd.android.package-archive" required></td></tr>
				<tr><th><label for="szs_version">Versión</label></th><td><input type="text" id="szs_version" name="szs_version" class="small-text" placeholder="0.3.0"></td></tr>
			</table>
			<?php submit_button( 'Publicar' ); ?>
		</form>
		<p class="description">Este servidor admite subidas de hasta <strong><?php echo esc_html( size_format( $limite ) ); ?></strong>. Si el APK es mayor, súbelo por SFTP como <code><?php echo esc_html( szs_ruta_apk() ); ?></code>: la portada lo ofrecerá igual.</p>

		<h2>Instalar en el móvil</h2>
		<ol style="max-width:720px;">
			<li>Abre la portada en el móvil y pulsa «Descargar para Android».</li>
			<li>Abre el fichero descargado. Android pedirá permiso para instalar apps de este origen (el navegador): concédelo.</li>
			<li>Instala y abre la app. En Ajustes → Sincronización pon la dirección de este WordPress y tu token.</li>
		</ol>
		<p class="description">Para actualizar, publica aquí la versión nueva y vuelve a descargarla en el móvil: se instala encima sin perder datos si está firmada con la misma clave que la anterior.</p>
	</div>
	<?php
}
