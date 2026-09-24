import 'dart:math';

import 'package:flutter/material.dart';

import '../../dominio/voz_personaje.dart';
import '../../nucleo/paleta_archivo.dart';
import '../../nucleo/pigmentos.dart';
import '../avatar_personaje.dart';
import '../pintura/trazo_a_mano.dart';

/// Objetos pintados del ático (doc 11 §1.1.9: la interfaz es objeto).
/// Todo CustomPainter con semilla: se dibujan siempre igual.

/// Fondo: tablero de la mesa visto desde arriba, con vetas y grano, y
/// la luz de la claraboya cayendo desde arriba.
class MesaDeMadera extends StatelessWidget {
  const MesaDeMadera({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _PintorMesa(), child: child);
  }
}

class _PintorMesa extends CustomPainter {
  const _PintorMesa();

  @override
  void paint(Canvas lienzo, Size tamano) {
    final rectangulo = Offset.zero & tamano;
    lienzo.drawRect(rectangulo, Paint()..color = Pigmentos.maderaMesa);
    final veta = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Pigmentos.tierraSombra.withValues(alpha: 0.35);
    final azar = Random(7);
    for (var y = 12.0; y < tamano.height; y += 18 + azar.nextDouble() * 22) {
      lienzo.drawPath(
        trazoAMano([Offset(-10, y), Offset(tamano.width + 10, y + azar.nextDouble() * 8 - 4)],
            semilla: y.round(), amplitud: 2.2),
        veta,
      );
    }
    pintarGrano(lienzo, rectangulo, color: Pigmentos.negroCarbon, semilla: 11, densidad: 0.9);
    // Claraboya: luz cálida arriba que se apaga hacia abajo.
    lienzo.drawRect(
      rectangulo,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Pigmentos.ocreAmarillo.withValues(alpha: 0.18),
            Colors.transparent,
            Pigmentos.negroCarbon.withValues(alpha: 0.35),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rectangulo),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Una hoja de papel de trapo con bordes rasgados y grano.
class HojaDePapel extends StatelessWidget {
  const HojaDePapel({
    super.key,
    required this.child,
    this.semilla = 0,
    this.ladosRasgados = const {LadoPapel.abajo},
    this.color = Pigmentos.papelTrapo,
    this.relleno = const EdgeInsets.fromLTRB(18, 16, 18, 20),
  });

  final Widget child;
  final int semilla;
  final Set<LadoPapel> ladosRasgados;
  final Color color;
  final EdgeInsets relleno;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PintorHoja(semilla: semilla, ladosRasgados: ladosRasgados, color: color),
      child: Padding(padding: relleno, child: child),
    );
  }
}

class _PintorHoja extends CustomPainter {
  const _PintorHoja({required this.semilla, required this.ladosRasgados, required this.color});

  final int semilla;
  final Set<LadoPapel> ladosRasgados;
  final Color color;

  @override
  void paint(Canvas lienzo, Size tamano) {
    final rectangulo = Offset.zero & tamano;
    final silueta = papelRasgado(rectangulo, ladosRasgados: ladosRasgados, semilla: semilla);
    lienzo.drawShadow(silueta, Pigmentos.negroCarbon, 3, false);
    lienzo.drawPath(silueta, Paint()..color = color);
    lienzo.save();
    lienzo.clipPath(silueta);
    pintarGrano(lienzo, rectangulo, color: Pigmentos.tierraSiena, semilla: semilla, densidad: 2.2);
    lienzo.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorHoja anterior) =>
      anterior.semilla != semilla || anterior.color != color;
}

/// Bandeja de mimbre vista desde arriba: borde grueso y trenzado.
class PintorBandejaMimbre extends CustomPainter {
  const PintorBandejaMimbre({required this.resaltada, this.semilla = 0});

  /// Resaltada cuando una tarjeta pasa por encima al arrastrar.
  final bool resaltada;
  final int semilla;

