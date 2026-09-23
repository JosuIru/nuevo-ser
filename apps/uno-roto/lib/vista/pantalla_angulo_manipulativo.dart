import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/repositorio_progreso.dart';
import '../dominio/contador_intentos_puzzle.dart';
import '../dominio/fragmento_en_tejado.dart' show TipoFragmentoEnTejado;
import '../dominio/problema_angulo.dart';
import '../dominio/respuesta_puzzle.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'escenario.dart';
import 'estado_pista_puzzle.dart';
import 'overlay_demo_puzzle.dart';
import 'widgets/ayuda_tras_fallos.dart';
import 'widgets/boton_ayuda_puzzle.dart';

/// Puzzle MED.04 en su variante manipulativa (doc 16, eje A — piloto
/// Fase D3): la tarea se invierte. En vez de RECONOCER qué es un
/// ángulo dado ("65° → agudo"), el niño lo PRODUCE: "forma un ángulo
/// obtuso" girando el brazo con el dedo, con el grado visible como en
/// un transportador. Producir exige la misma regla (agudo < 90 <
/// obtuso < 180) pero tocándola, no recordándola.
///
/// El grado se ajusta a pasos de 5° para que "recto" (90 exacto) y
/// "llano" (180 exacto) sean alcanzables con un dedo de niño. Mismo
/// contrato que el resto de puzzles: pop(true) captura, pop(false)
/// huida, contarFalloPuzzle en el error, pista escalonada y ayuda.
class PantallaAnguloManipulativo extends StatefulWidget {
  /// Categoría que se pide formar. Derivada del ángulo que traía el
  /// Fragmento — la misma que la pantalla clásica pediría reconocer.
  final TipoAngulo objetivo;

  const PantallaAnguloManipulativo({super.key, required this.objetivo});

  @override
  State<PantallaAnguloManipulativo> createState() =>
      _PantallaAnguloManipulativoState();
}

class _PantallaAnguloManipulativoState
    extends State<PantallaAnguloManipulativo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorCielo;
  late final EstadoPistaPuzzle _pista;

  /// Grados actuales del brazo móvil (0..180), en pasos de 5.
  int _grados = 20;

  bool _resolviendo = false;
  bool _acierto = false;
  bool _mostrandoDemo = false;
  static const _idDemo = 'angulo_manipulativo';

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
    _controladorCielo.dispose();
    super.dispose();
  }

  /// Nombre localizado de la categoría objetivo.
  String _nombreObjetivo(Locale locale) =>
      traducirNarrativa(widget.objetivo.etiqueta, locale);

  void _alArrastrar(Offset posicionLocal, Size tamano) {
    if (_resolviendo) return;
    _cerrarDemo();
    final vertice = _verticeEn(tamano);
    final dx = posicionLocal.dx - vertice.dx;
    final dy = vertice.dy - posicionLocal.dy; // y de pantalla invertida
    if (dx == 0 && dy == 0) return;
    var angulo = math.atan2(dy, dx) * 180 / math.pi;
    angulo = angulo.clamp(0.0, 180.0);
    // Pasos de 5° — sin esto, formar 90 o 180 exactos sería una
    // tortura de precisión, no una prueba de saber la regla.
    final ajustado = ((angulo / 5).round() * 5).clamp(5, 180);
    if (ajustado != _grados) {
      setState(() => _grados = ajustado);
    }
  }

  void _confirmar() {
    if (_resolviendo) return;
    final categoria = clasificarAngulo(_grados);
    final correcto = categoria == widget.objetivo;
    setState(() {
      _resolviendo = true;
      _acierto = correcto;
    });
    if (correcto) {
      HapticFeedback.heavyImpact();
      _pista.registrarAcierto();
      UltimaRespuestaPuzzle.registrar(RespuestaPuzzle(
        acertado: true,
        respuestaDelNino: '$_grados°',
        respuestaCorrecta: widget.objetivo.etiqueta,
        preguntaTexto: 'forma un ángulo ${widget.objetivo.etiqueta}',
        opciones: const [],
      ));
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      });
    } else {
      HapticFeedback.vibrate();
      contarFalloPuzzle();
      _pista.registrarFallo();
      comprobarYAyudarSiProcede(
          context, _pista, TipoFragmentoEnTejado.angulo);
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() => _resolviendo = false);
        _pista.mostrarSiToca();
      });
    }
  }

  void _huir() {
    Navigator.of(context).pop(false);
  }

  /// Vértice del ángulo dentro del lienzo del brazo.
  static Offset _verticeEn(Size tamano) =>
      Offset(tamano.width * 0.5, tamano.height * 0.68);

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final instruccion = traducirNarrativa(
      'Gira el brazo hasta formar un ángulo {tipo}.',
      locale,
    ).replaceAll('{tipo}', _nombreObjetivo(locale));
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
                            'MED',
                            style: TextStyle(
                              color: PaletaNeon.textoTenue.withOpacity(0.9),
                              fontSize: 12,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 58),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        instruccion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PaletaNeon.textoPrincipal,
                          fontSize: 19,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Pista escalonada: recuerda la regla numérica.
                      if (_pista.activa)
                        Text(
                          _reglaDe(widget.objetivo, locale),
                          style: TextStyle(
                            color: PaletaNeon.exitoSuave.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, restricciones) {
                            final tamano = restricciones.biggest;
                            return GestureDetector(
                              onPanUpdate: (d) =>
                                  _alArrastrar(d.localPosition, tamano),
                              onPanEnd: (_) {},
                              child: CustomPaint(
                                size: tamano,
                                painter: _PintorBrazoAngulo(
                                  grados: _grados,
                                  vertice: _verticeEn(tamano),
                                  resolviendo: _resolviendo,
                                  acierto: _acierto,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: GestureDetector(
                          onTap: _confirmar,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: PaletaNeon.violetaNeon,
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              traducirNarrativa('ASÍ', locale),
                              style: const TextStyle(
                                color: PaletaNeon.textoPrincipal,
                                fontSize: 15,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotonAyudaPuzzle(
                destacar: _pista.activa,
                tipo: TipoFragmentoEnTejado.angulo,
              ),
              if (_mostrandoDemo)
                OverlayDemoPuzzle(
                  mensaje: traducirNarrativa(
                    'Arrastra el brazo del ángulo y pulsa ASÍ cuando lo tengas.',
                    locale,
                  ),
                  alCerrar: _cerrarDemo,
                  posicionRelativa: const Alignment(0, 0.3),
                ),
            ],
          );
        },
      ),
    );
  }

  String _reglaDe(TipoAngulo objetivo, Locale locale) {
    final String regla;
    switch (objetivo) {
      case TipoAngulo.agudo:
        regla = 'Agudo: menos de 90°.';
      case TipoAngulo.recto:
        regla = 'Recto: 90° exactos.';
      case TipoAngulo.obtuso:
        regla = 'Obtuso: entre 90° y 180°.';
      case TipoAngulo.llano:
        regla = 'Llano: 180° exactos.';
      case TipoAngulo.completo:
        regla = 'Completo: 360°.';
    }
    return traducirNarrativa(regla, locale);
  }
}

