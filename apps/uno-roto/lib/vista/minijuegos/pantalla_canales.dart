import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';
import 'sprites_maquinas.dart';

/// Canales — máquina de Rexán: comecocos matemático. Deslizar el dedo
/// por el laberinto (o la cruceta) cambia de dirección. Nada se mueve
/// hasta el primer gesto: da tiempo a leer la regla. Cada laberinto
/// registra un resultado en la maestría (acierto con ≤ 1 fallo).
class PantallaCanales extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  /// Periodo del reloj del juego; los tests lo alargan.
  final Duration? periodo;

  const PantallaCanales({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
    this.periodo,
  });

  @override
  State<PantallaCanales> createState() => _PantallaCanalesState();
}

class _PantallaCanalesState extends State<PantallaCanales>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_canales';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.canales);

  late final math.Random _azar;
  late final List<String> _habilidadesConRegla;
  late PartidaCanales _partida;
  Timer? _reloj;
  int _ronda = 1;
  bool _empezado = false;
  bool _entreLaberintos = false;
  bool _terminada = false;
  bool _pausado = false;
  String? _lineaRexan;
  DateTime _inicioLaberinto = DateTime.now();

  Duration get _periodo =>
      widget.periodo ??
      Duration(
          milliseconds: switch (widget.dificultad) { 1 => 320, 2 => 280, _ => 250 });

  @override
  void initState() {
    super.initState();
    _azar = math.Random(widget.semilla);
    _habilidadesConRegla = [
      for (final id in widget.habilidadesPracticadas)
        if (ReglaCanales.para(id, widget.dificultad, math.Random(0)) != null) id,
    ];
    if (_habilidadesConRegla.isEmpty) _habilidadesConRegla.add('DIV.01');
    _nuevoLaberinto();
    _reloj = Timer.periodic(_periodo, (_) => _tic());
    for (final sprite in ['fragmento', 'sombra']) {
      SpritesMaquinas.cargar(sprite).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _nuevoLaberinto() {
    final idHabilidad =
        _habilidadesConRegla[(_ronda - 1) % _habilidadesConRegla.length];
    _partida = PartidaCanales(
      laberinto: LaberintoCanales(
          laberintosCanales[(_ronda - 1) % laberintosCanales.length]),
      regla: ReglaCanales.para(idHabilidad, widget.dificultad, _azar)!,
      dificultad: widget.dificultad,
      nivel: _ronda,
      azar: _azar,
    );
    _empezado = false;
    _entreLaberintos = false;
    _lineaRexan = null;
    _inicioLaberinto = DateTime.now();
  }

  void _cambiarDireccion(Direccion direccion) {
    if (_terminada || _entreLaberintos) return;
    setState(() {
      _partida.direccionDeseada = direccion;
      _empezado = true;
    });
  }

  void _tic() {
    if (!mounted || !_empezado || _entreLaberintos || _terminada || _pausado) return;
    final evento = _partida.avanzar();
    setState(() {
      switch (evento) {
        case EventoCanales.recogido:
          HapticFeedback.selectionClick();
          sonar('efecto_tap'); // gota entrando en agua (doc 12)
          anotarAcierto();
        case EventoCanales.noCumplia:
          HapticFeedback.vibrate();
          sonar('efecto_error');
          anotarFallo();
          _lineaRexan = 'no-cumple';
        case EventoCanales.pillado:
          HapticFeedback.mediumImpact();
          sonar('efecto_whoosh');
          _lineaRexan = 'Te han pillado. Vuelves a la salida.';
        case EventoCanales.laberintoTerminado:
          _terminarLaberinto();
        case EventoCanales.nada:
          break;
      }
    });
  }

  void _terminarLaberinto() {
    HapticFeedback.heavyImpact();
    sonar('efecto_acierto');
    _entreLaberintos = true;
    widget.registro?.registrar(
      idHabilidad: _partida.regla.idHabilidad,
      acierto: _partida.acierto,
      dificultad: 0.8 + 0.3 * widget.dificultad,
      duracion: DateTime.now().difference(_inicioLaberinto),
    );
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      _reloj?.cancel();
      return;
    }
    _lineaRexan = 'Laberinto limpio.';
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _ronda++;
        _nuevoLaberinto();
      });
    });
  }

  String _textoRegla(Locale locale) {
    final parametro = _partida.regla.parametro;
    return traducirNarrativa(_partida.regla.texto, locale)
        .replaceAll('{n}', parametro?.toString() ?? '');
  }

  String _linea(Locale locale) {
    if (_terminada) {
      return traducirNarrativa(
          'Tres laberintos. Las sombras se van a dormir; tú también.', locale);
    }
    final linea = _lineaRexan;
    if (linea == 'no-cumple') {
      return traducirNarrativa('Ese no cumple: {valor}.', locale)
          .replaceAll('{valor}', _partida.ultimoFallo?.etiqueta ?? '');
    }
    return traducirNarrativa(
        linea ??
            (_empezado
                ? _definicion.lineaRexan
                : switch (_ronda) {
                    1 => 'Lee la regla. Cuando quieras, elige una dirección.',
                    2 => 'Tres sombras esta vez. Lee la regla y elige dirección.',
                    _ => 'Una sombra ya no vaga: te busca. Y hay más números trampa.',
                  }),
        locale);
  }

  void _alDeslizar(DragEndDetails detalles) {
    final velocidad = detalles.velocity.pixelsPerSecond;
    if (velocidad.distance < 50) return;
    if (velocidad.dx.abs() > velocidad.dy.abs()) {
      _cambiarDireccion(velocidad.dx > 0 ? Direccion.derecha : Direccion.izquierda);
    } else {
      _cambiarDireccion(velocidad.dy > 0 ? Direccion.abajo : Direccion.arriba);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final laberinto = _partida.laberinto;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.regla.idHabilidad,
      dificultadEjemplo: widget.dificultad,
      parametroEjemplo: _partida.regla.parametro,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: _linea(locale),
      terminada: _terminada,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _textoRegla(locale),
                  style: const TextStyle(
                    color: PaletaNeon.ambarCanales,
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                traducirNarrativa('Quedan {n}', locale)
                    .replaceAll('{n}', '${_partida.pendientes}'),
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: laberinto.ancho / laberinto.alto,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanEnd: _alDeslizar,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PintorCanales(partida: _partida),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CrucetaMinijuego(alPulsar: _cambiarDireccion),
        ],
      ),
    );
  }
}

