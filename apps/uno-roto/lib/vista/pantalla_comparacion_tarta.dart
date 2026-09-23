import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/repositorio_progreso.dart';
import '../dominio/contador_intentos_puzzle.dart';
import '../dominio/fragmento_en_tejado.dart' show TipoFragmentoEnTejado;
import '../dominio/porciones_tarta.dart';
import '../dominio/problema_comparacion_distinta.dart';
import '../dominio/respuesta_puzzle.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'escenario.dart';
import 'estado_pista_puzzle.dart';
import 'overlay_demo_puzzle.dart';
import 'widgets/ayuda_tras_fallos.dart';
import 'widgets/boton_ayuda_puzzle.dart';

/// Puzzle FR.07 en su variante manipulativa "cortar la tarta" (doc 16,
/// eje A): dos tartas ya partidas según el denominador de cada
/// fracción. El niño SIRVE cada fracción pasando el dedo alrededor de
/// su tarta (el relleno encaja trozo a trozo) y, con las dos servidas,
/// toca la que tiene más.
///
/// La comparación deja de ser un cálculo a ciegas: lo que el niño ha
/// servido con su dedo es lo que compara. Si falla, la tarta correcta
/// se ilumina y lo servido se queda — puede mirar la diferencia y
/// volver a elegir. Mismo contrato que [PantallaComparacionDistinta]
/// (pop(true) captura / pop(false) huida, contarFalloPuzzle, pista
/// escalonada, ayuda tras fallos).
class PantallaComparacionTarta extends StatefulWidget {
  final ProblemaComparacionDistinta problema;

  const PantallaComparacionTarta({super.key, required this.problema});

  @override
  State<PantallaComparacionTarta> createState() =>
      _PantallaComparacionTartaState();
}

