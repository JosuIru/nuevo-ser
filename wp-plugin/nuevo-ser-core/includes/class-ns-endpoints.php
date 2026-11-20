<?php
/**
 * Registra las rutas REST bajo dos namespaces:
 *
 *   /wp-json/nuevo-ser/v1/*   ← canónico (a partir de C3)
 *   /wp-json/uno-roto/v1/*    ← alias deprecado (clientes Flutter desplegados)
 *
 * Las rutas alias devuelven el header HTTP `Deprecation: true` (RFC 9745) más
 * `Sunset` apuntando a v1.5 cuando se retiren. Internamente delegan al mismo
 * callback — comportamiento funcional idéntico.
 *
 * Endpoints públicos (sin JWT):
 *   POST /register   email + password + nombre_tutor + nombre_nino
 *   POST /login      email + password  → { token, nino_id }
 *
 * Endpoints protegidos (JWT en Authorization: Bearer):
 *   GET  /progress           → estado completo del niño
 *   POST /sync/progress      → merge LWW, devuelve estado final
 *   DELETE /account          → borrado GDPR completo
 *
 * Todos devuelven JSON. Errores como WP_REST_Response con código
 * HTTP apropiado.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Endpoints {

	/** Namespace canónico — usar en clientes nuevos. */
	public const NAMESPACE_CANONICO = 'nuevo-ser/v1';

	/** Namespace alias — vivo hasta v1.5 para clientes Flutter desplegados. */
	public const NAMESPACE_ALIAS = 'uno-roto/v1';

	public static function registrar(): void {
		self::registrar_grupo( self::NAMESPACE_CANONICO );
		self::registrar_grupo( self::NAMESPACE_ALIAS );
		// Endpoints de acompañamiento. Solo en el canónico: los clientes
		// desplegados de Uno Roto nunca los llamarán, no hay razón para
		// cargar el alias con deuda nueva.
		// Las rutas reales (las que tienen handler) se registran primero
		// para que ganen sobre el handler genérico 501 si hubiera
		// solapamiento accidental.
		self::registrar_companion_real( self::NAMESPACE_CANONICO );
		self::registrar_companion( self::NAMESPACE_CANONICO );
		// Endpoints específicos del juego El Cuaderno. Solo en canónico —
		// el alias `uno-roto/v1` no debería llevar deuda nueva.
		self::registrar_el_cuaderno_real( self::NAMESPACE_CANONICO );
		// El Taller: progreso sincronizado y sensei IA. Solo canónico.
		self::registrar_el_taller( self::NAMESPACE_CANONICO );
		// Endpoints del módulo de ciencia ciudadana de la app Fósiles
		// (`/nuevo-ser/v1/fosiles/*`). Mismo principio: solo canónico.
		self::registrar_fosiles_comunidad( self::NAMESPACE_CANONICO );
		add_filter( 'rest_post_dispatch', array( __CLASS__, 'marcar_alias_deprecado' ), 10, 3 );
	}

	/**
	 * Endpoints del módulo de ciencia ciudadana de la app Fósiles
	 * (NS_Fosiles_Comunidad). Tres bloques:
	 *
	 *   - Públicos (sin auth, rate-limited en handler):
	 *       POST /fosiles/aportaciones
	 *       GET  /fosiles/fotos-comunidad/por-formacion/{codigo}
	 *       POST /fosiles/aportaciones/borrar-mis-aportaciones
	 *       GET  /fosiles/aportaciones/confirmar-borrado
	 *
	 *   - Curador (JWT curador/admin o capability nuevoser_fosiles_revisar):
	 *       GET  /fosiles/aportaciones
	 *       GET  /fosiles/aportaciones/{id}
	 *       POST /fosiles/aportaciones/{id}/aprobar
	 *       POST /fosiles/aportaciones/{id}/rechazar
	 *       POST /fosiles/aportaciones/{id}/archivar
	 *
	 *   - Admin (capability nuevoser_fosiles_gestionar_catalogo):
	 *       GET    /fosiles/formaciones-catalogadas
	 *       POST   /fosiles/formaciones-catalogadas
	 *       PUT    /fosiles/formaciones-catalogadas/{id}
	 *       DELETE /fosiles/formaciones-catalogadas/{id}
	 */
	private static function registrar_fosiles_comunidad( string $namespace ): void {
		register_rest_route(
			$namespace,
			'/fosiles/aportaciones',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'crear_aportacion' ),
					'permission_callback' => '__return_true',
				),
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'listar_aportaciones_curador' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_curador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/borrar-mis-aportaciones',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'solicitar_borrado_rgpd' ),
					'permission_callback' => '__return_true',
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/confirmar-borrado',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'confirmar_borrado_rgpd' ),
					'permission_callback' => '__return_true',
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/(?P<id>\d+)',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'ver_aportacion_curador' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_curador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/(?P<id>\d+)/aprobar',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'aprobar_aportacion' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_curador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/(?P<id>\d+)/rechazar',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'rechazar_aportacion' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_curador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/aportaciones/(?P<id>\d+)/archivar',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'archivar_aportacion' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_curador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/fotos-comunidad/por-formacion/(?P<codigo>[A-Za-z0-9_\-]+)',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'listar_fotos_por_formacion' ),
					'permission_callback' => '__return_true',
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/formaciones-catalogadas',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'listar_formaciones_admin' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_admin' ),
				),
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'crear_formacion_admin' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_admin' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/fosiles/formaciones-catalogadas/(?P<id>\d+)',
			array(
				array(
					'methods'             => 'PUT',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'actualizar_formacion_admin' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_admin' ),
				),
				array(
					'methods'             => 'DELETE',
					'callback'            => array( 'NS_Fosiles_Comunidad', 'borrar_formacion_admin' ),
					'permission_callback' => array( 'NS_Fosiles_Comunidad', 'permiso_admin' ),
				),
			)
		);
	}

	/**
	 * Endpoints de companion ya implementados de verdad. La lista crece
	 * a medida que cada ruta sale del estado 501; cuando todas estén
	 * aquí, [self::endpoints_companion] queda vacío y se borra.
	 */
	private static function registrar_companion_real( string $namespace ): void {
		register_rest_route(
			$namespace,
			'/companion/cuaderno/entries',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Companion_Cuaderno', 'crear_entrada' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Companion_Cuaderno', 'listar_entradas' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/companion/mosaicos',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Companion_Mosaicos', 'crear_mosaico' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Companion_Mosaicos', 'listar_mosaicos' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/classrooms/(?P<code>[A-Za-z0-9]+)/join',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Companion_Aulas', 'unirse' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		// POST /classrooms — el profesor crea un aula. Requiere JWT
		// con tipo='profesor' (emitido por POST /auth/login).
		register_rest_route(
			$namespace,
			'/classrooms',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Companion_Aulas', 'crear_aula' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt_profesor' ),
				),
			)
		);

		// GET /classrooms/{id}/aggregates — agregados k≥5 del aula
		// para el profesor dueño.
		register_rest_route(
			$namespace,
			'/classrooms/(?P<id>\d+)/aggregates',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Companion_Aulas', 'agregados_aula' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt_profesor' ),
				),
			)
		);

		// Cuidadores — POC marcado BORRADOR (NS_Caregivers cabecera de
		// archivo). Pendiente LOPDGDD ítem 5 antes de producción.
		register_rest_route(
			$namespace,
			'/caregivers/link/request',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Caregivers', 'solicitar_vinculo' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);
		register_rest_route(
			$namespace,
			'/caregivers/link/verify',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Caregivers', 'verificar_vinculo' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt_cuidador' ),
				),
			)
		);
		register_rest_route(
			$namespace,
			'/caregivers/(?P<caregiverId>\d+)/children/(?P<childId>\d+)/summary',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_Caregivers', 'ver_resumen' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt_cuidador' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/companion/aggregates/weekly',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Companion_Agregados', 'archivar' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		// Login de adultos (profesor/cuidador). Público — este endpoint
		// es el que **emite** el JWT, así que no puede pedirlo. Paralelo
		// al `/login` del niño (que sigue tal cual en este mismo archivo).
		register_rest_route(
			$namespace,
			'/auth/login',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_Auth_Adulto', 'login' ),
					'permission_callback' => '__return_true',
				),
			)
		);
	}

	/**
	 * Endpoints específicos del juego El Cuaderno (doc 03 §5.3).
	 *
	 *   POST /el-cuaderno/observaciones  — registra metadatos de una
	 *                                       observación (sin texto libre,
	 *                                       solo what_seen_hash).
	 *   POST /el-cuaderno/sit-spot       — establece o jubila el sit spot.
	 *   GET  /el-cuaderno/misterios      — devuelve el catálogo filtrado
	 *                                       por region_code y season.
	 */
	private static function registrar_el_cuaderno_real( string $namespace ): void {
		register_rest_route(
			$namespace,
			'/el-cuaderno/observaciones',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_El_Cuaderno', 'crear_observacion' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/el-cuaderno/sit-spot',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_El_Cuaderno', 'establecer_sit_spot' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/el-cuaderno/misterios',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_El_Cuaderno', 'listar_misterios' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);

		register_rest_route(
			$namespace,
			'/el-cuaderno/tutor',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_El_Cuaderno', 'tutor_responder' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);
	}

	/**
	 * Endpoints de El Taller (NS_El_Taller), con el JWT del niño:
	 *   GET|POST /el-taller/progreso  — leer / fusionar el progreso.
	 *   POST     /el-taller/sensei    — comentario del sensei IA sobre un dibujo.
	 */
	private static function registrar_el_taller( string $namespace ): void {
		register_rest_route(
			$namespace,
			'/el-taller/progreso',
			array(
				array(
					'methods'             => 'GET',
					'callback'            => array( 'NS_El_Taller', 'obtener_progreso' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_El_Taller', 'sincronizar_progreso' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);
		register_rest_route(
			$namespace,
			'/el-taller/sensei',
			array(
				array(
					'methods'             => 'POST',
					'callback'            => array( 'NS_El_Taller', 'sensei_responder' ),
					'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
				),
			)
		);
	}

	/**
	 * Filtro `rest_post_dispatch`: si la ruta resuelta vive bajo el namespace
	 * alias, añade `Deprecation: true` y un `Sunset` informativo a la respuesta.
	 * Los clientes nuevos usan la canónica y no ven estos headers.
	 */
	public static function marcar_alias_deprecado( $response, $server, $request ) {
		if ( ! ( $response instanceof WP_REST_Response ) ) {
			return $response;
		}
		$ruta = (string) $request->get_route();
		if ( str_starts_with( $ruta, '/' . self::NAMESPACE_ALIAS . '/' ) ) {
			$response->header( 'Deprecation', 'true' );
			$response->header( 'Sunset', 'planned for plugin v1.5' );
			$ruta_canonica = '/' . self::NAMESPACE_CANONICO . substr( $ruta, strlen( self::NAMESPACE_ALIAS ) + 1 );
			$response->header( 'Link', '<' . rest_url( ltrim( $ruta_canonica, '/' ) ) . '>; rel="successor-version"' );
		}
		return $response;
	}

	private static function registrar_grupo( string $namespace ): void {
		register_rest_route(
			$namespace,
			'/register',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'registrar_cuenta' ),
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			$namespace,
			'/login',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'iniciar_sesion' ),
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			$namespace,
			'/auth/anadir-nino',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'anadir_nino' ),
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			$namespace,
			'/progress',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'obtener_progreso' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
			)
		);

		register_rest_route(
			$namespace,
			'/sync/progress',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'sincronizar_progreso' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
			)
		);

		register_rest_route(
			$namespace,
			'/account',
			array(
				'methods'             => 'DELETE',
				'callback'            => array( __CLASS__, 'borrar_cuenta' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
			)
		);

		register_rest_route(
			$namespace,
			'/tutor/explicar',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'tutor_explicar' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt' ),
			)
		);

		register_rest_route(
			$namespace,
			'/tutor/stats',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'tutor_stats' ),
				'permission_callback' => array( __CLASS__, 'permiso_admin_wp' ),
			)
		);

		register_rest_route(
			$namespace,
			'/audio/manifest',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'audio_manifest' ),
				'permission_callback' => '__return_true',
			)
		);

		// Endpoints del modo tutor. JWT distinto al del cliente del niño
		// (carga `usuario_id` en lugar de `nino_id`, TTL 15 minutos) para
		// que un dispositivo en manos del niño no pueda usarlo si el
		// tutor olvida cerrar.

		register_rest_route(
			$namespace,
			'/auth/iniciar-sesion-tutor',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'iniciar_sesion_tutor' ),
				'permission_callback' => '__return_true',
			)
		);

		// Reset de contraseña: público, anti-enumeración + rate limit.
		register_rest_route(
			$namespace,
			'/auth/solicitar-reset',
			array(
				'methods'             => 'POST',
				'callback'            => array( __CLASS__, 'auth_solicitar_reset' ),
				'permission_callback' => '__return_true',
			)
		);
		// La página HTML que el usuario abre desde el email. Acepta GET
		// (formulario) y POST (envío del formulario).
		register_rest_route(
			$namespace,
			'/auth/pagina-reset',
			array(
				'methods'             => array( 'GET', 'POST' ),
				'callback'            => array( __CLASS__, 'auth_pagina_reset' ),
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			$namespace,
			'/tutor/ninos',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'tutor_ninos' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt_tutor' ),
			)
		);

		register_rest_route(
			$namespace,
			'/tutor/progreso-nino/(?P<nino_id>\d+)',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'tutor_progreso_nino' ),
				'permission_callback' => array( __CLASS__, 'permiso_jwt_tutor' ),
			)
		);
	}

	/**
	 * Permission callback: solo admins de WordPress. Para endpoints
	 * de auditoría o métricas que NO deben estar abiertos a los
	 * tokens JWT del cliente.
	 */
	public static function permiso_admin_wp() {
		if ( ! is_user_logged_in() || ! current_user_can( 'manage_options' ) ) {
			return new WP_Error(
				'uroto_solo_admin',
				'Solo el administrador de WordPress puede ver esto.',
				array( 'status' => 403 )
			);
		}
		return true;
	}

	// -------------------------------------------------------------
	// Permission callback JWT.
	// -------------------------------------------------------------

	public static function permiso_jwt( WP_REST_Request $request ) {
		$token = NS_JWT::leer_token_de_request( $request );
		if ( ! $token ) {
			return new WP_Error(
				'uroto_sin_token',
				'Falta el header Authorization: Bearer.',
				array( 'status' => 401 )
			);
		}
		$carga = NS_JWT::validar( $token );
		if ( ! $carga || 'nino' !== NS_JWT::tipo_de_carga( $carga ) || ! isset( $carga['nino_id'] ) ) {
			return new WP_Error(
				'uroto_token_invalido',
				'Token no válido o expirado.',
				array( 'status' => 401 )
			);
		}
		$request->set_param( '_nino_id', (int) $carga['nino_id'] );
		return true;
	}

	/**
	 * Permission callback para endpoints que requieren un JWT de
	 * profesor (`tipo='profesor'`). Adjunta `_user_id` al request.
	 */
	public static function permiso_jwt_profesor( WP_REST_Request $request ) {
		return self::permiso_jwt_adulto( $request, 'profesor' );
	}

	/**
	 * Permission callback para endpoints que requieren un JWT de
	 * cuidador (`tipo='cuidador'`). Adjunta `_user_id` al request.
	 */
	public static function permiso_jwt_cuidador( WP_REST_Request $request ) {
		return self::permiso_jwt_adulto( $request, 'cuidador' );
	}

	private static function permiso_jwt_adulto( WP_REST_Request $request, string $tipo_esperado ) {
		$token = NS_JWT::leer_token_de_request( $request );
		if ( ! $token ) {
			return new WP_Error(
				'ns_sin_token',
				'Falta el header Authorization: Bearer.',
				array( 'status' => 401 )
			);
		}
		$carga = NS_JWT::validar( $token );
		if ( ! $carga
			|| $tipo_esperado !== NS_JWT::tipo_de_carga( $carga )
			|| ! isset( $carga['user_id'] ) ) {
			return new WP_Error(
				'ns_token_invalido',
				'Token no válido para este endpoint.',
				array( 'status' => 401 )
			);
		}
		$request->set_param( '_user_id', (int) $carga['user_id'] );
		return true;
	}

	// -------------------------------------------------------------
	// POST /register
	// -------------------------------------------------------------

	public static function registrar_cuenta( WP_REST_Request $request ) {
		$email         = sanitize_email( (string) $request->get_param( 'email' ) );
		$password      = (string) $request->get_param( 'password' );
		$nombre_tutor  = sanitize_text_field(
			(string) $request->get_param( 'nombre_tutor' )
		);
		$nombre_nino   = sanitize_text_field(
			(string) $request->get_param( 'nombre_nino' )
		);
		$locale        = sanitize_text_field(
			(string) ( $request->get_param( 'locale' ) ?: 'es' )
		);

		if ( ! is_email( $email ) || strlen( $password ) < 8 || '' === $nombre_nino ) {
			return new WP_REST_Response(
				array( 'error' => 'Datos inválidos.' ),
				400
			);
		}

		if ( NS_Repositorio::buscar_usuario_por_email( $email ) ) {
			return new WP_REST_Response(
				array( 'error' => 'El email ya está registrado.' ),
				409
			);
		}

		$usuario_id = NS_Repositorio::crear_usuario(
			$email,
			password_hash( $password, PASSWORD_DEFAULT ),
			$nombre_tutor,
			$locale
		);
		$nino_id    = NS_Repositorio::crear_nino( $usuario_id, $nombre_nino, $locale );

		return new WP_REST_Response(
			array(
				'token'       => NS_JWT::firmar( array( 'nino_id' => $nino_id ) ),
				'nino_id'     => $nino_id,
				'usuario_id'  => $usuario_id,
			),
			201
		);
	}

	// -------------------------------------------------------------
	// POST /login
	// -------------------------------------------------------------

	public static function iniciar_sesion( WP_REST_Request $request ) {
		$email    = sanitize_email( (string) $request->get_param( 'email' ) );
		$password = (string) $request->get_param( 'password' );
		$nino_id_pedido = $request->get_param( 'nino_id' );

		$usuario = NS_Repositorio::buscar_usuario_por_email( $email );
		if ( ! $usuario || ! password_verify( $password, $usuario['password_hash'] ) ) {
			return new WP_REST_Response(
				array( 'error' => 'Credenciales incorrectas.' ),
				401
			);
		}

		$ninos = NS_Repositorio::ninos_de_usuario( (int) $usuario['id'] );
		if ( empty( $ninos ) ) {
			return new WP_REST_Response(
				array( 'error' => 'La cuenta no tiene ningún perfil de niño.' ),
				404
			);
		}

		// Si se pidió un nino_id concreto, verificamos que pertenece a este
		// tutor. Si no, devolvemos el más antiguo (ninos[0]) — comportamiento
		// retro-compatible con clientes que aún no envían `nino_id`.
		$nino_id = (int) $ninos[0]['id'];
		if ( null !== $nino_id_pedido && '' !== $nino_id_pedido ) {
			$pedido = (int) $nino_id_pedido;
			$pertenece = false;
			foreach ( $ninos as $candidato ) {
				if ( (int) $candidato['id'] === $pedido ) {
					$pertenece = true;
					break;
				}
			}
			if ( ! $pertenece ) {
				return new WP_REST_Response(
					array( 'error' => 'El niño solicitado no pertenece a esta cuenta.' ),
					403
				);
			}
			$nino_id = $pedido;
		}

		// Lista pública de niños del tutor — útil al cliente para mostrar un
		// selector cuando hay varios. Solo id + nombre, no datos sensibles.
		$lista_ninos = array_map(
			static function ( array $n ): array {
				return array(
					'id'             => (int) $n['id'],
					'nombre_mostrar' => (string) $n['nombre_mostrar'],
				);
			},
			$ninos
		);

		return new WP_REST_Response(
			array(
				'token'   => NS_JWT::firmar( array( 'nino_id' => $nino_id ) ),
				'nino_id' => $nino_id,
				'ninos'   => $lista_ninos,
			),
			200
		);
	}

	// -------------------------------------------------------------
	// POST /auth/anadir-nino
	//
	// Añade un niño nuevo a un tutor que ya existe. Autentica con email +
	// password (no con JWT, porque el dispositivo que llama puede no haber
	// hecho login todavía — caso típico: segundo móvil del mismo padre).
	// Devuelve token JWT del niño recién creado, listo para usar como
	// sesión activa en este dispositivo.
	// -------------------------------------------------------------

	public static function anadir_nino( WP_REST_Request $request ) {
		$email       = sanitize_email( (string) $request->get_param( 'email' ) );
		$password    = (string) $request->get_param( 'password' );
		$nombre_nino = sanitize_text_field(
			(string) $request->get_param( 'nombre_nino' )
		);
		$locale      = sanitize_text_field(
			(string) ( $request->get_param( 'locale' ) ?: 'es' )
		);

		if ( ! is_email( $email ) || '' === $password || '' === $nombre_nino ) {
			return new WP_REST_Response(
				array( 'error' => 'Datos inválidos.' ),
				400
			);
		}

		$usuario = NS_Repositorio::buscar_usuario_por_email( $email );
		if ( ! $usuario || ! password_verify( $password, $usuario['password_hash'] ) ) {
			return new WP_REST_Response(
				array( 'error' => 'Credenciales incorrectas.' ),
				401
			);
		}

		$nino_id = NS_Repositorio::crear_nino(
			(int) $usuario['id'],
			$nombre_nino,
			$locale
		);

		return new WP_REST_Response(
			array(
				'token'   => NS_JWT::firmar( array( 'nino_id' => $nino_id ) ),
				'nino_id' => $nino_id,
			),
			201
		);
	}

	// -------------------------------------------------------------
	// GET /progress
	// -------------------------------------------------------------

	public static function obtener_progreso( WP_REST_Request $request ) {
		$nino_id = (int) $request->get_param( '_nino_id' );
		return new WP_REST_Response(
			array(
				'progreso'    => NS_Repositorio::cargar_progreso( $nino_id ),
				'habilidades' => NS_Repositorio::cargar_habilidades( $nino_id ),
			),
			200
		);
	}

	// -------------------------------------------------------------
	// POST /sync/progress
	// -------------------------------------------------------------

	public static function sincronizar_progreso( WP_REST_Request $request ) {
		$nino_id = (int) $request->get_param( '_nino_id' );
		$entrada = array(
			'progreso'    => $request->get_param( 'progreso' ) ?: null,
			'habilidades' => $request->get_param( 'habilidades' ) ?: array(),
		);
		$resultado = NS_Sincronizador::sincronizar( $nino_id, $entrada );
		return new WP_REST_Response( $resultado, 200 );
	}

	// -------------------------------------------------------------
	// DELETE /account
	// -------------------------------------------------------------

	public static function borrar_cuenta( WP_REST_Request $request ) {
		$nino_id = (int) $request->get_param( '_nino_id' );
		$nino    = NS_Repositorio::buscar_nino( $nino_id );
		if ( ! $nino ) {
			return new WP_REST_Response(
				array( 'error' => 'Niño no encontrado.' ),
				404
			);
		}
		NS_Repositorio::borrar_cuenta( (int) $nino['usuario_id'] );
		return new WP_REST_Response( array( 'ok' => true ), 200 );
	}

	// -------------------------------------------------------------
	// POST /tutor/explicar
	// -------------------------------------------------------------

	public static function tutor_explicar( WP_REST_Request $request ) {
		$id_habilidad       = sanitize_text_field(
			(string) $request->get_param( 'id_habilidad' )
		);
		$pregunta           = (string) $request->get_param( 'pregunta' );
		$contexto_fragmento = $request->get_param( 'contexto_fragmento' );
		if ( null !== $contexto_fragmento ) {
			$contexto_fragmento = sanitize_text_field( (string) $contexto_fragmento );
		}

		if ( '' === $id_habilidad ) {
			return new WP_REST_Response(
				array( 'error' => 'id_habilidad requerido.' ),
				400
			);
		}

		return NS_Tutor::explicar( $id_habilidad, $pregunta, $contexto_fragmento );
	}

	// -------------------------------------------------------------
	// GET /tutor/stats  (solo admin WP)
	// -------------------------------------------------------------

	public static function tutor_stats( WP_REST_Request $request ) {
		return new WP_REST_Response( NS_Tutor::metricas(), 200 );
	}

	// -------------------------------------------------------------
	// GET /audio/manifest  (público, sin JWT)
	// -------------------------------------------------------------
	//
	// Devuelve el manifest del paquete sonoro descargable más reciente:
	//   { version, url, sha256, tamano_bytes }
	//
	// El paquete se sirve desde wp-content/uploads/uno-roto/audio/.
	// Convención de nombres: audio_v<N>.zip + audio_v<N>.sha256.
	//
	// El servidor escanea el directorio y elige la versión numérica más
	// alta. Si no hay paquetes, devuelve 404.
	//
	// El cliente Flutter (lib/datos/descargador_audio.dart) consume este
	// endpoint al primer arranque y desde Ajustes de sonido →
	// "Comprobar actualizaciones".

	public static function audio_manifest( WP_REST_Request $request ) {
		$dir_uploads = wp_upload_dir();
		$dir_audio   = trailingslashit( $dir_uploads['basedir'] ) . 'uno-roto/audio';
		$base_url    = trailingslashit( $dir_uploads['baseurl'] ) . 'uno-roto/audio';

		if ( ! is_dir( $dir_audio ) ) {
			return new WP_REST_Response(
				array( 'error' => 'Paquete sonoro no publicado todavía.' ),
				404
			);
		}

		// Busca audio_vN.zip y se queda con la N más alta.
		$candidatos      = glob( $dir_audio . '/audio_v*.zip' ) ?: array();
		$mejor_version   = -1;
		$mejor_zip       = null;
		foreach ( $candidatos as $ruta ) {
			$nombre = basename( $ruta );
			if ( preg_match( '/^audio_v(\d+)\.zip$/', $nombre, $m ) ) {
				$version_int = (int) $m[1];
				if ( $version_int > $mejor_version ) {
					$mejor_version = $version_int;
					$mejor_zip     = $ruta;
				}
			}
		}

		if ( $mejor_version < 0 || null === $mejor_zip ) {
			return new WP_REST_Response(
				array( 'error' => 'No hay audio_v<N>.zip en uno-roto/audio.' ),
				404
			);
		}

		// El sha256 se lee de un fichero hermano audio_vN.sha256 si
		// existe (escrito por el script de despliegue), o se calcula al
		// vuelo y se cachea como transient 1h.
		$ruta_sha = preg_replace( '/\.zip$/', '.sha256', $mejor_zip );
		$sha256   = '';
		if ( file_exists( $ruta_sha ) ) {
			$contenido = trim( (string) file_get_contents( $ruta_sha ) );
			// Aceptamos formato `<sha>` o `<sha>  <archivo>` (sha256sum).
			$partes = preg_split( '/\s+/', $contenido );
			$sha256 = strtolower( $partes[0] ?? '' );
		}
		if ( '' === $sha256 ) {
			$clave_cache = 'uroto_audio_sha256_v' . $mejor_version;
			$cacheado    = get_transient( $clave_cache );
			if ( false !== $cacheado ) {
				$sha256 = $cacheado;
			} else {
				$sha256 = strtolower( hash_file( 'sha256', $mejor_zip ) ?: '' );
				set_transient( $clave_cache, $sha256, HOUR_IN_SECONDS );
			}
		}

		$tamano = filesize( $mejor_zip );

		// La URL devuelta sigue el esquema (http/https) de la petición que
		// llega al endpoint, no el del `siteurl` de WP. Así el cliente
		// móvil siempre recibe URLs coherentes con el dominio por el que
		// entró, aunque el admin tenga `home_url()` mal configurado o el
		// sitio se mueva a otro dominio. `set_url_scheme()` también acepta
		// detrás de un proxy si éste pasa `X-Forwarded-Proto`/`HTTPS`.
		$url_zip      = $base_url . '/' . basename( $mejor_zip );
		$esquema_real = self::detectar_esquema_petición( $request );
		$url_zip      = set_url_scheme( $url_zip, $esquema_real );

		return new WP_REST_Response(
			array(
				'version'      => $mejor_version,
				'url'          => $url_zip,
				'sha256'       => $sha256,
				'tamano_bytes' => (int) $tamano,
			),
			200
		);
	}

	/**
	 * Determina si la petición entró por HTTPS, robusto a proxies
	 * (Cloudflare, nginx delante de Apache, Local WP, etc.). Devuelve
	 * `'https'` o `'http'`.
	 *
	 * `is_ssl()` solo mira `$_SERVER['HTTPS']` y el puerto, lo que falla
	 * cuando hay un proxy SSL terminator delante. Además miramos las
	 * cabeceras `X-Forwarded-Proto` y `X-Forwarded-Ssl` que casi todos
	 * los proxies envían.
	 */
	private static function detectar_esquema_petición( WP_REST_Request $request ) {
		if ( is_ssl() ) {
			return 'https';
		}
		$cabecera_proto = $request->get_header( 'x-forwarded-proto' );
		if ( is_string( $cabecera_proto ) && strtolower( trim( $cabecera_proto ) ) === 'https' ) {
			return 'https';
		}
		$cabecera_ssl = $request->get_header( 'x-forwarded-ssl' );
		if ( is_string( $cabecera_ssl ) && strtolower( trim( $cabecera_ssl ) ) === 'on' ) {
			return 'https';
		}
		return 'http';
	}

	// =================================================================
	// Modo tutor
	// =================================================================
	//
	// El tutor entra desde la pantalla "Cuaderno" del cliente con su
	// email + password, recibe un JWT con `usuario_id` y TTL corto (15
	// min). Con ese token puede listar sus niños y consultar el
	// progreso detallado de cada uno. NO puede modificar nada — solo
	// lectura. El tutor no usa el mismo JWT que el cliente del niño.

	private const TTL_TUTOR_SEGUNDOS = 15 * 60;

	/**
	 * Permission callback: valida un JWT de tutor (carga `usuario_id`).
	 * Inyecta `_usuario_id` en la request para los handlers.
	 */
	public static function permiso_jwt_tutor( WP_REST_Request $request ) {
		$token = NS_JWT::leer_token_de_request( $request );
		if ( ! $token ) {
			return new WP_Error(
				'uroto_sin_token',
				'Falta el header Authorization: Bearer.',
				array( 'status' => 401 )
			);
		}
		$carga = NS_JWT::validar( $token );
		if ( ! $carga || ! isset( $carga['usuario_id'] ) ) {
			return new WP_Error(
				'uroto_token_invalido',
				'Token de tutor no válido o expirado.',
				array( 'status' => 401 )
			);
		}
		$request->set_param( '_usuario_id', (int) $carga['usuario_id'] );
		return true;
	}

	// -------------------------------------------------------------
	// POST /auth/iniciar-sesion-tutor
	// -------------------------------------------------------------

	public static function iniciar_sesion_tutor( WP_REST_Request $request ) {
		$email    = sanitize_email( (string) $request->get_param( 'email' ) );
		$password = (string) $request->get_param( 'password' );

		if ( '' === $email || '' === $password ) {
			return new WP_REST_Response(
				array( 'error' => 'email y password requeridos.' ),
				400
			);
		}

		$usuario = NS_Repositorio::buscar_usuario_por_email( $email );
		if ( ! $usuario || ! password_verify( $password, $usuario['password_hash'] ) ) {
			return new WP_REST_Response(
				array( 'error' => 'Credenciales incorrectas.' ),
				401
			);
		}

		$token = NS_JWT::firmar(
			array( 'usuario_id' => (int) $usuario['id'] ),
			self::TTL_TUTOR_SEGUNDOS
		);

		return new WP_REST_Response(
			array(
				'token'              => $token,
				'usuario_id'         => (int) $usuario['id'],
				'nombre_tutor'       => (string) $usuario['nombre_tutor'],
				'expira_en_segundos' => self::TTL_TUTOR_SEGUNDOS,
			),
			200
		);
	}

	// -------------------------------------------------------------
	// GET /tutor/ninos
	// -------------------------------------------------------------

	public static function tutor_ninos( WP_REST_Request $request ) {
		$usuario_id = (int) $request->get_param( '_usuario_id' );
		$ninos      = NS_Repositorio::ninos_de_usuario( $usuario_id );

		// Para cada niño añadimos un mini-resumen del estado: esquirlas,
		// rango, arco actual y nº de habilidades vistas. Deja a la app
		// pintar el selector sin tener que llamar al endpoint detallado
		// para los seis perfiles a la vez.
		$lista = array();
		foreach ( $ninos as $nino ) {
			$nino_id     = (int) $nino['id'];
			$progreso    = NS_Repositorio::cargar_progreso( $nino_id );
			$habilidades = NS_Repositorio::cargar_habilidades( $nino_id );
			$lista[]     = array(
				'nino_id'              => $nino_id,
				'nombre_mostrar'       => (string) $nino['nombre_mostrar'],
				'locale'               => (string) $nino['locale'],
				'esquirlas_total'      => $progreso ? (int) $progreso['esquirlas_total'] : 0,
				'rango'                => $progreso ? (int) $progreso['rango'] : 0,
				'arco_actual'          => $progreso ? (int) $progreso['arco_actual'] : 1,
				'habilidades_vistas'   => count( $habilidades ),
			);
		}

		return new WP_REST_Response( array( 'ninos' => $lista ), 200 );
	}

	// -------------------------------------------------------------
	// GET /tutor/progreso-nino/{nino_id}
	// -------------------------------------------------------------

	public static function tutor_progreso_nino( WP_REST_Request $request ) {
		$usuario_id = (int) $request->get_param( '_usuario_id' );
		$nino_id    = (int) $request->get_param( 'nino_id' );

		$nino = NS_Repositorio::buscar_nino( $nino_id );
		if ( ! $nino ) {
			return new WP_REST_Response(
				array( 'error' => 'Niño no encontrado.' ),
				404
			);
		}
		// Aislamiento: un tutor solo puede ver progreso de SUS niños.
		if ( (int) $nino['usuario_id'] !== $usuario_id ) {
			return new WP_REST_Response(
				array( 'error' => 'Este niño no pertenece a tu cuenta.' ),
				403
			);
		}

		return new WP_REST_Response(
			array(
				'nino_id'        => $nino_id,
				'nombre_mostrar' => (string) $nino['nombre_mostrar'],
				'progreso'       => NS_Repositorio::cargar_progreso( $nino_id ),
				'habilidades'    => NS_Repositorio::cargar_habilidades( $nino_id ),
			),
			200
		);
	}

	// =================================================================
	// Reset de contraseña
	// =================================================================

	public static function auth_solicitar_reset( WP_REST_Request $request ) {
		$email = sanitize_email( (string) $request->get_param( 'email' ) );
		if ( '' === $email ) {
			return new WP_REST_Response(
				array( 'error' => 'email requerido.' ),
				400
			);
		}
		// Devolvemos siempre 200 — política anti-enumeración.
		NS_Reset_Password::solicitar( $email );
		return new WP_REST_Response(
			array( 'ok' => true ),
			200
		);
	}

	public static function auth_pagina_reset( WP_REST_Request $request ) {
		// Esta función emite HTML directo y mata la ejecución; nunca
		// retorna a WP_REST. Solo está aquí para registro de la ruta.
		NS_Reset_Password::pagina_reset_html( $request );
	}

	// =================================================================
	// Acompañamiento — endpoints reservados (C7).
	// =================================================================
	//
	// Reservan la superficie REST descrita en la doc nuevo-ser-core-
	// arquitectura.md §4.3 + §7. Las tablas asociadas (ns_classrooms,
	// ns_caregiver_links, ns_cuaderno_entries, ns_mosaicos,
	// ns_weekly_summaries) ya existen tras C7 — vacías. Los handlers
	// devuelven 501 con cuerpo Problem Details (RFC 7807) hasta que un
	// chunk posterior cablee la lógica.
	//
	// Razones para registrarlos ya:
	//   - Documentación viva: `curl /wp-json/nuevo-ser/v1/companion/...`
	//     devuelve un mensaje claro en lugar de 404 "endpoint no existe",
	//     útil cuando un consumidor explora la API.
	//   - Reserva de ruta: si alguien implementa una alternativa con
	//     mismo nombre antes de tiempo, choca con el 501 — visible.
	//   - Permite escribir tests cliente-servidor que verifiquen
	//     "el endpoint existe pero aún no está disponible".

	private static function registrar_companion( string $namespace ): void {
		foreach ( self::endpoints_companion() as $ruta => $metodos ) {
			register_rest_route(
				$namespace,
				$ruta,
				array(
					'methods'             => $metodos,
					'callback'            => array( __CLASS__, 'companion_no_implementado' ),
					// Permission abierto a propósito: 501 antes que 401 da
					// más información a quien explora la API. Los handlers
					// que sustituyan a éste sí pondrán el permission_callback
					// adecuado (JWT, admin, etc.).
					'permission_callback' => '__return_true',
				)
			);
		}
	}

	/**
	 * Mapa ruta → método HTTP de los endpoints de acompañamiento.
	 * Espejo literal de la doc §4.3 (sección "POST /companion/*",
	 * "POST /classrooms/*", "POST /caregivers/*"). Cualquier endpoint
	 * que se mueva de aquí debe sustituirse por su handler real al
	 * mismo tiempo, no antes.
	 */
	private static function endpoints_companion(): array {
		// Todas las rutas reservadas en C7 ya tienen handler real
		// (cuaderno + mosaicos + aulas + agregados + caregivers).
		// El array queda vacío y se borrará en una pasada de
		// limpieza junto con `companion_no_implementado` y
		// `registrar_companion`. De momento dejamos la estructura
		// para que el que añada un endpoint nuevo en el futuro lo
		// reserve aquí primero.
		return array();
	}

	/**
	 * Handler único de los endpoints reservados. Devuelve 501 con cuerpo
	 * Problem Details (RFC 7807) — `application/problem+json` — para que
	 * los clientes puedan distinguir esta respuesta de un error de
	 * autenticación o de servidor sin parsear texto libre.
	 */
	public static function companion_no_implementado( WP_REST_Request $request ) {
		$ruta = (string) $request->get_route();
		$problema = array(
			'type'     => 'https://coleccion-nuevo-ser.com/errors/not-implemented',
			'title'    => 'Endpoint reservado, no implementado todavía',
			'status'   => 501,
			'detail'   => 'Esta ruta forma parte de la superficie del paquete '
				. 'companion (doc nuevo-ser-core-arquitectura.md §7) y '
				. 'estará disponible cuando arranque la fase de '
				. 'acompañamiento. Hasta entonces, devuelve 501 '
				. 'a propósito.',
			'endpoint' => $ruta,
		);
		$respuesta = new WP_REST_Response( $problema, 501 );
		$respuesta->header( 'Content-Type', 'application/problem+json; charset=utf-8' );
		return $respuesta;
	}
}
