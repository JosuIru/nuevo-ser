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
  };
}
