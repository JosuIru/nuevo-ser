import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../dominio/voz_personaje.dart';
import '../../nucleo/paleta.dart';

/// Retratos del elenco, por orden de preferencia:
/// 1. **Dibujo a mano** (concept-art escaneado, cuerpo entero) en
///    `assets/personajes/<id>.png` — hoy Kai y Oryn.
/// 2. **Retrato ilustrado PROVISIONAL** (busto circular) en
///    `assets/personajes/retratos/<id>.webp`: acuarelas de Las Versiones
///    viradas a la noche de Uno Roto (`arte/personajes/`).
/// 3. **Silueta PROVISIONAL** según la biblia visual
/// (`docs/personajes/biblia_visual.md`, "Estilo común"): silueta muy
/// oscura teñida del color dominante, contorno del color de marca y uno
/// o dos acentos que lo identifican de un vistazo.
///
/// Cuando llegue el dibujo de alguien: dejar el PNG en
/// `assets/personajes/<id>.png` y añadir el id a [personajesConDibujo].

/// Personajes con dibujo a mano ya integrado.
const personajesConDibujo = {'kai', 'oryn'};

/// Personajes con retrato ilustrado provisional.
const personajesConRetrato = {
  'sora', 'irune', 'rexan', 'naini', 'vadic', 'brina', 'ari',
};

enum TipoRetrato { dibujo, retrato, silueta, ninguno }

enum Peinado { mechon, corto, recogido, trenza, coleta, largo }

enum Acento {
  cremalleraMostaza,
  marcaPlata,
  baston,
  panueloAzul,
  barba,
  pulseras,
  telasCruzadas,
  gafas,
  manchasAceite,
  chaquetaLarga,
  mochila,
  panueloVerde,
  hiloCian,
}

class RasgosSilueta {
  final String id;
  final Color relleno;
  final Color contorno;

  /// Altura relativa al lienzo (1 = adulto alto).
  final double altura;

  /// Anchura de hombros relativa (1 = normal).
  final double hombros;
  final Peinado peinado;
  final List<Acento> acentos;

  /// Hombro derecho algo caído (Irune: vieja pelea).
  final bool hombroCaido;

  const RasgosSilueta({
    required this.id,
    required this.relleno,
    required this.contorno,
    required this.altura,
    this.hombros = 1,
    required this.peinado,
    this.acentos = const [],
    this.hombroCaido = false,
  });
}

/// Rasgos por voz. Colores: doc 11 (paleta por personaje) y doc 04
/// (aspecto). El contorno es el color de marca de la voz.
final rasgosPorVoz = <VozPersonaje, RasgosSilueta>{
  VozPersonaje.sora: const RasgosSilueta(
    id: 'sora',
    relleno: Color(0xFF0F0826),
    contorno: PaletaNeon.violetaNeon,
    altura: 0.86,
    hombros: 0.95,
    peinado: Peinado.mechon,
    acentos: [Acento.cremalleraMostaza, Acento.hiloCian],
  ),
  VozPersonaje.irune: const RasgosSilueta(
    id: 'irune',
    relleno: Color(0xFF12132A),
    contorno: PaletaNeon.violetaNeon,
    altura: 0.9,
    hombros: 0.9,
    peinado: Peinado.recogido,
    acentos: [Acento.marcaPlata],
    hombroCaido: true,
  ),
  VozPersonaje.rexan: const RasgosSilueta(
    id: 'rexan',
    relleno: Color(0xFF15131C),
    contorno: PaletaNeon.ambarCanales,
    altura: 0.95,
    hombros: 1.05,
    peinado: Peinado.corto,
    acentos: [Acento.baston, Acento.panueloAzul, Acento.barba],
  ),
  VozPersonaje.naini: const RasgosSilueta(
    id: 'naini',
    relleno: Color(0xFF1E1010),
    contorno: PaletaNeon.rosaAcento,
    altura: 0.92,
    peinado: Peinado.trenza,
    acentos: [Acento.telasCruzadas, Acento.pulseras],
  ),
  VozPersonaje.vadic: const RasgosSilueta(
    id: 'vadic',
    relleno: Color(0xFF10131F),
    contorno: PaletaNeon.grisMetal,
    altura: 1.0,
    hombros: 0.88,
    peinado: Peinado.corto,
    acentos: [Acento.gafas, Acento.manchasAceite],
  ),
  VozPersonaje.brina: const RasgosSilueta(
    id: 'brina',
    relleno: Color(0xFF1A130E),
    contorno: PaletaNeon.violetaNeon,
    altura: 0.92,
    peinado: Peinado.largo,
    acentos: [Acento.chaquetaLarga, Acento.mochila, Acento.gafas],
  ),
  VozPersonaje.ari: const RasgosSilueta(
    id: 'ari',
    relleno: Color(0xFF0C1A14),
    contorno: PaletaNeon.exitoSuave,
    altura: 0.8,
    hombros: 0.9,
    peinado: Peinado.coleta,
    acentos: [Acento.panueloVerde],
  ),
  VozPersonaje.aprendizNiko: const RasgosSilueta(
    id: 'niko',
    relleno: Color(0xFF0E1224),
    contorno: PaletaNeon.azulNeon,
    altura: 0.78,
    hombros: 0.92,
    peinado: Peinado.corto,
    acentos: [Acento.hiloCian],
  ),
};

