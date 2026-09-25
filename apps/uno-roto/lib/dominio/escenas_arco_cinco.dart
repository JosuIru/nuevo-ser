import 'escena_cinematica.dart';
import 'plano_escena.dart';
import 'voz_personaje.dart';

/// Arco V — La Montaña. Primer arco de la Era 3 (ampliación a 14 años,
/// 2026-09). Se abre tras el cierre del Arco IV (4.14) y avanza con las
/// habilidades de 1.º y 2.º de ESO: cada escena espera a que el niño
/// haya empezado una (`alg_04_introducida`, `fun_02_introducida`…), así
/// la historia sube la Montaña al ritmo en que se aprende su lenguaje.
///
/// Resuelve en parte dos preguntas abiertas de la biblia (§9): el
/// Algebrista vive —es Aldara, y está «del lado de la Montaña»— y lo que
/// Iria escribió y no se publicó. Deja abiertas las demás.
///
/// Personajes nuevos: Ulden (guardián del Archivo, doc 04 «puente a Era
/// 3»), Aldara (la Algebrista) y Velo (Fragmento de la niebla, combate
/// tras la 5.7). Tono de la biblia: mesura, sin fanfarria.
class EscenasArcoCinco {
  /// 5.1 — La carta. Brina enseña la carta de la Montaña: la niebla baja.
  static const EscenaCinematica laCarta = EscenaCinematica(
    id: '5.1',
    titulo: 'La carta',
    flagDeSalida: 'escena_5_1_vista',
    flagsRequeridos: {'escena_4_14_vista', 'alg_04_introducida'},
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Afueras. Tarde. El despacho de Brina: libros apilados en el suelo, una ventana que da a la Montaña.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.brina, texto: 'Pasa. Cierra, que entra el viento.'),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Te he llamado por esto.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Una hoja doblada en cuatro. Papel grueso, húmedo en los bordes. No hay palabras: sólo letras sueltas, igualdades y una x rodeada con un círculo.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.brina,
          texto: 'Me escribe así desde hace doce años.'),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Nunca una palabra. Sólo cuentas.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoEleccion(
        voz: VozPersonaje.brina,
        textoPrompt: '¿Sabes quién?',
        opciones: [
          OpcionEleccion(
            textoJugador: '¿El Algebrista?',
            textoRespuesta: 'Sí. Ahora ya lo sabes tú también.',
            flagsAEstablecer: {'arco5_carta_nombre'},
          ),
          OpcionEleccion(
            textoJugador: '¿Por qué en cuentas?',
            textoRespuesta: 'Porque una cuenta no se puede leer a medias.',
            flagsAEstablecer: {'arco5_carta_cuentas'},
          ),
          OpcionEleccion(
            textoJugador: '— mirar la hoja —',
            textoRespuesta: 'Mírala. Sin prisa.',
            flagsAEstablecer: {'arco5_carta_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
          voz: VozPersonaje.brina, texto: 'Ésta es distinta. Mira abajo.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3200),
        textoLectura:
            'Debajo de las letras, una frase de verdad, con letra apretada: «La niebla baja. Cuarenta metros cada semana. Está a mil doscientos metros del Borde.»',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Es la primera frase que me escribe en doce años.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoEleccion(
        voz: VozPersonaje.brina,
        textoPrompt:
            'Cuarenta metros cada semana. Mil doscientos. ¿Cuánto tarda en llegar?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Treinta semanas',
            textoRespuesta: 'Treinta. Eso me sale a mí.',
          ),
          OpcionEleccion(
            textoJugador: 'Cuarenta y ocho semanas',
            textoRespuesta: 'No. Mil doscientos entre cuarenta. Treinta.',
          ),
          OpcionEleccion(
            textoJugador: 'No lo sé',
            textoRespuesta: 'Mil doscientos entre cuarenta. Treinta semanas.',
          ),
        ],
      ),
      PlanoDialogo(voz: VozPersonaje.brina, texto: 'Siete meses.'),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Cuando llegue al Borde, los Fragmentos viejos bajarán con ella.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Al pie de la hoja, un dibujo pequeño: una brújula.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Esto no lo entendía. Hasta que he visto lo que llevas en el bolsillo.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'La brújula vieja de Sora pesa un poco más.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.brina,
          texto: 'Quiere que subas. Tú y quien te la dio.'),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Antes de nada, habla con Irune.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
          voz: VozPersonaje.brina,
          texto: 'Y no le digas que te he mandado yo.'),
    ],
  );

  /// 5.2 — Irune no sube. Cuarenta años atrás subieron dos; bajó una.
  static const EscenaCinematica iruneNoSube = EscenaCinematica(
    id: '5.2',
    titulo: 'Irune no sube',
    flagDeSalida: 'escena_5_2_vista',
    flagsRequeridos: {'escena_5_1_vista'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Tejados. Noche. Irune riega las macetas de la azotea con una lata vieja.',
      ),
      PlanoDialogo(voz: VozPersonaje.irune, texto: 'Te esperaba antes.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Le enseñas la hoja. No la coge. La mira desde lejos.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Escucha.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
          voz: VozPersonaje.irune,
          texto: 'Hace cuarenta años subimos dos. Bajé una.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1600),
        textoLectura: 'Deja la lata en el suelo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Yo iba a quedarme arriba. Todos lo daban por hecho. Yo también.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto:
            'Una noche hubo niebla. Mucha. Y tuve miedo de no volver a ver esta ciudad.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Bajé. La otra se quedó.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoEleccion(
        voz: VozPersonaje.irune,
        opciones: [
          OpcionEleccion(
            textoJugador: '¿La otra es quien escribe?',
            textoRespuesta: 'Sí.',
            flagsAEstablecer: {'arco5_irune_pregunta'},
          ),
          OpcionEleccion(
            textoJugador: '¿Te arrepientes?',
            textoRespuesta: 'Todos los días. Y ninguno.',
            flagsAEstablecer: {'arco5_irune_arrepiente'},
          ),
          OpcionEleccion(
            textoJugador: '— no decir nada —',
            textoRespuesta: 'Gracias.',
            flagsAEstablecer: {'arco5_irune_silencio'},
          ),
        ],
      ),
      PlanoDialogo(
          voz: VozPersonaje.irune,
          texto: 'No me pidas que suba. No voy a subir.'),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Pero tampoco te voy a decir que no subas.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
          voz: VozPersonaje.irune,
          texto: 'Antes, ve al Archivo. Pregunta por la página de Iria.'),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Si el guardián te la enseña, es que ha llegado el momento.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Vuelve a coger la lata. Riega una maceta que ya estaba regada.',
      ),
    ],
  );

  /// 5.3 — El Archivo. Ulden guarda la página inédita de Iria: un camino
  /// escrito en coordenadas.
  static const EscenaCinematica elArchivo = EscenaCinematica(
    id: '5.3',
    titulo: 'El Archivo',
    flagDeSalida: 'escena_5_3_vista',
    flagsRequeridos: {'escena_5_2_vista', 'fun_02_introducida'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'El Archivo de la Sociedad. Un sótano largo bajo el cuartel de las Afueras. Estanterías hasta el techo. Huele a papel y a café frío.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.ulden,
          texto:
              'Cuidado con el tercer escalón. Lleva cuatrocientos años suelto.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura:
            'Un hombre mayor, con unas gafas en la frente y otras en la nariz.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto:
            'Ulden. Guardo esto. No viene nunca nadie, así que me alegro de verte.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto:
            'Te manda Irune. Lo sé porque traes la misma cara que traía ella.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(voz: VozPersonaje.ulden, texto: 'La página de Iria.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Silencio largo. Ulden se quita las gafas de la nariz. Se deja las de la frente.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto:
            'Iria de Tres Voces escribió mucho. Casi todo se publicó. Esto no.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3200),
        textoLectura:
            'Una caja de madera. Dentro, una sola página: una cuadrícula, dos ejes y cuatro puntos en tinta. (0, 0). (2, 3). (5, 3). (7, 6).',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto: 'Durante cuatrocientos años hemos creído que era un ejercicio.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto: 'No lo es. Es un camino.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoEleccion(
        voz: VozPersonaje.ulden,
        textoPrompt: '¿Qué ves?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Coordenadas',
            textoRespuesta:
                'Eso. Pares de números: el primero dice cuánto andas; el segundo, cuánto subes.',
            flagsAEstablecer: {'arco5_archivo_coordenadas'},
          ),
          OpcionEleccion(
            textoJugador: 'Un mapa',
            textoRespuesta:
                'Casi. Un mapa que no dibuja el paisaje: sólo dice cómo cambia.',
            flagsAEstablecer: {'arco5_archivo_mapa'},
          ),
          OpcionEleccion(
            textoJugador: 'No lo sé',
            textoRespuesta:
                'Nadie lo supo en cuatrocientos años. Tranquilidad.',
            flagsAEstablecer: {'arco5_archivo_nolose'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto:
            'El origen, el (0, 0), es el Borde Oscuro. Lo he comprobado yo mismo. Con un mapa, claro.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.ulden,
        texto:
            'Llévatela. Iria la escribió para quien fuera a subir. Hasta hoy no había nadie.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
          voz: VozPersonaje.ulden,
          texto: 'Y tráemela de vuelta. Aunque sea mojada.'),
    ],
  );

  /// 5.4 — La página de Iria. Leer la gráfica del camino: un llano a
  /// media subida.
  static const EscenaCinematica laPaginaDeIria = EscenaCinematica(
    id: '5.4',
    titulo: 'La página de Iria',
    flagDeSalida: 'escena_5_4_vista',
    flagsRequeridos: {'escena_5_3_vista', 'fun_03_introducida'},
    sonidoDeEntrada: 'motivo_sora',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Tejados. Sora y tú, sentados, con la página de Iria entre los dos. La Montaña al fondo.',
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Así que era esto.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Léela tú. A mí las gráficas me marean.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Unidos, los puntos hacen una línea con escalones: sube, se queda plana, vuelve a subir.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.sora,
        textoPrompt: '¿Qué pasa entre el 2 y el 5?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'No sube: es llano',
            textoRespuesta: 'Un descansillo. Ahí se duerme.',
            flagsAEstablecer: {'arco5_pagina_llano'},
          ),
          OpcionEleccion(
            textoJugador: 'Baja',
            textoRespuesta:
                'Mira otra vez. El segundo número no cambia: tres y tres. Es llano.',
          ),
          OpcionEleccion(
            textoJugador: 'Sube más deprisa',
            textoRespuesta: 'Tres y tres. No sube nada. Es llano.',
          ),
        ],
      ),
      PlanoDialogo(
          voz: VozPersonaje.sora,
          texto: 'Un llano a media subida. Iria dormía ahí.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Y lo último, del 5 al 7, sube tres de golpe. Lo más empinado.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura: 'Sora dobla la página con cuidado. Tarda en hablar.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Te lo prometí en el borde. Que subíamos juntos.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
          voz: VozPersonaje.sora, texto: 'Pensaba que tardaríamos años.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'No pasa nada. Las promesas no avisan.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 5.5 — La sombra de la Montaña. Brina mide la Montaña con un palo y
  /// su sombra, como Tales. Como Iria.
  static const EscenaCinematica laSombraDeLaMontana = EscenaCinematica(
    id: '5.5',
    titulo: 'La sombra de la Montaña',
    flagDeSalida: 'escena_5_5_vista',
    flagsRequeridos: {'escena_5_4_vista', 'geo_09_introducida'},
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'El Borde Oscuro. La última farola. Brina clava un palo en la tierra. Atardecer: las sombras son largas.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Iria midió la Montaña sin subir. Vamos a hacer lo mismo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'El palo mide dos metros. Su sombra, tres.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Y la sombra de la cumbre acaba justo a tres mil metros de la base.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.brina,
        textoPrompt: 'Mismo sol, misma forma. ¿Cuánto mide la Montaña?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'Dos mil metros',
            textoRespuesta: 'Dos mil. Lo mismo que le salió a Iria.',
            flagsAEstablecer: {'arco5_tales_bien'},
          ),
          OpcionEleccion(
            textoJugador: 'Cuatro mil quinientos metros',
            textoRespuesta:
                'Al revés. El palo es más bajo que su sombra; la Montaña, también. Dos mil.',
          ),
          OpcionEleccion(
            textoJugador: 'Dos mil novecientos noventa y nueve',
            textoRespuesta:
                'No se resta. Se multiplica por la misma razón: dos tercios. Dos mil.',
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto: 'Y la niebla está a mil doscientos. Ya ha bajado de la mitad.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Esto es lo que me gusta de Tales. No hace falta tocar las cosas para saber cuánto miden.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Brina arranca el palo y se lo pone al hombro.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.brina,
        texto:
            'Cuando subáis, yo me quedo aquí. Alguien tiene que mirar la niebla desde abajo.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 5.6 — Cruzar el Borde. Kai presta el termo de su madre. Sora cruza
  /// un borde por primera vez desde Kir.
  static const EscenaCinematica cruzarElBorde = EscenaCinematica(
    id: '5.6',
    titulo: 'Cruzar el Borde',
    flagDeSalida: 'escena_5_6_vista',
    flagsRequeridos: {'escena_5_5_vista'},
    sonidoDeEntrada: 'motivo_kai',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Antes del alba. El Borde Oscuro. Sora, con una mochila demasiado grande. Tú, con la brújula.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Alguien corre hacia vosotros desde la última farola. Kai.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.kai,
          texto: 'No os vais sin despediros. No es educado.'),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Toma.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Un termo abollado, con una pegatina del Puerto.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.kai,
        texto: 'Era de mi madre. Lo quiero de vuelta.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoEleccion(
        voz: VozPersonaje.kai,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Te lo devuelvo',
            textoRespuesta: 'Más te vale.',
            flagsAEstablecer: {'arco5_kai_termo'},
          ),
          OpcionEleccion(
            textoJugador: 'Ven con nosotros',
            textoRespuesta:
                'No. Alguien tiene que quedarse a ganar a los de abajo.',
            flagsAEstablecer: {'arco5_kai_invitado'},
          ),
          OpcionEleccion(
            textoJugador: '— chocar la mano —',
            textoRespuesta: 'Vale. Vale. Idos ya.',
            flagsAEstablecer: {'arco5_kai_mano'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura:
            'Kai se va sin mirar atrás. Sora mira la línea donde acaba la luz. No se mueve.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'En Kir también había un borde.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
          voz: VozPersonaje.sora,
          texto: 'Nunca lo crucé. Cuando quise, ya no había ciudad.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Da un paso. Luego otro. La farola queda detrás.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Ya está. Era sólo un paso.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
    ],
  );

  /// 5.7 — La niebla. En el llano de Iria aparece Velo, que borra los
  /// números que sabes. Dispara el combate (`DesafioKurz.velo`).
  static const EscenaCinematica laNiebla = EscenaCinematica(
    id: '5.7',
    titulo: 'La niebla',
    flagDeSalida: 'escena_5_7_vista',
    flagsRequeridos: {'escena_5_6_vista', 'alg_09_introducida'},
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'El llano de Iria. Mil doscientos metros. La niebla llega de golpe: blanca, espesa, fría.',
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'No veo nada.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Algo se mueve dentro de la niebla. Un Fragmento sin forma: cuando lo miras, los números que llevas encima se borran.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Contaste los pasos hasta aquí. Ya no recuerdas cuántos. Donde estaba el número, hay un hueco.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoVelo,
        texto: '¿Cuántos?',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoVelo,
        texto: 'No lo sabes. Aquí arriba nadie lo sabe.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Es un Fragmento viejo. De los que se esconden.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto:
            '{nombre}. Brina dice que lo que no se ve se puede nombrar. No sé qué significa.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.fragmentoVelo,
        texto: 'Nómbralo, si puedes.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 5.8 (victoria) — Velo se retira y aparece Aldara.
  static const EscenaCinematica detrasDeLaNieblaVictoria = EscenaCinematica(
    id: '5.8victoria',
    titulo: 'Detrás de la niebla',
    flagDeSalida: 'escena_5_8_vista',
    flagsRequeridos: {'victoria_velo'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'La niebla se retira ladera arriba, como un animal que no quiere pelea. Detrás, una mujer mayor con un farol apagado.',
      ),
      PlanoDialogo(voz: VozPersonaje.aldara, texto: 'Lo has nombrado.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Hacía mucho que nadie de abajo lo nombraba.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Venid. Está a punto de hacer frío de verdad.'),
    ],
  );

  /// 5.8 (derrota) — Aldara abre la niebla. Perder también sigue.
  static const EscenaCinematica detrasDeLaNieblaDerrota = EscenaCinematica(
    id: '5.8derrota',
    titulo: 'Detrás de la niebla',
    flagDeSalida: 'escena_5_8_vista',
    flagsRequeridos: {'derrota_velo'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'La niebla os rodea. Entonces se abre sola, como una cortina. En medio, una mujer mayor con un farol apagado.',
      ),
      PlanoDialogo(voz: VozPersonaje.aldara, texto: 'Suficiente.'),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Velo se retira ladera arriba.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'No te preocupes. A mí me costó once años.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Venid. Está a punto de hacer frío de verdad.'),
    ],
  );

  /// 5.9 — La Algebrista. Aldara: del lado de la Montaña. La brújula la
  /// hizo ella, para alguien que bajó.
  static const EscenaCinematica laAlgebrista = EscenaCinematica(
    id: '5.9',
    titulo: 'La Algebrista',
    flagDeSalida: 'escena_5_9_vista',
    flagsRequeridos: {'escena_5_8_vista'},
    sonidoDeEntrada: 'motivo_montana',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3200),
        textoLectura:
            'Una casa de piedra pegada a la roca, a mil quinientos metros. Dentro, una estufa y una mesa llena de papeles. Las paredes, escritas con tiza de arriba abajo.',
      ),
      PlanoDialogo(voz: VozPersonaje.aldara, texto: 'Aldara.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Abajo me llaman «el Algebrista». Nunca he sabido si es por no preguntar o por no subir a ver.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Brina te escribe.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Brina me contesta. No es lo mismo.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        textoPrompt: 'Una pregunta cada uno. Aquí arriba se piensa despacio.',
        opciones: [
          OpcionEleccion(
            textoJugador: '¿De qué lado estás?',
            textoRespuesta:
                'Del lado de la Montaña. Los Fragmentos viejos vienen aquí a esconderse. Yo me quedo para que no bajen.',
            flagsAEstablecer: {'arco5_aldara_lado'},
          ),
          OpcionEleccion(
            textoJugador: '¿Qué es Velo?',
            textoRespuesta:
                'Uno de los primeros. No come proporción: come lo que sabes. Te deja los huecos.',
            flagsAEstablecer: {'arco5_aldara_velo'},
          ),
          OpcionEleccion(
            textoJugador: '¿Por qué nos has llamado?',
            textoRespuesta:
                'Porque la niebla baja. Y porque yo sola ya no puedo subirla.',
            flagsAEstablecer: {'arco5_aldara_llamada'},
          ),
        ],
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Yo pregunto otra cosa.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: '¿Por qué la brújula?',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Aldara coge la brújula de tus manos. La gira. En la tapa hay una marca que no habías visto: una x pequeña.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Porque la hice yo. Hace cuarenta años. Para alguien que bajó.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 1800),
        textoLectura: 'Sora se queda muy quieta.',
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'A mí me la dio Irune.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Ya.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara, texto: 'Dormid. Mañana empezamos.'),
    ],
  );

  /// 5.10 — La primera lección. La x no es lo que no sabes: es el nombre
  /// que le pones mientras tanto.
  static const EscenaCinematica laPrimeraLeccion = EscenaCinematica(
    id: '5.10',
    titulo: 'La primera lección',
    flagDeSalida: 'escena_5_10_vista',
    flagsRequeridos: {'escena_5_9_vista', 'alg_11_introducida'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Mañana. La niebla queda abajo, como un mar. Aldara escribe en la pared con tiza.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Abajo contáis lo que veis. Tres manzanas. Cinco puentes.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Aquí arriba casi nada se ve. Hay que contar lo que no está.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2200),
        textoLectura:
            'Escribe una x grande. La rodea con un círculo, como en las cartas.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Esto no es un número que no sabes.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Es el nombre que le pones mientras tanto. Para poder hablar de él.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Cuando algo tiene nombre, puedes decir lo que sabes de él. Y lo que sabes, a veces, basta.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        textoPrompt:
            'Tengo el triple de años que Sora, más veinticuatro. Sora tiene trece. ¿Cómo lo escribes?',
        opciones: [
          OpcionEleccion(
            textoJugador: 'a = 3 · 13 + 24',
            textoRespuesta:
                'Eso. Y si no supieras la edad de Sora, pondrías una s en su sitio.',
            flagsAEstablecer: {'arco5_leccion_bien'},
          ),
          OpcionEleccion(
            textoJugador: '3 · a + 24 = 13',
            textoRespuesta:
                'Al revés. El triple es de los años de Sora, no de los míos.',
          ),
          OpcionEleccion(
            textoJugador: 'a = 3 · (13 + 24)',
            textoRespuesta:
                'Sin paréntesis. El triple de Sora, y luego los veinticuatro.',
          ),
        ],
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Sesenta y tres.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Sesenta y tres. No se lo digas a Irune: cree que tengo más.',
        pausaPrevia: Duration(milliseconds: 600),
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Abajo cazáis acertando el número. Aquí arriba se gana escribiendo la relación.',
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Iria lo sabía.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Iria lo inventó. Por eso no la entendió nadie.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 5.11 — La cisterna. El volumen del depósito de agua de nieve; y
  /// Aldara pregunta por Irune.
  static const EscenaCinematica laCisterna = EscenaCinematica(
    id: '5.11',
    titulo: 'La cisterna',
    flagDeSalida: 'escena_5_11_vista',
    flagsRequeridos: {'escena_5_10_vista', 'geo_11_introducida'},
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Detrás de la casa, un depósito de piedra redondo, medio lleno de agua de nieve.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Un metro de radio. Dos metros de agua. Con eso paso el invierno.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        textoPrompt: 'Pi, tres coma catorce. ¿Cuántos litros son?',
        opciones: [
          OpcionEleccion(
            textoJugador: '6280 litros',
            textoRespuesta:
                'Seis metros cúbicos y pico. Seis mil doscientos ochenta litros.',
            flagsAEstablecer: {'arco5_cisterna_bien'},
          ),
          OpcionEleccion(
            textoJugador: '6,28 litros',
            textoRespuesta: 'Eso son metros cúbicos. Cada uno, mil litros.',
          ),
          OpcionEleccion(
            textoJugador: '12 560 litros',
            textoRespuesta:
                'Eso es la pared, no el agua. El volumen es la base por la altura.',
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Si no nieva, no llega.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Aldara no te mira cuando pregunta.',
      ),
      PlanoDialogo(voz: VozPersonaje.aldara, texto: '¿Cómo está?'),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Riega macetas ya regadas',
            textoRespuesta: 'Siempre lo hizo.',
            flagsAEstablecer: {'arco5_irune_macetas'},
          ),
          OpcionEleccion(
            textoJugador: 'Dice que no va a subir',
            textoRespuesta: 'Ya lo sé. No se lo pido.',
            flagsAEstablecer: {'arco5_irune_no_sube'},
          ),
          OpcionEleccion(
            textoJugador: 'Creo que te echa de menos',
            textoRespuesta: 'Eso lo dices tú. Pero gracias.',
            flagsAEstablecer: {'arco5_irune_echa_de_menos'},
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Cuando bajéis, le llevaréis una cosa.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 5.12 — Lo que escribió Iria. La otra mitad de la página: un sistema
  /// y una frase que la Sociedad no quiso publicar.
  static const EscenaCinematica loQueEscribioIria = EscenaCinematica(
    id: '5.12',
    titulo: 'Lo que escribió Iria',
    flagDeSalida: 'escena_5_12_vista',
    flagsRequeridos: {'escena_5_11_vista', 'alg_12_introducida'},
    loopDeFondo: 'musica_ceremonia',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 3000),
        textoLectura:
            'Noche. La estufa. Aldara saca una caja igual que la del Archivo. Dentro, otra página. La letra es la misma.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Ulden tiene la primera mitad. Yo, la segunda.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Iria la partió en dos para que nadie la leyera sin subir.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2400),
        textoLectura: 'Dos igualdades con dos letras. Y debajo, una frase.',
      ),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        textoPrompt: 'x + y = 7. x − y = 1. ¿Cuánto vale x?',
        opciones: [
          OpcionEleccion(
            textoJugador: '4',
            textoRespuesta:
                'Cuatro, y la y vale tres. Cuatro jornadas de subida; tres de bajada.',
            flagsAEstablecer: {'arco5_sistema_bien'},
          ),
          OpcionEleccion(
            textoJugador: '3',
            textoRespuesta:
                'Ése es y. Suma las dos igualdades: la y desaparece. x vale cuatro.',
          ),
          OpcionEleccion(
            textoJugador: '7',
            textoRespuesta:
                'Siete es la suma. Suma las dos igualdades y divide entre dos: cuatro.',
          ),
        ],
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Las cuentas dicen cuánto se tarda. La frase dice para qué subir.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Aldara no mira la página. Se la sabe.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: '«El Uno no volverá a ser uno. Será muchos que se entienden.»',
        pausaPrevia: Duration(milliseconds: 1200),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Silencio. La estufa cruje.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.sora, texto: 'Eso es lo que dicen los Opacos.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'No. Los Opacos dicen que da igual que no se entiendan.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Iria decía que el trabajo es ése: que se entiendan.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Por eso no se publicó. A la Sociedad le gusta más reparar que entender.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: '¿Y tú qué crees?'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto:
            'Que llevo cuarenta años aquí arriba escribiendo relaciones. Saca la cuenta.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
    ],
  );

  /// 5.13 — Bajar. Velo ha retrocedido, no se ha ido. Una carta para
  /// Irune.
  static const EscenaCinematica bajar = EscenaCinematica(
    id: '5.13',
    titulo: 'Bajar',
    flagDeSalida: 'escena_5_13_vista',
    flagsRequeridos: {'escena_5_12_vista'},
    sonidoDeEntrada: 'motivo_sora',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Amanecer. La niebla se ha retirado cien metros ladera arriba. No es mucho. Es algo.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.aldara,
          texto: 'Velo ha retrocedido. No se ha ido.'),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Volveréis. Cuando sepáis más letras.',
        pausaPrevia: Duration(milliseconds: 700),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Te da un sobre cerrado, sin nombre.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'Para Irune. Si lo abres, no te vuelvo a abrir la puerta.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.aldara,
        texto: 'La brújula quédatela. Ahora es tuya de verdad.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoEleccion(
        voz: VozPersonaje.aldara,
        opciones: [
          OpcionEleccion(
            textoJugador: 'Gracias, Aldara',
            textoRespuesta:
                'Gracias a ti. Hacía años que no hablaba en voz alta con nadie.',
            flagsAEstablecer: {'arco5_despedida_gracias'},
          ),
          OpcionEleccion(
            textoJugador: 'Ven con nosotros',
            textoRespuesta:
                'Alguien tiene que quedarse arriba. Irune lo sabía. Por eso bajó.',
            flagsAEstablecer: {'arco5_despedida_invitacion'},
          ),
          OpcionEleccion(
            textoJugador: '— asentir —',
            textoRespuesta: 'Eso. Aquí arriba se habla poco.',
            flagsAEstablecer: {'arco5_despedida_silencio'},
          ),
        ],
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Bajáis. Sora va delante. En el llano de Iria se para y mira atrás.',
      ),
      PlanoDialogo(
          voz: VozPersonaje.sora,
          texto: 'Pensaba que la Montaña era el final.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'Es otra ciudad. Más pequeña. Con una sola persona.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 5.14 — La carta de Irune. Cierre del Arco V.
  static const EscenaCinematica laCartaDeIrune = EscenaCinematica(
    id: '5.14',
    titulo: 'La carta de Irune',
    flagDeSalida: 'escena_5_14_vista',
    flagsRequeridos: {'escena_5_13_vista'},
    esCierreAmable: true,
    loopDeFondo: 'musica_amanecer_final',
    planos: [
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'Tejados. Tarde. Irune en la azotea, como siempre, con la lata.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Le das el sobre. Esta vez lo coge.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2800),
        textoLectura:
            'Lo abre. Dentro no hay letras sueltas: hay palabras. Una sola línea.',
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Irune lee. Deja la lata en el suelo.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Escucha.',
        pausaPrevia: Duration(milliseconds: 1000),
      ),
      PlanoDialogo(
          voz: VozPersonaje.irune, texto: 'Dice que hice bien en bajar.'),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Que alguien tenía que enseñar a los de abajo.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura: 'Irune mira la Montaña mucho rato.',
      ),
      PlanoDialogo(voz: VozPersonaje.irune, texto: 'Cuarenta años.'),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Y me lo dice en una línea.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2000),
        textoLectura: 'Guarda la carta en el bolsillo del pecho.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Devuélvele la página a Ulden. Y el termo a Kai.',
      ),
      PlanoDialogo(
        voz: VozPersonaje.irune,
        texto: 'Y luego descansa. Vas a subir más veces.',
        pausaPrevia: Duration(milliseconds: 800),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura:
            'En el borde norte, Sora, con las piernas colgando. Te hace sitio.',
      ),
      PlanoDialogo(voz: VozPersonaje.sora, texto: 'Cumplí.'),
      PlanoDialogo(
        voz: VozPersonaje.sora,
        texto: 'La próxima vez, subes tú delante.',
        pausaPrevia: Duration(milliseconds: 900),
      ),
      PlanoAmbiente(
        duracion: Duration(milliseconds: 2600),
        textoLectura: 'FIN DEL ARCO V. LA MONTAÑA.',
      ),
      PlanoCierreAmable(textoBoton: 'HASTA ENTONCES'),
    ],
  );

  static const List<EscenaCinematica> todas = [
    laCarta,
    iruneNoSube,
    elArchivo,
    laPaginaDeIria,
    laSombraDeLaMontana,
    cruzarElBorde,
    laNiebla,
    detrasDeLaNieblaVictoria,
    detrasDeLaNieblaDerrota,
    laAlgebrista,
    laPrimeraLeccion,
    laCisterna,
    loQueEscribioIria,
    bajar,
    laCartaDeIrune,
  ];
}
