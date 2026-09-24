import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'escenas_arco_1.dart';
import 'voz_personaje.dart';

/// Versiones cortas de las cinemáticas: 4-9 planos en vez de 15-46.
///
/// Motivo: en pruebas con el público objetivo (12 y 13 años), la
/// apertura del Arco 1 pedía unas 1.050 palabras y ~140 toques antes de
/// la primera decisión de juego (Brecha 1.1), y se aburrían antes de
/// llegar. La versión corta deja la misma historia en ~250 palabras y
/// pone una decisión en los primeros segundos.
///
/// Reglas:
/// - Mismo `id`, `flagDeSalida`, `flagsRequeridos`, ambiente y cierre
///   que la escena entera: el orquestador no distingue una de otra.
/// - Se conservan **todas** las elecciones de la escena entera con sus
///   mismos flags.
/// - Se reutilizan frases del guion (doc 07) siempre que se puede. Lo
///   nuevo (la elección de la inscripción en 1.0.1) está marcado como
///   BORRADOR en BLOQUEOS-PENDIENTES.md § ESCENAS-CORTAS.
/// - La escena entera sigue a un toque («ver entera») y hay un ajuste
///   en el menú para verlas siempre enteras.
class EscenasCortas {
  EscenasCortas._();

  /// Versión corta de la escena [idEscena], o `null` si no tiene.
  static EscenaCinematica? para(String idEscena) => _porId[idEscena];

  static bool tieneVersionCorta(String idEscena) => _porId.containsKey(idEscena);

  /// Ids de las escenas que tienen versión corta.
  static Iterable<String> get ids => _porId.keys;

  static EscenaCinematica _corta(EscenaCinematica entera, List<PlanoEscena> planos) {
    return EscenaCinematica(
      id: entera.id,
      titulo: entera.titulo,
      planos: planos,
      flagDeSalida: entera.flagDeSalida,
      flagsRequeridos: entera.flagsRequeridos,
      esCierreAmable: entera.esCierreAmable,
      sonidoDeEntrada: entera.sonidoDeEntrada,
      loopDeFondo: entera.loopDeFondo,
      ambiente: entera.ambiente,
    );
  }

  static const _breve = Duration(seconds: 3);
  static const _media = Duration(seconds: 4);
  static const _larga = Duration(seconds: 6);