/// Pinta el "transportador": brazo fijo horizontal, brazo móvil según
/// [grados], arco con el valor visible y vértice. Durante la
/// resolución tiñe el conjunto (éxito suave o rosa).
class _PintorBrazoAngulo extends CustomPainter {
  final int grados;
  final Offset vertice;
  final bool resolviendo;
  final bool acierto;

  _PintorBrazoAngulo({
    required this.grados,
    required this.vertice,
    required this.resolviendo,
    required this.acierto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final largoBrazo = math.min(size.width * 0.38, 160.0);
    final colorAcento = resolviendo
        ? (acierto ? PaletaNeon.exitoSuave : PaletaNeon.rosaAcento)
        : PaletaNeon.azulNeon;

    // Brazo fijo (horizontal, hacia la derecha).
    final pinturaFijo = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      vertice,
      vertice.translate(largoBrazo, 0),
      pinturaFijo,
    );

    // Brazo móvil.
    final radianes = grados * math.pi / 180;
    final extremoMovil = Offset(
      vertice.dx + largoBrazo * math.cos(radianes),
      vertice.dy - largoBrazo * math.sin(radianes),
    );
    final pinturaMovil = Paint()
      ..color = colorAcento
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(vertice, extremoMovil, pinturaMovil);

    // Tirador en el extremo móvil — invita a arrastrar.
    final pinturaTirador = Paint()
      ..color = colorAcento.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(extremoMovil, 18, pinturaTirador);
    canvas.drawCircle(
      extremoMovil,
      7,
      Paint()..color = colorAcento,
    );

    // Arco del ángulo.
    final pinturaArco = Paint()
      ..color = colorAcento.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawArc(
      Rect.fromCircle(center: vertice, radius: largoBrazo * 0.35),
      0,
      -radianes,
      false,
      pinturaArco,
    );

    // Vértice.
    canvas.drawCircle(
      vertice,
      4,
      Paint()..color = PaletaNeon.violetaNeon,
    );

    // Valor en grados, junto al arco.
    final anguloEtiqueta = radianes / 2;
    final posEtiqueta = Offset(
      vertice.dx + largoBrazo * 0.55 * math.cos(anguloEtiqueta),
      vertice.dy - largoBrazo * 0.55 * math.sin(anguloEtiqueta) - 10,
    );
    final pintorTexto = TextPainter(
      text: TextSpan(
        text: '$grados°',
        style: TextStyle(
          color: colorAcento,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorTexto.paint(
      canvas,
      Offset(
        posEtiqueta.dx - pintorTexto.width / 2,
        posEtiqueta.dy - pintorTexto.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorBrazoAngulo oldDelegate) {
    return oldDelegate.grados != grados ||
        oldDelegate.resolviendo != resolviendo ||
        oldDelegate.acierto != acierto ||
        oldDelegate.vertice != vertice;
  }
}
