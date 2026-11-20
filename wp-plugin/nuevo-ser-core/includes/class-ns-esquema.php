<?php
/**
 * Esquema MySQL de la plataforma Nuevo Ser Core. Todas las tablas con prefijo
 * `{$wpdb->prefix}ns_` (renombrado en C4 desde `{$wpdb->prefix}uroto_`).
 *
 * Modelo:
 * - ns_games: registro de juegos disponibles (uno-roto, las-versiones…).
 *   Permite multi-tenancy: una misma instalación puede alojar varios juegos.
 * - ns_usuarios: tutor legal. Email + password. Compartido entre juegos.
 * - ns_ninos: perfiles de niños asociados a un tutor. Compartidos entre juegos.
 * - ns_progreso: estado global del niño POR JUEGO (esquirlas, rango,
 *   nombre_jugador, flags JSON, arco actual). PK = (nino_id, game_id).
 * - ns_estado_habilidades: fila por (niño, habilidad, juego) con nivel,
 *   precisión y métricas del motor de maestría. PK = (nino_id, id_habilidad, game_id).
 * - ns_cache_tutor: caché de respuestas del Tutor IA. Compartida entre niños
 *   (sin PII en el contenido). game_id como columna informativa para stats.
 * - ns_password_reset: tokens de reset de contraseña. Compartido entre juegos.
 *
 * El guion completo del juego y los flags narrativos se guardan como JSON
 * en ns_progreso.flags_json — el cliente es la fuente de verdad sobre qué
 * flags significan qué; el servidor solo los persiste y los sincroniza.
 *
 * Renombrado semántico (`progreso` → `mastery_records`, etc.) diferido a v1.5.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Esquema {

	/**
	 * Mapa clave lógica → sufijo bajo el prefijo del wpdb. La clave es
	 * estable y vive en el código; el prefijo cambia entre instalaciones
	 * (`wp_`, `wp_test_`, …).
	 */
	public const SUFIJOS = array(
		'games'              => 'ns_games',
		'usuarios'           => 'ns_usuarios',
		'ninos'              => 'ns_ninos',
		'progreso'           => 'ns_progreso',
		'estado_habilidades' => 'ns_estado_habilidades',
		'cache_tutor'        => 'ns_cache_tutor',
		'password_reset'     => 'ns_password_reset',
		// Tablas de acompañamiento (C7). Soportan a la doc §5.5–5.9 y a los
		// endpoints reservados con 501 (`/wp-json/nuevo-ser/v1/companion/*`,
		// `/classrooms/*`, `/caregivers/*`). Se crean vacías; se rellenan
		// cuando los flujos correspondientes entren en producción (C9+).
		'classrooms'         => 'ns_classrooms',
		'classroom_members'  => 'ns_classroom_members',
		'caregiver_links'    => 'ns_caregiver_links',
		'cuaderno_entries'   => 'ns_cuaderno_entries',
		'mosaicos'           => 'ns_mosaicos',
		'weekly_summaries'   => 'ns_weekly_summaries',
		// Tablas específicas del juego El Cuaderno (doc 03 §3.2). La
		// frontera de privacidad del juego cae en estos campos: nada de
		// texto libre del niño ni coordenadas precisas vive aquí — solo
		// metadatos derivados (hash de la observación, region_code
		// NUTS-3). El nombre del sit spot sí entra (lo elige el niño,
		// no es PII estructural — "El Roble Grande", "Mi banco").
		'el_cuaderno_observaciones' => 'ns_el_cuaderno_observaciones',
		'el_cuaderno_sit_spots'     => 'ns_el_cuaderno_sit_spots',
		// Tablas específicas del módulo "ciencia ciudadana" de la app
		// Fósiles (operador, adulto aficionado). Frontera de privacidad:
		// las coordenadas precisas de cada hallazgo NO suben aquí — solo
		// la foto + datos declarados (tipo, especie, edad, formación,
		// notas) + contacto del aficionado (email + nombre opcional, NO
		// publicables). El curador edita los campos `*_curada` antes de
		// que la foto aparezca dentro de la app, asociada únicamente a
		// la formación geológica catalogada (estilo "Wikipedia").
		'fosiles_aportaciones'         => 'ns_fosiles_aportaciones',
		'fosiles_fotos_blob'           => 'ns_fosiles_fotos_blob',
		'fosiles_formaciones_catalogadas' => 'ns_fosiles_formaciones_catalogadas',
		'fosiles_borrados_rgpd'        => 'ns_fosiles_borrados_rgpd',
		// El Taller: el progreso del niño (JSON pequeño, sin dibujos) y el
		// contador diario del sensei. Las imágenes del sensei no se guardan.
		'el_taller_progreso'           => 'ns_el_taller_progreso',
		'el_taller_sensei'             => 'ns_el_taller_sensei',
	);

	/** Mapeo del prefijo viejo al nuevo. Lo usa la migración M001. */
	public const SUFIJOS_VIEJOS = array(
		'usuarios'           => 'uroto_usuarios',
		'ninos'              => 'uroto_ninos',
		'progreso'           => 'uroto_progreso',
		'estado_habilidades' => 'uroto_estado_habilidades',
		'cache_tutor'        => 'uroto_cache_tutor',
		'password_reset'     => 'uroto_password_reset',
	);

	public static function nombre_tabla( string $clave ): string {
		global $wpdb;
		if ( ! isset( self::SUFIJOS[ $clave ] ) ) {
			throw new InvalidArgumentException( "Tabla desconocida: {$clave}" );
		}
		return $wpdb->prefix . self::SUFIJOS[ $clave ];
	}

	public static function nombre_tabla_vieja( string $clave ): string {
		global $wpdb;
		if ( ! isset( self::SUFIJOS_VIEJOS[ $clave ] ) ) {
			throw new InvalidArgumentException( "Tabla vieja desconocida: {$clave}" );
		}
		return $wpdb->prefix . self::SUFIJOS_VIEJOS[ $clave ];
	}

	/**
	 * SQL CREATE TABLE para cada tabla. dbDelta() requiere formato
	 * específico: PRIMARY KEY  con dos espacios, sin AUTO_INCREMENT en
	 * el CREATE si ya lo tiene, etc. Ver codex.wordpress.org/Creating_Tables_with_Plugins.
	 *
	 * @return string[] SQL statements.
	 */
	public static function sentencias_create(): array {
		global $wpdb;
		$charset_collate = $wpdb->get_charset_collate();
		$games            = self::nombre_tabla( 'games' );
		$usuarios         = self::nombre_tabla( 'usuarios' );
		$ninos            = self::nombre_tabla( 'ninos' );
		$progreso         = self::nombre_tabla( 'progreso' );
		$habilidades      = self::nombre_tabla( 'estado_habilidades' );
		$cache_tutor      = self::nombre_tabla( 'cache_tutor' );
		$reset_password   = self::nombre_tabla( 'password_reset' );
		$classrooms       = self::nombre_tabla( 'classrooms' );
		$classroom_member = self::nombre_tabla( 'classroom_members' );
		$caregiver_links  = self::nombre_tabla( 'caregiver_links' );
		$cuaderno_entries = self::nombre_tabla( 'cuaderno_entries' );
		$mosaicos         = self::nombre_tabla( 'mosaicos' );
		$weekly_summaries = self::nombre_tabla( 'weekly_summaries' );
		$el_cuaderno_observaciones = self::nombre_tabla( 'el_cuaderno_observaciones' );
		$el_cuaderno_sit_spots     = self::nombre_tabla( 'el_cuaderno_sit_spots' );
		$fosiles_aportaciones      = self::nombre_tabla( 'fosiles_aportaciones' );
		$fosiles_fotos_blob        = self::nombre_tabla( 'fosiles_fotos_blob' );
		$fosiles_formaciones       = self::nombre_tabla( 'fosiles_formaciones_catalogadas' );
		$fosiles_borrados_rgpd     = self::nombre_tabla( 'fosiles_borrados_rgpd' );
		$el_taller_progreso        = self::nombre_tabla( 'el_taller_progreso' );
		$el_taller_sensei          = self::nombre_tabla( 'el_taller_sensei' );

		return array(
			"CREATE TABLE {$games} (
				id VARCHAR(64) NOT NULL,
				name VARCHAR(128) NOT NULL,
				age_min TINYINT UNSIGNED NOT NULL,
				age_max TINYINT UNSIGNED NOT NULL,
				schema_version VARCHAR(16) NOT NULL DEFAULT '1.0',
				active TINYINT(1) NOT NULL DEFAULT 1,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (id)
			) {$charset_collate};",

			"CREATE TABLE {$usuarios} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				email VARCHAR(190) NOT NULL,
				password_hash VARCHAR(255) NOT NULL,
				nombre_tutor VARCHAR(120) NOT NULL DEFAULT '',
				locale VARCHAR(8) NOT NULL DEFAULT 'es',
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY email (email)
			) {$charset_collate};",

			"CREATE TABLE {$ninos} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				usuario_id BIGINT UNSIGNED NOT NULL,
				nombre_mostrar VARCHAR(60) NOT NULL,
				locale VARCHAR(8) NOT NULL DEFAULT 'es',
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				KEY usuario_id (usuario_id)
			) {$charset_collate};",

			"CREATE TABLE {$progreso} (
				nino_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL DEFAULT 'uno-roto',
				nombre_jugador VARCHAR(60) NOT NULL DEFAULT '',
				esquirlas_total INT UNSIGNED NOT NULL DEFAULT 0,
				rango TINYINT UNSIGNED NOT NULL DEFAULT 0,
				arco_actual TINYINT UNSIGNED NOT NULL DEFAULT 1,
				flags_json LONGTEXT NOT NULL,
				actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (nino_id, game_id)
			) {$charset_collate};",

			"CREATE TABLE {$habilidades} (
				nino_id BIGINT UNSIGNED NOT NULL,
				id_habilidad VARCHAR(24) NOT NULL,
				game_id VARCHAR(64) NOT NULL DEFAULT 'uno-roto',
				nivel TINYINT UNSIGNED NOT NULL DEFAULT 0,
				precision_ponderada DECIMAL(4,3) NOT NULL DEFAULT 0,
				tiempo_mediano_seg DECIMAL(6,2) NOT NULL DEFAULT 0,
				total_exposiciones INT UNSIGNED NOT NULL DEFAULT 0,
				sesiones_consecutivas_buenas INT UNSIGNED NOT NULL DEFAULT 0,
				ultima_practica DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
				intentos_recientes_json LONGTEXT NOT NULL,
				actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (nino_id, id_habilidad, game_id)
			) {$charset_collate};",

			"CREATE TABLE {$cache_tutor} (
				clave_hash CHAR(64) NOT NULL,
				id_habilidad VARCHAR(24) NOT NULL,
				game_id VARCHAR(64) NOT NULL DEFAULT 'uno-roto',
				pregunta TEXT NOT NULL,
				respuesta LONGTEXT NOT NULL,
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				usos INT UNSIGNED NOT NULL DEFAULT 0,
				PRIMARY KEY  (clave_hash),
				KEY id_habilidad (id_habilidad),
				KEY game_id (game_id),
				KEY creado_en (creado_en)
			) {$charset_collate};",

			"CREATE TABLE {$reset_password} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				usuario_id BIGINT UNSIGNED NOT NULL,
				token_hash CHAR(64) NOT NULL,
				expira_en DATETIME NOT NULL,
				usado_en DATETIME NULL DEFAULT NULL,
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY token_hash (token_hash),
				KEY usuario_id (usuario_id),
				KEY expira_en (expira_en)
			) {$charset_collate};",

			// ---------------------------------------------------------
			// Tablas de acompañamiento (C7) — doc §5.5–5.9.
			//
			// Se crean ahora con dbDelta para reservar la superficie de
			// almacenamiento; los handlers asociados en NS_Endpoints
			// devuelven 501 hasta que C9 implemente la lógica.
			//
			// FOREIGN KEYs declaradas a título informativo: dbDelta no
			// las aplica realmente, así que la integridad referencial
			// la garantizan los handlers PHP cuando arranquen.
			// ---------------------------------------------------------

			"CREATE TABLE {$classrooms} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				code VARCHAR(16) NOT NULL,
				teacher_user_id BIGINT UNSIGNED NOT NULL,
				name VARCHAR(128) NOT NULL,
				game_ids LONGTEXT NOT NULL,
				language VARCHAR(8) NOT NULL DEFAULT 'es',
				active TINYINT(1) NOT NULL DEFAULT 1,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY code (code),
				KEY teacher_user_id (teacher_user_id)
			) {$charset_collate};",

			"CREATE TABLE {$classroom_member} (
				classroom_id BIGINT UNSIGNED NOT NULL,
				user_id BIGINT UNSIGNED NOT NULL,
				joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				active TINYINT(1) NOT NULL DEFAULT 1,
				PRIMARY KEY  (classroom_id, user_id),
				KEY user_id (user_id)
			) {$charset_collate};",

			"CREATE TABLE {$caregiver_links} (
				caregiver_user_id BIGINT UNSIGNED NOT NULL,
				child_user_id BIGINT UNSIGNED NOT NULL,
				consent_method VARCHAR(32) NOT NULL DEFAULT '',
				consent_verified_at DATETIME NULL DEFAULT NULL,
				consent_evidence LONGTEXT NULL DEFAULT NULL,
				consent_token VARCHAR(64) NULL DEFAULT NULL,
				active TINYINT(1) NOT NULL DEFAULT 1,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				revoked_at DATETIME NULL DEFAULT NULL,
				PRIMARY KEY  (caregiver_user_id, child_user_id),
				UNIQUE KEY consent_token (consent_token),
				KEY child_user_id (child_user_id)
			) {$charset_collate};",

			"CREATE TABLE {$cuaderno_entries} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				user_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL,
				type VARCHAR(32) NOT NULL DEFAULT '',
				title VARCHAR(255) NOT NULL DEFAULT '',
				content_ref VARCHAR(255) NOT NULL DEFAULT '',
				content_meta LONGTEXT NULL DEFAULT NULL,
				anchored_to LONGTEXT NULL DEFAULT NULL,
				shared_with_classroom_ids LONGTEXT NULL DEFAULT NULL,
				shared_with_caregiver_ids LONGTEXT NULL DEFAULT NULL,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				KEY user_game_created (user_id, game_id, created_at)
			) {$charset_collate};",

			"CREATE TABLE {$mosaicos} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				user_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL,
				arc_id VARCHAR(64) NOT NULL,
				format VARCHAR(32) NOT NULL DEFAULT '',
				title VARCHAR(255) NOT NULL DEFAULT '',
				content_ref VARCHAR(255) NOT NULL DEFAULT '',
				content_meta LONGTEXT NULL DEFAULT NULL,
				required_anchors LONGTEXT NULL DEFAULT NULL,
				fulfilled_anchors LONGTEXT NULL DEFAULT NULL,
				qualitative_feedback LONGTEXT NULL DEFAULT NULL,
				shared_with_classroom_ids LONGTEXT NULL DEFAULT NULL,
				shared_with_caregiver_ids LONGTEXT NULL DEFAULT NULL,
				completed_at DATETIME NULL DEFAULT NULL,
				PRIMARY KEY  (id),
				KEY user_game_arc (user_id, game_id, arc_id)
			) {$charset_collate};",

			"CREATE TABLE {$weekly_summaries} (
				user_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL,
				iso_week VARCHAR(10) NOT NULL,
				summary_text TEXT NOT NULL,
				conversation_prompt TEXT NULL,
				aggregates_hash VARCHAR(64) NOT NULL,
				aggregates_payload LONGTEXT NOT NULL DEFAULT '',
				generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (user_id, game_id, iso_week),
				KEY aggregates_hash (aggregates_hash)
			) {$charset_collate};",

			// ---------------------------------------------------------
			// Tablas específicas del juego El Cuaderno (doc 03 §3.2).
			//
			// El texto libre `queVio` del niño NUNCA se almacena aquí
			// — viaja como `what_seen_hash` (sha256). La capa de sync
			// del cliente Dart calcula el hash antes de subir.
			// Coordenadas precisas tampoco — solo `region_code` NUTS-3.
			// Las fotos y dibujos se referencian por `photo_blob_id` /
			// `drawing_blob_id` cuando la niña explícitamente comparte
			// (Sprint 5+ con R2); en S2 ambos campos quedan a NULL.
			// ---------------------------------------------------------

			"CREATE TABLE {$el_cuaderno_observaciones} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				uuid CHAR(36) NOT NULL,
				user_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL DEFAULT 'el-cuaderno',
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				occurred_at DATETIME NOT NULL,
				place_name VARCHAR(255) NOT NULL DEFAULT '',
				region_code VARCHAR(16) NOT NULL DEFAULT '',
				weather_json LONGTEXT NULL DEFAULT NULL,
				what_seen_hash CHAR(64) NOT NULL,
				proposed_id VARCHAR(255) NOT NULL DEFAULT '',
				confidence VARCHAR(24) NOT NULL,
				has_photo TINYINT(1) NOT NULL DEFAULT 0,
				has_drawing TINYINT(1) NOT NULL DEFAULT 0,
				photo_blob_id VARCHAR(64) NOT NULL DEFAULT '',
				drawing_blob_id VARCHAR(64) NOT NULL DEFAULT '',
				misterio_id VARCHAR(64) NOT NULL DEFAULT '',
				sit_spot_id CHAR(36) NOT NULL DEFAULT '',
				shared_with LONGTEXT NULL DEFAULT NULL,
				soft_deleted_at DATETIME NULL DEFAULT NULL,
				PRIMARY KEY  (id),
				UNIQUE KEY uuid (uuid),
				KEY user_game_time (user_id, game_id, occurred_at),
				KEY region_misterio (region_code, misterio_id)
			) {$charset_collate};",

			"CREATE TABLE {$el_cuaderno_sit_spots} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				uuid CHAR(36) NOT NULL,
				user_id BIGINT UNSIGNED NOT NULL,
				game_id VARCHAR(64) NOT NULL DEFAULT 'el-cuaderno',
				name VARCHAR(255) NOT NULL,
				region_code VARCHAR(16) NOT NULL DEFAULT '',
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				last_visit_at DATETIME NULL DEFAULT NULL,
				retired_at DATETIME NULL DEFAULT NULL,
				PRIMARY KEY  (id),
				UNIQUE KEY uuid (uuid),
				KEY user_game (user_id, game_id)
			) {$charset_collate};",

			// ---------------------------------------------------------
			// Tablas de "ciencia ciudadana" para la app Fósiles.
			//
			// El aficionado NO tiene cuenta: envía la foto desde la app
			// con un `token_dispositivo` (UUID v4 persistido en el
			// SharedPreferences del móvil). Email + nombre son datos de
			// contacto puntuales para que el curador notifique resultado;
			// NUNCA se publican dentro de la app.
			//
			// El curador (WP user con rol `nuevoser_curador_fosiles`)
			// edita `*_curada` y elige `formacion_catalogada_id` antes
			// de aprobar. Solo entonces la foto aparece dentro de la
			// galería pública de la formación.
			//
			// `wp_ns_fosiles_fotos_blob` desacopla el archivo binario
			// del registro lógico: la misma foto subida dos veces se
			// detecta por `sha256` y reusa la fila — ahorra disco y
			// permite identificar spam fotos-clonadas.
			// ---------------------------------------------------------

			"CREATE TABLE {$fosiles_fotos_blob} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				ruta_archivo VARCHAR(512) NOT NULL,
				mime VARCHAR(64) NOT NULL DEFAULT 'image/jpeg',
				sha256 CHAR(64) NOT NULL,
				tamano_bytes INT UNSIGNED NOT NULL DEFAULT 0,
				ancho_px MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
				alto_px MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
				thumbnail_ruta VARCHAR(512) NOT NULL DEFAULT '',
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY sha256 (sha256)
			) {$charset_collate};",

			"CREATE TABLE {$fosiles_formaciones} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				codigo VARCHAR(96) NOT NULL,
				nombre_oficial VARCHAR(255) NOT NULL,
				periodo VARCHAR(64) NOT NULL DEFAULT '',
				edad_aproximada VARCHAR(96) NOT NULL DEFAULT '',
				regiones LONGTEXT NULL DEFAULT NULL,
				descripcion LONGTEXT NULL DEFAULT NULL,
				activo TINYINT(1) NOT NULL DEFAULT 1,
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY codigo (codigo)
			) {$charset_collate};",

			"CREATE TABLE {$fosiles_aportaciones} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				fecha_revision DATETIME NULL DEFAULT NULL,
				estado VARCHAR(16) NOT NULL DEFAULT 'pendiente',
				tipo VARCHAR(16) NOT NULL DEFAULT 'fosil',
				email_contacto VARCHAR(190) NOT NULL DEFAULT '',
				nombre_contacto VARCHAR(120) NOT NULL DEFAULT '',
				especie_declarada VARCHAR(255) NOT NULL DEFAULT '',
				edad_declarada VARCHAR(128) NOT NULL DEFAULT '',
				formacion_declarada VARCHAR(255) NOT NULL DEFAULT '',
				notas_aficionado LONGTEXT NULL DEFAULT NULL,
				formacion_catalogada_id BIGINT UNSIGNED NULL DEFAULT NULL,
				especie_curada VARCHAR(255) NOT NULL DEFAULT '',
				edad_curada VARCHAR(128) NOT NULL DEFAULT '',
				comentarios_curador LONGTEXT NULL DEFAULT NULL,
				motivo_rechazo LONGTEXT NULL DEFAULT NULL,
				curador_user_id BIGINT UNSIGNED NULL DEFAULT NULL,
				foto_blob_id BIGINT UNSIGNED NOT NULL,
				token_dispositivo VARCHAR(64) NOT NULL DEFAULT '',
				ip_subida VARCHAR(64) NOT NULL DEFAULT '',
				consentimiento TINYINT(1) NOT NULL DEFAULT 0,
				PRIMARY KEY  (id),
				KEY estado (estado),
				KEY formacion_catalogada (formacion_catalogada_id, estado),
				KEY token_dia (token_dispositivo, fecha_creacion),
				KEY ip_dia (ip_subida, fecha_creacion),
				KEY email_contacto (email_contacto)
			) {$charset_collate};",

			// Tokens RGPD de un solo uso emitidos al solicitar borrado
			// por email. La fila se inserta al solicitar, se marca
			// `usado_en` cuando el usuario hace click, y a partir de
			// ese momento el handler ejecuta el borrado de las
			// aportaciones de ese email. Tokens caducan en 24h.
			"CREATE TABLE {$fosiles_borrados_rgpd} (
				id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
				email_contacto VARCHAR(190) NOT NULL,
				token_hash CHAR(64) NOT NULL,
				expira_en DATETIME NOT NULL,
				usado_en DATETIME NULL DEFAULT NULL,
				ip_solicitud VARCHAR(64) NOT NULL DEFAULT '',
				creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				PRIMARY KEY  (id),
				UNIQUE KEY token_hash (token_hash),
				KEY email_expira (email_contacto, expira_en)
			) {$charset_collate};",

			// El Taller: un progreso por niño (fusionado en cada sincronización).
			"CREATE TABLE {$el_taller_progreso} (
				nino_id BIGINT UNSIGNED NOT NULL,
				progreso_json LONGTEXT NOT NULL,
				actualizado_en DATETIME NOT NULL,
				PRIMARY KEY  (nino_id)
			) {$charset_collate};",

			// El Taller: consultas al sensei por niño y día (cuota).
			"CREATE TABLE {$el_taller_sensei} (
				nino_id BIGINT UNSIGNED NOT NULL,
				fecha DATE NOT NULL,
				turnos SMALLINT UNSIGNED NOT NULL DEFAULT 0,
				PRIMARY KEY  (nino_id,fecha)
			) {$charset_collate};",
		);
	}

	/**
	 * Filas seed para `ns_games`. INSERT IGNORE — idempotente.
	 *
	 * Las Versiones (10-14) y futuros juegos se añaden cuando sus apps
	 * empiecen a sincronizar; mantener esta lista corta evita que la tabla
	 * declare juegos que aún no existen como producto.
	 */
	public static function games_seed(): array {
		return array(
			array(
				'id'             => 'uno-roto',
				'name'           => 'Uno Roto',
				'age_min'        => 9,
				'age_max'        => 12,
				'schema_version' => '1.0',
			),
			// 'el-cuaderno' arranca su sincronización en S2. El nombre
			// es provisional (biblia §10.1).
			array(
				'id'             => 'el-cuaderno',
				'name'           => 'El Cuaderno',
				'age_min'        => 9,
				'age_max'        => 13,
				'schema_version' => '1.0',
			),
			// 'las-versiones' empieza a sincronizar en F8.7 — Mosaico
			// del Arco 1 al endpoint /companion/mosaicos. El esquema
			// del Mosaico v2 (8 viñetas con código de confianza) es
			// estable; los Arcos 2-4 lo reusarán.
			array(
				'id'             => 'las-versiones',
				'name'           => 'Las Versiones',
				'age_min'        => 10,
				'age_max'        => 14,
				'schema_version' => '1.0',
			),
			// 'fosiles' es app **del operador para adulto aficionado**,
			// no de la línea Kids. Se siembra el game_id porque las
			// tablas de aportaciones a la comunidad lo referencian
			// implícitamente (multi-tenancy del plugin); el age_min/max
			// no se aplica al ser adulto, pero respetan el formato de la
			// columna (TINYINT UNSIGNED NOT NULL).
			array(
				'id'             => 'el-taller',
				'name'           => 'El Taller',
				'age_min'        => 10,
				'age_max'        => 16,
				'schema_version' => '1.0',
			),
			array(
				'id'             => 'fosiles',
				'name'           => 'Fósiles',
				'age_min'        => 16,
				'age_max'        => 99,
				'schema_version' => '1.0',
			),
		);
	}
}