/// Id de cada personaje por nombre visible de su voz.
const _idPorNombre = {
  'Sora': 'sora',
  'Kai': 'kai',
  'Irune': 'irune',
  'Oryn': 'oryn',
  'Naini': 'naini',
  'Brina': 'brina',
  'Rexán': 'rexan',
  'Vadic': 'vadic',
  'Ari': 'ari',
  'Niko': 'niko',
};

TipoRetrato tipoRetrato(VozPersonaje voz) {
  final id = _idPorNombre[voz.nombreVisible];
  if (id == null) return TipoRetrato.ninguno;
  if (personajesConDibujo.contains(id)) return TipoRetrato.dibujo;
  if (personajesConRetrato.contains(id)) return TipoRetrato.retrato;
  if (rasgosPorVoz.containsKey(voz)) return TipoRetrato.silueta;
  return TipoRetrato.ninguno;
}

/// Retrato de [voz]: el dibujo si existe, si no la silueta provisional.
/// Ocupa el espacio que le den (se ajusta sin deformar).
class RetratoPersonaje extends StatelessWidget {
  final VozPersonaje voz;

  const RetratoPersonaje({super.key, required this.voz});

  @override
  Widget build(BuildContext contexto) {
    final id = _idPorNombre[voz.nombreVisible];
    final rasgos = rasgosPorVoz[voz];
    Widget silueta() => rasgos == null
        ? const SizedBox.shrink()
        : AspectRatio(
            aspectRatio: 0.62,
            child: CustomPaint(painter: PintorSilueta(rasgos)),
          );
    switch (tipoRetrato(voz)) {
      case TipoRetrato.dibujo:
        return Image.asset(
          'assets/personajes/$id.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        );
      case TipoRetrato.retrato:
        return AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            'assets/personajes/retratos/$id.webp',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            // Sin el asset (p. ej. en tests), la silueta.
            errorBuilder: (_, __, ___) => silueta(),
          ),
        );
      case TipoRetrato.silueta:
        return silueta();
      case TipoRetrato.ninguno:
        return const SizedBox.shrink();
    }
  }
}

/// Figura humana de pie, en un único contorno limpio (las piezas se
/// unen con [Path.combine] antes de trazar el borde).
class PintorSilueta extends CustomPainter {
  final RasgosSilueta rasgos;

  PintorSilueta(this.rasgos);

