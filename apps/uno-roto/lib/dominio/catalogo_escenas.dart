import 'escena_cinematica.dart';
import 'escenas_arco_cinco.dart';
import 'plano_escena.dart';
import 'voz_personaje.dart';

/// Catálogo de escenas narrativas implementadas. Las frases provienen
/// del doc 07 (guion Arco 1). Se añaden escenas según la narrativa las
/// requiere.
class CatalogoEscenas {
  /// 1.1 — El tejado. Primer arranque. Sora reconoce al niño, le explica
  /// qué son los Fragmentos, le ofrece entrenar. Doc 07 §1.1.
  static const EscenaCinematica llegada = EscenaCinematica(
    id: '1.1',
    titulo: 'El tejado',
    flagDeSalida: 'escena_1_1_vista',
    sonidoDeEntrada: 'motivo_sora',
    planos: [
      PlanoAmbiente(duracion: Duration(milliseconds: 2200)),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Una azotea. Noche azul-violeta. Viento.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Llegas tarde.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Siempre llegáis tarde.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Sora se gira despacio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '{nombre}, ¿verdad?',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Señala al horizonte. Una montaña oscura.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Eso es la Montaña. Hoy no.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vale. Escucha. No te lo voy a decir dos veces.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Esta ciudad tiene Fragmentos. Se comen cosas que no se ven. Nosotros los cazamos.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Te acabas de alistar. No sabes lo que haces. Tranquilo, nadie lo sabe al principio.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Yo voy a enseñarte.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Vienes a entrenar, o has venido a mirar?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Vengo a entrenar.',
            textoRespuesta: 'Bien.',
            flagsAEstablecer: {'intencion_entrenar'},
          ),
          OpcionEleccion(
            textoJugador: 'No sé muy bien qué hacer.',
            textoRespuesta: 'Ya lo verás. Sígueme.',
            flagsAEstablecer: {'intencion_no_sabe'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale. Sígueme y miras.',
            flagsAEstablecer: {'intencion_silencio'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'AZULA — EDIFICIO DE LOS TEJADOS',
      ),
    ],
  );

  /// 1.2 — La primera ventana. Tutorial: Sora muestra un Pleno y guía al
  /// niño a dividirlo y desfragmentar las mitades. Doc 07 §1.2.
  /// Habilidad introducida: FR.01.
  static const EscenaCinematica primeraVentana = EscenaCinematica(
    id: '1.2',
    titulo: 'La primera ventana',
    flagDeSalida: 'escena_1_2_vista',
    flagsRequeridos: {'escena_1_1_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Una azotea contigua. Algo flota sobre el suelo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Eso.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Eso es un Fragmento. Pequeño. Inofensivo, casi.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Es un Pleno. Vale uno. Un entero. ¿Ves?',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Dividirlo es romperlo en partes iguales. Prueba.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoInteractivo(
        vozInstruccion: VozPersonaje.sora,
        instruccion: 'Desliza el dedo sobre el Pleno.',
        accion: AccionEsperada.dividirPleno,
        estadoInicial: EstadoFragmentoTutorial.plenoCompleto,
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Un medio. Eso es un medio.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoInteractivo(
        vozInstruccion: VozPersonaje.sora,
        instruccion: 'Toca cada mitad para desfragmentarla.',
        accion: AccionEsperada.desfragmentarMitades,
        estadoInicial: EstadoFragmentoTutorial.dosMitades,
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Se llama desfragmentar.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No los matas. Los vuelves al sitio del que salieron.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vamos.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 1.3 — El callejón. Una mujer mayor desorientada delante de una
  /// puerta. Sora explica el efecto residual de los Fragmentos en los
  /// adultos. Doc 07 §1.3.
  static const EscenaCinematica callejon = EscenaCinematica(
    id: '1.3',
    titulo: 'El callejón',
    flagDeSalida: 'escena_1_3_vista',
    flagsRequeridos: {'escena_1_2_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Callejón trasero. Una farola amarilla parpadea.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Un gato cruza. Una mujer mayor, parada frente a una puerta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mira.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Lleva así un rato. No recuerda por qué ha venido.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Eso pasa cuando hay Fragmentos cerca. No muchos. No fuertes. Pero suficientes.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Por eso los cazamos.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'La mujer se va. Se mueve bien. Solo desajustada.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Preguntas?',
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Se va a poner bien?',
            textoRespuesta:
                'Seguramente. Los Fragmentos de aquí son pequeños. Se le pasa en una hora.',
            flagsAEstablecer: {'pregunta_por_mujer'},
          ),
          OpcionEleccion(
            textoJugador: '¿Cuántos Fragmentos hay?',
            textoRespuesta: 'Muchos. Siempre.',
            flagsAEstablecer: {'pregunta_por_cantidad'},
          ),
          OpcionEleccion(
            textoJugador: '¿Ella sabe?',
            textoRespuesta: 'No. Casi nadie sabe.',
            flagsAEstablecer: {'pregunta_por_saber'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vamos. Irune te está esperando.',
            flagsAEstablecer: {'callejon_silencio'},
          ),
        ],
      ),
    ],
  );

  /// 1.4 — Irune. Sala interior, luz cálida. Irune presenta las tres
  /// reglas fundamentales. Doc 07 §1.4.
  static const EscenaCinematica presentacionIrune = EscenaCinematica(
    id: '1.4',
    titulo: 'Irune',
    flagDeSalida: 'escena_1_4_vista',
    flagsRequeridos: {'escena_1_3_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Sala interior. Luz cálida. Libros. Una puerta con la placa ARCHIVO.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Irune sentada. Pelo blanco, chaqueta gris, marca de plata al cuello.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Llegas. Pasa.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Soy Irune. Esta es mi casa, y también la tuya ahora, si te lo tomas en serio.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Sora te va a enseñar. Es la mejor que tengo ahora mismo. No se lo digas.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Sora al fondo mira al suelo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Tres cosas, {nombre}. Escucha.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Primera. Aquí nadie sabe más de lo que sabe. Si alguien te dice que lo sabe todo, desconfía. Aunque sea yo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Segunda. Los Fragmentos no son enemigos. Son pedazos de algo que se rompió. Los desfragmentamos. Eso es todo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Tercera. Si te cansas, paras. Si necesitas irte, te vas. Esto no es una cárcel.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Vete con ella ya. Yo tengo cosas que hacer.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Al salir, Sora casi sin girarse:',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Cae bien, Irune. Cuando quiere.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
    ],
  );

  /// 1.5 — Kurz aparece. Primer Fragmento nombrado con voz propia (en
  /// itálica). Sora lo invoca tras la primera sesión completa. Combate
  /// calibrado a derrota — el cierre emocional es la escena 1.6. Doc 07
  /// §1.5.
  static const EscenaCinematica kurzAparece = EscenaCinematica(
    id: '1.5',
    titulo: 'Kurz aparece',
    flagDeSalida: 'escena_1_5_vista',
    flagsRequeridos: {'escena_1_4_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'De vuelta a la azotea. La noche más cerrada.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mejor.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No tan mal.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vale. Hoy tienes un regalo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Sora silba. Algo grande baja del cielo.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Brazos largos. Cabeza redonda. Ojos. Sobre él, el valor 3/4.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Otro.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Pequeño.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Es Kurz. Lleva aquí más tiempo que yo. Es un Fragmento nombrado. No se disuelve — se retira y vuelve.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Sirve para poneros a prueba. No es malo.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Pero es mejor que tú. Todavía.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: '¿Empezamos?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'El combate llega y se va. No hay forma de ganar hoy.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Muy lento.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Otra vez mal.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Tenías que haberlo visto venir.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Kurz se acerca. Calmo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Ya está. No pasa nada.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 1.6 — La derrota. Cierre emocional tras perder contra Kurz. Primera
  /// media sonrisa de Sora y primera aparición del botón HASTA MAÑANA.
  /// Doc 07 §1.6. Doc 13 storyboard 2.
  static const EscenaCinematica primeraDerrota = EscenaCinematica(
    id: '1.6',
    titulo: 'La derrota',
    flagDeSalida: 'escena_1_6_vista',
    flagsRequeridos: {'combate_kurz_1_completado'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Negro. La azotea vuelve. Sentado en el suelo. Kurz se aleja.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Sora se acerca. Tiende la mano.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'En serio. Bien.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'La primera vez se pierde. Siempre. Yo también perdí contra Kurz mi primera vez.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Y la segunda.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Y la tercera.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura:
            'Primera media sonrisa. Apenas un ángulo de la boca.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'La cuarta gané. Y no se olvida.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Kurz va a volver. Cuando estés listo, vuelves tú a él. Y le ganas.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Lo pillas?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Sí.',
            textoRespuesta: 'Mm.',
            flagsAEstablecer: {'derrota_respuesta_si'},
          ),
          OpcionEleccion(
            textoJugador: '¿Y si no puedo?',
            textoRespuesta: 'Puedes. No hoy. Pero puedes.',
            flagsAEstablecer: {'derrota_respuesta_duda'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale. Vamos a descansar.',
            flagsAEstablecer: {'derrota_respuesta_silencio'},
          ),
        ],
      ),
      PlanoCierreAmable(),
    ],
  );

  /// 1.7 — Kai visto de lejos. Pausa en un punto elevado, Sora señala a
  /// otro aprendiz. Kai asiente sin sonrisa y se va. Doc 07 §1.7.
  /// Cierre amable: al terminar, vuelta al mapa en lugar de encadenar.
  static const EscenaCinematica kaiVistoDeLejos = EscenaCinematica(
    id: '1.7',
    titulo: 'Kai visto de lejos',
    flagDeSalida: 'escena_1_7_vista',
    flagsRequeridos: {'escena_1_6_vista'},
    esCierreAmable: true,
    sonidoDeEntrada: 'motivo_kai',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Otra noche. Punto elevado de la azotea. Otro aprendiz entrena a 30 metros.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Se mueve con soltura. No es el primer día que lo hace.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ese es Kai.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Lleva cuatro años entrenando.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Es bueno.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Kai termina, se echa la mochila al hombro. Pasa cerca.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Asiente a Sora — saludo profesional. A ti te mira un segundo. Sin sonrisa. Registrando.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Sigue bajando.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Él va dos rangos por delante.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Algún día te lo vas a encontrar de verdad.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Sora te ofrece una cantimplora.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bebe. Toca otra ronda.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 1.9 — Los Plenos. Sora introduce el concepto de Impropio sumando
  /// tres medios. Doc 07 §1.9. Requiere `fr_05_competente` — activado por
  /// el motor de maestría cuando el niño domina FR.05 (suma de
  /// fracciones con mismo denominador). Hasta entonces la escena queda
  /// latente en el catálogo.
  static const EscenaCinematica losPlenos = EscenaCinematica(
    id: '1.9',
    titulo: 'Los Plenos',
    flagDeSalida: 'escena_1_9_vista',
    flagsRequeridos: {'escena_1_7_vista', 'fr_05_competente'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Azotea nueva al norte. Cinco Fragmentos orbitan.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Tres medios. Dos tercios. Todos flotando.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mira.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Cuántos medios ves?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Tres.',
            textoRespuesta: 'Bien.',
            flagsAEstablecer: {'plenos_respuesta_correcta'},
          ),
          OpcionEleccion(
            textoJugador: 'Cinco.',
            textoRespuesta:
                'No. Cinco son todos. Tres son los medios. Otra vez.',
            flagsAEstablecer: {'plenos_respuesta_incorrecta'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Si sumas los tres medios...',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '¿Cuánto tienes?',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'Los tres medios se fusionan. 3/2. Se desborda.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Tres medios. Más de uno entero.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Cuando pasa de uno, se llama impropio.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Son más grandes. Más trabajo.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Pero aún no. Hoy, solo practica la suma.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 1.11 — La cena que no se ve. Plaza pequeña, mesa fuera de un bar
  /// cerrado pero iluminado. Sora y el jugador comen en silencio. Doc 07
  /// §1.11. Cierre amable: termina en silencio, deja respiración.
  static const EscenaCinematica laCena = EscenaCinematica(
    id: '1.11',
    titulo: 'La cena que no se ve',
    flagDeSalida: 'escena_1_11_vista',
    flagsRequeridos: {'escena_1_7_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Plaza pequeña. Mesa fuera de un bar cerrado pero iluminado.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Come.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Mastican en silencio. Una pareja pasa riéndose. Sora los mira un instante.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No todo es entrenar.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Aunque lo parezca.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura: 'Sora termina antes. Mira al cielo. Dos lunas.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Las dos esta noche.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Y cuando no están las dos?',
            textoRespuesta: 'Eso es otro tema. Come.',
            flagsAEstablecer: {'cena_pregunta_lunas'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta:
                'Vamos. Duermes mucho mejor si entrenas antes.',
            flagsAEstablecer: {'cena_silencio'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Deja unas monedas en la mesa al levantarse.',
      ),
    ],
  );

  /// 1.10pre — Kurz vuelve. Cinemática breve antes del segundo combate.
  /// Doc 07 §1.10. Se dispara cuando el niño ya pasó la cena (proxy de
  /// "tras 2-3 entrenamientos").
  static const EscenaCinematica kurzVuelve = EscenaCinematica(
    id: '1.10pre',
    titulo: 'Kurz vuelve',
    flagDeSalida: 'escena_1_10_pre_vista',
    flagsRequeridos: {'escena_1_11_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'La azotea otra vez. Otra noche. Sora silba.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Kurz baja del cielo. Más grande. Sobre él, el valor 5/6.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Otra vez.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'A ver.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 1.10cierre (derrota) — frase corta, mano de Sora un instante.
  /// Doc 07 §1.10 rama "Si pierde".
  static const EscenaCinematica kurzVuelveDerrota = EscenaCinematica(
    id: '1.10derrota',
    titulo: 'Kurz vuelve — cierre derrota',
    flagDeSalida: 'escena_1_10_resuelta',
    flagsRequeridos: {'derrota_kurz_2'},
    esCierreAmable: true,
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Casi.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Otra vez la semana que viene.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Has durado más.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bastante más.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Sora pone la mano en tu hombro un instante. La aparta rápido.',
      ),
    ],
  );

  /// 1.10cierre (victoria) — raro pero posible. Doc 07 §1.10 rama
  /// "Si gana".
  static const EscenaCinematica kurzVuelveVictoria = EscenaCinematica(
    id: '1.10victoria',
    titulo: 'Kurz vuelve — cierre victoria',
    flagDeSalida: 'escena_1_10_resuelta',
    flagsRequeridos: {'victoria_kurz_2'},
    esCierreAmable: true,
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Vaya.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Tú ya eres otra cosa.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Has ganado.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No suelen ganar la segunda.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Irune querrá verte.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 1.12pre — Hoy. Doc 07 §1.12. Sora declara que el niño está listo,
  /// silba, Kurz baja por última vez. La azotea está al atardecer
  /// (única escena con luz distinta). Se dispara tras la 1.10 resuelta.
  static const EscenaCinematica kurzVencidoPre = EscenaCinematica(
    id: '1.12pre',
    titulo: 'Hoy',
    flagDeSalida: 'escena_1_12_pre_vista',
    flagsRequeridos: {'escena_1_10_resuelta'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'La azotea al atardecer. Por primera vez no es de noche.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Hoy.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Hoy estás listo.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Silba. Kurz baja. La azotea tiembla un poco. 7/8 sobre él.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Ah.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Te noto distinto.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Vamos.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 1.12cierre (victoria) — esperado. Doc 07 §1.12. Activa
  /// `escena_1_12_vista` para que la 1.13 ceremonia se dispare.
  static const EscenaCinematica kurzVencidoVictoria = EscenaCinematica(
    id: '1.12victoria',
    titulo: 'Kurz vencido',
    flagDeSalida: 'escena_1_12_vista',
    flagsRequeridos: {'victoria_kurz_3'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'Kurz se hace pequeño. Sube despacio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Nos veremos cuando seas Iniciado.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Sora asiente una vez, muy despacio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ya está.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ya eres algo más que un aprendiz.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Mira hacia la puerta. Irune está ahí. Asiente de lejos. Entra.',
      ),
    ],
  );

  /// 1.12cierre (derrota) — el niño aún no estaba listo. Vuelve a casa
  /// sin avance. Tendrá que rejugarlo otra vez (en el prototipo basta
  /// con activar el mismo flag combate_kurz_3_completado para volver a
  /// disparar el combate la próxima sesión... no implementado todavía).
  static const EscenaCinematica kurzVencidoDerrota = EscenaCinematica(
    id: '1.12derrota',
    titulo: 'Hoy aún no',
    flagDeSalida: 'escena_1_12_derrota_vista',
    flagsRequeridos: {'derrota_kurz_3'},
    esCierreAmable: true,
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.fragmentoKurz,
        texto: 'Otra vez. La semana que viene.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mañana.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Estabas cerca.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 1.13 — Las palabras de Irune. Ceremonia de Aprendiz II. Doc 07
  /// §1.13. Latente hasta que el jugador derrote a Kurz por segunda vez
  /// (`escena_1_12_vista`) y haya alcanzado el rango Aprendiz II.
  static const EscenaCinematica palabrasDeIrune = EscenaCinematica(
    id: '1.13',
    titulo: 'Las palabras de Irune',
    flagDeSalida: 'escena_1_13_vista',
    loopDeFondo: 'musica_ceremonia',
    flagsRequeridos: {
      'escena_1_12_vista',
      'rango_aprendiz_ii_alcanzado',
    },
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'La sala de Irune. La luz más cálida que la primera vez.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Siéntate.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'No te voy a felicitar. Sora tampoco. No es nuestro estilo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Pero lo que has hecho es real.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'La gente habla de rangos como si fueran diplomas. No lo son. Son responsabilidades.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Ahora eres Aprendiz II. Eso quiere decir que puedes salir del Edificio de los Tejados sin que Sora vaya detrás.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Vas a hacerte amigos, enemigos, dudas. Sobre todo dudas.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Mañana puedes bajar a los Canales. Si quieres. O no. Tú decides.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Y una cosa más.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Hace mucho que no ponía una marca de Aprendiz II.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Silencio. Irune deja respirar la frase un momento largo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Me alegro de que vuelva a haber alguien que la merezca.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Te pone una marca plateada al cuello. Una cuerda fina. Frío al principio, luego templada.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bienvenido, Aprendiz II.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Ya puedes irte. Duerme.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoCierreAmable(),
    ],
  );

  /// 1.14 — Los Canales desde arriba. Cierre del Arco I. Doc 07 §1.14.
  /// Sora regala su brújula vieja al jugador (objeto narrativo que
  /// reaparecerá en el Arco IV).
  static const EscenaCinematica canalesDesdeArriba = EscenaCinematica(
    id: '1.14',
    titulo: 'Los Canales desde arriba',
    flagDeSalida: 'escena_1_14_vista',
    flagsRequeridos: {'escena_1_13_vista'},
    esCierreAmable: true,
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Borde de la azotea. Sora sentada con las piernas colgando, sin miedo. Mira al norte.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Abajo, los Canales: puentes pequeños iluminados, reflejos amarillos en el agua. Una ciudad dentro de la ciudad.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Siéntate.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Allí vas a ir mañana.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Los Canales.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Maestro Rexán.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Va a caerte bien. Es el tipo más simpático de la orden. No te fíes del todo — lo usa.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Tiene una cojera. No preguntes por ella.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Algún día te lo contará. O no. Ya verás.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Tienes que ir solo. Yo te esperaré aquí.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Sí. Solo.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No te asustes. Rexán es buena gente. Y tú ya no eres tan nuevo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Sora saca una pequeña brújula de bolsillo. No mágica. Solo una brújula.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Toma. Era mía cuando empecé aquí.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Devuélvemela cuando vuelvas.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Mira otra vez hacia los Canales. Viento. Fundido lento.',
      ),
      PlanoCierreAmable(textoBoton: 'HASTA MAÑANA'),
    ],
  );

  // ============================================================
  // Arco 2 — Canales y Zafrán. Doc 08.
  // ============================================================

  /// 2.1 — Bajar solo. Sora despide al jugador en la escalera del
  /// Edificio de los Tejados. Primera vez que va por la ciudad sin ella.
  /// Doc 08 §2.1.
  static const EscenaCinematica bajarSolo = EscenaCinematica(
    id: '2.1',
    titulo: 'Bajar solo',
    flagDeSalida: 'escena_2_1_vista',
    flagsRequeridos: {'escena_1_14_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Escalera que baja del Edificio de los Tejados. Niebla baja en las calles.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ya.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vete.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Si te pasa algo, vuelves corriendo. No te hagas el valiente.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Y si tardas mucho, voy yo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Calles estrechas. Una pareja en un portal. Un gato dormido. Un Fragmento tonto se disuelve solo.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'La luz cambia — más amarilla. El agua aparece entre las piedras.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'BARRIO DE LOS CANALES',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Al otro lado de un puente, un hombre mayor sentado en un saliente. Lee. Levanta la vista. Sonríe.',
      ),
    ],
  );

  /// 2.2 — Rexán. Primer encuentro con el Maestro de los Canales.
  /// Introduce la equivalencia de fracciones (FR.09). Doc 08 §2.2.
  static const EscenaCinematica conocerARexan = EscenaCinematica(
    id: '2.2',
    titulo: 'Rexán',
    flagDeSalida: 'escena_2_2_vista',
    flagsRequeridos: {'escena_2_1_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Se levanta. Cojea. No lo esconde ni lo señala.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'A ver, a ver.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Primera sonrisa abierta de un adulto en el juego.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Tú eres el que Sora manda.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Tiende la mano.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Rexán. Maestro de los Canales, dicen. Yo me llamo Rexán. Sin más.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Tú ya sabes lo que es un Fragmento. Sabes sumar trozos cuando son iguales. Ya eres Aprendiz II. No está mal.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Aquí vas a aprender algo distinto.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Señala el canal. Dos Fragmentos flotan sobre el agua: 1/2 y 2/4.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.rexan,
        textoPrompt: '¿Cuál es más grande?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'El segundo.',
            textoRespuesta:
                'Mm. ¿Seguro? Míralos otra vez. Mira el agua.',
            flagsAEstablecer: {'rexan_equivalencia_error'},
          ),
          OpcionEleccion(
            textoJugador: 'El primero.',
            textoRespuesta:
                'Mm. ¿Seguro? Míralos otra vez. Mira el agua.',
            flagsAEstablecer: {'rexan_equivalencia_error'},
          ),
          OpcionEleccion(
            textoJugador: 'Son iguales.',
            textoRespuesta: 'Bien, {nombre}. Bien.',
            flagsAEstablecer: {'rexan_equivalencia_acierto'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Los dos Fragmentos orbitan despacio y se fusionan en uno.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Son la misma cosa. Con nombres distintos.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Un medio. Dos cuartos. Mismo trozo de mundo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Eso se llama equivaler.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Toda verdad tiene otra forma igualmente verdadera.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Es lo que aprendes aquí. Lo demás viene después.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Vamos. Te enseño el barrio.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 2.3 — El primer Fragmento Espejo. Tutorial narrativo de familia D
  /// (Espejo) + mecánica de emparejar por equivalencia. La mecánica
  /// real se experimenta en el cazadero libre. Doc 08 §2.3.
  static const EscenaCinematica primerEspejo = EscenaCinematica(
    id: '2.3',
    titulo: 'El primer Fragmento Espejo',
    flagDeSalida: 'escena_2_3_vista',
    flagsRequeridos: {'escena_2_2_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Callejón junto al canal. Dos Fragmentos emergen a la vez, con el mismo halo: 3/4 y 6/8.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Fragmentos Espejo.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Se llaman así porque van en pareja. Uno parece el reflejo del otro.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Y casi siempre lo es.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Míralos bien, {nombre}. ¿Son equivalentes?',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Tres de cuatro. Seis de ocho. Simplifica seis de ocho y tienes tres de cuatro.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Cuando encuentres dos así, los emparejas y se disuelven juntos. Es el gesto más limpio que puedes hacer.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'A veces no son equivalentes. Entonces tienes que reconocerlo y atacar por separado. No pasa nada.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Si los emparejas mal, hacen ruido. Los oyes.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Te guiña un ojo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Vas a aprender a oírlos.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 2.5 — Una pintada rara. Primera semilla visible del conflicto de
  /// los Opacos. Rexán la esquiva sin miedo, con cansancio. Doc 08
  /// §2.5. Canónicamente aleatoria; aquí se encadena tras 2.3 para
  /// asegurar exposición.
  static const EscenaCinematica pintadaRara = EscenaCinematica(
    id: '2.5',
    titulo: 'Una pintada rara',
    flagDeSalida: 'escena_2_5_vista',
    flagsRequeridos: {'escena_2_3_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Callejón. Pared vieja con una pintada reciente: un círculo roto con cuatro líneas hacia fuera.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Debajo, en letra temblorosa: "El uno era la cárcel."',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Vámonos, {nombre}.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.rexan,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Qué es esto?',
            textoRespuesta: 'Pintadas. No importantes.',
            flagsAEstablecer: {'pintada_preguntado_que'},
          ),
          OpcionEleccion(
            textoJugador: '¿Por qué dice eso?',
            textoRespuesta: 'Porque algunos piensan así. Vamos.',
            flagsAEstablecer: {'pintada_preguntado_porque'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vamos.',
            flagsAEstablecer: {'pintada_silencio'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'No gira la cabeza hacia la pintada. Su voz no tiene miedo. Tiene cansancio.',
      ),
    ],
  );

  /// 2.6 — La primera vez que Zafrán se menciona. Latente: requiere que
  /// el motor active `fr_09_competente`. Doc 08 §2.6.
  static const EscenaCinematica zafranMencionado = EscenaCinematica(
    id: '2.6',
    titulo: 'La primera vez que Zafrán se menciona',
    flagDeSalida: 'escena_2_6_vista',
    flagsRequeridos: {'escena_2_5_vista', 'fr_09_competente'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Terraza de un bar cerrado. Sillas apiladas. Dos monedas antiguas en la mesa.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Oye.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: '¿Sora te ha hablado de Zafrán alguna vez?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Niegas con la cabeza.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Bueno. Yo te digo el nombre al menos.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Es un Fragmento grande. Muy viejo. Vive por aquí.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Ahora mismo no te preocupes de él. No te va a ver. No te tiene que ver.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Pero si alguna vez oyes un silbido largo y raro por la noche, de los canales... te vuelves al Edificio de los Tejados.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.rexan,
        textoPrompt: 'Sin pensarlo. ¿De acuerdo?',
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Por qué?',
            textoRespuesta:
                'Porque sí. Confía en mí una vez y hazme caso. Solo una vez.',
            flagsAEstablecer: {'zafran_preguntado_porque'},
          ),
          OpcionEleccion(
            textoJugador: 'Vale.',
            textoRespuesta: 'Bien. Gracias.',
            flagsAEstablecer: {'zafran_acepta'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: '¿Has visto la luna esta noche? Solo una. Qué pena.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
    ],
  );

  /// 2.7 — Un Dual en el puente. Tutorial narrativo de familia F
  /// (Duales) y MCM (DIV.07). Latente: requiere motor activando
  /// `fr_16_introducida`. Doc 08 §2.7.
  static const EscenaCinematica dualEnPuente = EscenaCinematica(
    id: '2.7',
    titulo: 'Un Dual en el puente',
    flagDeSalida: 'escena_2_7_vista',
    flagsRequeridos: {'escena_2_6_vista', 'fr_16_introducida'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Puente grande. Niebla leve. Dos Fragmentos flotan unidos por una línea de luz densa: 1/3 y 1/4.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Duales.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Esto es lo nuevo. Esto es lo que querías ver.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Con los Duales, no puedes atacar a uno solo. Están enganchados.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Tienes que unirlos primero. Volverlos un solo Fragmento. Y entonces los atacas.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Para unirlos, tienen que hablar el mismo idioma. Mismo denominador.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Un tercio y un cuarto no hablan el mismo idioma. Mira.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Los Fragmentos se rozan. Un chirrido desagradable. Rebotan.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: '¿Lo oyes? Así suena cuando los unes mal.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Busca un número que sea múltiplo de los dos. De tres y de cuatro.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Doce. 1/3 se vuelve 4/12. 1/4 se vuelve 3/12. Se funden en 7/12.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Doce es lo más pequeño que los dos comparten. Se llama mínimo común múltiplo. MCM, para ir rápido.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Ahora ya es un Fragmento normal. Atácalo.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Rexán sonríe de medio lado.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Esto es lo más bonito que se aprende aquí.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'En serio. Cuando esto lo tienes, el resto es juego.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 2.8 — Rexán y el agua. Muelle pequeño, silencio largo. Rexán
  /// menciona a Oryn y su herida vieja. "El mar acuerda. Los canales
  /// olvidan." Doc 08 §2.8.
  static const EscenaCinematica rexanYElAgua = EscenaCinematica(
    id: '2.8',
    titulo: 'Rexán y el agua',
    flagDeSalida: 'escena_2_8_vista',
    flagsRequeridos: {'escena_2_7_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Muelle pequeño al borde de un canal ancho. Pies casi tocando el agua.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Un minuto de silencio. Solo el agua.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Yo me formé en el Puerto, ¿sabes?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Oryn me entrenó. Hace muchos años. Él era joven todavía, como Sora ahora.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Desde entonces, el agua me gusta.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Tira una piedrita al agua.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Cuando me pasó lo de la pierna, hace ya, volví al Puerto a recuperar.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Estuve un año entero viendo el agua desde un muelle como este.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Cuando pude caminar otra vez, me preguntaron si quería volver a ser Maestro.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Les dije que sí, pero aquí, en los Canales. Porque los canales tienen agua también, y no son el mar.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'El mar acuerda. Los canales olvidan.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Eso no lo entiendes todavía. No importa.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoEleccion(
        voz: VozPersonaje.rexan,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Qué te pasó?',
            textoRespuesta: 'Otro día, {nombre}. Hoy no.',
            flagsAEstablecer: {'rexan_pregunta_pierna'},
          ),
          OpcionEleccion(
            textoJugador: '¿Sora conoce a Oryn?',
            textoRespuesta:
                'Sora no baja al Puerto. No le gusta el agua. Aún.',
            flagsAEstablecer: {'rexan_pregunta_sora_oryn'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            flagsAEstablecer: {'rexan_silencio_agua'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Tira otra piedrita. Se levanta apoyándose en el bastón.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Venga. Antes de que nos durmamos los dos.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 2.9 — Ari. Primer encuentro con otra aprendiz. 12 años,
  /// discípula de Vadic. Doc 08 §2.9.
  static const EscenaCinematica conocerAAri = EscenaCinematica(
    id: '2.9',
    titulo: 'Ari',
    flagDeSalida: 'escena_2_9_vista',
    flagsRequeridos: {'escena_2_8_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Esquina cerca del Edificio de los Tejados. Una chica de tu edad, mochila cruzada.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Hola.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: '¿Tú también eres nuevo?',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Soy Ari. Llegué hace seis meses.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.ari,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Yo soy {nombre}.',
            textoRespuesta: 'Mm.',
            flagsAEstablecer: {'ari_presentado'},
          ),
          OpcionEleccion(
            textoJugador: '— solo asentir —',
            textoRespuesta: 'Poco hablador, tú. Me gusta.',
            flagsAEstablecer: {'ari_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Oye. Estoy con el Maestro Vadic. Industria. ¿Tú?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.ari,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Con Rexán, de Canales.',
            textoRespuesta:
                'Ah, Rexán. Me cae bien. Luego te caerá a ti.',
            flagsAEstablecer: {'ari_sabe_rexan'},
          ),
          OpcionEleccion(
            textoJugador: 'No lo sé todavía.',
            textoRespuesta:
                'Vale, vale, no preguntaba por preguntar. Solo curiosidad.',
            flagsAEstablecer: {'ari_no_sabe'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'Bueno. Me tengo que ir. Mis padres no saben que ando por aquí a esta hora.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Nos vemos por los tejados.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Echa a correr. Se gira al correr:',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'No te metas con los Espejo los lunes, eh. No sé por qué pero los lunes son raros.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 2.10 — El silbido lejano. Rexán lo oye, se queda quieto, manda
  /// al Edificio de los Tejados. Sora espera al jugador con "Pasa.
  /// Irune quiere verte." LATENTE: requiere `fr_16_competente`.
  /// Doc 08 §2.10.
  static const EscenaCinematica silbidoLejano = EscenaCinematica(
    id: '2.10',
    titulo: 'El silbido lejano',
    flagDeSalida: 'escena_2_10_vista',
    sonidoDeEntrada: 'narrativo_silbido_zafran',
    flagsRequeridos: {'escena_2_9_vista', 'fr_16_competente'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Mitad de un entrenamiento con Rexán. Un silbido largo y grave rompe el aire.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Tres segundos. Un quiebro extraño al final. Ni pájaro ni sirena.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Rexán se queda completamente quieto. Deja caer el bastón sin darse cuenta. Lo recoge despacio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Se acabó por hoy.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Intenta sonreír. No lo consigue del todo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Vete al Edificio de los Tejados. Ahora. Despacio pero ya.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Y no pasas por la calle del mercado nocturno.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Dile a Irune que he oído a Zafrán.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Se va en dirección contraria. La cojera se nota más. Calles silenciosas. Puestos cerrando antes. Ventanas apagándose al pasar.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Al subir al Edificio, Sora en la puerta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Pasa. Irune quiere verte.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 2.11 — Sora vuelve a bajar. Amanecer, Sora con bolsa cruzada, va
  /// contigo al combate. Doc 08 §2.11.
  static const EscenaCinematica soraVuelveABajar = EscenaCinematica(
    id: '2.11',
    titulo: 'Sora vuelve a bajar',
    flagDeSalida: 'escena_2_11_vista',
    flagsRequeridos: {'escena_2_10_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Azotea al amanecer. Sora con cazadora gruesa y una bolsa pequeña cruzada al cuerpo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Hoy voy contigo.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No al entrenamiento. Al combate.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Rexán no puede. No debe. Así que voy yo.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Irune aparece en la puerta sin cruzar. Asiente a Sora. Desaparece.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Zafrán es un Fragmento Dual muy viejo. Enorme. Vive entre los canales, en la zona más profunda del distrito.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'No ataca todo el tiempo. A veces está dormido años. Y de vez en cuando sale.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'La última vez fue hace dos semanas. Un ruido en el mercado. No fue mucho. Rexán lo contuvo.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'La anterior, hace veinte años, le dejó la pierna como la tiene.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Esta no la aguanta solo. Irune no quiere que vaya él. Voy yo.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Y tú.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Primera mirada sin distancia.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'No porque seas bueno. Porque es tu distrito ahora. Tienes que verlo con tus ojos.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Te quedas atrás. Atacas cuando te digo. No haces nada que no te diga.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Vale?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Vale.',
            textoRespuesta: 'Mm.',
            flagsAEstablecer: {'sora_zafran_asiento'},
          ),
          OpcionEleccion(
            textoJugador: '¿Voy a estar bien?',
            textoRespuesta: 'Mientras me hagas caso, sí.',
            flagsAEstablecer: {'sora_zafran_miedo'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale. Vamos.',
            flagsAEstablecer: {'sora_zafran_silencio'},
          ),
        ],
      ),
    ],
  );

  /// 2.12 — La noche de Zafrán. Pre-combate. Plaza del pozo. Marca
  /// vieja de Sora. "Esta es por Rexán." Al terminar esta cinemática,
  /// el orquestador lanzará el combate jugable de Zafrán (pendiente).
  /// Doc 08 §2.12.
  static const EscenaCinematica nocheDeZafran = EscenaCinematica(
    id: '2.12',
    titulo: 'La noche de Zafrán',
    flagDeSalida: 'escena_2_12_vista',
    flagsRequeridos: {'escena_2_11_vista'},
    sonidoDeEntrada: 'narrativo_silbido_zafran',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'La parte más profunda y vieja del Barrio. Plaza circular pequeña. Pozo viejo de piedra cubierto con reja oxidada.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Aquí.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Sale de ahí.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Cuando salga, será grande. Más que todo lo que has visto.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Va a tener dos valores distintos. Denominadores diferentes. Tú y yo los vamos a fusionar.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Yo uno. Tú otro.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Como en los puentes con Rexán.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Si fallas, no pasa nada. Yo fusiono los dos. Pero va a tardar más. Y va a doler más.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Atrás.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'La reja tiembla. Salta. Emerge Zafrán: altura de una casa, dos cuerpos conectados por una línea de luz densa.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Izquierdo 5/7. Derecho 3/11. Cuerpo agrietado en patrones viejos.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Un sonido vibrante hace temblar las piedras. La respiración de Sora se acelera. Rabia, no miedo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Hola, Zafrán.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Sí. Me acuerdo.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Saca una marca pequeña del bolsillo. Vieja. Oxidada. Distinta de la del cuello. La aprieta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Esta es por Rexán.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 2.13 — Tras el combate. Zafrán escapa debilitado al pozo. "Se va.
  /// Otra vez. Pero le hemos hecho daño. Lo has hecho bien. Muy bien,
  /// {nombre}." Doc 08 §2.13 (parte post-combate). Primera vez que
  /// Sora usa "muy" en el juego.
  static const EscenaCinematica zafranEscapa = EscenaCinematica(
    id: '2.13',
    titulo: 'Zafrán escapa',
    flagDeSalida: 'escena_2_13_vista',
    flagsRequeridos: {'combate_zafran_completado'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Zafrán se hace pequeño. Al llegar a 1/16, escapa al pozo con un chirrido. La reja cae con un golpe seco.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Silencio. Sora se limpia la cara con el dorso de la mano.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Se va.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Otra vez.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Pero le hemos hecho daño.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Algo en su cara más abierto que nunca lo has visto.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Lo has hecho bien.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Muy bien, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 2.14 — Después. Sora sentada, golpe en la pierna. Saca otra
  /// marca vieja y revela que era de su maestra anterior. Doc 08 §2.14.
  static const EscenaCinematica despuesDeZafran = EscenaCinematica(
    id: '2.14',
    titulo: 'Después',
    flagDeSalida: 'escena_2_14_vista',
    flagsRequeridos: {'escena_2_13_vista'},
    sonidoDeEntrada: 'motivo_sora',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Sora sentada en el suelo contra el pozo. Mano en la rodilla izquierda.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No es grave.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Solo el golpe. Mañana estará.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Saca la pequeña marca vieja. La mira. La aprieta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Esta era de alguien.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'De mi maestra. Antes de Irune.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Qué le pasó?',
            textoRespuesta:
                'Lo mismo que a Rexán, más o menos. Peor.',
            flagsAEstablecer: {'sora_maestra_pregunta_que'},
          ),
          OpcionEleccion(
            textoJugador: '¿Fue Zafrán?',
            textoRespuesta:
                'No. Eso fue otra cosa. Otra ciudad.',
            flagsAEstablecer: {'sora_maestra_pregunta_zafran'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte con ella en silencio —',
            textoRespuesta: 'Gracias.',
            flagsAEstablecer: {'sora_maestra_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ayúdame a levantarme.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Acepta tu mano más tiempo del necesario. Cojea dos o tres pasos. Recupera su ritmo.',
      ),
    ],
  );

  /// 2.15 — Rexán espera. Al volver, marca plateada con un nuevo
  /// filete azul. Rexán abre el cuello: su marca tiene varios
  /// filetes. Doc 08 §2.15.
  static const EscenaCinematica rexanEspera = EscenaCinematica(
    id: '2.15',
    titulo: 'Rexán espera',
    flagDeSalida: 'escena_2_15_vista',
    flagsRequeridos: {'escena_2_14_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Al volver al Edificio de los Tejados, Rexán está apoyado en el muro de la entrada con el bastón.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Sora se queda atrás dando espacio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'A ver. Enséñame.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Enseñas la marca de Aprendiz II. Tiene ahora un pequeño filete azul — señal de haber sobrevivido a un combate con un Fragmento nombrado.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Bonita.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'La mía también la tiene.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Se abre el cuello. Su marca con varios filetes azules, algunos viejos, uno muy desteñido.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Gracias.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Sora.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Rexán.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Sube. Irune quiere verte.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Y duerme, {nombre}. Mañana es otro día y hoy ya estuvo.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Al entrar, Rexán y Sora se quedan fuera juntos. Sin hablar. Solo estando.',
      ),
    ],
  );

  /// 2.16 — Los Canales en silencio. Cierre del Arco 2. Sora menciona
  /// su ciudad sin cortar. "Aún." Doc 08 §2.16.
  static const EscenaCinematica canalesEnSilencio = EscenaCinematica(
    id: '2.16',
    titulo: 'Los Canales en silencio',
    flagDeSalida: 'escena_2_16_vista',
    flagsRequeridos: {'escena_2_15_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Azotea. Borde norte. Sora con las piernas colgando, como al final del Arco 1. La niebla disipada, luces reflejadas en el agua.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Un minuto de silencio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Oye.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Cuando era pequeña, en mi ciudad...',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '...tenía una ventana que daba a un canal.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Se parece a estos.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Mirada breve. Vuelve al paisaje. Primera vez que menciona su ciudad sin cortar.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No es importante. No sé por qué lo he dicho.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Mañana, si quieres, puedes bajar al Mercado. Conocer a Naini.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Yo no voy. Ella y yo ya nos conocemos.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Pero tú vas a querer ir. Te va a caer bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'La ciudad ya es tuya. Todos los distritos.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bueno. Casi todos. La Montaña no.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Segunda media sonrisa de Sora.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Aún.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoCierreAmable(textoBoton: 'HASTA MAÑANA'),
    ],
  );

  // ============================================================
  // Arco 3 — La ciudad entera. Doc 09.
  // ============================================================

  /// 3.1 — Naini. Entrada al Mercado de la Luz. Primera maestra que
  /// saluda con alegría explosiva. Introduce proporciones y porcentajes
  /// como "valor en circulación". Doc 09 §3.1.
  static const EscenaCinematica conocerANaini = EscenaCinematica(
    id: '3.1',
    titulo: 'Naini',
    flagDeSalida: 'escena_3_1_vista',
    flagsRequeridos: {'escena_2_16_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Portón alto iluminado. Una explosión de luz, sonido y olor al cruzarlo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: '¡Qué bueno verte!',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Soy Naini. Maestra del Mercado. Aunque aquí casi todos me llaman Naini a secas.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Iniciado, ¿eh? Pues venga. Pasa, pasa. Te cuento.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Fragmentos silvestres flotan entre la gente sin alarma.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'El Mercado es distinto. Aquí los Fragmentos no son enemigos todo el rato. Son valor en circulación.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.naini,
        textoPrompt: '¿Tú has hecho alguna vez un trueque?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Sí.',
            textoRespuesta: 'Vale. Entonces ya medio entiendes.',
            flagsAEstablecer: {'naini_trueque_si'},
          ),
          OpcionEleccion(
            textoJugador: 'No.',
            textoRespuesta: 'Pues lo vas a hacer hoy.',
            flagsAEstablecer: {'naini_trueque_no'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Aquí se cambia una cosa por otra. Un Fragmento por tres. Tres por uno. Porcentajes. Proporciones. Eso es lo que vas a aprender aquí.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Y también vas a aprender a distinguir un trueque honesto de uno que no lo es.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Pero eso ya es más adelante. Ven.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
    ],
  );

  /// 3.2 — El Mercado de la Luz. Tutorial narrativo de proporciones
  /// y porcentajes con manzanas. Doc 09 §3.2.
  static const EscenaCinematica mercadoDeLaLuz = EscenaCinematica(
    id: '3.2',
    titulo: 'El Mercado de la Luz',
    flagDeSalida: 'escena_3_2_vista',
    flagsRequeridos: {'escena_3_1_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Puesto grande de frutas. 15 manzanas rojas y 10 amarillas.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.naini,
        textoPrompt:
            'Si te llevas un tercio de las rojas y la mitad de las amarillas, ¿cuántas en total?',
        opciones: [
          OpcionEleccion(
            textoJugador: '8.',
            textoRespuesta: 'No. Un tercio de 15 son 5. La mitad de 10 son 5.',
            flagsAEstablecer: {'mercado_fallo_1'},
          ),
          OpcionEleccion(
            textoJugador: '10.',
            textoRespuesta: 'Justo. 5 y 5.',
            flagsAEstablecer: {'mercado_acierto_1'},
          ),
          OpcionEleccion(
            textoJugador: '12.',
            textoRespuesta:
                'Demasiadas. Un tercio de 15 son 5. La mitad de 10 son 5.',
            flagsAEstablecer: {'mercado_fallo_1'},
          ),
        ],
      ),
      PlanoEleccion(
        voz: VozPersonaje.naini,
        textoPrompt:
            '¿Y qué porcentaje del total son tus 10 manzanas? El total era 25.',
        opciones: [
          OpcionEleccion(
            textoJugador: '25%.',
            textoRespuesta: 'No. 10 de 25. Diez de veinticinco.',
            flagsAEstablecer: {'mercado_fallo_2'},
          ),
          OpcionEleccion(
            textoJugador: '40%.',
            textoRespuesta: '40%. Justo.',
            flagsAEstablecer: {'mercado_acierto_2'},
          ),
          OpcionEleccion(
            textoJugador: '50%.',
            textoRespuesta: 'Casi. 10 de 25 no es la mitad.',
            flagsAEstablecer: {'mercado_fallo_2'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Te pone dos manzanas en la mano. Le guiña un ojo a la vendedora.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Aquí nadie te enseña nada gratis. Pero todo se aprende.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Esa es la regla del Mercado. Nada gratis. Pero todo posible.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
    ],
  );

  /// 3.3 — Kai otra vez. Plaza lateral del Mercado. Kai propone
  /// duelo amistoso. Doc 09 §3.3. Al terminar esta cinemática, el
  /// orquestador lanza el duelo jugable.
  static const EscenaCinematica kaiOtraVez = EscenaCinematica(
    id: '3.3',
    titulo: 'Kai otra vez',
    flagDeSalida: 'escena_3_3_vista',
    flagsRequeridos: {'escena_3_2_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Plaza lateral del Mercado. Kai. Más filetes azules en su marca de Aprendiz.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Hombre.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Me dijeron que habías bajado a ver a Naini.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Interesante.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.kai,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Vivo. Como ves. Tú también, ¿no?',
            textoRespuesta: 'Mm.',
            flagsAEstablecer: {'kai_cordial'},
          ),
          OpcionEleccion(
            textoJugador: 'No te me pongas raro, Kai.',
            textoRespuesta: 'Oye, oye, tranquilo. Solo te saludaba.',
            flagsAEstablecer: {'kai_directo'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale. Tú mandas.',
            flagsAEstablecer: {'kai_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Oye. He oído lo de Zafrán.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto:
            'No todo el mundo sobrevive a su primer Fragmento nombrado.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Yo conmigo el mío... todavía no lo vi.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Bueno. Es lo que hay.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto:
            'Si un día te aburres de entrenar con señores mayores, podemos combatir.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Tú contra mí. Nada oficial. Solo para ver.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
    ],
  );

  /// 3.5 — Kai desaparece. Ari se acerca tras el duelo, explica a
  /// Kai. Primer elogio directo en el juego. Doc 09 §3.5.
  static const EscenaCinematica kaiDesaparece = EscenaCinematica(
    id: '3.5',
    titulo: 'Kai desaparece',
    flagDeSalida: 'escena_3_5_vista',
    flagsRequeridos: {'combate_duel_kai_completado'},
    esCierreAmable: true,
    sonidoDeEntrada: 'motivo_kai',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Ari se acerca. Kai ya no está. Te ofrece un refresco.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Toma.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'No te va a hablar en un tiempo.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Es así.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'Cuando yo le gané a Elen hace tres meses, estuvo desaparecida dos semanas. Ahora somos colegas.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Déjale espacio.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'Tengo que volver con Vadic. Industria. Si bajas alguna vez, me avisas.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Se gira al irse.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Por cierto, has estado bien.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
    ],
  );

  /// 3.6 — Vadic. Entrada a Industria. Maestro que mide con calibre.
  /// Introduce DEC.01 (unidades y conversión). Doc 09 §3.6.
  static const EscenaCinematica conocerAVadic = EscenaCinematica(
    id: '3.6',
    titulo: 'Vadic',
    flagDeSalida: 'escena_3_6_vista',
    flagsRequeridos: {'escena_3_5_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Galpón de ladrillo rojo. Luz gris. Un hombre mide algo con un calibre. No levanta la vista.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Un momento.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Anota. Guarda el calibre. Ahora mira.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Vadic.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: '¿Nombre?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Dices tu nombre. Asiente una vez.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoEleccion(
        voz: VozPersonaje.vadic,
        textoPrompt: 'Esto mide 2,34 metros. ¿Cuántos centímetros son?',
        opciones: [
          OpcionEleccion(
            textoJugador: '23,4.',
            textoRespuesta: 'No. Un metro son cien centímetros.',
            flagsAEstablecer: {'vadic_cm_fallo'},
          ),
          OpcionEleccion(
            textoJugador: '234.',
            textoRespuesta: 'Correcto.',
            flagsAEstablecer: {'vadic_cm_acierto'},
          ),
          OpcionEleccion(
            textoJugador: '2340.',
            textoRespuesta: 'No. Eso serían milímetros.',
            flagsAEstablecer: {'vadic_cm_fallo'},
          ),
        ],
      ),
      PlanoEleccion(
        voz: VozPersonaje.vadic,
        textoPrompt: '¿Y en milímetros?',
        opciones: [
          OpcionEleccion(
            textoJugador: '234.',
            textoRespuesta: 'No. Diez veces más.',
            flagsAEstablecer: {'vadic_mm_fallo'},
          ),
          OpcionEleccion(
            textoJugador: '2340.',
            textoRespuesta: 'Correcto.',
            flagsAEstablecer: {'vadic_mm_acierto'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Aprendiz tres, Iniciado II. Bien para trabajar aquí.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto:
            'Aquí las cosas se miden bien o no se miden. No hay término medio.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.vadic,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Qué hago aquí?',
            textoRespuesta:
                'Lo que yo te diga, cuando yo te lo diga. Pero aprender a medir. Eso siempre.',
            flagsAEstablecer: {'vadic_pregunta_trabajo'},
          ),
          OpcionEleccion(
            textoJugador: '¿Cuánto tiempo llevas aquí?',
            textoRespuesta: 'Veintidós años.',
            flagsAEstablecer: {'vadic_pregunta_veterano'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vuelve mañana. Tengo trabajo.',
            flagsAEstablecer: {'vadic_silencio'},
          ),
        ],
      ),
    ],
  );

  /// 3.8 — Segunda pintada Opaca. En un callejón entre galpones.
  /// "La unidad es la medida de la obediencia." Vadic casi no reacciona.
  /// Doc 09 §3.8.
  static const EscenaCinematica segundaPintada = EscenaCinematica(
    id: '3.8',
    titulo: 'Una segunda pintada',
    flagDeSalida: 'escena_3_8_vista',
    flagsRequeridos: {'escena_3_6_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Callejón estrecho entre galpones. Pared de ladrillo. La misma mano que en los Canales.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Letra temblorosa: "La unidad es la medida de la obediencia."',
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Hay más últimamente.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Camina.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
    ],
  );

  /// 3.9 — Eco. Escena clave del Arco 3. Un Fragmento que habla, que
  /// no se puede atacar. El mundo baja de volumen a su alrededor.
  /// Hace una pregunta filosófica sin respuesta correcta. Doc 09 §3.9.
  /// Las frases de Eco van en VozPersonaje.fragmentoEco (Cormorant
  /// Garamond italic por el estilo del vocero Fragmento).
  static const EscenaCinematica eco = EscenaCinematica(
    id: '3.9',
    titulo: 'Eco',
    flagDeSalida: 'escena_3_9_vista',
    flagsRequeridos: {'escena_3_8_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Callejón cualquiera. De repente el mundo baja de volumen. Los pasos se apagan.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Un Fragmento pequeño flota delante de ti. Muestra dos valores a la vez: 2/4 y 1/2.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoEco,
        texto: 'Hola.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoEco,
        texto: 'Otro nuevo.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoEleccion(
        voz: VozPersonaje.fragmentoEco,
        textoPrompt: '¿Vas a desfragmentarme, Aprendiz?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Iniciado.',
            textoRespuesta: 'Ah. Disculpa. Mejor así.',
            flagsAEstablecer: {'eco_correccion_rango'},
          ),
          OpcionEleccion(
            textoJugador: 'No sé.',
            textoRespuesta: 'Eso es honesto. Mejor así.',
            flagsAEstablecer: {'eco_no_se_rango'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale. No hablas. Bien.',
            flagsAEstablecer: {'eco_silencio_rango'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Eco gira despacio sobre sí mismo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoEco,
        texto: 'Tengo una pregunta.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoEco,
        texto:
            'Si tú y yo fuéramos el mismo pedazo de algo mayor, con nombres distintos, ¿seríamos la misma cosa?',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Eco espera sin reloj.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.fragmentoEco,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Sí.',
            textoRespuesta: 'Entonces tú y yo ya somos.',
            flagsAEstablecer: {'eco_respuesta_si'},
          ),
          OpcionEleccion(
            textoJugador: 'No.',
            textoRespuesta: 'Entonces tú y yo todavía no somos.',
            flagsAEstablecer: {'eco_respuesta_no'},
          ),
          OpcionEleccion(
            textoJugador: 'No lo sé.',
            textoRespuesta: 'Yo tampoco. Ven a verme otra vez cuando sepas.',
            flagsAEstablecer: {'eco_respuesta_no_se'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte en silencio largo rato —',
            textoRespuesta: 'Otra vez será.',
            flagsAEstablecer: {'eco_respuesta_silencio'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Eco se desvanece en partículas que suben. No bajan. El mundo vuelve a su volumen.',
      ),
    ],
  );

  /// 3.10 — Oryn. Entrada al Puerto Silencioso. Monosilábico, pausas
  /// largas. Introduce FR.18/FR.19 (multiplicación y división de
  /// fracciones). Doc 09 §3.10.
  static const EscenaCinematica conocerAOryn = EscenaCinematica(
    id: '3.10',
    titulo: 'Oryn',
    flagDeSalida: 'escena_3_10_vista',
    flagsRequeridos: {'escena_3_9_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Muelle largo del Puerto Silencioso. Faro lejano parpadea. Mar negro.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Hm.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura: 'Pausa muy larga. Ocho segundos contados.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Siéntate si quieres.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Algo se mueve lejos en el mar. Se sumerge.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Oryn.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: '¿Nombre?',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Dices tu nombre.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Hm.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Aquí aprendes a multiplicar y a dividir.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Fracciones. Fracciones entre ellas.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'No es rápido.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Te mira lo justo para incomodarte.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.oryn,
        textoPrompt: '¿Preguntas?',
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Por qué es silencioso el Puerto?',
            textoRespuesta:
                'Trabajamos de noche. Y el mar pide silencio. Algunos piensan que el mar escucha.',
            flagsAEstablecer: {'oryn_pregunta_silencio'},
          ),
          OpcionEleccion(
            textoJugador: '¿Conociste a Rexán?',
            textoRespuesta: 'Hm. Mucho.',
            flagsAEstablecer: {'oryn_pregunta_rexan'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte callado —',
            textoRespuesta: 'Vale.',
            flagsAEstablecer: {'oryn_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Vuelve mañana. Empezamos.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 3.11 — Ari en el muelle. Cafetería nocturna. Ari ha visto algo
  /// raro en el muelle 7. Te pide que la acompañes. Doc 09 §3.11.
  static const EscenaCinematica ariEnElMuelle = EscenaCinematica(
    id: '3.11',
    titulo: 'Ari en el muelle',
    flagDeSalida: 'escena_3_11_vista',
    flagsRequeridos: {'escena_3_10_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Cafetería nocturna del Puerto. Ari ya ha pedido bebida para los dos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: '¡Eh!',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'No te esperaba aquí.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'Bueno, sí. Todo el mundo acaba pasando por el Puerto tarde o temprano.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Oye. ¿Te puedo pedir una cosa?',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto:
            'Llevo dos semanas viendo algo raro en el muelle 7. No voy a decir más aquí.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'No es un Fragmento normal. Creo que es... otra cosa.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoEleccion(
        voz: VozPersonaje.ari,
        textoPrompt:
            'Yo sola no voy. ¿Me acompañas mañana por la noche?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Vale.',
            textoRespuesta:
                'Gracias, {nombre}. En serio. Aquí mismo mañana, a la misma hora.',
            flagsAEstablecer: {'ari_mision_si'},
          ),
          OpcionEleccion(
            textoJugador: '¿No se lo has dicho a Oryn?',
            textoRespuesta:
                'No. No sé cómo reaccionaría. Y además... quiero ver qué es primero.',
            flagsAEstablecer: {'ari_mision_oryn'},
          ),
          OpcionEleccion(
            textoJugador: '¿Y si es peligroso?',
            textoRespuesta: 'Por eso te lo pido a ti.',
            flagsAEstablecer: {'ari_mision_peligro'},
          ),
        ],
      ),
    ],
  );

  /// 3.12 — El santuario. Muelle 7. Altar con Fragmento enjaulado
  /// entre espejos, reloj parado, rosa disecada, agua turbia. Ari
  /// pregunta a quién contárselo. Doc 09 §3.12.
  static const EscenaCinematica elSantuario = EscenaCinematica(
    id: '3.12',
    titulo: 'El santuario',
    flagDeSalida: 'escena_3_12_vista',
    flagsRequeridos: {'escena_3_11_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Muelle 7. Un almacén viejo con la puerta entornada. Luz rojiza dentro.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Un altar improvisado. Un Fragmento de valor 3/4 en una caja de cristal con filtros metálicos.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Alrededor: espejos antiguos, un reloj parado, una rosa disecada, un frasco con agua turbia.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Los objetos fuera del altar —silla, mesa— están mal proporcionados. Como si el espacio doblara.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: '¿Ves?',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Eso no es un Fragmento cualquiera.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Alguien lo está usando.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Una puerta se cierra dentro del almacén. Pasos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Vámonos.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Corréis. Atravesáis el muelle 7 en silencio. Al parar, Ari respira hondo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'Hay que contárselo.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.ari,
        texto: 'A alguien. No sé a quién.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoEleccion(
        voz: VozPersonaje.ari,
        opciones: [
          OpcionEleccion(
            textoJugador: 'A Sora.',
            textoRespuesta:
                'Sora... no sé. Ella es de Tejados. Mejor a uno del distrito de aquí.',
            flagsAEstablecer: {'santuario_escoge_sora'},
          ),
          OpcionEleccion(
            textoJugador: 'A Oryn.',
            textoRespuesta:
                'Oryn sabrá. Pero no sé si es la persona adecuada. Siempre me da la sensación de que sabe más cosas de las que dice.',
            flagsAEstablecer: {'santuario_escoge_oryn'},
          ),
          OpcionEleccion(
            textoJugador: 'A Naini.',
            textoRespuesta:
                'Sí. Ella sí. Naini reacciona. Los otros piensan demasiado antes.',
            flagsAEstablecer: {'santuario_escoge_naini'},
          ),
        ],
      ),
    ],
  );

  /// 3.13 — El interrogatorio de Naini. Despacho pequeño al fondo
  /// del Mercado. Naini sin sonrisa por primera vez. Revela qué son
  /// los Coleccionistas. Primer "gracias" de un maestro al jugador.
  /// Doc 09 §3.13.
  static const EscenaCinematica interrogatorioDeNaini = EscenaCinematica(
    id: '3.13',
    titulo: 'El interrogatorio de Naini',
    flagDeSalida: 'escena_3_13_vista',
    flagsRequeridos: {'escena_3_12_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Despacho pequeño al fondo del Mercado. Una lámpara de mesa. Naini sin sonrisa por primera vez.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Contádmelo. Paso a paso.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Escucha sin interrumpir. Toma notas. Hace un círculo en el papel.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Vale.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Esto no es un Fragmento silvestre. Esto es una infraestructura.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Alguien está capturando Fragmentos y manteniéndolos vivos para que funcionen en un lugar concreto.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Se llaman Coleccionistas. Algunos ricos que descubrieron hace décadas que un Fragmento grande, enjaulado, distorsiona el espacio a su alrededor.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Y si lo pones bien, distorsiona a tu favor.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Contratos que firmas dentro te favorecen. Reuniones duran lo que te conviene.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Gente que visita tu oficina olvida la mitad de lo que iba a decirte.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Es difícil de probar. Y es muy viejo.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Ari, esto lo has hecho bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: '{nombre}, tú también.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Primera vez que un maestro os mira como colegas. No como alumnos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Lo voy a llevar al Cónclave. Es nivel Fraccionista Mayor.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Gracias.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Primera vez que un maestro te da las gracias. Ari te mira de reojo. Tú también a ella.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto:
            'Vosotros dos no habéis estado nunca en ese muelle. ¿De acuerdo?',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Bien. Hala. Id a descansar.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
    ],
  );

  /// 3.14 — Kai vuelve. Azotea. Kai confiesa sospechas sobre su padre.
  /// Doc 09 §3.14.
  static const EscenaCinematica kaiVuelve = EscenaCinematica(
    id: '3.14',
    titulo: 'Kai vuelve',
    flagDeSalida: 'escena_3_14_vista',
    flagsRequeridos: {'escena_3_13_vista'},
    sonidoDeEntrada: 'motivo_kai',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Azotea principal. Sora al fondo sin acercarse. Kai sentado contra un respiradero mirando el cielo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Te está esperando.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Hombre.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Me enteré de lo del muelle 7.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'No vas a creerme, pero...',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto:
            'Yo llevaba un mes sospechando algo así en la calle donde vive mi padre.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Kai sin máscara. No es la primera vez que baja la guardia contigo pero sí es la más honda.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto:
            'No tengo pruebas. Pero cuando la gente entra a cenar con mi padre, salen distintas.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'No lo he hablado con nadie.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Necesito ayuda.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.kai,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Cuéntame.',
            textoRespuesta:
                'La oficina cerrada. La gente que sale confusa. Dos veces al mes. Mucha gente.',
            flagsAEstablecer: {'kai_padre_contar'},
          ),
          OpcionEleccion(
            textoJugador: '¿Por qué me lo cuentas a mí?',
            textoRespuesta:
                'Porque ya no confío en los que llevo años conociendo. Y tú acabas de hacer algo que yo no sabía hacer.',
            flagsAEstablecer: {'kai_padre_confianza'},
          ),
          OpcionEleccion(
            textoJugador: '— escuchar sin preguntar —',
            textoRespuesta: 'Gracias por no preguntar nada.',
            flagsAEstablecer: {'kai_padre_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Mañana te cuento más.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Has estado bien. En el duelo.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Sora murmura al fondo, casi para sí misma:',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vaya.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 3.15 — La misión conjunta. Fragmento Impropio 9/5. Irune la
  /// impone. Combate coordinado narrativo. Doc 09 §3.15.
  static const EscenaCinematica misionConjunta = EscenaCinematica(
    id: '3.15',
    titulo: 'La misión conjunta',
    flagDeSalida: 'escena_3_15_vista',
    flagsRequeridos: {'escena_3_14_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Barrio residencial entre Canales e Industria. Portal de una casa cualquiera. Un Fragmento Impropio de valor 9/5 flota a media altura.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Impropio.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Si lo convertimos en mixto, es 1 y 4/5.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.kai,
        textoPrompt: '¿Lo estabilizas tú o yo?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Yo.',
            textoRespuesta: 'Vale. Yo ataco.',
            flagsAEstablecer: {'kai_coop_yo'},
          ),
          OpcionEleccion(
            textoJugador: 'Tú.',
            textoRespuesta: 'Vale. Tú atacas.',
            flagsAEstablecer: {'kai_coop_tu'},
          ),
          OpcionEleccion(
            textoJugador: 'Juntos.',
            textoRespuesta: 'Vale. Juntos.',
            flagsAEstablecer: {'kai_coop_juntos'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'El Fragmento se estabiliza. Kai, ya de compañero:',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Espera.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Ahora.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Tu turno.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'El Fragmento se disuelve limpio. Kai guarda algo en el bolsillo. No dice qué.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Mañana te paso algo por escrito.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'De lo de mi padre.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Por si no te vuelvo a ver en un tiempo.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
    ],
  );

  /// 3.16 — Brina. Afueras, observatorio. 17% crecimiento trimestral
  /// de Fragmentos. Doc 09 §3.16.
  static const EscenaCinematica conocerABrina = EscenaCinematica(
    id: '3.16',
    titulo: 'Brina',
    flagDeSalida: 'escena_3_16_vista',
    flagsRequeridos: {'escena_3_15_vista'},
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Observatorio antiguo al borde de un campo. Cielo estrellado. Dos lunas esta noche.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Ah, tú.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Brina. Maestra de las Afueras. Y profesora, pero eso es otra cosa.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Déjame pensar.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Tú eres el que hizo lo de Zafrán con Sora y acaba de descubrir algo en el Puerto con Ari y trabajó ayer con Kai.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Meses resumidos en una frase.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Interesante.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Siéntate.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Aquí trabajamos con datos. Probabilidades. Tendencias.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Te voy a enseñar una cosa que te va a parecer aburrida. No lo es.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Te pone una tabla delante. Fechas en una columna. Números que suben en la otra.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.brina,
        textoPrompt: '¿Qué ves?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Los números suben.',
            textoRespuesta: 'Bien. ¿Sabes qué miden?',
            flagsAEstablecer: {'brina_grafico_suben'},
          ),
          OpcionEleccion(
            textoJugador: '¿Qué son?',
            textoRespuesta: 'Te lo iba a contar igual.',
            flagsAEstablecer: {'brina_grafico_pregunta'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Son Fragmentos. Fragmentos aparecidos en Azula cada mes.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'En los últimos dos años han subido un 17% cada trimestre.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Nadie se lo cuenta a los Fraccionistas nuevos. No quieren asustar.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Pero tú ya eres Iniciado III. Tienes que saber.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Azula está peor cada año.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Y no sabemos por qué.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
    ],
  );

  /// 3.17 — La Montaña se nombra. Primera mención del Algebrista.
  /// Doc 09 §3.17.
  static const EscenaCinematica laMontanaSeNombra = EscenaCinematica(
    id: '3.17',
    titulo: 'La Montaña se nombra',
    flagDeSalida: 'escena_3_17_vista',
    flagsRequeridos: {'escena_3_16_vista'},
    esCierreAmable: true,
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Mirador al borde de Afueras. Vista clara a la Montaña. La luna recorta su silueta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Todos acaban mirándola.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: '¿Irune te ha hablado de ella?',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Niegas con la cabeza.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Ahí arriba vive alguien que todavía cree que puede repararse.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoEleccion(
        voz: VozPersonaje.brina,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿Repararse qué?',
            textoRespuesta: 'El Uno. Lo que se rompió.',
            flagsAEstablecer: {'montana_reparar_que'},
          ),
          OpcionEleccion(
            textoJugador: '¿Quién vive?',
            textoRespuesta: 'El Algebrista.',
            flagsAEstablecer: {'montana_quien_vive'},
          ),
          OpcionEleccion(
            textoJugador: '— quedarte mirando —',
            textoRespuesta: 'Vale. Te lo cuento.',
            flagsAEstablecer: {'montana_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'El Algebrista.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Hace décadas que nadie sube. Irune no sube.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Algunos dicen que ya no vive. Yo creo que sí.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Algún día vas a querer subir.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'No hoy. No este año. Pero algún día.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Cuando te toque, alguien te ayudará a ir. Irune. Sora. Alguien.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 3.18 — Irune al fondo. Cierre del Arco 3. Irune menciona Eco por
  /// su nombre — sabe. Doc 09 §3.18.
  static const EscenaCinematica iruneAlFondo = EscenaCinematica(
    id: '3.18',
    titulo: 'Irune al fondo',
    flagDeSalida: 'escena_3_18_vista',
    flagsRequeridos: {'escena_3_17_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Sala de Irune. Chimenea encendida. Sora al fondo con un libro cerrado. Irune sirve té.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Han pasado muchas cosas.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Zafrán. El muelle 7. Kai. Eco.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'La última palabra con un tono distinto.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Sí. Sé lo de Eco.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'No te preocupes por él. De momento.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Has conocido a todos los maestros menos a Oryn bien. Eso te falta.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Y cuando lo conozcas, estarás listo.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Iniciado III, pronto. Fraccionista, en unos meses.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Mira a Sora un momento. Sora no se mueve.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Cuando seas Fraccionista, ya no hace falta que nadie vaya contigo a ningún sitio.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Entonces vas a tener que empezar a decidir tú qué hacer con lo que sabes.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Es menos cómodo de lo que parece.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura: 'Sonrisa pequeña.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Descansa. Vete con Sora.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Azotea. Borde. Sora apoyada. Tú a su lado. Ninguno habla. Azula abajo, todos sus distritos, la Montaña al fondo.',
      ),
      PlanoCierreAmable(textoBoton: 'HASTA MAÑANA'),
    ],
  );

  // ============================================================
  // Arco 4 — El ascenso. Doc 10. Cierre del MVP.
  // ============================================================

  /// 4.1 — El Puerto otra vez. Oryn introduce multiplicación de
  /// fracciones. "Una parte de una parte." Doc 10 §4.1.
  static const EscenaCinematica puertoOtraVez = EscenaCinematica(
    id: '4.1',
    titulo: 'El Puerto otra vez',
    flagDeSalida: 'escena_4_1_vista',
    flagsRequeridos: {'escena_3_18_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Muelle largo del Puerto. Más niebla que la última vez. Sin Ari.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Hoy empezamos.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Iniciado III. Sí.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto:
            'Aquí vas a aprender una cosa que parece magia. Multiplicar dos fracciones entre sí.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Dos tercios por tres cuartos.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'El resultado es más pequeño que los dos.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Parece mentira. No lo es.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Cobertizo al final del muelle. Un tablón viejo con cuerdas con nudos. Un dispositivo de entrenamiento casero.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Esto lo hice yo. Hace años.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto:
            'Cuando multiplicas una fracción por otra, tomas una parte de una parte.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoEleccion(
        voz: VozPersonaje.oryn,
        textoPrompt:
            'Si te quedas con la mitad de tres cuartos, ¿cuánto tienes?',
        opciones: [
          OpcionEleccion(
            textoJugador: '3/4.',
            textoRespuesta: 'No. La mitad de algo es menos.',
            flagsAEstablecer: {'oryn_mult_fallo'},
          ),
          OpcionEleccion(
            textoJugador: '3/8.',
            textoRespuesta:
                'Tres octavos. Menos que un medio. Menos que tres cuartos. Pero es la mitad de ese tres cuartos.',
            flagsAEstablecer: {'oryn_mult_acierto'},
          ),
          OpcionEleccion(
            textoJugador: '1/2.',
            textoRespuesta: 'No. Estás cogiendo la mitad, pero de tres cuartos, no de un entero.',
            flagsAEstablecer: {'oryn_mult_fallo'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto:
            'Esto hay que verlo muchas veces para que no parezca raro.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.2 — El agua recuerda. Silencio de Oryn. Frase única: "vuelve
  /// aquí si estás perdido". Doc 10 §4.2.
  static const EscenaCinematica elAguaRecuerda = EscenaCinematica(
    id: '4.2',
    titulo: 'El agua recuerda',
    flagDeSalida: 'escena_4_2_vista',
    flagsRequeridos: {'escena_4_1_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Madrugada. El cielo aclara muy despacio. Oryn mira el mar durante tres minutos reales. Tú estás ahí.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Hm.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: '{nombre}. Una cosa.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'El agua recuerda.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Silencio de cuatro segundos. La frase respira.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Esa es una de las dos veces en que te lo voy a decir.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto:
            'Si alguna vez estás perdido, vuelve aquí. No te digo por qué.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Solo vuelve.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoEleccion(
        voz: VozPersonaje.oryn,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Vale.',
            textoRespuesta: 'Mañana más. Descansa.',
            flagsAEstablecer: {'oryn_agua_si'},
          ),
          OpcionEleccion(
            textoJugador: '— asentir en silencio —',
            textoRespuesta: 'Mañana más. Descansa.',
            flagsAEstablecer: {'oryn_agua_silencio'},
          ),
        ],
      ),
    ],
  );

  /// 4.3 — La bolsa. Oryn abre por fin su bolsa impermeable. Te da
  /// una concha. Doc 10 §4.3. Objeto inventariable que Sora
  /// reconocerá.
  static const EscenaCinematica laBolsa = EscenaCinematica(
    id: '4.3',
    titulo: 'La bolsa',
    flagDeSalida: 'escena_4_3_vista',
    flagsRequeridos: {'escena_4_2_vista'},
    esCierreAmable: true,
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Oye.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Abre la bolsa impermeable que nunca abre delante de nadie. Saca una concha plana pulida con un agujero natural y un hilo fino.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Toma.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'No vale nada. Pero la llevo mucho tiempo.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Ahora la llevas tú.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Cierra la bolsa. Entra al cobertizo. Cierra la puerta.',
      ),
    ],
  );

  /// 4.4 — Tercera pintada. Muro de Afueras. Frase nueva + tachada.
  /// Completa el manifiesto Opaco (tres pintadas). Doc 10 §4.4.
  static const EscenaCinematica terceraPintada = EscenaCinematica(
    id: '4.4',
    titulo: 'Una tercera pintada',
    flagDeSalida: 'escena_4_4_vista',
    flagsRequeridos: {'escena_4_3_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Muro exterior al borde de Afueras. La misma mano que las dos anteriores.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'Frase nueva: "En la parte está la libertad."',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Debajo, otra pintura más reciente, distinta, tachando la primera: "La parte sola no libra a nadie."',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Las dos frases coexisten. Alguien ha respondido.',
      ),
    ],
  );

  /// 4.5 — Eco otra vez, casi. Silencio. No aparece. Doc 10 §4.5.
  static const EscenaCinematica ecoCasi = EscenaCinematica(
    id: '4.5',
    titulo: 'Eco otra vez, casi',
    flagDeSalida: 'escena_4_5_vista',
    flagsRequeridos: {'escena_4_4_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Un callejón parecido al de la primera vez. El mundo baja de volumen otra vez.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura: 'Pero nada aparece.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 4000),
        textoLectura: 'Silencio. Quince segundos. Te quedas quieto.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'El sonido vuelve. Sin explicación. Sientes que Eco estuvo a punto.',
      ),
    ],
  );

  /// 4.6 — Irune: la invitación. Plato de pastas. "Estás listo para
  /// la Prueba." Doc 10 §4.6.
  static const EscenaCinematica iruneInvitacion = EscenaCinematica(
    id: '4.6',
    titulo: 'Irune: la invitación',
    flagDeSalida: 'escena_4_6_vista',
    flagsRequeridos: {'escena_4_5_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Sala de Irune. Un plato de pastas pequeñas — nunca las había sacado antes. Dos tazas de té.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Toma.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Te he llamado porque ha llegado el momento.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Estás listo para la Prueba.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'No significa que sepas todo lo que tienes que saber. Significa que ya puedes demostrar lo que sabes.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'La diferencia es fina. Es real.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Puedes decir que no. Puedes esperar unos meses. No te voy a presionar.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Pero si dices que sí, te explico las tres formas.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoEleccion(
        voz: VozPersonaje.irune,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Sí.',
            textoRespuesta: 'Bien. Escucha.',
            flagsAEstablecer: {'ascension_acepta'},
          ),
          OpcionEleccion(
            textoJugador: '¿Qué tres formas?',
            textoRespuesta: 'Siéntate y te las explico.',
            flagsAEstablecer: {'ascension_pregunta'},
          ),
        ],
      ),
    ],
  );

  /// 4.7 — Las tres pruebas. Irune explica Fuego / Sendero / Espejo.
  /// El jugador elige. Doc 10 §4.7.
  static const EscenaCinematica tresPruebas = EscenaCinematica(
    id: '4.7',
    titulo: 'Las tres pruebas',
    flagDeSalida: 'escena_4_7_vista',
    flagsRequeridos: {'escena_4_6_vista'},
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Tres Pruebas. Tú eliges una.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Primera. Prueba de Fuego. Combate contra un Fragmento representativo de tu rango. Sin ayudas, sin Sora. Tú solo.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Es la más rápida. Tres minutos, cuatro. Intensa.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Para los que tienen confianza en su cuerpo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Segunda. Prueba de Sendero. Serie larga de Fragmentos, todos los tipos, con margen de error limitado. Mide tu fluidez.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Es la más lenta. Veinte minutos. Meditativa.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Para los que tienen paciencia.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Tercera. Prueba de Espejo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Tienes que enseñar a alguien más joven que tú. Un Fraccionista que está donde tú estabas hace un año.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Te enfrentas a sus fallos. Le ayudas a resolverlos. Le haces preguntas, no le das respuestas.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Mide si entiendes lo que has aprendido. Si puedes explicarlo a otro.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Es la más difícil. Y la más importante, para muchos.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Las tres valen lo mismo. Ninguna es superior a las otras. Elige.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoEleccion(
        voz: VozPersonaje.irune,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Fuego.',
            textoRespuesta: 'Bien. Mañana. Aquí. Después de cenar.',
            flagsAEstablecer: {'prueba_elegida_fuego'},
          ),
          OpcionEleccion(
            textoJugador: 'Sendero.',
            textoRespuesta: 'Bien. Mañana. Aquí. Después de cenar.',
            flagsAEstablecer: {'prueba_elegida_sendero'},
          ),
          OpcionEleccion(
            textoJugador: 'Espejo.',
            textoRespuesta: 'Bien. Mañana. Aquí. Después de cenar.',
            flagsAEstablecer: {'prueba_elegida_espejo'},
          ),
        ],
      ),
    ],
  );

  /// 4.8 Fuego — Sora antes del duelo de Fuego. Doc 10 §4.8.
  static const EscenaCinematica soraAntesFuego = EscenaCinematica(
    id: '4.8f',
    titulo: 'Sora antes — Fuego',
    flagDeSalida: 'escena_4_8_fuego_vista',
    flagsRequeridos: {'escena_4_7_vista', 'prueba_elegida_fuego'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Azotea. Sora de pie con los brazos cruzados. Te estaba esperando.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '¿Cuál?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1200),
        textoLectura: 'Dices: Fuego.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Clásica. Bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Solo una cosa. No vayas rápido. No es una carrera. La velocidad se entiende mal.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Respira en los cambios. Descomponer es también parar.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Suerte, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Cenamos. Luego entras.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
    ],
  );

  /// 4.8 Sendero — variante. Doc 10 §4.8.
  static const EscenaCinematica soraAntesSendero = EscenaCinematica(
    id: '4.8s',
    titulo: 'Sora antes — Sendero',
    flagDeSalida: 'escena_4_8_sendero_vista',
    flagsRequeridos: {'escena_4_7_vista', 'prueba_elegida_sendero'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Azotea. Sora de pie con los brazos cruzados. Te estaba esperando.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '¿Cuál?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1200),
        textoLectura: 'Dices: Sendero.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Paciente. Bien.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Es la que hice yo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Si te cansas a mitad, no te pares del todo. Cambia de ritmo. Descansa mientras sigues.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Suerte, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Cenamos. Luego entras.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
    ],
  );

  /// 4.8 Espejo — Sora se abre un punto más. No cena con el niño esta
  /// noche (encargo de Irune). Doc 10 §4.8.
  static const EscenaCinematica soraAntesEspejo = EscenaCinematica(
    id: '4.8e',
    titulo: 'Sora antes — Espejo',
    flagDeSalida: 'escena_4_8_espejo_vista',
    flagsRequeridos: {'escena_4_7_vista', 'prueba_elegida_espejo'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Azotea. Sora de pie con los brazos cruzados. Te estaba esperando.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '¿Cuál?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1400),
        textoLectura:
            'Dices: Espejo. Sora se queda callada dos segundos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Mm.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Vale.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Esa es la más personal.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Ten cuidado con lo que le dices al otro. A veces se te escapan cosas que no sabías que pensabas.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Y a veces... el otro se parece a alguien que no esperas.',
        pausaPrevia: Duration(milliseconds: 1800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Silencio. Sora nunca había sido tan explícita. No te mira directo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Suerte, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Tengo que hacer un encargo. Te alcanzo al final.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.9a — Prueba de Fuego. Post-combate vs Vorax. Sin palabras
  /// durante. Doc 10 §4.9a. El combate jugable se lanza desde el
  /// orquestador tras la 4.8f; esta escena se dispara al terminar.
  static const EscenaCinematica pruebaFuego = EscenaCinematica(
    id: '4.9f',
    titulo: 'Prueba de Fuego',
    flagDeSalida: 'prueba_completada',
    flagsRequeridos: {'combate_vorax_completado'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Azotea. Seis maestros. Sora. Kai. Ari. Ninguno habla durante el combate. Vorax se retira hacia arriba como Zafrán.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.9b — Prueba de Sendero. Recorrido por la ciudad solo.
  /// Narrado; cuatro tramos simbólicos. Doc 10 §4.9b.
  static const EscenaCinematica pruebaSendero = EscenaCinematica(
    id: '4.9s',
    titulo: 'Prueba de Sendero',
    flagDeSalida: 'prueba_completada',
    flagsRequeridos: {'escena_4_8_sendero_vista'},
    esCierreAmable: true,
    planos: [
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Prueba de Sendero.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Esta noche vas a recorrer la ciudad. Cuatro distritos. Una prueba en cada uno.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'En cada distrito te espera un Fragmento distinto, diseñado por el maestro correspondiente.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Nadie te va a acompañar. Nadie te va a ayudar.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Empiezas en los Canales.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Canales. Niebla baja. Un Fragmento Espejo 5/10 esperando. Lo emparejas con 1/2. Silencio.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Industria. Luz gris. Un Fragmento con unidades que no cuadran: 1,2 kg más 800 g. Un punto dos kilos.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Mercado. Puestos cerrando. Un Fragmento con 40 manzanas y una pregunta: el 25% son rojas. Diez rojas.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Afueras. Observatorio. Un Fragmento con una tendencia: tres meses subiendo 5. Lo que viene ya lo sabes.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Subes al Edificio de los Tejados antes del amanecer. Irune en la puerta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.9c — Prueba de Espejo. Niko (IA) sentado enfrente. Dos
  /// ejercicios pedagógicos. Doc 10 §4.9c. El tipo de respuesta del
  /// jugador diferencia `espejo_pasada_fuerte` vs
  /// `espejo_pasada_debil` (el guion distingue entre "enseñar" y
  /// "resolver"). Ambas pasan la Prueba.
  static const EscenaCinematica pruebaEspejo = EscenaCinematica(
    id: '4.9e',
    titulo: 'Prueba de Espejo',
    flagDeSalida: 'prueba_completada',
    flagsRequeridos: {'escena_4_8_espejo_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Sala de Irune. Cerrada. Luz tenue. Dos sillas frente a frente. Irune sale. Niko sentado enfrente.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Pelo que te recuerda a alguien. Un gesto que no sabes por qué reconoces.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'Hola.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'Tengo que aprender contigo.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'Irune me ha dicho que me vas a ayudar.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Ejercicio 1: 2/3 + 1/5 = ? Niko ha puesto 3/8 (sumando numeradores y denominadores).',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'No entiendo por qué está mal.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoEleccion(
        voz: VozPersonaje.aprendizNiko,
        opciones: [
          OpcionEleccion(
            textoJugador:
                'La respuesta es 13/15. Te la apuntas y vamos a otra.',
            textoRespuesta: 'Vale, gracias.',
            flagsAEstablecer: {'espejo_pasada_debil'},
          ),
          OpcionEleccion(
            textoJugador:
                '¿Es más o menos que medio, un tercio más un quinto?',
            textoRespuesta:
                'Más. Porque un tercio ya es casi medio. ¡Ah!',
            flagsAEstablecer: {'espejo_pasada_fuerte'},
          ),
          OpcionEleccion(
            textoJugador:
                'Los números de abajo no son iguales. ¿Los trozos son iguales?',
            textoRespuesta: 'No. ¡Ah!',
            flagsAEstablecer: {'espejo_pasada_fuerte'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Niko calcula por su cuenta. Se pasa la mano por el pelo hacia atrás dos veces.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: '13/15. ¿Así está bien?',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Ejercicio 2: 35% de 80 = ?',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto:
            'Sé que es algo así como 30. Pero no sé cómo pensarlo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoEleccion(
        voz: VozPersonaje.aprendizNiko,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Son 28. Ya está.',
            textoRespuesta: 'Vale. 28.',
            flagsAEstablecer: {'espejo_ej2_debil'},
          ),
          OpcionEleccion(
            textoJugador:
                'Si 10% de 80 son 8, ¿cuánto sería 30%?',
            textoRespuesta: '24. Y 5% son 4. ¡28!',
            flagsAEstablecer: {'espejo_ej2_fuerte'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura:
            'Se pasa la mano por el pelo otra vez. Dos veces. Como Sora cuando se concentra.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'Gracias.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto:
            'Irune me dijo que si alguien te explicaba esto bien, lo ibas a recordar siempre.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aprendizNiko,
        texto: 'Tú me lo explicaste bien.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Irune entra.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Se acabó.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Niko se va por una puerta que no habías visto. "Hasta mañana."',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Sora te espera fuera.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
    ],
  );

  /// 4.10 — La ceremonia. Azotea, amanecer. Todos los maestros. Cinco
  /// "Bien". Sora dice "Gracias." dos veces. Doc 10 §4.10.
  static const EscenaCinematica ceremonia = EscenaCinematica(
    id: '4.10',
    titulo: 'La ceremonia',
    flagDeSalida: 'escena_4_10_vista',
    flagsRequeridos: {'prueba_completada'},
    loopDeFondo: 'musica_ceremonia',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Azotea, amanecer empezando. Todos los maestros en semicírculo. Sora entre ellos pero un paso atrás. Kai y Ari junto a la escalera.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Repite conmigo.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Prometo buscar el Uno que fue.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Repites.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Prometo proteger el mundo que queda.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Repites.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Prometo no pretender nunca que sé más de lo que sé.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Repites.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Saca una marca nueva — más grande, plata clara, símbolo de la orden en relieve. Te cambia la del cuello.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bienvenido, Fraccionista.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Hace mucho que no ponía una de estas.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Cada maestro da un paso adelante y dice su palabra antigua:',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.naini,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.vadic,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.oryn,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Bien.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Cinco "bien" con cinco voces distintas. Hermoso sin necesitar más.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Sora.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Sora da un paso adelante. Frente a ti. Silencio de tres segundos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Gracias.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'En serio. Gracias.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'La palabra dicha dos veces. Enorme para Sora. Se aparta al borde del semicírculo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Por hoy está.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.11 — Rexán y el té. Esquina apartada. Marca vieja y desteñida.
  /// Doc 10 §4.11.
  static const EscenaCinematica rexanYElTe = EscenaCinematica(
    id: '4.11',
    titulo: 'Rexán y el té',
    flagDeSalida: 'escena_4_11_vista',
    flagsRequeridos: {'escena_4_10_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Esquina apartada de la azotea. Dos vasos pequeños humeantes.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Bébelo caliente.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'A ver, a ver.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Te ha tocado llevarme en este año.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Has sido muy buen aprendiz.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Ya no eres mi aprendiz. Ahora eres mi colega.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Si alguna vez quieres bajar a los Canales solo para hablar, me avisas.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Yo estaré.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Saca una pequeña marca vieja, muy desteñida.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto:
            'Era la primera marca de Fraccionista que me pusieron.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Ya tengo otras con más filetes azules.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Pero esta es la primera.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.rexan,
        texto: 'Cuida la tuya, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
    ],
  );

  /// 4.12 — Kai, lejos. Kai apoyado en un respiradero solo. Primera
  /// vez que dice "enhorabuena". Doc 10 §4.12.
  static const EscenaCinematica kaiLejos = EscenaCinematica(
    id: '4.12',
    titulo: 'Kai, lejos',
    flagDeSalida: 'escena_4_12_vista',
    flagsRequeridos: {'escena_4_11_vista'},
    esCierreAmable: true,
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Otra parte de la azotea. Kai apoyado en un respiradero, solo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Hombre.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Fraccionista.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Va delante, mira.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura:
            'Se señala a sí mismo. Sigue siendo Iniciado III. Tú ahora un rango por encima.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Vale.',
        pausaPrevia: Duration(milliseconds: 1100),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Yo lo soy en unos meses. Si no me distraigo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Oye.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto:
            'Lo de mi padre sigue en pie. Cuando me recuperes como colega, hablamos.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Enhorabuena, {nombre}.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura:
            'Asiente una sola vez. Forma máxima de reconocimiento. Primera vez que dice "enhorabuena".',
      ),
    ],
  );

  /// 4.13 — Sora en el borde. Reveal completo de su origen: Kir.
  /// Doc 10 §4.13. Momento más importante del MVP.
  static const EscenaCinematica soraEnElBorde = EscenaCinematica(
    id: '4.13',
    titulo: 'Sora en el borde',
    flagDeSalida: 'escena_4_13_vista',
    flagsRequeridos: {'escena_4_12_vista'},
    loopDeFondo: 'musica_amanecer_final',
    sonidoDeEntrada: 'motivo_sora',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Todos se han ido. Sora sentada en el borde norte, piernas colgando. Alba avanzada. La ciudad con luz limpia por primera vez. Distritos distinguibles. Montaña al fondo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Bueno.',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Lo has hecho.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Te voy a decir una cosa y luego no la digo más.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Yo llegué a Azula hace dos años. Sola.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Mi ciudad se llamaba Kir. Estaba al norte, al borde del mar.',
        pausaPrevia: Duration(milliseconds: 1800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'La palabra KIR queda un instante en el aire. Recuérdala.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'La perdimos.',
        pausaPrevia: Duration(milliseconds: 1600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Yo tenía once años cuando pasó.',
        pausaPrevia: Duration(milliseconds: 1700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura: 'Silencio muy largo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No entré aquí porque quisiera salvar el mundo.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Entré porque no quería que pasara otra vez.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Eso es todo. Pregúntame otro día si quieres más.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No creo que lo hagas.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Media sonrisa.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Tú no preguntas. Me gustó desde el principio.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Gesto hacia la Montaña.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Brina te habló de ella.',
        pausaPrevia: Duration(milliseconds: 1300),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ahí sube el que sea Fraccionista Mayor.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Yo tardaré. Tú tardarás más aún, porque empezaste más tarde.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            'Pero cuando llegue el momento, subimos juntos.',
        pausaPrevia: Duration(milliseconds: 1500),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Te lo prometo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No te prometo que la pelea valga la pena.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Te prometo que te acompaño.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Saca la brújula vieja. Te cierra los dedos sobre ella.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Quédatela.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ya no la necesito yo.',
        pausaPrevia: Duration(milliseconds: 1400),
      ),
    ],
  );

  /// 4.14 — La Montaña. Cierre de la Era 2. Doc 10 §4.14. La historia
  /// sigue en el Arco V (`escenas_arco_cinco.dart`).
  /// Fundido a blanco, créditos mínimos, HASTA ENTONCES.
  static const EscenaCinematica laMontanaCierre = EscenaCinematica(
    id: '4.14',
    titulo: 'La Montaña',
    flagDeSalida: 'escena_4_14_vista',
    flagsRequeridos: {'escena_4_13_vista'},
    esCierreAmable: true,
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Amanecer completo. La Montaña iluminada con nitidez por primera vez. Rocas. Laderas. Cumbre nevada. Un sendero tenue en un flanco.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Tú y Sora como siluetas pequeñas de espaldas. Viento. Amanecer.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3200),
        textoLectura: 'Silencio. Fundido a blanco.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'FIN DEL ARCO IV. EL ASCENSO.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'URO UNO ROTO',
      ),
      PlanoCierreAmable(textoBoton: 'HASTA ENTONCES'),
    ],
  );

  static const List<EscenaCinematica> todas = [
    llegada,
    primeraVentana,
    callejon,
    presentacionIrune,
    kurzAparece,
    primeraDerrota,
    kaiVistoDeLejos,
    losPlenos,
    laCena,
    kurzVuelve,
    kurzVuelveDerrota,
    kurzVuelveVictoria,
    kurzVencidoPre,
    kurzVencidoVictoria,
    kurzVencidoDerrota,
    palabrasDeIrune,
    canalesDesdeArriba,
    // Arco 2.
    bajarSolo,
    conocerARexan,
    primerEspejo,
    pintadaRara,
    zafranMencionado,
    dualEnPuente,
    rexanYElAgua,
    conocerAAri,
    silbidoLejano,
    soraVuelveABajar,
    nocheDeZafran,
    zafranEscapa,
    despuesDeZafran,
    rexanEspera,
    canalesEnSilencio,
    // Arco 3.
    conocerANaini,
    mercadoDeLaLuz,
    kaiOtraVez,
    kaiDesaparece,
    conocerAVadic,
    segundaPintada,
    eco,
    conocerAOryn,
    ariEnElMuelle,
    elSantuario,
    interrogatorioDeNaini,
    kaiVuelve,
    misionConjunta,
    conocerABrina,
    laMontanaSeNombra,
    iruneAlFondo,
    // Arco 4.
    puertoOtraVez,
    elAguaRecuerda,
    laBolsa,
    terceraPintada,
    ecoCasi,
    iruneInvitacion,
    tresPruebas,
    soraAntesFuego,
    soraAntesSendero,
    soraAntesEspejo,
    pruebaFuego,
    pruebaSendero,
    pruebaEspejo,
    ceremonia,
    rexanYElTe,
    kaiLejos,
    soraEnElBorde,
    laMontanaCierre,
    // Arco 5 (Era 3): la Montaña.
    ...EscenasArcoCinco.todas,
  ];

  static EscenaCinematica? porId(String id) {
    for (final escena in todas) {
      if (escena.id == id) return escena;
    }
    return null;
  }
}
