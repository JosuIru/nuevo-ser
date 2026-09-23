import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/encaje.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Encaje — máquina de Rexán: Tetris de fracciones. Se arrastra el dedo
/// por el tablero para mover la barra y se toca (o SOLTAR) para dejarla
/// caer. Cada fila llena es una unidad. Es práctica: no registra
/// maestría, porque no hay decisiones de acierto o fallo claras.
class PantallaEncaje extends StatefulWidget {
  final int dificultad;
  final int? semilla;

  /// Periodo de caída; los tests lo alargan para controlar el tiempo.
  final Duration? periodoCaida;

  const PantallaEncaje({
    super.key,
    required this.dificultad,
    this.semilla,
    this.periodoCaida,
  });

  @override
  State<PantallaEncaje> createState() => _PantallaEncajeState();
}

class _PantallaEncajeState extends State<PantallaEncaje> {
  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.encaje);

  final _tablero = TableroEncaje();
  late final GeneradorEncaje _generador;
  late PiezaEncaje _siguiente;
  Timer? _temporizador;
  String? _lineaRexan;
  bool _terminada = false;

  Duration get _periodo =>
      widget.periodoCaida ??
      Duration(
          milliseconds: switch (widget.dificultad) { 1 => 1100, 2 => 900, _ => 750 });

  @override
  void initState() {
    super.initState();
    _generador =
        GeneradorEncaje(dificultad: widget.dificultad, semilla: widget.semilla);
    _siguiente = _generador.siguiente(_tablero);
    _nuevaPieza();
    _temporizador = Timer.periodic(_periodo, (_) => _caer());
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _nuevaPieza() {
    final pieza = _siguiente;
    if (_tablero.entrar(pieza) == ResultadoCaida.tableroVaciado) {
      _lineaRexan = 'Se ha llenado. Lo vacío y seguimos.';
    }
    _siguiente = _generador.siguiente(_tablero);
  }

  void _caer() {
    if (_terminada || !mounted) return;
    setState(() {
      if (_tablero.bajar() == ResultadoCaida.encajada) _trasEncajar();
    });
  }

  void _soltar() {
    if (_terminada || _tablero.piezaActual == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _tablero.soltar();
      _trasEncajar();
    });
  }

  void _trasEncajar() {
    final unidadesAntes = _unidadesVistas;
    _unidadesVistas = _tablero.unidades;
    if (_tablero.unidades > unidadesAntes) {
      HapticFeedback.mediumImpact();
      _lineaRexan = 'Un uno.';
    }
    if (_tablero.unidades >= _definicion.rondasPorPartida) {
      _terminada = true;
      _temporizador?.cancel();
      return;
    }
    _nuevaPieza();
  }

  int _unidadesVistas = 0;

  void _moverConDedo(Offset posicion, Size lienzo) {
    final pieza = _tablero.piezaActual;
    if (pieza == null || _terminada) return;
    final anchoCelda = lienzo.width / columnasEncaje;
    final centroEnCeldas = posicion.dx / anchoCelda;
    setState(() => _tablero.moverA((centroEnCeldas - pieza.celdas / 2).round()));
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Seis unidades. La máquina se calienta; mañana más.'
        : _lineaRexan ?? _definicion.lineaRexan;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ronda: (_tablero.unidades + 1).clamp(1, _definicion.rondasPorPartida),
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: traducirNarrativa(linea, locale),
      terminada: _terminada,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                traducirNarrativa('Siguiente', locale).toUpperCase(),
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8),
                  fontSize: 10,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _siguiente.etiqueta.etiqueta,
                style: TextStyle(
                  color: colorDeFamilia(_siguiente.valor.denominador),
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: columnasEncaje / filasEncaje,
                child: LayoutBuilder(
                  builder: (_, restricciones) {
                    final lienzo = restricciones.biggest;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) =>
                          _moverConDedo(d.localPosition, lienzo),
                      onTap: _soltar,
                      child: CustomPaint(
                        size: lienzo,
                        painter: PintorEncaje(
                          tablero: _tablero,
                          mostrarFaltas: widget.dificultad < 3,
                          mostrarRejilla: widget.dificultad < 3,
                          textoFalta: traducirNarrativa('faltan', locale),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          BotonMinijuego(
            texto: traducirNarrativa('SOLTAR', locale),
            alPulsar: _tablero.piezaActual == null ? null : _soltar,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Un color por familia de denominador: se aprende a reconocer que
/// 2/4 y 1/2 son "de la misma casa" cuando se simplifican.
Color colorDeFamilia(int denominador) => switch (denominador) {
      1 || 2 => PaletaNeon.ambarCanales,
      3 => PaletaNeon.azulNeon,
      4 => PaletaNeon.violetaNeon,
      6 => PaletaNeon.exitoSuave,
      _ => PaletaNeon.rosaAcento,
    };

class PintorEncaje extends CustomPainter {
  final TableroEncaje tablero;
  final bool mostrarFaltas;
  final bool mostrarRejilla;
  final String textoFalta;

  PintorEncaje({
    required this.tablero,
    required this.mostrarFaltas,
    required this.mostrarRejilla,
    required this.textoFalta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final anchoCelda = size.width / columnasEncaje;
    final altoFila = size.height / filasEncaje;
    Rect rectDe(int fila, int inicio, int celdas) => Rect.fromLTWH(
          inicio * anchoCelda,
          size.height - (fila + 1) * altoFila,
          celdas * anchoCelda,
          altoFila,
        ).deflate(1.5);

    canvas.drawRect(Offset.zero & size,
        Paint()..color = PaletaNeon.fondoMedio.withOpacity(0.6));
    if (mostrarRejilla) {
      final pinturaRejilla = Paint()
        ..color = PaletaNeon.textoTenue.withOpacity(0.08)
        ..strokeWidth = 1;
      for (var celda = 1; celda < columnasEncaje; celda++) {
        canvas.drawLine(Offset(celda * anchoCelda, 0),
            Offset(celda * anchoCelda, size.height), pinturaRejilla);
      }
    }

    for (var fila = 0; fila < filasEncaje; fila++) {
      for (final trozo in tablero.filas[fila]) {
        _pintarBarra(canvas, rectDe(fila, trozo.inicio, trozo.pieza.celdas),
            trozo.pieza, opacidad: 0.75);
      }
      final falta = tablero.faltaEnFila(fila);
      if (mostrarFaltas && falta != null) {
        // En el hueco libre más largo de la fila, para no tapar trozos.
        final (inicioHueco, largoHueco) = _huecoMasLargo(fila);
        final rectHueco = rectDe(fila, inicioHueco, largoHueco);
        // Si no cabe "faltan 5/12", sólo "5/12"; si tampoco, nada.
        for (final texto in ['$textoFalta ${falta.etiqueta}', falta.etiqueta]) {
          if (_anchoTexto(texto, 10) <= rectHueco.width - 4) {
            _texto(canvas, texto, rectHueco.center,
                color: PaletaNeon.textoTenue.withOpacity(0.55), tamano: 10);
            break;
          }
        }
      }
    }

    final pieza = tablero.piezaActual;
    if (pieza != null) {
      _pintarBarra(
          canvas, rectDe(tablero.altura, tablero.columna, pieza.celdas), pieza,
          opacidad: 1);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = PaletaNeon.violetaBase.withOpacity(0.6),
    );
  }

  (int, int) _huecoMasLargo(int fila) {
    final ocupadas = List.filled(columnasEncaje, false);
    for (final trozo in tablero.filas[fila]) {
      for (var celda = trozo.inicio; celda < trozo.fin; celda++) {
        ocupadas[celda] = true;
      }
    }
    var mejorInicio = 0, mejorLargo = 0, inicio = 0;
    for (var celda = 0; celda <= columnasEncaje; celda++) {
      if (celda == columnasEncaje || ocupadas[celda]) {
        if (celda - inicio > mejorLargo) {
          mejorInicio = inicio;
          mejorLargo = celda - inicio;
        }
        inicio = celda + 1;
      }
    }
    return (mejorInicio, mejorLargo);
  }

  void _pintarBarra(Canvas canvas, Rect rect, PiezaEncaje pieza,
      {required double opacidad}) {
    final color = colorDeFamilia(pieza.valor.denominador);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = color.withOpacity(0.35 * opacidad));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withOpacity(opacidad),
    );
    if (rect.width > 20) {
      _texto(canvas, pieza.etiqueta.etiqueta, rect.center,
          color: PaletaNeon.textoPrincipal.withOpacity(opacidad), tamano: 12);
    }
  }

  double _anchoTexto(String texto, double tamano) => (TextPainter(
        text: TextSpan(text: texto, style: TextStyle(fontSize: tamano)),
        textDirection: TextDirection.ltr,
      )..layout())
          .width;

  void _texto(Canvas canvas, String texto, Offset ancla,
      {required Color color, required double tamano}) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(
        canvas, ancla - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorEncaje anterior) => true;
}
