import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../datos/dibujos_monstruos.dart';
import '../../dominio/bestiario.dart';
import 'pantalla_recreativa.dart';

/// El monstruo de cada máquina (su familia del bestiario), pequeño y
/// junto a la línea de Rexán. Respira mientras se juega; al fallar,
/// crece y se ríe; al acertar, se encoge y se aparta. No estorba al
/// juego ni lo decide: está ahí para que se vea contra quién se juega.
enum FamiliaMonstruo {
  oxidados,
  signos,
  destellos,
  maleza,
  azarosos,
  oleaje,
  destenidos,
  cambiados,
  mudos,
  polillas,
  revisores,
  vertigos,
  fugas,
  impropios,
  comparadores,
}

/// El monstruo de cada máquina, por su nombre en el catálogo.
const monstruoDeMaquina = <String, FamiliaMonstruo>{
  'Engranajes': FamiliaMonstruo.oxidados,
  'El pozo': FamiliaMonstruo.signos,
  'Rebote': FamiliaMonstruo.destellos,
  'Planos': FamiliaMonstruo.maleza,
  'Las redes': FamiliaMonstruo.azarosos,
  'Nivelar': FamiliaMonstruo.oleaje,
  'Pinturas': FamiliaMonstruo.destenidos,
  'El taller del relojero': FamiliaMonstruo.cambiados,
  'La caja negra': FamiliaMonstruo.mudos,
  'El telar': FamiliaMonstruo.polillas,
  'El tranvía': FamiliaMonstruo.revisores,
  'Andamios': FamiliaMonstruo.vertigos,
  'Depósitos': FamiliaMonstruo.fugas,
  'La hornada': FamiliaMonstruo.impropios,
  'Esclusas': FamiliaMonstruo.comparadores,
};

/// El color del aura de la familia en el bestiario (el mismo en todas
/// partes, para que se reconozca).
Color colorDeMonstruo(FamiliaMonstruo familia) {
  for (final ficha in CatalogoBestiario.todas) {
    if (ficha.id == familia.name) return ficha.colorAura;
  }
  return const Color(0xFFA67EC8);
}

enum _Reaccion { ninguna, seRie, seEncoge }

class MonstruoMaquina extends StatefulWidget {
  final FamiliaMonstruo familia;
  final ValueListenable<AvisoEfecto?>? efectos;
  final double tamano;

  const MonstruoMaquina({super.key, required this.familia, this.efectos, this.tamano = 52});

  @override
  State<MonstruoMaquina> createState() => _MonstruoMaquinaState();
}

class _MonstruoMaquinaState extends State<MonstruoMaquina> with TickerProviderStateMixin {
  late final AnimationController _respiro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _reaccion =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  _Reaccion _tipo = _Reaccion.ninguna;

  @override
  void initState() {
    super.initState();
    if (PantallaRecreativa.animacionAmbiente) _respiro.repeat();
    widget.efectos?.addListener(_alAviso);
  }

