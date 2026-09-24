import 'package:flutter/material.dart';

import '../nucleo/paleta.dart';
import 'personajes/retratos.dart' show DibujoOPersonaje;

/// Presencia de Sora: avatar en silueta en la esquina inferior izquierda
/// con un bocadillo que aparece cuando tiene algo que decir.
class SoraPresencia extends StatelessWidget {
  final String? textoActivo;
  final VoidCallback? alTocarBocadillo;

  const SoraPresencia({
    super.key,
    required this.textoActivo,
    this.alTocarBocadillo,
  });

  @override
  Widget build(BuildContext contexto) {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 16,
            bottom: 0,
            child: _AvatarSora(),
          ),
          if (textoActivo != null)
            Positioned(
              left: 96,
              right: 16,
              bottom: 30,
              child: _BocadilloSora(
                texto: textoActivo!,
                alTocar: alTocarBocadillo,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarSora extends StatelessWidget {
  const _AvatarSora();

  @override
  Widget build(BuildContext contexto) {
    // Su retrato (provisional) en un círculo al pie del lienzo de 70×90;
    // si el asset no carga, la silueta clásica.
    return SizedBox(
      width: 70,
      height: 90,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: DibujoOPersonaje(
          id: 'sora',
          color: PaletaNeon.violetaNeon,
          ancho: 70,
          alto: 70,
          original: SizedBox(
            width: 70,
            height: 70,
            child: Image.asset(
              'assets/personajes/retratos/sora.webp',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => CustomPaint(
                size: const Size(70, 90),
                painter: _PintorSilueta(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorSilueta extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinturaSilueta = Paint()..color = const Color(0xFF0F0826);
    final pinturaContorno = Paint()
      ..color = PaletaNeon.violetaNeon.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pinturaMostaza = Paint()
      ..color = const Color(0xFFB89A4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Cabeza + mechón asimétrico: círculo con una prolongación superior.
    final centroCabeza = Offset(size.width / 2, size.height * 0.28);
    final radioCabeza = size.width * 0.22;
    final trazoCabeza = Path()
      ..addOval(Rect.fromCircle(center: centroCabeza, radius: radioCabeza))
      ..moveTo(centroCabeza.dx - radioCabeza * 0.7,
          centroCabeza.dy - radioCabeza * 0.4)
      ..lineTo(centroCabeza.dx - radioCabeza * 1.1,
          centroCabeza.dy + radioCabeza * 0.2)
      ..lineTo(centroCabeza.dx - radioCabeza * 0.3,
          centroCabeza.dy - radioCabeza * 0.8);

    canvas.drawPath(trazoCabeza, pinturaSilueta);
    canvas.drawCircle(centroCabeza, radioCabeza, pinturaContorno);

    // Cuerpo: cazadora hasta mitad de lienzo.
    final rectCazadora = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.42,
      size.width * 0.5,
      size.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectCazadora, const Radius.circular(6)),
      pinturaSilueta,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectCazadora, const Radius.circular(6)),
      pinturaContorno,
    );

    // Cremallera y ribete mostaza.
    canvas.drawLine(
      Offset(rectCazadora.center.dx, rectCazadora.top + 6),
      Offset(rectCazadora.center.dx, rectCazadora.bottom - 6),
      pinturaMostaza,
    );
    canvas.drawLine(
      Offset(rectCazadora.left + 4, rectCazadora.top + 4),
      Offset(rectCazadora.right - 4, rectCazadora.top + 4),
      pinturaMostaza,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorSilueta oldDelegate) => false;
}

class _BocadilloSora extends StatelessWidget {
  final String texto;
  final VoidCallback? alTocar;

  const _BocadilloSora({required this.texto, this.alTocar});

  @override
  Widget build(BuildContext contexto) {
    return GestureDetector(
      onTap: alTocar,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (hijo, animacion) => FadeTransition(
          opacity: animacion,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.05, 0),
              end: Offset.zero,
            ).animate(animacion),
            child: hijo,
          ),
        ),
        child: Container(
          key: ValueKey(texto),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoProfundo.withOpacity(0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: PaletaNeon.violetaNeon.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PaletaNeon.violetaNeon.withOpacity(0.25),
                blurRadius: 14,
              ),
            ],
          ),
          child: Text(
            texto,
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
