import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../dominio/mapa_sonidos.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../tema/colores.dart';
import '../tema/tipografia.dart';

/// Mapa de sonidos: el niño en el centro, tres anillos (cerca, media
/// distancia, lejos) y una marca por cada sonido que oye, donde le
/// llega. Juego de campo clásico de cuaderno de naturalista.
///
/// Como el lienzo de dibujo, devuelve los bytes PNG con
/// `Navigator.pop` y la observación lo guarda en el hueco del dibujo:
/// no hay esquema nuevo, y el mapa se queda sólo en el dispositivo
/// como cualquier dibujo (hard limit de privacidad).
///
/// Sin sonido, sin cronómetro, sin recuento que premie: el contenido
/// es lo que se oye fuera (guía sonora: el silencio es el contenido).
class PantallaMapaSonidos extends StatefulWidget {
  const PantallaMapaSonidos({super.key});

  @override
  State<PantallaMapaSonidos> createState() => _EstadoPantallaMapaSonidos();
}

class _EstadoPantallaMapaSonidos extends State<PantallaMapaSonidos> {
  final MapaSonidos _mapa = MapaSonidos();
  final GlobalKey _claveRepaint = GlobalKey();
  TipoSonido _tipoElegido = TipoSonido.pajaro;

  void _alTocarMapa(Offset posicion, Size tamano) {
    final radio = tamano.shortestSide / 2;
    final centro = tamano.center(Offset.zero);
    final x = (posicion.dx - centro.dx) / radio;
    final y = (posicion.dy - centro.dy) / radio;
    setState(() {
      if (!_mapa.quitarCercaDe(x, y)) {
        _mapa.marcar(MarcaSonido(x: x, y: y, tipo: _tipoElegido));
      }
    });
  }

