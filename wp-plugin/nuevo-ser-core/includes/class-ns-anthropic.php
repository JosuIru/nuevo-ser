<?php
/**
 * Cliente HTTP del API de Anthropic. Encapsulado aparte del orquestador
 * para que los tests puedan stubearlo y para que migrar a otro proveedor
 * solo requiera tocar este archivo.
 *
 * Doc 03 §9: modelo barato (haiku), explicaciones cortas, system prompt
 * que limita el alcance al MVP. La key se lee de `NS_ANTHROPIC_KEY`
 * (definida en wp-config.php) — fallar al no estar definida es
 * preferible a que el plugin envíe peticiones sin auth.
 *
 * @package NuevoSerCore
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class NS_Anthropic {

	private const ENDPOINT      = 'https://api.anthropic.com/v1/messages';
	private const VERSION_API   = '2023-06-01';
	private const MODELO_DEFECTO = 'claude-haiku-4-5';
	private const MAX_TOKENS    = 400;

	/**
	 * Pide una explicación al modelo. Devuelve el texto crudo (todavía
	 * sin pasar por el filtro de salida — eso lo hace el orquestador).
	 *
	 * @throws RuntimeException Si la API no devuelve 200 o el formato
	 *                          de la respuesta es inesperado.
	 */
	public static function pedir_explicacion(
		string $id_habilidad,
		string $pregunta,
		?string $contexto_fragmento = null
	): string {
		if ( ! defined( 'NS_ANTHROPIC_KEY' ) || '' === NS_ANTHROPIC_KEY ) {
			throw new RuntimeException( 'NS_ANTHROPIC_KEY no definida en wp-config.php.' );
		}

		$prompt_sistema = self::construir_prompt_sistema( $id_habilidad, $contexto_fragmento );

		$cuerpo = wp_json_encode(
			array(
				'model'      => self::MODELO_DEFECTO,
				'max_tokens' => self::MAX_TOKENS,
				'system'     => $prompt_sistema,
				'messages'   => array(
					array(
						'role'    => 'user',
						'content' => $pregunta,
					),
				),
			)
		);

		$respuesta = wp_remote_post(
			self::ENDPOINT,
			array(
				'headers' => array(
					'Content-Type'      => 'application/json',
					'x-api-key'         => NS_ANTHROPIC_KEY,
					'anthropic-version' => self::VERSION_API,
				),
				'body'    => $cuerpo,
				'timeout' => 20,
			)
		);

		if ( is_wp_error( $respuesta ) ) {
			throw new RuntimeException( 'Error de red: ' . $respuesta->get_error_message() );
		}
		$codigo = (int) wp_remote_retrieve_response_code( $respuesta );
		$body   = wp_remote_retrieve_body( $respuesta );
		if ( 200 !== $codigo ) {
			throw new RuntimeException( "Anthropic devolvió HTTP {$codigo}: {$body}" );
		}
		$datos = json_decode( $body, true );
		if ( ! is_array( $datos ) || empty( $datos['content'][0]['text'] ) ) {
			throw new RuntimeException( 'Respuesta de Anthropic con formato inesperado.' );
		}
		return (string) $datos['content'][0]['text'];
	}

	/**
	 * Pide un resumen semanal a partir de los agregados anonimizados que
	 * sube el cliente del niño. Devuelve el texto crudo (todavía sin
	 * pasar por el filtro ni por el parseador JSON — eso lo hace el
	 * orquestador, igual que con `pedir_explicacion`).
	 *
	 * Se le pide al modelo que responda en JSON estricto con dos campos
	 * (`summary_text`, `conversation_prompt`). La práctica habitual con
	 * Claude funciona bien si lo pides en el system prompt y lo
	 * refuerzas en el user.
	 *
	 * @param array<string,mixed> $agregados Shape libre — la app del
	 *      niño decide qué contadores mete. El modelo se adapta.
	 * @throws RuntimeException Si la API no devuelve 200 o el formato de
	 *      la respuesta es inesperado (la verificación del JSON interno
	 *      es del orquestador, aquí sólo el envoltorio de Anthropic).
	 */
	public static function pedir_resumen_semanal( array $agregados ): string {
		if ( ! defined( 'NS_ANTHROPIC_KEY' ) || '' === NS_ANTHROPIC_KEY ) {
			throw new RuntimeException( 'NS_ANTHROPIC_KEY no definida en wp-config.php.' );
		}

		$prompt_sistema = self::construir_prompt_resumen_semanal();
		$prompt_usuario = self::construir_user_resumen_semanal( $agregados );

		$cuerpo = wp_json_encode(
			array(
				'model'      => self::MODELO_DEFECTO,
				'max_tokens' => self::MAX_TOKENS,
				'system'     => $prompt_sistema,
				'messages'   => array(
					array(
						'role'    => 'user',
						'content' => $prompt_usuario,
					),
				),
			)
		);

		$respuesta = wp_remote_post(
			self::ENDPOINT,
			array(
				'headers' => array(
					'Content-Type'      => 'application/json',
					'x-api-key'         => NS_ANTHROPIC_KEY,
					'anthropic-version' => self::VERSION_API,
				),
				'body'    => $cuerpo,
				'timeout' => 20,
			)
		);

		if ( is_wp_error( $respuesta ) ) {
			throw new RuntimeException( 'Error de red: ' . $respuesta->get_error_message() );
		}
		$codigo = (int) wp_remote_retrieve_response_code( $respuesta );
		$body   = wp_remote_retrieve_body( $respuesta );
		if ( 200 !== $codigo ) {
			throw new RuntimeException( "Anthropic devolvió HTTP {$codigo}: {$body}" );
		}
		$datos = json_decode( $body, true );
		if ( ! is_array( $datos ) || empty( $datos['content'][0]['text'] ) ) {
			throw new RuntimeException( 'Respuesta de Anthropic con formato inesperado.' );
		}
		return (string) $datos['content'][0]['text'];
	}

	/**
	 * Prompt de sistema para el resumen semanal. Acota voz, idioma,
	 * longitud y formato. NO asume que el adulto sea padre/madre — la
	 * conversation_prompt se redacta de forma neutra para que sirva con
	 * cualquier persona acompañante.
	 */
	private static function construir_prompt_resumen_semanal(): string {
		$lineas   = array();
		$lineas[] = 'Eres un tutor cariñoso de un niño o niña de 9 a 14 años.';
		$lineas[] = 'Hablas en castellano, con frases cortas, voz cálida, segunda persona del singular ("tú").';
		$lineas[] = 'Te dan los agregados anónimos de su semana de juego en JSON.';
		$lineas[] = 'Devuelves SOLO un objeto JSON estricto con dos campos:';
		$lineas[] = '  "summary_text": un resumen de 3 o 4 frases que celebra logros y propone un foco para la próxima semana.';
		$lineas[] = '  "conversation_prompt": una pregunta breve (máx 1 frase) para que un adulto se la haga al niño y conversen.';
		$lineas[] = 'Sin emoticonos. Sin enlaces. Sin datos personales. Sin nombres propios inventados.';
		$lineas[] = 'No saludes ni firmes. Empieza directamente por el contenido.';
		$lineas[] = 'No menciones que los datos vienen en JSON ni hables del propio formato.';
		return implode( "\n", $lineas );
	}

	/**
	 * Mensaje del usuario para el resumen semanal. Aquí va el JSON con
	 * los agregados — el modelo lo lee y produce su respuesta.
	 *
	 * @param array<string,mixed> $agregados
	 */
	private static function construir_user_resumen_semanal( array $agregados ): string {
		$json = wp_json_encode(
			$agregados,
			JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT
		);
		if ( false === $json ) {
			$json = '{}';
		}
		return "Agregados de la semana:\n{$json}\n\nDevuelve solo el JSON con summary_text y conversation_prompt.";
	}

	/**
	 * Prompt de sistema. Acota voz, idioma, longitud y alcance. La
	 * habilidad se incluye literal — si el modelo la reconoce, mejor;
	 * si no, ya tiene el contexto del Fragmento (o ninguno) para
	 * orientarse. Se mantiene corto: cada token cuesta y el modelo no
	 * necesita un manual entero para responder a un niño.
	 */
	private static function construir_prompt_sistema(
		string $id_habilidad,
		?string $contexto_fragmento
	): string {
		$lineas   = array();
		$lineas[] = 'Eres un tutor de matemáticas para chicas y chicos de 9 a 14 años (de 4.º de Primaria a 2.º de ESO).';
		$lineas[] = 'Hablas en castellano, con frases cortas y voz cariñosa.';
		$lineas[] = 'Responde como mucho en 4 frases. Sin emoticonos.';
		$lineas[] = 'No des la solución directa: da la pista o el método para que el niño lo descubra.';
		$lineas[] = 'Solo matemáticas del juego (fracciones, decimales, proporciones y porcentajes, divisibilidad, enteros y potencias, álgebra y ecuaciones, funciones, geometría y medida, estadística y probabilidad), al nivel del curso de la habilidad.';
		$lineas[] = 'Si te preguntan cualquier otra cosa, responde: "De eso no sé. Pregúntame de matemáticas."';
		$lineas[] = '';
		$lineas[] = 'Habilidad actual: ' . $id_habilidad;
		if ( null !== $contexto_fragmento && '' !== trim( $contexto_fragmento ) ) {
			$lineas[] = 'Lo que ve en pantalla: ' . trim( $contexto_fragmento );
		}
		return implode( "\n", $lineas );
	}
}