  @override
  void paint(Canvas lienzo, Size tamano) {
    final exterior = (Offset.zero & tamano).deflate(2);
    final interior = exterior.deflate(9);
    const mimbre = Pigmentos.ocreAmarillo;
    lienzo.drawPath(rectanguloAMano(exterior, semilla: semilla, amplitud: 1.5),
        Paint()..color = Color.lerp(mimbre, Pigmentos.tierraSiena, 0.35)!);
    // Trenzado: pequeñas eses alternas en el aro.
    final trenza = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Pigmentos.tierraSombra.withValues(alpha: 0.55);
    for (var x = exterior.left + 4; x < exterior.right - 4; x += 7) {
      lienzo.drawLine(Offset(x, exterior.top + 2), Offset(x + 4, interior.top - 1), trenza);
      lienzo.drawLine(Offset(x + 4, exterior.bottom - 2), Offset(x, interior.bottom + 1), trenza);
    }
    lienzo.drawPath(
        rectanguloAMano(interior, semilla: semilla + 1),
        Paint()
          ..color = resaltada
              ? Color.lerp(mimbre, PaletaArchivo.ambarLacre, 0.4)!.withValues(alpha: 0.9)
              : Color.lerp(mimbre, Pigmentos.tierraSombra, 0.25)!.withValues(alpha: 0.85));
    pintarGrano(lienzo, interior, color: Pigmentos.negroCarbon, semilla: semilla, densidad: 1.5);
  }

  @override
  bool shouldRepaint(covariant PintorBandejaMimbre anterior) =>
      anterior.resaltada != resaltada;
}

/// Balanza de latón de dos platillos. [inclinacion] en [-1, 1]:
/// negativo baja el platillo izquierdo (duda), positivo el derecho
/// (seguridad). Sin números: la balanza es la devolución.
class PintorBalanza extends CustomPainter {
  const PintorBalanza({required this.inclinacion});

  final double inclinacion;

  @override
  void paint(Canvas lienzo, Size tamano) {
    const laton = Pigmentos.oroDePan;
    const sombra = Pigmentos.tierraSombra;
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(laton, sombra, 0.25)!;
    final centroX = tamano.width / 2;
    final base = tamano.height - 8;
    final pivote = Offset(centroX, tamano.height * 0.28);
    // Pie y columna.
    trazo.strokeWidth = 5;
    lienzo.drawPath(trazoAMano([Offset(centroX - 40, base), Offset(centroX + 40, base)], semilla: 1), trazo);
    lienzo.drawPath(trazoAMano([Offset(centroX, base), pivote], semilla: 2, amplitud: 0.8), trazo);
    // Brazo inclinado (máximo 14°).
    final angulo = inclinacion.clamp(-1.0, 1.0) * 14 * pi / 180;
    final semibrazo = tamano.width * 0.36;
    final extremoIzquierdo = pivote + Offset(-cos(angulo), -sin(angulo)) * semibrazo;
    final extremoDerecho = pivote + Offset(cos(angulo), sin(angulo)) * semibrazo;
    trazo.strokeWidth = 4;
    lienzo.drawPath(trazoAMano([extremoIzquierdo, extremoDerecho], semilla: 3, amplitud: 0.8), trazo);
    lienzo.drawCircle(pivote, 5, Paint()..color = laton);
    // Platillos colgando.
    trazo.strokeWidth = 1.2;
    for (final extremo in [extremoIzquierdo, extremoDerecho]) {
      final platillo = extremo + Offset(0, tamano.height * 0.34);
      lienzo.drawLine(extremo, platillo + const Offset(-22, 0), trazo);
      lienzo.drawLine(extremo, platillo + const Offset(22, 0), trazo);
      final cuenco = Path()
        ..moveTo(platillo.dx - 28, platillo.dy)
        ..quadraticBezierTo(platillo.dx, platillo.dy + 18, platillo.dx + 28, platillo.dy)
        ..close();
      lienzo.drawPath(cuenco, Paint()..color = laton.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant PintorBalanza anterior) => anterior.inclinacion != inclinacion;
}

/// Andrés hablando: retrato y la frase, en tinta sobre papel.
class LineaDeAndres extends StatelessWidget {
  const LineaDeAndres({super.key, required this.texto, this.semilla = 0});

  final String texto;
  final int semilla;

  @override
  Widget build(BuildContext context) {
    return HojaDePapel(
      semilla: semilla,
      ladosRasgados: const {LadoPapel.derecha},
      relleno: const EdgeInsets.fromLTRB(12, 12, 18, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AvatarPersonaje(voz: VozPersonaje.andres, tamano: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                  color: PaletaArchivo.tintaNegra, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