  static final Map<String, EscenaCinematica> _porId = {
    // 1.0.1 La evaluación — la primera decisión llega en el tercer plano.
    EscenasArco1.laEvaluacion.id: _corta(EscenasArco1.laEvaluacion, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'Iruña. Archivo de la calle Curia. Sala de evaluación.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.begona,
        texto: 'Maren Lozano. Tienes 13 años recién cumplidos. Lo habitual '
            'es que los Aspirantes tengan 14 mínimo.',
      ),
      const PlanoEleccion(
        voz: VozPersonaje.begona,
        textoPrompt: '¿Por qué estás aquí?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Porque mi madre me contó lo que hacéis. Y porque '
                'hace cuatro años fui a Aralar y no quise irme.',
            flagsAEstablecer: {'motivo_madre_aralar'},
          ),
          OpcionEleccion(
            textoJugador: 'Quiero saber cómo se sabe lo que pasó.',
            flagsAEstablecer: {'motivo_curiosidad_epistemica'},
          ),
          OpcionEleccion(
            textoJugador: 'Mi padre dijo que era buen sitio para empezar.',
            flagsAEstablecer: {'motivo_recomendacion_familiar'},
          ),
          OpcionEleccion(
            textoJugador: 'No lo sé bien.',
            flagsAEstablecer: {'motivo_indeciso'},
          ),
        ],
      ),
      // BORRADOR (nuevo, no está en el guion): la evaluación se juega en
      // vez de leerse. No afirma nada histórico: la inscripción es la
      // misma pieza sin identificar que pone el guion sobre la mesa.
      const PlanoEleccion(
        voz: VozPersonaje.begona,
        textoPrompt: 'Una inscripción romana, rota. ¿Qué sabes seguro de ella?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Que alguien la talló.',
            textoRespuesta: 'Eso sí se puede decir.',
            vozRespuesta: VozPersonaje.isaura,
            flagsAEstablecer: {'evaluacion_mirada_lo_seguro'},
          ),
          OpcionEleccion(
            textoJugador: 'Quién la talló.',
            textoRespuesta: '¿Lo pone en algún sitio?',
            vozRespuesta: VozPersonaje.isaura,
            flagsAEstablecer: {'evaluacion_mirada_sobreconfiada'},
          ),
          OpcionEleccion(
            textoJugador: 'Todavía nada. Primero la miraría.',
            textoRespuesta: 'Mm.',
            vozRespuesta: VozPersonaje.isaura,
            flagsAEstablecer: {'evaluacion_mirada_prudente'},
          ),
        ],
      ),
      const PlanoDialogo(
        voz: VozPersonaje.begona,
        texto: 'No buscamos respuestas correctas. Buscamos cómo respondes.',
      ),
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Deliberan quince minutos. Isaura dobla el papel de Maren '
            'y se lo guarda en el bolsillo. No es protocolo.',
      ),
      const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Aspirante. Te aceptamos.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Bienvenida, Maren.'),
      const PlanoCierreAmable(textoBoton: 'VOLVER MAÑANA'),
    ]),

    // 1.0.2 El recorrido.
    EscenasArco1.elRecorrido.id: _corta(EscenasArco1.elRecorrido, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Al día siguiente, Isaura le enseña el Archivo: el patio, '
            'la domus romana del sótano, la biblioteca. Se cruzan con '
            'Marina, 17 años, Aprendiz III.',
      ),
      const PlanoAmbiente(duracion: _breve, textoLectura: 'Suben al ático. Vitrinas con piezas.'),
      const PlanoDialogo(
        voz: VozPersonaje.andres,
        texto: 'Yo soy Andrés. El de las cosas. Cuando rompas algo, vienes '
            'a verme — pero con cara de pena.',
      ),
      const PlanoEleccion(
        voz: VozPersonaje.isaura,
        textoPrompt: '¿Té o café?',
        opciones: [
          OpcionEleccion(textoJugador: 'Café.', flagsAEstablecer: {'preferencia_cafe'}),
          OpcionEleccion(textoJugador: 'Té.', flagsAEstablecer: {'preferencia_te'}),
          OpcionEleccion(textoJugador: 'Agua.', flagsAEstablecer: {'preferencia_agua'}),
        ],
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Mañana subes a Aralar conmigo. Mañana es tu primera Brecha.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Pensaba que tardaba más.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'No se aprende esperando.'),
      const PlanoCierreAmable(textoBoton: 'IR A CASA'),
    ]),

    // 1.0.3 La primera tarde en casa.
    EscenasArco1.laPrimeraTardeEnCasa.id: _corta(EscenasArco1.laPrimeraTardeEnCasa, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'En casa, a la hora de comer. Iratxe, Antonio y Naia.',
      ),
      const PlanoDialogo(voz: VozPersonaje.naia, texto: 'Maren, ¿hoy te han hecho cronista ya?'),
      const PlanoEleccion(
        voz: VozPersonaje.naia,
        textoPrompt: '¿Y qué hace una cronista?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Cuenta las cosas como pasaron.',
            flagsAEstablecer: {'oficio_explicado_simple'},
          ),
          OpcionEleccion(
            textoJugador: 'Lee cosas viejas y trata de entenderlas.',
            flagsAEstablecer: {'oficio_explicado_humilde'},
          ),
          OpcionEleccion(
            textoJugador: 'Hace preguntas. Después busca respuestas.',
            flagsAEstablecer: {'oficio_explicado_preguntas'},
          ),
        ],
      ),
      const PlanoDialogo(voz: VozPersonaje.naia, texto: '¿Y cómo sabes cómo pasaron?'),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Ese es el trabajo.'),
      const PlanoCierreAmable(textoBoton: 'HASTA MAÑANA'),
    ]),

    // 1.1.1 Camino a Aralar.
    EscenasArco1.caminoAAralar.id: _corta(EscenasArco1.caminoAAralar, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: '7:00 de la mañana. Isaura conduce hacia la sierra de Aralar.',
      ),
      const PlanoEleccion(
        voz: VozPersonaje.isaura,
        textoPrompt: '¿Has dormido?',
        opciones: [
          OpcionEleccion(textoJugador: 'Mal.', flagsAEstablecer: {'noche_previa_dormida_mal'}),
          OpcionEleccion(
            textoJugador: 'Casi nada.',
            flagsAEstablecer: {'noche_previa_apenas_dormida'},
          ),
          OpcionEleccion(textoJugador: 'Bien.', flagsAEstablecer: {'noche_previa_dormida_bien'}),
        ],
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'La primera vez se duerme mal.'),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Hoy, un dolmen. No te explico nada antes. Tú miras. Tú '
            'formulas. Yo vuelvo a la hora.',
      ),
      const PlanoCierreAmable(textoBoton: 'BAJAR DEL COCHE'),
    ]),

    // 1.1.2 El campo de dólmenes.
    EscenasArco1.elCampoDeDolmenes.id: _corta(EscenasArco1.elCampoDeDolmenes, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Un campo de dólmenes entre la hierba alta. En toda Aralar, '
            'más de cien.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'El tuyo es ése. Hay tres informes en el Archivo. Te los he '
            'traído. Léelos cuando quieras.',
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Te dejo. Vuelvo a las once.'),
      const PlanoCierreAmable(textoBoton: 'EMPEZAR'),
    ]),
    // ─── Pirineo ────────────────────────────────────────────────────

    // 1.3.3 Dentro de la cueva.
    EscenasArco1.dentroDeLaCueva.id: _corta(EscenasArco1.dentroDeLaCueva, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'El covacho: entrada amplia, luz los primeros metros, '
            'después oscuridad. Goteo lejano.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Mira al suelo aquí. Hoguera. La cocina, el dormir, las '
            'herramientas — todo aquí. Hace algo más de trece mil años.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Puedo tocar?'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'No.'),
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'El custodio abre una segunda entrada, más estrecha. Bajan '
            'cinco minutos. Dos grandes losas cierran a medias el paso.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Para qué son?'),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'No se sabe. Las pusieron mucho después de los grabados. Por '
            'qué exactamente — lo decidirás tú si llegas a esa Brecha algún día.',
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Aquí.'),
      const PlanoCierreAmable(textoBoton: 'ENCENDER LA LINTERNA'),
    ]),

    // 1.3.4 La pared — la luz rasante se elige, no se lee.
    EscenasArco1.laPared.id: _corta(EscenasArco1.laPared, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Sala de techos altos. La linterna de Maren sobre la '
            'piedra. Al principio no se ve nada.',
      ),
      // BORRADOR (nuevo): en el guion Maren prueba ángulos y las líneas
      // aparecen con la luz oblicua; aquí lo prueba la jugadora.
      const PlanoEleccion(
        voz: VozPersonaje.isaura,
        textoPrompt: '¿Cómo pones la luz?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'De frente, directa a la pared.',
            textoRespuesta: 'Así sólo se ve piedra. Prueba de lado.',
            vozRespuesta: VozPersonaje.isaura,
            flagsAEstablecer: {'linterna_de_frente'},
          ),
          OpcionEleccion(
            textoJugador: 'De lado, casi rozando la roca.',
            textoRespuesta: 'Ahí.',
            vozRespuesta: VozPersonaje.isaura,
            flagsAEstablecer: {'linterna_rasante'},
          ),
        ],
      ),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Con la luz rasante, las líneas aparecen. Un bisonte. Un '
            'ciervo más arriba. Una cabeza de uro. La parte trasera de un caballo.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Cuánto tiempo lleva eso allí?'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Trece mil años, aproximadamente.'),
      const PlanoDialogo(
        voz: VozPersonaje.maren,
        texto: '¿Por qué grabar algo donde no lo va a ver nadie a la luz del día?',
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Esa es la pregunta.'),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Maren pone la mano abierta cerca del bisonte, sin tocarlo. '
            'Compara su mano con la línea que alguien grabó. Después la retira.',
      ),
      const PlanoCierreAmable(textoBoton: 'VOLVER AL COCHE'),
    ]),

    // 1.3.5 Vuelta y silencio.
    EscenasArco1.vueltaYSilencio.id: _corta(EscenasArco1.vueltaYSilencio, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'Vuelta del Pirineo. Cuarenta minutos en silencio.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.maren,
        texto: 'El custodio dijo «después os abro la otra». Pero sólo me '
            'llevaste a dos cuevas.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Hay una tercera, descubierta hace poco. Pinturas de más de '
            'veinte mil años. Se entra con cuerdas y equipo de espeleología. '
            'Yo casi no salgo.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Entonces todavía aparecen cosas.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Todo el tiempo. El oficio no se acaba.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: '¿Necesitas hablar de lo de hoy?'),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No ahora.'),
      const PlanoCierreAmable(textoBoton: 'SUBIR A CASA'),
    ]),

    // 1.3.6 El primer Concilio formal — las respuestas se eligen.
    EscenasArco1.elPrimerConcilioFormal.id: _corta(EscenasArco1.elPrimerConcilioFormal, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Salón del Concilio. Aitor y Joana revisan. Karim observa '
            'al fondo. Maren presenta su reconstrucción de la cueva.',
      ),
      // BORRADOR (nuevo): la respuesta de Maren del guion es la primera
      // opción; la segunda es la tentación que el oficio corrige.
      const PlanoEleccion(
        voz: VozPersonaje.aitor,
        textoPrompt: 'El covacho data la habitación. ¿Cómo conectas covacho con '
            'grabados?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'No los conecto con seguridad. La datación del covacho '
                'es Sólida. Que los hicieran los mismos, Disputado.',
            textoRespuesta: 'Bien.',
            vozRespuesta: VozPersonaje.aitor,
            flagsAEstablecer: {'concilio_1_3_conexion_prudente'},
          ),
          OpcionEleccion(
            textoJugador: 'Son de la misma época, así que los hicieron los mismos.',
            textoRespuesta: '¿Lo prueba algo, o sólo lo sugiere?',
            vozRespuesta: VozPersonaje.aitor,
            flagsAEstablecer: {'concilio_1_3_conexion_sobreconfiada'},
          ),
        ],
      ),
      const PlanoDialogo(voz: VozPersonaje.aitor, texto: 'Sellada. Disputada como debe ser.'),
      const PlanoEleccion(
        voz: VozPersonaje.karim,
        textoPrompt: 'Dijiste que el significado de los grabados «no se puede '
            'determinar». ¿Quieres reformular?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'No podemos determinarlo con la evidencia disponible.',
            textoRespuesta: 'Mejor. La diferencia importa.',
            vozRespuesta: VozPersonaje.karim,
            flagsAEstablecer: {'concilio_1_3_reformula'},
          ),
          OpcionEleccion(
            textoJugador: 'No. No se puede saber y ya.',
            textoRespuesta: '¿Nunca? ¿O no con lo que tenemos hoy? La diferencia importa.',
            vozRespuesta: VozPersonaje.karim,
            flagsAEstablecer: {'concilio_1_3_no_reformula'},
          ),
        ],
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Mm.'),
      const PlanoCierreAmable(textoBoton: 'SALIR DEL SALÓN'),
    ]),

    // 1.3.7 El apunte largo — se conservan las frases del guion.
    EscenasArco1.elApunteLargo.id: _corta(EscenasArco1.elApunteLargo, [
      const PlanoAmbiente(duracion: _breve, textoLectura: 'Esa noche. Maren escribe en el cuaderno.'),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'En la cueva no se ven hasta que mueves la linterna en el '
            'ángulo correcto. Después aparecen. El bisonte. El ciervo. La cabeza '
            'del uro. El caballo.',
      ),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Karim me corrigió: «no se puede determinar con la evidencia '
            'disponible». Tiene razón. No es lo mismo.',
      ),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Alguien decidió grabar un bisonte donde nadie iba a verlo a '
            'la luz del día. Su mano se parecía a la mía. Estuvo allí donde yo '
            'estuve hoy. Y se fue.',
      ),
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Nosotras lo vimos. Eso no es Disputado.',
      ),
      const PlanoCierreAmable(textoBoton: 'HASTA MAÑANA'),
    ]),

    // ─── Irulegi ────────────────────────────────────────────────────

    // 1.4.1 El yacimiento.
    EscenasArco1.viajeAYacimientoIrulegi.id: _corta(EscenasArco1.viajeAYacimientoIrulegi, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Monte Irulegi, sobre el valle de Aranguren. Un poblado '
            'fortificado, parcialmente excavado.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.arqueologo,
        texto: 'Tú eres la nueva. Empieza por la casa. Las escaleras conservan '
            'siete peldaños.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Esta es tu última Brecha de Aspirante. Mañana viene el Concilio '
            'entero. No estás sola. Pero estás expuesta.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Primer cuarto del siglo I a.C. Tropas romanas lo incendiaron. Lo '
            'que tienes hoy es una fotografía congelada de una jornada de hace '
            'dos mil años.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'En esta casa encontraron la Mano de Irulegi. Está en el Museo de '
            'Navarra. Volvemos por la tarde a verla.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Aquí cerca encontraron también los restos de un bebé. Murió poco '
            'antes de nacer. La Brecha no se centra en él. Pero conviene que sepas '
            'que existió.',
      ),
      const PlanoCierreAmable(textoBoton: 'EMPEZAR LA JORNADA'),
    ]),

    // 1.4.2 Material congelado.
    EscenasArco1.materialCongelado.id: _corta(EscenasArco1.materialCongelado, [
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Dos horas en el yacimiento: cerámica local junto a piezas '
            'romanas en el mismo nivel, puntas de flecha, glandes de honda. Las '
            'casas colapsaron sobre todo lo demás.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.arqueologo,
        texto: 'Aquí intentaron imitar un pavimento romano. Pero la base no estaba '
            'bien preparada. Se les hundió.',
      ),
      const PlanoAmbiente(
        duracion: _larga,
        textoLectura: 'Por la tarde, en el Museo de Navarra, Maren mira la Mano: '
            'lámina de bronce, una inscripción grabada. La cartela trae dos '
            'lecturas: la de 2022 y otra tras limpiar la pieza.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.vozDeFuente,
        texto: 'Las dos no dicen lo mismo. Los expertos no se han puesto de acuerdo.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.vozDeFuente,
        texto: 'Voy a tener que sostener la incertidumbre. No me quiero precipitar.',
      ),
      const PlanoCierreAmable(textoBoton: 'EMPEZAR LA BRECHA'),
    ]),

    // 1.4.3 El gran Concilio — las tres preguntas se contestan eligiendo.
    EscenasArco1.granConcilio.id: _corta(EscenasArco1.granConcilio, [
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'Salón del Concilio. Begoña en cabecera; Isaura, Aitor, '
            'Joana y Karim. Maren presenta de pie su reconstrucción de Irulegi.',
      ),
      // BORRADOR (nuevo): en las tres elecciones la primera opción resume la
      // respuesta de Maren en el guion; la otra es la tentación, y quien
      // pregunta devuelve el criterio.
      const PlanoEleccion(
        voz: VozPersonaje.aitor,
        textoPrompt: 'La adopción incompleta de técnicas romanas. ¿Por qué Probable '
            'y no Sólido?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Porque el enlosado hundido puede tener más de una causa. '
                'Con un solo caso, queda Probable.',
            textoRespuesta: 'Bien.',
            vozRespuesta: VozPersonaje.aitor,
            flagsAEstablecer: {'gran_concilio_aitor_prudente'},
          ),
          OpcionEleccion(
            textoJugador: 'Debería ser Sólido: está claro que no sabían hacerlo.',
            textoRespuesta: '¿Y si fue un hundimiento del terreno? Con un solo caso, '
                'Probable.',
            vozRespuesta: VozPersonaje.aitor,
            flagsAEstablecer: {'gran_concilio_aitor_sobreconfiada'},
          ),
        ],
      ),
      const PlanoEleccion(
        voz: VozPersonaje.joana,
        textoPrompt: 'Las lecturas de la Mano. ¿Por qué Disputada y no «lectura no '
            'establecida»?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Porque sí hay lecturas. Lo que no hay es acuerdo entre '
                'ellas ni entre los expertos.',
            textoRespuesta: 'Distinción correcta.',
            vozRespuesta: VozPersonaje.joana,
            flagsAEstablecer: {'gran_concilio_joana_distingue'},
          ),
          OpcionEleccion(
            textoJugador: 'Porque nadie sabe leerla.',
            textoRespuesta: 'Hay lecturas. Lo que no hay es acuerdo. Eso es Disputado.',
            vozRespuesta: VozPersonaje.joana,
            flagsAEstablecer: {'gran_concilio_joana_confunde'},
          ),
        ],
      ),
      const PlanoEleccion(
        voz: VozPersonaje.karim,
        textoPrompt: 'La Mano sale en actos populares; hay quien se la tatúa. ¿Qué '
            'hace la Cronista con ese peso?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Lo respeta, pero no lo mete en la reconstrucción: habla '
                'del presente, no del siglo I a.C.',
            textoRespuesta: 'Bien.',
            vozRespuesta: VozPersonaje.karim,
            flagsAEstablecer: {'gran_concilio_karim_separa'},
          ),
          OpcionEleccion(
            textoJugador: 'Lo tiene en cuenta: si importa tanto, será por algo.',
            textoRespuesta: 'Eso dice mucho de hoy. De hace dos mil años, no.',
            vozRespuesta: VozPersonaje.karim,
            flagsAEstablecer: {'gran_concilio_karim_mezcla'},
          ),
        ],
      ),
      const PlanoDialogo(
        voz: VozPersonaje.begona,
        texto: '¿No estás confundiendo «contacto romano» con «romanización»?',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.maren,
        texto: 'No lo había pensado así de claro. Probablemente sí lo estoy haciendo.',
      ),
      const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Bien que lo digas.'),
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'Deliberan veinte minutos. Maren espera en el pasillo. Vuelve.',
      ),
      const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Aprendiz I. Bienvenida.'),
      const PlanoCierreAmable(textoBoton: 'SALIR DEL CONCILIO'),
    ]),

    // 1.4.4 Aprendiz I.
    EscenasArco1.aprendizI.id: _corta(EscenasArco1.aprendizI, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'El patio del Archivo. Maren en un banco junto al pozo. '
            'Isaura se sienta a su lado.',
      ),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Has estado bien.'),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Pensaba que iba a hacerlo peor.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Tu peor sigue siendo bueno.'),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Karim me pilló.'),
      const PlanoDialogo(
        voz: VozPersonaje.isaura,
        texto: 'Karim te pilla siempre. Es su trabajo. Pero te ha pillado para '
            'ayudarte a crecer. Lo que viene es Pompelo: el Arco 2.',
      ),
      const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Isaura. Gracias.'),
      const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Mm.'),
      const PlanoAmbiente(duracion: _breve, textoLectura: 'APRENDIZ I'),
      const PlanoCierreAmable(textoBoton: 'CERRAR EL ARCO'),
    ]),

    // 1.Z Cierre del arco.
    EscenasArco1.cierreDelArco.id: _corta(EscenasArco1.cierreDelArco, [
      const PlanoAmbiente(
        duracion: _breve,
        textoLectura: 'Noche de noviembre. Maren en su mesa, el cuaderno abierto.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.vozDeFuente,
        texto: 'Hoy he entregado el Mosaico. Marina dice que ya soy del club.',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.vozDeFuente,
        texto: 'He visto grabados en la roca de hace trece mil años. Begoña no se '
            'rió de mí cuando dije «probablemente sí lo estoy haciendo».',
      ),
      const PlanoDialogo(
        voz: VozPersonaje.vozDeFuente,
        texto: 'El lunes empieza el Arco 2. Vamos a Pompelo, debajo de la calle '
            'Curia. No sé qué voy a encontrar. Pero tengo ganas.',
      ),
      const PlanoAmbiente(
        duracion: _media,
        textoLectura: 'ARCO 1 — CERRADO. Continuará en Arco 2 — La llegada de las '
            'palabras.',
      ),
      const PlanoCierreAmable(textoBoton: 'CERRAR EL CUADERNO'),
    ]),
  };
}
