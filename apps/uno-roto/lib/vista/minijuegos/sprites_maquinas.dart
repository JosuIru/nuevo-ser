import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Sprites de las máquinas (renders de flavor3d en `arte/sprites/`).
/// Se cargan una vez y quedan en memoria; mientras no están, los
/// pintores dibujan su forma sencilla de siempre.
class SpritesMaquinas {
  static final Map<String, ui.Image> _cargados = {};
  static final Map<String, Future<ui.Image?>> _enCurso = {};

  static ui.Image? ya(String nombre) => _cargados[nombre];

  static Future<ui.Image?> cargar(String nombre) =>
      _enCurso.putIfAbsent(nombre, () async {
        try {
          final datos = await rootBundle.load('assets/sprites/$nombre.png');
          final codec =
              await ui.instantiateImageCodec(datos.buffer.asUint8List());
          final imagen = (await codec.getNextFrame()).image;
          _cargados[nombre] = imagen;
          return imagen;
        } catch (_) {
          return null;
        }
      });
}

/// Dibuja [imagen] ajustada (sin deformar) dentro de [destino].
void pintarSprite(ui.Canvas canvas, ui.Image imagen, ui.Rect destino,
    {double opacidad = 1}) {
  final ancho = imagen.width.toDouble();
  final alto = imagen.height.toDouble();
  final escala = (destino.width / ancho) < (destino.height / alto)
      ? destino.width / ancho
      : destino.height / alto;
  final rect = ui.Rect.fromCenter(
      center: destino.center, width: ancho * escala, height: alto * escala);
  canvas.drawImageRect(
    imagen,
    ui.Rect.fromLTWH(0, 0, ancho, alto),
    rect,
    ui.Paint()
      ..filterQuality = ui.FilterQuality.medium
      ..color = ui.Color.fromRGBO(255, 255, 255, opacidad),
  );
}
