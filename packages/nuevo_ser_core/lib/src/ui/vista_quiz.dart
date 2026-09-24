import 'package:flutter/material.dart';

import '../quiz/calibracion_quiz.dart';
import '../quiz/pregunta_quiz.dart';
import '../quiz/sesion_quiz.dart';

/// Textos de la vista de quiz. Cada juego los da en su voz e idioma.
class TextosQuiz {
  const TextosQuiz({
    required this.siguiente,
    required this.terminar,
    this.preguntaConfianza = '¿Cuánto te fías de tu respuesta?',
    this.etiquetasConfianza = const {
      ConfianzaRespuesta.alta: 'Seguro',
      ConfianzaRespuesta.media: 'Creo que sí',
      ConfianzaRespuesta.baja: 'No lo sé',
    },
    this.progreso,
  });

  final String siguiente;
  final String terminar;
  final String preguntaConfianza;
  final Map<ConfianzaRespuesta, String> etiquetasConfianza;

  /// «Pregunta 2 de 5». `null` para no enseñarlo.
  final String Function(int actual, int total)? progreso;
}

/// Colores de la devolución. Por defecto **no hay rojo**: la opción
/// correcta se resalta y la elegida por error sólo se marca con un
/// borde apagado (regla de los juegos Kids: nunca humillar). Las apps
/// de adulto pueden pasar verde/rojo.
class ColoresDevolucionQuiz {
  const ColoresDevolucionQuiz({this.correcta, this.elegidaErronea});

  final Color? correcta;
  final Color? elegidaErronea;
}

/// Vista genérica de una [SesionQuiz]. No lleva Scaffold: el juego la
/// mete en su propio marco (la mesa del Archivo, el cuaderno…).
///
/// - Sin marcador salvo que se pida con [mostrarMarcador].
/// - Si la sesión pide confianza, primero se elige la opción y después
///   se declara la confianza; hasta entonces no se revela nada.
/// - La imagen la construye el juego con [constructorImagen] (asset
///   local en Kids, red en apps de adulto).
class VistaQuiz extends StatefulWidget {
  const VistaQuiz({
    super.key,
    required this.sesion,
    required this.textos,
    required this.alTerminar,
    this.constructorImagen,
    this.mostrarMarcador = false,
    this.colores = const ColoresDevolucionQuiz(),
  });

  final SesionQuiz sesion;
  final TextosQuiz textos;
  final void Function(SesionQuiz sesion) alTerminar;
  final Widget Function(BuildContext context, String rutaImagen)?
      constructorImagen;
  final bool mostrarMarcador;
  final ColoresDevolucionQuiz colores;

  @override
  State<VistaQuiz> createState() => _EstadoVistaQuiz();
}

class _EstadoVistaQuiz extends State<VistaQuiz> {
  final Stopwatch _cronometroPregunta = Stopwatch()..start();

  /// Opción tocada a la espera de declarar la confianza.
  String? _opcionPendienteDeConfianza;

  SesionQuiz get _sesion => widget.sesion;

  void _alTocarOpcion(String idOpcion) {
    if (_sesion.respuestaActual != null) return;
    if (_sesion.pideConfianza) {
      setState(() => _opcionPendienteDeConfianza = idOpcion);
      return;
    }
    _responder(idOpcion, null);
  }

  void _responder(String idOpcion, ConfianzaRespuesta? confianza) {
    _cronometroPregunta.stop();
    setState(() {
      _sesion.responder(idOpcion,
          duracion: _cronometroPregunta.elapsed, confianza: confianza);
      _opcionPendienteDeConfianza = null;
    });
  }