  Future<void> _guardarYSalir() async {
    if (_mapa.estaVacio) return;
    final limite = _claveRepaint.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (limite == null) return;
    final imagen = await limite.toImage(pixelRatio: 2);
    final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? bytes = datos?.buffer.asUint8List();
    if (bytes == null || !mounted) return;
    Navigator.of(context).pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.of(context);
    return Scaffold(
      backgroundColor: PaletaCuaderno.papelClaro,
      appBar: AppBar(
        backgroundColor: PaletaCuaderno.papelClaro,
        title: Text(textos.mapaSonidosTitulo),
        actions: [
          IconButton(
            tooltip: textos.mapaSonidosDeshacer,
            icon: const Icon(Icons.undo),
            onPressed: _mapa.estaVacio ? null : () => setState(_mapa.deshacer),
          ),
          TextButton(
            onPressed: _mapa.estaVacio ? null : _guardarYSalir,
            child: Text(textos.mapaSonidosGuardar),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                textos.mapaSonidosIntroduccion,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tinta,
                  tamano: TipografiaCuaderno.tamano14,
                ),
              ),
            ),
            Expanded(
              child: RepaintBoundary(
                key: _claveRepaint,
                child: ColoredBox(
                  color: PaletaCuaderno.papelClaro,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: LayoutBuilder(
                            builder: (context, restricciones) {
                              final lado = min(restricciones.maxWidth, restricciones.maxHeight);
                              final tamano = Size(lado, lado);
                              return Center(
                                child: GestureDetector(
                                  key: const ValueKey('superficie-mapa-sonidos'),
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (detalles) =>
                                      _alTocarMapa(detalles.localPosition, tamano),
                                  child: CustomPaint(
                                    size: tamano,
                                    painter: _PintorMapa(
                                      marcas: _mapa.marcas,
                                      textoCentro: textos.mapaSonidosCentro,
                                      textoDelante: textos.mapaSonidosDelante,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (!_mapa.estaVacio)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: _Leyenda(tipos: _mapa.tiposPresentes, textos: textos),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Text(
                textos.mapaSonidosAyuda,
                style: TipografiaCuaderno.sans(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final tipo in TipoSonido.values)
                    ChoiceChip(
                      // Sin marca de verificación: taparía el símbolo,
                      // que es justo lo que hay que reconocer.
                      showCheckmark: false,
                      selected: tipo == _tipoElegido,
                      onSelected: (_) => setState(() => _tipoElegido = tipo),
                      avatar: CustomPaint(
                        size: const Size(18, 18),
                        painter: _PintorGlifo(tipo),
                      ),
                      label: Text(nombreTipoSonido(tipo, textos)),
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

String nombreTipoSonido(TipoSonido tipo, TextosApp textos) {
  switch (tipo) {
    case TipoSonido.pajaro:
      return textos.mapaSonidosTipoPajaro;
    case TipoSonido.insecto:
      return textos.mapaSonidosTipoInsecto;
    case TipoSonido.agua:
      return textos.mapaSonidosTipoAgua;
    case TipoSonido.viento:
      return textos.mapaSonidosTipoViento;
    case TipoSonido.hojas:
      return textos.mapaSonidosTipoHojas;
    case TipoSonido.animal:
      return textos.mapaSonidosTipoAnimal;
    case TipoSonido.persona:
      return textos.mapaSonidosTipoPersona;
    case TipoSonido.maquina:
      return textos.mapaSonidosTipoMaquina;
    case TipoSonido.noSe:
      return textos.mapaSonidosTipoNoSe;
  }
}

/// Leyenda con los tipos que aparecen: queda dentro de la imagen
/// guardada para que el mapa se entienda al releerlo meses después.
class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.tipos, required this.textos});

  final List<TipoSonido> tipos;
  final TextosApp textos;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (final tipo in tipos)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(size: const Size(16, 16), painter: _PintorGlifo(tipo)),
              const SizedBox(width: 4),
              Text(
                nombreTipoSonido(tipo, textos),
                style: TipografiaCuaderno.sans(
                  color: PaletaCuaderno.tinta,
                  tamano: TipografiaCuaderno.tamano12,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _PintorMapa extends CustomPainter {
  _PintorMapa({required this.marcas, required this.textoCentro, required this.textoDelante});

  final List<MarcaSonido> marcas;
  final String textoCentro;
  final String textoDelante;

  @override
  void paint(Canvas lienzo, Size tamano) {
    final centro = tamano.center(Offset.zero);
    final radio = tamano.shortestSide / 2;
    final anillo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = PaletaCuaderno.tintaTenue.withValues(alpha: 0.45);
    for (var indice = 1; indice <= 3; indice++) {
      _circuloPunteado(lienzo, centro, radio * indice / 3 - 1, anillo);
    }
    _texto(lienzo, textoDelante, centro + Offset(0, -radio + 10), PaletaCuaderno.tintaTenue, 11);
    lienzo.drawCircle(centro, 5, Paint()..color = PaletaCuaderno.tinta);
    _texto(lienzo, textoCentro, centro + const Offset(0, 16), PaletaCuaderno.tinta, 12);
    for (final marca in marcas) {
      final punto = centro + Offset(marca.x, marca.y) * radio;
      _PintorGlifo.pintar(lienzo, marca.tipo, punto, 22);
    }
  }

  void _circuloPunteado(Canvas lienzo, Offset centro, double radio, Paint pincel) {
    const segmentos = 72;
    for (var indice = 0; indice < segmentos; indice += 2) {
      final desde = indice * 2 * pi / segmentos;
      lienzo.drawArc(Rect.fromCircle(center: centro, radius: radio), desde,
          2 * pi / segmentos, false, pincel);
    }
  }

  void _texto(Canvas lienzo, String texto, Offset centro, Color color, double tamanoLetra) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamanoLetra)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(lienzo, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PintorMapa anterior) =>
      !identical(anterior.marcas, marcas) || anterior.marcas.length != marcas.length;
}

/// Símbolos de trazo sencillo, como los que se dibujan a lápiz en un
/// cuaderno de campo. Uno por tipo, reconocibles a 16 px.
class _PintorGlifo extends CustomPainter {
  const _PintorGlifo(this.tipo);

  final TipoSonido tipo;

  static Color colorDe(TipoSonido tipo) {
    switch (tipo) {
      case TipoSonido.agua:
      case TipoSonido.viento:
        return PaletaCuaderno.azulCenizaProfundo;
      case TipoSonido.hojas:
      case TipoSonido.insecto:
        return PaletaCuaderno.verdeBosque;
      case TipoSonido.animal:
      case TipoSonido.pajaro:
        return PaletaCuaderno.sienaTenue;
      case TipoSonido.persona:
      case TipoSonido.maquina:
      case TipoSonido.noSe:
        return PaletaCuaderno.carbon;
    }
  }

  static void pintar(Canvas lienzo, TipoSonido tipo, Offset centro, double tamano) {
    final mitad = tamano / 2;
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.4, tamano / 11)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colorDe(tipo);
    Offset p(double x, double y) => centro + Offset(x * mitad, y * mitad);
    switch (tipo) {
      case TipoSonido.pajaro:
        // Gaviota de dos arcos.
        lienzo.drawPath(
            Path()
              ..moveTo(p(-0.9, 0).dx, p(-0.9, 0).dy)
              ..quadraticBezierTo(p(-0.45, -0.6).dx, p(-0.45, -0.6).dy, p(0, 0.1).dx, p(0, 0.1).dy)
              ..quadraticBezierTo(p(0.45, -0.6).dx, p(0.45, -0.6).dy, p(0.9, 0).dx, p(0.9, 0).dy),
            pincel);
      case TipoSonido.insecto:
        lienzo.drawOval(Rect.fromCenter(center: p(0, 0.2), width: mitad * 0.7, height: mitad * 1.1), pincel);
        lienzo.drawLine(p(-0.1, -0.35), p(-0.5, -0.85), pincel);
        lienzo.drawLine(p(0.1, -0.35), p(0.5, -0.85), pincel);
      case TipoSonido.agua:
        for (final altura in [-0.45, 0.0, 0.45]) {
          final camino = Path()..moveTo(p(-0.85, altura).dx, p(-0.85, altura).dy);
          for (var paso = 0; paso < 4; paso++) {
            final x0 = -0.85 + paso * 0.425;
            camino.quadraticBezierTo(p(x0 + 0.21, altura + (paso.isEven ? -0.22 : 0.22)).dx,
                p(x0 + 0.21, altura + (paso.isEven ? -0.22 : 0.22)).dy, p(x0 + 0.425, altura).dx, p(x0 + 0.425, altura).dy);
          }
          lienzo.drawPath(camino, pincel);
        }
      case TipoSonido.viento:
        lienzo.drawPath(
            Path()
              ..moveTo(p(-0.9, -0.3).dx, p(-0.9, -0.3).dy)
              ..lineTo(p(0.4, -0.3).dx, p(0.4, -0.3).dy)
              ..arcToPoint(p(0.4, -0.8), radius: Radius.circular(mitad * 0.25), clockwise: false),
            pincel);
        lienzo.drawPath(
            Path()
              ..moveTo(p(-0.9, 0.3).dx, p(-0.9, 0.3).dy)
              ..lineTo(p(0.6, 0.3).dx, p(0.6, 0.3).dy)
              ..arcToPoint(p(0.6, 0.8), radius: Radius.circular(mitad * 0.25)),
            pincel);
      case TipoSonido.hojas:
        final hoja = Path()
          ..moveTo(p(-0.8, 0.8).dx, p(-0.8, 0.8).dy)
          ..quadraticBezierTo(p(-0.8, -0.8).dx, p(-0.8, -0.8).dy, p(0.8, -0.8).dx, p(0.8, -0.8).dy)
          ..quadraticBezierTo(p(0.8, 0.8).dx, p(0.8, 0.8).dy, p(-0.8, 0.8).dx, p(-0.8, 0.8).dy);
        lienzo.drawPath(hoja, pincel);
        lienzo.drawLine(p(-0.8, 0.8), p(0.4, -0.4), pincel);
      case TipoSonido.animal:
        // Huella: almohadilla y tres dedos.
        lienzo.drawOval(Rect.fromCenter(center: p(0, 0.35), width: mitad * 0.9, height: mitad * 0.7), pincel);
        for (final dedo in [p(-0.55, -0.35), p(0, -0.6), p(0.55, -0.35)]) {
          lienzo.drawCircle(dedo, mitad * 0.18, pincel);
        }
      case TipoSonido.persona:
        lienzo.drawCircle(p(0, -0.5), mitad * 0.3, pincel);
        lienzo.drawLine(p(0, -0.2), p(0, 0.5), pincel);
        lienzo.drawLine(p(-0.5, 0.05), p(0.5, 0.05), pincel);
        lienzo.drawLine(p(0, 0.5), p(-0.4, 0.95), pincel);
        lienzo.drawLine(p(0, 0.5), p(0.4, 0.95), pincel);
      case TipoSonido.maquina:
        lienzo.drawRect(Rect.fromCenter(center: p(0, -0.1), width: mitad * 1.5, height: mitad * 1.0), pincel);
        lienzo.drawCircle(p(-0.45, 0.6), mitad * 0.22, pincel);
        lienzo.drawCircle(p(0.45, 0.6), mitad * 0.22, pincel);
      case TipoSonido.noSe:
        final pintor = TextPainter(
          text: TextSpan(
              text: '?',
              style: TextStyle(color: colorDe(tipo), fontSize: tamano * 0.95, fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        pintor.paint(lienzo, centro - Offset(pintor.width / 2, pintor.height / 2));
    }
  }

  @override
  void paint(Canvas lienzo, Size tamano) =>
      pintar(lienzo, tipo, tamano.center(Offset.zero), tamano.shortestSide);

  @override
  bool shouldRepaint(covariant _PintorGlifo anterior) => anterior.tipo != tipo;
}
