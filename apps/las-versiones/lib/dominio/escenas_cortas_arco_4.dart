import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'escenas_arco_4.dart';
import 'escenas_cortas.dart';
import 'voz_personaje.dart';

/// Versiones cortas de las escenas largas del Arco 4. Mismas reglas que
/// las del Arco 1 (ver `escenas_cortas.dart`).
///
/// En los momentos cumbre (4.C, 4.F, 4.G.2, 4.H.2, 4.Z) se condensa sin
/// añadir nada: las frases que cierran cada escena van literales. No se
/// añaden hechos históricos (material pendiente del comité:
/// REFORMULACION-1512, JOANA-DE-RONCAL, PARED-MEDIANERA-1394).

const _breve = Duration(seconds: 3);
const _media = Duration(seconds: 4);
const _larga = Duration(seconds: 6);

final Map<String, EscenaCinematica> escenasCortasArco4 = {
  // 4.0.1 Apertura del arco.
  EscenasArco4.aperturaDelArco4.id: EscenasCortas.corta(EscenasArco4.aperturaDelArco4, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Despacho de Isaura, primera semana de junio.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Aprendiz III. Este arco son seis semanas. Es el último antes de la '
          'graduación.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Si me gradúo.'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Si te gradúas.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Olite, con Aitor. La corte de Carlos III el Noble. Una persona '
          'concreta, no el rey. Tú eliges qué persona. Después, las tres '
          'comunidades en Estella, con Karim.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Y al final leerás cartas de Catalina de Foix. No como Brecha.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No vamos a tocar 1512.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'No. Para que entiendas lo que decides cuando decides no entrar todavía.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tasio te ha escrito. Cuando lo leas, decides tú qué haces.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Maren guarda el sobre en la mochila sin abrir. Sale. Isaura mira '
          'por la ventana norte. La sonrisa pequeñísima vuelve durante un segundo.',
    ),
  ]),

  // 4.1.3 Joana de Roncal.
  EscenasArco4.joanaDeRoncal.id: EscenasCortas.corta(EscenasArco4.joanaDeRoncal, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Sala de cuentas, palacio de Olite. Pagos a personal, compras, '
          'regalos. Trabajo lento.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Aparece gente que no conozco: cocineros, escribas, médicos. La '
          'mayoría se nombran una vez y desaparecen. Hay una que aparece muchas veces.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Joana de Roncal.'),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Doncella de cámara de 1402 a 1412, primero de la reina Leonor, '
          'después de la infanta Blanca. Viaja con la corte. En 1412 deja de '
          'aparecer en los registros.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Diez años de palacio. Después nada. Aitor tenía razón. Esta es mi Brecha.',
    ),
    const PlanoDialogo(voz: VozPersonaje.aitor, texto: '¿Quién?'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Joana de Roncal. Doncella de cámara entre 1402 y 1412.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.aitor,
      texto: 'No la conozco. Eso es buena señal.',
    ),
  ]),

  // 4.1.4 Las trazas de una vida.
  EscenasArco4.lasTrazasDeUnaVida.id: EscenasCortas.corta(EscenasArco4.lasTrazasDeUnaVida, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Mesa de Trabajo, varias jornadas. Maren reúne cada registro de '
          'Joana de Roncal.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: '1402: su hermano paga el viaje al palacio. 1407: permiso para '
          'visitar a su madre enferma. 1408: telas para un vestido especial. 1412: '
          'deja de aparecer. Ese año, limosnas a la familia de Roncal «por la '
          'pérdida de su hija».',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'El vestido de 1408 podría sugerir compromiso. Pero el matrimonio no '
          'aparece. Sigue siendo «doncella» en los registros.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Y desaparece en 1412 — quizá murió, quizá se retiró, quizá pasó a otro '
          'servicio del que no tenemos registro.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Diez años en palacio. Una mujer joven que vio crecer a las infantas. Que '
          'pudo haber estado a punto de casarse y no se casó. Que probablemente murió '
          'antes de los treinta.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Eso es lo que se puede saber.',
    ),
  ]),

  // 4.A.1 Cartas de Catalina.
  EscenasArco4.cartasDeCatalina.id: EscenasCortas.corta(EscenasArco4.cartasDeCatalina, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Biblioteca del Archivo. Cinco cartas conservadas de Catalina de '
          'Foix. Esto es lectura, no Brecha.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'De 1503 a 1511 el tono cambia: de los asuntos domésticos a la '
          'prudencia ante «las pretensiones del rey católico». En 1511, Catalina '
          'escribe a su madre.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Si Fernando entra en Pamplona, el reino se acaba.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Catalina sabía que algo venía. Lo escribió a su madre con miedo concreto.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Lo que sigue está en la siguiente capa. Una capa que no me toca.',
    ),
  ]),

  // 4.A.2 Esto es para cuando seas mayor.
  EscenasArco4.paraCuandoSeasMayor.id: EscenasCortas.corta(EscenasArco4.paraCuandoSeasMayor, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Despacho de Isaura, esa tarde. Maren lleva sus notas de las cartas.',
    ),
    // BORRADOR (nuevo): la lectura de Maren del guion es la primera opción;
    // la segunda es la tentación de leer las cartas sólo como política.
    const PlanoEleccion(
      voz: VozPersonaje.isaura,
      textoPrompt: '¿Qué tienes?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Que sabían lo que venía. Y que la carta a su madre tiene miedo '
              'personal: pierden el mundo en el que vivían.',
          textoRespuesta: 'Sí.',
          vozRespuesta: VozPersonaje.isaura,
          flagsAEstablecer: {'cartas_catalina_miedo_personal'},
        ),
        OpcionEleccion(
          textoJugador: 'Que es un asunto de reyes y alianzas. Política.',
          textoRespuesta: 'Relee la carta a su madre. No es sólo política.',
          vozRespuesta: VozPersonaje.isaura,
          flagsAEstablecer: {'cartas_catalina_solo_politica'},
        ),
      ],
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Esto es Brecha grande, ¿verdad?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Es Brecha enorme. Pero no para hoy. Para trabajar 1512 con honestidad hace '
          'falta haber trabajado primero todo lo anterior.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Esto es para cuando sea mayor, ¿verdad?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Esto es para cuando seas mayor.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Y no tienes que ser tú quien la trabaje. Otros vendrán. Eso no es derrota.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'El oficio es relevo. No es protagonismo.',
    ),
  ]),

  // 4.B.2 Karim sobre los responsa.
  EscenasArco4.karimSobreLosResponsa.id: EscenasCortas.corta(EscenasArco4.karimSobreLosResponsa, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Mesa de Trabajo en Estella. Archivos notariales, responsa '
          'rabínicos, documentación mudéjar.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Los responsa: cartas pidiendo consejo a un rabino. La respuesta se '
          'conserva; el problema queda implícito en ella. Te dicen lo que pasaba en '
          'la calle.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Un responsum de 1379. Un comerciante judío de Estella pactó con un '
          'panadero cristiano el pan ácimo de Pascua. El cristiano cobró y no '
          'entregó. ¿Puede demandarlo en tribunal cristiano?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'El rabino responde que sí, pero recomienda mediación previa con el '
          'alcalde de la villa para no escalar.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Eso me dice más que diez páginas de tratado teórico. La gente vivía '
          'mezclada. A veces el pacto se rompía. Los caminos para resolverlo eran '
          'múltiples.',
    ),
  ]),

  // 4.C Antonio termina la frase.
  EscenasArco4.antonioTerminaLaFrase.id: EscenasCortas.corta(EscenasArco4.antonioTerminaLaFrase, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Cocina de casa, una noche. Maren seca platos. Antonio friega. '
          'Varios minutos sin hablar.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Hace cuatro meses, en esta cocina, te dije «Maren» y después dije '
          '«olvídalo». Te voy a terminar la frase ahora.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Iba a decirte que verte crecer en este oficio me ha dado más miedo del '
          'que esperaba.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Porque veo que vas a pasar la vida con preguntas que la mayoría no se '
          'hace. Y las preguntas tienen precio. Soledad. A ratos.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Te arrepientes de haberme empujado?'),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'No. No te empujé. Te leí cuentos. Tú decidiste el oficio.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Me has enseñado tú.'),
    const PlanoDialogo(voz: VozPersonaje.antonio, texto: 'Las dos a las dos.'),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Aita ha terminado su frase de hace cuatro meses. Soledad a ratos. Lo '
          'dijo. Y le creo. Pero también dijo otra cosa. Las dos a las dos.',
    ),
  ]),

  // 4.D Naia con su cuaderno.
  EscenasArco4.naiaConSuCuaderno.id: EscenasCortas.corta(EscenasArco4.naiaConSuCuaderno, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Sábado. Naia entra en el cuarto de Maren con un cuaderno pequeño '
          'rosa, nuevo. Diez preguntas con letra de niña de ocho años.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.naia,
      texto: 'Tú tienes un cuaderno con preguntas. Yo me he hecho uno también.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.naia,
      texto: '«¿Por qué se mueren las personas en orden raro?»',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No sé.'),
    const PlanoDialogo(
      voz: VozPersonaje.naia,
      texto: '«¿Las cosas bonitas son siempre verdad?»',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No.'),
    const PlanoDialogo(voz: VozPersonaje.naia, texto: 'Las otras me las contesto sola.'),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Mi hermana de ocho años tiene cuaderno propio. Una de sus preguntas la '
          'aprendió de mí, sin que yo lo planeara. Se va a contestar sola.',
    ),
  ]),

  // 4.F El cuaderno de Isaura.
  EscenasArco4.elCuadernoDeIsaura.id: EscenasCortas.corta(EscenasArco4.elCuadernoDeIsaura, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Despacho de Isaura, días antes de la graduación. Isaura saca su '
          'cuaderno marrón viejo y lo abre por una página de marzo de 1991.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: '¿Cómo distingo lo que sé de lo que quiero saber? Tasio me preguntó hoy '
          'si soy cobarde por preferir Probable a Sólido. ¿Lo soy?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Mi compañero de Aprendizaje. Tasio Iribarrena. Murió en 1996. El Tasio '
          'de ahora se llama así por coincidencia familiar. Lo afectó todo.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Le perdoné cosas que probablemente no debía haber perdonado. Quizá si '
          'hubiera sido más exigente, no se habría ido así. Quizá sí. No lo sé.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Otra página. Octubre de 2024. Una sola pregunta.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Si Maren llegara a una versión propia de la Brecha del incendio, ¿podría '
          'yo aceptar mi propia versión revisada con humildad? ¿O me he vuelto '
          'demasiado vieja para revisar?',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No es vejez.'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Eso lo decido yo.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Si algún día un alumno tuyo te enseña algo que tú no habías visto, '
          'recuérdate que no es derrota. Es relevo.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Gracias por enseñármelas.'),
  ]),

  // 4.G.2 El segundo encuentro con Tasio.
  EscenasArco4.elSegundoEncuentroConTasio.id:
      EscenasCortas.corta(EscenasArco4.elSegundoEncuentroConTasio, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Sede de Resolutiva, Tudela. Una oficina pequeña. Sólo están ellos dos.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'Te voy a hacer la oferta. Sin adornos. Cuando te gradúes, Resolutiva '
          'tiene un puesto para ti. Porque eres la única persona que ha trabajado esa '
          'Brecha en seis años llegando a algo nuevo.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: '¿No estás contratando una versión más joven de ti?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'Buena pregunta. Honestamente: no lo sé. Tú no eres como yo. Yo a tu edad '
          'ya estaba pensando en cómo romperlo. Tú estás pensando en cómo profundizarlo.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'No te ofrezco esto como gancho. Te lo ofrezco como opción. Si en un año '
          'no me has contestado, asumiré que no.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Te voy a pensar. Es probable que no te conteste.',
    ),
    const PlanoDialogo(voz: VozPersonaje.tasio, texto: 'También vale.'),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'Sea cual sea tu decisión, no la tomes para complacer a Isaura. Ni para '
          'incomodarla. Ni para complacerme a mí. Ni para incomodarme.',
    ),
    const PlanoDialogo(voz: VozPersonaje.tasio, texto: 'Vas a ser buena.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Eso ya me lo dijiste.'),
  ]),

  // 4.H.2 La ceremonia — el voto se conserva entero en un solo plano.
  EscenasArco4.laCeremonia.id: EscenasCortas.corta(EscenasArco4.laCeremonia, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: '29 de junio, mediodía. Patio del Archivo, junto al brocal del pozo. '
          'Los Cronistas en semicírculo. Al fondo, Iratxe, Antonio, Naia y Eider.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.begona,
      texto: 'Maren Lozano. Aprendiz III. Hoy te graduamos como Cronista joven del '
          'Archivo. Pronuncias el voto del oficio.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Prometo formular preguntas honestas. Escuchar las fuentes en lo que dicen '
          'y en lo que callan. Anclar mis afirmaciones en evidencia. Declarar mis '
          'niveles de confianza con honestidad.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Defender mis versiones ante el Concilio. Aceptar las correcciones '
          'razonables. No inventar lo que no sé. No callar lo que sé.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'No usar a los muertos como ventrílocuos. Y mantener vivo el oficio '
          'mientras pueda hacerlo bien.',
    ),
    const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Bienvenida.'),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Maren coge el cuaderno blanco. Tiembla un poco. Aplauden. Al fondo, '
          'Iratxe llora en silencio. Naia mira con la boca abierta.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.begona,
      texto: 'Cronista. Por hoy ya está. Mañana es el primer día.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Cronista.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Te dejo sola un rato. Cuando salgas, ven a verme al despacho.',
    ),
  ]),

  // 4.Z El patio vacío — cierre del MVP.
  EscenasArco4.elPatioVacio.id: EscenasCortas.corta(EscenasArco4.elPatioVacio, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'El patio del Archivo está vacío. Maren se sienta junto al brocal y '
          'abre el cuaderno de Aprendiz I.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'El primer apunte: «No sabemos cómo se llamaban. Pero sé que '
          'enterraron a alguien que les importaba.» Las manos del Pirineo. Joana de '
          'Roncal. La pared medianera de Estella.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Cuaderno de Aprendiz I. Cerrado el 29 de junio.',
    ),
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Abre el cuaderno blanco nuevo. La primera página en blanco.',
    ),
    const PlanoDialogo(voz: VozPersonaje.vozDeFuente, texto: 'Hoy empiezo de cero.'),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'No es verdad. No empiezo de cero.',
    ),
    const PlanoDialogo(voz: VozPersonaje.vozDeFuente, texto: 'Empiezo de aquí.'),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Maren camina hacia el despacho de Isaura. El patio queda vacío. '
          'LAS VERSIONES — ARCO 4 — CERRADO. FIN DEL MVP.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Maren tiene catorce años recién cumplidos. Su carrera de Cronista '
          'empieza ahora. Lo que pase después pertenece a otra historia.',
    ),
    const PlanoAmbiente(duracion: _breve, textoLectura: 'Gracias por jugar.'),
  ]),
};
