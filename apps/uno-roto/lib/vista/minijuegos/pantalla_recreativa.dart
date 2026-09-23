import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../nucleo/paleta.dart';

/// Lo que una máquina le cuenta a su pantalla para que reaccione.
enum EfectoPantalla { acierto, fallo }

/// Aviso de efecto: el contador distingue dos aciertos seguidos.
typedef AvisoEfecto = ({EfectoPantalla efecto, int numero});

/// Color del cartel de cada máquina (el de su arte en la sala de Rexán).
const coloresDeMaquina = <String, Color>{
  'Puentes': Color(0xFFE0824E),
  'Encaje': Color(0xFFE3A457),
  'Canales': Color(0xFFD9C08E),
  'Parejas': Color(0xFFD9848C),
  'Minas': Color(0xFFB9744E),
  'Serpiente': Color(0xFF9CCBA8),
  'Balanza': Color(0xFF8F8CD6),
  'La flota': Color(0xFF3F74D8),
  'Salto': Color(0xFFD65A48),
};

/// La pantalla de una máquina recreativa alrededor del juego: marco
/// luminoso del color de la máquina, fondo animado lento (rejilla en
/// perspectiva y motas), barrido CRT suave y viñeteado. Reacciona a los
/// avisos: chispas al acertar, sacudida y parpadeo rosa al fallar, y un
/// barrido de luz al cambiar de ronda.
class PantallaRecreativa extends StatefulWidget {
  /// Apagado en los tests: una animación en bucle no deja que
  /// `pumpAndSettle` termine nunca.
  static bool animacionAmbiente = true;

  final Color color;
  final int ronda;
  final ValueListenable<AvisoEfecto?>? efectos;
  final Widget child;

  const PantallaRecreativa({
    super.key,
    required this.color,
    required this.ronda,
    required this.child,
    this.efectos,
  });

  @override
  State<PantallaRecreativa> createState() => _PantallaRecreativaState();
}

class _PantallaRecreativaState extends State<PantallaRecreativa>
    with TickerProviderStateMixin {
  late final AnimationController _ambiente = AnimationController(
      vsync: this, duration: const Duration(seconds: 24));
  late final AnimationController _chispas = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _sacudida = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final AnimationController _barrido = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  int _semillaChispas = 0;

  @override
  void initState() {
    super.initState();
    if (PantallaRecreativa.animacionAmbiente) _ambiente.repeat();
    widget.efectos?.addListener(_alAviso);
  }

  @override
  void didUpdateWidget(PantallaRecreativa anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.efectos != widget.efectos) {
      anterior.efectos?.removeListener(_alAviso);
      widget.efectos?.addListener(_alAviso);
    }
    if (widget.ronda != anterior.ronda) _barrido.forward(from: 0);
  }

  @override
  void dispose() {
    widget.efectos?.removeListener(_alAviso);
    _ambiente.dispose();
    _chispas.dispose();
    _sacudida.dispose();
    _barrido.dispose();
    super.dispose();
  }

  void _alAviso() {
    final aviso = widget.efectos?.value;
    if (aviso == null) return;
    switch (aviso.efecto) {
      case EfectoPantalla.acierto:
        _semillaChispas = aviso.numero;
        _chispas.forward(from: 0);
      case EfectoPantalla.fallo:
        _sacudida.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final color = widget.color;
    return AnimatedBuilder(
      animation: Listenable.merge([_sacudida, _chispas]),
      builder: (_, hijo) {
        final t = _sacudida.value;
        final desplazamiento = t == 0 || t == 1
            ? 0.0
            : math.sin(t * math.pi * 7) * 7 * (1 - t);
        final brillo = _chispas.isAnimating ? 1 - _chispas.value : 0.0;
        return Transform.translate(
          offset: Offset(desplazamiento, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Color.lerp(color.withOpacity(0.45), color, brillo)!,
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.18 + 0.3 * brillo),
                  blurRadius: 18 + 14 * brillo,
                ),
              ],
            ),
            child: hijo,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: _PintorFondoRecreativa(animacion: _ambiente, color: color),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: widget.child,
            ),
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _PintorCristal(color: color)),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _PintorEfectos(
                  chispas: _chispas,
                  sacudida: _sacudida,
                  barrido: _barrido,
                  color: color,
                  semilla: () => _semillaChispas,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rejilla en perspectiva que avanza despacio hacia quien mira y motas
/// que suben: ambiente, nunca protagonista.
class _PintorFondoRecreativa extends CustomPainter {
  final Animation<double> animacion;
  final Color color;

  _PintorFondoRecreativa({required this.animacion, required this.color})
      : super(repaint: animacion);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaNeon.fondoProfundo,
            Color.lerp(PaletaNeon.fondoProfundo, color, 0.10)!,
          ],
        ).createShader(rect),
    );

    // Rejilla del suelo: horizonte al 55 %, líneas que se acercan.
    final horizonte = size.height * 0.55;
    final linea = Paint()
      ..color = color.withOpacity(0.10)
      ..strokeWidth = 1;
    final avance = (animacion.value * 6) % 1;
    for (var i = 0; i < 9; i++) {
      final z = (i + avance) / 9; // 0 lejos, 1 cerca
      final y = horizonte + (size.height - horizonte) * z * z;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linea);
    }
    final centro = size.width / 2;
    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(Offset(centro + i * size.width * 0.04, horizonte),
          Offset(centro + i * size.width * 0.32, size.height), linea);
    }

    // Motas que suben y se apagan arriba.
    final mota = Paint();
    for (var i = 0; i < 18; i++) {
      final azar = math.Random(i * 31 + 5);
      final fase = (animacion.value * (0.6 + azar.nextDouble()) + azar.nextDouble()) % 1;
      final x = azar.nextDouble() * size.width +
          math.sin((fase + i) * math.pi * 2) * 6;
      final y = size.height * (1 - fase);
      mota.color = color.withOpacity(0.25 * math.sin(fase * math.pi));
      canvas.drawCircle(Offset(x, y), 1 + azar.nextDouble() * 1.5, mota);
    }
  }

  @override
  bool shouldRepaint(_PintorFondoRecreativa anterior) => anterior.color != color;
}

