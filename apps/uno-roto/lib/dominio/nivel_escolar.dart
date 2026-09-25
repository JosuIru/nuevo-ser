/// El punto de partida de un niño: el curso por el que va en
/// matemáticas. Lo fija la prueba de nivel con Sora o el adulto (Fase A
/// de la ampliación a 14 años). Sin nivel, el juego se comporta como
/// siempre: se empieza por lo más básico.
///
/// Los cursos siguen la LOMLOE de forma orientativa (ver `course` en
/// `assets/data/skills.json`, PROVISIONAL hasta revisión docente).
enum NivelEscolar {
  cuartoPrimaria('4P', '4.º de Primaria', 0),
  quintoPrimaria('5P', '5.º de Primaria', 40),
  sextoPrimaria('6P', '6.º de Primaria', 100),
  primeroEso('1E', '1.º de ESO', 150),
  segundoEso('2E', '2.º de ESO', 200);

  /// Código del curso en el catálogo de habilidades.
  final String codigo;

  /// Nombre para enseñar (castellano; se traduce con traducirNarrativa).
  final String nombre;

  /// Suelo de acceso: con este nivel, los distritos, las habilidades y
  /// la dificultad se abren como si ya se hubiera recorrido lo de antes.
  /// No son esquirlas: no se ganan ni se gastan, sólo abren.
  final int esquirlasSuelo;

  const NivelEscolar(this.codigo, this.nombre, this.esquirlasSuelo);

  static NivelEscolar? deCodigo(String? codigo) {
    for (final nivel in values) {
      if (nivel.codigo == codigo) return nivel;
    }
    return null;
  }
}

/// Índice del curso [codigo] (0 = 4.º de Primaria), o null si no lo es.
int? indiceDeCurso(String? codigo) => NivelEscolar.deCodigo(codigo)?.index;

/// Las esquirlas con las que se decide el acceso (distritos, rango de
/// habilidades, dificultad): las reales o el suelo del nivel, lo que sea
/// mayor. Las esquirlas que se enseñan y se gastan siguen siendo las
/// reales.
int esquirlasParaAcceso(int esquirlasReales, NivelEscolar? nivel) {
  final suelo = nivel?.esquirlasSuelo ?? 0;
  return esquirlasReales > suelo ? esquirlasReales : suelo;
}

/// Si una habilidad de [cursoHabilidad] se da por sabida con [nivel]:
/// las de cursos anteriores al del niño.
bool seDaPorSabida(String? cursoHabilidad, NivelEscolar? nivel) {
  final indice = indiceDeCurso(cursoHabilidad);
  return nivel != null && indice != null && indice < nivel.index;
}

/// Si una habilidad queda demasiado atrás para proponerla con [nivel]:
/// dos cursos o más por debajo. (Las del curso anterior se siguen
/// proponiendo de vez en cuando: repasar lo reciente ayuda.)
bool quedaMuyAtras(String? cursoHabilidad, NivelEscolar? nivel) {
  final indice = indiceDeCurso(cursoHabilidad);
  return nivel != null && indice != null && indice <= nivel.index - 2;
}
