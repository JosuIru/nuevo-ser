import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/repositorio_progreso.dart';
import '../dominio/contador_intentos_puzzle.dart';
import '../dominio/fragmento_en_tejado.dart'
    show ModoComparacion, TipoFragmentoEnTejado;
import '../dominio/problema_comparacion.dart';
import '../dominio/problema_espejo.dart' show Fraccion;
import '../dominio/respuesta_puzzle.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'escenario.dart';
import 'estado_pista_puzzle.dart';
import 'overlay_demo_puzzle.dart';
import 'widgets/ayuda_tras_fallos.dart';
import 'widgets/boton_ayuda_puzzle.dart';

/// Puzzle FR.05 / FR.06 en su variante manipulativa (doc 16, eje A —
/// piloto de la Fase D3): las dos fracciones cuelgan de una balanza y
/// el niño ARRASTRA hacia abajo el platillo que cree más pesado, en
/// lugar de tocar una tarjeta.
///
/// El feedback es la física honesta de la balanza: si acierta, el
/// platillo se asienta donde él lo dejó; si falla, la balanza se
/// endereza sola hacia el lado verdadero — ve la verdad, no una cruz
/// roja. Mismo generador, misma evaluación y mismo contrato que
/// [PantallaComparacion] (pop(true) captura / pop(false) huida,
/// contarFalloPuzzle, pista escalonada, ayuda tras fallos).
class PantallaComparacionBalanza extends StatefulWidget {
  final Fraccion a;
  final Fraccion b;
  final ModoComparacion modo;

  const PantallaComparacionBalanza({
    super.key,
    required this.a,
    required this.b,
    required this.modo,
  });

  @override
  State<PantallaComparacionBalanza> createState() =>
      _PantallaComparacionBalanzaState();
}

