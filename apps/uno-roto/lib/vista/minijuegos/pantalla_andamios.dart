import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/andamios.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Andamios — segunda sala de Rexán. Se elige el lado de la plataforma o
/// la escalera entre cuatro. La elegida se dibuja tal cual: si no es
/// justa, no llega o se pasa, y los Vértigos la hacen tambalearse.
class PantallaAndamios extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaAndamios({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaAndamios> createState() => _PantallaAndamiosState();
}

class _PantallaAndamiosState extends State<PantallaAndamios>
    with TickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_andamios';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.andamios);
  static const _tipos = [
    TipoAndamio.plataforma,
    TipoAndamio.plataforma,
    TipoAndamio.escalera,
    TipoAndamio.escalera,
    TipoAndamio.apoyar,
    TipoAndamio.apoyar,
  ];

  late final GeneradorAndamios _generador;
  late final AnimationController _asentado = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _vaiven = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));
  late RetoAndamio _reto;
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
    _generador = GeneradorAndamios(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _asentado.dispose();
    _vaiven.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _asentado.value = 0;
    _vaiven.value = 1;
  }

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
    final d = _reto.datos;
    setState(() {
      _elegida = opcion;
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          TipoAndamio.plataforma => 'Lado justo. La plataforma no se mueve.',
          _ => 'Justa. Ni el viento la mueve. A arreglar la farola.',
        };
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoAndamio.plataforma when opcion * 2 == d[0] =>
            'La mitad no: busca el número que multiplicado por sí mismo da el área.',
          TipoAndamio.plataforma => 'Esa plataforma no mide eso. ¿Qué número por sí mismo da el área?',
          TipoAndamio.escalera when opcion == d[0] + d[1] =>
            'Sumar la pared y el suelo da de más: la escalera va en diagonal. Eleva al cuadrado.',
          TipoAndamio.escalera => 'Los Vértigos la mueven: no es justa. Escalera² = pared² + suelo².',
          TipoAndamio.apoyar when opcion == d[0] - d[1] =>
            'Restar sin más no vale: suelo² = escalera² − pared².',
          TipoAndamio.apoyar => 'Así no sube lo que tiene que subir. Suelo² = escalera² − pared².',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      _vaiven.forward(from: 0);
      return;
    }
    sonar('efecto_acierto');
    await _asentado.forward(from: 0);
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
        ? _texto('Seis andamios montados. Las farolas de la Montaña vuelven a dar luz.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale);
    final pregunta = switch (_reto.tipo) {
      TipoAndamio.plataforma =>
        _texto('Una plataforma cuadrada de {a} m². ¿Cuánto mide su lado?', locale, {'a': '${d[0]}'}),
      TipoAndamio.escalera => _texto(
          'La farola está a {h} m de alto y el pie de la escalera, a {b} m de la pared. ¿Qué escalera llega justa?',
          locale,
          {'h': '${d[0]}', 'b': '${d[1]}'}),
      TipoAndamio.apoyar => _texto(
          'La escalera mide {c} m y tiene que subir {h} m. ¿A cuántos metros de la pared se apoya?', locale,
          {'c': '${d[0]}', 'h': '${d[1]}'}),
    };
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
              key: const ValueKey('pregunta-andamios'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([_asentado, _vaiven]),
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: PintorAndamio(
                  reto: _reto,
                  elegida: _elegida,
                  asentado: _asentado.value,
                  vaiven: _vaiven.value,
                  pista: ofrecerPista,
                ),
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
                        child: Text('$opcion m', style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 20)),
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

/// La plataforma o la pared con su escalera. [elegida] es la medida que
/// se ha tocado (se dibuja tal cual); [vaiven] (0→1) es la ráfaga de los
/// Vértigos tras un fallo; [asentado] (0→1) enseña la buena.
class PintorAndamio extends CustomPainter {
  final RetoAndamio reto;
  final int? elegida;
  final double asentado;
  final double vaiven;

  /// Pista (tras dos fallos): la cuenta que hay que hacer, con símbolos.
  final bool pista;

  PintorAndamio({required this.reto, this.elegida, this.asentado = 0, this.vaiven = 1, this.pista = false});

  static const _madera = Color(0xFFC9A25E);
  static const _pared = Color(0xFF2A2F5A);
  static const _rejilla = Color(0xFF3A4270);

  bool get _justa => elegida == reto.respuesta;

  /// Ángulo del tambaleo: una ráfaga que se apaga.
  double get _tambaleo => _justa ? 0 : math.sin(vaiven * math.pi * 5) * (1 - vaiven) * 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    if (reto.tipo == TipoAndamio.plataforma) {
      _plataforma(canvas, size);
    } else {
      _paredYEscalera(canvas, size);
    }
    if (pista) {
      final d = reto.datos;
      final cuenta = switch (reto.tipo) {
        TipoAndamio.plataforma => '? × ? = ${d[0]}',
        TipoAndamio.escalera => '${d[0]}² + ${d[1]}² = ?²',
        TipoAndamio.apoyar => '${d[0]}² − ${d[1]}² = ?²',
      };
      final pintor = TextPainter(
        text: TextSpan(text: cuenta, style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout();
      final caja = Rect.fromLTWH(8, 6, pintor.width + 16, pintor.height + 8);
      canvas.drawRRect(RRect.fromRectAndRadius(caja, const Radius.circular(8)),
          Paint()..color = const Color(0xFF14102A).withOpacity(0.85));
      canvas.drawRRect(
          RRect.fromRectAndRadius(caja, const Radius.circular(8)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = PaletaNeon.ambarCanales.withOpacity(0.7));
      pintor.paint(canvas, caja.topLeft + const Offset(8, 4));
    }
  }

  void _plataforma(Canvas canvas, Size size) {
    final area = reto.datos[0];
    final lado = reto.respuesta;
    final mayor = math.max(lado, reto.opciones.reduce(math.max)).toDouble();
    final metro = math.min(size.width, size.height) * 0.86 / mayor;
    final centro = Offset(size.width / 2, size.height / 2);
    final plataforma = Rect.fromCenter(center: centro, width: lado * metro, height: lado * metro);
    canvas.drawRect(plataforma, Paint()..color = _madera.withOpacity(0.35));
    // Los metros cuadrados aparecen al acertar.
    if (asentado > 0) {
      final visibles = (area * asentado).round();
      for (var i = 0; i < visibles; i++) {
        final celda = Rect.fromLTWH(plataforma.left + (i % lado) * metro, plataforma.top + (i ~/ lado) * metro, metro, metro);
        canvas.drawRect(celda.deflate(1), Paint()..color = _madera.withOpacity(0.7));
      }
    }
    canvas.drawRect(
        plataforma,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _madera);
    _rotulo(canvas, '$area m²', centro, 18);
    // La plataforma elegida, encima: si no es justa, se nota y se mueve.
    final elegida = this.elegida;
    if (elegida != null && !_justa) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(_tambaleo);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: elegida * metro, height: elegida * metro),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = PaletaNeon.rosaAcento);
      canvas.restore();
      _rotulo(canvas, '$elegida × $elegida = ${elegida * elegida}', centro + Offset(0, elegida * metro / 2 + 14), 13);
    }
  }

  /// Hasta dónde sube una escalera de [largo] con el pie a [pie] de la pared.
  static double alturaApoyada(double largo, double pie) => largo > pie ? math.sqrt(largo * largo - pie * pie) : 0;

  void _paredYEscalera(Canvas canvas, Size size) {
    final esEscalera = reto.tipo == TipoAndamio.escalera;
    // Pared a la derecha y suelo abajo. En "escalera" se elige el largo; en
    // "apoyar", la distancia del pie a la pared.
    final alto = esEscalera ? reto.datos[0] : reto.datos[1];
    final largoFijo = esEscalera ? 0 : reto.datos[0];
    final distanciaFija = esEscalera ? reto.datos[1] : 0;
    double largoDe(int opcion) => esEscalera ? opcion.toDouble() : largoFijo.toDouble();
    double pieDe(int opcion) => esEscalera ? distanciaFija.toDouble() : opcion.toDouble();

    var anchoMundo = 0.0;
    var altoMundo = alto.toDouble();
    for (final opcion in reto.opciones) {
      anchoMundo = math.max(anchoMundo, pieDe(opcion));
      altoMundo = math.max(altoMundo, alturaApoyada(largoDe(opcion), pieDe(opcion)));
    }
    anchoMundo += 2;
    altoMundo += 1.5;
    final metro = math.min(size.width * 0.86 / anchoMundo, size.height * 0.9 / altoMundo);
    final suelo = size.height * 0.95;
    final paredX = size.width / 2 + anchoMundo * metro / 2 - metro;
    Offset punto(double x, double y) => Offset(paredX - x * metro, suelo - y * metro);

    // Suelo con marcas de metro, pared y farola.
    canvas.drawLine(Offset(0, suelo), Offset(size.width, suelo),
        Paint()
          ..color = _rejilla
          ..strokeWidth = 2);
    for (var x = 0; x <= anchoMundo; x++) {
      canvas.drawLine(punto(x.toDouble(), 0), punto(x.toDouble(), 0) + const Offset(0, 5), Paint()..color = _rejilla);
    }
    canvas.drawRect(Rect.fromPoints(punto(0, 0), punto(-0.8, altoMundo)), Paint()..color = _pared);
    for (var y = 1; y < altoMundo; y++) {
      canvas.drawLine(punto(0, y.toDouble()), punto(-0.8, y.toDouble()), Paint()..color = _rejilla);
    }
    final farola = punto(0, alto.toDouble());
    canvas.drawCircle(farola, 7, Paint()..color = PaletaNeon.ambarCanales.withOpacity(0.25 + 0.6 * asentado));
    canvas.drawCircle(farola, 3, Paint()..color = PaletaNeon.ambarCanales);
    _rotulo(canvas, '$alto m', punto(-0.4, alto / 2), 13, girar: true);
    if (esEscalera) {
      _rotulo(canvas, '$distanciaFija m', punto(distanciaFija / 2, 0) + const Offset(0, 16), 13);
    }

    final elegida = this.elegida;
    if (elegida == null) {
      if (!esEscalera) {
        _rotulo(canvas, '$largoFijo m', Offset(size.width * 0.25, size.height * 0.12), 15);
      }
      return;
    }
    // La escalera elegida, apoyada en la pared: si es larga se pasa de la
    // farola; si es corta, no llega.
    final largo = largoDe(elegida);
    final pie = pieDe(elegida);
    final subeHasta = alturaApoyada(largo, pie);
    final angulo = math.atan2(subeHasta, pie) + _tambaleo;
    final base = punto(pie, 0);
    final punta = base + Offset(math.cos(angulo), -math.sin(angulo)) * (largo * metro);
    _escalera(canvas, base, punta, metro, _justa ? _madera : PaletaNeon.rosaAcento);
    if (esEscalera) {
      _rotulo(canvas, '$elegida m', base + (punta - base) / 2 + const Offset(-22, -10), 13);
    } else {
      _rotulo(canvas, '$largoFijo m', base + (punta - base) / 2 + const Offset(-22, -10), 13);
      _rotulo(canvas, '$elegida m', punto(pie / 2, 0) + const Offset(0, 16), 13);
    }
  }

  void _escalera(Canvas canvas, Offset base, Offset punta, double metro, Color color) {
    final eje = punta - base;
    final largo = eje.distance;
    if (largo < 1) return;
    final normal = Offset(-eje.dy, eje.dx) / largo * 6;
    final larguero = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base + normal, punta + normal, larguero);
    canvas.drawLine(base - normal, punta - normal, larguero);
    final peldanos = (largo / (metro * 0.5)).floor();
    for (var i = 1; i < peldanos; i++) {
      final p = base + eje * (i / peldanos);
      canvas.drawLine(p + normal, p - normal,
          Paint()
            ..color = color
            ..strokeWidth = 2);
    }
  }

  void _rotulo(Canvas canvas, String texto, Offset centro, double tamano, {bool girar = false}) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: PaletaNeon.textoPrincipal, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    if (girar) canvas.rotate(-math.pi / 2);
    pintor.paint(canvas, Offset(-pintor.width / 2, -pintor.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorAndamio anterior) => true;
}