class _PantallaComparacionTartaState extends State<PantallaComparacionTarta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorCielo;
  late final EstadoPistaPuzzle _pista;
  final _recorridos = [RecorridoTarta(), RecorridoTarta()];

  /// Tarta elegida en el último intento (0/1), para teñirla mientras se
  /// muestra el resultado.
  int? _eleccion;
  bool _resolviendo = false;
  bool _mostrandoDemo = false;
  static const _idDemo = 'comparacion_tarta';

  ProblemaComparacionDistinta get _problema => widget.problema;

  @override
  void initState() {
    super.initState();
    _controladorCielo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _pista = EstadoPistaPuzzle(alCambiar: () => setState(() {}));
    _decidirSiMostrarDemo();
  }

  Future<void> _decidirSiMostrarDemo() async {
    final vistos = await RepositorioProgreso().cargarDemosPuzzlesVistos();
    if (!mounted || vistos.contains(_idDemo)) return;
    setState(() => _mostrandoDemo = true);
  }

  Future<void> _cerrarDemo() async {
    if (!_mostrandoDemo) return;
    setState(() => _mostrandoDemo = false);
    await RepositorioProgreso().marcarDemoPuzzleVisto(_idDemo);
  }

  @override
  void dispose() {
    _pista.dispose();
    _controladorCielo.dispose();
    super.dispose();
  }

  int _servidas(int indice) {
    final fraccion = indice == 0 ? _problema.a : _problema.b;
    return porcionesServidas(
        _recorridos[indice].anguloAcumulado, fraccion.denominador);
  }

  bool _bienServida(int indice) {
    final fraccion = indice == 0 ? _problema.a : _problema.b;
    return _servidas(indice) == fraccion.numerador;
  }

  bool get _ambasServidas => _bienServida(0) && _bienServida(1);

  Offset _relativoAlCentro(Offset posicion, Size lienzo) =>
      posicion - Offset(lienzo.width / 2, lienzo.height / 2);

  void _alEmpezarArrastre(int indice, Offset posicion, Size lienzo) {
    if (_resolviendo) return;
    _cerrarDemo();
    final relativo = _relativoAlCentro(posicion, lienzo);
    _recorridos[indice].empezar(anguloDesdeLasDoce(relativo.dx, relativo.dy));
  }

  void _alArrastrar(int indice, Offset posicion, Size lienzo) {
    if (_resolviendo) return;
    final relativo = _relativoAlCentro(posicion, lienzo);
    final antes = _servidas(indice);
    setState(() => _recorridos[indice]
        .mover(anguloDesdeLasDoce(relativo.dx, relativo.dy)));
    if (_servidas(indice) != antes) HapticFeedback.selectionClick();
  }

  void _alSoltar(int indice) {
    _recorridos[indice].terminar();
    if (_bienServida(indice)) HapticFeedback.lightImpact();
    setState(() {});
  }

  void _alTocarTarta(int indice) {
    if (_resolviendo || !_ambasServidas) return;
    _cerrarDemo();
    final correcto = _problema.esCorrecta(indice);
    setState(() {
      _resolviendo = true;
      _eleccion = indice;
    });
    final opciones = [_problema.a.etiqueta, _problema.b.etiqueta];
    if (correcto) {
      HapticFeedback.heavyImpact();
      _pista.registrarAcierto();
      UltimaRespuestaPuzzle.registrar(RespuestaPuzzle(
        acertado: true,
        respuestaDelNino: opciones[indice],
        respuestaCorrecta: opciones[_problema.indiceMayor],
        preguntaTexto: '¿qué tarta tiene más? (fracciones distintas)',
        opciones: opciones,
      ));
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      });
    } else {
      HapticFeedback.vibrate();
      contarFalloPuzzle();
      _pista.registrarFallo();
      comprobarYAyudarSiProcede(
          context, _pista, TipoFragmentoEnTejado.comparacionDistinta);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _resolviendo = false;
          _eleccion = null;
        });
        _pista.mostrarSiToca();
      });
    }
  }

  void _huir() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final instruccion = _ambasServidas
        ? 'Ahora toca la tarta que tiene más.'
        : 'Sirve cada fracción: pasa el dedo alrededor de su tarta.';
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controladorCielo,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: PintorEscenario(
                  fasePulso: _controladorCielo.value,
                  nivelRestauracion: 0.3,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _huir,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: PaletaNeon.violetaBase,
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppLocalizations.of(contexto).puzzleBotonHuir,
                                style: const TextStyle(
                                  color: PaletaNeon.textoPrincipal,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(contexto)
                                .puzzleHeaderComparar,
                            style: const TextStyle(
                              color: PaletaNeon.textoTenue,
                              fontSize: 12,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 58),
                        ],
                      ),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          traducirNarrativa(instruccion, locale),
                          key: ValueKey(instruccion),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: PaletaNeon.textoPrincipal,
                            fontSize: 19,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          children: [
                            for (final indice in const [0, 1])
                              Expanded(child: _tarta(indice)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotonAyudaPuzzle(
                destacar: _pista.activa,
                tipo: TipoFragmentoEnTejado.comparacionDistinta,
              ),
              if (_mostrandoDemo)
                OverlayDemoPuzzle(
                  mensaje: traducirNarrativa(
                    'Sirve cada fracción: pasa el dedo alrededor de su tarta.',
                    locale,
                  ),
                  alCerrar: _cerrarDemo,
                  posicionRelativa: const Alignment(0, 0.35),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _tarta(int indice) {
    final fraccion = indice == 0 ? _problema.a : _problema.b;
    final servidas = _servidas(indice);
    final bienServida = _bienServida(indice);
    final EstadoTarta estado;
    if (_resolviendo && _eleccion != null) {
      if (indice == _problema.indiceMayor) {
        estado = EstadoTarta.mayor;
      } else {
        estado = indice == _eleccion ? EstadoTarta.elegidaMenor : EstadoTarta.normal;
      }
    } else if (_pista.activa && _ambasServidas && indice == _problema.indiceMayor) {
      estado = EstadoTarta.pista;
    } else {
      estado = EstadoTarta.normal;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          fraccion.etiqueta,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 30,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (_, restricciones) {
              final lienzo = restricciones.biggest;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) =>
                    _alEmpezarArrastre(indice, d.localPosition, lienzo),
                onPanUpdate: (d) =>
                    _alArrastrar(indice, d.localPosition, lienzo),
                onPanEnd: (_) => _alSoltar(indice),
                onTap: () => _alTocarTarta(indice),
                child: CustomPaint(
                  size: lienzo,
                  painter: PintorTarta(
                    denominador: fraccion.denominador,
                    servidas: servidas,
                    bienServida: bienServida,
                    // Pista mientras se sirve: silueta de lo que toca.
                    guia: _pista.activa && !bienServida
                        ? fraccion.numerador
                        : null,
                    estado: estado,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          opacity: servidas > 0 ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            '$servidas/${fraccion.denominador}',
            style: TextStyle(
              color: bienServida
                  ? PaletaNeon.exitoSuave
                  : PaletaNeon.textoTenue,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

enum EstadoTarta { normal, pista, mayor, elegidaMenor }

/// Tarta partida en [denominador] trozos con [servidas] rellenos desde
/// las 12 en sentido horario. Ámbar para lo servido; borde verde suave
/// cuando lo servido coincide con la fracción pedida.
class PintorTarta extends CustomPainter {
  final int denominador;
  final int servidas;
  final bool bienServida;
  final int? guia;
  final EstadoTarta estado;

  PintorTarta({
    required this.denominador,
    required this.servidas,
    required this.bienServida,
    required this.guia,
    required this.estado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.shortestSide / 2 - 10;
    final circulo = Rect.fromCircle(center: centro, radius: radio);
    const arriba = -math.pi / 2;
    final porTrozo = 2 * math.pi / denominador;

    // Base.
    canvas.drawCircle(
        centro, radio, Paint()..color = PaletaNeon.fondoMedio.withOpacity(0.85));

    // Silueta guía (pista): lo que habría que servir.
    if (guia != null && guia! > 0) {
      canvas.drawArc(
        circulo,
        arriba,
        porTrozo * guia!,
        true,
        Paint()..color = PaletaNeon.ambarCanales.withOpacity(0.18),
      );
    }

    // Lo servido.
    if (servidas > 0) {
      canvas.drawArc(
        circulo,
        arriba,
        porTrozo * servidas,
        true,
        Paint()
          ..color = PaletaNeon.ambarCanales
              .withOpacity(estado == EstadoTarta.elegidaMenor ? 0.45 : 0.85),
      );
    }

    // Cortes.
    final pinturaCorte = Paint()
      ..color = PaletaNeon.fondoProfundo.withOpacity(0.9)
      ..strokeWidth = 2;
    for (var trozo = 0; trozo < denominador; trozo++) {
      final angulo = arriba + porTrozo * trozo;
      canvas.drawLine(
        centro,
        centro + Offset(math.cos(angulo), math.sin(angulo)) * radio,
        pinturaCorte,
      );
    }

    // Borde según estado.
    final Color colorBorde;
    double grosorBorde = 2;
    switch (estado) {
      case EstadoTarta.mayor:
        colorBorde = PaletaNeon.exitoSuave;
        grosorBorde = 4;
      case EstadoTarta.elegidaMenor:
        colorBorde = PaletaNeon.rosaAcento;
        grosorBorde = 3;
      case EstadoTarta.pista:
        colorBorde = PaletaNeon.violetaNeon;
        grosorBorde = 4;
      case EstadoTarta.normal:
        colorBorde =
            bienServida ? PaletaNeon.exitoSuave : PaletaNeon.violetaBase;
    }
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorBorde
        ..color = colorBorde,
    );
  }

  @override
  bool shouldRepaint(PintorTarta anterior) =>
      anterior.denominador != denominador ||
      anterior.servidas != servidas ||
      anterior.bienServida != bienServida ||
      anterior.guia != guia ||
      anterior.estado != estado;
}
