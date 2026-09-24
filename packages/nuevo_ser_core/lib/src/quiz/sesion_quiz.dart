import 'calibracion_quiz.dart';
import 'generador_preguntas_quiz.dart';
import 'pregunta_quiz.dart';

/// Lo que se le pasa al juego cada vez que se responde una pregunta,
/// para que lo registre en su motor de maestría si quiere.
class ResultadoRespuestaQuiz {
  const ResultadoRespuestaQuiz({
    required this.pregunta,
    required this.idOpcionElegida,
    required this.acierto,
    required this.duracion,
    this.confianza,
  });

  final PreguntaQuiz pregunta;
  final String idOpcionElegida;
  final bool acierto;
  final Duration duracion;

  /// `null` si la partida no pide confianza.
  final ConfianzaRespuesta? confianza;

  String? get idHabilidad => pregunta.idHabilidad;
  double get dificultad => pregunta.dificultad;
}

/// Partida de quiz con un número fijo de preguntas y cierre (sin
/// «una más» infinita). Cada pregunta admite **una sola** respuesta:
/// es el primer intento, el único que cuenta para la maestría.
///
/// Puro: no sabe de widgets. La vista pregunta [preguntaActual],
/// llama a [responder] y luego a [avanzar].
class SesionQuiz {
  SesionQuiz({
    required GeneradorPreguntasQuiz generador,
    required this.numeroPreguntas,
    this.pideConfianza = false,
    this.alResponder,
  })  : assert(numeroPreguntas > 0),
        _generador = generador {
    _preguntaActual = _generador.siguiente();
  }

  final GeneradorPreguntasQuiz _generador;
  final int numeroPreguntas;

  /// Si es `true`, [responder] exige declarar la confianza.
  final bool pideConfianza;

  /// Se llama una vez por pregunta respondida.
  final void Function(ResultadoRespuestaQuiz resultado)? alResponder;

  late PreguntaQuiz _preguntaActual;
  ResultadoRespuestaQuiz? _respuestaActual;
  final List<ResultadoRespuestaQuiz> _respuestas = [];

  PreguntaQuiz get preguntaActual => _preguntaActual;

  /// Respuesta dada a la pregunta actual, o `null` si aún no se ha
  /// respondido.
  ResultadoRespuestaQuiz? get respuestaActual => _respuestaActual;

  /// Número de la pregunta actual, empezando en 1.
  int get numeroPreguntaActual => _respuestas.length +
      (_respuestaActual == null ? 1 : 0);

  List<ResultadoRespuestaQuiz> get respuestas => List.unmodifiable(_respuestas);

  bool get terminada =>
      _respuestas.length >= numeroPreguntas && _respuestaActual != null;

  /// Registra la respuesta a la pregunta actual. Devuelve `null` si ya
  /// estaba respondida (no hay segundo intento).
  ResultadoRespuestaQuiz? responder(
    String idOpcion, {
    required Duration duracion,
    ConfianzaRespuesta? confianza,
  }) {
    if (_respuestaActual != null) return null;
    if (pideConfianza && confianza == null) {
      throw ArgumentError('esta partida pide declarar la confianza');
    }
    if (!_preguntaActual.opciones.any((o) => o.idElemento == idOpcion)) {
      throw ArgumentError.value(idOpcion, 'idOpcion', 'no es una opción');
    }
    final resultado = ResultadoRespuestaQuiz(
      pregunta: _preguntaActual,
      idOpcionElegida: idOpcion,
      acierto: _preguntaActual.esCorrecta(idOpcion),
      duracion: duracion,
      confianza: confianza,
    );
    _respuestaActual = resultado;
    _respuestas.add(resultado);
    alResponder?.call(resultado);
    return resultado;
  }

  /// Pasa a la siguiente pregunta. Devuelve `false` (y no hace nada) si
  /// la actual no está respondida o la partida ha terminado.
  bool avanzar() {
    if (_respuestaActual == null || terminada) return false;
    _respuestaActual = null;
    _preguntaActual = _generador.siguiente();
    return true;
  }

  /// Resumen de calibración de lo respondido con confianza.
  ResumenCalibracionQuiz resumenCalibracion({
    EscalaConfianza escala = const EscalaConfianza(),
  }) {
    return ResumenCalibracionQuiz.calcular(
      [
        for (final respuesta in _respuestas)
          if (respuesta.confianza != null)
            RespuestaCalibrada(
              confianza: respuesta.confianza!,
              acierto: respuesta.acierto,
              numeroOpciones: respuesta.pregunta.opciones.length,
            ),
      ],
      escala: escala,
    );
  }
}
