import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'escenas_arco_3.dart';
import 'escenas_cortas.dart';
import 'voz_personaje.dart';

/// Versiones cortas de las escenas largas del Arco 3. Mismas reglas que
/// las del Arco 1 (ver `escenas_cortas.dart`).
///
/// 3.6.x es la Brecha del incendio de la judería de Tudela de 1378
/// (TUDELA-1378, pendiente de validación del comité): ahí sólo se
/// condensa, sin elecciones ni réplicas nuevas, y se conservan literales
/// víctimas, cifras, nombres y el silencio de tres semanas como dato.

const _breve = Duration(seconds: 3);
const _media = Duration(seconds: 4);
const _larga = Duration(seconds: 6);

final Map<String, EscenaCinematica> escenasCortasArco3 = {
  // 3.0.1 Apertura del arco.
  EscenasArco3.aperturaDelArco.id: EscenasCortas.corta(EscenasArco3.aperturaDelArco, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Despacho de Isaura. Carpetas de Brechas pendientes.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Aprendiz II. Este arco son tres meses. Vas a viajar mucho. San '
          'Cernin para empezar. Después Tudela. Leyre. Roncesvalles. Estella.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Y al final del arco hay una Brecha que vas a tener que trabajar. '
          'La del incendio de la judería de Tudela de 1378.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿La que rompió a Tasio contigo?'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Esa.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Por qué me tocas a mí?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Porque ahora mismo eres la persona del Archivo que puede llegar a '
          'una versión nueva sin estar atrapada en la mía o en la suya.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No estoy segura de poder.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Yo tampoco lo estoy. Pero tienes tres meses para prepararte.',
    ),
  ]),

  // 3.1.2 Tres lenguas.
  EscenasArco3.tresLenguas.id: EscenasCortas.corta(EscenasArco3.tresLenguas, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Mesa de Trabajo. Tres documentos: el Fuero de Pamplona-San '
          'Cernin (1129), en latín jurídico; una carta de queja de la Navarrería '
          'al rey Sancho VI, en romance navarro; y una regla de los burgueses de '
          'San Cernin, en occitano gascón.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Tres lenguas para tres comunidades en la misma ciudad.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Yo pensaba que había una iglesia, un señor, un castillo. Pero aquí '
          'había tres comunidades con sus propios fueros, peleadas entre sí, y tres '
          'lenguas escritas a la vez. ¿Por qué no sabía esto?',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Los conflictos entre los tres burgos duraron casi dos siglos y '
          'se resolvieron sólo por el Privilegio de la Unión de 1423 — Sólido. El '
          'plurilingüismo de la Iruña medieval es estructural, no accidental — '
          'Probable.',
    ),
  ]),

  // 3.2.3 Las fuentes árabes.
  EscenasArco3.lasFuentesArabes.id: EscenasCortas.corta(EscenasArco3.lasFuentesArabes, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Museo de Tudela. Sobre la mesa: Ibn Hayyán, Al-Razi, una crónica '
          'anónima, inscripciones árabes locales, la Crónica de Alfonso III y '
          'material arqueológico de la alcazaba.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Los Banu Qasi eran muladíes — descendientes hispano-godos '
          'convertidos. Su nombre Qasi viene de Casio, el conde visigodo que se '
          'convirtió al islam tras la invasión.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Eran cristianos hace tres generaciones. Después fueron musulmanes '
          'plenos. Después se aliaron con vascones de Pamplona contra Córdoba. '
          'Después fueron derrotados por Córdoba y reabsorbidos.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: '¿Eran "musulmanes pero hispanos"? ¿"Hispanos pero musulmanes"? Las '
          'dos cosas a la vez. La pregunta presupone una dicotomía que en su época '
          'no funcionaba así.',
    ),
  ]),

  // 3.2.5 El encuentro con Tasio.
  EscenasArco3.elEncuentroConTasio.id: EscenasCortas.corta(EscenasArco3.elEncuentroConTasio, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Tasio, 32 años, invita a Maren a un café. Aitor se queda en su '
          'mesa: si le necesita, que le mire. Tasio paga los dos cafés.',
    ),
    const PlanoDialogo(voz: VozPersonaje.tasio, texto: 'Esto no es soborno. Es protocolo.'),
    // BORRADOR (nuevo): la pregunta de Tasio se contesta eligiendo. La
    // primera opción es la respuesta del guion; las réplicas son las dos
    // mitades de la frase de Tasio en el guion.
    const PlanoEleccion(
      voz: VozPersonaje.tasio,
      textoPrompt: '¿Crees que el Archivo es reformable desde dentro?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'No sé.',
          textoRespuesta: 'Esa respuesta es buena. La gente que está segura de que '
              'sí está mintiendo. La gente que está segura de que no está vendiendo '
              'el oficio entero.',
          vozRespuesta: VozPersonaje.tasio,
          flagsAEstablecer: {'tasio_reformable_no_se'},
        ),
        OpcionEleccion(
          textoJugador: 'Sí, seguro.',
          textoRespuesta: 'La gente que está segura de que sí está mintiendo.',
          vozRespuesta: VozPersonaje.tasio,
          flagsAEstablecer: {'tasio_reformable_si'},
        ),
        OpcionEleccion(
          textoJugador: 'No.',
          textoRespuesta: 'La gente que está segura de que no está vendiendo el '
              'oficio entero.',
          vozRespuesta: VozPersonaje.tasio,
          flagsAEstablecer: {'tasio_reformable_no'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: '¿Tú quieres ser Isaura? La pregunta no es trampa. Te la dejo para '
          'que la masques sola.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'Cuando trabajes la Brecha del incendio de la judería de Tudela del '
          '1378, recuérdame. La Brecha tiene tres lecturas: la de Isaura, la mía, y '
          'la tercera. La tercera es la tuya, si la haces. No la fuerces. Pero no la '
          'evites tampoco.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.tasio,
      texto: 'Si llegas a una versión propia, defiéndela bien. Si no llegas, no te '
          'inventes una para complacer a nadie. Ni a Isaura, ni a mí.',
    ),
    const PlanoDialogo(voz: VozPersonaje.tasio, texto: 'Vas a ser buena. Tú decide a qué.'),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Tasio sale. Maren se queda con el café a medio terminar. Aitor '
          'la mira por primera vez. No comenta.',
    ),
    const PlanoDialogo(voz: VozPersonaje.aitor, texto: '¿Volvemos al museo?'),
  ]),

  // 3.2.7 Reconstrucción y Concilio (Banu Qasi).
  EscenasArco3.reconstruccionYConcilioBanuQasi.id:
      EscenasCortas.corta(EscenasArco3.reconstruccionYConcilioBanuQasi, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Salón del Concilio. Karim, Aitor y Joana. Maren presenta su '
          'reconstrucción de los Banu Qasi.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Dinastía muladí en la Ribera del Ebro entre los s. VIII y X — '
          'Sólido. Origen en Casio — Probable. Alianzas alternantes con '
          'Pamplona-vascones y con Córdoba — Sólido. Rebelión del s. IX como '
          'soberanía local fronteriza, no movimiento religioso — Probable.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Identidad plenamente musulmana en el s. IX aunque su origen '
          'reciente fuera hispano-cristiano: la dicotomía moderna "musulmán vs '
          'hispano" no aplica al periodo — Sólido como afirmación metodológica.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Karim pregunta qué fuentes se han conservado y cuáles se han '
          'perdido, y por qué. Maren contesta con cuidado. Sellada.',
    ),
  ]),

  // 3.3.4 Cuándo se escribió.
  EscenasArco3.cuandoSeEscribio.id: EscenasCortas.corta(EscenasArco3.cuandoSeEscribio, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Maren compara las versiones de la leyenda de Virila: la del s. '
          'XIII, una del XV, una del XVII.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'La leyenda se escribe en el s. XIII. Leyre en el s. XIII estaba en '
          'declive. Había perdido su importancia política. Los reyes ya no se '
          'enterraban aquí.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Esos trescientos años no son los del milagro. Son los que separan la '
          'fundación de Leyre del momento de redacción de la leyenda.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'La leyenda de Virila no cuenta lo que pasó en el s. IX. Cuenta cómo '
          'Leyre del s. XIII se sentía mirando al s. IX.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Primera documentación en un códice del s. XIII — Sólido. Un '
          'abad Virila en listas del s. IX — Sólido. La conexión entre los dos no '
          'puede establecerse — Sólido (la incertidumbre). La leyenda informa más '
          'del s. XIII que del s. IX — Probable.',
    ),
  ]),

  // 3.4.3 Las dos versiones.
  EscenasArco3.lasDosVersiones.id: EscenasCortas.corta(EscenasArco3.lasDosVersiones, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Fuentes del s. IX (Vita Karoli de Eginardo, Annales Regni '
          'Francorum): una emboscada vascona a la retaguardia carolingia que volvía '
          'de Zaragoza. Murió, entre otros, un tal Rolando.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'La Chanson de Roland (h. 1100): sarracenos en vez de vascones, '
          'Rolando héroe con Durendal y olifante, la traición de Ganelón, combate '
          'cristiano-musulmán.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'La Chanson cambia tres cosas grandes: vascones por moros; emboscada '
          'por traición; conflicto político por conflicto religioso.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Los tres cambios apuntan en la misma dirección. La Chanson reescribe '
          'Roncesvalles para que encaje con las Cruzadas — que están empezando '
          'precisamente cuando se escribe.',
    ),
  ]),

  // ─── TUDELA-1378: sólo condensado, sin elecciones ni réplicas nuevas ──

  // 3.6.1 Isaura presenta.
  EscenasArco3.isauraPresenta.id: EscenasCortas.corta(EscenasArco3.isauraPresenta, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Despacho de Isaura, principios de mayo. Una carpeta gruesa '
          'sobre la mesa — la carpeta de la Brecha.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'En noviembre de 1378, el barrio judío de Tudela ardió en una noche. '
          'Murieron al menos dieciocho personas, según lo que se documenta. Cuatro '
          'casas destruidas completas, otras siete dañadas. La sinagoga sufrió '
          'daños menores.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Las actas del Concejo del día siguiente lo atribuyen a "personas no '
          'identificadas, ajenas a la comunidad cristiana de la villa". El padrón '
          'judío posterior — incompleto — registra las muertes. Una carta de un '
          'superviviente a un correligionario de Zaragoza, dieciocho meses después, '
          'habla de "los señores del Concejo que callaron tres semanas antes y no '
          'callaron tres semanas después".',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Yo digo: Probable. Hay indicios sólidos pero no documentación '
          'directa. Tasio dice Sólido. E identifica por nombre a tres miembros del '
          'Concejo del 1378 como responsables de la complicidad activa.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Yo dije que la evidencia de Tasio era circunstancial. Que la '
          'correlación de presencias no es prueba. Que el testimonio inquisitorial '
          'es de fuente mediada y posiblemente extraído bajo presión. Que para '
          'identificar nominalmente a personas como responsables de un asesinato '
          'colectivo hace falta más.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tasio pensó que yo era cobarde. No lo sé. Lo que sé es que prefiero '
          'quedarme en Probable que afirmar Sólido lo que es sólo Probable.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Te paso la carpeta. Tienes seis semanas. Llega a tu propia versión. '
          'Sin imitar la mía, sin imitar la suya. Y defiéndela.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Si no llegas a una propia, lo declaras. "He revisado el material. He '
          'visto los argumentos de las dos versiones. No tengo elementos para llegar '
          'a una tercera. Mi conclusión es que se mantiene la disputa."',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Karim ha pedido invitar a Tasio al Concilio de cierre como observador '
          'externo. Si no la sostienes con Tasio mirando, no la has sostenido del '
          'todo.',
    ),
    const PlanoAmbiente(duracion: _breve, textoLectura: 'Maren coge la carpeta. Pesa.'),
  ]),

  // 3.6.2 Las fuentes de 1378 — se conservan literales las cuatro notas.
  EscenasArco3.lasFuentesDe1378.id: EscenasCortas.corta(EscenasArco3.lasFuentesDe1378, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Mesa de Trabajo. Ocho montones: actas del Concejo del periodo, '
          'padrón parcial de la judería, carta del superviviente, fragmento de '
          'testimonio inquisitorial, correspondencia del rey Carlos II al Concejo, '
          'informes arqueológicos del barrio, casos peninsulares del s. XIV y las '
          'dos reconstrucciones publicadas previas.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Día cuatro. Tasio tiene razón en una cosa. La correlación de '
          'presencias en sesiones del Concejo previas al incendio NO es prueba — '
          'pero tampoco es nada. Las tres personas que él identifica estuvieron '
          'presentes en las tres sesiones donde se discutió "el problema judío" en '
          'el mes anterior. Eso no es probable que sea casual.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Día once. Pero también tiene razón Isaura. El testimonio inquisitorial '
          'de seis años después es problemático. El converso que lo da podría haber '
          'dicho lo que el inquisidor quería oír, podría tener motivos personales '
          'contra los acusados, podría confundir lo que vio.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Día dieciocho. Hay algo que ninguno de los dos dice. Las actas del '
          'Concejo posteriores al incendio. Isaura las usa. Tasio también. Pero '
          'ninguno comenta lo que llevan tres semanas sin tratar.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Día veintidós. Las actas posteriores al incendio dejan de mencionar al '
          'barrio judío durante tres semanas completas. Cuando lo retoman, lo hacen '
          'en términos administrativos burocráticos. Eso es silencio anómalo. Las '
          'actas anteriores discutían "el problema judío" cada dos sesiones. Después '
          'del incendio: nada durante tres semanas.',
    ),
    const PlanoDialogo(voz: VozPersonaje.vozDeFuente, texto: 'El silencio es información.'),
  ]),

  // 3.6.5 Conversación con Karim.
  EscenasArco3.conversacionConKarim.id: EscenasCortas.corta(EscenasArco3.conversacionConKarim, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Cafetería del Archivo, días después. Karim lee el avance de la '
          'reconstrucción de Maren.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Tu afirmación cuatro. "El silencio de tres semanas en las actas '
          'posteriores al incendio es información sobre la complicidad institucional, '
          'declarado como dato en sí mismo." Esto no lo dice ni Isaura ni Tasio. '
          '¿Por qué crees que no lo dicen?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Porque los dos discuten sobre qué pasó en la noche del incendio y en '
          'los días previos. La pregunta de qué pasó después — institucionalmente — '
          'no la formulan ninguno como Brecha propia.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Y tú la formulas como afirmación dentro de la tuya. Eso es lo que '
          'estaba esperando que alguien dijera desde 2021.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Maren. Esa afirmación cuatro va a ser tu escudo y tu blanco. Los '
          'Anclados te van a preguntar cómo argumentas que el silencio de tres '
          'semanas es Sólido y no Probable. Tasio se va a alegrar pero también va a '
          'querer empujarte más allá.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Cómo defiendo la solidez?'),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Comparas con el patrón anterior. ¿Cuántas veces en los seis meses '
          'anteriores el Concejo trató asuntos del barrio judío? Y comparas con el '
          'patrón posterior. ¿Cuándo retoman? ¿En qué términos?',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Ya lo tengo.'),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: 'Entonces es Sólido.'),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Tasio está invitado al Concilio. Le voy a sentar al fondo. No va a '
          'poder hacer preguntas. Sólo escuchar. Si en cualquier momento te incomoda '
          'su presencia, me avisas con la mirada y le pido salir.',
    ),
  ]),

  // 3.6.7 Reconstrucción final — las nueve afirmaciones, literales,
  // agrupadas de dos en dos (menos toques, mismo texto).
  EscenasArco3.reconstruccionFinal.id: EscenasCortas.corta(EscenasArco3.reconstruccionFinal, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Mesa de Trabajo. La reconstrucción final de Maren tiene nueve '
          'afirmaciones articuladas con sus anclajes. Las va escribiendo a limpio.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Una. El incendio del barrio judío de Tudela en noviembre de '
          '1378, con al menos dieciocho víctimas mortales documentadas. Sólido.\n\n'
          'Dos. La carta del superviviente identifica un patrón de "callar antes y '
          'no callar después" entre algunos miembros del Concejo. Sólido la fuente; '
          'la interpretación específica de qué actores requiere otras fuentes '
          'corroboradoras.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Tres. La correlación de presencias en sesiones previas '
          'identifica a tres miembros con presencia continua. Sólido la correlación; '
          'Probable la implicación directa.\n\nCuatro. El silencio de tres semanas '
          'en las actas posteriores al incendio, en contraste con el patrón previo, '
          'es información sobre la postura institucional del Concejo y constituye '
          'dato en sí mismo. Sólido.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Cinco. La complicidad institucional como categoría general — '
          'Sólido. La forma específica (orden directa, pacto silencioso, omisión '
          'deliberada) — Probable sin posibilidad actual de discriminar.\n\nSeis. La '
          'identificación nominal de los tres miembros señalados por Tasio — '
          'Disputado. La evidencia sostiene sospecha razonable pero no determinación '
          'nominativa con la confianza que el oficio requiere para nombrar a '
          'personas en relación a un asesinato colectivo.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Siete. El testimonio inquisitorial de seis años después es '
          'fuente mediada con sesgo del productor (inquisidor) y posibles '
          'motivaciones del declarante (converso). Sólido como caracterización '
          'metodológica.\n\nOcho. La Brecha sigue siendo, tras seiscientos cincuenta '
          'años, una herida histórica abierta. La identificación nominativa queda '
          'Disputada y reabierta. Sólido como declaración de estado.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Nueve. Las víctimas merecen ser reconocidas con nombre cuando '
          'sea posible. El padrón parcial conserva nombres incompletos. Maren añade '
          'los cuatro nombres parcialmente conservados — un Mosé ben con apellido '
          'fragmentado, una Dueña con apellido perdido, un niño Yosef con '
          'identificación parcial, una mujer Esther con casa identificada. Sólido '
          'como tarea pendiente.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'No he resuelto la Brecha. He añadido lo que podía añadir.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Lo que añado es: el silencio posterior es dato. Y los nombres de las '
          'víctimas son tarea pendiente.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'No es lo que Tasio quería. No es exactamente lo que Isaura defendió. '
          'Es mío.',
    ),
  ]),

  // 3.6.8 El Concilio del incendio.
  EscenasArco3.elConcilioDelIncendio.id: EscenasCortas.corta(EscenasArco3.elConcilioDelIncendio, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Salón del Concilio, una semana después. Sala más llena de lo '
          'habitual. Begoña preside. Tasio al fondo, sentado en una silla que '
          'normalmente no se usa. Maren presenta las nueve afirmaciones.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Tu afirmación nueve — los nombres de las víctimas como tarea '
          'pendiente. ¿Por qué la incluyes?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Porque sin ella la Brecha trata el incendio como acontecimiento '
          'histórico abstracto. Las víctimas tenían nombres. Algunos los conservamos '
          'parcialmente. Reconocerlos es parte del oficio. Y declarar que los '
          'desconocidos son tarea pendiente es declarar que el oficio sigue.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.begona,
      texto: 'Tu reconstrucción defiende posiciones más sólidas que las dos '
          'anteriores publicadas en algunos puntos, y posiciones más cautas en otros. '
          '¿Cómo respondes a quien te diga que estás "haciendo encaje" entre las dos '
          'versiones para parecer original?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Que cada afirmación tiene su anclaje propio. Que la afirmación cuatro '
          '— el silencio de tres semanas — no la contiene ninguna de las dos '
          'versiones anteriores. Que mi reconstrucción no encaja entre las dos: '
          'extiende el debate añadiendo un dato que ambas versiones tenían disponible '
          'y ninguna usó como afirmación independiente.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.begona,
      texto: '¿Y si te dicen que estás siendo presuntuosa?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Que me lo demuestren mostrando que el silencio posterior no es dato.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Isaura, Karim, Joana y Aitor: «Sello.»',
    ),
    const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Sellada. Aprendiz III.'),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Maren no se mueve durante un segundo. Después asiente. Tasio al '
          'fondo asiente solemnemente. Isaura la mira desde su sitio. Asiente. Sale.',
    ),
  ]),
  // 3.C.1 Naia pregunta otra vez.
  EscenasArco3.naiaPreguntaOtraVez.id: EscenasCortas.corta(EscenasArco3.naiaPreguntaOtraVez, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Sábado tarde. Naia entra sin llamar con un papel doblado. '
          'Letra grande de niña de 8 años.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Si las leyendas son sobre el momento en que se escriben, ¿qué pasa '
          'con las películas?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.naia,
      texto: 'Te oí hablando con aita de Leyre. Las películas también son sobre '
          'el momento en que se hacen, ¿no? No sobre la época que cuentan.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Casi siempre.'),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Mi hermana de ocho años acaba de hacerme una pregunta de oficio.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Voy a guardar el papel toda mi vida.',
    ),
  ]),

  // 3.Z Aprendiz III.
  EscenasArco3.aprendizIII.id: EscenasCortas.corta(EscenasArco3.aprendizIII, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Patio del Archivo, junto al brocal del pozo. Maren se sienta '
          'al lado de Isaura.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Aprendiz III. Has cerrado el arco más difícil. Lo que viene es '
          'Olite. Y la antesala de 1512.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Tasio dijo «cuando te gradúes, hablamos».',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Lo dijo. Lo sospechaba.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Y si no decido bien?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'No hay decidir bien o mal. Hay decidir con honestidad. Lo que sea '
          'con honestidad será bien.',
    ),
    const PlanoAmbiente(duracion: _media, textoLectura: 'APRENDIZ III'),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Continuará en Arco 4 — Una corte brillante en su crepúsculo.',
    ),
  ]),
};
