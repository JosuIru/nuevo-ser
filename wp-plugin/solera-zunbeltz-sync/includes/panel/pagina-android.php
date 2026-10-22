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
	add_submenu_page( SZS_PAGINA_INICIO, szs_t( 'App Android' ), szs_t( 'App Android' ), SZS_CAPACIDAD_WP_PANEL, SZS_PAGINA_ANDROID, 'szs_pagina_android' );
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
				? szs_t( 'El APK supera el límite de subida de este servidor. Súbelo por SFTP (ver abajo).' )
				: szs_t( 'No llegó ningún fichero.' ),
		);
	}
	$error = szs_publicar_apk( (string) $fichero['tmp_name'], szs_campo_post( 'szs_version' ) );
	if ( null !== $error ) {
		return array( 'error', $error );
	}
	szs_registrar_actividad( szs_persona_del_panel(), 'crear', 'app_android', '', 'App Android ' . szs_campo_post( 'szs_version' ), '', '', 'panel' );
	return array( 'success', szs_t( 'App Android publicada. Ya se descarga desde la portada.' ) );
}

function szs_pagina_android(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso  = szs_procesar_subida_apk();
	if ( isset( $_GET['szs_comprobar_github'] ) ) {
		delete_transient( SZS_TRANSITORIO_APK );
	}
	$apk_github = szs_apk_github();
	$apk        = szs_apk_publicado();
	$limite     = (int) wp_max_upload_size();
	?>
	<div class="wrap">
		<h1><?php echo esc_html( szs_t( 'App Android' ) ); ?></h1>
		<p><?php echo esc_html( szs_t( 'La app para móviles Android se descarga desde la portada de este WordPress («Descargar para Android») o directamente en:' ) ); ?></p>
		<p><code style="user-select:all;"><?php echo esc_html( szs_url_apk() ); ?></code></p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>

		<h2><?php echo esc_html( szs_t( 'Versión que se descarga' ) ); ?></h2>
		<?php if ( null !== $apk_github ) : ?>
			<p>
				<strong><?php echo esc_html( szs_t( 'Versión %s', $apk_github['version'] ) ); ?></strong>
				· <?php echo esc_html( size_format( $apk_github['tamano'] ) ); ?>
				· <?php echo esc_html( szs_t( 'publicada en GitHub el %s', wp_date( 'd/m/Y H:i', $apk_github['fecha'] ) ) ); ?>
			</p>
			<p class="description"><?php echo esc_html( szs_t( 'Sale sola de la última versión publicada de la app; no hace falta subir nada. Se comprueba cada hora:' ) ); ?> <a href="<?php echo esc_url( add_query_arg( 'szs_comprobar_github', '1' ) ); ?>"><?php echo esc_html( szs_t( 'comprobar ahora' ) ); ?></a>.</p>
		<?php else : ?>
			<p><em><?php echo esc_html( szs_t( 'No se ha podido consultar GitHub (o no hay versiones publicadas). Mientras, se descarga el APK subido aquí abajo.' ) ); ?> <a href="<?php echo esc_url( add_query_arg( 'szs_comprobar_github', '1' ) ); ?>"><?php echo esc_html( szs_t( 'Volver a comprobar' ) ); ?></a>.</em></p>
		<?php endif; ?>

		<h2><?php echo esc_html( szs_t( 'APK de respaldo' ) ); ?></h2>
		<p class="description"><?php echo esc_html( szs_t( 'Solo se ofrece si GitHub no responde.' ) ); ?></p>
		<?php if ( null === $apk ) : ?>
			<p><em><?php echo esc_html( szs_t( 'No hay ninguno subido.' ) ); ?></em></p>
		<?php else : ?>
			<p>
				<strong><?php echo esc_html( '' === $apk['version'] ? szs_t( 'Sin número de versión' ) : szs_t( 'Versión %s', $apk['version'] ) ); ?></strong>
				· <?php echo esc_html( size_format( $apk['tamano'] ) ); ?>
				· <?php echo esc_html( szs_t( 'subida el %s', wp_date( 'd/m/Y H:i', $apk['fecha'] ) ) ); ?>
			</p>
		<?php endif; ?>

		<h2><?php echo esc_html( szs_t( 'Subir un APK de respaldo' ) ); ?></h2>
		<form method="post" enctype="multipart/form-data">
			<?php wp_nonce_field( 'szs_android' ); ?>
			<input type="hidden" name="szs_accion" value="subir">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_apk"><?php echo esc_html( szs_t( 'Fichero APK' ) ); ?></label></th><td><input type="file" id="szs_apk" name="szs_apk" accept=".apk,application/vnd.android.package-archive" required></td></tr>
				<tr><th><label for="szs_version"><?php echo esc_html( szs_t( 'Versión' ) ); ?></label></th><td><input type="text" id="szs_version" name="szs_version" class="small-text" placeholder="0.3.0"></td></tr>
			</table>
			<?php submit_button( szs_t( 'Publicar' ) ); ?>
		</form>
		<p class="description"><?php echo szs_t( 'Este servidor admite subidas de hasta <strong>%1$s</strong>. Si el APK es mayor, súbelo por SFTP como <code>%2$s</code>: la portada lo ofrecerá igual.', esc_html( size_format( $limite ) ), esc_html( szs_ruta_apk() ) ); // phpcs:ignore WordPress.Security.EscapeOutput ?></p>

		<h2><?php echo esc_html( szs_t( 'Instalar en el móvil' ) ); ?></h2>
		<ol style="max-width:720px;">
			<li><?php echo esc_html( szs_t( 'Abre la portada en el móvil y pulsa «Descargar para Android».' ) ); ?></li>
			<li><?php echo esc_html( szs_t( 'Abre el fichero descargado. Android pedirá permiso para instalar apps de este origen (el navegador): concédelo.' ) ); ?></li>
			<li><?php echo esc_html( szs_t( 'Instala y abre la app. En Ajustes → Sincronización pon la dirección de este WordPress y tu clave de usuario.' ) ); ?></li>
		</ol>
		<p class="description"><?php echo esc_html( szs_t( 'Para actualizar, en la app: Ajustes → Actualizaciones. Se instala encima sin perder datos.' ) ); ?></p>
	</div>
	<?php
}
