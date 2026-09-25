import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/repositorio_progreso.dart';
import '../dominio/contador_intentos_puzzle.dart';
import '../dominio/eso/problema_eso.dart';
import '../dominio/fragmento_en_tejado.dart' show TipoFragmentoEnTejado;
import '../dominio/respuesta_puzzle.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'escenario.dart';
import 'estado_pista_puzzle.dart';
import 'overlay_demo_puzzle.dart';
import 'widgets/ayuda_tras_fallos.dart';
import 'widgets/boton_ayuda_puzzle.dart';
import 'widgets/cabecera_puzzle.dart';
import 'widgets/tarjeta_numero.dart';

/// El puzzle de las habilidades de 1.º y 2.º de ESO: enunciado, un
/// dibujo si el problema lo trae (plano, gráfica, triángulos, cuerpos,
/// figuras, tablas, árboles) y cuatro opciones. Lo propio de cada
/// habilidad vive en su [FichaProblemaEso].
class PantallaProblemaEso extends StatefulWidget {
  final ProblemaEso problema;

  const PantallaProblemaEso({super.key, required this.problema});

  @override
  State<PantallaProblemaEso> createState() => _PantallaProblemaEsoState();
}

class _PantallaProblemaEsoState extends State<PantallaProblemaEso>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorCielo;
  late final EstadoPistaPuzzle _pista;
  int? _indiceSeleccionado;
  bool _revelado = false;
  bool _mostrandoDemo = false;
  static const _idDemo = 'eso';

  ProblemaEso get _problema => widget.problema;

  @override
  void initState() {
    super.initState();
    _controladorCielo =
        AnimationController(vsync: this, duration: const Duration(seconds: 16))
          ..repeat();
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

  void _elegir(int indice) {
    if (_revelado && _indiceSeleccionado == _problema.indiceCorrecto) return;
    setState(() {
      _indiceSeleccionado = indice;
      _revelado = true;
    });
    if (indice == _problema.indiceCorrecto) {
      HapticFeedback.heavyImpact();
      _pista.registrarAcierto();
      UltimaRespuestaPuzzle.registrar(RespuestaPuzzle(
        acertado: true,
        respuestaDelNino: _problema.opciones[indice],
        respuestaCorrecta: _problema.respuesta,
        preguntaTexto: _problema.enunciadoRelleno,
        opciones: _problema.opciones,
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
          context, _pista, TipoFragmentoEnTejado.problemaEso,
          idHabilidadEso: _problema.idHabilidad);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _revelado = false);
        _pista.mostrarSiToca();
      });
    }
  }

  void _huir() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    String traducir(String texto) => traducirNarrativa(texto, locale);
    var enunciado = traducir(_problema.enunciado);
    _problema.datos.forEach(
        (clave, valor) => enunciado = enunciado.replaceAll('{$clave}', valor));
    final visual = _problema.visual;
    final titulo = fichasProblemasEso[_problema.idHabilidad]?.tituloAyuda;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controladorCielo,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
                painter: PintorEscenario(
                    fasePulso: _controladorCielo.value,
                    nivelRestauracion: 0.3)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CabeceraPuzzle(
                        alHuir: _huir,
                        titulo: titulo == null ? '' : traducir(titulo)),
                    const SizedBox(height: 16),
                    Text(
                      enunciado,
                      key: const ValueKey('eso-enunciado'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PaletaNeon.textoPrincipal,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visual != null)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _DibujoEso(visual: visual, traducir: traducir),
                        ),
                      )
                    else
                      const Spacer(flex: 2),
                    const SizedBox(height: 12),
                    Expanded(
                      flex: 4,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.9,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < _problema.opciones.length; i++)
                            TarjetaNumero(
                              key: ValueKey('eso-opcion-$i'),
                              valor: traducir(_problema.opciones[i]),
                              seleccionado: _indiceSeleccionado == i,
                              marcarCorrecto: _revelado &&
                                  _indiceSeleccionado == i &&
                                  i == _problema.indiceCorrecto,
                              marcarIncorrecto: _revelado &&
                                  _indiceSeleccionado == i &&
                                  i != _problema.indiceCorrecto,
                              marcarPista: _pista.activa &&
                                  i == _problema.indiceCorrecto,
                              alTocar: () => _elegir(i),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BotonAyudaPuzzle(
              destacar: _pista.activa,
              tipo: TipoFragmentoEnTejado.problemaEso,
              idHabilidadEso: _problema.idHabilidad,
            ),
            if (_mostrandoDemo)
              OverlayDemoPuzzle(
                mensaje: AppLocalizations.of(contexto).demoPuzzleTocaResultado,
                alCerrar: _cerrarDemo,
                posicionRelativa: const Alignment(0, 0.45),
              ),
          ],
        ),
      ),
    );
  }
}

