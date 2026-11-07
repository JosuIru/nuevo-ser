import 'dart:math' as math;

/// Un ejercicio de la ficha. [enunciado] es la consigna; [destacado], si
/// hay, es la expresión que se escribe en grande (p. ej. «3/4 = ___/12»);
/// [tabla], si hay, se pinta como tabla bajo el enunciado.
///
/// [solucion] no se imprime en v0.1: sirve para los tests (comprobar que
/// el generador no se equivoca) y para un futuro solucionario del profe.
///
/// Marcado de texto: `^{...}` es superíndice (la letra no trae ⁵…⁹).
class Ejercicio {
  final String enunciado;
  final String? destacado;
  final List<List<String>>? tabla;
  final String solucion;

  /// Renglones para escribir a mano bajo el ejercicio.
  final int renglones;

  const Ejercicio({
    required this.enunciado,
    this.destacado,
    this.tabla,
    required this.solucion,
    this.renglones = 3,
  });

  /// Clave para no repetir el mismo ejercicio en una ficha.
  String get clave => '$enunciado|$destacado|$tabla';
}

/// Lo que hace falta para la ficha de una habilidad: explicación para
/// 9-14 años, la pregunta de «explícalo con tus palabras» y el generador.
class PlantillaFicha {
  final String idHabilidad;
  final String descripcion;
  final String preguntaExplicalo;
  final Ejercicio Function(math.Random azar) generar;

  const PlantillaFicha({
    required this.idHabilidad,
    required this.descripcion,
    required this.preguntaExplicalo,
    required this.generar,
  });
}

/// Contenido completo de una ficha, ya generado.
class ContenidoFicha {
  final String idHabilidad;
  final String nombreHabilidad;
  final String nombreDominio;
  final String? curso;
  final String descripcion;
  final List<Ejercicio> ejercicios;
  final String preguntaExplicalo;
  final int semilla;

  const ContenidoFicha({
    required this.idHabilidad,
    required this.nombreHabilidad,
    required this.nombreDominio,
    required this.curso,
    required this.descripcion,
    required this.ejercicios,
    required this.preguntaExplicalo,
    required this.semilla,
  });
}
