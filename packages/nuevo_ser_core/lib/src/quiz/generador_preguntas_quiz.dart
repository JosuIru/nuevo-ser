import 'dart:math';

import 'pregunta_quiz.dart';

/// Monta preguntas de identificación a partir de un catálogo de
/// [ElementoQuiz]. Puro y reproducible con semilla.
///
/// Distractores, por orden de preferencia:
/// 1. los confundibles declarados del elemento (errores típicos),
/// 2. los del mismo grupo,
/// 3. el resto del catálogo.
/// Dentro de cada tramo se baraja, así que dos partidas con el mismo
/// elemento no ofrecen siempre las mismas opciones.
///
/// Los elementos correctos salen sin repetirse hasta agotar el
/// catálogo (baraja sin reposición), para que una partida corta no
/// pregunte dos veces lo mismo.
class GeneradorPreguntasQuiz {
  GeneradorPreguntasQuiz({
    required List<ElementoQuiz> catalogo,
    required this.enunciado,
    this.numeroOpciones = 4,
    int? semilla,
  })  : _catalogo = List.unmodifiable(catalogo),
        _aleatorio = Random(semilla) {
    if (numeroOpciones < 2) {
      throw ArgumentError.value(
          numeroOpciones, 'numeroOpciones', 'hacen falta al menos 2');
    }
    if (catalogo.length < 2) {
      throw ArgumentError.value(catalogo.length, 'catalogo',
          'hacen falta al menos 2 elementos para tener distractores');
    }
  }

  final List<ElementoQuiz> _catalogo;
  final Random _aleatorio;

  /// Texto de la pregunta a partir del elemento correcto. Cada juego lo
  /// escribe en su voz y su idioma («¿Qué fósil es este?», «¿De qué capa
  /// es esta fuente?»).
  final String Function(ElementoQuiz elementoCorrecto) enunciado;

  /// Si el catálogo es más pequeño, la pregunta lleva menos opciones.
  final int numeroOpciones;

  final List<ElementoQuiz> _pendientes = [];
  int _contadorPreguntas = 0;

  /// Siguiente pregunta de la baraja.
  PreguntaQuiz siguiente() {
    if (_pendientes.isEmpty) {
      _pendientes
        ..addAll(_catalogo)
        ..shuffle(_aleatorio);
    }
    return preguntaSobre(_pendientes.removeLast());
  }

  /// Pregunta sobre un elemento concreto (para quien quiera elegir el
  /// orden, p. ej. repasar primero lo que se falló).
  PreguntaQuiz preguntaSobre(ElementoQuiz correcto) {
    final distractores = _elegirDistractores(correcto);
    final opciones = [correcto, ...distractores]
        .map((elemento) =>
            OpcionQuiz(idElemento: elemento.id, texto: elemento.nombreVisible))
        .toList()
      ..shuffle(_aleatorio);
    _contadorPreguntas++;
    return PreguntaQuiz(
      id: '${correcto.id}#$_contadorPreguntas',
      enunciado: enunciado(correcto),
      opciones: opciones,
      idOpcionCorrecta: correcto.id,
      rutaImagen: correcto.rutaImagen,
      idHabilidad: correcto.idHabilidad,
      explicacion: correcto.explicacion,
      dificultad: _dificultad(correcto, distractores),
    );
  }

  List<ElementoQuiz> _elegirDistractores(ElementoQuiz correcto) {
    final cuantos = min(numeroOpciones - 1, _catalogo.length - 1);
    final otros = _catalogo.where((e) => e.id != correcto.id).toList();

    final confundibles = otros
        .where((e) => correcto.idsConfundibles.contains(e.id))
        .toList()
      ..shuffle(_aleatorio);
    final mismoGrupo = otros
        .where((e) =>
            correcto.grupo != null &&
            e.grupo == correcto.grupo &&
            !confundibles.contains(e))
        .toList()
      ..shuffle(_aleatorio);
    final resto = otros
        .where((e) => !confundibles.contains(e) && !mismoGrupo.contains(e))
        .toList()
      ..shuffle(_aleatorio);

    return [...confundibles, ...mismoGrupo, ...resto].take(cuantos).toList();
  }

  /// 1.0 con distractores lejanos; hasta 3.0 si todos son confundibles
  /// o del mismo grupo. Es la misma escala 1-3 que usan las máquinas de
  /// Uno Roto.
  double _dificultad(ElementoQuiz correcto, List<ElementoQuiz> distractores) {
    if (distractores.isEmpty) return 1.0;
    final cercanos = distractores
        .where((d) =>
            correcto.idsConfundibles.contains(d.id) ||
            (correcto.grupo != null && d.grupo == correcto.grupo))
        .length;
    return 1.0 + 2.0 * cercanos / distractores.length;
  }
}
