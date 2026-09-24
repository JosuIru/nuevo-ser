import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/depositos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/tranvia.dart' show enDecimal;
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Depósitos — segunda sala de Rexán. Se elige cuánto cabe entre cuatro;
/// al acertar, el depósito se llena por capas (o la tapa de la tubería se
/// rodea o se cubre). Si se pide de más, las Fugas lo derraman.
class PantallaDepositos extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaDepositos({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaDepositos> createState() => _PantallaDepositosState();
}

class _PantallaDepositosState extends State<PantallaDepositos>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_depositos';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.depositos);
  static const _tipos = [
    TipoDeposito.cubos,
    TipoDeposito.cubos,
    TipoDeposito.litros,
    TipoDeposito.litros,
    TipoDeposito.vallaCirculo,
    TipoDeposito.areaCirculo,
  ];

  late final GeneradorDepositos _generador;
  late final AnimationController _llenado = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
  late RetoDeposito _reto;
  int _ronda = 1;
  int? _elegida;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _terminada = false;
  String? _lineaRexan;
  DateTime _inicio = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  @override
  void initState() {
    super.initState();
    _generador = GeneradorDepositos(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _llenado.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _llenado.value = 0;
  }

  String _escrito(int valor) => _reto.enCentesimas ? enDecimal(valor) : '$valor';

  Future<void> _elegir(int opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuesta;
    if (!_yaRegistrado) {
      _yaRegistrado = true;
      widget.registro?.registrar(
        idHabilidad: _reto.idHabilidad,
        acierto: acierta,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: DateTime.now().difference(_inicio),
      );
    }
    setState(() {
      _elegida = opcion;
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          TipoDeposito.cubos => 'Capa a capa, lleno hasta arriba.',
          TipoDeposito.litros => 'Cada litro es un cubo de 10 cm de lado. Lleno.',
          _ => 'Tubería medida. La Industria se enfría.',
        };
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoDeposito.cubos when opcion > _reto.respuesta =>
            'Las Fugas: eso no cabe, se sale por el borde. Cuenta una capa y multiplica por las capas.',
          TipoDeposito.cubos => 'Falta agua. Cuenta una capa y multiplica por las capas.',
          TipoDeposito.litros =>
            'Multiplica las tres medidas y pasa a litros: 1 litro son 1000 cm³.',
          TipoDeposito.vallaCirculo =>
            'La valla es la vuelta: 2 × 3,14 × el radio. Nada al cuadrado.',
          TipoDeposito.areaCirculo =>
            'La tapa es la superficie: 3,14 × el radio × el radio.',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _llenado.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() {
      if (_ronda >= _definicion.rondasPorPartida) {
        _terminada = true;
      } else {
        _ronda++;
        _nuevoReto();
      }
    });
  }

  String _texto(String plantilla, Locale locale, [Map<String, String> datos = const {}]) {
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final d = _reto.datos;
    final linea = _terminada
        ? _texto('Seis depósitos llenos y ni una gota por el suelo. Las Fugas se secan.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale);
    final pregunta = switch (_reto.tipo) {
      TipoDeposito.cubos => _texto('Un depósito de {l} × {a} × {h} cubitos. ¿Cuántos cubitos caben?', locale,
          {'l': '${d[0]}', 'a': '${d[1]}', 'h': '${d[2]}'}),
      TipoDeposito.litros => _texto('Un depósito de {l} × {a} × {h} cm. ¿Cuántos litros caben?', locale,
          {'l': '${d[0]}', 'a': '${d[1]}', 'h': '${d[2]}'}),
      TipoDeposito.vallaCirculo => _texto(
          'Una tapa de tubería de radio {r} m. ¿Cuántos metros de valla la rodean? (π ≈ 3,14)', locale,
          {'r': '${d[0]}'}),
      TipoDeposito.areaCirculo => _texto(
          'Una tapa de tubería de radio {r} m. ¿Cuántos m² de chapa la cubren? (π ≈ 3,14)', locale,
          {'r': '${d[0]}'}),
    };
    final desborda = !_resuelto && _elegida != null && _elegida! > _reto.respuesta;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _reto.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: linea,
      terminada: _terminada,
      child: Column(
        children: [
          Text(pregunta,
              key: const ValueKey('pregunta-depositos'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _llenado,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: PintorDeposito(reto: _reto, llenado: _llenado.value, desborda: desborda),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final opcion in _reto.opciones)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      key: ValueKey('opcion-$opcion'),
                      onTap: () => _elegir(opcion),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: _elegida == opcion
                                ? [PaletaNeon.ambarCanales.withOpacity(0.35), PaletaNeon.ambarCanales.withOpacity(0.1)]
                                : [const Color(0xFF2A1A55), PaletaNeon.fondoMedio],
                          ),
                          border: Border.all(color: PaletaNeon.violetaNeon.withOpacity(0.45)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(_escrito(opcion),
                                style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// El depósito en perspectiva caballera, o la tapa redonda de la tubería.
/// [llenado] (0→1) sube el agua capa a capa o recorre la tapa;
/// [desborda] pinta el agua saliéndose por el borde (las Fugas).
class PintorDeposito extends CustomPainter {
  final RetoDeposito reto;
  final double llenado;
  final bool desborda;

  PintorDeposito({required this.reto, required this.llenado, this.desborda = false});

  static const _chapa = Color(0xFF8C93B8);
  static const _agua = Color(0xFF4FA9D9);
  static const _rejilla = Color(0xFF3A4270);

  @override
  void paint(Canvas canvas, Size size) {
    switch (reto.tipo) {
      case TipoDeposito.cubos:
      case TipoDeposito.litros:
        _caja(canvas, size);
      case TipoDeposito.vallaCirculo:
      case TipoDeposito.areaCirculo:
        _tapa(canvas, size);
    }
  }

  void _caja(Canvas canvas, Size size) {
    // En litros las medidas van en decenas de cm: cada cubito es un litro.
    final escala = reto.tipo == TipoDeposito.litros ? 10 : 1;
    final [largo, ancho, alto] = [for (final medida in reto.datos) medida ~/ escala];
    // Perspectiva caballera: el fondo va en diagonal a la mitad.
    const profundidad = Offset(0.5, -0.5);
    final unidades = Size(largo + ancho * profundidad.dx, alto + ancho * -profundidad.dy);
    final lado = math.min(size.width * 0.8 / unidades.width, size.height * 0.8 / unidades.height);
    // Esquina de abajo a la izquierda del frente.
    final origen = Offset((size.width - unidades.width * lado) / 2, (size.height + unidades.height * lado) / 2);
    Offset punto(double x, double y, double z) =>
        origen + Offset(x * lado + z * profundidad.dx * lado, -y * lado + z * profundidad.dy * lado);

    Path cara(List<Offset> esquinas) => Path()..addPolygon(esquinas, true);
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _rejilla;
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _chapa;

    // Pared del fondo, lateral y suelo, con su cuadrícula.
    canvas.drawPath(
        cara([punto(0, 0, ancho.toDouble()), punto(largo.toDouble(), 0, ancho.toDouble()),
          punto(largo.toDouble(), alto.toDouble(), ancho.toDouble()), punto(0, alto.toDouble(), ancho.toDouble())]),
        Paint()..color = const Color(0xFF1C2248));
    for (var x = 0; x <= largo; x++) {
      canvas.drawLine(punto(x.toDouble(), 0, 0), punto(x.toDouble(), 0, ancho.toDouble()), trazo);
    }
    for (var z = 0; z <= ancho; z++) {
      canvas.drawLine(punto(0, 0, z.toDouble()), punto(largo.toDouble(), 0, z.toDouble()), trazo);
    }

    // El agua, capa a capa.
    final nivel = llenado * alto;
    if (nivel > 0) {
      final capasLlenas = nivel.floor();
      for (var capa = 0; capa < alto; capa++) {
        final arriba = math.min(nivel, capa + 1.0);
        if (arriba <= capa) break;
        final abajo = capa.toDouble();
        final opacidad = capa < capasLlenas ? 0.55 : 0.4;
        canvas.drawPath(
            cara([punto(0, abajo, 0), punto(largo.toDouble(), abajo, 0), punto(largo.toDouble(), arriba, 0), punto(0, arriba, 0)]),
            Paint()..color = _agua.withOpacity(opacidad));
        canvas.drawPath(
            cara([punto(largo.toDouble(), abajo, 0), punto(largo.toDouble(), abajo, ancho.toDouble()),
              punto(largo.toDouble(), arriba, ancho.toDouble()), punto(largo.toDouble(), arriba, 0)]),
            Paint()..color = _agua.withOpacity(opacidad * 0.75));
      }
      // Superficie con los cubitos de una capa.
      canvas.drawPath(
          cara([punto(0, nivel, 0), punto(largo.toDouble(), nivel, 0), punto(largo.toDouble(), nivel, ancho.toDouble()),
            punto(0, nivel, ancho.toDouble())]),
          Paint()..color = _agua.withOpacity(0.8));
      for (var x = 1; x < largo; x++) {
        canvas.drawLine(punto(x.toDouble(), nivel, 0), punto(x.toDouble(), nivel, ancho.toDouble()),
            Paint()..color = Colors.white.withOpacity(0.35));
      }
      for (var z = 1; z < ancho; z++) {
        canvas.drawLine(punto(0, nivel, z.toDouble()), punto(largo.toDouble(), nivel, z.toDouble()),
            Paint()..color = Colors.white.withOpacity(0.35));
      }
      // Rayas de capa en el frente.
      for (var y = 1; y < nivel; y++) {
        canvas.drawLine(punto(0, y.toDouble(), 0), punto(largo.toDouble(), y.toDouble(), 0),
            Paint()..color = Colors.white.withOpacity(0.25));
      }
    }

    // Las Fugas: el agua pedida de más se sale por el borde delantero.
    if (desborda) {
      final chorro = Paint()..color = _agua.withOpacity(0.7);
      for (var i = 0; i < 3; i++) {
        final x = largo * (0.25 + 0.25 * i);
        final inicio = punto(x, alto.toDouble(), 0);
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(inicio.dx - 3, inicio.dy, 6, alto * lado + 8), const Radius.circular(3)),
            chorro);
      }
      final suelo = punto(largo / 2, 0, 0);
      canvas.drawOval(Rect.fromCenter(center: suelo + const Offset(0, 14), width: largo * lado, height: 14), chorro);
    }

    // Aristas de la caja.
    for (final (a, b) in [
      (punto(0, 0, 0), punto(largo.toDouble(), 0, 0)),
      (punto(0, 0, 0), punto(0, alto.toDouble(), 0)),
      (punto(largo.toDouble(), 0, 0), punto(largo.toDouble(), alto.toDouble(), 0)),
      (punto(0, alto.toDouble(), 0), punto(largo.toDouble(), alto.toDouble(), 0)),
      (punto(largo.toDouble(), 0, 0), punto(largo.toDouble(), 0, ancho.toDouble())),
      (punto(largo.toDouble(), alto.toDouble(), 0), punto(largo.toDouble(), alto.toDouble(), ancho.toDouble())),
      (punto(0, alto.toDouble(), 0), punto(0, alto.toDouble(), ancho.toDouble())),
      (punto(largo.toDouble(), 0, ancho.toDouble()), punto(largo.toDouble(), alto.toDouble(), ancho.toDouble())),
      (punto(0, alto.toDouble(), ancho.toDouble()), punto(largo.toDouble(), alto.toDouble(), ancho.toDouble())),
    ]) {
      canvas.drawLine(a, b, borde);
    }

    // Medidas.
    final unidad = reto.tipo == TipoDeposito.litros ? ' cm' : '';
    _rotulo(canvas, '${reto.datos[0]}$unidad', punto(largo / 2, 0, 0) + const Offset(0, 14));
    _rotulo(canvas, '${reto.datos[2]}$unidad', punto(0, alto / 2, 0) + const Offset(-24, 0));
    _rotulo(canvas, '${reto.datos[1]}$unidad', punto(largo.toDouble(), 0, ancho / 2) + const Offset(26, 6));
  }

  void _tapa(Canvas canvas, Size size) {
    final radio = reto.datos[0];
    final centro = Offset(size.width / 2, size.height / 2);
    final radioPantalla = math.min(size.width, size.height) * 0.36;
    // La tubería asoma por detrás.
    canvas.drawCircle(centro + const Offset(8, 10), radioPantalla, Paint()..color = const Color(0xFF14102A));
    canvas.drawCircle(centro, radioPantalla, Paint()..color = const Color(0xFF1C2248));
    // Cuadrícula de metros dentro de la tapa.
    final metro = radioPantalla / radio;
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: centro, radius: radioPantalla)));
    for (var i = -radio; i <= radio; i++) {
      canvas.drawLine(centro + Offset(i * metro, -radioPantalla), centro + Offset(i * metro, radioPantalla),
          Paint()..color = _rejilla);
      canvas.drawLine(centro + Offset(-radioPantalla, i * metro), centro + Offset(radioPantalla, i * metro),
          Paint()..color = _rejilla);
    }
    if (reto.tipo == TipoDeposito.areaCirculo && llenado > 0) {
      canvas.drawCircle(centro, radioPantalla * llenado, Paint()..color = _agua.withOpacity(0.6));
    }
    canvas.restore();
    canvas.drawCircle(
        centro,
        radioPantalla,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _chapa);
    if (reto.tipo == TipoDeposito.vallaCirculo && llenado > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radioPantalla + 6),
          -math.pi / 2,
          2 * math.pi * llenado,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = PaletaNeon.ambarCanales);
    }
    // El radio.
    canvas.drawLine(centro, centro + Offset(radioPantalla, 0),
        Paint()
          ..color = PaletaNeon.rosaAcento
          ..strokeWidth = 2.5);
    canvas.drawCircle(centro, 3.5, Paint()..color = PaletaNeon.rosaAcento);
    _rotulo(canvas, 'r = $radio m', centro + Offset(radioPantalla / 2, -14));
  }

  void _rotulo(Canvas canvas, String texto, Offset centro) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 13)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorDeposito anterior) => true;
}