  void _alPulsarSiguiente() {
    if (_sesion.terminada) {
      widget.alTerminar(_sesion);
      return;
    }
    setState(() {
      _sesion.avanzar();
      _cronometroPregunta
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pregunta = _sesion.preguntaActual;
    final respuesta = _sesion.respuestaActual;
    final aciertos = _sesion.respuestas.where((r) => r.acierto).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.textos.progreso != null || widget.mostrarMarcador)
          Row(
            children: [
              if (widget.textos.progreso != null)
                Text(
                  widget.textos.progreso!(
                      _sesion.numeroPreguntaActual.clamp(
                          1, _sesion.numeroPreguntas),
                      _sesion.numeroPreguntas),
                  style: tema.textTheme.labelLarge,
                ),
              const Spacer(),
              if (widget.mostrarMarcador)
                Text('$aciertos / ${_sesion.respuestas.length}',
                    style: tema.textTheme.labelLarge),
            ],
          ),
        const SizedBox(height: 8),
        Text(pregunta.enunciado, style: tema.textTheme.titleLarge),
        if (pregunta.rutaImagen != null && widget.constructorImagen != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.constructorImagen!(context, pregunta.rutaImagen!),
              ),
            ),
          ),
        const SizedBox(height: 8),
        for (final opcion in pregunta.opciones)
          _TarjetaOpcion(
            opcion: opcion,
            estado: _estadoOpcion(opcion, pregunta, respuesta),
            colores: widget.colores,
            alTocar: () => _alTocarOpcion(opcion.idElemento),
          ),
        if (_opcionPendienteDeConfianza != null) ...[
          const SizedBox(height: 16),
          Text(widget.textos.preguntaConfianza,
              style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final confianza in ConfianzaRespuesta.values)
                OutlinedButton(
                  onPressed: () =>
                      _responder(_opcionPendienteDeConfianza!, confianza),
                  child: Text(
                      widget.textos.etiquetasConfianza[confianza] ??
                          confianza.name),
                ),
            ],
          ),
        ],
        if (respuesta != null) ...[
          if (pregunta.explicacion != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(pregunta.explicacion!,
                  style: tema.textTheme.bodyLarge),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _alPulsarSiguiente,
              child: Text(_sesion.terminada
                  ? widget.textos.terminar
                  : widget.textos.siguiente),
            ),
          ),
        ],
      ],
    );
  }

  _EstadoOpcion _estadoOpcion(OpcionQuiz opcion, PreguntaQuiz pregunta,
      ResultadoRespuestaQuiz? respuesta) {
    if (respuesta == null) {
      return opcion.idElemento == _opcionPendienteDeConfianza
          ? _EstadoOpcion.marcada
          : _EstadoOpcion.normal;
    }
    if (pregunta.esCorrecta(opcion.idElemento)) return _EstadoOpcion.correcta;
    if (opcion.idElemento == respuesta.idOpcionElegida) {
      return _EstadoOpcion.elegidaErronea;
    }
    return _EstadoOpcion.normal;
  }
}

enum _EstadoOpcion { normal, marcada, correcta, elegidaErronea }

class _TarjetaOpcion extends StatelessWidget {
  const _TarjetaOpcion({
    required this.opcion,
    required this.estado,
    required this.colores,
    required this.alTocar,
  });

  final OpcionQuiz opcion;
  final _EstadoOpcion estado;
  final ColoresDevolucionQuiz colores;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final Color colorBorde;
    Color? colorFondo;
    switch (estado) {
      case _EstadoOpcion.normal:
        colorBorde = esquema.outlineVariant;
      case _EstadoOpcion.marcada:
        colorBorde = esquema.primary;
      case _EstadoOpcion.correcta:
        colorBorde = colores.correcta ?? esquema.primary;
        colorFondo = (colores.correcta ?? esquema.primary).withValues(alpha: 0.12);
      case _EstadoOpcion.elegidaErronea:
        colorBorde = colores.elegidaErronea ?? esquema.outline;
        colorFondo = colores.elegidaErronea?.withValues(alpha: 0.12);
    }
    return Card(
      color: colorFondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: colorBorde,
            width: estado == _EstadoOpcion.normal ? 1 : 2),
      ),
      child: ListTile(title: Text(opcion.texto), onTap: alTocar),
    );
  }
}
