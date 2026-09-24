import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart' show Celda, Direccion;
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/retos_calculo.dart';
import '../../dominio/minijuegos/serpiente.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';
import 'pantalla_recreativa.dart';

/// Serpiente — máquina de Rexán. Guiar la serpiente (deslizar o cruceta)
/// hasta el número que responde al reto. Nada se mueve hasta el primer
/// gesto. Cada ronda (cinco respuestas) registra maestría por habilidad.
class PantallaSerpiente extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;
  final Duration? periodo;

  const PantallaSerpiente({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
    this.periodo,
  });

  @override
  State<PantallaSerpiente> createState() => _PantallaSerpienteState();
}

class _PantallaSerpienteState extends State<PantallaSerpiente>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_serpiente';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.serpiente);
  static const _respuestasPorRonda = 5;

  late final PartidaSerpiente _partida;
  Timer? _reloj;
  int _ronda = 1;
  bool _empezado = false;
  bool _terminada = false;
  bool _pausado = false;
  String? _lineaRexan;
  DateTime _inicioRonda = DateTime.now();

  @override
  void initState() {
    super.initState();
    final habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (habilidadesConRetoCalculo.contains(id)) id,
    ];
    _partida = PartidaSerpiente(
      habilidades: habilidades.isEmpty ? ['ARI.01'] : habilidades,
      dificultad: widget.dificultad,
      azar: math.Random(widget.semilla),
    );
    final periodo = widget.periodo ??
        Duration(
            milliseconds:
                switch (widget.dificultad) { 1 => 330, 2 => 290, _ => 250 });
    _reloj = Timer.periodic(periodo, (_) => _tic());
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _girar(Direccion direccion) {
    if (_terminada) return;
    setState(() {
      _partida.girar(direccion);
      _empezado = true;
    });
  }

  void _tic() {
    if (!mounted || !_empezado || _terminada || _pausado) return;
    final evento = _partida.avanzar();
    setState(() {
      switch (evento) {
        case EventoSerpiente.correcto:
          HapticFeedback.lightImpact();
          sonar('efecto_tap');
          anotarAcierto();
          _lineaRexan = null;
          if (_partida.correctosEnRonda >= _respuestasPorRonda) _cerrarRonda();
        case EventoSerpiente.incorrecto:
          HapticFeedback.vibrate();
          sonar('efecto_error');
          anotarFallo();
          _lineaRexan = 'Ese no era. Busca otro.';
        case EventoSerpiente.muro:
          HapticFeedback.lightImpact();
          _lineaRexan = 'Un muro. Gira y sigue.';
        case EventoSerpiente.nada:
          break;
      }
    });
  }

  void _cerrarRonda() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicioRonda);
    _partida.cerrarRonda().forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * widget.dificultad,
        duracion: duracion,
      );
    });
    _inicioRonda = DateTime.now();
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      _reloj?.cancel();
      return;
    }
    _ronda++;
    _partida.cambiarNivel(_ronda);
    _lineaRexan = _ronda == 2
        ? 'Cinco. Ahora hay muros: no hacen daño, pero hay que rodearlos.'
        : 'Cinco más. Los números ya no se están quietos.';
  }

  void _alDeslizar(DragEndDetails detalles) {
    final velocidad = detalles.velocity.pixelsPerSecond;
    if (velocidad.distance < 50) return;
    if (velocidad.dx.abs() > velocidad.dy.abs()) {
      _girar(velocidad.dx > 0 ? Direccion.derecha : Direccion.izquierda);
    } else {
      _girar(velocidad.dy > 0 ? Direccion.abajo : Direccion.arriba);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Tres rondas. La serpiente se enrosca y duerme.'
        : _lineaRexan ??
            (_empezado
                ? _definicion.lineaRexan
                : 'Lee la cuenta. Cuando quieras, elige una dirección.');
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.reto.idHabilidad,
      dificultadEjemplo: widget.dificultad,
      enunciadoActual: _partida.reto.enunciado,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: traducirNarrativa(linea, locale),
      terminada: _terminada,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_partida.reto.enunciado} = ?',
                  style: const TextStyle(
                    color: PaletaNeon.ambarCanales,
                    fontSize: 22,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${_partida.correctosEnRonda} / $_respuestasPorRonda',
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: PartidaSerpiente.columnas / PartidaSerpiente.filas,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanEnd: _alDeslizar,
                  child: RelojAmbiente(
                    periodo: const Duration(milliseconds: 1600),
                    builder: (_, fase) => CustomPaint(
                      size: Size.infinite,
                      painter: PintorSerpiente(partida: _partida, fase: fase),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CrucetaMinijuego(alPulsar: _girar),
        ],
      ),
    );
  }
}

