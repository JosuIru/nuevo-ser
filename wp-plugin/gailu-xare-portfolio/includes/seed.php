<?php
/**
 * Seed inicial del portfolio Gailu Xare con los 15 proyectos en 4
 * colecciones (Cuadernos de Campo, Nuevo Ser Kids, Larrea, Flavor)
 * + descargas + asignación a colección vía taxonomía gxare_coleccion.
 *
 * Idempotente vía meta `gxare_seed_id`.
 *
 * @package GailuXarePortfolio
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function gxare_seed_run(): void {
	// Términos de la taxonomía colección.
	$colecciones = array(
		'cuadernos-de-campo' => array(
			'nombre'      => 'Cuadernos de Campo',
			'descripcion' => 'Cuadernos de campo digitales para adulto aficionado. Geología, paleontología y naturaleza.',
		),
		'nuevo-ser-kids' => array(
			'nombre'      => 'Nuevo Ser Kids',
			'descripcion' => 'Juegos educativos para niños 9-14. Matemáticas, pensamiento histórico, naturaleza y lengua.',
		),
		'solera' => array(
			'nombre'      => 'Larrea',
			'descripcion' => 'Suite de gestión agrícola para Iberia. App nuclear + cinco verticales especializadas.',
		),
		'flavor' => array(
			'nombre'      => 'Flavor',
			'descripcion' => 'Plataforma WordPress de Gailu Labs para comunidades, medios federados y asistente IA.',
		),
	);
	foreach ( $colecciones as $slug => $datos ) {
		if ( ! term_exists( $slug, 'gxare_coleccion' ) ) {
			wp_insert_term(
				$datos['nombre'],
				'gxare_coleccion',
				array( 'slug' => $slug, 'description' => $datos['descripcion'] )
			);
		}
	}

	// Proyectos
	foreach ( gxare_seed_proyectos() as $entry ) {
		$post_id = gxare_seed_insertar( $entry );
		if ( $post_id > 0 && isset( $entry['coleccion'] ) ) {
			wp_set_object_terms( $post_id, $entry['coleccion'], 'gxare_coleccion' );
		}
	}

	// Descargas
	foreach ( gxare_seed_descargas() as $entry ) {
		gxare_seed_insertar( $entry );
	}
}

/**
 * Inserta un post si no existe. Si ya existe, lo actualiza con el
 * post_title y refresca los metas para reflejar el seed más reciente.
 * Devuelve el post_id o 0.
 */
function gxare_seed_insertar( array $entry ): int {
	$existente = get_posts(
		array(
			'post_type'      => $entry['post_type'],
			'meta_key'       => 'gxare_seed_id',
			'meta_value'     => $entry['seed_id'],
			'posts_per_page' => 1,
			'post_status'    => 'any',
			'no_found_rows'  => true,
		)
	);

	if ( ! empty( $existente ) ) {
		$post_id = (int) $existente[0]->ID;
		// Refrescar los metas (no toca title/content para no pisar
		// edición humana posterior; sí refresca metas para subir
		// contenido nuevo del seed).
		foreach ( ( $entry['meta'] ?? array() ) as $key => $value ) {
			update_post_meta( $post_id, $key, $value );
		}
		return $post_id;
	}

	$post_id = wp_insert_post(
		array(
			'post_type'    => $entry['post_type'],
			'post_status'  => 'publish',
			'post_title'   => $entry['title'],
			'post_name'    => $entry['slug'] ?? '',
			'post_content' => $entry['content'] ?? '',
			'post_excerpt' => $entry['excerpt'] ?? '',
			'menu_order'   => $entry['orden'] ?? 0,
		)
	);
	if ( ! $post_id || is_wp_error( $post_id ) ) {
		return 0;
	}
	update_post_meta( $post_id, 'gxare_seed_id', $entry['seed_id'] );
	foreach ( ( $entry['meta'] ?? array() ) as $key => $value ) {
		update_post_meta( $post_id, $key, $value );
	}
	return (int) $post_id;
}

