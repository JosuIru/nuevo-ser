/// Un elemento del catálogo del que sale un quiz: un fósil, una fuente
/// histórica, una especie observada, una plaga del olivar… El quiz no
/// sabe de qué va; sólo necesita un nombre que ofrecer como opción y
/// pistas de parecido para elegir buenos distractores.
///
/// Patrón extraído del quiz de identificación de Fósiles
/// (cuadernos-de-campo), que tiraba del catálogo de su guía en vez de
/// pedir preguntas escritas a mano.
class ElementoQuiz {
  const ElementoQuiz({
    required this.id,
    required this.nombreVisible,
    this.grupo,
    this.rutaImagen,
    this.idsConfundibles = const <String>[],
    this.idHabilidad,
    this.explicacion,
  });

  final String id;

  /// Lo que se lee en la opción.
  final String nombreVisible;

  /// Familia de parecido (periodo geológico, capa histórica, orden
  /// taxonómico…). Los distractores del mismo grupo se prefieren a los
  /// de otros grupos: se parecen más y enseñan más.
  final String? grupo;

  /// Ruta de la imagen del elemento. El quiz no la carga: cada juego
  /// decide cómo (asset local en los juegos Kids, que no pueden pedir
  /// nada a terceros; red en las apps de adulto).
  final String? rutaImagen;

  /// Elementos con los que se confunde de verdad (errores típicos).
  /// Son los primeros distractores que se eligen.
  final List<String> idsConfundibles;

  /// Habilidad que ejercita acertar este elemento, si el juego registra
  /// maestría.
  final String? idHabilidad;

  /// Frase breve que se enseña tras responder, acierte o no.
  final String? explicacion;
}

/// Una opción de una pregunta. Lleva el id del elemento del que sale
/// para poder comparar sin depender del texto.
class OpcionQuiz {
  const OpcionQuiz({required this.idElemento, required this.texto});

  final String idElemento;
  final String texto;
}

/// Una pregunta ya montada: enunciado, opciones barajadas y cuál es la
/// buena.
class PreguntaQuiz {
  const PreguntaQuiz({
    required this.id,
    required this.enunciado,
    required this.opciones,
    required this.idOpcionCorrecta,
    this.rutaImagen,
    this.idHabilidad,
    this.explicacion,
    this.dificultad = 1.0,
  });

  final String id;
  final String enunciado;
  final List<OpcionQuiz> opciones;
  final String idOpcionCorrecta;
  final String? rutaImagen;
  final String? idHabilidad;
  final String? explicacion;

  /// Dificultad que se pasa al motor de maestría. Sube cuando los
  /// distractores son confundibles o del mismo grupo.
  final double dificultad;

  bool esCorrecta(String idOpcion) => idOpcion == idOpcionCorrecta;
}
