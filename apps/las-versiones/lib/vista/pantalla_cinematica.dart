import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../nucleo/paleta_archivo.dart';
import 'avatar_personaje.dart';
import 'fondo_ambiente.dart';

/// Reproductor mínimo de cinemáticas para Las Versiones. Recorre los
/// planos genéricos de [EscenaCinematica] uno a uno:
///
/// - [PlanoAmbiente] auto-avanza tras [PlanoAmbiente.duracion]; si
///   trae texto de lectura se muestra como acotación tenue.
/// - [PlanoDialogo] revela el texto letra-a-letra. Tap acelera; tras
///   completar el reveal, el siguiente tap avanza.
/// - [PlanoEleccion] pide al jugador que elija entre 2-4 opciones.
///   Al elegir, los flags se propagan vía [alEstablecerFlag] y el
///   plano se cierra inmediatamente.
/// - [PlanoCierreAmable] muestra un botón grande centrado; al
///   pulsarlo cierra la escena.
///
/// Es deliberadamente más simple que `PantallaCinematica` de Uno
/// Roto: no hay PlanoInteractivo, no hay reveal de respuesta tras
/// elección, no hay escenario pintado, no hay sustitución de
/// tokens. Cuando alguno de esos elementos haga falta se
/// añadirá — o se considerará la extracción de la pantalla a la
/// plataforma como F1.5.
class PantallaCinematica extends StatefulWidget {
  /// Escena a reproducir.
  final EscenaCinematica escena;

  /// Callback al terminar la escena (tras el último plano o tras
  /// pulsar el botón de cierre amable).
  final VoidCallback alTerminar;

  /// Callback opcional invocado por cada flag activado durante la
  /// escena — típicamente lo persiste el orquestador.
  final ValueChanged<String>? alEstablecerFlag;

  /// Callback opcional para abrir el Menú principal mientras una
  /// cinemática está en pantalla. Se muestra como engranaje pequeño
  /// arriba-derecha, fuera del área de tap-para-avanzar.
  final VoidCallback? alAbrirMenu;

  /// Si [escena] es la versión corta de una cinemática, la versión
  /// entera. Aparece el botón «VER ENTERA», que la reproduce desde el
  /// principio en el mismo sitio (mismos flags al terminar).
  final EscenaCinematica? escenaEntera;

  const PantallaCinematica({
    super.key,
    required this.escena,
    required this.alTerminar,
    this.alEstablecerFlag,
    this.alAbrirMenu,
    this.escenaEntera,
  });

  @override
  State<PantallaCinematica> createState() => _PantallaCinematicaState();
}

/// Fases internas del player. El nombre describe en qué está la
/// pantalla en cada momento (no qué plano hay).
enum _Fase {
  pausaPrevia,
  revelando,
  esperandoTap,
  mostrandoOpciones,
  mostrandoCierreAmable,
}

class _PantallaCinematicaState extends State<PantallaCinematica> {
  /// Velocidad de reveal letra a letra. 25ms ≈ 40 caracteres por
  /// segundo, ritmo cómodo de lectura para el público objetivo.
  static const Duration _intervaloReveal = Duration(milliseconds: 25);

  /// Tiempo que la cinemática debe estar abierta antes de mostrar el
  /// botón "SALTAR ESCENA". Niños del público objetivo (10-14 años)
  /// necesitan poder escapar de cinemáticas largas sin pelearse con
  /// el tap-skip plano a plano. 8 segundos da tiempo a leer el primer
  /// plano de contexto pero corta antes de que la sensación de
  /// "página interminable" se consolide.
  static const Duration _retardoBotonSaltar = Duration(seconds: 8);

  int _indicePlano = 0;
  _Fase _fase = _Fase.pausaPrevia;

  /// Escena en reproducción: la recibida, o la entera si se pulsó
  /// «VER ENTERA».
  late EscenaCinematica _escena = widget.escena;