function gxare_seed_proyectos(): array {
	return array(

		// ╔════════════════════════════════════════════════════════════
		// ║ CUADERNOS DE CAMPO
		// ╚════════════════════════════════════════════════════════════

		array(
			'seed_id'   => 'proy-cdc-fosiles',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'cuadernos-de-campo-fosiles',
			'orden'     => 10,
			'coleccion' => 'cuadernos-de-campo',
			'title'     => 'Fósiles',
			'excerpt'   => 'Cuaderno de campo digital de paleontología y mineralogía con cobertura cartográfica IGME nacional.',
			'content'   => 'Anota hallazgos georreferenciados con foto, edad geológica, formación y orientación de estrato. Asistente IGME contextual, certificado verificable SHA-256, módulo opcional de ciencia ciudadana con curaduría profesional.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Cuaderno de paleontología y mineralogía con asistente IGME.',
				'gxare_proyecto_audiencia'   => 'Adulto aficionado',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, IGME WMS, Ed25519, Anthropic Claude',
				'gxare_proyecto_marca'       => 'Cuadernos de Campo',
				'gxare_proyecto_url_web'     => 'https://github.com/JosuIru/cuadernos-de-campo',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/cuadernos-de-campo',
				'gxare_proyecto_color'       => '#5E7D3A',
				'gxare_proyecto_destacado'   => '1',
				'gxare_proyecto_landing'     => 'cuadernos-de-campo',
				'gxare_proyecto_que_hace_largo' => 'Cuaderno de campo digital para aficionados a la paleontología y la mineralogía. Permite anotar hallazgos georreferenciados con foto, edad geológica, formación, orientación de la capa (strike/dip) y notas, registrar tracks GPS de las rutas, consultar yacimientos curados con cobertura cartográfica IGME nacional y una guía de identificación de fósiles y minerales. Incluye pantalla de estadísticas, línea de tiempo cronoestratigráfica y quiz autocomprobatorio. Construido en Flutter con sqflite, flutter_map y geolocator. Funciona offline en el campo, con datos almacenados localmente y catálogos curados listos para auditoría científica.',
				'gxare_proyecto_para_quien'  => 'Adulto aficionado a la paleontología o la mineralogía que sale al campo: senderistas con interés geológico, geólogos amateurs, profesores que coleccionan piezas con sus alumnos. Soluciona el problema de tener fotos sueltas en el carrete sin la información que vuelve útil una pieza (dónde, cuándo, en qué estrato, junto a qué). Está pensada para quien quiere construirse una colección documentada propia.',
				'gxare_proyecto_virtudes'    => "Cobertura cartográfica IGME nacional integrada\nCaptura el strike/dip del estrato, no sólo la foto\nCatálogo de yacimientos curados por el autor\nFunciona offline y respeta la privacidad de las coordenadas precisas\nCatálogos compartibles entre cuadernos cuando se auditen",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'APK release estable v1.0.14+15 con unas 9.300 líneas de código. Integrada en el monorepo Nuevo Ser para reutilizar la plataforma compartida (storage cifrado, perfiles, sync, mapas offline). Falta extraer los catálogos curados al directorio compartido del monorepo para auditoría del comité científico y completar el sync al backend respetando la privacidad estructural.',
				'gxare_proyecto_faq'         => "¿Esta app sirve para identificar fósiles automáticamente con la cámara? :: No. Es un cuaderno de campo, no un identificador. Trae una guía de referencia, pero la identificación la hace el aficionado con su criterio.\n¿Mis hallazgos viajan a algún servidor? :: Las coordenadas precisas se quedan en local. Cuando se active la sincronización, al backend irán metadatos y la zona NUTS-3, nunca el punto exacto del hallazgo.\n¿Está pensada para niños? :: No. Es app de adulto aficionado, con vocabulario técnico (cronoestratigrafía, strike/dip, formaciones). Para niños la línea Kids tiene otros juegos.\n¿Cubre minerales además de fósiles? :: Sí. Incluye catálogo de minerales y la pantalla de anotar admite ambos tipos con campos específicos.",
			),
		),

		array(
			'seed_id'   => 'proy-cdc-naturaleza',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'cuadernos-de-campo-naturaleza',
			'orden'     => 20,
			'coleccion' => 'cuadernos-de-campo',
			'title'     => 'Naturaleza',
			'excerpt'   => 'Cuaderno de avistamientos de fauna, flora e insectos con identificación asistida por IA y datos GBIF.',
			'content'   => 'Misma arquitectura que Fósiles, dominio más estrecho. Identificación con Claude o Pl@ntNet (con tu propia API key). Datos GBIF de la zona. Quiz didáctico, mapas offline, certificado verificable.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Cuaderno de fauna, flora e insectos con IA opcional.',
				'gxare_proyecto_audiencia'   => 'Adulto aficionado',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, GBIF, Pl@ntNet, Anthropic Claude',
				'gxare_proyecto_marca'       => 'Cuadernos de Campo',
				'gxare_proyecto_url_web'     => 'https://github.com/JosuIru/cuadernos-de-campo',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/cuadernos-de-campo',
				'gxare_proyecto_color'       => '#3A7D5A',
				'gxare_proyecto_destacado'   => '1',
				'gxare_proyecto_landing'     => 'cuadernos-de-campo',
				'gxare_proyecto_que_hace_largo' => 'Cuaderno de campo digital para anotar observaciones de animales, insectos y plantas con foto, lugar y notas. Comparte arquitectura técnica con la app de fósiles pero su catálogo es vivo en vez de mineral. Permite registrar hallazgos georreferenciados, marcar tracks GPS de las rutas, consultar una guía de identificación curada, ver estadísticas personales de avistamientos y autocomprobarse con un quiz. Construida sobre Flutter, sqflite, flutter_map, geolocator y permission_handler. Funciona offline en el campo y soporta también escritorio Linux.',
				'gxare_proyecto_para_quien'  => 'Adulto aficionado a la naturaleza: ornitólogos amateurs, botánicos de fin de semana, entomólogos por afición, senderistas con interés naturalista. Soluciona el mismo problema que su hermana de fósiles: convertir las fotos sueltas del paseo en un cuaderno trazable con dónde, cuándo y qué se vio, sin depender de redes sociales ni de plataformas que capturen los datos.',
				'gxare_proyecto_virtudes'    => "Catálogo de identificación curado por el autor\nSoporta Android y Linux desktop\nFunciona offline y respeta la privacidad de las coordenadas\nComparte stack y patrón con la app hermana de fósiles\nTracks GPS y estadísticas integradas",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Producto funcional con unas 6.500 líneas de código, traído al monorepo Nuevo Ser desde su repositorio anterior para reutilizar la plataforma compartida. Falta mover el catálogo curado al directorio compartido del monorepo cuando el comité científico lo audite, y completar el sync al backend con privacidad estructural (coordenadas precisas en local, sólo metadatos y NUTS-3 al servidor).',
				'gxare_proyecto_faq'         => "¿Reemplaza a iNaturalist o eBird? :: No. Es cuaderno personal sin red social ni validación comunitaria. Si se decide en el futuro, podrá exportar hacia esas plataformas con consentimiento explícito.\n¿Identifica especies con la cámara? :: No. Trae guía de referencia para que el adulto identifique con su criterio. La aplicación no diagnostica.\n¿Mis observaciones se comparten con alguien? :: No por defecto. Todo queda local. Si se activa el sync, al backend van metadatos y zona NUTS-3, las coordenadas precisas no salen del dispositivo.\n¿Vale para llevar al monte sin cobertura? :: Sí. Es offline-first. La sincronización es opt-in y se hace cuando hay wifi.",
			),
		),

		// ╔════════════════════════════════════════════════════════════
		// ║ NUEVO SER KIDS (4 juegos del monorepo)
		// ╚════════════════════════════════════════════════════════════

		array(
			'seed_id'   => 'proy-uno-roto',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'uno-roto',
			'orden'     => 30,
			'coleccion' => 'nuevo-ser-kids',
			'title'     => 'Uno Roto',
			'excerpt'   => 'Juego de matemáticas 9-12 con narrativa, motor de maestría y tutor IA.',
			'content'   => 'Mecánica narrativa de "uno roto en pedazos": el niño recompone fracciones, resuelve problemas de proporcionalidad y construye habilidad matemática real (no rote learning).',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Matemáticas 9-12 con narrativa y motor de maestría.',
				'gxare_proyecto_audiencia'   => 'Niños 9-14',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, Material 3, sqflite, motor maestría, Anthropic',
				'gxare_proyecto_marca'       => 'Nuevo Ser Kids',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#8A4FBE',
				'gxare_proyecto_destacado'   => '1',
				'gxare_proyecto_que_hace_largo' => 'Juego de matemáticas narrativo para tableta y móvil donde las fracciones, decimales, proporciones, geometría y estadística son el gameplay, no su excusa. El niño caza Fragmentos por seis distritos visualmente diferenciados (Tejados, Canales, Mercado, Industria, Puerto, Afueras), resuelve puzzles con distractores curados a errores reales de niños y avanza por cuatro arcos narrativos con más de 60 escenas, combates jugables contra Fragmentos nombrados y rangos narrativos. Incluye motor de maestría adaptativo de cinco niveles, periódico semanal in-game, modo entrenamiento por dominio, tres idiomas y Tutor IA opcional con doble filtro de seguridad.',
				'gxare_proyecto_para_quien'  => 'Niñas y niños de 9 a 14 años que estudian matemáticas de Primaria 3-6 y ESO 1-2. Pensado para casa más que para clase. Soluciona el problema de los ejercicios de fracciones sin sentido: aquí las matemáticas viven dentro de una ciudad rota que se restaura cuando el jugador comprende. También sirve a docentes que quieren un material respetuoso, sin gamificación tóxica y sin publicidad.',
				'gxare_proyecto_virtudes'    => "76 habilidades en 11 dominios con puzzles dedicados y distractores curados\nMotor adaptativo de maestría con cinco niveles y decaimiento por olvido\nCuatro arcos narrativos completos con combates jugables y rangos narrativos\nTutor IA limitado por filtros, cuota y caché (sin tracking ni publicidad)\nTres idiomas peninsulares cooficiales desde el primer arranque",
				'gxare_proyecto_pedagogia'   => 'Defiende que la mesura es el sabor: nada de euforia, nada de sonidos de castigo, nada de combos de XP. Las matemáticas son el mundo, no un peaje. El niño avanza porque comprende, no porque acumula puntos. Cada puzzle codifica un error sistemático de aprendizaje (más cifras decimales no significa mayor valor, olvidar el /2 al pasar de rectángulos a triángulos, la concatenación 2h30 leída como 230) y los distractores están elegidos contra esos errores reales. El motor de maestría no se ve: el niño percibe rangos narrativos (Aprendiz I, II, III, Iniciado) en lugar de barras de progreso. Privacidad por diseño, open source de verdad y un tutor que nunca da la solución directa pero acompaña con metáforas.',
				'gxare_proyecto_estado_largo'=> 'MVP prácticamente completo (~95%) en fase 8-9 del roadmap. Catálogo de habilidades cerrado, narrativa de los cuatro arcos jugable end-to-end, combates jugables y tutor IA probado en producción con Anthropic real. Falta sustituir los placeholders programáticos por arte y música finales, completar el segundo lote de assets sonoros del paquete descargable y validar con tests reales con niños la calibración del tutor.',
				'gxare_proyecto_faq'         => "¿Necesita conexión a internet para jugar? :: No. Funciona offline. La sincronización del progreso al backend y el tutor IA son opcionales y necesitan conexión sólo en ese momento.\n¿Tiene anuncios, compras integradas o tracking? :: Ninguna de las tres cosas. Privacidad por diseño es uno de los principios innegociables del juego.\n¿Sirve para una clase entera o sólo para casa? :: Hoy está pensado para uso individual. Soporta multi-perfil en el mismo dispositivo y los maestros pueden recomendarlo, pero no hay panel de aula con varios alumnos todavía.\n¿Qué pasa cuando el niño se equivoca varias veces seguidas? :: Tras dos fallos aparece una pista visual sobre el candidato correcto. Tras cinco fallos se le ofrece una explicación pedagógica del tipo de puzzle, no se le penaliza. La voz nunca regaña.",
			),
		),

		array(
			'seed_id'   => 'proy-las-versiones',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'las-versiones',
			'orden'     => 31,
			'coleccion' => 'nuevo-ser-kids',
			'title'     => 'Las Versiones',
			'excerpt'   => 'Pensamiento histórico crítico para 10-14: cada hecho admite varias narraciones.',
			'content'   => 'La protagonista Maren, 13 años, ingresa al Archivo de Iruña como Aspirante a Cronista y aprende el oficio investigando Brechas a lo largo de cuatro arcos narrativos.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Pensamiento histórico 10-14: cada hecho, varias narraciones.',
				'gxare_proyecto_audiencia'   => 'Niños 10-14',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, motor maestría P1-P4, Companion',
				'gxare_proyecto_marca'       => 'Nuevo Ser Kids',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#C4602E',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Juego de pensamiento histórico crítico para 10-14 años. La protagonista Maren, 13 años, ingresa al Archivo de Iruña como Aspirante a Cronista y aprende el oficio investigando Brechas: formular preguntas honestas, evaluar fuentes contra criterios explícitos (¿quién?, ¿cuándo?, ¿para qué público?, ¿qué se omite?), reconstruir el pasado anclando cada afirmación a evidencia con tres niveles visibles (Sólido / Probable / Disputado) y defender la versión ante un Concilio de mentora y rivales. Cubre diez capas históricas de Nafarroa, desde la prehistoria hasta el umbral de la conquista de 1512.',
				'gxare_proyecto_para_quien'  => 'Niños de 10 a 14 años que estudian Historia y Geografía en LOMLOE primaria ciclo 3 y ESO 1-2. También docentes y familias que quieren un juego que no esconda los matices de la historia: el silencio en las fuentes como dato, la propaganda cruzada en una epopeya, el desplazamiento de una leyenda. Soluciona la trampa del libro de texto que premia saber fechas: aquí lo que se premia es haber juzgado bien con lo disponible.',
				'gxare_proyecto_virtudes'    => "65 habilidades en 7 dominios incluida la formulación de preguntas (novedad v0.2)\nCuatro arcos narrativos completos con 13 Brechas jugables y cuatro Mosaicos integradores\nCódigo de confianza Sólido/Probable/Disputado como núcleo mecánico, no decoración\nValidación histórica por comité asesor (las sustituciones diegéticas están registradas)\nPrivacidad estructural, sin tracking, AGPL-3.0 + CC-BY-SA 4.0",
				'gxare_proyecto_pedagogia'   => 'Defiende que la historia se enseña honestamente cuando se enseña a convivir con la incertidumbre sin caer en relativismo. La calibración epistémica (declarar el nivel de confianza correcto sobre cada afirmación) es el corazón pedagógico, medido con el Brier invertido del perfil P4. El juego enseña que una inscripción romana es propaganda, que el silencio vascón en las fuentes carolingias es el dato (no la ausencia de dato), que la Chanson de Roland cuenta más sobre el siglo XII cruzado que sobre el episodio del 778, y que se pueden hacer Brechas que no acaban con quien las hace. Las cinco fases (Formular preguntas, Recolección, Evaluación, Reconstrucción, Concilio) son el oficio del historiador encarnado en mecánica.',
				'gxare_proyecto_estado_largo'=> 'MVP funcionalmente jugable end-to-end (Fase 10). Cuatro arcos completos con 13 Brechas jugables, cuatro Mosaicos integradores y pantalla de graduación. 596 tests verde, analyzer limpio, APK debug y release compilables. Pendiente sólo la validación masiva del comité asesor histórico sobre los puntos sensibles registrados en BLOQUEOS-PENDIENTES.',
				'gxare_proyecto_faq'         => "¿No es muy duro para 10-14 años un juego sobre incertidumbre histórica? :: La asunción del juego es que el niño es inteligente, atento y digno. Los matices se sostienen porque están encarnados en personajes y mecánica, no en discursos.\n¿Cómo se evita el riesgo de meter contenido histórico falso? :: Hay un comité asesor histórico que valida cada afirmación factual. Lo no validado está sustituido por formulación diegética genérica y registrado en un tracker. Nada toca producción sin pasar por el filtro.\n¿Premia tener razón o haber juzgado bien? :: Lo segundo. El motor del juego (calibración Brier) penaliza tanto declarar Sólido lo que es Disputado como declarar Disputado lo que es Sólido. El oficio honesto vale más que el acierto.\n¿Funciona en clase o sólo en casa? :: Funciona en los dos contextos. Tiene soporte multi-perfil en el mismo dispositivo y cableado opt-in al companion para que un adulto acompañante vea el Mosaico entregado.",
			),
		),

		array(
			'seed_id'   => 'proy-el-cuaderno',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'el-cuaderno',
			'orden'     => 32,
			'coleccion' => 'nuevo-ser-kids',
			'title'     => 'El Cuaderno',
			'excerpt'   => 'Cuaderno de campo digital infantil (9-13) para observar el medio sin gamificación intrusiva.',
			'content'   => 'Sit spot real. Tutor IA con barreras. Privacidad estructural. Sin XP ni rachas ni notificaciones push.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Cuaderno de campo de naturaleza para niños 9-13, sin gamificación intrusiva.',
				'gxare_proyecto_audiencia'   => 'Niños 9-13',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, Isar local cifrado, tutor cuaderno IA, Companion',
				'gxare_proyecto_marca'       => 'Nuevo Ser Kids',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#3A8B6A',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Herramienta de campo digital con alma pedagógica. El niño tiene un sit spot real (un banco del parque, una piedra junto al río, un árbol del patio) al que vuelve, anota observaciones separando estructuralmente qué viste de qué crees que es, declara el nivel de confianza (consenso / hipótesis activa / no segura), investiga Misterios contextualizados a su lugar y su estación, formula sus propias preguntas paralelas al catálogo del adulto y construye su cuaderno personal con foto, dibujo a tinta gruesa y texto. Incluye Tutor IA con barreras (ZDR, sin memoria entre conversaciones, lista negra, cuota 30 turnos/día), mapa offline opt-in, exportación a PDF, vista del cuidador con resumen semanal y vista del aula (k≥5) para docentes.',
				'gxare_proyecto_para_quien'  => 'Niños de 9 a 13 años que estudian Conocimiento del Medio Natural (LOMLOE primaria ciclos 2 y 3). Pensado como pre-Biología y pre-Ecología. Soluciona el problema de la naturaleza enseñada en libros sin contacto: aquí el lugar es el lugar real del niño, no un valle ficticio. También sirve a familias y maestras que buscan un material respetuoso con la atención del niño y con su intimidad.',
				'gxare_proyecto_virtudes'    => "Sit spot real con regreso regular como corazón pedagógico\nPrivacidad estructural: texto, fotos, dibujos y coordenadas viven en Isar cifrado local\nTutor IA con doble filtro, ZDR y cuota diaria\nSin XP, sin rachas, sin notificaciones push, sin \"logros\"\nMultiidioma desde el primer arranque (castellano completo, euskera y catalán como fallback)",
				'gxare_proyecto_pedagogia'   => 'Defiende que la palabra naturaleza presupone separación entre quien observa y lo observado, y que el oficio se enseña amplificando la atención del niño al lugar real donde está, no inventando un valle ficticio. Los principios jerárquicos son innegociables: el cuaderno es del niño, recordar antes que aprender, nunca humillar, maestría observable nunca declarada, cierre amable y ritmo respetuoso. El mapa de 59 habilidades en 9 dominios (Presencia, Observación, Registro, Identificación, Relaciones, Ciclos, Hábitats, Hipótesis, Tejido roto y tejido vivo) se mide con un perfil compuesto P5 que no se ve. La voz pasa el test "podría salir esto de alguien que llevara cuarenta años caminando este monte".',
				'gxare_proyecto_estado_largo'=> 'Sprints S0 a S8 y bloque A (A1-A10) cerrados; bloque B parcialmente cerrado como fallback de experto. 518 tests verde, APK debug compila e instala en Android. Sprint S9 (piloto con 12-15 familias) bloqueado por decisiones humanas pendientes: validación científica del catálogo, asesoría psicológica para el caso 1 del doc 15, política LOPDGDD para menores, ilustradora botánica, auth de profesor/cuidador.',
				'gxare_proyecto_faq'         => "¿Por qué no se llama un juego de naturaleza si va de eso? :: Porque la palabra naturaleza presupone que estamos separados de ella. El cuaderno amplifica la atención del niño hacia el lugar real donde está, sea un parque urbano, un patio o un monte.\n¿Qué información sale del dispositivo? :: Texto, fotos, dibujos y coordenadas precisas viven cifrados en local. Al servidor sólo van metadatos (hash del texto, zona NUTS-3 y agregados semanales firmados), nunca contenido bruto del niño.\n¿Sirve sin sit spot real, sólo desde la cama? :: Funciona, pero pierde el corazón. La pedagogía es habitar un lugar y volver. Sin regreso regular, el juego se reduce a un cuaderno de notas.\n¿Cómo evita la gamificación tóxica que tienen otras apps infantiles? :: No tiene XP, ni niveles visibles, ni rachas, ni notificaciones push, ni recompensas variables, ni ranking, ni \"logros\". El progreso visible es el cuaderno mismo, que crece a medida que el niño lo construye.",
			),
		),

		array(
			'seed_id'   => 'proy-el-descifrador',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'el-descifrador',
			'orden'     => 33,
			'coleccion' => 'nuevo-ser-kids',
			'title'     => 'El Descifrador',
			'excerpt'   => 'Lengua + L2 + pensamiento crítico para 11-14: oficio civil de descifrar documentos en un puerto atlántico ficticio.',
			'content'   => 'Verbo motor: descifrar. Mundo: La Estafeta. Materia: lengua + idiomas L2 (lectura asistida en eu/ca/gl) + pensamiento crítico + redacción.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Lengua + L2 + crítica para 11-14, mundo de oficinas de un puerto atlántico.',
				'gxare_proyecto_audiencia'   => 'Niños 11-14',
				'gxare_proyecto_estado'      => 'esqueleto',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, Melos, multilingüe es/eu/ca/gl',
				'gxare_proyecto_marca'       => 'Nuevo Ser Kids',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#2D6A92',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Juego de oficio civil donde el niño es aprendiz en la oficina de descifradores de La Estafeta, un puerto atlántico ficticio peninsular. Llegan papeles del mundo (cartas, panfletos, recetas, manifiestos, etiquetas comerciales) en distintas lenguas y el aprendiz los identifica, los entiende lo suficiente con ayuda del contexto, decide qué hacer con ellos y construye su cuaderno propio. La mecánica nuclear son seis operaciones (identificar, marcar, anotar, proponer, verificar, decidir) y el cuaderno persistente es el progreso visible, sin XP ni estrellas. Las cuatro lenguas peninsulares cooficiales son contenido nuclear desde el día uno; portugués, francés, italiano, inglés, alemán y latín fragmentario son L2 de lectura asistida.',
				'gxare_proyecto_para_quien'  => 'Niños de 11 a 14 años que cursan ESO 1-2. Materia principal: lengua castellana, idioma extranjero y pensamiento crítico. Soluciona dos problemas: el enfoque atomizado de las apps tipo Duolingo (que prometen enseñar una lengua entera y no enseñan a leer en contexto) y el desconocimiento mutuo entre las cuatro lenguas peninsulares cooficiales, ausentes simultáneamente en casi todos los materiales escolares.',
				'gxare_proyecto_virtudes'    => "Las cuatro cooficiales peninsulares como contenido nuclear desde el primer arranque\nAnti-Duolingo estructural: enseña a leer en lengua que no dominas con contexto, no la lengua entera\nVerbo motor \"descifrar\" como oficio civil concreto, no abstracción escolar\nVoz del maestro sobria (Antón coral con Aitziber), sin \"¡muy bien!\" ni emoticonos\nCuaderno del jugador como progreso visible, sin XP ni rachas",
				'gxare_proyecto_pedagogia'   => 'Defiende que la habilidad transferible importa más que el dominio enciclopédico de una lengua: lo útil no es saber cien palabras de italiano, sino saber leer una receta italiana sabiendo italiano cero y reconociendo que farina es harina, burro es mantequilla y caldo es caliente (no caldo). Las 36 habilidades atómicas en 4 dominios (más 5 transversales) están medidas con el perfil P6 del motor adaptativo. La pedagogía del documento prescribe reglas innegociables para cada pieza del corpus: ninguna se incluye sin asesoría lingüística profesional, ninguna pone palabras en boca de persona real histórica, ninguna folkloriza ninguna cultura. El silencio es contenido (no hay celebraciones del rendimiento) y el cuaderno propio es el progreso visible.',
				'gxare_proyecto_estado_largo'=> 'Esqueleto técnico v0.1.0 (mayo 2026) con estructura Flutter+Melos, dependencias a la plataforma compartida, cuatro lenguas cooficiales cableadas con flutter_localizations y test de humo verde. Doce decisiones de entrada a Fase 1 aprobadas el 2026-05-13. Sin mecánica, sin contenido, sin assets, sin motor, sin corpus. Pendiente: asesoría lingüística para las cuatro cooficiales primero, corpus seminal mixto, encargo de ilustradora y compositor.',
				'gxare_proyecto_faq'         => "¿Va a enseñar a mi hijo italiano o gallego? :: No promete eso. Promete enseñarle a leer una receta en italiano o una carta en gallego con ayuda del contexto, aunque no domine ninguno de los dos. Es habilidad transferible, no curso de idiomas.\n¿Por qué incluye euskera y gallego desde el principio si en mi región no se hablan? :: Porque las cuatro cooficiales son contenido nuclear del juego. Un niño peninsular del siglo XXI puede toparse con papeles en cualquiera de las cuatro y la escuela rara vez se las presenta juntas.\n¿Cómo se trata el árabe si no se descifra? :: Se identifica como árabe (reconocer el alfabeto, distinguirlo del hebreo, del persa o del urdu) pero no se finge descifrarlo. El juego es honesto con el alcance del aprendiz.\n¿Cuándo estará jugable? :: Hoy sólo hay esqueleto técnico. La Fase 1 (producción real del corpus y la mecánica) arranca ahora; el piloto está previsto en Fase 4 con 10-20 niños en 2-3 centros.",
			),
		),

		// ╔════════════════════════════════════════════════════════════
		// ║ SOLERA (agro + 5 verticales)
		// ╚════════════════════════════════════════════════════════════

		// El proyecto paraguas — landing del ecosistema completo
		// (las 6 verticales agrarias presentadas como una sola
		// familia). Renderiza con template-parts/landing-solera.php,
		// no con la genérica. Va primero en orden dentro de la
		// colección porque es la puerta de entrada al resto.
		array(
			'seed_id'   => 'proy-solera-ecosistema',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-ecosistema',
			'orden'     => 39,
			'coleccion' => 'solera',
			'title'     => 'Larrea — el ecosistema',
			'excerpt'   => 'Ecosistema de cuadernos de campo para oficios de la tierra: agro, viticultura, apícola, arbolado urbano, quesera y aceitera.',
			'content'   => 'Una raíz común (nuevo_ser_core) y seis cuadernos especializados por oficio. Offline de raíz, libros oficiales en PDF y catálogos curados.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Seis cuadernos · una misma raíz.',
				'gxare_proyecto_audiencia'   => 'Profesionales de oficios de la tierra (agricultores, viticultores, apicultores, técnicos municipales, queseros, almazareros)',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'ecosistema',
				'gxare_proyecto_tech'        => 'Flutter, Melos monorepo, sqflite, Claude Vision BYO key, Material 3',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#5E7D3A',
				'gxare_proyecto_destacado'   => '1',
				// Render con la plantilla específica del ecosistema.
				'gxare_proyecto_landing'     => 'solera',
				'gxare_proyecto_que_hace_largo' => 'Larrea es un ecosistema de aplicaciones móviles para profesionales que trabajan con plantas, animales y patrimonio vivo. Una finca, un viñedo, un colmenar, un arbolado municipal, una quesería o una almazara — cada oficio en su cuaderno, con sus catálogos curados, su libro oficial en PDF y su libro económico REAGP. Las seis verticales comparten núcleo técnico (nuevo_ser_core) y vocabulario, pero cada una verticaliza para los tiempos, normativa y categorías de su materia.',
				'gxare_proyecto_para_quien'  => 'Profesionales y semi-profesionales de oficios de la tierra que llevan o quieren llevar un cuaderno de campo serio: viticultor o enólogo de bodega 5-30 ha, apicultor con 20-200 colmenas, técnico de arbolado municipal, quesería artesanal, maestro almazarero. También aficionado avanzado con explotación mixta. Las apps no explican el oficio — lo acompañan.',
				'gxare_proyecto_virtudes'    => "Offline de raíz: el cuaderno vive en sqflite local, la nube sólo entra cuando tú lo decides\nLibros oficiales (PAC, REGA, AICA, APPCC, partes municipales) en PDF listos para inspección\nIA visual con Claude — BYO key, sin captura de datos en nuestros servidores\nCatálogos curados con fuente pública verificable, editables por tu asesor en CSV\nLibro económico REAGP por vertical con compensación correcta (12% aceituna, 4% aceite, 10% envasado…)\nUn solo monorepo con Melos: si tienes olivar y colmenar, las dos apps comparten plataforma técnica",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Cuatro verticales estables (agro, viticultura, apícola, aceitera) con APK release publicada. Quesera en beta interno (catálogos provisionales). Arbolado urbano estable con asesor fiscal trabajando F1U-10. Los PDFs llevan sello PROVISIONAL hasta firma del asesor humano de referencia de cada vertical (técnico OCA, veterinario apícola, auditor AICA, inspector autonómico).',
				'gxare_proyecto_faq'         => "¿Las apps son gratis u open source? :: Código bajo AGPL-3.0, contenidos bajo CC-BY-SA 4.0. El plan comercial cubre soporte, hospedaje futuro de sync y validación profesional continua.\n¿Qué datos suben a la nube? :: Ninguno por defecto. Las apps son offline de raíz; coordenadas y fotos viven en sqflite local. Sólo sale del móvil lo que tú decides compartir.\n¿Hay versión iOS o web? :: Por ahora sólo Android. Compilan a iOS técnicamente pero el roadmap prioriza estabilidad sobre cobertura de plataforma.\n¿Los libros oficiales son válidos para inspección? :: Estructura conforme a normativa pero con sello PROVISIONAL hasta firma del asesor humano de referencia. La auditoría final es responsabilidad del titular.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-agro',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera',
			'orden'     => 40,
			'coleccion' => 'solera',
			'title'     => 'Larrea',
			'excerpt'   => 'Gestor de fincas agrícolas para Iberia. Modelo "planta con identidad persistente".',
			'content'   => 'Modo trufas único en mercado, cuaderno MAPA integrado, cobertura PAC.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Gestor de fincas para agricultura ibérica.',
				'gxare_proyecto_audiencia'   => 'Agricultor profesional',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, MAPA, PAC, GPS, Anthropic Vision',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#8B6F4E',
				'gxare_proyecto_destacado'   => '1',
				'gxare_proyecto_que_hace_largo' => 'Larrea es la app nuclear de gestión de fincas agrícolas para Iberia, pensada como gestor de planta con identidad persistente: cada árbol, cepa o pie individual conserva su historial completo de cosechas, observaciones, incidencias y tratamientos a lo largo de los años. Es multi-finca, soporta puntos sueltos sin finca obligatoria y se verticaliza por cultivo activando catálogos curados. Incluye Cuaderno de Explotación digital conforme al RD 1311/2012, IA por foto con Claude Vision, libro económico anual con extracto fiscal REAGP y modelo 347, y backup local zip. Funciona offline real y sólo sube a la nube en momentos de sync.',
				'gxare_proyecto_para_quien'  => 'Agricultor profesional y semi-profesional ibérico con explotación mixta (frutales, olivar, pistacho, truficultura, viñedo, dehesa), que hoy lleva el cuaderno PAC en papel o Excel y necesita pasar la inspección sin volverse loco. Especialmente útil para titulares con cultivos diversificados que no quieren cambiar de app por cada parcela. El modo truficultura no existe en ninguna competencia del mercado actual.',
				'gxare_proyecto_virtudes'    => "Modo trufas único en el mercado (Tuber spp y hospederos cruzados)\nCuaderno de Explotación PDF conforme al RD 1311/2012 listo para inspección\nIA Claude Vision contrastada contra catálogo curado de plagas\nPunto suelto soportado de raíz: planta sin finca obligatoria\nOffline real con backup zip y migraciones BD no destructivas",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Fases F0 a F3.5 cerradas con funcionalidad completa hasta libro económico provisional. F4 (backend nube multi-operador) y F5 (voz manos libres + marketplace fitosanitarios) están bloqueadas por decisiones humanas de stack, auth y monetización. El cuaderno MAPA y el extracto fiscal llevan banner provisional hasta firma de asesor fiscal humano y validación por inspector real.',
				'gxare_proyecto_faq'         => "¿Funciona sin cobertura en el monte? :: Sí, la app es offline real con sqflite local. La nube sólo entra cuando hay sync y eso queda para F4.\n¿Genera el cuaderno PAC oficial? :: Genera un PDF conforme al RD 1311/2012 con titular, asesor, parcelas SIGPAC y tratamientos. El XML SIEX/CUE oficial está diferido hasta que el MAPA estabilice la spec XSD por campaña.\n¿Qué hace la IA por foto? :: Identifica plagas y enfermedades con Claude Haiku Vision, contrasta contra el catálogo curado por nombre científico y pre-rellena la incidencia con manejo cultural. No recomienda productos comerciales en v1.\n¿Soporta multi-operador con peones y asesor? :: Todavía no. En v1 es single-user local. El multi-operador con roles llega en F4 junto con el backend nube.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-viticultura',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-viticultura',
			'orden'     => 41,
			'coleccion' => 'solera',
			'title'     => 'Larrea Viticultura',
			'excerpt'   => 'Cuaderno PAC móvil + IA vid para bodegas pequeñas y medianas.',
			'content'   => 'La cepa como entidad central. IA vid específica (mildiu, oídio, botritis, Xylella, Flavescencia). Libro PAC + económico separando uva (REAGP) de vino (IVA general).',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Cuaderno PAC + IA vid para bodegas 5-30 ha.',
				'gxare_proyecto_audiencia'   => 'Bodegas pequeñas/medianas',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, PAC RD 1311/2012, RD 285/2021',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#7B2D26',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Larrea Viticultura es el primer fork especializado de la suite, dirigido a bodegas pequeñas y medianas. La cepa es la entidad central con variedad, portainjerto, marco y etiqueta de fila; el viticultor registra observaciones, tratamientos con campos PAC obligatorios y cosechas con trazabilidad por lote. Incluye calendario fenológico BBCH por variedad y zona, IA Claude Vision vid-específica (mildiu, oídio, botritis, polilla del racimo, Xylella, Flavescencia dorada con banner rojo de declaración obligatoria), libro PAC PDF firmable, y libro económico anual diferenciando uva (REAGP) de vino transformado (IVA general).',
				'gxare_proyecto_para_quien'  => 'Viticultor y enólogo de bodega de 5 a 30 ha que combina trabajo de campo con compliance creciente: PAC anual, trazabilidad DOP/IGP, modelo 347. Compite con Vintia y AgroOptima, que son ERP pesados de oficina; Larrea Viticultura va en el móvil al campo. Ticket objetivo 15-40 euros mensuales por finca.',
				'gxare_proyecto_virtudes'    => "Cuaderno PAC móvil generado desde el campo, no desde la oficina\nCatálogo curado con fuente pública revisada (MAPA, IMIDA, ENTAV-INRA, registro fitosanitario 2026)\nIA vid-específica con 14 patologías canónicas y matching fuzzy en 3 estados\nCalendario BBCH 72 estados por zona productiva y variedad\nLibro económico separa uva REAGP de vino general 21% para no liar al asesor fiscal",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'F0 a F1-12 cerradas (12 fases). Catálogos pre-curados con fuente pública y flag de revisión completado. Pendiente auditoría humana del enólogo + agrónomo asesor con número de colegiado para retirar el banner provisional. CUE digital (RD 34/2025, vigor 2027) registrado para F1.1.',
				'gxare_proyecto_faq'         => "¿Cumple el formato exacto del libro oficial PAC? :: El generador sigue el RD 1311/2012 y el RD 285/2021 vigentes. Validación final del formato requiere firma de inspector real OCA.\n¿Soporta Xylella y Flavescencia dorada? :: Sí. Ambas están marcadas como declaración obligatoria y disparan banner rojo automático al diagnosticarlas tanto manualmente como por IA.\n¿Vale para una bodega que vende a granel y embotella? :: Sí. El libro económico distingue venta de uva, vino a granel y vino en botella con su IVA correcto y el campo de lote para trazabilidad DOP.\n¿Se puede usar sin clave de Anthropic? :: Sí. La IA es opcional y BYO key. Toda la funcionalidad de cuaderno, mapa y libro PAC funciona sin clave.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-apicola',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-apicola',
			'orden'     => 42,
			'coleccion' => 'solera',
			'title'     => 'Larrea Apícola',
			'excerpt'   => 'Libro REGA digital + gestión de varroa + IA apícola para 20-200 colmenas.',
			'content'   => 'La colmena como entidad persistente con matrícula. Trashumancia bien modelada como evento.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Libro REGA + varroa + IA apícola, 20-200 colmenas.',
				'gxare_proyecto_audiencia'   => 'Apicultor profesional',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, REGA, Reglamento CE 853/2004',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#C99A3B',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Larrea Apícola es el fork vertical para apicultores profesionales y semi-profesionales que llevan el libro REGA exigido por el RD 209/2002 y el Reglamento CE 853/2004. La colmena es entidad persistente con matrícula única, tipo, raza de abeja y año/color de la reina por ciclo de cinco años. Modela explícitamente la trashumancia como evento con origen, destino, fecha y motivo (mielada, invernada, sanitario), algo que casi ningún competidor hace bien. Incluye tratamientos contra varroa con sustancias activas, plazos de seguridad, libro REGA PDF firmable, IA Claude Vision con lista canónica peninsular, y extracto económico REAGP con ingreso por alquiler de polinización separado.',
				'gxare_proyecto_para_quien'  => 'Apicultor con 20 a 200 colmenas que hoy lleva el libro oficial en papel o Excel y acumula desfases en SITRAN apícola. Comprador-tipo cooperativista o autónomo profesional. Suscripción objetivo 8-20 euros mensuales: ticket bajo, volumen alto, mercado muy concreto en Iberia.',
				'gxare_proyecto_virtudes'    => "Trashumancia bien modelada como evento de pleno derecho con origen+destino+motivo\nLibro REGA PDF conforme al RD 209/2002 y al Reglamento CE 853/2004\nBanner rojo automático para patologías de declaración obligatoria (Tropilaelaps, loque americana)\nColor de marca de la reina calculado automáticamente por ciclo de cinco años\nCatálogos provenientes de COLOSS, CIMA Vet, WOAH Manual y RD 1132/2010",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'F1A-1 a F1A-10 cerradas (10 fases). Catálogos revisados contra fuente pública con catalogosCompletamenteRevisados=true. Pendiente auditoría humana del veterinario apícola con colegiado y verificación de RD autonómico de cada CCAA. SITRAN-AP digital anotado para F1.1.',
				'gxare_proyecto_faq'         => "¿Sustituye al veterinario asesor? :: No, lo complementa. La app lleva la trazabilidad documental, pero el dictamen sanitario sigue siendo del veterinario colegiado.\n¿Cómo modela un camión que mueve colmenas a varios destinos? :: La trashumancia se registra como evento de movimiento con origen y destino. La asignación fina del coste de transporte por destino queda como decisión fiscal pendiente con asesor.\n¿El extracto fiscal soporta el alquiler de colmenas para polinización? :: Sí, va como categoría aparte porque el CNAE y el IVA difieren de la venta de miel. Está marcado provisional hasta firma de fiscalista.\n¿Recomienda marcas comerciales como Apivar o ApiBioxal? :: No. En el catálogo sólo aparecen sustancias activas (ácido oxálico, timol, amitraz). La marca y dosis vigente es responsabilidad del veterinario.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-arbolado',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-arbolado-urbano',
			'orden'     => 43,
			'coleccion' => 'solera',
			'title'     => 'Larrea Arbolado Urbano',
			'excerpt'   => 'B2B para ayuntamientos: QR chapa + valoración VTA + multi-operario.',
			'content'   => 'Inventario por QR de chapa municipal escaneable desde móvil en treinta segundos.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'QR chapa + VTA + multi-operario para ayuntamientos.',
				'gxare_proyecto_audiencia'   => 'Ayuntamientos',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, VTA, Facturae 3.2',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#3A7D5A',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Larrea Arbolado Urbano es el fork B2B de la suite, orientado a la gestión municipal del arbolado público. Cada árbol lleva chapa con QR resistente a la intemperie; el operario lo escanea, ve el historial completo (especie, edad, perímetro, altura, riesgo VTA) y registra inspección, poda, tratamiento o incidencia en treinta segundos. Genera partes municipales firmables en PDF con técnico responsable, NIF, empresa contratista y carnet de aplicador. Incluye IA Claude Vision para arbolado urbano peninsular, evaluación VTA simplificada trazable, y modelo de facturación B2B con factura electrónica Facturae 3.2 para FACe.',
				'gxare_proyecto_para_quien'  => 'Técnico de medio ambiente de ayuntamiento pequeño o mediano que hoy gestiona el arbolado en Excel más la memoria del jardinero veterano a punto de jubilarse; o empresa de jardinería que mantiene varios municipios bajo contrato. Compite con software municipal pesado (Esri ArcGIS, GVSIG verde) que cuesta cinco cifras. Licencia anual 500-3.000 euros por municipio según número de árboles.',
				'gxare_proyecto_virtudes'    => "Inventario por QR de chapa municipal escaneable desde móvil en treinta segundos\nMulti-operario con NIF, empresa contratista y carnet de aplicador trazables por firma\nVTA (Visual Tree Assessment) simplificada con histórico defensible ante reclamación\nCatálogos basados en Madrid OpenData, Barcelona OpenData, AEPJP y EN 17321\nModelo de facturación Facturae 3.2 listo para FACe, obligatoria en AAPP",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'F1U-1 a F1U-9 cerradas. F1U-10 (facturación B2B con FACe) cerrada como provisional. Pendiente auditoría del ingeniero técnico forestal asesor + firma del ayuntamiento piloto. Decisiones abiertas: si la app envía a FACe por API con certificado digital o sólo registra factura emitida.',
				'gxare_proyecto_faq'         => "¿Qué pasa si la chapa QR se cae o la rompe un vandalismo? :: El árbol queda identificable por identificador municipal (IRU-2024-PASEO-042) además del payload del QR. La asociación nueva chapa-árbol se hace desde la ficha en treinta segundos.\n¿La app emite el dictamen de talar un árbol? :: No. La app registra y traza el riesgo VTA, pero la decisión de tala es siempre del técnico cualificado firmante. La responsabilidad jurídica no se delega.\n¿Cómo protege la privacidad ciudadana en las fotos? :: Las fotos no suben a ningún servidor de Larrea. Sólo viajan a Anthropic cuando el operario pulsa identificación IA, y por elección explícita.\n¿Soporta empresa contratista que mantiene varios municipios? :: Sí. El operario y la empresa contratista van en cada parte. El multi-rol completo con backend llega en F2.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-quesera',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-quesera',
			'orden'     => 44,
			'coleccion' => 'solera',
			'title'     => 'Larrea Quesera',
			'excerpt'   => 'Cuaderno APPCC + curación + trazabilidad de lotes para queserías artesanas.',
			'content'   => 'El lote de producción como entidad central. Verticalización por DO.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'APPCC + curación + trazabilidad para queserías artesanas.',
				'gxare_proyecto_audiencia'   => 'Queserías artesanas',
				'gxare_proyecto_estado'      => 'mvp',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, APPCC, DOPs',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#D4A537',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Larrea Quesera es el fork vertical para queserías artesanales que hoy llevan la trazabilidad en Excel y cuaderno de papel. Modela el lote de producción como entidad central con trazabilidad completa desde la recepción de leche (volumen, temperatura, pH, grasa, proteína, antibióticos) hasta la pieza individual en cava, con peso, ubicación, volteos y estado (afinando, lista, expedida, baja). Genera Libro de Trazabilidad APPCC en PDF con siete secciones listo para inspección sanitaria. Verticalización por Denominación de Origen (Idiazabal, Manchego, Cabrales, Roncal, Mahón…) que valida raza, curación mínima, zona y métodos del pliego.',
				'gxare_proyecto_para_quien'  => 'Quesero artesanal con 1-10 empleados y 20-500 piezas en afinado, en cualquier DO peninsular. Hoy lleva la trazabilidad mezclando Excel, papel y etiquetas a mano. Suscripción objetivo 10-25 euros mensuales por quesería. Pieza necesaria antes de cada inspección de RGSEAA o del consejo regulador.',
				'gxare_proyecto_virtudes'    => "Libro de Trazabilidad APPCC PDF con siete secciones inspeccionables\nGestión de afinado por pieza individual con historia completa (volteos, ahumados, peso)\nVerticalización por DO valida pliego de condiciones automáticamente\nCatálogos curados de 23 tipos de queso, 17 razas lecheras, 15 DOs, 18 defectos\nTrazabilidad de partidas de leche por proveedor (ganadero externo o rebaño propio)",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'F1-1 a F1-5 cerradas, con catálogos provisionales. F1-6 (perfiles DO con validación de pliego), F1-7 (IA Claude Vision para defectos), F1-8 (backup + pulido), F1-9 (libro económico) y F1-10 (catálogos pre-curados) pendientes. Validación del libro de trazabilidad por inspector real bloqueada hasta cierre de catálogos.',
				'gxare_proyecto_faq'         => "¿Cubre yogur, requesón y cuajada o sólo queso? :: Hoy se centra en queso. La extensión a otros productos lácteos es decisión humana abierta y depende del nicho del cliente piloto.\n¿Cómo se valida que un queso cumple el pliego DOP? :: Activas el perfil DOP (por ejemplo Idiazabal) y la app valida raza, zona, curación mínima y métodos contra el pliego cargado. El cumplimiento final del Consejo Regulador sigue siendo del quesero.\n¿La etiqueta que genera la app sirve para imprimir directamente? :: No de forma vinculante. El quesero verifica antes de imprimir. La app facilita el contenido legal, no asume responsabilidad regulatoria.\n¿Cumple Reglamento CE 853/2004 sobre subproductos? :: Sigue la estructura, pero el formato exacto debe validarse con inspector autonómico antes de release público.",
			),
		),

		array(
			'seed_id'   => 'proy-solera-aceitera',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'solera-aceitera',
			'orden'     => 45,
			'coleccion' => 'solera',
			'title'     => 'Larrea Aceitera',
			'excerpt'   => 'PAC olivar + libro AICA + DOP + IA visual plagas para almazaras 100-2000 hl.',
			'content'   => 'Cubre el ciclo completo olivar→almazara→libro fiscal en una sola herramienta.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'PAC + AICA + DOP + IA visual plagas para almazaras pequeñas.',
				'gxare_proyecto_audiencia'   => 'Almazaras 100-2000 hl/campaña',
				'gxare_proyecto_estado'      => 'esqueleto',
				'gxare_proyecto_tipo'        => 'app',
				'gxare_proyecto_tech'        => 'Flutter, sqflite, PAC RD 1311/2012, AICA RD 760/2021, REAGP',
				'gxare_proyecto_marca'       => 'Larrea',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/nuevo-ser',
				'gxare_proyecto_color'       => '#6B7B3A',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_que_hace_largo' => 'Larrea Aceitera es el fork vertical para almazaras pequeñas y medianas que llevan a la vez cuaderno PAC olivar y libro de movimientos del aceite. Modela el ciclo completo: parcela olivarera con SIGPAC y variedad mayoritaria, recolección por método, recepción de aceituna en almazara, molturación con rendimiento, lote de aceite con acidez/peróxidos/K232/K270 y categoría (virgen extra, virgen, lampante), movimientos por lote y venta diferenciando España, UE y extra UE. Cumple RD 1311/2012, RD 285/2021 y RD 760/2021 (AICA). Incluye IA Claude Vision olivar, verticalización por DOP y cierre fiscal REAGP olivar.',
				'gxare_proyecto_para_quien'  => 'Maestro almazarero o técnico de cooperativa pequeña/mediana (100-2000 hl/campaña, 1-15 empleados) que hoy lleva tres cuadernos paralelos: PAC olivar, libro AICA del aceite y libro fiscal REAGP. Sector infradigitalizado fuera de las grandes cooperativas. Suscripción 15-30 euros mensuales por almazara, con opción de licencia anual cooperativa cuando hay más de 50 socios.',
				'gxare_proyecto_virtudes'    => "Cubre el ciclo completo olivar→almazara→libro fiscal en una sola herramienta\nLibro de movimientos del aceite AICA conforme al RD 760/2021\nVerticalización por 29 DOPs vigentes con pliego (variedades, acidez máxima, zona)\nIA Claude Vision con 25 patologías canónicas olivar peninsular y declaración obligatoria\nREAGP olivar bien modelado: aceituna 4%/12% compensación, aceite 4% básico, alquiler exento",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'F1-A1 a F1-A11 cerradas (esqueleto + 18 modelos POJO + sqflite v2 + 20 pantallas + 3 generadores PDF con sello PROVISIONAL R1 + 5 catálogos revisados + IA Claude Vision + libro económico REAGP + APK release de 56 MB + 83 tests). Auditoría humana final del asesor agrónomo, técnico OCA, auditor AICA y asesor fiscal sigue pendiente para retirar los sellos provisionales.',
				'gxare_proyecto_faq'         => "¿Distingue venta de aceituna a almazara de venta de aceite envasado? :: Sí, son tipos distintos en el libro económico con IVA y compensación REAGP diferenciados. Es clave para que el extracto fiscal no confunda al asesor.\n¿Soporta cooperativa con socios externos que llevan aceituna? :: Sí. La partida de aceituna distingue origen propio de origen socio con albarán y porcentaje de defectos por catador.\n¿Cubre alperujo, orujo graso y hueso de aceituna? :: La venta de subproducto está modelada como categoría, pero la integración con extractora y biomasa queda como decisión humana pendiente.\n¿La acidez/peróxidos/K232/K270 los introduce el almazarero o se importan? :: Manual en v1, importados desde el laboratorio analítico está planificado para F2 cuando entre el backend nube.",
			),
		),

		// ╔════════════════════════════════════════════════════════════
		// ║ FLAVOR (3 plugins WP)
		// ╚════════════════════════════════════════════════════════════

		array(
			'seed_id'   => 'proy-flavor-platform',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'flavor-platform',
			'orden'     => 50,
			'coleccion' => 'flavor',
			'title'     => 'Flavor Platform',
			'excerpt'   => 'Plataforma integral para WordPress: comunidades, IA, page builder, deep links, matching, newsletter, sellos.',
			'content'   => 'Plugin WordPress modular con 74+ módulos comunitarios y apps móviles Flutter incluidas.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Plataforma integral WordPress: comunidades, IA, page builder.',
				'gxare_proyecto_audiencia'   => 'Cooperativas, ayuntamientos, PYMES responsables',
				'gxare_proyecto_estado'      => 'maduro',
				'gxare_proyecto_tipo'        => 'plugin',
				'gxare_proyecto_tech'        => 'PHP 8.1, WordPress 6.4, Flutter, WooCommerce, Ed25519',
				'gxare_proyecto_marca'       => 'Flavor',
				'gxare_proyecto_url_web'     => 'https://gailu.net',
				'gxare_proyecto_color'       => '#6C8AA0',
				'gxare_proyecto_destacado'   => '1',
				'gxare_proyecto_que_hace_largo' => 'Flavor Platform es la plataforma integral de Gailu Labs sobre WordPress orientada a comunidades, cooperativas, asociaciones, ayuntamientos y redes ciudadanas. Combina más de 74 módulos comunitarios activables como piezas Lego (socios, grupos de consumo, marketplace, presupuestos participativos, transparencia, foros, chat interno, banco de tiempo, huertos urbanos, energía comunitaria, crowdfunding, agregador de contenido, hostelería), un page builder visual propio con bloques dinámicos, apps móviles Flutter (cliente y admin) compartiendo base de código, asistente conversacional IA multi-proveedor, APIs REST automatizables vía Claude Code y addons opcionales.',
				'gxare_proyecto_para_quien'  => 'Cooperativas, ayuntamientos pequeños y medianos, PYMES responsables, asociaciones, federaciones y redes municipales que hoy mantienen un Frankenstein de 15 plugins WordPress mal integrados. También partners e integradores que despliegan instancias verticales (grupo de consumo, comunidad vecinal, cooperativa, asociación) y necesitan apps móviles incluidas sin tocar Flutter. Distribuido bajo GPL-2.0.',
				'gxare_proyecto_virtudes'    => "74+ módulos interconectados que comparten datos, permisos, UI y API en un único núcleo\nPage builder visual fullscreen con bloques dinámicos y presets de diseño\nApps móviles Flutter cliente y admin compartiendo base de código y catálogo de módulos\nFederación multi-sitio Ed25519 (sodium) para conectar comunidades autónomas\nAutomatización completa por API REST con API key X-VBP-Key",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Versión 3.5.12 con plantillas de sitio para cooperativa, asociación, comunidad y grupos de consumo. Cache canónico migrado a Flavor_Cache_Manager (Performance_Cache marcado deprecated desde 3.6.0). Sigue auditoría viva en reports/AUDITORIA-ESTADO-REAL-2026-03-04.md. Mesh Installer (Ed25519) y Network Installer del core deben mantenerse separados.',
				'gxare_proyecto_faq'         => "¿Tengo que activar los 74 módulos? :: No. La regla explícita es no activar más de 20 módulos sin justificación. Cada plantilla activa sólo el subconjunto necesario para el caso de uso.\n¿Puedo automatizar la creación del sitio desde Claude Code? :: Sí. El endpoint POST /wp-json/flavor-site-builder/v1/site/create levanta sitio completo en una sola llamada autenticada con X-VBP-Key.\n¿Las apps móviles son una APK genérica o se compilan por cliente? :: Se compilan por cliente desde la misma base con build_app.sh client release. Cada módulo WordPress activo tiene contraparte Flutter.\n¿Funciona con cualquier tema WordPress? :: La plataforma asume el tema flavor-starter. Tocar el HTML por Gutenberg está expresamente prohibido: las páginas se crean siempre por Visual Builder Pro.",
			),
		),

		array(
			'seed_id'   => 'proy-flavor-news-hub',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'flavor-news-hub',
			'orden'     => 51,
			'coleccion' => 'flavor',
			'title'     => 'Flavor News Hub',
			'excerpt'   => 'Backend headless para agregar medios alternativos y listar colectivos organizados.',
			'content'   => 'CPTs, ingesta RSS, REST pública, verificación humana.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Agregador headless de medios alternativos y colectivos.',
				'gxare_proyecto_audiencia'   => 'Medios federados, radios libres, colectivos',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'plugin',
				'gxare_proyecto_tech'        => 'PHP 8.1, WordPress, RSS/Atom, REST API',
				'gxare_proyecto_marca'       => 'Flavor',
				'gxare_proyecto_url_repo'    => 'https://github.com/JosuIru/flavor-news-hub',
				'gxare_proyecto_color'       => '#B05E3B',
				'gxare_proyecto_destacado'   => '0',
				// Renderiza con bloques importados del Visual Builder
				// Pro de flavor-platform. Tras importar (wp gxare
				// importar-flavor-landing <id> --proyecto=...), el
				// portfolio no depende del plugin Flavor para mostrarla.
				'gxare_proyecto_landing'     => 'bloques',
				'gxare_proyecto_que_hace_largo' => 'Plugin headless de WordPress que actúa como backend agregador de medios alternativos, radios libres y colectivos activistas. Expone cuatro Custom Post Types (fuente, noticia, colectivo, radio) más una taxonomía compartida de temáticas canónicas. Ingesta automatizada de feeds RSS/Atom/YouTube/Mastodon/podcast cada 30 minutos vía wp_cron con dedupe por GUID y URL original. API REST pública flavor-news/v1 sin autenticación de lectura con filtros por temática, territorio, idioma y fecha. Plantillas web públicas /n/, /c/, /f/ independientes del tema activo (HTML de 10-15 KB sin enqueues de terceros).',
				'gxare_proyecto_para_quien'  => 'Proyectos de medios federados, radios libres, agregadores de prensa alternativa y colectivos que quieren disponer de un catálogo curado y federado de fuentes sin pagar APIs comerciales. Pensado para alimentar tanto la web pública como una app Flutter de lectura con catálogo offline. Licencia AGPL-3.0-or-later: si despliegas instancia modificada accesible por red, publicas los cambios.',
				'gxare_proyecto_virtudes'    => "Ingesta automatizada cada 30 minutos con dedupe idempotente por GUID y URL original\nAPI REST pública sin auth, filtrable por temática, territorio, idioma, fecha desde\nPlantillas públicas independientes del tema, 10-15 KB, sin JS, accesibles AA y prefers-color-scheme\nCriterio de reutilización claro: sólo metadatos y enlace canónico, nunca artículo completo\nSuite PHPUnit con WP_UnitTestCase y bootstrap real de WordPress",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Las seis capas marcadas como cerradas (CPTs, ingesta, REST, admin, plantillas web, tests). Workflow GitHub Actions pendiente (tarea #14). Sincronización del seed bundleado entre backend/seed/*.json y app/assets/seed/*.json requiere build de la app Flutter para que la versión offline vea cambios manuales hechos vía WP-CLI.',
				'gxare_proyecto_faq'         => "¿Puedo importar artículos completos de un medio? :: No. La regla práctica del proyecto: sólo se almacenan metadatos (nombre, web, feed, territorio, idiomas, temas) y enlace canónico al original. Si empieza a sustituir al medio, está fuera del objetivo.\n¿Cómo se da de alta un colectivo nuevo? :: Vía POST /collectives/submit con honeypot y rate limit por IP (3 altas/hora). Entra como pending con _fnh_verified=false y nunca aparece en la API pública hasta que un verificador humano lo apruebe.\n¿Funciona como fuente de datos para una app móvil? :: Sí. Endpoints /feed-html (HTML pre-renderizado para scroll infinito), /apps/check-update, /settings.\n¿Qué pasa con los emails de contacto en la REST? :: No se exponen. Los campos _fnh_contact_email y _fnh_submitted_by_email están marcados explícitamente como no expuestos en la API estándar de WordPress ni en flavor-news/v1.",
			),
		),

		array(
			'seed_id'   => 'proy-flavor-chat-ia',
			'post_type' => 'gxare_proyecto',
			'slug'      => 'flavor-chat-ia',
			'orden'     => 52,
			'coleccion' => 'flavor',
			'title'     => 'Flavor Chat IA',
			'excerpt'   => 'Asistente conversacional con IA para sitios WordPress con tema minimalista propio.',
			'content'   => 'Multi-proveedor IA (Claude, OpenAI, DeepSeek, Mistral) integrado en flavor-starter.',
			'meta'      => array(
				'gxare_proyecto_subtitulo'   => 'Chat IA conversacional integrado en WordPress.',
				'gxare_proyecto_audiencia'   => 'Cooperativas, ayuntamientos, PYMES con tema flavor-starter',
				'gxare_proyecto_estado'      => 'produccion',
				'gxare_proyecto_tipo'        => 'plugin',
				'gxare_proyecto_tech'        => 'PHP 8.1, WordPress, Anthropic / OpenAI / DeepSeek / Mistral',
				'gxare_proyecto_marca'       => 'Flavor',
				'gxare_proyecto_url_web'     => 'https://gailu.net',
				'gxare_proyecto_color'       => '#C99A3B',
				'gxare_proyecto_destacado'   => '0',
				'gxare_proyecto_landing'     => 'flavor-chat-ia',
				'gxare_proyecto_que_hace_largo' => 'Asistente conversacional con IA del ecosistema Gailu Labs para sitios WordPress que usan el tema minimalista flavor-starter. Soporta multi-proveedor (Claude Sonnet 4 y Haiku, OpenAI GPT-4o-mini, DeepSeek, Mistral) configurable desde el panel de administración con clave API por proveedor, modelo seleccionable, nombre del asistente personalizable y prompt de rol editable. El plugin flavor-landing actúa como landing promocional multiidioma (castellano, inglés, euskera, catalán, gallego) que explica la propuesta de la red federada Flavor.',
				'gxare_proyecto_para_quien'  => 'Cooperativas, ayuntamientos, PYMES responsables y comunidades conscientes que ya usan o evalúan Flavor Platform y necesitan un asistente conversacional sin atarse a un único proveedor de IA. La landing está dirigida a potenciales partners e integradores que llegan por ronda comercial o por NGI/Zero Commons.',
				'gxare_proyecto_virtudes'    => "Multi-proveedor IA con conmutación caliente sin tocar código (Claude, OpenAI, DeepSeek, Mistral)\nClaves API por proveedor en password field, enmascaradas en lectura, regenerables\nActivación granular: se puede habilitar/deshabilitar el chat en el sitio sin desactivar el plugin\nNombre del asistente y rol de comportamiento configurables desde admin sin tocar código\nLanding promocional accesible y multiidioma (es/en/eu/ca/gl)",
				'gxare_proyecto_pedagogia'   => '',
				'gxare_proyecto_estado_largo'=> 'Versión 1.3.1 de la landing (flavor-landing); el chat propiamente vive embebido en flavor-platform 3.5.12 con la pantalla de configuración en admin/class-chat-settings.php. Producto comercial maduro de Flavor Studio / Gailu Labs, integrado con el tema flavor-starter y con propuesta NGI Zero Commons documentada.',
				'gxare_proyecto_faq'         => "¿Funciona con cualquier tema WordPress? :: Está pensado para flavor-starter. La integración visual asume su sistema de tokens; en otros temas el chat funciona pero la estética puede no cuadrar.\n¿Tengo que pagar a varios proveedores de IA? :: No. Configuras sólo el proveedor que vayas a usar (Claude por defecto). Los demás quedan vacíos y el selector sólo expone los activos.\n¿Cambia el proveedor por usuario o por sitio? :: Por sitio en v1. El proveedor activo es global y se cambia desde Ajustes. La selección por rol o por sección queda como roadmap.\n¿La clave API se ve en claro alguna vez? :: No. El campo es password y al cargar la pantalla sólo se muestra una versión enmascarada de la clave guardada. La regeneración es explícita desde admin.",
			),
		),

	);
}

