import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../dominio/ambiente_cielo.dart';
import '../dominio/plano_escena.dart';
import '../dominio/ritmo_juego.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import '../dominio/voz_personaje.dart';
import '../sonido/catalogo_voces.dart';
import '../sonido/servicio_sonoro.dart';
import 'escenario.dart';
import 'sora_presencia.dart';
import 'widget_fragmento_tutorial.dart';

/// Reproductor de escenas cinemáticas. Recorre los planos uno a uno
/// respetando:
/// - Silencios escritos (PlanoAmbiente auto-avanza tras su duración).
/// - Reveal letra-a-letra para diálogos (doc 13 §2.1 planos duran).
/// - Pausa entre frases del mismo personaje (pausaPrevia).
/// - Opciones en PlanoEleccion — se revelan tras el prompt; al elegir,
///   se muestra la respuesta como un sub-reveal y se activan flags.
/// - Tap para completar el reveal o avanzar cuando está esperando.
/// Al terminar invoca [alTerminar].
class PantallaCinematica extends StatefulWidget {
  final EscenaCinematica escena;
  final VoidCallback alTerminar;

  /// Nombre del jugador. Se sustituye en los textos cada vez que aparece
  /// el token `{nombre}` — guion del Arco 1.
  final String nombreJugador;

  /// Callback invocado por cada flag narrativo establecido durante la
  /// escena — típicamente para persistirlo en el repositorio. Es async
  /// porque la persistencia con SharedPreferences lo es; los sitios
  /// llamantes deben hacer `await` para evitar perder el flag si la
  /// app se cierra entre la elección y el commit a disco.
  final Future<void> Function(String)? alEstablecerFlag;

  /// Ritmo del juego — afecta velocidad de reveal y duración de
  /// ambientes. Si se omite, usa estándar.
  final RitmoJuego ritmo;

  const PantallaCinematica({
    super.key,
    required this.escena,
    required this.alTerminar,
    this.nombreJugador = '',
    this.alEstablecerFlag,
    this.ritmo = RitmoJuego.estandar,
  });

  @override
  State<PantallaCinematica> createState() => _PantallaCinematicaState();
}

/// Sustituye `{nombre}` por el nombre real del jugador. Se mantiene como
/// función pura para poder usarla desde tests.
String aplicarTokens(String texto, String nombreJugador) {
  if (nombreJugador.isEmpty) return texto;
  return texto.replaceAll('{nombre}', nombreJugador);
}

/// Traduce primero al idioma del [locale] y luego sustituye `{nombre}`.
/// Las claves de la traducción incluyen el token literal `{nombre}`,
/// así que el orden importa: traducir antes de aplicar tokens.
String traducirYAplicarTokens(
  String textoEs,
  String nombreJugador,
  Locale? locale,
) {
  return aplicarTokens(traducirNarrativa(textoEs, locale), nombreJugador);
}

enum _FaseReproduccion {
  pausaPrevia,
  revelando,
  esperandoTap,
  mostrandoOpciones,
  revelandoRespuesta,
  esperandoTapRespuesta,
  esperandoAccionInteractiva,
  mostrandoCierreAmable,
  saliendo,
}

