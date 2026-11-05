import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Curvas de nivel concéntricas y algo deformadas, de adorno en la
/// cabecera (como el plano de la presentación).
class CurvasDeNivel extends CustomPainter {
  CurvasDeNivel({
    required this.color,
    this.centroRelativo = const Offset(1.02, 0.5),
    this.separacion = 0.085,
  });

  /// Distancia entre anillos, en proporción al alto.
  final double separacion;

  /// Centro de los anillos, en proporción al tamaño (1,0 = borde derecho).
  final Offset centroRelativo;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final centro =
        Offset(size.width * centroRelativo.dx, size.height * centroRelativo.dy);
    for (var anillo = 1; anillo <= 14; anillo++) {
      final radio = anillo * size.height * separacion;
      final camino = Path();
      for (var paso = 0; paso <= 72; paso++) {
        final angulo = paso / 72 * 2 * math.pi;
        // Una ondulación suave que cambia con el anillo.
        final deformacion = 1 +
            0.10 * math.sin(3 * angulo + anillo * 0.4) +
            0.05 * math.cos(5 * angulo - anillo * 0.3);
        final punto = centro +
            Offset(math.cos(angulo) * radio * 1.25 * deformacion,
                math.sin(angulo) * radio * deformacion);
        paso == 0
            ? camino.moveTo(punto.dx, punto.dy)
            : camino.lineTo(punto.dx, punto.dy);
      }
      canvas.drawPath(camino, pincel);
    }
  }

  @override
  bool shouldRepaint(CurvasDeNivel viejo) => viejo.color != color;
}