function gxare_seed_descargas(): array {
	return array(
		array(
			'seed_id'  => 'desc-fosiles-1.0.13',
			'post_type'=> 'gxare_descarga',
			'slug'     => 'fosiles-apk-1-0-13',
			'orden'    => 10,
			'title'    => 'Fósiles — APK Android',
			'meta' => array(
				'gxare_descarga_proyecto_slug' => 'cuadernos-de-campo-fosiles',
				'gxare_descarga_version'       => '1.0.13+14',
				'gxare_descarga_fecha'         => '2026-05-19',
				'gxare_descarga_plataforma'    => 'android',
				'gxare_descarga_url'           => 'https://github.com/JosuIru/nuevo-ser/releases/download/apks-2026-05-19/fosiles-1.0.13+14.apk',
				'gxare_descarga_peso'          => '~68 MB',
				'gxare_descarga_notas'         => 'Asistente IGME estable, motor de sugerencias enriquecido, visor de fotos, navegación entre fichas, clustering, onboarding. Cobertura IGME nacional.',
			),
		),
		array(
			'seed_id'  => 'desc-naturaleza-1.0.6',
			'post_type'=> 'gxare_descarga',
			'slug'     => 'naturaleza-apk-1-0-6',
			'orden'    => 20,
			'title'    => 'Naturaleza — APK Android',
			'meta' => array(
				'gxare_descarga_proyecto_slug' => 'cuadernos-de-campo-naturaleza',
				'gxare_descarga_version'       => '1.0.6+7',
				'gxare_descarga_fecha'         => '2026-05-20',
				'gxare_descarga_plataforma'    => 'android',
				'gxare_descarga_url'           => 'https://github.com/JosuIru/cuadernos-de-campo/releases/download/naturaleza-v1.0.6/naturaleza-1.0.6+7.apk',
				'gxare_descarga_peso'          => '~77 MB',
				'gxare_descarga_notas'         => 'Tipo de evidencia filtrado por categoría, especie corregida visible en lista, borrar anotaciones al margen, banner de actualización en Mapa y Lista. Mi fenología, Tasa de acierto, Salidas como unidad narrativa, hipótesis personal.',
			),
		),
		array(
			'seed_id'  => 'desc-flavor-platform-3.5.13',
			'post_type'=> 'gxare_descarga',
			'slug'     => 'flavor-platform-3-5-13',
			'orden'    => 30,
			'title'    => 'Flavor Platform — ZIP WordPress',
			'meta' => array(
				'gxare_descarga_proyecto_slug' => 'flavor-platform',
				'gxare_descarga_version'       => '3.5.13',
				'gxare_descarga_fecha'         => '2026-05-19',
				'gxare_descarga_plataforma'    => 'wp',
				'gxare_descarga_url'           => 'https://gailu.net',
				'gxare_descarga_notas'         => 'Plataforma integral WP. Contacta para acceso.',
			),
		),
		array(
			'seed_id'  => 'desc-flavor-news-0.16.6',
			'post_type'=> 'gxare_descarga',
			'slug'     => 'flavor-news-hub-apk',
			'orden'    => 40,
			'title'    => 'Flavor News Hub — APK Android',
			'meta' => array(
				'gxare_descarga_proyecto_slug' => 'flavor-news-hub',
				'gxare_descarga_version'       => '0.16.6',
				'gxare_descarga_fecha'         => '2026-05-05',
				'gxare_descarga_plataforma'    => 'android',
				'gxare_descarga_url'           => 'https://github.com/JosuIru/flavor-news-hub/releases/download/v0.16.6/flavor-news-hub-app-v0.16.6.apk',
				'gxare_descarga_notas'         => 'App cliente de lectura del catálogo agregado. Consume la API REST flavor-news/v1 del backend. AGPL-3.0.',
			),
		),
	);
}