class _PantallaComparacionBalanzaState
    extends State<PantallaComparacionBalanza>
    with TickerProviderStateMixin {
  late final AnimationController _controladorCielo;
  late final AnimationController _controladorBalanza;
  late final EstadoPistaPuzzle _pista;
  late final ProblemaComparacion _problema;

  /// Inclinación actual de la balanza, -1 (izquierda abajo del todo)
  /// a +1 (derecha abajo del todo). Durante el arrastre la mueve el
  /// dedo; en las animaciones, el controlador.
  double _inclinacion = 0;

  /// Desde dónde y hacia dónde anima el controlador de la balanza.
  double _inclinacionDesde = 0;
  double _inclinacionHasta = 0;

  /// `true` mientras se muestra el resultado (bloquea el gesto).
  bool _resolviendo = false;
  bool _acierto = false;
  bool _mostrandoDemo = false;
  static const _idDemo = 'comparacion_balanza';

  /// Umbral de inclinación para que soltar cuente como respuesta.
  static const double _umbralRespuesta = 0.35;

  @override
  void initState() {
    super.initState();
    _controladorCielo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _controladorBalanza = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addListener(() {
        setState(() {
          final t = Curves.easeOutBack.transform(_controladorBalanza.value);
          _inclinacion = _inclinacionDesde +
              (_inclinacionHasta - _inclinacionDesde) * t;
        });
      });
    _pista = EstadoPistaPuzzle(alCambiar: () => setState(() {}));
    _problema = ProblemaComparacion(
      a: widget.a,
      b: widget.b,
      modo: widget.modo,
    );
    _decidirSiMostrarDemo();
  }

  Future<void> _decidirSiMostrarDemo() async {
    final repositorio = RepositorioProgreso();
    final vistos = await repositorio.cargarDemosPuzzlesVistos();
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
    _controladorBalanza.dispose();
    _controladorCielo.dispose();
    super.dispose();
  }

  void _animarBalanzaHacia(double destino) {
    _inclinacionDesde = _inclinacion;
    _inclinacionHasta = destino;
    _controladorBalanza.forward(from: 0);
  }

  void _alArrastrar(DragUpdateDetails detalles, double anchoLienzo) {
    if (_resolviendo) return;
    _cerrarDemo();
    // El lado lo decide dónde está el dedo; la magnitud, cuánto baja.
    final enLadoIzquierdo =
        detalles.localPosition.dx < anchoLienzo / 2;
    final delta = detalles.delta.dy / 140; // sensibilidad del gesto
    setState(() {
      _inclinacion = (_inclinacion + (enLadoIzquierdo ? -delta : delta))
          .clamp(-1.0, 1.0);
    });
  }

  void _alSoltar() {
    if (_resolviendo) return;
    if (_inclinacion.abs() < _umbralRespuesta) {
      // Gesto tímido: la balanza vuelve al fiel sin evaluar.
      _animarBalanzaHacia(0);
      return;
    }
    // Inclinación negativa = lado izquierdo (a) abajo = "a pesa más".
    final indiceElegido = _inclinacion < 0 ? 0 : 1;
    final correcto = _problema.esCorrecto(indiceElegido);
    final indiceMayor = _problema.indiceMayor ?? 0;
    setState(() {
      _resolviendo = true;
      _acierto = correcto;
    });
    // La física honesta: la balanza se asienta SIEMPRE del lado
    // verdadero — si acertó, confirma su gesto; si falló, lo corrige.
    _animarBalanzaHacia(indiceMayor == 0 ? -1.0 : 1.0);
    if (correcto) {
      HapticFeedback.heavyImpact();
      _pista.registrarAcierto();
      final opciones = [_problema.a.etiqueta, _problema.b.etiqueta];
      UltimaRespuestaPuzzle.registrar(RespuestaPuzzle(
        acertado: true,
        respuestaDelNino: opciones[indiceElegido],
        respuestaCorrecta: opciones[indiceMayor],
        preguntaTexto: widget.modo == ModoComparacion.mismoNumerador
            ? '¿qué fracción pesa más? (mismo numerador)'
            : '¿qué fracción pesa más? (mismo denominador)',
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
          context, _pista, TipoFragmentoEnTejado.comparacion);
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() => _resolviendo = false);
        _animarBalanzaHacia(0);
        _pista.mostrarSiToca();
      });
    }
  }

  void _huir() {
    Navigator.of(context).pop(false);
  }

  String _pistaSegunModo(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    switch (widget.modo) {
      case ModoComparacion.mismoDenominador:
        return textos.comparacionMismoTamano;
      case ModoComparacion.mismoNumerador:
        return textos.comparacionMismoNumero;
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
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
                      Text(
                        traducirNarrativa(
                          'Arrastra hacia abajo el platillo que pese más.',
                          locale,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PaletaNeon.textoPrincipal,
                          fontSize: 19,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _pistaSegunModo(contexto),
                        style: TextStyle(
                          color: PaletaNeon.textoTenue.withOpacity(0.8),
                          fontSize: 12,
                          letterSpacing: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, restricciones) {
                            return GestureDetector(
                              onVerticalDragUpdate: (d) => _alArrastrar(
                                  d, restricciones.biggest.width),
                              onVerticalDragEnd: (_) => _alSoltar(),
                              child: CustomPaint(
                                size: restricciones.biggest,
                                painter: _PintorBalanza(
                                  etiquetaA: _problema.a.etiqueta,
                                  etiquetaB: _problema.b.etiqueta,
                                  inclinacion: _inclinacion,
                                  resolviendo: _resolviendo,
                                  acierto: _acierto,
                                  ladoPista: _pista.activa
                                      ? _problema.indiceMayor
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotonAyudaPuzzle(
                destacar: _pista.activa,
                tipo: TipoFragmentoEnTejado.comparacion,
              ),
              if (_mostrandoDemo)
                OverlayDemoPuzzle(
                  mensaje: traducirNarrativa(
                    'Arrastra hacia abajo el platillo que pese más.',
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
}

/// Pinta la balanza: fulcro, brazo inclinado según [inclinacion]
/// (-1 izquierda abajo … +1 derecha abajo), cuerdas y dos platillos
/// con sus fracciones. Durante la resolución tiñe el platillo ganador
/// (éxito suave si acertó, rosa si la balanza tuvo que corregir).
class _PintorBalanza extends CustomPainter {
  final String etiquetaA;
  final String etiquetaB;
  final double inclinacion;
  final bool resolviendo;
  final bool acierto;

  /// Lado a resaltar como pista escalonada (0 = a, 1 = b), o null.
  final int? ladoPista;

  _PintorBalanza({
    required this.etiquetaA,
    required this.etiquetaB,
    required this.inclinacion,
    required this.resolviendo,
    required this.acierto,
    required this.ladoPista,
  });

  static const double _anguloMaximo = 0.30; // radianes

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.32);
    final medioBrazo = math.min(size.width * 0.36, 150.0);
    final angulo = inclinacion * _anguloMaximo;

    final pinturaEstructura = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Pie y fulcro.
    canvas.drawLine(
      centro,
      Offset(centro.dx, size.height * 0.86),
      pinturaEstructura,
    );
    canvas.drawCircle(
      centro,
      5,
      Paint()..color = PaletaNeon.violetaNeon,
    );

    // Brazo.
    final extremoIzq = Offset(
      centro.dx - medioBrazo * math.cos(angulo),
      centro.dy - medioBrazo * math.sin(angulo),
    );
    final extremoDer = Offset(
      centro.dx + medioBrazo * math.cos(angulo),
      centro.dy + medioBrazo * math.sin(angulo),
    );
    canvas.drawLine(extremoIzq, extremoDer, pinturaEstructura);

    _pintarPlatillo(
      canvas: canvas,
      colgadoDe: extremoIzq,
      etiqueta: etiquetaA,
      indice: 0,
    );
    _pintarPlatillo(
      canvas: canvas,
      colgadoDe: extremoDer,
      etiqueta: etiquetaB,
      indice: 1,
    );
  }

  void _pintarPlatillo({
    required Canvas canvas,
    required Offset colgadoDe,
    required String etiqueta,
    required int indice,
  }) {
    const largoCuerda = 54.0;
    const radioPlatillo = 52.0;
    final centroPlatillo = colgadoDe.translate(0, largoCuerda + 18);

    // El lado que baja es el más pesado: -1 → izquierda (índice 0).
    final esElQueBaja =
        (indice == 0 && inclinacion < 0) || (indice == 1 && inclinacion > 0);
    final Color colorAcento;
    if (resolviendo && esElQueBaja) {
      colorAcento = acierto ? PaletaNeon.exitoSuave : PaletaNeon.rosaAcento;
    } else if (ladoPista == indice) {
      colorAcento = PaletaNeon.exitoSuave.withOpacity(0.6);
    } else {
      colorAcento = PaletaNeon.violetaBase;
    }

    final pinturaCuerda = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.5)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      colgadoDe,
      colgadoDe.translate(0, largoCuerda),
      pinturaCuerda,
    );

    final pinturaFondo = Paint()
      ..color = PaletaNeon.fondoMedio.withOpacity(0.75);
    final pinturaBorde = Paint()
      ..color = colorAcento
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(centroPlatillo, radioPlatillo, pinturaFondo);
    if (resolviendo && esElQueBaja || ladoPista == indice) {
      final pinturaHalo = Paint()
        ..color = colorAcento.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(centroPlatillo, radioPlatillo + 4, pinturaHalo);
    }
    canvas.drawCircle(centroPlatillo, radioPlatillo, pinturaBorde);

    final pintorTexto = TextPainter(
      text: TextSpan(
        text: etiqueta,
        style: TextStyle(
          color: resolviendo && esElQueBaja
              ? colorAcento
              : PaletaNeon.textoPrincipal,
          fontSize: 30,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorTexto.paint(
      canvas,
      Offset(
        centroPlatillo.dx - pintorTexto.width / 2,
        centroPlatillo.dy - pintorTexto.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorBalanza oldDelegate) {
    return oldDelegate.inclinacion != inclinacion ||
        oldDelegate.resolviendo != resolviendo ||
        oldDelegate.acierto != acierto ||
        oldDelegate.ladoPista != ladoPista ||
        oldDelegate.etiquetaA != etiquetaA ||
        oldDelegate.etiquetaB != etiquetaB;
  }
}
