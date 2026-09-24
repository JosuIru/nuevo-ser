import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Un dibujo del niño (El taller de dibujo) con un halo neón de [color]
/// que sigue su silueta: así encaja en el mundo sin tapar su trazo.
/// Sin [tamano], ocupa el cuadrado más grande que quepa.
class DibujoConHalo extends StatelessWidget {
  final String ruta;
  final Color color;
  final double? tamano;

  const DibujoConHalo({super.key, required this.ruta, required this.color, this.tamano});

  @override
  Widget build(BuildContext contexto) {
    final tamanoFijo = tamano;
    if (tamanoFijo != null) return _dibujo(tamanoFijo);
    return LayoutBuilder(builder: (_, limites) {
      final lado = limites.biggest.shortestSide;
      return Center(child: _dibujo(lado.isFinite ? lado : 120));
    });
  }

  Widget _dibujo(double lado) {
    final fichero = File(ruta);
    return SizedBox.square(
      dimension: lado,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(color.withOpacity(0.9), BlendMode.srcIn),
              child: Image.file(fichero, width: lado, height: lado, fit: BoxFit.contain, gaplessPlayback: true),
            ),
          ),
          Image.file(fichero, width: lado * 0.9, height: lado * 0.9, fit: BoxFit.contain, gaplessPlayback: true),
        ],
      ),
    );
  }
}
