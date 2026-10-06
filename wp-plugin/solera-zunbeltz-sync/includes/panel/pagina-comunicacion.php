<?php
/**
 * Panel · Peticiones y Avisos.
 *
 * - Peticiones de tarea de las personas tester: convertirlas en tarea (el
 *   formulario de tarea llega relleno) o descartarlas con un motivo.
 * - Avisos de campo: ver los abiertos, resolverlos y publicar avisos o
 *   noticias (ferias, subvenciones…) para todo el espacio.
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function szs_pagina_peticiones(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = null;
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_peticiones' );
		$uid = szs_campo_post( 'szs_uid' );
		if ( 'descartar' === sanitize_key( wp_unslash( $_POST['szs_accion'] ) ) && null !== szs_obtener_entidad( 'peticion', $uid ) ) {
			szs_guardar_entidad_desde_panel(
				'peticion',
				$uid,
				array(
					'estado'    => 'descartada',
					'respuesta' => szs_texto_largo_post( 'szs_respuesta' ),
				)
			);
			$aviso = array( 'success', 'Petición descartada. Quien la pidió verá el motivo al sincronizar.' );
		}
	}

	$peticiones = szs_listar_entidades_tipo( 'peticion' );
	usort(
		$peticiones,
		static fn( array $a, array $b ): int => array(
			'pendiente' === ( $a['datos']['estado'] ?? 'pendiente' ) ? 0 : 1,
			empty( $a['datos']['urgente'] ) ? 1 : 0,
			-( $a['datos']['fecha_creacion_ms'] ?? 0 ),
		) <=> array(
			'pendiente' === ( $b['datos']['estado'] ?? 'pendiente' ) ? 0 : 1,
			empty( $b['datos']['urgente'] ) ? 1 : 0,
			-( $b['datos']['fecha_creacion_ms'] ?? 0 ),
		)
	);
	$nombres = szs_nombres_personas();
	$fincas  = szs_nombres_fincas();
	$estados = array(
		'pendiente'  => 'Pendiente',
		'aceptada'   => 'Aceptada (tarea creada)',
		'descartada' => 'Descartada',
	);
	?>
	<div class="wrap">
		<h1>Peticiones de tarea</h1>
		<p>Lo que las personas tester ven que hace falta. Solo coordinación crea tareas: aquí se convierten en tarea o se descartan.</p>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<table class="widefat striped">
			<thead><tr><th>Petición</th><th>Quién</th><th>Finca</th><th>Fecha</th><th>Estado</th><th>Acciones</th></tr></thead>
			<tbody>
			<?php if ( empty( $peticiones ) ) : ?>
				<tr><td colspan="6">No hay peticiones.</td></tr>
			<?php endif; ?>
			<?php foreach ( $peticiones as $peticion ) : ?>
				<?php
				$datos     = $peticion['datos'];
				$estado    = (string) ( $datos['estado'] ?? 'pendiente' );
				$pendiente = 'pendiente' === $estado;
				?>
				<tr>
					<td>
						<?php if ( ! empty( $datos['urgente'] ) ) : ?><strong style="color:#b8402a;">Urgente · </strong><?php endif; ?>
						<strong><?php echo esc_html( (string) ( $datos['titulo'] ?? '' ) ); ?></strong>
						<?php if ( '' !== (string) ( $datos['descripcion'] ?? '' ) ) : ?><br><?php echo esc_html( (string) $datos['descripcion'] ); ?><?php endif; ?>
						<?php if ( '' !== (string) ( $datos['respuesta'] ?? '' ) ) : ?><br><em>Respuesta: <?php echo esc_html( (string) $datos['respuesta'] ); ?></em><?php endif; ?>
					</td>
					<td><?php echo esc_html( $nombres[ $peticion['autor_uid'] ] ?? '—' ); ?></td>
					<td><?php echo esc_html( $fincas[ $datos['finca_uid'] ?? '' ] ?? '—' ); ?></td>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $datos['fecha_creacion_ms'] ?? 0 ) ) ); ?></td>
					<td><?php echo esc_html( $estados[ $estado ] ?? $estado ); ?></td>
					<td>
						<?php if ( $pendiente ) : ?>
							<a class="button button-primary button-small" href="<?php echo esc_url( szs_url_pagina( SZS_PAGINA_TAREAS, array( 'vista' => 'formulario', 'peticion' => $peticion['uid'] ) ) ); ?>">Crear la tarea</a>
							<form method="post" style="margin-top:6px;display:flex;gap:4px;">
								<?php wp_nonce_field( 'szs_peticiones' ); ?>
								<input type="hidden" name="szs_accion" value="descartar">
								<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $peticion['uid'] ); ?>">
								<input type="text" name="szs_respuesta" placeholder="Motivo (lo verá quien la pidió)">
								<button class="button button-small">Descartar</button>
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

function szs_pagina_avisos(): void {
	if ( ! szs_puede_usar_panel() ) {
		return;
	}
	$aviso = null;
	if ( 'POST' === ( $_SERVER['REQUEST_METHOD'] ?? '' ) && isset( $_POST['szs_accion'] ) ) {
		check_admin_referer( 'szs_avisos' );
		$accion = sanitize_key( wp_unslash( $_POST['szs_accion'] ) );
		$uid    = szs_campo_post( 'szs_uid' );
		if ( in_array( $accion, array( 'resolver', 'reabrir' ), true ) && null !== szs_obtener_entidad( 'aviso', $uid ) ) {
			szs_guardar_entidad_desde_panel( 'aviso', $uid, array( 'estado' => 'resolver' === $accion ? 'resuelto' : 'abierto' ) );
			$aviso = array( 'success', 'resolver' === $accion ? 'Aviso resuelto.' : 'Aviso reabierto.' );
		}
		if ( 'publicar' === $accion ) {
			$titulo    = szs_campo_post( 'szs_titulo' );
			$categoria = sanitize_key( szs_campo_post( 'szs_categoria', 'noticias' ) );
			if ( '' === $titulo || ! isset( SZS_CATEGORIAS_AVISO[ $categoria ] ) ) {
				$aviso = array( 'error', 'Falta el título.' );
			} else {
				szs_guardar_entidad_desde_panel(
					'aviso',
					szs_nuevo_uid(),
					array(
						'titulo'      => $titulo,
						'descripcion' => szs_texto_largo_post( 'szs_descripcion' ),
						'categoria'   => $categoria,
						'gravedad'    => '1' === szs_campo_post( 'szs_alarma' ) ? 'alarma' : 'aviso',
						'estado'      => 'abierto',
						'fecha_ms'    => szs_ahora_ms(),
						'finca_uid'   => '',
						'punto_uid'   => '',
					)
				);
				$aviso = array( 'success', 'Publicado. Llegará a todos los móviles al sincronizar.' );
			}
		}
	}

	$avisos = szs_listar_entidades_tipo( 'aviso' );
	usort(
		$avisos,
		static fn( array $a, array $b ): int => array(
			'abierto' === ( $a['datos']['estado'] ?? 'abierto' ) ? 0 : 1,
			'alarma' === ( $a['datos']['gravedad'] ?? '' ) ? 0 : 1,
			-( $a['datos']['fecha_ms'] ?? 0 ),
		) <=> array(
			'abierto' === ( $b['datos']['estado'] ?? 'abierto' ) ? 0 : 1,
			'alarma' === ( $b['datos']['gravedad'] ?? '' ) ? 0 : 1,
			-( $b['datos']['fecha_ms'] ?? 0 ),
		)
	);
	$nombres = szs_nombres_personas();
	?>
	<div class="wrap">
		<h1>Avisos del espacio</h1>
		<?php szs_mostrar_aviso_panel( $aviso ); ?>
		<h2>Publicar un aviso o una noticia</h2>
		<form method="post" style="max-width:720px;">
			<?php wp_nonce_field( 'szs_avisos' ); ?>
			<input type="hidden" name="szs_accion" value="publicar">
			<table class="form-table" role="presentation">
				<tr><th><label for="szs_categoria">Categoría</label></th><td><?php szs_selector( 'szs_categoria', SZS_CATEGORIAS_AVISO, 'noticias' ); ?></td></tr>
				<tr><th><label for="szs_titulo">Título</label></th><td><input type="text" id="szs_titulo" name="szs_titulo" class="regular-text" placeholder="Feria de ganado: inscripción hasta el día 25"></td></tr>
				<tr><th><label for="szs_descripcion">Detalles</label></th><td><textarea id="szs_descripcion" name="szs_descripcion" rows="3" class="large-text"></textarea></td></tr>
				<tr><th>Alarma</th><td><label><input type="checkbox" name="szs_alarma" value="1"> Es una alarma (salta como notificación en los móviles)</label></td></tr>
			</table>
			<?php submit_button( 'Publicar' ); ?>
		</form>

		<h2>Avisos</h2>
		<table class="widefat striped">
			<thead><tr><th>Aviso</th><th>Categoría</th><th>Quién</th><th>Fecha</th><th>Estado</th><th></th></tr></thead>
			<tbody>
			<?php if ( empty( $avisos ) ) : ?>
				<tr><td colspan="6">No hay avisos.</td></tr>
			<?php endif; ?>
			<?php foreach ( $avisos as $entidad ) : ?>
				<?php
				$datos   = $entidad['datos'];
				$abierto = 'abierto' === ( $datos['estado'] ?? 'abierto' );
				$alarma  = 'alarma' === ( $datos['gravedad'] ?? '' );
				?>
				<tr>
					<td>
						<?php if ( $alarma ) : ?><strong style="color:#b8402a;">Alarma · </strong><?php endif; ?>
						<strong><?php echo esc_html( (string) ( $datos['titulo'] ?? '' ) ); ?></strong>
						<?php if ( '' !== (string) ( $datos['descripcion'] ?? '' ) ) : ?><br><?php echo esc_html( (string) $datos['descripcion'] ); ?><?php endif; ?>
					</td>
					<td><?php echo esc_html( SZS_CATEGORIAS_AVISO[ $datos['categoria'] ?? '' ] ?? '—' ); ?></td>
					<td><?php echo esc_html( $nombres[ $entidad['autor_uid'] ] ?? '—' ); ?></td>
					<td><?php echo esc_html( szs_fecha_ms( (int) ( $datos['fecha_ms'] ?? 0 ), 'd/m/Y H:i' ) ); ?></td>
					<td><?php echo $abierto ? 'Abierto' : 'Resuelto'; ?></td>
					<td>
						<form method="post">
							<?php wp_nonce_field( 'szs_avisos' ); ?>
							<input type="hidden" name="szs_accion" value="<?php echo $abierto ? 'resolver' : 'reabrir'; ?>">
							<input type="hidden" name="szs_uid" value="<?php echo esc_attr( $entidad['uid'] ); ?>">
							<button class="button button-small"><?php echo $abierto ? 'Marcar resuelto' : 'Reabrir'; ?></button>
						</form>
					</td>
				</tr>
			<?php endforeach; ?>
			</tbody>
		</table>
	</div>
	<?php
}