class _PantallaCinematicaState extends State<PantallaCinematica>
    with TickerProviderStateMixin {
  static const Duration _duracionFade = Duration(milliseconds: 420);
  static const Duration _intervaloRevealBase = Duration(milliseconds: 32);

  Duration get _intervaloReveal => Duration(
        milliseconds: (_intervaloRevealBase.inMilliseconds *
                widget.ritmo.multiplicadorReveal)
            .round(),
      );

  Duration _duracionAmbiente(Duration base) => Duration(
        milliseconds:
            (base.inMilliseconds * widget.ritmo.multiplicadorAmbiente).round(),
      );

  late final AnimationController _controladorCielo;
  late final AnimationController _controladorLluvia;
  late final AnimationController _controladorFade;
  late final Animation<Offset> _desplazamientoEntrada;

  int _indicePlano = 0;
  int _caracteresRevelados = 0;
  _FaseReproduccion _fase = _FaseReproduccion.pausaPrevia;
  Timer? _temporizador;

  /// Índice de la opción elegida en un PlanoEleccion. null mientras no
  /// se haya elegido.
  int? _indiceOpcionElegida;

  @override
  void initState() {
    super.initState();
    _controladorCielo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    // Periodo corto para la lluvia: cada ~1.5s las gotas hacen una pasada
    // completa por la pantalla. Solo se activa visiblemente cuando la
    // escena trae intensidadLluvia > 0.
    _controladorLluvia = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _controladorFade = AnimationController(
      vsync: this,
      duration: _duracionFade,
      value: 0,
    );
    _desplazamientoEntrada = Tween<Offset>(
      begin: const Offset(0, 0.028),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controladorFade,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _dispararSonidosDeEscena();
    _iniciarPlanoActual();
  }

  @override
  void didUpdateWidget(covariant PantallaCinematica viejo) {
    super.didUpdateWidget(viejo);
    // El orquestador puede cambiar la escena por prop sin recrear el
    // widget. Si no reseteamos, el _indicePlano se queda apuntando a
    // un plano que la nueva escena no tiene → RangeError. Detectamos
    // por identidad: la lista `planos` de cada escena es inmutable,
    // así que comparar referencias es suficiente y barato.
    if (!identical(viejo.escena.planos, widget.escena.planos)) {
      _temporizador?.cancel();
      _indicePlano = 0;
      _caracteresRevelados = 0;
      _indiceOpcionElegida = null;
      _fase = _FaseReproduccion.pausaPrevia;
      _dispararSonidosDeEscena();
      _iniciarPlanoActual();
    }
  }

  void _dispararSonidosDeEscena() {
    // Motivos puntuales (doc 12 §Momentos sonoros únicos). Se reproducen
    // como efecto: el catálogo los marca en capa narrativa para que
    // atenúen el resto si procede.
    final sonidoEntrada = widget.escena.sonidoDeEntrada;
    if (sonidoEntrada != null) {
      ServicioSonoro.instancia.reproducirEfecto(sonidoEntrada);
    }
    final loop = widget.escena.loopDeFondo;
    if (loop != null) {
      ServicioSonoro.instancia.reproducirLoop(loop, msFade: 1800);
    }
  }

  @override
  void dispose() {
    _controladorCielo.dispose();
    _controladorLluvia.dispose();
    _controladorFade.dispose();
    _temporizador?.cancel();
    // Si la escena trajo loop propio, lo apagamos al salir con fade
    // amable. Si no había loop, esto es no-op.
    if (widget.escena.loopDeFondo != null) {
      ServicioSonoro.instancia
          .detenerCapa(CapaAudio.musica, msFade: 1200);
    }
    super.dispose();
  }

  PlanoEscena get _planoActual {
    final planos = widget.escena.planos;
    final indice = _indicePlano.clamp(0, planos.length - 1);
    return planos[indice];
  }

  /// Voz "visible" del plano actual: la del diálogo si es PlanoDialogo,
  /// la del prompt si es PlanoEleccion, null en ambientes y cierres.
  /// Se usa para decidir qué avatar de personaje superponer.
  VozPersonajeContrato? get _vozActivaPlano {
    final plano = _planoActual;
    if (plano is PlanoDialogo) return plano.voz;
    if (plano is PlanoEleccion) return plano.voz;
    return null;
  }

  /// Devuelve el avatar GRANDE del personaje que está hablando en el
  /// plano actual. Ocupa hasta el 50 % del alto disponible y lleva
  /// animación de respiración (escala cíclica) + sway lateral muy
  /// sutil — así no parece un sticker estático.
  ///
  /// Kai y Oryn usan los PNG escaneados del concept-art original; Sora
  /// reutiliza su CustomPainter (silueta) escalado vía FittedBox al
  /// mismo tamaño que los demás.
  ///
  /// Devuelve SizedBox vacío para voces sin avatar (Irune, Rexán, Ari,
  /// Vadic, Naini, Brina, Niko, narrador, Fragmentos nombrados).
  Widget _construirPresenciaPersonaje() {
    final voz = _vozActivaPlano;
    Widget? avatarCrudo;
    Alignment alineacion = Alignment.bottomCenter;
    if (voz == VozPersonaje.sora) {
      // SoraPresencia fija el alto (120) pero no el ancho: dentro de un
      // FittedBox el ancho quedaría sin límite y su Stack no se podría
      // maquetar. Se le da su tamaño natural (avatar de 70 px a 16 px del
      // borde) y el FittedBox la infla desde ahí.
      avatarCrudo = const FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 86,
          height: 120,
          child: SoraPresencia(textoActivo: null),
        ),
      );
      alineacion = Alignment.bottomLeft;
    } else if (voz == VozPersonaje.kai) {
      avatarCrudo = Image.asset(
        'assets/personajes/kai.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
      alineacion = Alignment.bottomRight;
    } else if (voz == VozPersonaje.oryn) {
      avatarCrudo = Image.asset(
        'assets/personajes/oryn.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
      alineacion = Alignment.bottomCenter;
    }
    if (avatarCrudo == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: AnimatedOpacity(
            opacity: _fase == _FaseReproduccion.saliendo ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 320),
            child: Align(
              alignment: alineacion,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                child: _AvatarRespirando(child: avatarCrudo),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _iniciarPlanoActual() async {
    _temporizador?.cancel();
    _caracteresRevelados = 0;
    _indiceOpcionElegida = null;
    _fase = _FaseReproduccion.pausaPrevia;

    await _controladorFade.forward();
    if (!mounted) return;

    final plano = _planoActual;
    switch (plano) {
      case PlanoAmbiente():
        setState(() => _fase = _FaseReproduccion.revelando);
        _temporizador = Timer(_duracionAmbiente(plano.duracion), _avanzar);
      case PlanoDialogo():
        if (plano.pausaPrevia > Duration.zero) {
          _temporizador = Timer(plano.pausaPrevia, _empezarRevealDialogo);
        } else {
          _empezarRevealDialogo();
        }
      case PlanoEleccion():
        if (plano.textoPrompt == null) {
          setState(() => _fase = _FaseReproduccion.mostrandoOpciones);
        } else {
          _empezarRevealPrompt();
        }
      case PlanoInteractivo():
        setState(() => _fase = _FaseReproduccion.esperandoAccionInteractiva);
      case PlanoCierreAmable():
        if (plano.pausaPrevia > Duration.zero) {
          _temporizador = Timer(
            plano.pausaPrevia,
            () {
              if (!mounted) return;
              setState(() => _fase = _FaseReproduccion.mostrandoCierreAmable);
            },
          );
        } else {
          setState(() => _fase = _FaseReproduccion.mostrandoCierreAmable);
        }
    }
  }

  String _conTokens(String texto) => traducirYAplicarTokens(
        texto,
        widget.nombreJugador,
        Localizations.maybeLocaleOf(context),
      );

  void _empezarRevealDialogo() {
    if (!mounted) return;
    final plano = _planoActual;
    if (plano is! PlanoDialogo) return;
    // Si esta frase canónica tiene voz TTS generada, la disparamos
    // al inicio del reveal. Capa narrativos → ducking automático
    // sobre música/ambient. Si no está catalogada, sigue como hoy
    // (texto en pantalla y sin audio).
    final rutaVoz = CatalogoVoces.rutaVozPara(plano.voz, plano.texto);
    if (rutaVoz != null) {
      ServicioSonoro.instancia.reproducirVoz(rutaVoz);
    }
    _revelarTexto(
      _conTokens(plano.texto),
      faseAlTerminar: _FaseReproduccion.esperandoTap,
    );
  }

  void _empezarRevealPrompt() {
    final plano = _planoActual;
    if (plano is! PlanoEleccion) return;
    _revelarTexto(
      _conTokens(plano.textoPrompt ?? ''),
      faseAlTerminar: _FaseReproduccion.mostrandoOpciones,
    );
  }

  void _empezarRevealRespuesta() {
    final plano = _planoActual;
    if (plano is! PlanoEleccion) return;
    final indice = _indiceOpcionElegida;
    if (indice == null) return;
    final respuesta = _conTokens(plano.opciones[indice].textoRespuesta ?? '');
    if (respuesta.isEmpty) {
      _avanzar();
      return;
    }
    _revelarTexto(
      respuesta,
      faseAlTerminar: _FaseReproduccion.esperandoTapRespuesta,
    );
  }

  void _revelarTexto(String texto, {required _FaseReproduccion faseAlTerminar}) {
    setState(() {
      _caracteresRevelados = 0;
      _fase = faseAlTerminar == _FaseReproduccion.esperandoTapRespuesta
          ? _FaseReproduccion.revelandoRespuesta
          : _FaseReproduccion.revelando;
    });
    _temporizador = Timer.periodic(_intervaloReveal, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _caracteresRevelados++;
      });
      if (_caracteresRevelados >= texto.length) {
        timer.cancel();
        setState(() => _fase = faseAlTerminar);
      }
    });
  }

  Future<void> _elegirOpcion(int indice) async {
    final plano = _planoActual;
    if (plano is! PlanoEleccion) return;
    if (_fase != _FaseReproduccion.mostrandoOpciones) return;
    HapticFeedback.selectionClick();
    setState(() => _indiceOpcionElegida = indice);
    final callback = widget.alEstablecerFlag;
    if (callback != null) {
      for (final flag in plano.opciones[indice].flagsAEstablecer) {
        await callback(flag);
      }
    }
    if (!mounted) return;
    _empezarRevealRespuesta();
  }

  void _alPulsar() {
    final plano = _planoActual;
    switch (_fase) {
      case _FaseReproduccion.pausaPrevia:
      case _FaseReproduccion.saliendo:
      case _FaseReproduccion.mostrandoOpciones:
      case _FaseReproduccion.esperandoAccionInteractiva:
      case _FaseReproduccion.mostrandoCierreAmable:
        return;
      case _FaseReproduccion.revelando:
        _completarRevealActual();
        setState(() => _fase = _FaseReproduccion.esperandoTap);
        if (plano is PlanoEleccion) {
          setState(() => _fase = _FaseReproduccion.mostrandoOpciones);
        }
      case _FaseReproduccion.revelandoRespuesta:
        _completarRevealActual();
        setState(() => _fase = _FaseReproduccion.esperandoTapRespuesta);
      case _FaseReproduccion.esperandoTap:
      case _FaseReproduccion.esperandoTapRespuesta:
        HapticFeedback.selectionClick();
        _avanzar();
    }
  }

  void _completarRevealActual() {
    _temporizador?.cancel();
    final plano = _planoActual;
    int longitud = 0;
    if (plano is PlanoDialogo) {
      longitud = _conTokens(plano.texto).length;
    } else if (plano is PlanoEleccion) {
      if (_fase == _FaseReproduccion.revelando) {
        longitud = _conTokens(plano.textoPrompt ?? '').length;
      } else if (_fase == _FaseReproduccion.revelandoRespuesta) {
        final indice = _indiceOpcionElegida;
        if (indice != null) {
          longitud =
              _conTokens(plano.opciones[indice].textoRespuesta ?? '').length;
        }
      }
    }
    HapticFeedback.selectionClick();
    setState(() => _caracteresRevelados = longitud);
  }

  Future<void> _avanzar() async {
    if (!mounted) return;
    _temporizador?.cancel();
    setState(() => _fase = _FaseReproduccion.saliendo);
    await _controladorFade.reverse();
    if (!mounted) return;

    if (_indicePlano + 1 >= widget.escena.planos.length) {
      widget.alTerminar();
      return;
    }
    setState(() => _indicePlano++);
    _iniciarPlanoActual();
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _alPulsar,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge(
                [_controladorCielo, _controladorLluvia],
              ),
              builder: (_, __) => CustomPaint(
                painter: PintorEscenario(
                  fasePulso: _controladorCielo.value,
                  fasePulsoLluvia: _controladorLluvia.value,
                  nivelRestauracion: 0.15,
                  // El default genérico del core es AmbienteEscenaNeutro;
                  // el PintorEscenario de uno-roto solo sabe pintar
                  // AmbienteCielo, así que cualquier otro tipo cae al
                  // neutro propio del juego.
                  ambiente: widget.escena.ambiente is AmbienteCielo
                      ? widget.escena.ambiente as AmbienteCielo
                      : AmbienteCielo.neutro,
                ),
              ),
            ),
            Container(color: PaletaNeon.fondoProfundo.withOpacity(0.35)),
            SafeArea(
              child: FadeTransition(
                opacity: _controladorFade,
                child: SlideTransition(
                  position: _desplazamientoEntrada,
                  child: _construirContenidoDePlano(),
                ),
              ),
            ),
            _construirPresenciaPersonaje(),
            _IndicadorSaltar(alPulsar: widget.alTerminar),
          ],
        ),
      ),
    );
  }

  Widget _construirContenidoDePlano() {
    final plano = _planoActual;
    // PlanoEscena dejó de ser sealed cuando se subió al core (cada
    // juego añade sus subclases sin tocar la plataforma), así que
    // este switch ya no es exhaustivo a ojos del analyzer y necesita
    // un default — devolvemos un widget vacío para planos
    // desconocidos en lugar de explotar.
    if (plano is PlanoAmbiente) {
      final lectura = plano.textoLectura;
      return _VistaAmbiente(
        textoLectura: lectura == null ? null : _conTokens(lectura),
      );
    }
    if (plano is PlanoDialogo) {
      final completo = _conTokens(plano.texto);
      return _VistaDialogo(
        voz: plano.voz,
        textoRevelado: completo.substring(
          0,
          _caracteresRevelados.clamp(0, completo.length),
        ),
        mostrandoIndicador: _fase == _FaseReproduccion.esperandoTap,
      );
    }
    if (plano is PlanoEleccion) {
      return _VistaEleccion(
        plano: plano,
        nombreJugador: widget.nombreJugador,
        fase: _fase,
        caracteresRevelados: _caracteresRevelados,
        indiceElegida: _indiceOpcionElegida,
        alElegir: _elegirOpcion,
      );
    }
    if (plano is PlanoInteractivo) {
      return _VistaInteractiva(
        plano: plano,
        instruccion: _conTokens(plano.instruccion),
        alCompletar: _avanzar,
      );
    }
    if (plano is PlanoCierreAmable) {
      return _VistaCierreAmable(
        textoBoton: plano.textoBoton,
        visible: _fase == _FaseReproduccion.mostrandoCierreAmable,
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
    if (textoLectura == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 140),
        child: Text(
          textoLectura!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2,
            fontStyle: FontStyle.italic,
            color: PaletaNeon.textoTenue.withOpacity(0.55),
            fontWeight: FontWeight.w300,
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
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 420),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nombre.isNotEmpty)
            Text(
              nombre.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 4,
                color: voz.colorNombre,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 10),
          Text(textoRevelado, style: voz.estiloTextoCuerpo()),
          const SizedBox(height: 18),
          AnimatedOpacity(
            opacity: mostrandoIndicador ? 0.55 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Text(
              AppLocalizations.of(contexto).tocaParaContinuar,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2.2,
                color: PaletaNeon.textoTenue.withOpacity(0.7),
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
  final PlanoEleccion plano;
  final String nombreJugador;
  final _FaseReproduccion fase;
  final int caracteresRevelados;
  final int? indiceElegida;
  final ValueChanged<int> alElegir;

  const _VistaEleccion({
    required this.plano,
    required this.nombreJugador,
    required this.fase,
    required this.caracteresRevelados,
    required this.indiceElegida,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext contexto) {
    final nombre = plano.voz.nombreVisible;
    // El locale viaja por context — necesario para que prompt y opciones
    // se traduzcan a eu/ca igual que el resto de líneas. Antes pasaba
    // sólo por aplicarTokens y los textos de PlanoEleccion quedaban
    // siempre en castellano aunque el niño tuviera el idioma cambiado.
    final locale = Localizations.maybeLocaleOf(contexto);
    final prompt = traducirYAplicarTokens(
      plano.textoPrompt ?? '',
      nombreJugador,
      locale,
    );
    final estaRevelandoPrompt = fase == _FaseReproduccion.revelando;
    final estaMostrandoOpciones = fase == _FaseReproduccion.mostrandoOpciones;
    final estaRevelandoRespuesta = fase == _FaseReproduccion.revelandoRespuesta;
    final esperandoTapRespuesta =
        fase == _FaseReproduccion.esperandoTapRespuesta;

    final textoPromptRevelado = estaRevelandoPrompt
        ? prompt.substring(0, caracteresRevelados.clamp(0, prompt.length))
        : prompt;

    final indiceResp = indiceElegida;
    final respuesta = indiceResp != null
        ? traducirYAplicarTokens(
            plano.opciones[indiceResp].textoRespuesta ?? '',
            nombreJugador,
            locale,
          )
        : '';
    final textoRespuestaRevelado = estaRevelandoRespuesta
        ? respuesta.substring(0, caracteresRevelados.clamp(0, respuesta.length))
        : respuesta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 420),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prompt.isNotEmpty) ...[
            if (nombre.isNotEmpty)
              Text(
                nombre.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 4,
                  color: plano.voz.colorNombre,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 10),
            Text(textoPromptRevelado, style: plano.voz.estiloTextoCuerpo()),
            const SizedBox(height: 22),
          ],
          if (estaMostrandoOpciones)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var indice = 0; indice < plano.opciones.length; indice++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _BotonOpcion(
                      texto: traducirYAplicarTokens(
                        plano.opciones[indice].textoJugador,
                        nombreJugador,
                        locale,
                      ),
                      alPulsar: () => alElegir(indice),
                    ),
                  ),
              ],
            ),
          if (estaRevelandoRespuesta || esperandoTapRespuesta) ...[
            const SizedBox(height: 8),
            if (nombre.isNotEmpty)
              Text(
                nombre.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 4,
                  color: plano.voz.colorNombre,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 10),
            Text(textoRespuestaRevelado, style: plano.voz.estiloTextoCuerpo()),
            const SizedBox(height: 18),
            AnimatedOpacity(
              opacity: esperandoTapRespuesta ? 0.55 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: Text(
                AppLocalizations.of(contexto).tocaParaContinuar,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.2,
                  color: PaletaNeon.textoTenue.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: PaletaNeon.azulNeon.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            color: PaletaNeon.textoPrincipal,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _VistaInteractiva extends StatelessWidget {
  final PlanoInteractivo plano;
  final String instruccion;
  final VoidCallback alCompletar;

  const _VistaInteractiva({
    required this.plano,
    required this.instruccion,
    required this.alCompletar,
  });

  @override
  Widget build(BuildContext contexto) {
    final nombre = plano.vozInstruccion.nombreVisible;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          if (nombre.isNotEmpty)
            Text(
              nombre.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 4,
                color: plano.vozInstruccion.colorNombre,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 10),
          Text(
            instruccion,
            textAlign: TextAlign.center,
            style: plano.vozInstruccion.estiloTextoCuerpo(),
          ),
          const SizedBox(height: 36),
          WidgetFragmentoTutorial(
            accionEsperada: plano.accion,
            estadoInicial: plano.estadoInicial,
            alCompletar: alCompletar,
          ),
          const Spacer(flex: 3),
          _PistaGesto(accion: plano.accion),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _PistaGesto extends StatelessWidget {
  final AccionEsperada accion;

  const _PistaGesto({required this.accion});

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    final pista = switch (accion) {
      AccionEsperada.dividirPleno => textos.cinematicaAccionDividir,
      AccionEsperada.desfragmentarMitades => textos.cinematicaAccionDesfragmentar,
    };
    return Text(
      pista,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 2.4,
        fontStyle: FontStyle.italic,
        color: PaletaNeon.textoTenue.withOpacity(0.6),
      ),
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
            foregroundColor: PaletaNeon.textoPrincipal,
            side: BorderSide(
              color: PaletaNeon.violetaNeon.withOpacity(0.55),
              width: 1.2,
            ),
            backgroundColor: PaletaNeon.fondoMedio.withOpacity(0.35),
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

/// Animación de "respiración" para los avatares grandes de la
/// cinemática: escala cíclica 1.0 ↔ 1.025 y sway horizontal de 4 px
/// con periodo ligeramente distinto, para que no parezca un sticker
/// estático. La animación se reproduce en bucle indefinidamente y no
/// necesita gestión externa — el AnimationController se libera al
/// disponer del state.
class _AvatarRespirando extends StatefulWidget {
  final Widget child;

  const _AvatarRespirando({required this.child});

  @override
  State<_AvatarRespirando> createState() => _AvatarRespirandoState();
}

class _AvatarRespirandoState extends State<_AvatarRespirando>
    with TickerProviderStateMixin {
  late final AnimationController _controladorEscala;
  late final AnimationController _controladorSway;

  @override
  void initState() {
    super.initState();
    _controladorEscala = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _controladorSway = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controladorEscala.dispose();
    _controladorSway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controladorEscala, _controladorSway]),
      builder: (_, hijo) {
        final escala = 1.0 +
            Curves.easeInOut.transform(_controladorEscala.value) * 0.025;
        final desplazamientoX =
            (Curves.easeInOut.transform(_controladorSway.value) - 0.5) * 8;
        return Transform.translate(
          offset: Offset(desplazamientoX, 0),
          child: Transform.scale(
            scale: escala,
            alignment: Alignment.bottomCenter,
            child: hijo,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _IndicadorSaltar extends StatelessWidget {
  final VoidCallback alPulsar;

  const _IndicadorSaltar({required this.alPulsar});

  @override
  Widget build(BuildContext contexto) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, right: 12),
          child: TextButton(
            onPressed: alPulsar,
            style: TextButton.styleFrom(
              foregroundColor: PaletaNeon.textoTenue.withOpacity(0.55),
            ),
            child: Text(
              AppLocalizations.of(contexto).botonSaltar,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