class PintorCanales extends CustomPainter {
  final PartidaCanales partida;

  PintorCanales({required this.partida});

  @override
  void paint(Canvas canvas, Size size) {
    final laberinto = partida.laberinto;
    final lado = size.width / laberinto.ancho;
    Rect rectDe(Celda celda) =>
        Rect.fromLTWH(celda.columna * lado, celda.fila * lado, lado, lado);

    // Agua de los canales y muros.
    canvas.drawRect(Offset.zero & size,
        Paint()..color = PaletaNeon.azulNeon.withOpacity(0.07));
    final pinturaMuro = Paint()..color = PaletaNeon.fondoMedio;
    final pinturaBorde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = PaletaNeon.violetaBase.withOpacity(0.45);
    for (var fila = 0; fila < laberinto.alto; fila++) {
      for (var columna = 0; columna < laberinto.ancho; columna++) {
        final celda = Celda(fila, columna);
        if (laberinto.esCanal(celda)) continue;
        final rect = rectDe(celda).deflate(0.5);
        canvas.drawRect(rect, pinturaMuro);
        canvas.drawRect(rect, pinturaBorde);
      }
    }

    // Números.
    partida.numeros.forEach((celda, numero) {
      final pintor = TextPainter(
        text: TextSpan(
          text: numero.etiqueta,
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: numero.etiqueta.length > 3 ? lado * 0.3 : lado * 0.38,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final centro = rectDe(celda).center;
      pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
    });

    // Sombras.
    final spriteSombra = SpritesMaquinas.ya('sombra');
    for (var indice = 0; indice < partida.sombras.length; indice++) {
      final sombra = partida.sombras[indice];
      final centro = rectDe(sombra).center;
      // La cazadora lleva un halo rosado: se distingue de lejos.
      if (partida.esCazadora(indice)) {
        canvas.drawCircle(centro, lado * 0.62,
            Paint()
              ..color = PaletaNeon.rosaAcento.withOpacity(0.35)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
      if (spriteSombra != null) {
        pintarSprite(canvas, spriteSombra, rectDe(sombra).inflate(lado * 0.1));
        continue;
      }
      canvas.drawCircle(centro, lado * 0.42,
          Paint()..color = PaletaNeon.violetaBase.withOpacity(0.55));
      canvas.drawCircle(centro, lado * 0.42,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = PaletaNeon.violetaNeon.withOpacity(0.8));
    }

    // El Fragmento del niño.
    final spriteFragmento = SpritesMaquinas.ya('fragmento');
    if (spriteFragmento != null) {
      pintarSprite(
          canvas, spriteFragmento, rectDe(partida.jugador).inflate(lado * 0.08));
      return;
    }
    final centroJugador = rectDe(partida.jugador).center;
    canvas.drawCircle(centroJugador, lado * 0.36,
        Paint()..color = PaletaNeon.ambarCanales);
    canvas.drawCircle(
      centroJugador,
      lado * 0.48,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = PaletaNeon.ambarCanales.withOpacity(0.4),
    );
  }

  @override
  bool shouldRepaint(PintorCanales anterior) => true;
}
