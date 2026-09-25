import 'voz_personaje.dart';

/// Configuración de un combate contra un Fragmento nombrado (Kurz,
/// Zafrán...). Cada combate tiene su propio set de preguntas, valor
/// inicial, tiempo límite y vocero — Kurz habla por sí mismo, Zafrán
/// no habla y es Sora quien guía entre preguntas.
class DesafioKurz {
  /// Identificador estable para flags y persistencia: "kurz_1", "zafran".
  final String identificador;

  /// Nombre que aparece en el HUD como título del Fragmento.
  final String nombreFragmento;

  /// Quién dice las frases entre preguntas. Su color y nombre se usan
  /// como etiqueta encima de cada frase. Kurz habla por sí mismo
  /// (VozPersonaje.fragmentoKurz); Zafrán no habla, Sora guía
  /// (VozPersonaje.sora).
  final VozPersonaje vozQueHabla;

  /// Si es true, el Fragmento se pinta con dos óvalos como ojos.
  /// Kurz los tiene; Zafrán no (es Dual, más antiguo y siniestro).
  final bool mostrarOjos;

  /// Valor inicial del Fragmento que el jugador ve. Decrece con
  /// cada acierto.
  final List<String> secuenciaValores;

  /// Preguntas en orden. El niño responde una por una.
  final List<PreguntaKurz> preguntas;

  /// Vidas del jugador. Cuando llega a 0, derrota.
  final int kiInicial;

  /// Tiempo en segundos que el jugador tiene para responder cada
  /// pregunta. Cortísimo en kurz_1 (calibrado a derrota), más generoso
  /// después.
  final int segundosPorPregunta;

  /// Frase del vocero cuando el jugador acierta.
  final String fraseAcierto;

  /// Frase mostrada al perder (ki = 0).
  final String fraseDerrota;

  /// Frase mostrada al ganar.
  final String fraseVictoria;

  const DesafioKurz({
    required this.identificador,
    required this.secuenciaValores,
    required this.preguntas,
    required this.kiInicial,
    required this.segundosPorPregunta,
    required this.fraseAcierto,
    required this.fraseDerrota,
    required this.fraseVictoria,
    this.nombreFragmento = 'KURZ',
    this.vozQueHabla = VozPersonaje.fragmentoKurz,
    this.mostrarOjos = true,
  });

  /// Total de aciertos necesarios para victoria — coincide con el
  /// número de preguntas. Útil para tests y para mostrar progreso.
  int get aciertosNecesarios => preguntas.length;

