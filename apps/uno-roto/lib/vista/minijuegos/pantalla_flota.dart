import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart' show Celda;
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/flota.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';
import 'pantalla_recreativa.dart';

/// La flota — máquina de Rexán. Rexán canta columna y fila en cálculo;
/// el niño toca la casilla. Si se equivoca, se le enseña cuál era y el
/// disparo se hace igual. Cada flota hundida registra maestría por
/// habilidad (acierto con como mucho un fallo).
class PantallaFlota extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaFlota({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaFlota> createState() => _PantallaFlotaState();
}

class _PantallaFlotaState extends State<PantallaFlota> with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_flota';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.flota);

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);

  /// Dificultad de las cuentas en esta ronda (sube con el nivel).
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  late final math.Random _azar;
  late final List<String> _habilidades;
  late PartidaFlota _partida;
  int _ronda = 1;
  Celda? _correccion;
  bool _esperando = false;
  bool _terminada = false;
  String? _lineaRexan;
  String _datoLinea = '';
  DateTime _inicio = DateTime.now();

  @override
  void initState() {
    super.initState();
    _azar = math.Random(widget.semilla);
    _habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (id == 'PROP.04' || id == 'FR.22') id,
    ];
    if (_habilidades.isEmpty) _habilidades.add('FR.22');
    _nuevaPartida();
  }

  void _nuevaPartida() {
    _partida = PartidaFlota(
        habilidades: _habilidades, dificultad: _enNivel.dificultad, azar: _azar);
    _inicio = DateTime.now();
    _correccion = null;
    _lineaRexan = null;
  }

  void _tocar(Celda celda) {
    if (_esperando || _terminada) return;
    final objetivo = _partida.objetivo;
    final (acierta, resultado) = _partida.tocar(celda);
    setState(() {
      _esperando = true;
      if (acierta) {
        HapticFeedback.selectionClick();
        _correccion = null;
        anotarAcierto();
        _lineaRexan = switch (resultado) {
          ResultadoDisparo.agua => 'Agua.',
          ResultadoDisparo.tocado => '¡Tocado!',
          ResultadoDisparo.hundido => 'Hundido.',
        };
      } else {
        HapticFeedback.vibrate();
        sonar('efecto_error');
        anotarFallo();
        _correccion = objetivo;
        _datoLinea = 'columna ${objetivo.columna + 1}, fila ${objetivo.fila + 1}';
        _lineaRexan = 'Era la casilla {dato}. Disparo ahí.';
      }
      if (resultado != ResultadoDisparo.agua) sonar('efecto_tablon');
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _esperando = false;
        _correccion = null;
        if (_partida.flotaHundida) {
          _terminarPartida();
        } else {
          _partida.nuevoObjetivo();
        }
      });
    });
  }

  void _terminarPartida() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicio);
    _partida.aciertoPorHabilidad.forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: duracion,
      );
    });
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      return;
    }
    _ronda++;
    _nuevaPartida();
    _lineaRexan = 'Flota hundida. La siguiente, mar adentro: cuentas más difíciles.';
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Dos flotas al fondo. El Puerto vuelve a estar en calma.'
        : _lineaRexan ?? _definicion.lineaRexan;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.columna.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      enunciadoActual: _partida.columna.expresion,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan:
          traducirNarrativa(linea, locale).replaceAll('{dato}', _datoLinea),
      terminada: _terminada,
      child: Column(
        children: [
          _Coordenadas(
            columna: _partida.columna.expresion,
            fila: _partida.fila.expresion,
            textoColumna: traducirNarrativa('Columna', locale),
            textoFila: traducirNarrativa('Fila', locale),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (_, restricciones) {
                    final lienzo = restricciones.biggest;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (detalles) {
                        final celda = PintorFlota.celdaEn(
                            detalles.localPosition, lienzo);
                        if (celda != null) _tocar(celda);
                      },
                      // El mar se mueve siempre; el último disparo, al caer.
                      child: RelojAmbiente(
                        periodo: const Duration(seconds: 3),
                        builder: (_, fase) => TweenAnimationBuilder<double>(
                          key: ValueKey('disparo-$_ronda-${_partida.disparos.length}'),
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (_, impacto, __) => CustomPaint(
                            size: lienzo,
                            painter: PintorFlota(
                              partida: _partida,
                              correccion: _correccion,
                              fase: fase,
                              impacto: impacto,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Coordenadas extends StatelessWidget {
  final String columna;
  final String fila;
  final String textoColumna;
  final String textoFila;

  const _Coordenadas({
    required this.columna,
    required this.fila,
    required this.textoColumna,
    required this.textoFila,
  });

  Widget _dato(String etiqueta, String valor) => Expanded(
        child: Column(
          children: [
            Text(etiqueta.toUpperCase(),
                style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 2.5)),
            const SizedBox(height: 2),
            Text(valor,
                style: const TextStyle(
                    color: PaletaNeon.ambarCanales, fontSize: 20)),
          ],
        ),
      );

  @override
  Widget build(BuildContext contexto) =>
      Row(children: [_dato(textoColumna, columna), _dato(textoFila, fila)]);
}

/// Tablero 8×8 con números en los bordes (columnas arriba, filas a la
/// izquierda): mar que ondula, disparos hechos (anillos en el agua,
/// llamas en lo tocado, humo en lo hundido) y, si hace falta, la casilla
/// correcta.
class PintorFlota extends CustomPainter {
  final PartidaFlota partida;
  final Celda? correccion;
  final Animation<double>? fase;

  /// 0→1 tras el último disparo: la salpicadura o la explosión.
  final double impacto;

  PintorFlota({
    required this.partida,
    required this.correccion,
    this.fase,
    this.impacto = 1,
  }) : super(repaint: fase);

  static const _margen = 0.1; // fracción para los números de los bordes

  static Celda? celdaEn(Offset posicion, Size lienzo) {
    final inicio = lienzo.width * _margen;
    final lado = (lienzo.width - inicio) / PartidaFlota.lado;
    final columna = ((posicion.dx - inicio) / lado).floor();
    final fila = ((posicion.dy - inicio) / lado).floor();
    if (columna < 0 || fila < 0 || columna >= PartidaFlota.lado || fila >= PartidaFlota.lado) {
      return null;
    }
    return Celda(fila, columna);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final inicio = size.width * _margen;
    final lado = (size.width - inicio) / PartidaFlota.lado;
    final t = fase?.value ?? 0;
    Rect rectDe(Celda celda) => Rect.fromLTWH(
        inicio + celda.columna * lado, inicio + celda.fila * lado, lado, lado);

    for (var i = 0; i < PartidaFlota.lado; i++) {
      _texto(canvas, '${i + 1}', Offset(inicio + (i + 0.5) * lado, inicio / 2));
      _texto(canvas, '${i + 1}', Offset(inicio / 2, inicio + (i + 0.5) * lado));
    }

    // El mar: degradado y olas que corren en diagonal.
    final mar = Rect.fromLTWH(inicio, inicio, lado * PartidaFlota.lado, lado * PartidaFlota.lado);
    canvas.drawRect(
      mar,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1F4A), Color(0xFF0A1433), Color(0xFF102A5C)],
        ).createShader(mar),
    );
    canvas.save();
    canvas.clipRect(mar);
    final ola = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = PaletaNeon.azulNeon.withOpacity(0.16);
    for (var fila = 0; fila < PartidaFlota.lado * 2; fila++) {
      final y = inicio + (fila + 0.5) * lado / 2;
      final camino = Path();
      for (var x = 0.0; x <= mar.width; x += 4) {
        final altura = math.sin((x / lado) * math.pi + t * math.pi * 2 + fila * 0.9) *
            lado * 0.06;
        if (x == 0) {
          camino.moveTo(inicio + x, y + altura);
        } else {
          camino.lineTo(inicio + x, y + altura);
        }
      }
      canvas.drawPath(camino, ola);
    }
    canvas.restore();

    final linea = Paint()
      ..style = PaintingStyle.stroke
      ..color = PaletaNeon.azulNeon.withOpacity(0.22);
    for (var f = 0; f < PartidaFlota.lado; f++) {
      for (var c = 0; c < PartidaFlota.lado; c++) {
        canvas.drawRect(rectDe(Celda(f, c)), linea);
      }
    }

    final ultima = partida.disparos.isEmpty ? null : partida.disparos.keys.last;
    partida.disparos.forEach((celda, resultado) {
      final rect = rectDe(celda);
      final esUltima = celda == ultima;
      final progreso = esUltima ? impacto : 1.0;
      switch (resultado) {
        case ResultadoDisparo.agua:
          _agua(canvas, rect.center, lado, progreso);
        case ResultadoDisparo.tocado:
          _casco(canvas, rect, lado, hundido: false);
          _llama(canvas, rect.center, lado, t + celda.columna * 0.3);
          if (esUltima) _explosion(canvas, rect.center, lado, progreso);
        case ResultadoDisparo.hundido:
          _casco(canvas, rect, lado, hundido: true);
          _humo(canvas, rect.center, lado, t + celda.fila * 0.37);
          if (esUltima) _explosion(canvas, rect.center, lado, progreso);
      }
    });

    final celdaCorrecta = correccion;
    if (celdaCorrecta != null) {
      canvas.drawRect(
        rectDe(celdaCorrecta).deflate(2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = PaletaNeon.exitoSuave,
      );
    }
  }

  /// Agua: un punto y anillos que se abren (del todo en el último disparo).
  void _agua(Canvas canvas, Offset centro, double lado, double progreso) {
    canvas.drawCircle(centro, lado * 0.08,
        Paint()..color = PaletaNeon.azulNeon.withOpacity(0.7));
    final anillo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 2; i++) {
      final radio = lado * (0.16 + 0.24 * progreso) * (1 + i * 0.45);
      anillo.color = PaletaNeon.azulNeon.withOpacity(0.55 * (1 - progreso * 0.6) / (1 + i));
      canvas.drawCircle(centro, radio, anillo);
    }
  }

  /// Trozo de barco: gris metal si está tocado, rojo apagado si hundido.
  void _casco(Canvas canvas, Rect rect, double lado, {required bool hundido}) {
    final casco = RRect.fromRectAndRadius(rect.deflate(lado * 0.14), Radius.circular(lado * 0.12));
    canvas.drawRRect(
      casco,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: hundido
              ? [PaletaNeon.rojoOxidado, const Color(0xFF3A1712)]
              : [PaletaNeon.grisMetal, const Color(0xFF5B6470)],
        ).createShader(casco.outerRect),
    );
    // Remaches.
    final remache = Paint()..color = Colors.black.withOpacity(0.35);
    for (final dx in [-0.22, 0.0, 0.22]) {
      canvas.drawCircle(casco.center + Offset(dx * lado, lado * 0.16), lado * 0.035, remache);
    }
  }

  /// Llama que parpadea sobre lo tocado.
  void _llama(Canvas canvas, Offset centro, double lado, double t) {
    final latido = 0.8 + 0.2 * math.sin(t * math.pi * 6);
    final base = centro + Offset(0, -lado * 0.02);
    for (final (color, escala) in [
      (PaletaNeon.rosaAcento, 0.34),
      (PaletaNeon.ambarCanales, 0.24),
      (const Color(0xFFFFF1C4), 0.12),
    ]) {
      final alto = lado * escala * latido;
      final llama = Path()
        ..moveTo(base.dx - alto * 0.55, base.dy)
        ..quadraticBezierTo(base.dx - alto * 0.5, base.dy - alto * 0.9, base.dx, base.dy - alto * 1.6)
        ..quadraticBezierTo(base.dx + alto * 0.5, base.dy - alto * 0.9, base.dx + alto * 0.55, base.dy)
        ..close();
      canvas.drawPath(llama, Paint()..color = color.withOpacity(0.9));
    }
  }

  /// Humo gris que sube de lo hundido.
  void _humo(Canvas canvas, Offset centro, double lado, double t) {
    final humo = Paint();
    for (var i = 0; i < 3; i++) {
      final f = (t + i / 3) % 1;
      humo.color = PaletaNeon.grisMetal.withOpacity(0.35 * (1 - f));
      canvas.drawCircle(
          centro + Offset(math.sin((f + i) * 3) * lado * 0.08, -lado * (0.1 + 0.45 * f)),
          lado * (0.08 + 0.1 * f),
          humo);
    }
  }

  /// Destello del impacto: un anillo ámbar que se abre y se apaga.
  void _explosion(Canvas canvas, Offset centro, double lado, double progreso) {
    if (progreso >= 1) return;
    canvas.drawCircle(
      centro,
      lado * (0.2 + 0.7 * progreso),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - progreso) + 0.5
        ..color = PaletaNeon.ambarCanales.withOpacity(1 - progreso),
    );
    canvas.drawCircle(centro, lado * 0.45 * (1 - progreso),
        Paint()..color = const Color(0xFFFFF1C4).withOpacity(0.6 * (1 - progreso)));
  }

  void _texto(Canvas canvas, String texto, Offset centro) {
    final pintor = TextPainter(
      text: TextSpan(
          text: texto,
          style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorFlota anterior) => true;
}