  /// Réplica a la opción elegida en un `PlanoEleccion`
  /// (`OpcionEleccion.textoRespuesta`), mostrada como diálogo antes de
  /// pasar al plano siguiente.
  PlanoDialogo? _planoRespuesta;
  int _caracteresRevelados = 0;
  Timer? _temporizadorReveal;
  Timer? _temporizadorPlanoAmbiente;
  Timer? _temporizadorBotonSaltar;
  bool _botonSaltarVisible = false;

  PlanoEscena get _planoActual => _planoRespuesta ?? _escena.planos[_indicePlano];

  bool get _puedeVerEntera =>
      widget.escenaEntera != null && !identical(_escena, widget.escenaEntera);

  void _verEntera() {
    final entera = widget.escenaEntera;
    if (entera == null) return;
    HapticFeedback.selectionClick();
    _temporizadorReveal?.cancel();
    _temporizadorPlanoAmbiente?.cancel();
    setState(() {
      _escena = entera;
      _indicePlano = 0;
      _planoRespuesta = null;
      _caracteresRevelados = 0;
      _fase = _Fase.pausaPrevia;
    });
    _iniciarPlanoActual();
  }

  /// `true` si el botón SALTAR ESCENA debe estar visible y operable.
  /// No aparece durante un `PlanoEleccion` — la elección es agencia
  /// del jugador y no debe poder esquivarse con el botón. Tampoco se
  /// muestra sobre `PlanoCierreAmable` porque ese ya es el botón
  /// natural de salida.
  bool get _puedeSaltar {
    if (!_botonSaltarVisible) return false;
    final plano = _planoActual;
    if (plano is PlanoEleccion) return false;
    if (plano is PlanoCierreAmable) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarPlanoActual());
    _temporizadorBotonSaltar = Timer(_retardoBotonSaltar, () {
      if (!mounted) return;
      setState(() => _botonSaltarVisible = true);
    });
  }

  @override
  void dispose() {
    _temporizadorReveal?.cancel();
    _temporizadorPlanoAmbiente?.cancel();
    _temporizadorBotonSaltar?.cancel();
    super.dispose();
  }

  void _iniciarPlanoActual() {
    if (!mounted) return;
    final plano = _planoActual;
    setState(() {
      _caracteresRevelados = 0;
      _fase = _Fase.pausaPrevia;
    });

    if (plano is PlanoAmbiente) {
      _temporizadorPlanoAmbiente = Timer(plano.duracion, _avanzar);
      return;
    }
    if (plano is PlanoDialogo) {
      Timer(plano.pausaPrevia, _empezarRevealDialogo);
      return;
    }
    if (plano is PlanoEleccion) {
      _empezarRevealPrompt();
      return;
    }
    if (plano is PlanoCierreAmable) {
      Timer(plano.pausaPrevia, () {
        if (!mounted) return;
        setState(() => _fase = _Fase.mostrandoCierreAmable);
      });
      return;
    }
    // Plano desconocido — saltamos sin romper.
    _avanzar();
  }

  void _empezarRevealDialogo() {
    if (!mounted) return;
    final plano = _planoActual;
    if (plano is! PlanoDialogo) return;
    _revelar(plano.texto, faseFinal: _Fase.esperandoTap);
  }

  void _empezarRevealPrompt() {
    if (!mounted) return;
    final plano = _planoActual;
    if (plano is! PlanoEleccion) return;
    final prompt = plano.textoPrompt ?? '';
    if (prompt.isEmpty) {
      setState(() => _fase = _Fase.mostrandoOpciones);
      return;
    }
    _revelar(prompt, faseFinal: _Fase.mostrandoOpciones);
  }

  void _revelar(String texto, {required _Fase faseFinal}) {
    setState(() {
      _caracteresRevelados = 0;
      _fase = _Fase.revelando;
    });
    _temporizadorReveal = Timer.periodic(_intervaloReveal, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _caracteresRevelados++);
      if (_caracteresRevelados >= texto.length) {
        timer.cancel();
        setState(() => _fase = faseFinal);
      }
    });
  }

  void _completarRevealActual() {
    _temporizadorReveal?.cancel();
    final plano = _planoActual;
    int longitudFinal = 0;
    if (plano is PlanoDialogo) {
      longitudFinal = plano.texto.length;
    } else if (plano is PlanoEleccion) {
      longitudFinal = (plano.textoPrompt ?? '').length;
    }
    setState(() => _caracteresRevelados = longitudFinal);
  }

  void _alPulsar() {
    final plano = _planoActual;
    switch (_fase) {
      case _Fase.pausaPrevia:
        // Durante un PlanoAmbiente la fase queda en pausaPrevia
        // mientras corre su Timer; el tap salta el resto del plano.
        // En la pausa previa de un PlanoDialogo (típicamente <1s) lo
        // ignoramos para no interrumpir el ritmo del diálogo antes de
        // que empiece el reveal.
        if (plano is PlanoAmbiente) {
          HapticFeedback.selectionClick();
          _avanzar();
        }
        return;
      case _Fase.mostrandoOpciones:
      case _Fase.mostrandoCierreAmable:
        return;
      case _Fase.revelando:
        _completarRevealActual();
        if (plano is PlanoEleccion) {
          setState(() => _fase = _Fase.mostrandoOpciones);
        } else {
          setState(() => _fase = _Fase.esperandoTap);
        }
      case _Fase.esperandoTap:
        HapticFeedback.selectionClick();
        _avanzar();
    }
  }

  void _elegirOpcion(int indice) {
    if (_fase != _Fase.mostrandoOpciones) return;
    final plano = _planoActual;
    if (plano is! PlanoEleccion) return;
    HapticFeedback.selectionClick();
    final opcion = plano.opciones[indice];
    for (final flag in opcion.flagsAEstablecer) {
      widget.alEstablecerFlag?.call(flag);
    }
    final respuesta = opcion.textoRespuesta;
    if (respuesta != null && respuesta.isNotEmpty) {
      setState(() {
        _planoRespuesta = PlanoDialogo(
          voz: opcion.vozRespuesta ?? plano.voz,
          texto: respuesta,
        );
      });
      _iniciarPlanoActual();
      return;
    }
    _avanzar();
  }

  void _avanzar() {
    if (!mounted) return;
    _temporizadorReveal?.cancel();
    _temporizadorPlanoAmbiente?.cancel();
    _planoRespuesta = null;
    if (_indicePlano + 1 >= _escena.planos.length) {
      widget.alTerminar();
      return;
    }
    setState(() => _indicePlano++);
    _iniciarPlanoActual();
  }

  /// Salta hasta el siguiente `PlanoEleccion` o al final de la
  /// escena. Si la cinemática no contiene más elecciones por delante,
  /// se cierra entera (igual que el último tap del último plano —
  /// dispara `alTerminar` que activa el `flagDeSalida` y los flags de
  /// cierre institucionales). Si quedan elecciones por delante, se
  /// detiene en la primera para que el jugador decida — el motivo
  /// que la elección encarna no se puede saltar (por ejemplo, la
  /// pregunta nuclear de Begoña en 1.0.1 *"¿por qué estás aquí?"*).
  void _saltarHastaSiguienteEleccionOFinal() {
    if (!_puedeSaltar) return;
    HapticFeedback.selectionClick();
    _temporizadorReveal?.cancel();
    _temporizadorPlanoAmbiente?.cancel();
    _planoRespuesta = null;
    final planos = _escena.planos;
    var indice = _indicePlano + 1;
    while (indice < planos.length) {
      if (planos[indice] is PlanoEleccion) break;
      indice++;
    }
    if (indice >= planos.length) {
      widget.alTerminar();
      return;
    }
    setState(() {
      _indicePlano = indice;
      _caracteresRevelados = 0;
      _fase = _Fase.pausaPrevia;
    });
    _iniciarPlanoActual();
  }

  @override
  Widget build(BuildContext contexto) {
    final totalPlanos = _escena.planos.length;
    final fraccion =
        totalPlanos == 0 ? 0.0 : (_indicePlano + 1) / totalPlanos;
    return Scaffold(
      backgroundColor: PaletaArchivo.fondoProfundo,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _alPulsar,
        child: Stack(
          children: [
            Positioned.fill(
              child: FondoAmbiente(ambiente: _escena.ambiente),
            ),
            SafeArea(child: _construirContenidoDePlano()),
            // Barra de progreso de la cinemática — discreta, en la
            // parte superior. Anticipa la duración para que el niño
            // no sienta que el flujo es interminable.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    value: fraccion,
                    minHeight: 2,
                    backgroundColor:
                        PaletaArchivo.ambarLacre.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PaletaArchivo.ambarLacre.withOpacity(0.55),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.alAbrirMenu != null)
              Positioned(
                top: 4,
                right: 4,
                child: SafeArea(
                  child: IconButton(
                    tooltip: 'Menú',
                    iconSize: 22,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: PaletaArchivo.ambarLacre,
                    ),
                    onPressed: widget.alAbrirMenu,
                  ),
                ),
              ),
            // «VER ENTERA» — arriba a la izquierda, sólo en la versión
            // corta de una escena. Discreto: la corta es la opción por
            // defecto (muchos 12-13 años se aburrían leyendo).
            if (_puedeVerEntera)
              Positioned(
                top: 4,
                left: 4,
                child: SafeArea(
                  child: TextButton.icon(
                    onPressed: _verEntera,
                    style: TextButton.styleFrom(
                      foregroundColor: PaletaArchivo.textoTenue,
                    ),
                    icon: const Icon(Icons.unfold_more, size: 16),
                    label: const Text(
                      'VER ENTERA',
                      style: TextStyle(fontSize: 11, letterSpacing: 2.4),
                    ),
                  ),
                ),
              ),
            // Botón SALTAR ESCENA — abajo a la izquierda, fuera del
            // área principal de tap-para-avanzar. Tras 8 segundos se
            // hace fade-in. Oculto durante PlanoEleccion (la decisión
            // necesita agencia) y durante PlanoCierreAmable (el
            // cierre amable ya es el botón natural).
            Positioned(
              bottom: 12,
              left: 12,
              child: SafeArea(
                child: IgnorePointer(
                  ignoring: !_puedeSaltar,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _puedeSaltar ? 0.85 : 0.0,
                    child: TextButton.icon(
                      onPressed: _saltarHastaSiguienteEleccionOFinal,
                      style: TextButton.styleFrom(
                        foregroundColor: PaletaArchivo.ambarLacre,
                        backgroundColor:
                            PaletaArchivo.fondoMedio.withOpacity(0.75),
                        side: BorderSide(
                          color:
                              PaletaArchivo.ambarLacre.withOpacity(0.55),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.fast_forward, size: 16),
                      label: const Text(
                        'SALTAR',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenidoDePlano() {
    final plano = _planoActual;
    if (plano is PlanoAmbiente) {
      return _VistaAmbiente(textoLectura: plano.textoLectura);
    }
    if (plano is PlanoDialogo) {
      final completo = plano.texto;
      return _VistaDialogo(
        voz: plano.voz,
        textoRevelado: completo.substring(
          0,
          _caracteresRevelados.clamp(0, completo.length),
        ),
        mostrandoIndicador: _fase == _Fase.esperandoTap,
      );
    }
    if (plano is PlanoEleccion) {
      final prompt = plano.textoPrompt ?? '';
      final textoPromptRevelado = _fase == _Fase.revelando
          ? prompt.substring(0, _caracteresRevelados.clamp(0, prompt.length))
          : prompt;
      return _VistaEleccion(
        voz: plano.voz,
        textoPrompt: textoPromptRevelado,
        opciones: plano.opciones,
        mostrandoOpciones: _fase == _Fase.mostrandoOpciones,
        alElegir: _elegirOpcion,
      );
    }
    if (plano is PlanoCierreAmable) {
      return _VistaCierreAmable(
        textoBoton: plano.textoBoton,
        visible: _fase == _Fase.mostrandoCierreAmable,
        alPulsar: _avanzar,
      );
    }
    return const SizedBox.shrink();
  }
}

class _VistaAmbiente extends StatelessWidget {
  final String? textoLectura;

  const _VistaAmbiente({this.textoLectura});

  @override
  Widget build(BuildContext contexto) {
    final texto = textoLectura;
    if (texto == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 140),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.8,
            fontStyle: FontStyle.italic,
            color: PaletaArchivo.textoTenue.withOpacity(0.65),
            fontWeight: FontWeight.w300,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}

class _VistaDialogo extends StatelessWidget {
  final VozPersonajeContrato voz;
  final String textoRevelado;
  final bool mostrandoIndicador;

  const _VistaDialogo({
    required this.voz,
    required this.textoRevelado,
    required this.mostrandoIndicador,
  });

  @override
  Widget build(BuildContext contexto) {
    final nombre = voz.nombreVisible;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nombre.isNotEmpty) _CabeceraVoz(voz: voz),
          const SizedBox(height: 10),
          Text(textoRevelado, style: voz.estiloTextoCuerpo()),
          const SizedBox(height: 18),
          AnimatedOpacity(
            opacity: mostrandoIndicador ? 0.55 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Text(
              'toca para continuar',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2.2,
                color: PaletaArchivo.textoTenue.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaEleccion extends StatelessWidget {
  final VozPersonajeContrato voz;
  final String textoPrompt;
  final List<OpcionEleccion> opciones;
  final bool mostrandoOpciones;
  final ValueChanged<int> alElegir;

  const _VistaEleccion({
    required this.voz,
    required this.textoPrompt,
    required this.opciones,
    required this.mostrandoOpciones,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext contexto) {
    final nombre = voz.nombreVisible;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textoPrompt.isNotEmpty) ...[
            if (nombre.isNotEmpty) _CabeceraVoz(voz: voz),
            const SizedBox(height: 10),
            Text(textoPrompt, style: voz.estiloTextoCuerpo()),
            const SizedBox(height: 22),
          ],
          if (mostrandoOpciones)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var indice = 0; indice < opciones.length; indice++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _BotonOpcion(
                      texto: opciones[indice].textoJugador,
                      alPulsar: () => alElegir(indice),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BotonOpcion extends StatelessWidget {
  final String texto;
  final VoidCallback alPulsar;

  const _BotonOpcion({required this.texto, required this.alPulsar});

  @override
  Widget build(BuildContext contexto) {
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PaletaArchivo.fondoMedio.withOpacity(0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: PaletaArchivo.ambarLacre.withOpacity(0.45),
            width: 1.0,
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            color: PaletaArchivo.textoPrincipal,
            letterSpacing: 0.3,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Cabecera del bloque de diálogo: avatar procedural a la izquierda +
/// nombre del hablante en versalitas a la derecha. Se usa para
/// `PlanoDialogo` y para el prompt de un `PlanoEleccion`.
class _CabeceraVoz extends StatelessWidget {
  final VozPersonajeContrato voz;

  const _CabeceraVoz({required this.voz});

  @override
  Widget build(BuildContext contexto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarPersonaje(voz: voz),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            voz.nombreVisible.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 4,
              color: voz.colorNombre,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _VistaCierreAmable extends StatelessWidget {
  final String textoBoton;
  final bool visible;
  final VoidCallback alPulsar;

  const _VistaCierreAmable({
    required this.textoBoton,
    required this.visible,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext contexto) {
    return Center(
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 420),
        child: TextButton(
          onPressed: visible ? alPulsar : null,
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            foregroundColor: PaletaArchivo.textoPrincipal,
            side: BorderSide(
              color: PaletaArchivo.ambarLacre.withOpacity(0.55),
              width: 1.2,
            ),
            backgroundColor: PaletaArchivo.fondoMedio.withOpacity(0.45),
          ),
          child: Text(
            textoBoton,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
