<?php
/**
 * Endpoints de El Taller (dibujo, manga, animación y código; repo ~/Projects/educa).
 *
 * Bajo `/wp-json/nuevo-ser/v1/el-taller/*`, con el JWT del niño:
 *
 *   GET  /el-taller/progreso   → el progreso guardado (o uno vacío).
 *   POST /el-taller/progreso   → fusiona el del dispositivo con el guardado y
 *                                devuelve el resultado (el cliente se queda con él).
 *   POST /el-taller/sensei     → comentario del «sensei» IA sobre un dibujo.
 *
 * Frontera de privacidad:
 *   - El progreso es un JSON pequeño (prácticas, tinta, días, logros): sin dibujos.
 *   - Las obras del portafolio NO suben: viven en el dispositivo.
 *   - La imagen del sensei se manda a Anthropic para comentarla y se descarta:
 *     no se guarda en el servidor ni en la caché. Solo se cuenta el turno (cuota diaria).
 *   - El sensei solo funciona si la familia lo activa en el dispositivo (el
 *     cliente lo pide tras una puerta para adultos) y nunca dibuja por el niño.
 *
 * La lógica pura (fusión, validación, prompt y lectura de la respuesta) es
 * estática y sin WordPress: la prueban tests/test_el_taller.php.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_El_Taller {

	/** Igual que MAXIMO_REGISTRO en educa/src/nucleo/progreso.ts. */
	const MAXIMO_REGISTRO = 400;

	/** Tamaño máximo del progreso que se acepta (bytes de JSON). */
	const MAXIMO_BYTES_ESTADO = 200000;

	/** Tamaño máximo de la imagen del sensei (base64). El cliente la reduce a 1024 px. */
	const MAXIMO_BYTES_IMAGEN = 1500000;

	/** Consultas al sensei por niño y día. */
	const SENSEI_MAXIMO_DIA = 10;

	/**
	 * Modelo del sensei. Se puede cambiar en wp-config.php con
	 * `define( 'NS_EL_TALLER_MODELO', '...' );` (p. ej. uno más barato).
	 */
	const MODELO_DEFECTO = 'claude-opus-5-5';

	const ENDPOINT_ANTHROPIC = 'https://api.anthropic.com/v1/messages';

	/** Ids de logros en el orden del cliente (LOGROS en progreso.ts). */
	const ORDEN_LOGROS = array( 'primer-paso', 'racha-3', 'racha-7', 'racha-30', 'cinco-ramas', 'maestria', 'animador', 'programador', 'mangaka', 'gesto-50', 'ia-sabia', 'mil-tinta' );

	// =================================================================
	// Lógica pura
	// =================================================================

	/** Estado vacío, con la misma forma que estadoInicial() del cliente. */
	public static function estado_inicial(): array {
		return array(
			'version'     => 1,
			'nombre'      => '',
			'tinta'       => 0,
			'practicas'   => array(),
			'diasActivos' => array(),
			'logros'      => array(),
			'registro'    => array(),
		);
	}

	/** Repara un estado recibido (mismas reglas que normalizarEstado del cliente). */
	public static function normalizar_estado( $datos ): array {
		$base = self::estado_inicial();
		if ( ! is_array( $datos ) ) {
			return $base;
		}
		$es_fecha = static function ( $valor ): bool {
			return is_string( $valor ) && 1 === preg_match( '/^\d{4}-\d{2}-\d{2}$/', $valor );
		};

		$practicas = array();
		if ( isset( $datos['practicas'] ) && is_array( $datos['practicas'] ) ) {
			foreach ( $datos['practicas'] as $id_habilidad => $veces ) {
				if ( ( is_int( $veces ) || is_float( $veces ) ) && $veces > 0 && is_finite( (float) $veces ) ) {
					$practicas[ substr( (string) $id_habilidad, 0, 60 ) ] = (int) floor( $veces );
				}
			}
		}

		$dias = array();
		if ( isset( $datos['diasActivos'] ) && is_array( $datos['diasActivos'] ) ) {
			$dias = array_values( array_unique( array_filter( $datos['diasActivos'], $es_fecha ) ) );
			sort( $dias );
		}

		$logros = array();
		if ( isset( $datos['logros'] ) && is_array( $datos['logros'] ) ) {
			$logros = array_values( array_filter( $datos['logros'], 'is_string' ) );
		}

		$registro = array();
		if ( isset( $datos['registro'] ) && is_array( $datos['registro'] ) ) {
			$validas = array_values(
				array_filter(
					$datos['registro'],
					static function ( $anotacion ) use ( $es_fecha ): bool {
						return is_array( $anotacion ) && $es_fecha( $anotacion['fecha'] ?? null ) && is_string( $anotacion['idHabilidad'] ?? null );
					}
				)
			);
			$validas = array_slice( $validas, -self::MAXIMO_REGISTRO );
			foreach ( $validas as $posicion => $anotacion ) {
				$id         = isset( $anotacion['id'] ) && is_string( $anotacion['id'] ) && '' !== $anotacion['id']
					? substr( $anotacion['id'], 0, 40 )
					: 'antiguo-' . $anotacion['fecha'] . '-' . $anotacion['idHabilidad'] . '-' . $posicion;
				$tinta      = $anotacion['tinta'] ?? 0;
				$registro[] = array(
					'id'          => $id,
					'fecha'       => $anotacion['fecha'],
					'idHabilidad' => substr( $anotacion['idHabilidad'], 0, 60 ),
					'tinta'       => ( is_int( $tinta ) || is_float( $tinta ) ) && $tinta > 0 ? (int) floor( $tinta ) : 0,
				);
			}
		}

		$tinta = $datos['tinta'] ?? 0;
		return array(
			'version'     => 1,
			'nombre'      => isset( $datos['nombre'] ) && is_string( $datos['nombre'] ) ? mb_substr( $datos['nombre'], 0, 40 ) : '',
			'tinta'       => ( is_int( $tinta ) || is_float( $tinta ) ) && $tinta >= 0 ? (int) floor( $tinta ) : 0,
			'practicas'   => $practicas,
			'diasActivos' => $dias,
			'logros'      => $logros,
			'registro'    => $registro,
		);
	}

	/**
	 * Fusiona dos progresos. Espejo de fusionarEstados() en educa/src/nucleo/fusion.ts:
	 * base = el de más tinta; se le suman las anotaciones del otro que no conoce (por id).
	 */
	public static function fusionar_estados( $estado_a, $estado_b ): array {
		$a = self::normalizar_estado( $estado_a );
		$b = self::normalizar_estado( $estado_b );
		if ( $a['tinta'] !== $b['tinta'] ) {
			list( $base, $otro ) = $a['tinta'] > $b['tinta'] ? array( $a, $b ) : array( $b, $a );
		} elseif ( count( $a['registro'] ) !== count( $b['registro'] ) ) {
			list( $base, $otro ) = count( $a['registro'] ) > count( $b['registro'] ) ? array( $a, $b ) : array( $b, $a );
		} else {
			list( $base, $otro ) = array( $a, $b );
		}

		$ids_base     = array_flip( array_column( $base['registro'], 'id' ) );
		$fecha_minima = count( $base['registro'] ) >= self::MAXIMO_REGISTRO ? $base['registro'][0]['fecha'] : '';
		$nuevas       = array_values(
			array_filter(
				$otro['registro'],
				static function ( array $anotacion ) use ( $ids_base, $fecha_minima ): bool {
					return ! isset( $ids_base[ $anotacion['id'] ] ) && strcmp( $anotacion['fecha'], $fecha_minima ) >= 0;
				}
			)
		);

		$practicas = $base['practicas'];
		$tinta     = $base['tinta'];
		foreach ( $nuevas as $anotacion ) {
			$practicas[ $anotacion['idHabilidad'] ] = ( $practicas[ $anotacion['idHabilidad'] ] ?? 0 ) + 1;
			$tinta                                 += $anotacion['tinta'];
		}
		foreach ( $otro['practicas'] as $id_habilidad => $veces ) {
			$practicas[ $id_habilidad ] = max( $practicas[ $id_habilidad ] ?? 0, $veces );
		}

		$registro = array_merge( $base['registro'], $nuevas );
		usort(
			$registro,
			static function ( array $anotacion_a, array $anotacion_b ): int {
				return strcmp( $anotacion_a['fecha'], $anotacion_b['fecha'] ) ?: strcmp( $anotacion_a['id'], $anotacion_b['id'] );
			}
		);
		$registro = array_slice( $registro, -self::MAXIMO_REGISTRO );

		$logros = array_values( array_unique( array_merge( $base['logros'], $otro['logros'] ) ) );
		usort(
			$logros,
			static function ( string $logro_a, string $logro_b ): int {
				$posicion_a = array_search( $logro_a, self::ORDEN_LOGROS, true );
				$posicion_b = array_search( $logro_b, self::ORDEN_LOGROS, true );
				return ( false === $posicion_a ? -1 : $posicion_a ) <=> ( false === $posicion_b ? -1 : $posicion_b );
			}
		);

		$dias = array_values( array_unique( array_merge( $base['diasActivos'], $otro['diasActivos'] ) ) );
		sort( $dias );

		return array(
			'version'     => 1,
			'nombre'      => '' !== $base['nombre'] ? $base['nombre'] : $otro['nombre'],
			'tinta'       => $tinta,
			'practicas'   => $practicas,
			'diasActivos' => $dias,
			'logros'      => $logros,
			'registro'    => $registro,
		);
	}

	/**
	 * Valida la petición al sensei.
	 *
	 * @return array{ok:bool, error?:string, imagen?:string, tipo?:string, idioma?:string, habilidad?:string, consigna?:string, pregunta?:string}
	 */
	public static function validar_peticion_sensei( $cuerpo ): array {
		if ( ! is_array( $cuerpo ) ) {
			return array( 'ok' => false, 'error' => 'cuerpo_no_es_objeto' );
		}
		$imagen = isset( $cuerpo['imagen'] ) ? (string) $cuerpo['imagen'] : '';
		$tipo   = isset( $cuerpo['tipo_imagen'] ) ? (string) $cuerpo['tipo_imagen'] : 'image/jpeg';
		if ( '' === $imagen ) {
			return array( 'ok' => false, 'error' => 'falta_imagen' );
		}
		if ( strlen( $imagen ) > self::MAXIMO_BYTES_IMAGEN ) {
			return array( 'ok' => false, 'error' => 'imagen_demasiado_grande' );
		}
		if ( ! in_array( $tipo, array( 'image/jpeg', 'image/png', 'image/webp' ), true ) ) {
			return array( 'ok' => false, 'error' => 'tipo_de_imagen_no_admitido' );
		}
		if ( 1 !== preg_match( '/^[A-Za-z0-9+\/]+={0,2}$/', $imagen ) ) {
			return array( 'ok' => false, 'error' => 'imagen_no_es_base64' );
		}
		$pregunta = isset( $cuerpo['pregunta'] ) ? trim( (string) $cuerpo['pregunta'] ) : '';
		if ( mb_strlen( $pregunta ) > 300 ) {
			return array( 'ok' => false, 'error' => 'pregunta_demasiado_larga' );
		}
		$idioma = isset( $cuerpo['idioma'] ) && 'eu' === $cuerpo['idioma'] ? 'eu' : 'es';
		return array(
			'ok'        => true,
			'imagen'    => $imagen,
			'tipo'      => $tipo,
			'idioma'    => $idioma,
			'habilidad' => mb_substr( trim( (string) ( $cuerpo['habilidad'] ?? '' ) ), 0, 80 ),
			'consigna'  => mb_substr( trim( (string) ( $cuerpo['consigna'] ?? '' ) ), 0, 300 ),
			'pregunta'  => $pregunta,
		);
	}

	/** Instrucciones del sensei. Estables (sin fechas ni ids) para que la caché de prompts funcione. */
	public static function prompt_sistema( string $idioma ): string {
		$lengua = 'eu' === $idioma
			? 'Responde SIEMPRE en euskera batua, sencillo y cercano.'
			: 'Responde SIEMPRE en castellano, sencillo y cercano.';
		return "Eres el sensei de El Taller, un taller de dibujo, manga y animación para un chaval de unos 12 años que dibuja mucho y bien.\n"
			. "Te enseña un dibujo suyo (a veces una foto de un dibujo en papel) y quiere mejorar.\n\n"
			. "Cómo respondes:\n"
			. "- Empieza por algo concreto que esté bien hecho y di por qué funciona (nada de elogios vacíos).\n"
			. "- Señala UNA o DOS cosas que mejorar, las más importantes, con un truco práctico para cada una.\n"
			. "- Termina con una pregunta que le haga mirar su dibujo (por ejemplo: «¿de dónde viene la luz?»).\n"
			. "- Si te dice qué estaba practicando, céntrate en eso.\n"
			. "- Máximo 120 palabras. Sin listas largas ni jerga sin explicar.\n\n"
			. "Lo que nunca haces:\n"
			. "- No dibujas por él ni describes cómo debería quedar el dibujo entero: él decide.\n"
			. "- No comparas su estilo con artistas para decirle que copie a nadie.\n"
			. "- No pides ni comentas datos personales, ni lo que se vea en la foto que no sea el dibujo (caras, casas, nombres escritos).\n"
			. "- Si la imagen no es un dibujo o no se ve bien, dilo con cariño y pide otra foto con buena luz.\n"
			. "- Si te pide algo que no es sobre dibujo, manga, animación o su proceso creativo, recondúcelo amablemente al dibujo.\n\n"
			. $lengua;
	}

	/** Texto del usuario que acompaña a la imagen. */
	public static function texto_usuario( array $peticion ): string {
		$partes = array();
		if ( '' !== $peticion['habilidad'] ) {
			$partes[] = 'Estoy practicando: ' . $peticion['habilidad'] . '.';
		}
		if ( '' !== $peticion['consigna'] ) {
			$partes[] = 'La misión era: ' . $peticion['consigna'];
		}
		$partes[] = '' !== $peticion['pregunta'] ? 'Mi pregunta: ' . $peticion['pregunta'] : '¿Qué te parece mi dibujo y qué mejorarías?';
		return implode( "\n", $partes );
	}

	/** Modelos que aceptan el fallback del servidor cuando rechazan una petición. */
	const MODELOS_CON_FALLBACK = array( 'claude-fable-5-2', 'claude-fable-5-1', 'claude-opus-5-5', 'claude-opus-5', 'claude-sonnet-5-5' );

	public static function admite_fallback( string $modelo ): bool {
		return in_array( $modelo, self::MODELOS_CON_FALLBACK, true );
	}

	/** Cuerpo de la petición a la API de Messages. */
	public static function cuerpo_peticion( array $peticion, string $modelo ): array {
		$cuerpo = array(
			'model'         => $modelo,
			// El razonamiento también gasta de aquí: margen de sobra para una respuesta corta.
			'max_tokens'    => 8000,
			'system'        => array(
				array(
					'type'          => 'text',
					'text'          => self::prompt_sistema( $peticion['idioma'] ),
					'cache_control' => array( 'type' => 'ephemeral' ),
				),
			),
			'messages'      => array(
				array(
					'role'    => 'user',
					'content' => array(
						array(
							'type'   => 'image',
							'source' => array(
								'type'       => 'base64',
								'media_type' => $peticion['tipo'],
								'data'       => $peticion['imagen'],
							),
						),
						array(
							'type' => 'text',
							'text' => self::texto_usuario( $peticion ),
						),
					),
				),
			),
		);
		// Haiku 4.5 y anteriores no aceptan `effort`.
		if ( 0 !== strpos( $modelo, 'claude-haiku-4' ) ) {
			$cuerpo['output_config'] = array( 'effort' => 'medium' );
		}
		// Si el modelo rechaza la petición, el servidor la repite con otro (beta en la cabecera).
		if ( self::admite_fallback( $modelo ) ) {
			$cuerpo['fallbacks'] = 'default';
		}
		return $cuerpo;
	}

	/**
	 * Saca el texto de la respuesta de la API. Devuelve null si no hay texto que mostrar
	 * (rechazo de toda la cadena, respuesta vacía o formato inesperado).
	 */
	public static function texto_de_respuesta( $datos ): ?string {
		if ( ! is_array( $datos ) || ! isset( $datos['content'] ) || ! is_array( $datos['content'] ) ) {
			return null;
		}
		if ( 'refusal' === ( $datos['stop_reason'] ?? '' ) ) {
			return null;
		}
		$textos = array();
		foreach ( $datos['content'] as $bloque ) {
			// Los bloques de razonamiento (thinking) y de cambio de modelo (fallback) no se enseñan.
			if ( is_array( $bloque ) && 'text' === ( $bloque['type'] ?? '' ) && isset( $bloque['text'] ) ) {
				$textos[] = (string) $bloque['text'];
			}
		}
		$texto = trim( implode( "\n", $textos ) );
		return '' === $texto ? null : $texto;
	}

	/** Mensaje amable cuando el sensei no puede contestar. */
	public static function mensaje_sin_respuesta( string $idioma ): string {
		return 'eu' === $idioma
			? 'Oraingoan ezin izan dut zure marrazkia ondo ikusi. Atera beste argazki bat argi onarekin, mesedez.'
			: 'Esta vez no he podido ver bien tu dibujo. Prueba con otra foto con buena luz, por favor.';
	}

	// =================================================================
	// Endpoints
	// =================================================================

	public static function obtener_progreso( WP_REST_Request $request ) {
		$nino_id = (int) $request->get_param( '_nino_id' );
		return new WP_REST_Response( array( 'progreso' => self::leer_progreso( $nino_id ) ), 200 );
	}

	public static function sincronizar_progreso( WP_REST_Request $request ) {
		global $wpdb;
		$nino_id = (int) $request->get_param( '_nino_id' );
		$cuerpo  = $request->get_json_params();
		if ( ! is_array( $cuerpo ) || ! isset( $cuerpo['progreso'] ) || ! is_array( $cuerpo['progreso'] ) ) {
			return new WP_REST_Response( array( 'error' => 'Falta el progreso.' ), 400 );
		}
		if ( strlen( (string) wp_json_encode( $cuerpo['progreso'] ) ) > self::MAXIMO_BYTES_ESTADO ) {
			return new WP_REST_Response( array( 'error' => 'El progreso es demasiado grande.' ), 413 );
		}
		$fusionado = self::fusionar_estados( self::leer_progreso( $nino_id ), $cuerpo['progreso'] );
		$wpdb->replace(
			NS_Esquema::nombre_tabla( 'el_taller_progreso' ),
			array(
				'nino_id'        => $nino_id,
				'progreso_json'  => wp_json_encode( $fusionado ),
				'actualizado_en' => current_time( 'mysql', true ),
			),
			array( '%d', '%s', '%s' )
		);
		return new WP_REST_Response( array( 'progreso' => $fusionado ), 200 );
	}

	public static function sensei_responder( WP_REST_Request $request ) {
		$nino_id  = (int) $request->get_param( '_nino_id' );
		$peticion = self::validar_peticion_sensei( $request->get_json_params() );
		if ( ! $peticion['ok'] ) {
			return new WP_REST_Response( array( 'error' => $peticion['error'] ), 400 );
		}
		$turnos_hoy = self::turnos_sensei_hoy( $nino_id );
		if ( $turnos_hoy >= self::SENSEI_MAXIMO_DIA ) {
			return new WP_REST_Response(
				array(
					'error'   => 'cuota',
					'mensaje' => 'eu' === $peticion['idioma'] ? 'Gaur asko marraztu duzu! Bihar jarraituko dugu.' : '¡Hoy has dibujado un montón! Seguimos mañana.',
				),
				429
			);
		}
		if ( ! defined( 'NS_ANTHROPIC_KEY' ) || '' === NS_ANTHROPIC_KEY ) {
			return new WP_REST_Response( array( 'error' => 'sensei_no_configurado' ), 503 );
		}
		$modelo = defined( 'NS_EL_TALLER_MODELO' ) && '' !== NS_EL_TALLER_MODELO ? (string) NS_EL_TALLER_MODELO : self::MODELO_DEFECTO;
		$cabeceras = array(
			'Content-Type'      => 'application/json',
			'x-api-key'         => NS_ANTHROPIC_KEY,
			'anthropic-version' => '2023-06-01',
		);
		if ( self::admite_fallback( $modelo ) ) {
			$cabeceras['anthropic-beta'] = 'server-side-fallback-2026-07-01';
		}
		$respuesta_http = wp_remote_post(
			self::ENDPOINT_ANTHROPIC,
			array(
				'headers' => $cabeceras,
				'body'    => wp_json_encode( self::cuerpo_peticion( $peticion, $modelo ) ),
				'timeout' => 60,
			)
		);
		self::sumar_turno_sensei( $nino_id );
		if ( is_wp_error( $respuesta_http ) ) {
			return new WP_REST_Response( array( 'error' => 'sin_conexion_con_el_sensei' ), 502 );
		}
		$codigo = (int) wp_remote_retrieve_response_code( $respuesta_http );
		if ( 200 !== $codigo ) {
			return new WP_REST_Response( array( 'error' => 'sensei_no_disponible', 'codigo' => $codigo ), 502 );
		}
		$texto = self::texto_de_respuesta( json_decode( wp_remote_retrieve_body( $respuesta_http ), true ) );
		if ( null === $texto ) {
			$texto = self::mensaje_sin_respuesta( $peticion['idioma'] );
		} else {
			$revision = NS_Filtro_Tutor::revisar_respuesta( $texto );
			$texto    = $revision['ok'] ? (string) $revision['limpio'] : self::mensaje_sin_respuesta( $peticion['idioma'] );
		}
		return new WP_REST_Response(
			array(
				'respuesta'       => $texto,
				'turnos_restantes' => max( 0, self::SENSEI_MAXIMO_DIA - $turnos_hoy - 1 ),
			),
			200
		);
	}

	// =================================================================
	// Persistencia
	// =================================================================

	private static function leer_progreso( int $nino_id ): array {
		global $wpdb;
		$tabla = NS_Esquema::nombre_tabla( 'el_taller_progreso' );
		$json  = $wpdb->get_var( $wpdb->prepare( "SELECT progreso_json FROM {$tabla} WHERE nino_id = %d", $nino_id ) );
		return self::normalizar_estado( is_string( $json ) ? json_decode( $json, true ) : null );
	}

	private static function turnos_sensei_hoy( int $nino_id ): int {
		global $wpdb;
		$tabla = NS_Esquema::nombre_tabla( 'el_taller_sensei' );
		return (int) $wpdb->get_var( $wpdb->prepare( "SELECT turnos FROM {$tabla} WHERE nino_id = %d AND fecha = %s", $nino_id, gmdate( 'Y-m-d' ) ) );
	}

	private static function sumar_turno_sensei( int $nino_id ): void {
		global $wpdb;
		$tabla = NS_Esquema::nombre_tabla( 'el_taller_sensei' );
		$wpdb->query(
			$wpdb->prepare(
				"INSERT INTO {$tabla} (nino_id, fecha, turnos) VALUES (%d, %s, 1) ON DUPLICATE KEY UPDATE turnos = turnos + 1",
				$nino_id,
				gmdate( 'Y-m-d' )
			)
		);
	}
}
