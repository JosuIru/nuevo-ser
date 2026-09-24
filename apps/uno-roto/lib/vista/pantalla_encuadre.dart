import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';

/// El taller de dibujo: antes de guardar, el niño ajusta qué parte de la
/// foto es su dibujo. Empieza con el encuadre que propone el juego;
/// se arrastran las esquinas para cambiar el tamaño y el recuadro para
/// moverlo. Devuelve el encuadre en fracciones de la foto (0 a 1), o
/// null si se cancela.
class PantallaEncuadre extends StatefulWidget {
  final Uint8List foto;

  /// El encuadre de partida; sin él, casi toda la foto.
  final Rect? sugerido;

  const PantallaEncuadre({super.key, required this.foto, this.sugerido});

  @override
  State<PantallaEncuadre> createState() => _PantallaEncuadreState();
}

enum _Agarre { ninguno, mover, arribaIzquierda, arribaDerecha, abajoIzquierda, abajoDerecha }

class _PantallaEncuadreState extends State<PantallaEncuadre> {
  ui.Image? _imagen;
  late Rect _encuadre = widget.sugerido ?? const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95);
  _Agarre _agarre = _Agarre.ninguno;

  /// Tamaño mínimo del encuadre, en fracción de la foto.
  static const _minimo = 0.08;

  @override
  void initState() {
    super.initState();
    _decodificar();
  }

  Future<void> _decodificar() async {
    final codec = await ui.instantiateImageCodec(widget.foto);
    final imagen = (await codec.getNextFrame()).image;
    if (mounted) setState(() => _imagen = imagen);
  }

  /// Dónde se dibuja la foto dentro de [lienzo] (ajustada sin deformar).
  Rect _zonaFoto(Size lienzo, ui.Image imagen) {
    final escala = (lienzo.width / imagen.width).clamp(0.0, lienzo.height / imagen.height);
    final ancho = imagen.width * escala;
    final alto = imagen.height * escala;
    return Rect.fromLTWH((lienzo.width - ancho) / 2, (lienzo.height - alto) / 2, ancho, alto);
  }

  Rect _enPantalla(Rect zona) => Rect.fromLTRB(
        zona.left + _encuadre.left * zona.width,
        zona.top + _encuadre.top * zona.height,
        zona.left + _encuadre.right * zona.width,
        zona.top + _encuadre.bottom * zona.height,
      );

  void _empezar(Offset punto, Rect zona) {
    final recuadro = _enPantalla(zona);
    const alcance = 36.0;
    final esquinas = {
      _Agarre.arribaIzquierda: recuadro.topLeft,
      _Agarre.arribaDerecha: recuadro.topRight,
      _Agarre.abajoIzquierda: recuadro.bottomLeft,
      _Agarre.abajoDerecha: recuadro.bottomRight,
    };
    for (final MapEntry(key: agarre, value: esquina) in esquinas.entries) {
      if ((punto - esquina).distance < alcance) {
        _agarre = agarre;
        return;
      }
    }
    _agarre = recuadro.contains(punto) ? _Agarre.mover : _Agarre.ninguno;
  }

  void _mover(Offset delta, Rect zona) {
    if (_agarre == _Agarre.ninguno) return;
    final dx = delta.dx / zona.width;
    final dy = delta.dy / zona.height;
    var r = _encuadre;
    switch (_agarre) {
      case _Agarre.mover:
        final x = (r.left + dx).clamp(0.0, 1 - r.width);
        final y = (r.top + dy).clamp(0.0, 1 - r.height);
        r = Rect.fromLTWH(x, y, r.width, r.height);
      case _Agarre.arribaIzquierda:
        r = Rect.fromLTRB((r.left + dx).clamp(0.0, r.right - _minimo), (r.top + dy).clamp(0.0, r.bottom - _minimo),
            r.right, r.bottom);
      case _Agarre.arribaDerecha:
        r = Rect.fromLTRB(r.left, (r.top + dy).clamp(0.0, r.bottom - _minimo),
            (r.right + dx).clamp(r.left + _minimo, 1.0), r.bottom);
      case _Agarre.abajoIzquierda:
        r = Rect.fromLTRB((r.left + dx).clamp(0.0, r.right - _minimo), r.top, r.right,
            (r.bottom + dy).clamp(r.top + _minimo, 1.0));
      case _Agarre.abajoDerecha:
        r = Rect.fromLTRB(r.left, r.top, (r.right + dx).clamp(r.left + _minimo, 1.0),
            (r.bottom + dy).clamp(r.top + _minimo, 1.0));
      case _Agarre.ninguno:
        break;
    }
    setState(() => _encuadre = r);
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final imagen = _imagen;
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          traducirNarrativa('Encuadre', locale).toUpperCase(),
          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.w300),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Text(
                traducirNarrativa(
                    'Ajusta el recuadro a tu dibujo: arrastra las esquinas para cambiarlo de tamaño y el centro para moverlo.',
                    locale),
                style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 14, height: 1.45),
              ),
            ),
            Expanded(
              child: imagen == null
                  ? const Center(child: CircularProgressIndicator(color: PaletaNeon.azulNeon))
                  : LayoutBuilder(builder: (_, limites) {
                      final zona = _zonaFoto(limites.biggest, imagen);
                      return GestureDetector(
                        key: const ValueKey('lienzo-encuadre'),
                        onPanStart: (d) => _empezar(d.localPosition, zona),
                        onPanUpdate: (d) => _mover(d.delta, zona),
                        onPanEnd: (_) => _agarre = _Agarre.ninguno,
                        child: CustomPaint(
                          size: limites.biggest,
                          painter: _PintorEncuadre(imagen: imagen, zona: zona, recuadro: _enPantalla(zona)),
                        ),
                      );
                    }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('encuadre-toda'),
                      onPressed: () => setState(() => _encuadre = const Rect.fromLTRB(0, 0, 1, 1)),
                      child: Text(traducirNarrativa('Toda la foto', locale)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('encuadre-usar'),
                      onPressed: imagen == null ? null : () => Navigator.of(contexto).pop(_encuadre),
                      child: Text(traducirNarrativa('Usar este encuadre', locale)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PintorEncuadre extends CustomPainter {
  final ui.Image imagen;
  final Rect zona;
  final Rect recuadro;

  _PintorEncuadre({required this.imagen, required this.zona, required this.recuadro});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      imagen,
      Rect.fromLTWH(0, 0, imagen.width.toDouble(), imagen.height.toDouble()),
      zona,
      Paint()..filterQuality = FilterQuality.medium,
    );
    // Lo que queda fuera, a oscuras.
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(zona), Path()..addRect(recuadro)),
      Paint()..color = Colors.black.withOpacity(0.6),
    );
    canvas.drawRect(
        recuadro,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = PaletaNeon.ambarCanales);
    for (final esquina in [recuadro.topLeft, recuadro.topRight, recuadro.bottomLeft, recuadro.bottomRight]) {
      canvas.drawCircle(esquina, 11, Paint()..color = PaletaNeon.ambarCanales);
      canvas.drawCircle(esquina, 5, Paint()..color = PaletaNeon.fondoProfundo);
    }
  }

  @override
  bool shouldRepaint(_PintorEncuadre anterior) => anterior.recuadro != recuadro || anterior.imagen != imagen;
}