/// El dibujo del problema. Las tablas van como widget (texto que se
/// ajusta); el resto se pinta.
class _DibujoEso extends StatelessWidget {
  final VisualEso visual;
  final String Function(String) traducir;

  const _DibujoEso({required this.visual, required this.traducir});

  /// El mismo dibujo con sus rótulos traducidos (los números y las
  /// medidas no están en los mapas y quedan igual).
  VisualEso _traducido() {
    List<String> lista(List<String> textos) =>
        [for (final texto in textos) traducir(texto)];
    Map<String, String> medidas(Map<String, String> originales) => {
          for (final entrada in originales.entries)
            entrada.key: traducir(entrada.value)
        };
    return switch (visual) {
      VisualPlano(:final rango, :final puntos, :final rectas) => VisualPlano(
          rango: rango,
          rectas: rectas,
          puntos: [
            for (final punto in puntos)
              (x: punto.x, y: punto.y, etiqueta: traducir(punto.etiqueta))
          ],
        ),
      VisualGrafica(:final puntos, :final etiquetaX, :final etiquetaY) =>
        VisualGrafica(
            puntos: puntos,
            etiquetaX: traducir(etiquetaX),
            etiquetaY: traducir(etiquetaY)),
      VisualTriangulos(:final ladosPequeno, :final ladosGrande) =>
        VisualTriangulos(
            ladosPequeno: lista(ladosPequeno), ladosGrande: lista(ladosGrande)),
      VisualCuerpo(:final forma, medidas: final originales) =>
        VisualCuerpo(forma: forma, medidas: medidas(originales)),
      VisualFigura(:final forma, :final lados, medidas: final originales) =>
        VisualFigura(forma: forma, lados: lados, medidas: medidas(originales)),
      VisualTabla(:final cabecera, :final filas) => VisualTabla(
          cabecera: lista(cabecera),
          filas: [for (final fila in filas) lista(fila)]),
      VisualArbol(:final primeras, :final segundas) => VisualArbol(
          primeras: lista(primeras),
          segundas: [for (final ramas in segundas) lista(ramas)]),
    };
  }

  @override
  Widget build(BuildContext contexto) {
    final dibujo = _traducido();
    if (dibujo is VisualTabla) return Center(child: _TablaEso(tabla: dibujo));
    final CustomPainter pintor = switch (dibujo) {
      VisualPlano() => _PintorPlano(dibujo),
      VisualGrafica() => _PintorGrafica(dibujo),
      VisualTriangulos() => _PintorTriangulos(dibujo),
      VisualCuerpo() => _PintorCuerpo(dibujo),
      VisualFigura() => _PintorFigura(dibujo),
      VisualArbol() => _PintorArbol(dibujo),
      VisualTabla() => throw StateError('La tabla no se pinta'),
    };
    return CustomPaint(
        key: const ValueKey('eso-dibujo'),
        painter: pintor,
        size: Size.infinite);
  }
}

class _TablaEso extends StatelessWidget {
  final VisualTabla tabla;

  const _TablaEso({required this.tabla});