/// El cristal de la pantalla: líneas de barrido muy suaves y viñeteado.
class _PintorCristal extends CustomPainter {
  final Color color;

  _PintorCristal({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final barrido = Paint()..color = Colors.black.withOpacity(0.10);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), barrido);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
          stops: const [0.65, 1],
        ).createShader(rect),
    );
    // Reflejo diagonal en el cristal.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.2, 0.2),
          colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_PintorCristal anterior) => anterior.color != color;
}

/// Chispas desde el centro al acertar, parpadeo rosa al fallar y barrido
/// de luz de arriba abajo al cambiar de ronda.
class _PintorEfectos extends CustomPainter {
  final Animation<double> chispas;
  final Animation<double> sacudida;
  final Animation<double> barrido;
  final Color color;
  final int Function() semilla;

  _PintorEfectos({
    required this.chispas,
    required this.sacudida,
    required this.barrido,
    required this.color,
    required this.semilla,
  }) : super(repaint: Listenable.merge([chispas, sacudida, barrido]));

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (sacudida.isAnimating) {
      canvas.drawRect(rect,
          Paint()..color = PaletaNeon.rosaAcento.withOpacity(0.16 * (1 - sacudida.value)));
    }
    if (barrido.isAnimating) {
      final y = size.height * barrido.value;
      canvas.drawRect(
        Rect.fromLTWH(0, y - 60, size.width, 60),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, color.withOpacity(0.28)],
          ).createShader(Rect.fromLTWH(0, y - 60, size.width, 60)),
      );
    }
    if (chispas.isAnimating) {
      final t = Curves.easeOutCubic.transform(chispas.value);
      final azar = math.Random(semilla());
      final centro = Offset(size.width * (0.35 + 0.3 * azar.nextDouble()),
          size.height * (0.35 + 0.3 * azar.nextDouble()));
      final chispa = Paint()..strokeCap = StrokeCap.round;
      for (var i = 0; i < 16; i++) {
        final angulo = azar.nextDouble() * math.pi * 2;
        final distancia = (40 + azar.nextDouble() * 70) * t;
        final direccion = Offset(math.cos(angulo), math.sin(angulo));
        final punta = centro + direccion * distancia;
        chispa
          ..color = (i.isEven ? color : PaletaNeon.ambarCanales).withOpacity(1 - chispas.value)
          ..strokeWidth = 2.2 * (1 - chispas.value) + 0.6;
        canvas.drawLine(punta - direccion * 8, punta, chispa);
      }
    }
  }

  @override
  bool shouldRepaint(_PintorEfectos anterior) => false;
}

/// Reloj de ambiente para los dibujos de cada máquina (olas, agua,
/// latidos): da una fase 0→1 que se repite. Parado en los tests, como el
/// fondo de la pantalla.
class RelojAmbiente extends StatefulWidget {
  final Duration periodo;
  final Widget Function(BuildContext contexto, Animation<double> fase) builder;

  const RelojAmbiente({
    super.key,
    this.periodo = const Duration(seconds: 4),
    required this.builder,
  });

  @override
  State<RelojAmbiente> createState() => _RelojAmbienteState();
}

class _RelojAmbienteState extends State<RelojAmbiente>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fase =
      AnimationController(vsync: this, duration: widget.periodo);

  @override
  void initState() {
    super.initState();
    if (PantallaRecreativa.animacionAmbiente) _fase.repeat();
  }

  @override
  void dispose() {
    _fase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) => widget.builder(contexto, _fase);
}
