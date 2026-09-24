import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'escenas_arco_2.dart';
import 'escenas_cortas.dart';
import 'voz_personaje.dart';

/// Versiones cortas de las escenas largas del Arco 2. Mismas reglas que
/// las del Arco 1 (ver `escenas_cortas.dart`): mismo id y flags, frases
/// clave del guion literales, nada histórico nuevo. Lo que no está en
/// el guion va marcado `BORRADOR (nuevo)` y anotado en
/// BLOQUEOS-PENDIENTES.md § ESCENAS-CORTAS.

const _breve = Duration(seconds: 3);
const _media = Duration(seconds: 4);
const _larga = Duration(seconds: 6);

final Map<String, EscenaCinematica> escenasCortasArco2 = {
  // ─── Pompelo ──────────────────────────────────────────────────────

  // 2.1.1 Bajar al sótano.
  EscenasArco2.bajarAlSotano.id: EscenasCortas.corta(EscenasArco2.bajarAlSotano, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Isaura abre una puerta lateral del sótano. Una galería baja, '
          'con bóveda romana, por debajo de la calle Curia.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Se abre a una sala: pavimento, una basa de columna, restos de '
          'muro. Sobre una mesa, una pieza cubierta con una tela.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Bienvenida a Pompelo.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Esto está debajo de la calle?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Esto es la calle. Lo que tú caminas arriba está sobre lo que ves aquí.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Y antes era Pompaelo, ¿no?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Pompelo, mejor. La epigrafía oficial dice Pompelo. Pompaelo aparece '
          'después, en el Itinerario de Antonino.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Isaura aparta la tela. Un ara funeraria de piedra arenisca, rota '
          'en dos partes que encajan. Tiene texto por dos lados.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Esa es tu Brecha de hoy. Estaba reutilizada en la cimentación de la '
          'muralla. Hablarás con Karim.',
    ),
  ]),

  // 2.1.2 Las dos caras.
  EscenasArco2.laInscripcion.id: EscenasCortas.corta(EscenasArco2.laInscripcion, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Dos caras contiguas del ara. En una, una sola línea breve. En '
          'la otra, seis líneas erosionadas en los bordes.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Cara A: · D · M · S ·\n\nCara B:\nD · M\n[A]elio Att[i]-\nano '
          'BNFO\nann(orum) XX+[--]\n[A]elio Attia[n]-\no ex ro(gatu) po[s(uit)]',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No la entiendo bien.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'No tienes que entenderla todavía. Formula tus preguntas. Esta vez '
          'tienes texto. Eso te da más herramientas y más trampas.',
    ),
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Llega Karim: chaqueta gris, libreta y una linterna pequeña. '
          'Isaura se va.',
    ),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: '¿Sabes algo de epigrafía romana?'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Casi nada.'),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: 'Vale. Empezamos por el principio.'),
  ]),

  // 2.1.3 Karim enseña epigrafía.
  EscenasArco2.karimEnsenaEpigrafia.id: EscenasCortas.corta(EscenasArco2.karimEnsenaEpigrafia, [
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Esto no es texto. Es texto abreviado, codificado, y roto. D·M·S: Dis '
          'Manibus Sacrum, consagrado a los Dioses Manes. Casi todas las '
          'funerarias empiezan así.',
    ),
    // BORRADOR (nuevo): en el guion Maren ve la diferencia sola; aquí la
    // mira la jugadora.
    const PlanoEleccion(
      voz: VozPersonaje.karim,
      textoPrompt: 'Mira las letras de la cara B. La E, la L. ¿Ves la diferencia con '
          'la cara A?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'La A es más rígida, más cuadrada. La B es más suelta.',
          textoRespuesta: 'Bien.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'epigrafia_2_1_ve_la_diferencia'},
        ),
        OpcionEleccion(
          textoJugador: 'Son iguales: están en la misma piedra.',
          textoRespuesta: 'Mira la E otra vez: casi una epsilon griega. La B es más '
              'suelta.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'epigrafia_2_1_no_ve_la_diferencia'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'La paleografía de la cara A apunta al s. I d.C. La cara B al s. III d.C.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Doscientos años entre las dos caras de un mismo cubo. ¿Cómo?',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Tres hipótesis: la cara A se pintó y el pigmento se perdió antes '
          'de reutilizarla; o un taller la tuvo con el DMS grabado sin comprador '
          'hasta el s. III; o se desechó por un defecto en la S y se reusó después.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Ninguna de las tres está confirmada. Las tres son plausibles. Vas a '
          'tener que sostener la incertidumbre.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Línea cinco: Aelio Attiano otra vez. Es el padre. Pero está en dativo, '
          'igual que el difunto. Debería estar en nominativo. El lapicida se '
          'equivocó.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Los errores en epigrafía son importantes. Porque te dicen algo que el '
          'texto correcto no te diría.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'A los Dioses Manes. A Elio Attiano, su buen hijo, de treinta (y '
          'tantos) años de edad, lo dedicó (el monumento) Elio Attiano, de acuerdo '
          'con su ruego.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Ahora la pregunta más importante. Esta piedra no estaba donde fue hecha '
          'cuando la encontraron.',
    ),
  ]),

  // 2.1.4 Dónde apareció.
  EscenasArco2.quienPagoEsto.id: EscenasCortas.corta(EscenasArco2.quienPagoEsto, [
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'El ara fue hallada como sillar de la muralla bajoimperial, calle Merced, '
          '2004. La muralla es de finales del s. III, principios del s. IV. Periodo '
          'de mucha inestabilidad.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Su padre encargó esta piedra para honrar al hijo muerto. Y después la '
          'arrancaron para ponerla en una muralla. Eso parece una falta de respeto.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Lo es. Hoy lo vemos así. Pero hay que entender el contexto. Cuando hay '
          'urgencia, los ladrillos vienen de donde sea. Incluso de los monumentos a '
          'tus muertos.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Una inscripción no es un documento neutral. Es propaganda en el sentido '
          'amplio. No miente, pero selecciona. La piedra no nos cuenta cómo era '
          'Aelio Attiano. Nos cuenta cómo el padre quería recordarlo.',
    ),
    // BORRADOR (nuevo): en el guion Maren lo dice sola y Karim contesta;
    // aquí lo elige la jugadora.
    const PlanoEleccion(
      voz: VozPersonaje.karim,
      textoPrompt: '¿Y el error del lapicida? ¿Qué nos dice?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Algo que el padre no eligió. Es información que no es '
              'propaganda.',
          textoRespuesta: 'Eso lo digo yo a estudiantes universitarios y muchos no lo '
              'ven. Lo has dicho tú al primer día.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'epigrafia_2_1_error_escapa_propaganda'},
        ),
        OpcionEleccion(
          textoJugador: 'Nada: es una errata sin importancia.',
          textoRespuesta: 'El padre no eligió que el lapicida se equivocara. El error '
              'está ahí en contra de su voluntad. Eso también es información.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'epigrafia_2_1_error_sin_importancia'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Te dejo trabajar. Vuelvo en una hora a ver tu reconstrucción.',
    ),
  ]),

  // 2.1.5 Reconstrucción y Concilio.
  EscenasArco2.reconstruccionYConcilio.id: EscenasCortas.corta(EscenasArco2.reconstruccionYConcilio, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Salón del Concilio. Begoña, Isaura, Karim y Aitor. Maren presenta: '
          'el error del lapicida (Sólido el hecho, Disputado la causa) y la '
          'reutilización en la muralla (Sólido el hecho, Probable el contexto).',
    ),
    // BORRADOR (nuevo): primera opción = respuesta del guion resumida.
    const PlanoEleccion(
      voz: VozPersonaje.begona,
      textoPrompt: '¿Por qué crees que esta piedra apareció en la muralla y no en la '
          'necrópolis donde fue hecha?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'La muralla se hizo con urgencia, en crisis, con lo que había '
              'cerca. Lo declaro Probable: también pudo ser porque era barato.',
          textoRespuesta: 'Bien.',
          vozRespuesta: VozPersonaje.begona,
          flagsAEstablecer: {'concilio_2_1_muralla_probable'},
        ),
        OpcionEleccion(
          textoJugador: 'Porque ya no respetaban a sus muertos. Es Sólido.',
          textoRespuesta: '¿Todos? ¿O la urgencia defensiva pesó más que la dignidad '
              'funeraria en ese momento? Eso es Probable.',
          vozRespuesta: VozPersonaje.begona,
          flagsAEstablecer: {'concilio_2_1_muralla_sobreconfiada'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.begona,
      texto: 'El error del lapicida. ¿Por qué le has dado importancia?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Una inscripción es propaganda en el sentido de que selecciona. Pero un '
          'error es información que escapa a la propaganda.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'El lapicida quizá tenía poco latín. Eso es información sobre Pompelo en '
          'el s. III. La piedra nos lo dice a través del error.',
    ),
    const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Bien.'),
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Karim asiente desde su sitio. Tres segundos largos. Begoña lo nota.',
    ),
    const PlanoDialogo(voz: VozPersonaje.begona, texto: '¿Te has portado bien?'),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: 'No demasiado. Pero ella sí.'),
  ]),

  // 2.1.6 El primer apunte de Pompelo.
  EscenasArco2.primerApunteDePompelo.id: EscenasCortas.corta(EscenasArco2.primerApunteDePompelo, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Noche. Maren en su mesa, cuaderno abierto. Lo que vio hoy está '
          'debajo de la calle Curia.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'En Aralar yo no entendía el silencio. En Pompelo no entiendo bien lo que '
          'se ha dicho.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Karim me dijo: "Una inscripción no es un documento neutral. Es '
          'propaganda." Eso lo voy a apuntar en grande.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Las piedras no son sólo lo que el dedicante eligió. Son también lo que '
          'escapó a su elección.',
    ),
    const PlanoCierreAmable(textoBoton: 'CERRAR EL CUADERNO'),
  ]),

  // ─── Calagurris ───────────────────────────────────────────────────

  // 2.2.3 Quintiliano sobre sí mismo.
  EscenasArco2.quintilianoSobreSiMismo.id: EscenasCortas.corta(EscenasArco2.quintilianoSobreSiMismo, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Sala del museo. Maren con los dos volúmenes verdes que le prestó '
          'su padre y cuatro pasajes marcados. Isaura en un banco, callada.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Pasaje A: cuándo se retiró de la enseñanza. Pasaje B: su llegada '
          'a Roma. Pasaje C: la dedicatoria a su patrón Vitorio Marcelo. Pasaje D: '
          'la muerte de su hijo.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'No habla casi nada de Calagurris. No habla de sus padres. No habla de '
          'por qué se fue.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: '¿Eso significa que Calagurris no le importaba? ¿O que estaba escribiendo '
          'para una élite romana que no tenía interés en su origen provincial?',
    ),
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Maren anota las omisiones una por una. Separar lo dicho de lo no '
          'dicho.',
    ),
    const PlanoCierreAmable(textoBoton: 'LLAMAR A LA ARQUEÓLOGA'),
  ]),

  // 2.2.4 Lo que omite.
  EscenasArco2.loQueOmite.id: EscenasCortas.corta(EscenasArco2.loQueOmite, [
    const PlanoDialogo(voz: VozPersonaje.arqueologa, texto: '¿Qué tienes?'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Dos cosas. Lo que dice y lo que no dice. No habla casi nada de '
          'Calagurris, ni de sus padres, ni de su infancia, ni de por qué se fue.',
    ),
    // BORRADOR (nuevo): primera opción = respuesta del guion resumida.
    const PlanoEleccion(
      voz: VozPersonaje.arqueologa,
      textoPrompt: '¿Por qué crees que omite tanto?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Tres hipótesis: escribe para un público romano, quiere que lo '
              'vean como romano, o el género no pide biografía. Me convence la mezcla.',
          textoRespuesta: 'Eso lo notas tú. La mayoría de la gente no lo nota.',
          vozRespuesta: VozPersonaje.arqueologa,
          flagsAEstablecer: {'quintiliano_omisiones_varias_hipotesis'},
        ),
        OpcionEleccion(
          textoJugador: 'Porque odiaba Calagurris.',
          textoRespuesta: 'Eso no lo dice en ningún sitio. ¿Qué otras razones podría '
              'haber?',
          vozRespuesta: VozPersonaje.arqueologa,
          flagsAEstablecer: {'quintiliano_omisiones_una_sola_causa'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.arqueologa,
      texto: 'Cuando escribe la Institutio llevaba cuarenta años en Roma. Es probable '
          'que ya no se sintiera de aquí.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Eso le pasa a la gente. Mi madre dice que su prima de Cuba vuelve a Cuba '
          'y ya no le encaja del todo.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Maren escribe siete afirmaciones. Probable: que se sentía romano '
          'más que hispano al escribir. Disputado: el peso real de Calagurris en su '
          'formación. Las omisiones pesan menos que las afirmaciones.',
    ),
    const PlanoCierreAmable(textoBoton: 'PREPARAR EL CONCILIO'),
  ]),

  // 2.2.5 El Concilio en Calahorra.
  EscenasArco2.elConcilioEnCalahorra.id: EscenasCortas.corta(EscenasArco2.elConcilioEnCalahorra, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Concilio reducido, por primera vez fuera del Archivo: Aitor por '
          'pantalla desde Iruña, la arqueóloga en la sala.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.arqueologa,
      texto: 'Has marcado Probable que Quintiliano se sentía romano más que hispano. '
          '¿Qué te haría declararlo Sólido?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Algún testimonio explícito de él mismo o de sus contemporáneos sobre su '
          'identidad.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.aitor,
      texto: 'La declaras Probable porque te basas en omisiones. Las omisiones son '
          'evidencia más débil que las afirmaciones.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Sí.'),
    const PlanoDialogo(voz: VozPersonaje.aitor, texto: 'Bien. Sellada.'),
    const PlanoCierreAmable(textoBoton: 'CERRAR EL CONCILIO'),
  ]),

  // 2.2.6 Lo que fue y dejó de ser.
  EscenasArco2.loQueFueYDejoDeSer.id: EscenasCortas.corta(EscenasArco2.loQueFueYDejoDeSer, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Vuelven hacia Iruña al anochecer. Maren más callada de lo habitual.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Calahorra fue navarra. Hasta 1076. Y ahora es Rioja. La arqueóloga no se '
          'sentía navarra. ¿Y eso qué es?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Eso es la historia. Las cosas son y dejan de ser. Lo que fue navarro fue '
          'navarro de verdad. Lo que es riojano hoy es riojano de verdad.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿No son contradictorias?'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'No. Son sucesivas.'),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Calagurris era Calagurris. Después fue navarra. Después dejó de serlo. '
          'Quintiliano fue de aquí. Después no. Las cosas son y dejan de ser.',
    ),
    const PlanoCierreAmable(textoBoton: 'CERRAR EL CUADERNO'),
  ]),

  // 2.B.1 El cuaderno de Isaura.
  EscenasArco2.elCuadernoDeIsaura.id: EscenasCortas.corta(EscenasArco2.elCuadernoDeIsaura, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Despacho de Isaura. Está terminando de escribir en un cuaderno '
          'marrón viejo. Lo guarda en un cajón al ver entrar a Maren.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Qué cuaderno es ése?'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'El mío. Más viejo. Más feo. Treinta años.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Qué hay dentro?'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Preguntas.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Sólo?'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Sólo.'),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Cuando Maren sale, Isaura abre el cajón, mira una página antigua '
          'sin leerla y vuelve a guardar el cuaderno.',
    ),
    const PlanoCierreAmable(textoBoton: 'SALIR DEL DESPACHO'),
  ]),

  // ─── La domus ─────────────────────────────────────────────────────

  // 2.3.1 La domus de los mosaicos.
  EscenasArco2.laDomusDeLosMosaicos.id: EscenasCortas.corta(EscenasArco2.laDomusDeLosMosaicos, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Mediados de enero. Otra galería bajo el casco viejo. Un suelo de '
          'mosaico con teselas blancas, negras, rojas y azules; muros pintados; un '
          'horno; una cisterna.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Esto es una casa. Sabemos algo de quién vivía aquí. No mucho.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'El mosaico es del siglo II. La casa fue habitada al menos doscientos '
          'años. Tienes capas dentro de la propia casa.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tu Brecha: ¿cómo era la vida de las personas que vivieron en esta casa? '
          'Tres fuentes: una inscripción del propietario, una tablilla con cuentas, '
          'restos materiales.',
    ),
    // BORRADOR (nuevo): en el guion la pregunta la hace Maren sola.
    const PlanoEleccion(
      voz: VozPersonaje.isaura,
      textoPrompt: '¿Qué preguntas tú?',
      opciones: [
        OpcionEleccion(
          textoJugador: '¿Y las personas que no eran propietarios?',
          textoRespuesta: 'Esa es la pregunta correcta.',
          vozRespuesta: VozPersonaje.isaura,
          flagsAEstablecer: {'domus_pregunta_por_los_no_propietarios'},
        ),
        OpcionEleccion(
          textoJugador: '¿Cuánto costó el mosaico?',
          textoRespuesta: 'También se puede preguntar. Pero hay otra más difícil: ¿y '
              'las personas que no eran propietarios?',
          vozRespuesta: VozPersonaje.isaura,
          flagsAEstablecer: {'domus_pregunta_por_el_mosaico'},
        ),
      ],
    ),
    const PlanoCierreAmable(textoBoton: 'EMPEZAR LA BRECHA'),
  ]),

  // 2.3.2 Las personas que vivieron aquí.
  EscenasArco2.lasPersonasQueVivieronAqui.id: EscenasCortas.corta(EscenasArco2.lasPersonasQueVivieronAqui, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Cuatro fuentes sobre la mesa: la inscripción de un Cornelio, '
          'magistrado local; una tablilla de cuentas que menciona «siervos» sin '
          'nombrar; cerámica, herramientas y restos del horno; y domus parecidas de '
          'otras ciudades.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'El Cornelio aparece en todas las fuentes. Su esposa aparece una vez. Sus '
          'hijos no aparecen. Los siervos aparecen como números: dos.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Pero alguien encendió ese horno cada mañana. Alguien limpiaba estos '
          'mosaicos.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Los nombres de quienes la hacían funcionar no están.',
    ),
    const PlanoCierreAmable(textoBoton: 'SALIR A RESPIRAR'),
  ]),

  // 2.3.3 La crisis.
  EscenasArco2.laCrisis.id: EscenasCortas.corta(EscenasArco2.laCrisis, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'El patio del Archivo. Maren en el banco junto al pozo, sin '
          'escribir. Isaura se sienta a su lado.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: '¿Qué pasa?'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No quiero seguir esta Brecha. Me da rabia.'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Me da rabia que el Cornelio tenga inscripción y los siervos no tengan '
          'nada. Que tenga que hablar de "su" mosaico cuando el mosaico lo limpiaba '
          'alguien que no aparece.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Y si declaro todo eso, suena como Tasio. Y si no lo declaro, soy cómplice.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: '¿Quieres una pausa?'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'No. Quiero que me ayudes a entender cómo se hace esto sin volverme loca.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Vamos a la cocina. Te invito un té.'),
    const PlanoCierreAmable(textoBoton: 'IR A LA COCINA'),
  ]),

  // 2.3.4 Comprender sin justificar.
  EscenasArco2.comprenderSinJustificar.id: EscenasCortas.corta(EscenasArco2.comprenderSinJustificar, [
    const PlanoAmbiente(duracion: _breve, textoLectura: 'Cocina del Archivo. Dos tazas de té.'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Lo que sientes es legítimo. La esclavitud en Pompelo fue una atrocidad '
          'humana.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Entonces ¿por qué tengo que tratarla con neutralidad?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'No tienes que tratarla con neutralidad. Tienes que tratarla con '
          'comprensión. Es distinto.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Comprensión es: esto es lo que sabemos de cómo funcionaba en esta domus, '
          'esto es lo que NO sabemos sobre las personas esclavizadas, y todo ocurrió '
          'en un sistema que hoy reconocemos como atrocidad, aunque la mayoría de los '
          'romanos no lo formularan así.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tu valoración está fuera, como cronista del siglo XXI mirando. La de '
          'ellos está dentro, como sujetos de su tiempo. Las dos cosas conviven en tu '
          'Brecha.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿La diferencia con Tasio?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tasio inventaría sus nombres si pudiera fundamentarlo a medias. Tú no '
          'inventas. Declaras la ausencia. La ausencia documentada es información.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Las grietas también hablan.'),
    const PlanoCierreAmable(textoBoton: 'VOLVER A LA MESA DE TRABAJO'),
  ]),

  // 2.3.5 Reconstrucción.
  EscenasArco2.reconstruccionDeLaDomus.id: EscenasCortas.corta(EscenasArco2.reconstruccionDeLaDomus, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Mesa de Trabajo. Maren reformula la reconstrucción.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'La domus fue residencia de la familia Cornelia desde mediados del '
          'siglo II hasta finales del III. Sólido. La casa empleaba al menos dos '
          'personas esclavizadas, según las cuentas domésticas. Sólido.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: '6. Estas personas no están nombradas en ninguna fuente que se '
          'conserve. Su número exacto, sus nombres, sus vidas concretas, sus orígenes '
          'culturales se desconocen. Sólido (la ausencia).',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'La afirmación 6 es la que más le importa. El «Sólido (la '
          'ausencia)» lo escribe a mano, sin abreviar.',
    ),
    const PlanoCierreAmable(textoBoton: 'PREPARAR EL CONCILIO'),
  ]),

  // 2.3.6 Concilio de la domus.
  EscenasArco2.concilioDeLaDomus.id: EscenasCortas.corta(EscenasArco2.concilioDeLaDomus, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Salón del Concilio. Karim, Aitor e Isaura revisan. Maren presenta '
          'sus 8 afirmaciones.',
    ),
    // BORRADOR (nuevo): primera opción = respuesta del guion resumida.
    const PlanoEleccion(
      voz: VozPersonaje.karim,
      textoPrompt: 'Tu afirmación 6 declara una ausencia. Es inhabitual. ¿Por qué la '
          'declaras?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Porque la ausencia no es neutralidad de las fuentes. Es '
              'estructura: no sabemos quiénes eran porque la sociedad estaba hecha '
              'para que no quedara registro.',
          textoRespuesta: 'Estás reformulando «no sabemos quiénes eran» en algo más '
              'fuerte.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'concilio_2_3_ausencia_como_estructura'},
        ),
        OpcionEleccion(
          textoJugador: 'Porque me daba pena que no salieran.',
          textoRespuesta: 'La pena es legítima. Pero la ausencia dice algo de cómo '
              'funcionaba aquella sociedad: estaba hecha para que no quedara registro.',
          vozRespuesta: VozPersonaje.karim,
          flagsAEstablecer: {'concilio_2_3_ausencia_como_pena'},
        ),
      ],
    ),
    const PlanoDialogo(voz: VozPersonaje.aitor, texto: 'Eso es Reformismo aplicado.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Lo sé. Pero está fundamentado.'),
    const PlanoDialogo(voz: VozPersonaje.aitor, texto: 'Lo está.'),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: 'Sellada. Bien hecho.'),
    const PlanoAmbiente(duracion: _breve, textoLectura: 'En el pasillo, Karim alcanza a Maren.'),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'La afirmación 6 es de las que me hacen tener esperanza con esta '
          'institución.',
    ),
    const PlanoCierreAmable(textoBoton: 'CERRAR LA ESTACIÓN'),
  ]),

  // ─── Wamba ────────────────────────────────────────────────────────

  // 2.4.1 Una Brecha de un solo lado.
  EscenasArco2.unaBrechaDeUnSoloLado.id: EscenasCortas.corta(EscenasArco2.unaBrechaDeUnSoloLado, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Mediados de febrero. Despacho de Isaura. Tres libros y una carpeta '
          'gastada sobre la mesa.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Tu Brecha de cierre. Wamba. Año 673. Campaña visigótica contra los '
          'vascones del norte.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Esta Brecha tiene un problema estructural. Y no se puede resolver. Sólo '
          'se puede declarar.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Las fuentes son todas de un solo lado. Visigodos hablando de vascones '
          'derrotados. Los vascones no se defienden por escrito. No porque no '
          'escribieran nada — porque no se conserva.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Vas a tener que reconstruir desde fuentes hostiles, declarar el sesgo, y '
          'aceptar que tu reconstrucción tendrá un techo.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Qué pasa si la fastidio?'),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Te quedas Aprendiz I un tiempo más. Reabres. Lo intentas otra vez. No la '
          'vas a fastidiar, Maren.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Eso no lo sabes.'),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Tienes razón. No lo sé.'),
    const PlanoCierreAmable(textoBoton: 'COGER LA CARPETA'),
  ]),

  // 2.4.2 Las crónicas visigodas.
  EscenasArco2.lasCronicasVisigodas.id: EscenasCortas.corta(EscenasArco2.lasCronicasVisigodas, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Biblioteca del Archivo. Tres días con la Historia Wambae regis de '
          'Julián de Toledo. A la izquierda, lo que dice. A la derecha, lo que esa '
          'formulación presupone.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Julián de Toledo escribe sesenta años después de los hechos. Es '
          'propaganda dinástica.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'La palabra "rebelde" presupone autoridad legítima previa. Julián lo da '
          'por hecho. Pero esa es la pregunta.',
    ),
    // BORRADOR (nuevo): primera opción = respuesta del guion.
    const PlanoEleccion(
      voz: VozPersonaje.aitor,
      textoPrompt: 'Pregunta de oficio: ¿estaban los vascones bajo dominio visigodo '
          'antes del 673?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Las fuentes visigodas dicen que sí. Pero que cada generación '
              'tenga que enviar una campaña significa que no del todo.',
          textoRespuesta: 'Mm.',
          vozRespuesta: VozPersonaje.aitor,
          flagsAEstablecer: {'wamba_dominio_duda_fundada'},
        ),
        OpcionEleccion(
          textoJugador: 'Sí: lo dice la crónica.',
          textoRespuesta: '¿La crónica de quién? Si cada generación manda una '
              'campaña, ¿estaban dominados del todo?',
          vozRespuesta: VozPersonaje.aitor,
          flagsAEstablecer: {'wamba_dominio_cree_la_cronica'},
        ),
      ],
    ),
    const PlanoCierreAmable(textoBoton: 'CERRAR LA EDICIÓN'),
  ]),

  // 2.4.3 El silencio vascón.
  EscenasArco2.elSilencioVascon.id: EscenasCortas.corta(EscenasArco2.elSilencioVascon, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Un asentamiento vascón al norte de Iruña. Estructuras de piedra '
          'seca, una pared baja, cerámica hecha a mano, sin torno.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'Esto es lo que tenemos del lado vascón.'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'No hay inscripciones. ¿Eso significa que no escribían?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Significa que no se conservan inscripciones suyas. Que escribieran o no '
          'es otra pregunta.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.isaura,
      texto: 'Lo que tenemos del lado vascón son objetos. Materia silenciosa. Tienes '
          'que combinarlos con la lectura crítica de las fuentes hostiles.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Volver a la prehistoria, en cierto sentido.',
    ),
    const PlanoDialogo(voz: VozPersonaje.isaura, texto: 'En cierto sentido sí.'),
    const PlanoCierreAmable(textoBoton: 'BAJAR DEL YACIMIENTO'),
  ]),

  // 2.4.5 Conversación con Karim.
  EscenasArco2.conversacionConKarim.id: EscenasCortas.corta(EscenasArco2.conversacionConKarim, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Cocina del Archivo. Maren le cuenta a Karim su frustración: las '
          'fuentes, el techo que no se mueve.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Te voy a decir algo que igual te molesta. Lo que te frustra es lo más '
          'importante de la Brecha.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'El silencio vascón es el dato. No es ausencia de dato. Es dato. Es '
          'información sobre cómo funcionaba la dominación.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'O que había fuentes vasconas y se perdieron.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'O eso. Lo segundo también es información — significa que la dominación '
          'posterior eliminó lo que pudo.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'La gente que escribe la historia normalmente no escribe sobre los '
          'silencios. Tu trabajo va a notarse precisamente porque tú sí vas a '
          'escribir sobre los silencios.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: '¿Eso es Reformismo?'),
    const PlanoDialogo(voz: VozPersonaje.karim, texto: 'Eso es oficio.'),
    const PlanoCierreAmable(textoBoton: 'VOLVER A LA MESA'),
  ]),

  // 2.4.6 Reconstrucción honesta.
  EscenasArco2.reconstruccionHonesta.id: EscenasCortas.corta(EscenasArco2.reconstruccionHonesta, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'La reconstrucción. Wamba dirigió una campaña militar contra los '
          'vascones del norte en 673: Sólido. El estatus real de los vascones antes de '
          'la campaña: Disputado.',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: '7. No se conservan fuentes producidas por los vascones del '
          'periodo. Ni textuales ni epigráficas. Sólido (la ausencia).',
    ),
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: '9. La reconstrucción del lado vascón tiene un techo metodológico '
          'estructural. Sólido como declaración metodológica.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'No he resuelto la Brecha. La he declarado.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Igual eso es lo que tenía que hacer.',
    ),
    const PlanoCierreAmable(textoBoton: 'PREPARAR EL CONCILIO'),
  ]),

  // 2.4.7 El Concilio dividido.
  EscenasArco2.elConcilioDividido.id: EscenasCortas.corta(EscenasArco2.elConcilioDividido, [
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Salón del Concilio. Begoña preside; Isaura, Karim, Aitor y Joana. '
          'Marina observa al fondo. Maren, de pie, con sus nueve afirmaciones.',
    ),
    // BORRADOR (nuevo): en las dos elecciones la primera opción resume la
    // respuesta de Maren en el guion.
    const PlanoEleccion(
      voz: VozPersonaje.joana,
      textoPrompt: 'La afirmación 8, «esta ausencia documental no es accidente», es '
          'interpretativa. ¿Por qué Probable?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'La asimetría de fuentes está documentada; lo que significa es '
              'inferencia. Sólido afirmaría una inferencia como hecho; Disputado '
              'exageraría la duda.',
          textoRespuesta: 'Vale. Probable acepto.',
          vozRespuesta: VozPersonaje.joana,
          flagsAEstablecer: {'concilio_2_4_probable_bien_calibrado'},
        ),
        OpcionEleccion(
          textoJugador: 'Debería ser Sólido: está claro que los dominaban.',
          textoRespuesta: 'La asimetría es documentada. Lo que significa es inferencia. '
              'Eso es Probable.',
          vozRespuesta: VozPersonaje.joana,
          flagsAEstablecer: {'concilio_2_4_sobreconfiada'},
        ),
      ],
    ),
    const PlanoDialogo(
      voz: VozPersonaje.karim,
      texto: 'Yo la habría declarado Sólido tirando a Probable alto. Pero acepto '
          'Probable.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.aitor,
      texto: 'Yo la habría declarado Probable bajo. Acepto Probable.',
    ),
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Risa breve en la sala. Tres escuelas convergiendo en Probable '
          'desde distintos lados.',
    ),
    const PlanoEleccion(
      voz: VozPersonaje.begona,
      textoPrompt: 'Tu afirmación 9 es una declaración metodológica. ¿Por qué la '
          'incluyes?',
      opciones: [
        OpcionEleccion(
          textoJugador: 'Para que nadie crea que con más trabajo se llega a más '
              'certeza sobre el lado vascón. El techo es estructural.',
          textoRespuesta: 'Bien.',
          vozRespuesta: VozPersonaje.begona,
          flagsAEstablecer: {'concilio_2_4_declara_el_techo'},
        ),
        OpcionEleccion(
          textoJugador: 'Para cubrirme por si alguien me critica.',
          textoRespuesta: 'Inclúyela por otra razón: para que quien retome esta '
              'Brecha sepa qué se puede pedir a las fuentes y qué no.',
          vozRespuesta: VozPersonaje.begona,
          flagsAEstablecer: {'concilio_2_4_techo_como_defensa'},
        ),
      ],
    ),
    const PlanoDialogo(voz: VozPersonaje.begona, texto: 'Sellada.'),
    const PlanoDialogo(voz: VozPersonaje.marina, texto: 'Begoña ha sonreído.'),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'No la vi.'),
    const PlanoCierreAmable(textoBoton: 'IR AL PATIO'),
  ]),

  // ─── Cierre del arco ──────────────────────────────────────────────

  // 2.Z.1 Antonio y Wamba.
  EscenasArco2.antonioYWamba.id: EscenasCortas.corta(EscenasArco2.antonioYWamba, [
    const PlanoAmbiente(
      duracion: _breve,
      textoLectura: 'Cocina de casa. Maren y Antonio cocinan pasta. La casa, más '
          'callada de lo normal.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Las fuentes son todas de un lado. Karim me dijo que el silencio es un '
          'dato. ¿Tú lo habías pensado así alguna vez?',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Sí. Pero no con esas palabras. Cuando leí El Quijote de adolescente. '
          'Cervantes habla mucho de moriscos. Pero los moriscos no aparecen '
          'escribiendo.',
    ),
    const PlanoDialogo(voz: VozPersonaje.maren, texto: 'Es lo mismo.'),
    const PlanoDialogo(voz: VozPersonaje.antonio, texto: 'Es lo mismo.'),
    const PlanoDialogo(
      voz: VozPersonaje.maren,
      texto: 'Aita. No tengo claro qué tipo de oficio he elegido.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Eso es buena señal. Los oficios que tienes claros desde el principio '
          'suelen ser los que se acaban antes.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.antonio,
      texto: 'Maren. Mmm. Olvídalo. Sigamos cocinando.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'Cenan. Pero antes de que Antonio dijera «olvídalo», Maren ha hecho '
          'algo que él no ha visto.',
    ),
    const PlanoCierreAmable(textoBoton: 'SUBIR AL CUARTO'),
  ]),

  // 2.Z.2 La grabación.
  EscenasArco2.laGrabacion.id: EscenasCortas.corta(EscenasArco2.laGrabacion, [
    const PlanoAmbiente(
      duracion: _larga,
      textoLectura: 'Cuarto de Maren. Auriculares. Grabó la conversación entera con el '
          'móvil en el bolsillo del delantal, sin decírselo a su padre. La escucha '
          'completa, con los ojos cerrados.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'He grabado a mi padre sin decírselo. No es bonito hacerlo. Mañana se lo '
          'cuento.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'He oído mi voz hablando con mi padre como con un par.',
    ),
    const PlanoDialogo(
      voz: VozPersonaje.vozDeFuente,
      texto: 'Y dijo "Maren" y después "olvídalo". ¿Qué iba a decirme y se calló? Eso '
          'lo apunto como pregunta abierta. Como Isaura.',
    ),
    const PlanoAmbiente(
      duracion: _media,
      textoLectura: 'ARCO 2 — CERRADO. Continuará en Arco 3 — La forja del reino.',
    ),
    const PlanoCierreAmable(textoBoton: 'CERRAR EL ARCO'),
  ]),
};
