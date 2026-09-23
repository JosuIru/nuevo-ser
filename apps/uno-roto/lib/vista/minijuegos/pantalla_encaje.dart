import 'dart:async';
import 'dart:math' as math;

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

class _PantallaEncajeState extends State<PantallaEncaje>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_encaje';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.encaje);

  final _tablero = TableroEncaje();
  late final GeneradorEncaje _generador;
  late PiezaEncaje _siguiente;
  Timer? _temporizador;
  String? _lineaRexan;
  bool _terminada = false;
  bool _pausado = false;

  /// Nivel por unidades completadas: 0-1 → 1, 2-3 → 2, 4-5 → 3.
  int get _nivel => math.min(3, 1 + _tablero.unidades ~/ 2);

  Duration get _periodo {
    final base = widget.periodoCaida ??
        Duration(
            milliseconds: switch (widget.dificultad) { 1 => 1100, 2 => 900, _ => 750 });
    return base * const [1.0, 0.85, 0.7][_nivel - 1];
  }

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
    if (_terminada || _pausado || !mounted) return;
    setState(() {
      if (_tablero.bajar() == ResultadoCaida.encajada) _trasEncajar();
    });
  }

  void _soltar() {
    if (_terminada || _tablero.piezaActual == null) return;
    HapticFeedback.lightImpact();
    sonar('efecto_tablon');
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
      sonar('efecto_fila_completa');
      anotarAcierto();
      _lineaRexan = 'Un uno.';
      if (_nivel != _generador.nivel && _tablero.unidades < _definicion.rondasPorPartida) {
        _generador.nivel = _nivel;
        _temporizador?.cancel();
        _temporizador = Timer.periodic(_periodo, (_) => _caer());
        _lineaRexan = _nivel == 2
            ? 'Ahora algunas piezas vienen disfrazadas: 2/4 es 1/2.'
            : 'Más rápido y sin ayudas en el tablero. Tú sabes lo que falta.';
      }
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
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: 'FR.16',
      dificultadEjemplo: widget.dificultad,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
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
                      // El destello de la fila se reproduce con cada unidad.
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('unidad-${_tablero.unidades}'),
                        tween: Tween(begin: _tablero.unidades == 0 ? 1 : 0, end: 1),
                        duration: const Duration(milliseconds: 650),
                        builder: (_, destello, __) => CustomPaint(
                        size: lienzo,
                        painter: PintorEncaje(
                          destelloFila: destello,
                          tablero: _tablero,
                          mostrarFaltas: widget.dificultad < 3 && _nivel < 3,
                          mostrarRejilla: widget.dificultad < 3 && _nivel < 3,
                          textoFalta: traducirNarrativa('faltan', locale),
                        ),
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

  /// 0→1 tras completar una unidad: la fila brilla y se apaga.
  final double destelloFila;

  PintorEncaje({
    this.destelloFila = 1,
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
      // Sombra: dónde quedaría si se soltara ahora.
      final caida = tablero.alturaDeCaida;
      if (caida != null && caida != tablero.altura) {
        final sombra = RRect.fromRectAndRadius(
            rectDe(caida, tablero.columna, pieza.celdas), const Radius.circular(3));
        canvas.drawRRect(
          sombra,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = colorDeFamilia(pieza.valor.denominador).withOpacity(0.35),
        );
      }
      _pintarBarra(
          canvas, rectDe(tablero.altura, tablero.columna, pieza.celdas), pieza,
          opacidad: 1, brillo: true);
    }

    final filaCompletada = tablero.ultimaFilaCompletada;
    if (filaCompletada != null && destelloFila < 1) {
      final banda = Rect.fromLTWH(0, size.height - (filaCompletada + 1) * altoFila,
          size.width, altoFila).inflate(altoFila * 0.6 * destelloFila);
      canvas.drawRect(
        banda,
        Paint()
          ..color = PaletaNeon.ambarCanales.withOpacity(0.55 * (1 - destelloFila))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
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
      {required double opacidad, bool brillo = false}) {
    final color = colorDeFamilia(pieza.valor.denominador);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    if (brillo) {
      canvas.drawRRect(
          rrect.inflate(2),
          Paint()
            ..color = color.withOpacity(0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    // Relieve: más luz arriba, más sombra abajo, filo claro.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.55 * opacidad), color.withOpacity(0.2 * opacidad)],
        ).createShader(rect),
    );
    canvas.drawLine(rect.topLeft + const Offset(3, 1.5), rect.topRight + const Offset(-3, 1.5),
        Paint()
          ..color = Colors.white.withOpacity(0.25 * opacidad)
          ..strokeWidth = 1);
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