class PintorSerpiente extends CustomPainter {
  final PartidaSerpiente partida;
  final Animation<double>? fase;

  PintorSerpiente({required this.partida, this.fase}) : super(repaint: fase);

  @override
  void paint(Canvas canvas, Size size) {
    final t = fase?.value ?? 0;
    final lado = size.width / PartidaSerpiente.columnas;
    Rect rectDe(Celda celda) =>
        Rect.fromLTWH(celda.columna * lado, celda.fila * lado, lado, lado);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      Paint()..color = PaletaNeon.fondoMedio.withOpacity(0.7),
    );
    final punto = Paint()..color = PaletaNeon.violetaBase.withOpacity(0.25);
    for (var f = 0; f < PartidaSerpiente.filas; f++) {
      for (var c = 0; c < PartidaSerpiente.columnas; c++) {
        canvas.drawCircle(rectDe(Celda(f, c)).center, 1.2, punto);
      }
    }

    // Muros: bloques de neón azul.
    for (final muro in partida.muros) {
      final rect = rectDe(muro).deflate(lado * 0.06);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.12)),
          Paint()..color = PaletaNeon.azulNeon.withOpacity(0.18));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.12)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = PaletaNeon.azulNeon.withOpacity(0.8),
      );
    }

    partida.numeros.forEach((celda, valor) {
      // Laten, cada uno a su ritmo.
      final latido = math.sin((t + (celda.fila + celda.columna) * 0.17) * math.pi * 2);
      final rect = rectDe(celda).deflate(lado * (0.08 - 0.035 * latido));
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(lado * 0.24)),
          Paint()
            ..color = PaletaNeon.violetaNeon.withOpacity(0.18 + 0.12 * latido)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.2)),
          Paint()..color = PaletaNeon.fondoProfundo);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = PaletaNeon.violetaNeon.withOpacity(0.7),
      );
      final texto = TextPainter(
        text: TextSpan(
          text: conSignoMenos(valor),
          style: TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: conSignoMenos(valor).length > 2 ? lado * 0.34 : lado * 0.42),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      texto.paint(canvas, rect.center - Offset(texto.width / 2, texto.height / 2));
    });

    // La serpiente: un cuerpo continuo de la cola a la cabeza, de ámbar
    // apagado a ámbar vivo, con escamas. Donde cruza un borde, se corta.
    final cuerpo = partida.cuerpo;
    final grosor = lado * 0.66;
    for (var i = cuerpo.length - 1; i > 0; i--) {
      final desde = cuerpo[i];
      final hasta = cuerpo[i - 1];
      final contiguas = (desde.fila - hasta.fila).abs() + (desde.columna - hasta.columna).abs() == 1;
      final tono = Color.lerp(PaletaNeon.ambarCanales,
          PaletaNeon.ambarCanales.withOpacity(0.45), i / cuerpo.length)!;
      final trazo = Paint()
        ..color = tono
        ..strokeWidth = grosor * (1 - 0.35 * i / cuerpo.length)
        ..strokeCap = StrokeCap.round;
      if (contiguas) {
        canvas.drawLine(rectDe(desde).center, rectDe(hasta).center, trazo);
      } else {
        canvas.drawCircle(rectDe(desde).center, trazo.strokeWidth / 2, trazo);
      }
    }
    // Escamas: pequeños arcos oscuros a lo largo del cuerpo.
    final escama = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF6B4A14).withOpacity(0.55);
    for (var i = 1; i < cuerpo.length; i++) {
      final centro = rectDe(cuerpo[i]).center;
      for (final dx in [-0.14, 0.14]) {
        canvas.drawArc(
            Rect.fromCircle(center: centro + Offset(dx * lado, 0), radius: lado * 0.12),
            0.3, 2.5, false, escama);
      }
    }
    canvas.drawCircle(rectDe(partida.cabeza).center, grosor * 0.62,
        Paint()..color = PaletaNeon.ambarCanales);
    final cabeza = rectDe(partida.cabeza);
    final ojo = Paint()..color = PaletaNeon.fondoProfundo;
    final lateral = Offset(partida.direccion.dFila.toDouble(),
            -partida.direccion.dColumna.toDouble()) *
        (lado * 0.18);
    final adelante = Offset(partida.direccion.dColumna.toDouble(),
            partida.direccion.dFila.toDouble()) *
        (lado * 0.12);
    for (final signo in [-1.0, 1.0]) {
      canvas.drawCircle(cabeza.center + adelante + lateral * signo, lado * 0.07, ojo);
    }
  }

  @override
  bool shouldRepaint(PintorSerpiente anterior) => true;
}