  @override
  Widget build(BuildContext contexto) {
    Widget celda(String texto, {bool cabecera = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cabecera
                  ? PaletaNeon.ambarCanales
                  : PaletaNeon.textoPrincipal,
              fontSize: 16,
              fontWeight: cabecera ? FontWeight.w500 : FontWeight.w300,
            ),
          ),
        );
    final borde = BorderSide(color: PaletaNeon.azulNeon.withOpacity(0.45));
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Table(
        key: const ValueKey('eso-tabla'),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(
            horizontalInside: borde,
            verticalInside: borde,
            top: borde,
            bottom: borde),
        children: [
          TableRow(children: [
            for (final texto in tabla.cabecera) celda(texto, cabecera: true)
          ]),
          for (final fila in tabla.filas)
            TableRow(children: [for (final texto in fila) celda(texto)]),
        ],
      ),
    );
  }
}

// --- Pintores -------------------------------------------------------------

final Paint _pincelTrazo = Paint()
  ..color = PaletaNeon.azulNeon
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.4
  ..strokeJoin = StrokeJoin.round;

final Paint _pincelTenue = Paint()
  ..color = PaletaNeon.textoTenue.withOpacity(0.35)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1;

/// Escribe [texto] centrado en [ancla]. Los `?` salen en violeta y más
/// grandes: es lo que se pregunta.
void _escribir(Canvas canvas, String texto, Offset ancla,
    {double tamano = 15, Color? color}) {
  final pregunta = texto.contains('?');
  final pincel = TextPainter(
    text: TextSpan(
      text: texto,
      style: TextStyle(
        color: color ??
            (pregunta ? PaletaNeon.violetaNeon : PaletaNeon.textoPrincipal),
        fontSize: pregunta ? tamano + 5 : tamano,
        fontWeight: pregunta ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  pincel.paint(canvas, ancla - Offset(pincel.width / 2, pincel.height / 2));
}

/// El cuadrado más grande que cabe en [tamano], centrado.
Rect _cuadroCentrado(Size tamano, {double margen = 0}) {
  final lado = math.min(tamano.width, tamano.height) - margen * 2;
  return Rect.fromCenter(
      center: tamano.center(Offset.zero), width: lado, height: lado);
}

class _PintorPlano extends CustomPainter {
  final VisualPlano plano;

  _PintorPlano(this.plano);

  @override
  void paint(Canvas canvas, Size size) {
    final cuadro = _cuadroCentrado(size, margen: 6);
    final rango = plano.rango;
    final paso = cuadro.width / (rango * 2);
    Offset aPantalla(num x, num y) =>
        Offset(cuadro.center.dx + x * paso, cuadro.center.dy - y * paso);

    for (var i = -rango; i <= rango; i++) {
      canvas.drawLine(aPantalla(i, -rango), aPantalla(i, rango), _pincelTenue);
      canvas.drawLine(aPantalla(-rango, i), aPantalla(rango, i), _pincelTenue);
    }
    final pincelEje = Paint()
      ..color = PaletaNeon.textoTenue
      ..strokeWidth = 1.6;
    canvas.drawLine(aPantalla(-rango, 0), aPantalla(rango, 0), pincelEje);
    canvas.drawLine(aPantalla(0, -rango), aPantalla(0, rango), pincelEje);
    _escribir(canvas, 'x', aPantalla(rango, 0) + const Offset(-8, 12),
        tamano: 13, color: PaletaNeon.textoTenue);
    _escribir(canvas, 'y', aPantalla(0, rango) + const Offset(12, 8),
        tamano: 13, color: PaletaNeon.textoTenue);
    for (var i = -rango + 1; i < rango; i++) {
      if (i == 0 || (rango > 6 && i.isOdd)) continue;
      _escribir(canvas, conSigno(i), aPantalla(i, 0) + const Offset(0, 10),
          tamano: 10, color: PaletaNeon.textoTenue);
      _escribir(canvas, conSigno(i), aPantalla(0, i) + const Offset(-12, 0),
          tamano: 10, color: PaletaNeon.textoTenue);
    }

    canvas.save();
    canvas.clipRect(cuadro);
    for (final recta in plano.rectas) {
      canvas.drawLine(
        aPantalla(-rango, recta.pendiente * -rango + recta.ordenada),
        aPantalla(rango, recta.pendiente * rango + recta.ordenada),
        Paint()
          ..color = PaletaNeon.ambarCanales
          ..strokeWidth = 2.6,
      );
    }
    canvas.restore();

    final pincelPunto = Paint()..color = PaletaNeon.rosaAcento;
    for (final punto in plano.puntos) {
      final centro = aPantalla(punto.x, punto.y);
      canvas.drawCircle(centro, 5, pincelPunto);
      if (punto.etiqueta.isNotEmpty)
        _escribir(canvas, punto.etiqueta, centro + const Offset(12, -12),
            tamano: 14);
    }
  }

  @override
  bool shouldRepaint(_PintorPlano viejo) => viejo.plano != plano;
}

class _PintorGrafica extends CustomPainter {
  final VisualGrafica grafica;

  _PintorGrafica(this.grafica);

  String get etiquetaX => grafica.etiquetaX;
  String get etiquetaY => grafica.etiquetaY;

  @override
  void paint(Canvas canvas, Size size) {
    if (grafica.puntos.isEmpty) return;
    final area = Rect.fromLTRB(40, 20, size.width - 16, size.height - 34);
    final maximoX = grafica.puntos.map((p) => p.x).reduce(math.max).toDouble();
    final maximoY = grafica.puntos.map((p) => p.y).reduce(math.max).toDouble();
    final escalaX = maximoX == 0 ? 1.0 : area.width / maximoX;
    final escalaY = maximoY == 0 ? 1.0 : area.height / maximoY;
    Offset aPantalla(num x, num y) =>
        Offset(area.left + x * escalaX, area.bottom - y * escalaY);

    final pincelEje = Paint()
      ..color = PaletaNeon.textoTenue
      ..strokeWidth = 1.6;
    canvas.drawLine(area.bottomLeft, area.bottomRight, pincelEje);
    canvas.drawLine(area.bottomLeft, area.topLeft, pincelEje);
    if (etiquetaX.isNotEmpty) {
      _escribir(canvas, etiquetaX, Offset(area.center.dx, size.height - 8),
          tamano: 12, color: PaletaNeon.textoTenue);
    }
    if (etiquetaY.isNotEmpty) {
      _escribir(canvas, etiquetaY, Offset(area.left + 40, area.top - 10),
          tamano: 12, color: PaletaNeon.textoTenue);
    }

    final valoresX = {for (final punto in grafica.puntos) punto.x};
    final valoresY = {for (final punto in grafica.puntos) punto.y};
    for (final x in valoresX) {
      canvas.drawLine(aPantalla(x, 0), aPantalla(x, maximoY), _pincelTenue);
      _escribir(
          canvas, formatearDecimal(x), aPantalla(x, 0) + const Offset(0, 11),
          tamano: 11, color: PaletaNeon.textoTenue);
    }
    for (final y in valoresY) {
      canvas.drawLine(aPantalla(0, y), aPantalla(maximoX, y), _pincelTenue);
      _escribir(
          canvas, formatearDecimal(y), aPantalla(0, y) + const Offset(-20, 0),
          tamano: 11, color: PaletaNeon.textoTenue);
    }

    final camino = Path()
      ..moveTo(aPantalla(grafica.puntos.first.x, grafica.puntos.first.y).dx,
          aPantalla(grafica.puntos.first.x, grafica.puntos.first.y).dy);
    for (final punto in grafica.puntos.skip(1)) {
      final destino = aPantalla(punto.x, punto.y);
      camino.lineTo(destino.dx, destino.dy);
    }
    canvas.drawPath(
      camino,
      Paint()
        ..color = PaletaNeon.ambarCanales
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );
    final pincelPunto = Paint()..color = PaletaNeon.rosaAcento;
    for (final punto in grafica.puntos) {
      canvas.drawCircle(aPantalla(punto.x, punto.y), 4, pincelPunto);
    }
  }

  @override
  bool shouldRepaint(_PintorGrafica viejo) => viejo.grafica != grafica;
}

class _PintorTriangulos extends CustomPainter {
  final VisualTriangulos triangulos;

  _PintorTriangulos(this.triangulos);

  void _triangulo(
      Canvas canvas, Offset abajoIzquierda, double base, List<String> lados) {
    final abajoDerecha = abajoIzquierda.translate(base, 0);
    final arriba = abajoIzquierda.translate(base * 0.3, -base * 0.8);
    canvas.drawPath(
      Path()
        ..moveTo(abajoIzquierda.dx, abajoIzquierda.dy)
        ..lineTo(abajoDerecha.dx, abajoDerecha.dy)
        ..lineTo(arriba.dx, arriba.dy)
        ..close(),
      _pincelTrazo,
    );
    if (lados.isNotEmpty)
      _escribir(
          canvas,
          lados[0],
          Offset.lerp(abajoIzquierda, abajoDerecha, 0.5)! +
              const Offset(0, 14));
    if (lados.length > 1)
      _escribir(canvas, lados[1],
          Offset.lerp(abajoIzquierda, arriba, 0.5)! + const Offset(-16, 0));
    if (lados.length > 2)
      _escribir(canvas, lados[2],
          Offset.lerp(arriba, abajoDerecha, 0.5)! + const Offset(16, -4));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final basePequena = size.width * 0.24;
    final baseGrande = math.min(size.width * 0.44, (size.height - 40) / 0.8);
    final suelo = size.height - 24;
    _triangulo(canvas, Offset(size.width * 0.06, suelo), basePequena,
        triangulos.ladosPequeno);
    _triangulo(canvas, Offset(size.width * 0.46, suelo), baseGrande,
        triangulos.ladosGrande);
  }

  @override
  bool shouldRepaint(_PintorTriangulos viejo) => viejo.triangulos != triangulos;
}

class _PintorCuerpo extends CustomPainter {
  final VisualCuerpo cuerpo;

  _PintorCuerpo(this.cuerpo);

  String? _medida(String clave) => cuerpo.medidas[clave];

  @override
  void paint(Canvas canvas, Size size) {
    final cuadro = _cuadroCentrado(size, margen: 22);
    final discontinua = Paint()
      ..color = PaletaNeon.azulNeon.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    switch (cuerpo.forma) {
      case FormaCuerpo.prisma:
      case FormaCuerpo.cubo:
        final esCubo = cuerpo.forma == FormaCuerpo.cubo;
        final ancho = cuadro.width * (esCubo ? 0.55 : 0.68);
        final alto = esCubo ? ancho : cuadro.height * 0.5;
        final fondo = Offset(ancho * 0.32, -ancho * 0.26);
        final frente =
            Rect.fromLTWH(cuadro.left, cuadro.bottom - alto, ancho, alto);
        canvas.drawRect(frente, _pincelTrazo);
        final atras = frente.shift(fondo);
        canvas.drawLine(frente.topLeft, atras.topLeft, _pincelTrazo);
        canvas.drawLine(frente.topRight, atras.topRight, _pincelTrazo);
        canvas.drawLine(frente.bottomRight, atras.bottomRight, _pincelTrazo);
        canvas.drawLine(atras.topLeft, atras.topRight, _pincelTrazo);
        canvas.drawLine(atras.topRight, atras.bottomRight, _pincelTrazo);
        canvas.drawLine(frente.bottomLeft, atras.bottomLeft, discontinua);
        canvas.drawLine(atras.bottomLeft, atras.bottomRight, discontinua);
        canvas.drawLine(atras.bottomLeft, atras.topLeft, discontinua);
        final largo = _medida(esCubo ? 'lado' : 'largo');
        if (largo != null)
          _escribir(
              canvas, largo, Offset(frente.center.dx, frente.bottom + 14));
        final textoAlto = _medida('alto');
        if (textoAlto != null)
          _escribir(
              canvas, textoAlto, Offset(frente.left - 22, frente.center.dy));
        final anchoTexto = _medida('ancho');
        if (anchoTexto != null) {
          _escribir(
              canvas,
              anchoTexto,
              Offset.lerp(frente.bottomRight, atras.bottomRight, 0.5)! +
                  const Offset(24, 4));
        }
      case FormaCuerpo.cilindro:
      case FormaCuerpo.cono:
        final ancho = cuadro.width * 0.55;
        final alto = cuadro.height * 0.62;
        final base = Rect.fromCenter(
            center: Offset(cuadro.center.dx, cuadro.bottom - ancho * 0.15),
            width: ancho,
            height: ancho * 0.3);
        canvas.drawArc(base, 0, math.pi, false, _pincelTrazo);
        canvas.drawArc(base, math.pi, math.pi, false, discontinua);
        final cima = base.center.translate(0, -alto);
        if (cuerpo.forma == FormaCuerpo.cilindro) {
          canvas.drawOval(base.shift(Offset(0, -alto)), _pincelTrazo);
          canvas.drawLine(base.centerLeft, base.centerLeft.translate(0, -alto),
              _pincelTrazo);
          canvas.drawLine(base.centerRight,
              base.centerRight.translate(0, -alto), _pincelTrazo);
        } else {
          canvas.drawLine(base.centerLeft, cima, _pincelTrazo);
          canvas.drawLine(base.centerRight, cima, _pincelTrazo);
          final generatriz = _medida('generatriz');
          if (generatriz != null)
            _escribir(
                canvas,
                generatriz,
                Offset.lerp(base.centerRight, cima, 0.5)! +
                    const Offset(22, 0));
        }
        canvas.drawLine(base.center, base.centerRight, discontinua);
        canvas.drawLine(
            base.center, base.center.translate(0, -alto), discontinua);
        final radio = _medida('radio');
        if (radio != null)
          _escribir(
              canvas,
              radio,
              Offset.lerp(base.center, base.centerRight, 0.5)! +
                  const Offset(0, -10));
        final altoTexto = _medida('alto');
        if (altoTexto != null)
          _escribir(canvas, altoTexto, base.center.translate(-20, -alto / 2));
      case FormaCuerpo.piramide:
        final ancho = cuadro.width * 0.62;
        final alto = cuadro.height * 0.62;
        final frenteIzquierda =
            Offset(cuadro.left + cuadro.width * 0.08, cuadro.bottom - 10);
        final frenteDerecha = frenteIzquierda.translate(ancho, 0);
        final fondo = Offset(ancho * 0.3, -ancho * 0.22);
        final centroBase =
            Offset.lerp(frenteIzquierda, frenteDerecha + fondo, 0.5)!;
        final cima = centroBase.translate(0, -alto);
        canvas.drawLine(frenteIzquierda, frenteDerecha, _pincelTrazo);
        canvas.drawLine(frenteDerecha, frenteDerecha + fondo, _pincelTrazo);
        canvas.drawLine(frenteIzquierda, frenteIzquierda + fondo, discontinua);
        canvas.drawLine(
            frenteIzquierda + fondo, frenteDerecha + fondo, discontinua);
        for (final esquina in [
          frenteIzquierda,
          frenteDerecha,
          frenteDerecha + fondo
        ]) {
          canvas.drawLine(esquina, cima, _pincelTrazo);
        }
        canvas.drawLine(frenteIzquierda + fondo, cima, discontinua);
        canvas.drawLine(centroBase, cima, discontinua);
        final lado = _medida('lado');
        if (lado != null)
          _escribir(
              canvas,
              lado,
              Offset.lerp(frenteIzquierda, frenteDerecha, 0.5)! +
                  const Offset(0, 14));
        final altoTexto = _medida('alto');
        if (altoTexto != null)
          _escribir(canvas, altoTexto, centroBase.translate(-18, -alto / 2));
      case FormaCuerpo.esfera:
        final radioPantalla = cuadro.width * 0.36;
        final centro = cuadro.center;
        canvas.drawCircle(centro, radioPantalla, _pincelTrazo);
        final ecuador = Rect.fromCenter(
            center: centro,
            width: radioPantalla * 2,
            height: radioPantalla * 0.5);
        canvas.drawArc(ecuador, 0, math.pi, false, _pincelTrazo);
        canvas.drawArc(ecuador, math.pi, math.pi, false, discontinua);
        canvas.drawLine(
            centro, centro.translate(radioPantalla, 0), discontinua);
        final radio = _medida('radio');
        if (radio != null)
          _escribir(canvas, radio, centro.translate(radioPantalla / 2, -12));
    }
  }

  @override
  bool shouldRepaint(_PintorCuerpo viejo) => viejo.cuerpo != cuerpo;
}

class _PintorFigura extends CustomPainter {
  final VisualFigura figura;

  _PintorFigura(this.figura);

  String? _medida(String clave) => figura.medidas[clave];

  void _poligono(Canvas canvas, List<Offset> vertices) {
    final camino = Path()..moveTo(vertices.first.dx, vertices.first.dy);
    for (final vertice in vertices.skip(1)) {
      camino.lineTo(vertice.dx, vertice.dy);
    }
    canvas.drawPath(camino..close(), _pincelTrazo);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cuadro = _cuadroCentrado(size, margen: 26);
    final discontinua = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    switch (figura.forma) {
      case FormaPlana.trapecio:
        final abajoIzquierda =
            Offset(cuadro.left, cuadro.bottom - cuadro.height * 0.2);
        final abajoDerecha = Offset(cuadro.right, abajoIzquierda.dy);
        final alto = cuadro.height * 0.5;
        final arribaIzquierda =
            abajoIzquierda.translate(cuadro.width * 0.22, -alto);
        final arribaDerecha =
            abajoDerecha.translate(-cuadro.width * 0.12, -alto);
        _poligono(canvas,
            [abajoIzquierda, abajoDerecha, arribaDerecha, arribaIzquierda]);
        canvas.drawLine(arribaIzquierda,
            Offset(arribaIzquierda.dx, abajoIzquierda.dy), discontinua);
        final mayor = _medida('baseMayor');
        if (mayor != null)
          _escribir(
              canvas,
              mayor,
              Offset.lerp(abajoIzquierda, abajoDerecha, 0.5)! +
                  const Offset(0, 14));
        final menor = _medida('baseMenor');
        if (menor != null)
          _escribir(
              canvas,
              menor,
              Offset.lerp(arribaIzquierda, arribaDerecha, 0.5)! +
                  const Offset(0, -14));
        final altoTexto = _medida('alto');
        if (altoTexto != null)
          _escribir(canvas, altoTexto,
              Offset(arribaIzquierda.dx + 18, abajoIzquierda.dy - alto / 2));
      case FormaPlana.rombo:
        final centro = cuadro.center;
        final mitadAncho = cuadro.width * 0.45;
        final mitadAlto = cuadro.height * 0.3;
        _poligono(canvas, [
          centro.translate(-mitadAncho, 0),
          centro.translate(0, -mitadAlto),
          centro.translate(mitadAncho, 0),
          centro.translate(0, mitadAlto),
        ]);
        canvas.drawLine(centro.translate(-mitadAncho, 0),
            centro.translate(mitadAncho, 0), discontinua);
        canvas.drawLine(centro.translate(0, -mitadAlto),
            centro.translate(0, mitadAlto), discontinua);
        final mayor = _medida('diagonalMayor');
        if (mayor != null)
          _escribir(canvas, mayor, centro.translate(mitadAncho / 2, 12));
        final menor = _medida('diagonalMenor');
        if (menor != null)
          _escribir(canvas, menor, centro.translate(18, -mitadAlto / 2));
      case FormaPlana.poligonoRegular:
        final lados = math.max(3, figura.lados);
        final centro = cuadro.center;
        final radio = cuadro.width * 0.42;
        // Un lado abajo, horizontal.
        final giro = math.pi / 2 + math.pi / lados;
        final vertices = [
          for (var i = 0; i < lados; i++)
            centro +
                Offset(math.cos(giro + i * 2 * math.pi / lados),
                        math.sin(giro + i * 2 * math.pi / lados)) *
                    radio,
        ];
        _poligono(canvas, vertices);
        final apotema = radio * math.cos(math.pi / lados);
        canvas.drawLine(centro, centro.translate(0, apotema), discontinua);
        final ladoTexto = _medida('lado');
        if (ladoTexto != null)
          _escribir(canvas, ladoTexto, centro.translate(0, apotema + 14));
        final apotemaTexto = _medida('apotema');
        if (apotemaTexto != null)
          _escribir(canvas, apotemaTexto, centro.translate(18, apotema / 2));
      case FormaPlana.trianguloRectangulo:
        final esquina = Offset(cuadro.left + cuadro.width * 0.12,
            cuadro.bottom - cuadro.height * 0.1);
        final derecha = esquina.translate(cuadro.width * 0.76, 0);
        final arriba = esquina.translate(0, -cuadro.height * 0.62);
        _poligono(canvas, [esquina, derecha, arriba]);
        canvas.drawRect(
            Rect.fromLTWH(esquina.dx, esquina.dy - 12, 12, 12), _pincelTenue);
        final cateto1 = _medida('cateto1');
        if (cateto1 != null)
          _escribir(canvas, cateto1,
              Offset.lerp(esquina, derecha, 0.5)! + const Offset(0, 14));
        final cateto2 = _medida('cateto2');
        if (cateto2 != null)
          _escribir(canvas, cateto2,
              Offset.lerp(esquina, arriba, 0.5)! + const Offset(-20, 0));
        final hipotenusa = _medida('hipotenusa');
        if (hipotenusa != null)
          _escribir(canvas, hipotenusa,
              Offset.lerp(arriba, derecha, 0.5)! + const Offset(18, -14));
      case FormaPlana.rectangulo:
        final rectangulo = Rect.fromCenter(
            center: cuadro.center,
            width: cuadro.width * 0.8,
            height: cuadro.height * 0.5);
        canvas.drawRect(rectangulo, _pincelTrazo);
        final base = _medida('base');
        if (base != null)
          _escribir(
              canvas, base, rectangulo.bottomCenter + const Offset(0, 14));
        final alto = _medida('alto');
        if (alto != null)
          _escribir(canvas, alto, rectangulo.centerLeft + const Offset(-22, 0));
    }
  }

  @override
  bool shouldRepaint(_PintorFigura viejo) => viejo.figura != figura;
}

class _PintorArbol extends CustomPainter {
  final VisualArbol arbol;

  _PintorArbol(this.arbol);

  @override
  void paint(Canvas canvas, Size size) {
    final raiz = Offset(18, size.height / 2);
    final columnaPrimera = size.width * 0.42;
    final columnaSegunda = size.width - 60;
    final pincelNudo = Paint()..color = PaletaNeon.azulNeon;
    canvas.drawCircle(raiz, 4, pincelNudo);
    final totalHojas = arbol.segundas
        .fold<int>(0, (suma, ramas) => suma + math.max(1, ramas.length));
    final altoHoja = size.height / math.max(1, totalHojas);
    var hoja = 0;
    for (var i = 0; i < arbol.primeras.length; i++) {
      final ramas =
          i < arbol.segundas.length ? arbol.segundas[i] : const <String>[];
      final hojasDeEsta = math.max(1, ramas.length);
      final nudo = Offset(columnaPrimera, altoHoja * (hoja + hojasDeEsta / 2));
      canvas.drawLine(raiz, nudo, _pincelTrazo);
      canvas.drawCircle(nudo, 4, pincelNudo);
      _escribir(canvas, arbol.primeras[i],
          Offset.lerp(raiz, nudo, 0.55)! + const Offset(0, -12),
          tamano: 13);
      for (var j = 0; j < ramas.length; j++) {
        final extremo = Offset(columnaSegunda, altoHoja * (hoja + j + 0.5));
        canvas.drawLine(nudo, extremo, _pincelTrazo);
        canvas.drawCircle(extremo, 4, pincelNudo);
        _escribir(canvas, ramas[j],
            Offset.lerp(nudo, extremo, 0.6)! + const Offset(0, -11),
            tamano: 13);
      }
      hoja += hojasDeEsta;
    }
  }

  @override
  bool shouldRepaint(_PintorArbol viejo) => viejo.arbol != arbol;
}