  /// Combate 1: el primero. Calibrado a derrota. Doc 07 §1.5.
  static const DesafioKurz primero = DesafioKurz(
    identificador: 'kurz_1',
    secuenciaValores: ['3/4', '2/4', '1/4', '—'],
    kiInicial: 2,
    segundosPorPregunta: 4,
    preguntas: [
      PreguntaKurz(
        enunciado: '¿Cuántos cuartos hay en un entero?',
        opciones: ['2', '3', '4', '6'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Muy lento.',
      ),
      PreguntaKurz(
        enunciado: 'Si tengo 3/4 y quito 1/4, ¿cuánto queda?',
        opciones: ['1/4', '2/4', '3/4', '4/4'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Otra vez mal.',
      ),
      PreguntaKurz(
        enunciado: '¿Qué es más: 1/2 o 1/4?',
        opciones: ['1/2', '1/4', 'Iguales'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Tenías que haberlo visto venir.',
      ),
    ],
    fraseAcierto: 'Mm.',
    fraseDerrota: 'Ya está. No pasa nada.',
    fraseVictoria: 'Vaya. Otra vez la semana que viene.',
  );

  /// Combate 2: tras 2-3 entrenamientos. Doc 07 §1.10. Valor 5/6, ki más
  /// generoso, tiempo algo mayor. Probabilidad real de victoria si el
  /// niño está en forma — pero la derrota sigue siendo lo esperado.
  static const DesafioKurz segundo = DesafioKurz(
    identificador: 'kurz_2',
    secuenciaValores: ['5/6', '4/6', '3/6', '2/6', '1/6', '—'],
    kiInicial: 3,
    segundosPorPregunta: 6,
    preguntas: [
      PreguntaKurz(
        enunciado: '¿Cuánto es 5/6 - 1/6?',
        opciones: ['3/6', '4/6', '5/6', '6/6'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Lento.',
      ),
      PreguntaKurz(
        enunciado: '¿Cuánto es 4/6 - 1/6?',
        opciones: ['2/6', '3/6', '4/6', '5/6'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'No lo veas — calcúlalo.',
      ),
      PreguntaKurz(
        enunciado: 'Simplifica 3/6.',
        opciones: ['1/2', '1/3', '2/3', '3/4'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Vamos.',
      ),
      PreguntaKurz(
        enunciado: '¿Cuánto es 2/6 + 1/6?',
        opciones: ['1/6', '2/6', '3/6', '4/6'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Mm.',
      ),
      PreguntaKurz(
        enunciado: 'Simplifica 2/6.',
        opciones: ['1/2', '1/3', '2/3', '3/6'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Otra.',
      ),
    ],
    fraseAcierto: 'Mm.',
    fraseDerrota: 'Casi. Otra vez la semana que viene.',
    fraseVictoria: 'Vaya. Tú ya eres otra cosa.',
  );

  /// Combate 3: el definitivo. Doc 07 §1.12. Valor 7/8, ki generoso,
  /// tiempo cómodo. Calibrado a VICTORIA. Si el niño llega aquí, está
  /// listo para Aprendiz II.
  static const DesafioKurz tercero = DesafioKurz(
    identificador: 'kurz_3',
    secuenciaValores: ['7/8', '5/8', '3/8', '1/8', '—'],
    kiInicial: 4,
    segundosPorPregunta: 8,
    preguntas: [
      PreguntaKurz(
        enunciado: '¿Cuánto es 7/8 - 2/8?',
        opciones: ['3/8', '5/8', '6/8', '9/8'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Te noto distinto. No basta.',
      ),
      PreguntaKurz(
        enunciado: 'Simplifica 4/8.',
        opciones: ['1/2', '1/4', '2/4', '3/4'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Vamos.',
      ),
      PreguntaKurz(
        enunciado: '¿Cuánto es 5/8 - 2/8?',
        opciones: ['1/8', '2/8', '3/8', '4/8'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Mm.',
      ),
      PreguntaKurz(
        enunciado: 'Simplifica 6/8.',
        opciones: ['2/4', '3/4', '4/8', '5/8'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Otra.',
      ),
    ],
    fraseAcierto: 'Mm.',
    fraseDerrota: 'Otra vez. La semana que viene.',
    fraseVictoria: 'Nos veremos cuando seas Iniciado.',
  );

  /// Combate contra Zafrán. Doc 08 §2.13. Dual con denominadores primos
  /// 7 y 11 — el ejercicio consiste en encontrar el MCM (77) y
  /// amplificar ambos valores. Zafrán no habla: Sora guía.
  ///
  /// El niño siempre termina con victoria narrativa (Zafrán escapa
  /// debilitado, no se le derrota del todo). Por eso kiInicial es
  /// generoso y las preguntas son sobre el pipeline MCM → fusión.
  static const DesafioKurz zafran = DesafioKurz(
    identificador: 'zafran',
    nombreFragmento: 'ZAFRÁN',
    vozQueHabla: VozPersonaje.sora,
    mostrarOjos: false,
    secuenciaValores: ['76/77', '38/77', '19/77', '3/77', '—'],
    kiInicial: 5,
    segundosPorPregunta: 10,
    preguntas: [
      PreguntaKurz(
        enunciado: '¿Cuál es el MCM de 7 y 11?',
        opciones: ['18', '44', '77', '88'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Amplifica. Busca un múltiplo de los dos.',
      ),
      PreguntaKurz(
        enunciado: '¿A qué equivale 5/7 con denominador 77?',
        opciones: ['35/77', '45/77', '55/77', '77/77'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Siete por once son 77. Cinco por once.',
      ),
      PreguntaKurz(
        enunciado: '¿A qué equivale 3/11 con denominador 77?',
        opciones: ['11/77', '21/77', '33/77', '44/77'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Once por siete. Tres por siete.',
      ),
      PreguntaKurz(
        enunciado: '¿Cuánto es 55/77 + 21/77?',
        opciones: ['74/77', '75/77', '76/77', '77/77'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Suma los numeradores. ¡Ahora!',
      ),
      PreguntaKurz(
        enunciado: '¿Cuánto le falta a 76/77 para ser un entero?',
        opciones: ['1/77', '2/77', '7/77', '11/77'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Sigue. No pares.',
      ),
    ],
    fraseAcierto: 'Bien.',
    fraseDerrota: 'Déjame a mí. Cuando puedas, seguimos.',
    fraseVictoria: 'Muy bien, {nombre}.',
  );

  /// Duelo amistoso contra Kai. Doc 09 §3.4. Tres rondas (reacción,
  /// precisión, Duales) representadas como 3 preguntas. Kai es el
  /// vocero — no es un Fragmento pero usamos el mismo widget. Sin
  /// ojos, halo rosa. Calibrado a victoria si el niño ha entrenado.
  static const DesafioKurz duelKai = DesafioKurz(
    identificador: 'duel_kai',
    nombreFragmento: 'KAI',
    vozQueHabla: VozPersonaje.kai,
    mostrarOjos: false,
    secuenciaValores: ['III', 'II', 'I', '—'],
    kiInicial: 3,
    segundosPorPregunta: 7,
    preguntas: [
      PreguntaKurz(
        enunciado: 'Ronda de reacción. ¿Cuánto es 3/5 de 20?',
        opciones: ['10', '12', '15', '18'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Más rápido.',
      ),
      PreguntaKurz(
        enunciado: 'Ronda de precisión. ¿A qué porcentaje equivale 3/4?',
        opciones: ['60 %', '70 %', '75 %', '80 %'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'No está mal. Pero sigue mal.',
      ),
      PreguntaKurz(
        enunciado: 'Ronda Dual. 1/2 + 1/3 = ?',
        opciones: ['2/5', '3/6', '5/6', '2/3'],
        indiceCorrecto: 2,
        fraseFalloKurz: '¿Eso es todo?',
      ),
    ],
    fraseAcierto: 'Mm.',
    fraseDerrota: 'Buen intento. Otro día te doy la revancha.',
    fraseVictoria: 'Vale. Ya está.',
  );

  /// Combate contra Vorax. Doc 10 §4.9a (Prueba de Fuego).
  /// Fragmento Impropio 11/4. Silencio absoluto, maestros como
  /// testigos. Sin vocero humano — narrador describe lo que ves.
  /// Calibrado a victoria; requiere entender conversión mixto +
  /// descomposición en cuartos.
  static const DesafioKurz vorax = DesafioKurz(
    identificador: 'vorax',
    nombreFragmento: 'VORAX',
    vozQueHabla: VozPersonaje.narrador,
    mostrarOjos: false,
    secuenciaValores: ['11/4', '2 y 3/4', '3/4', '2/4', '1/4', '—'],
    kiInicial: 5,
    segundosPorPregunta: 10,
    preguntas: [
      PreguntaKurz(
        enunciado: '11/4 es Impropio. Conviértelo a número mixto.',
        opciones: ['1 y 7/4', '2 y 3/4', '3 y 2/4', '4 y 1/4'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Vorax recupera la forma impropia. Respira.',
      ),
      PreguntaKurz(
        enunciado: 'Eliminas el 2 entero. ¿Qué parte queda como Fragmento?',
        opciones: ['1/4', '2/4', '3/4', '4/4'],
        indiceCorrecto: 2,
        fraseFalloKurz: 'Vorax tiembla. Descomponer es también parar.',
      ),
      PreguntaKurz(
        enunciado: '3/4 en cuartos: ¿cuántos cuartos son?',
        opciones: ['2', '3', '4', '6'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Vorax se agita. No vayas rápido.',
      ),
      PreguntaKurz(
        enunciado: 'Tras eliminar un cuarto, ¿cuánto queda?',
        opciones: ['1/4', '2/4', '3/4', '4/4'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Silencio. Otra vez.',
      ),
      PreguntaKurz(
        enunciado: 'Tras eliminar otro cuarto, ¿cuánto queda?',
        opciones: ['0', '1/4', '2/4', '3/4'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Vorax intenta recuperar la forma impropia.',
      ),
    ],
    fraseAcierto: 'Vorax se encoge un grado más.',
    fraseDerrota: 'Vorax se retira. Tendrás que volver.',
    fraseVictoria: 'Vorax se retira hacia arriba. Silencio.',
  );

  /// Velo (Arco V, tras la 5.7): el Fragmento de la niebla tapa un
  /// número y hay que nombrarlo. Ecuaciones de 1.º y 2.º de ESO; más
  /// tiempo por pregunta que los de Primaria.
  static const DesafioKurz velo = DesafioKurz(
    identificador: 'velo',
    nombreFragmento: 'VELO',
    vozQueHabla: VozPersonaje.fragmentoVelo,
    mostrarOjos: false,
    secuenciaValores: ['▢▢▢▢▢', '▢▢▢▢', '▢▢▢', '▢▢', '▢', '—'],
    kiInicial: 5,
    segundosPorPregunta: 20,
    preguntas: [
      PreguntaKurz(
        enunciado: 'Velo tapa un número: 3 · ▢ − 5 = 16. ¿Cuál es?',
        opciones: ['5', '7', '8', '11'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'La niebla se espesa. Deshaz la cuenta al revés.',
      ),
      PreguntaKurz(
        enunciado:
            'El doble de un número, más cuatro, es dieciocho. ¿Qué número es?',
        opciones: ['7', '9', '11', '14'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Escríbelo primero: 2x + 4 = 18.',
      ),
      PreguntaKurz(
        enunciado: '2 · (▢ + 4) = 18. ¿Qué número tapa?',
        opciones: ['5', '7', '9', '14'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'El dos multiplica a todo el paréntesis.',
      ),
      PreguntaKurz(
        enunciado: '▢/2 + ▢/3 = 10. Es el mismo número las dos veces. ¿Cuál?',
        opciones: ['12', '15', '20', '60'],
        indiceCorrecto: 0,
        fraseFalloKurz: 'Busca un denominador común. Seis.',
      ),
      PreguntaKurz(
        enunciado: 'x + y = 14 y x − y = 4. ¿Cuánto vale x?',
        opciones: ['5', '9', '10', '18'],
        indiceCorrecto: 1,
        fraseFalloKurz: 'Suma las dos igualdades. La y desaparece.',
      ),
    ],
    fraseAcierto: 'La niebla se abre un palmo.',
    fraseDerrota: 'Velo se cierra. Alguien sale de la niebla.',
    fraseVictoria: 'Velo se deshace en gotas. Hay alguien detrás.',
  );
}

class PreguntaKurz {
  final String enunciado;
  final List<String> opciones;
  final int indiceCorrecto;
  final String fraseFalloKurz;

  const PreguntaKurz({
    required this.enunciado,
    required this.opciones,
    required this.indiceCorrecto,
    required this.fraseFalloKurz,
  });
}

/// Resultado de un combate contra Kurz. El orquestador lo usa para
/// activar los flags narrativos correspondientes.
class ResultadoCombateKurz {
  final bool victoria;
  final int kiFinal;
  final int aciertos;

  const ResultadoCombateKurz({
    required this.victoria,
    required this.kiFinal,
    required this.aciertos,
  });
}