  @override
  void didUpdateWidget(MonstruoMaquina anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.efectos != widget.efectos) {
      anterior.efectos?.removeListener(_alAviso);
      widget.efectos?.addListener(_alAviso);
    }
  }

  @override
  void dispose() {
    widget.efectos?.removeListener(_alAviso);
    _respiro.dispose();
    _reaccion.dispose();
    super.dispose();
  }

  void _alAviso() {
    final aviso = widget.efectos?.value;
    if (aviso == null || !mounted) return;
    setState(() {
      _tipo = aviso.efecto == EfectoPantalla.fallo ? _Reaccion.seRie : _Reaccion.seEncoge;
    });
    _reaccion.forward(from: 0);
  }

  @override
  Widget build(BuildContext contexto) => IgnorePointer(
        child: SizedBox.square(
          dimension: widget.tamano,
          child: ValueListenableBuilder<Map<String, String>>(
            valueListenable: DibujosMonstruos.rutas,
            builder: (_, dibujos, __) {
              final dibujo = dibujos[widget.familia.name];
              return AnimatedBuilder(
                animation: Listenable.merge([_respiro, _reaccion]),
                builder: (_, __) {
                  final risa = _tipo == _Reaccion.seRie ? _reaccion.value : 0.0;
                  final derrota = _tipo == _Reaccion.seEncoge ? _reaccion.value : 0.0;
                  if (dibujo == null) {
                    return CustomPaint(
                      painter: PintorMonstruo(
                          familia: widget.familia, respiro: _respiro.value, risa: risa, derrota: derrota),
                    );
                  }
                  // El dibujo del niño, con los mismos gestos que el original.
                  final gesto = gestoMonstruo(_respiro.value, risa, derrota);
                  return Transform.translate(
                    offset: Offset(0, gesto.desplazamiento),
                    child: Transform.rotate(
                      angle: gesto.giro,
                      child: Transform.scale(
                        scale: gesto.escala,
                        child: Opacity(
                          opacity: gesto.opacidad,
                          child: DibujoMonstruo(
                            key: const ValueKey('dibujo-monstruo'),
                            ruta: dibujo,
                            color: colorDeMonstruo(widget.familia),
                            tamano: widget.tamano,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
}

/// Los gestos del monstruo (dibujado o no): cuánto crece, bota, gira y
/// se apaga según respira, se ríe o se encoge.
({double escala, double desplazamiento, double giro, double opacidad}) gestoMonstruo(
    double respiro, double risa, double derrota) {
  final ciclo = math.sin(respiro * 2 * math.pi);
  final campanaRisa = math.sin(risa * math.pi);
  final campanaDerrota = math.sin(derrota * math.pi);
  return (
    escala: 1 + 0.03 * ciclo + 0.18 * campanaRisa - 0.4 * campanaDerrota,
    desplazamiento: 2 * ciclo - 6 * math.sin(risa * math.pi * 3).abs() * (1 - risa),
    // El dibujo se balancea un poco al reírse, como si se burlara.
    giro: 0.15 * math.sin(risa * math.pi * 4) * (1 - risa),
    opacidad: 1 - 0.6 * campanaDerrota,
  );
}

/// El dibujo del niño con un halo neón del color de su familia, que
/// sigue la silueta: así encaja en el mundo sin tapar su trazo.
class DibujoMonstruo extends StatelessWidget {
  final String ruta;
  final Color color;
  final double tamano;

  const DibujoMonstruo({super.key, required this.ruta, required this.color, required this.tamano});

  @override
  Widget build(BuildContext contexto) {
    final fichero = File(ruta);
    return SizedBox.square(
      dimension: tamano,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(color.withOpacity(0.9), BlendMode.srcIn),
              child: Image.file(fichero, width: tamano, height: tamano, fit: BoxFit.contain, gaplessPlayback: true),
            ),
          ),
          Image.file(fichero, width: tamano * 0.9, height: tamano * 0.9, fit: BoxFit.contain, gaplessPlayback: true),
        ],
      ),
    );
  }
}

/// Dibuja el monstruo en un cuadro. [respiro] (0→1, en bucle) lo mueve
/// despacio; [risa] (0→1) es la reacción a un fallo: crece, bota y
/// entorna los ojos; [derrota] (0→1), a un acierto: se encoge, se
/// apaga y vuelve.
class PintorMonstruo extends CustomPainter {
  final FamiliaMonstruo familia;
  final double respiro;
  final double risa;
  final double derrota;

  PintorMonstruo({required this.familia, this.respiro = 0, this.risa = 0, this.derrota = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final color = colorDeMonstruo(familia);
    final ciclo = math.sin(respiro * 2 * math.pi);
    // Reacciones: suben y bajan en su duración (campana).
    final campanaRisa = math.sin(risa * math.pi);
    final campanaDerrota = math.sin(derrota * math.pi);
    final escala = 1 + 0.03 * ciclo + 0.18 * campanaRisa - 0.4 * campanaDerrota;
    final bote = -6 * math.sin(risa * math.pi * 3).abs() * (1 - risa);
    final opacidad = 1 - 0.6 * campanaDerrota;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 2 * ciclo + bote);
    canvas.scale(escala * size.width / 52);
    // Halo del color de la familia.
    canvas.drawCircle(Offset.zero, 24,
        Paint()
          ..color = color.withOpacity(0.18 * opacidad)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    final cuerpo = Paint()..color = color.withOpacity(opacidad);
    final oscuro = Paint()..color = Color.lerp(color, Colors.black, 0.45)!.withOpacity(opacidad);
    final linea = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(opacidad);
    var ojos = const Offset(0, -2);
    var separacion = 5.0;

    switch (familia) {
      case FamiliaMonstruo.oxidados:
        // Rueda dentada roída, girando despacio.
        canvas.save();
        canvas.rotate(respiro * 2 * math.pi / 6);
        for (var i = 0; i < 8; i++) {
          if (i == 2 || i == 5) continue; // dientes que se ha comido
          final a = i * math.pi / 4;
          canvas.drawRect(Rect.fromCenter(center: Offset(math.cos(a), math.sin(a)) * 15, width: 6, height: 6), oscuro);
        }
        canvas.restore();
        canvas.drawCircle(Offset.zero, 14, cuerpo);
        canvas.drawCircle(const Offset(6, 6), 3, oscuro);
      case FamiliaMonstruo.signos:
        // Un signo menos con alas de murciélago.
        final aleteo = 4 * ciclo;
        for (final lado in [-1.0, 1.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(lado * 9, 0)
                ..quadraticBezierTo(lado * 20, -12 - aleteo, lado * 24, 2)
                ..quadraticBezierTo(lado * 17, -2, lado * 14, 6)
                ..close(),
              oscuro);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 22, height: 14), const Radius.circular(7)), cuerpo);
        ojos = const Offset(0, -1);
        separacion = 4.5;
      case FamiliaMonstruo.destellos:
        // Chispa de cuatro puntas que late.
        final punta = 20 + 3 * ciclo;
        final estrella = Path();
        for (var i = 0; i < 8; i++) {
          final r = i.isEven ? punta : 7.0;
          final a = i * math.pi / 4 - math.pi / 2;
          final p = Offset(math.cos(a), math.sin(a)) * r;
          i == 0 ? estrella.moveTo(p.dx, p.dy) : estrella.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(estrella..close(), cuerpo);
        separacion = 4;
      case FamiliaMonstruo.maleza:
        // Mata de hierba con ojos.
        for (var i = -2; i <= 2; i++) {
          final vaiven = 2 * math.sin(respiro * 2 * math.pi + i);
          canvas.drawLine(Offset(i * 5.0, 14), Offset(i * 7.0 + vaiven, -12 - (2 - i.abs()) * 4.0),
              linea..strokeWidth = 3.5);
        }
        canvas.drawOval(Rect.fromCenter(center: const Offset(0, 8), width: 30, height: 14), cuerpo);
        ojos = const Offset(0, 7);
      case FamiliaMonstruo.azarosos:
        // Pez que cambia de color al saltar.
        final tinte = HSVColor.fromColor(color).withHue((HSVColor.fromColor(color).hue + 120 * respiro) % 360).toColor();
        final pez = Paint()..color = tinte.withOpacity(opacidad);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 32, height: 20), pez);
        canvas.drawPath(
            Path()
              ..moveTo(14, 0)
              ..lineTo(24, -9 + 2 * ciclo)
              ..lineTo(24, 9 - 2 * ciclo)
              ..close(),
            pez);
        ojos = const Offset(-6, -2);
        separacion = 3.5;
      case FamiliaMonstruo.oleaje:
        // Una ola que se riza.
        final ola = Path()
          ..moveTo(-22, 14)
          ..quadraticBezierTo(-18, -14, 6, -14)
          ..quadraticBezierTo(22, -14, 18, 0)
          ..quadraticBezierTo(8, -6, 6, 4)
          ..quadraticBezierTo(4, 14, 22, 14)
          ..close();
        canvas.save();
        canvas.translate(2 * ciclo, 0);
        canvas.drawPath(ola, cuerpo);
        canvas.restore();
        ojos = const Offset(-6, -3);
        separacion = 4;
      case FamiliaMonstruo.destenidos:
        // Mancha gris que se come el color: borde irregular.
        final mancha = Path();
        for (var i = 0; i <= 12; i++) {
          final a = i * math.pi / 6;
          final r = 16 + 3 * math.sin(i * 2.3 + respiro * 2 * math.pi);
          final p = Offset(math.cos(a), math.sin(a)) * r;
          i == 0 ? mancha.moveTo(p.dx, p.dy) : mancha.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(mancha..close(), Paint()..color = const Color(0xFF8A8A92).withOpacity(opacidad));
        canvas.drawCircle(const Offset(10, 9), 5, cuerpo);
      case FamiliaMonstruo.cambiados:
        // Una pesa con la etiqueta cambiada.
        canvas.drawPath(
            Path()
              ..moveTo(-16, 16)
              ..lineTo(16, 16)
              ..lineTo(11, -8)
              ..lineTo(-11, -8)
              ..close(),
            cuerpo);
        canvas.drawCircle(const Offset(0, -12), 5, linea..strokeWidth = 2.5);
        _rotulo(canvas, respiro < 0.5 ? 'g' : 'kg', const Offset(0, 9), oscuro.color);
        ojos = const Offset(0, 0);
        separacion = 4.5;
      case FamiliaMonstruo.mudos:
        // Una caja negra con la boca cosida.
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 30, height: 28), const Radius.circular(5)),
            Paint()..color = const Color(0xFF1A1630).withOpacity(opacidad));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 30, height: 28), const Radius.circular(5)),
            linea..strokeWidth = 1.5);
        final boca = Paint()
          ..color = color.withOpacity(opacidad)
          ..strokeWidth = 1.5;
        canvas.drawLine(const Offset(-7, 7), const Offset(7, 7), boca);
        for (var x = -5.0; x <= 5; x += 3.3) {
          canvas.drawLine(Offset(x, 4.5), Offset(x, 9.5), boca);
        }
      case FamiliaMonstruo.polillas:
        // Polilla que bate las alas.
        final apertura = 0.7 + 0.3 * ciclo.abs();
        for (final lado in [-1.0, 1.0]) {
          canvas.save();
          canvas.scale(lado * apertura, 1);
          canvas.drawOval(Rect.fromLTWH(2, -16, 18, 18), cuerpo);
          canvas.drawOval(Rect.fromLTWH(2, 0, 13, 13), oscuro);
          canvas.restore();
        }
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 7, height: 24), oscuro);
        ojos = const Offset(0, -8);
        separacion = 2.5;
      case FamiliaMonstruo.revisores:
        // Gorra de revisor y gafas redondas.
        canvas.drawCircle(const Offset(0, 4), 15, cuerpo);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, -11), width: 32, height: 9), const Radius.circular(3)), oscuro);
        canvas.drawRect(Rect.fromCenter(center: const Offset(4, -6), width: 22, height: 3), oscuro);
        for (final x in [-5.5, 5.5]) {
          canvas.drawCircle(Offset(x, 1), 4.5, Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.white.withOpacity(0.9 * opacidad));
        }
        ojos = const Offset(0, 1);
        separacion = 5.5;
      case FamiliaMonstruo.vertigos:
        // Remolino de viento.
        final remolino = Path();
        for (var i = 0; i <= 40; i++) {
          final t = i / 40;
          final a = t * 4 * math.pi + respiro * 2 * math.pi;
          final p = Offset(math.cos(a), math.sin(a)) * (4 + 16 * t);
          i == 0 ? remolino.moveTo(p.dx, p.dy) : remolino.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(remolino, linea..strokeWidth = 3);
        canvas.drawCircle(Offset.zero, 8, cuerpo);
        separacion = 3.5;
        ojos = Offset.zero;
      case FamiliaMonstruo.fugas:
        // Una gota con ojos.
        canvas.drawPath(
            Path()
              ..moveTo(0, -20)
              ..quadraticBezierTo(16, 2, 13, 8)
              ..arcToPoint(const Offset(-13, 8), radius: const Radius.circular(13))
              ..quadraticBezierTo(-16, 2, 0, -20)
              ..close(),
            cuerpo);
        ojos = const Offset(0, 4);
      case FamiliaMonstruo.impropios:
        // Un pan que no cabe en sí: círculo con un bulto de más.
        canvas.drawCircle(const Offset(-3, 2), 15, cuerpo);
        canvas.drawCircle(Offset(11 + ciclo, -6), 8, cuerpo);
        canvas.drawLine(const Offset(-3, -13), const Offset(-3, 17), Paint()
          ..color = oscuro.color
          ..strokeWidth = 1.5);
        ojos = const Offset(-3, 0);
      case FamiliaMonstruo.comparadores:
        // Dos que se miran, uno más alto que otro.
        canvas.drawCircle(Offset(-9, 4 - 2 * ciclo), 9, cuerpo);
        canvas.drawCircle(Offset(10, -2 + 2 * ciclo), 12, oscuro);
        _ojos(canvas, Offset(-9, 3 - 2 * ciclo), 3, opacidad);
        ojos = Offset(10, -3 + 2 * ciclo);
        separacion = 4;
    }
    _ojos(canvas, ojos, separacion, opacidad);
    canvas.restore();
  }

  /// Los ojos: redondos; al reírse, dos arcos entornados.
  void _ojos(Canvas canvas, Offset centro, double separacion, double opacidad) {
    for (final lado in [-1.0, 1.0]) {
      final ojo = centro + Offset(lado * separacion, 0);
      if (risa > 0.1 && risa < 0.9) {
        canvas.drawArc(Rect.fromCircle(center: ojo, radius: 2.6), math.pi, math.pi, false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = Colors.white.withOpacity(opacidad));
      } else {
        canvas.drawCircle(ojo, 2.6, Paint()..color = Colors.white.withOpacity(opacidad));
        canvas.drawCircle(ojo + Offset(0.6, derrota > 0 ? 1 : 0.4), 1.3,
            Paint()..color = const Color(0xFF14102A).withOpacity(opacidad));
      }
    }
  }

  void _rotulo(Canvas canvas, String texto, Offset centro, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorMonstruo anterior) => true;
}