  @override
  void paint(Canvas canvas, Size size) {
    final alto = size.height * rasgos.altura * 0.97;
    final suelo = size.height * 0.99;
    final arriba = suelo - alto;
    final centroX = size.width / 2;
    final radioCabeza = alto * 0.078;
    final centroCabeza = Offset(centroX, arriba + radioCabeza * 1.1);
    final alturaHombros = arriba + alto * 0.2;
    final medioHombros = alto * 0.125 * rasgos.hombros;
    final alturaCadera = arriba + alto * 0.54;
    final medioCadera = medioHombros * 0.78;
    final caida = rasgos.hombroCaido ? alto * 0.018 : 0.0;

    // Torso (con hombros redondeados).
    final torso = Path()
      ..moveTo(centroX - medioHombros, alturaHombros + medioHombros * 0.35)
      ..quadraticBezierTo(centroX - medioHombros, alturaHombros,
          centroX - medioHombros * 0.55, alturaHombros)
      ..lineTo(centroX + medioHombros * 0.55, alturaHombros + caida)
      ..quadraticBezierTo(centroX + medioHombros, alturaHombros + caida,
          centroX + medioHombros, alturaHombros + medioHombros * 0.35 + caida)
      ..lineTo(centroX + medioCadera, alturaCadera)
      ..lineTo(centroX - medioCadera, alturaCadera)
      ..close();

    final cuello = Path()
      ..addRect(Rect.fromCenter(
          center: Offset(centroX, alturaHombros - radioCabeza * 0.3),
          width: radioCabeza * 0.8,
          height: radioCabeza * 1.2));

    final cabeza = Path()
      ..addOval(Rect.fromCircle(center: centroCabeza, radius: radioCabeza));

    Path brazo(double lado) {
      final hombro = Offset(centroX + lado * medioHombros * 0.86,
          alturaHombros + medioHombros * 0.3 + (lado > 0 ? caida : 0));
      final mano = Offset(centroX + lado * medioHombros * 1.12,
          arriba + alto * 0.52 + (lado > 0 ? caida : 0));
      return _segmento(hombro, mano, alto * 0.045, alto * 0.035);
    }

    Path pierna(double lado) {
      final cadera = Offset(centroX + lado * medioCadera * 0.45, alturaCadera - 2);
      final pie = Offset(centroX + lado * medioCadera * 0.55, suelo - alto * 0.02);
      return _segmento(cadera, pie, alto * 0.075, alto * 0.05);
    }

    var cuerpo = torso;
    for (final pieza in [
      cuello,
      cabeza,
      brazo(-1),
      brazo(1),
      pierna(-1),
      pierna(1),
      _pelo(centroCabeza, radioCabeza, alturaHombros),
      if (rasgos.acentos.contains(Acento.chaquetaLarga))
        Path()
          ..moveTo(centroX - medioHombros * 0.95, alturaHombros + medioHombros * 0.4)
          ..lineTo(centroX + medioHombros * 0.95, alturaHombros + medioHombros * 0.4)
          ..lineTo(centroX + medioCadera * 1.25, arriba + alto * 0.8)
          ..lineTo(centroX - medioCadera * 1.25, arriba + alto * 0.8)
          ..close(),
      if (rasgos.acentos.contains(Acento.mochila))
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(centroX + medioHombros * 0.7, alturaHombros + alto * 0.03,
                  medioHombros * 0.55, alto * 0.2),
              Radius.circular(alto * 0.02))),
    ]) {
      cuerpo = Path.combine(PathOperation.union, cuerpo, pieza);
    }

    canvas.drawPath(cuerpo, Paint()..color = rasgos.relleno);
    canvas.drawPath(
      cuerpo,
      Paint()
        ..color = rasgos.contorno.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, alto * 0.011)
        ..strokeJoin = StrokeJoin.round,
    );

    _acentos(canvas, alto,
        centroX: centroX,
        centroCabeza: centroCabeza,
        radioCabeza: radioCabeza,
        alturaHombros: alturaHombros,
        medioHombros: medioHombros,
        alturaCadera: alturaCadera,
        suelo: suelo,
        arriba: arriba,
        caida: caida);
  }

  /// Segmento redondeado (brazo, pierna) que se estrecha de [a] a [b].
  Path _segmento(Offset a, Offset b, double anchoA, double anchoB) {
    final direccion = b - a;
    final normal = Offset(-direccion.dy, direccion.dx) / direccion.distance;
    return Path()
      ..moveTo((a + normal * anchoA / 2).dx, (a + normal * anchoA / 2).dy)
      ..lineTo((b + normal * anchoB / 2).dx, (b + normal * anchoB / 2).dy)
      ..arcToPoint(b - normal * anchoB / 2, radius: Radius.circular(anchoB / 2))
      ..lineTo((a - normal * anchoA / 2).dx, (a - normal * anchoA / 2).dy)
      ..close();
  }

  Path _pelo(Offset c, double r, double alturaHombros) {
    final pelo = Path();
    switch (rasgos.peinado) {
      case Peinado.mechon: // Sora: corte irregular, mechón a la izquierda
        pelo
          ..addArc(Rect.fromCircle(center: c.translate(0, -r * 0.08), radius: r * 1.08),
              math.pi, math.pi)
          ..moveTo(c.dx - r * 0.9, c.dy - r * 0.3)
          ..lineTo(c.dx - r * 1.25, c.dy + r * 0.55)
          ..lineTo(c.dx - r * 0.35, c.dy - r * 0.6)
          ..close();
      case Peinado.corto:
        pelo.addArc(Rect.fromCircle(center: c.translate(0, -r * 0.1), radius: r * 1.05),
            math.pi * 1.05, math.pi * 0.9);
      case Peinado.recogido: // moño
        pelo.addOval(Rect.fromCircle(center: c.translate(r * 0.35, -r * 1.0), radius: r * 0.5));
      case Peinado.trenza: // trenza práctica sobre el hombro
        pelo
          ..addArc(Rect.fromCircle(center: c.translate(0, -r * 0.08), radius: r * 1.06),
              math.pi, math.pi)
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(c.dx + r * 0.55, c.dy, r * 0.42, (alturaHombros - c.dy) + r * 2.2),
              Radius.circular(r * 0.2)));
      case Peinado.coleta:
        pelo.addOval(Rect.fromCenter(
            center: c.translate(-r * 1.05, -r * 0.2), width: r * 0.7, height: r * 1.3));
      case Peinado.largo:
        pelo.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTRB(c.dx - r * 1.12, c.dy - r * 1.08, c.dx + r * 1.12,
                alturaHombros + r * 0.4),
            Radius.circular(r)));
    }
    return pelo;
  }

  void _acentos(Canvas canvas, double alto,
      {required double centroX,
      required Offset centroCabeza,
      required double radioCabeza,
      required double alturaHombros,
      required double medioHombros,
      required double alturaCadera,
      required double suelo,
      required double arriba,
      required double caida}) {
    Paint trazo(Color color, [double grosor = 1]) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, alto * 0.016) * grosor
      ..strokeCap = StrokeCap.round;
    final manoDerecha =
        Offset(centroX + medioHombros * 1.12, arriba + alto * 0.52 + caida);
    final manoIzquierda = Offset(centroX - medioHombros * 1.12, arriba + alto * 0.52);

    for (final acento in rasgos.acentos) {
      switch (acento) {
        case Acento.cremalleraMostaza:
          final mostaza = trazo(const Color(0xFFB89A4E));
          canvas.drawLine(Offset(centroX, alturaHombros + alto * 0.03),
              Offset(centroX, alturaCadera - alto * 0.02), mostaza);
          canvas.drawLine(
              Offset(centroX - medioHombros * 0.5, alturaHombros + alto * 0.015),
              Offset(centroX + medioHombros * 0.5, alturaHombros + alto * 0.015),
              mostaza);
        case Acento.hiloCian:
          // El cian Fraccionista escondido en el cuello.
          canvas.drawLine(
              Offset(centroX - radioCabeza * 0.45, alturaHombros - radioCabeza * 0.15),
              Offset(centroX + radioCabeza * 0.45, alturaHombros - radioCabeza * 0.15),
              trazo(const Color(0xFF5CB4C2), 0.8));
        case Acento.marcaPlata:
          canvas.drawCircle(Offset(centroX, alturaHombros + alto * 0.05), alto * 0.012,
              Paint()..color = const Color(0xFFA9B6BC));
        case Acento.baston:
          canvas.drawLine(manoDerecha.translate(alto * 0.01, 0),
              Offset(manoDerecha.dx + alto * 0.03, suelo - alto * 0.01),
              trazo(const Color(0xFF7A5A3C), 1.3));
        case Acento.panueloAzul:
          canvas.drawLine(
              Offset(centroX - radioCabeza * 0.8, alturaHombros - radioCabeza * 0.05),
              Offset(centroX + radioCabeza * 0.8, alturaHombros - radioCabeza * 0.05),
              trazo(const Color(0xFF2B4DA6), 1.5));
        case Acento.barba:
          canvas.drawArc(
              Rect.fromCircle(center: centroCabeza, radius: radioCabeza * 0.8),
              math.pi * 0.2, math.pi * 0.6, false, trazo(const Color(0xFF8C8C90)));
        case Acento.pulseras:
          for (final mano in [manoIzquierda, manoDerecha]) {
            for (var i = 0; i < 3; i++) {
              canvas.drawLine(mano.translate(-alto * 0.02, -alto * 0.03 - i * alto * 0.018),
                  mano.translate(alto * 0.02, -alto * 0.03 - i * alto * 0.018),
                  trazo(const Color(0xFFC8A25B), 0.7));
            }
          }
        case Acento.telasCruzadas:
          canvas.drawLine(
              Offset(centroX - medioHombros * 0.7, alturaHombros + alto * 0.02),
              Offset(centroX + medioHombros * 0.6, alturaCadera - alto * 0.04),
              trazo(const Color(0xFFB8742E), 1.4));
          canvas.drawLine(
              Offset(centroX + medioHombros * 0.7, alturaHombros + alto * 0.05),
              Offset(centroX - medioHombros * 0.3, alturaHombros + alto * 0.16),
              trazo(const Color(0xFF2B4DA6), 1.2));
        case Acento.gafas:
          final altura = rasgos.id == 'brina'
              ? centroCabeza.dy - radioCabeza * 0.55 // en la frente
              : centroCabeza.dy - radioCabeza * 0.05;
          for (final lado in [-1.0, 1.0]) {
            canvas.drawCircle(Offset(centroX + lado * radioCabeza * 0.4, altura),
                radioCabeza * 0.27, trazo(const Color(0xFFB0B4BD), 0.6));
          }
        case Acento.manchasAceite:
          for (final punto in [
            Offset(centroX - medioHombros * 0.4, alturaHombros + alto * 0.14),
            Offset(centroX + medioHombros * 0.3, alturaHombros + alto * 0.24),
          ]) {
            canvas.drawCircle(punto, alto * 0.012, Paint()..color = const Color(0xFF8A6353));
          }
        case Acento.chaquetaLarga:
        case Acento.mochila:
          break; // forman parte del contorno
        case Acento.panueloVerde:
          canvas.drawLine(
              Offset(centroX - radioCabeza * 0.85, alturaHombros - radioCabeza * 0.05),
              Offset(centroX + radioCabeza * 0.85, alturaHombros - radioCabeza * 0.05),
              trazo(const Color(0xFF2F8B60), 1.6));
      }
    }
  }

  @override
  bool shouldRepaint(PintorSilueta anterior) => anterior.rasgos != rasgos;
}
