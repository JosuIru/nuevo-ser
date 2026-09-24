import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart' show Celda;
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/rebote.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Rebote — segunda sala de Rexán. Medir y clasificar ángulos, disparar
/// el láser para que rebote hasta la diana y dibujar reflejos. Cuenta el
/// primer intento de cada reto.
class PantallaRebote extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  /// «Sin transportador» (reto de la semana): todas las rondas son de
  /// medir a ojo; el transportador aparece al contestar. No puntúa.
  final bool sinTransportador;

  const PantallaRebote({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
    this.sinTransportador = false,
  });

  @override
  State<PantallaRebote> createState() => _PantallaReboteState();
}

class _PantallaReboteState extends State<PantallaRebote>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_rebote';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.rebote);
  static const _tipos = [
    TipoRebote.medir,
    TipoRebote.clasificar,
    TipoRebote.laser,
    TipoRebote.reflexion,
    TipoRebote.simetria,
    TipoRebote.simetria,
  ];

  late final GeneradorRebote _generador;
  late final AnimationController _disparo = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  late RetoRebote _reto;
  final Set<Celda> _dibujadas = {};
  bool _comprobado = false;
  int _ronda = 1;
  int? _elegida;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _terminada = false;
  String? _lineaRexan;
  Map<String, String> _datosLinea = const {};
  DateTime _inicio = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  @override
  void initState() {
    super.initState();
    _generador = GeneradorRebote(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _disparo.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = widget.sinTransportador
        ? _generador.estimar()
        : _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _dibujadas.clear();
    _comprobado = false;
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _disparo.value = 0;
  }

  void _registrar(bool acierto) {
    // A ojo no puntúa: es para afinar la intuición.
    if (_yaRegistrado || widget.sinTransportador) return;
    _yaRegistrado = true;
    widget.registro?.registrar(
      idHabilidad: _reto.idHabilidad,
      acierto: acierto,
      dificultad: 0.8 + 0.3 * _enNivel.dificultad,
      duracion: DateTime.now().difference(_inicio),
    );
  }

  Future<void> _elegir(int opcion) async {
    if (_resuelto || _disparo.isAnimating) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuesta;
    _registrar(acierta);
    setState(() {
      _elegida = opcion;
      _lineaRexan = null;
    });
    if (_reto.tipo == TipoRebote.laser || _reto.tipo == TipoRebote.reflexion) {
      sonar('efecto_tap');
      await _disparo.forward(from: 0);
      if (!mounted) return;
    }
    setState(() {
      _datosLinea = {'v': '$opcion', 'g': '${_reto.grados}'};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          _ when widget.sinTransportador => 'Buen ojo: {g}°.',
          TipoRebote.laser => 'Diana. El foco vuelve a su sitio.',
          TipoRebote.reflexion => 'Sale con {g}°: igual que llegó.',
          _ => 'Medido y apuntado.',
        };
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          _ when widget.sinTransportador =>
            'A ojo engaña. Ahí tienes el transportador: compruébalo y vuelve a elegir.',
          TipoRebote.medir => 'Mira dónde empieza el cero del transportador y cuenta desde ahí.',
          TipoRebote.clasificar => 'Compáralo con una esquina de papel: el recto mide 90°.',
          TipoRebote.laser => _tocaDestello(opcion)
              ? 'Un Destello se ha tragado la luz. Con {v}° no llega.'
              : 'Con {v}° el rayo no da en la diana. Prueba otro.',
          TipoRebote.reflexion => 'El rayo sale del espejo con el mismo ángulo con el que llega.',
          TipoRebote.simetria => '',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      _disparo.value = 0;
      return;
    }
    sonar('efecto_acierto');
    await _siguiente();
  }

  bool _tocaDestello(int grados) {
    final laser = _reto.laser;
    final destello = _reto.destello;
    if (laser == null || destello == null) return false;
    final (x, y) = destello;
    final xRebote = laser.puntoDeRebote(grados);
    final t = math.tan(grados * math.pi / 180);
    final yEnX = x < xRebote ? laser.alturaEmisor - x * t : (x - xRebote) * t;
    return (yEnX - y).abs() < 0.45;
  }

  void _tocarCelda(Celda celda) {
    if (_resuelto || celda.columna < _reto.columnas ~/ 2) return;
    HapticFeedback.selectionClick();
    setState(() {
      _comprobado = false;
      if (!_dibujadas.remove(celda)) _dibujadas.add(celda);
    });
  }

  Future<void> _comprobarSimetria() async {
    if (_resuelto) return;
    final acierta = _dibujadas.length == _reto.reflejo.length && _dibujadas.containsAll(_reto.reflejo);
    _registrar(acierta);
    setState(() {
      _comprobado = true;
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = 'El reflejo, exacto: cada cuadro a la misma distancia del espejo.';
      } else {
        anotarFallo();
        _lineaRexan = 'En rosa, los que sobran; con borde, los que faltan. Cada cuadro, a la misma distancia del espejo.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _siguiente();
  }

  Future<void> _siguiente() async {
    await Future.delayed(const Duration(milliseconds: 1900));
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

  String _nombreAngulo(int indice, Locale locale) => traducirNarrativa(
      const ['agudo', 'recto', 'obtuso', 'llano'][indice], locale);

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? _texto('Seis focos en su sitio. La Industria vuelve a tener luz.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = switch (_reto.tipo) {
      TipoRebote.medir when widget.sinTransportador && _elegida == null =>
        _texto('A ojo, sin transportador: ¿cuántos grados mide?', locale),
      TipoRebote.medir => _texto('¿Cuántos grados mide el ángulo?', locale),
      TipoRebote.clasificar => _texto('¿Qué tipo de ángulo es?', locale),
      TipoRebote.laser => _texto('¿Con qué ángulo hay que disparar para que rebote en el espejo y dé en la diana?', locale),
      TipoRebote.reflexion => _texto('El rayo llega al espejo con {g}°. ¿Con qué ángulo sale?', locale, {'g': '${_reto.grados}'}),
      TipoRebote.simetria => _texto('Dibuja el reflejo de la figura al otro lado del espejo.', locale),
    };
    final simetria = _reto.tipo == TipoRebote.simetria;
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
              key: const ValueKey('pregunta-rebote'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 15, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: simetria
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _reto.columnas / _reto.filas,
                      child: LayoutBuilder(
                        builder: (_, restricciones) {
                          final lienzo = restricciones.biggest;
                          final lado = lienzo.width / _reto.columnas;
                          return GestureDetector(
                            key: const ValueKey('cuadricula-simetria'),
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (d) => _tocarCelda(Celda((d.localPosition.dy / lado).floor(),
                                (d.localPosition.dx / lado).floor())),
                            child: CustomPaint(
                              size: lienzo,
                              painter: PintorSimetria(
                                reto: _reto,
                                dibujadas: _dibujadas,
                                comprobado: _comprobado,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _disparo,
                    builder: (_, __) => CustomPaint(
                      size: Size.infinite,
                      painter: PintorRebote(
                          reto: _reto,
                          elegida: _elegida,
                          progreso: _disparo.value,
                          ocultarTransportador: widget.sinTransportador && _elegida == null),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          if (simetria)
            BotonMinijuego(
              texto: traducirNarrativa('COMPROBAR', locale),
              alPulsar: _resuelto ? null : _comprobarSimetria,
            )
          else
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
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                _reto.tipo == TipoRebote.clasificar ? _nombreAngulo(opcion, locale) : '$opcion°',
                                style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 20),
                              ),
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

/// Transportador, ángulos, láser y espejo.
class PintorRebote extends CustomPainter {
  final RetoRebote reto;
  final int? elegida;
  final double progreso;

  /// «Sin transportador»: el ángulo solo, hasta que se contesta.
  final bool ocultarTransportador;

  PintorRebote({
    required this.reto,
    required this.elegida,
    required this.progreso,
    this.ocultarTransportador = false,
  });

  static const _luz = Color(0xFF7CF2FF);

  @override
  void paint(Canvas canvas, Size size) {
    switch (reto.tipo) {
      case TipoRebote.medir || TipoRebote.clasificar:
        _angulo(canvas, size, conTransportador: reto.tipo == TipoRebote.medir && !ocultarTransportador);
      case TipoRebote.laser:
        _laser(canvas, size);
      case TipoRebote.reflexion:
        _reflexion(canvas, size);
      case TipoRebote.simetria:
        break;
    }
  }

  void _angulo(Canvas canvas, Size size, {required bool conTransportador}) {
    final radio = math.min(size.width * 0.45, size.height * 0.8);
    final centro = Offset(size.width / 2, size.height * 0.85);
    if (conTransportador) {
      final arco = Rect.fromCircle(center: centro, radius: radio);
      canvas.drawArc(arco, math.pi, math.pi, true, Paint()..color = const Color(0xFFE8E2D0).withOpacity(0.12));
      canvas.drawArc(
          arco,
          math.pi,
          math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFFE8E2D0).withOpacity(0.7));
      for (var g = 0; g <= 180; g += 5) {
        final a = -g * math.pi / 180;
        final largo = g % 30 == 0 ? 14.0 : (g % 10 == 0 ? 9.0 : 5.0);
        final exterior = centro + Offset(math.cos(a), math.sin(a)) * radio;
        final interior = centro + Offset(math.cos(a), math.sin(a)) * (radio - largo);
        canvas.drawLine(interior, exterior,
            Paint()
              ..color = const Color(0xFFE8E2D0).withOpacity(0.7)
              ..strokeWidth = 1);
        if (g % 30 == 0) {
          _texto(canvas, '$g', centro + Offset(math.cos(a), math.sin(a)) * (radio - 26), 11, const Color(0xFFE8E2D0));
        }
      }
    }
    // Los dos lados del ángulo: uno sobre el 0, el otro en [grados].
    final lado = Paint()
      ..color = PaletaNeon.ambarCanales
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final a = -reto.grados * math.pi / 180;
    canvas.drawLine(centro, centro + Offset(radio * 0.95, 0), lado);
    canvas.drawLine(centro, centro + Offset(math.cos(a), math.sin(a)) * radio * 0.95, lado);
    canvas.drawArc(Rect.fromCircle(center: centro, radius: radio * 0.2), 0, a, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _luz);
    canvas.drawCircle(centro, 4, Paint()..color = PaletaNeon.ambarCanales);
  }

  void _laser(Canvas canvas, Size size) {
    final laser = reto.laser!;
    final escala = math.min(size.width, size.height) / 10.5;
    final origen = Offset((size.width - 10 * escala) / 2, size.height - (size.height - 10 * escala) / 2);
    Offset punto(double x, double y) => origen + Offset(x * escala, -y * escala);
    // Sala: paredes y espejo en el suelo.
    canvas.drawRect(Rect.fromPoints(punto(0, 10), punto(10, 0)), Paint()..color = const Color(0xFF14102A));
    canvas.drawLine(punto(0, 0), punto(10, 0),
        Paint()
          ..color = const Color(0xFFB9E6FF)
          ..strokeWidth = 4);
    // Emisor y diana.
    canvas.drawRect(Rect.fromCenter(center: punto(0.2, laser.alturaEmisor), width: 14, height: 18),
        Paint()..color = PaletaNeon.grisMetal);
    final diana = punto(9.85, laser.alturaDiana);
    final acertado = elegida == reto.respuesta && progreso >= 1;
    for (final (r, color) in [(14.0, PaletaNeon.rosaAcento), (9.0, Colors.white), (4.0, PaletaNeon.rosaAcento)]) {
      canvas.drawCircle(diana, r, Paint()..color = acertado ? PaletaNeon.exitoSuave : color);
    }
    // La horizontal del emisor: los ángulos se miden desde ella.
    final guia = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.3)
      ..strokeWidth = 1;
    for (var x = 0.4; x < 3; x += 0.4) {
      canvas.drawLine(punto(x, laser.alturaEmisor), punto(x + 0.2, laser.alturaEmisor), guia);
    }
    // El Destello.
    final destello = reto.destello;
    if (destello != null) {
      final centro = punto(destello.$1, destello.$2);
      canvas.drawCircle(centro, 10,
          Paint()
            ..color = PaletaNeon.rosaAcento.withOpacity(0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      final rayo = Paint()
        ..color = PaletaNeon.rosaAcento
        ..strokeWidth = 2;
      for (var k = 0; k < 4; k++) {
        final a = k * math.pi / 4;
        canvas.drawLine(centro - Offset(math.cos(a), math.sin(a)) * 7, centro + Offset(math.cos(a), math.sin(a)) * 7, rayo);
      }
    }
    // El rayo elegido, avanzando.
    final grados = elegida;
    if (grados == null || progreso == 0) return;
    final t = math.tan(grados * math.pi / 180);
    final xRebote = laser.puntoDeRebote(grados);
    final yFinal = (10 - xRebote) * t;
    final puntos = <(double, double)>[
      (0.2, laser.alturaEmisor),
      if (xRebote <= 10) (xRebote, 0) else (10, laser.alturaEmisor - 10 * t),
      if (xRebote <= 10) (10, yFinal),
    ];
    // Si pasa por el Destello, se corta ahí.
    var recorridos = puntos;
    if (destello != null) {
      final (dx, dy) = destello;
      final yEnX = dx < xRebote ? laser.alturaEmisor - dx * t : (dx - xRebote) * t;
      if ((yEnX - dy).abs() < 0.45) {
        recorridos = [
          for (final p in puntos)
            if (p.$1 < dx) p,
          (dx, dy),
        ];
      }
    }
    final camino = Path()..moveTo(punto(recorridos.first.$1, recorridos.first.$2).dx, punto(recorridos.first.$1, recorridos.first.$2).dy);
    for (final p in recorridos.skip(1)) {
      final q = punto(p.$1, math.min(10, p.$2));
      camino.lineTo(q.dx, q.dy);
    }
    final medida = camino.computeMetrics().fold<double>(0, (s, m) => s + m.length);
    final parcial = Path();
    var restante = medida * progreso;
    for (final m in camino.computeMetrics()) {
      final trozo = math.min(restante, m.length);
      parcial.addPath(m.extractPath(0, trozo), Offset.zero);
      restante -= trozo;
      if (restante <= 0) break;
    }
    canvas.drawPath(parcial,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = _luz.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(parcial,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _luz);
  }

  void _reflexion(Canvas canvas, Size size) {
    final suelo = size.height * 0.8;
    final centro = Offset(size.width / 2, suelo);
    canvas.drawLine(Offset(size.width * 0.08, suelo), Offset(size.width * 0.92, suelo),
        Paint()
          ..color = const Color(0xFFB9E6FF)
          ..strokeWidth = 4);
    final largo = math.min(size.width * 0.42, suelo * 0.9);
    final a = reto.grados * math.pi / 180;
    final entrada = centro + Offset(-math.cos(a), -math.sin(a)) * largo;
    final rayo = Paint()
      ..color = _luz
      ..strokeWidth = 2.5;
    canvas.drawLine(entrada, centro, rayo);
    canvas.drawArc(Rect.fromCircle(center: centro, radius: 34), math.pi, a, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = PaletaNeon.ambarCanales);
    _texto(canvas, '${reto.grados}°', centro + Offset(-math.cos(a / 2) * 56, -math.sin(a / 2) * 56), 14, PaletaNeon.ambarCanales);
    final grados = elegida;
    if (grados == null || progreso == 0) return;
    final b = grados * math.pi / 180;
    final salida = centro + Offset(math.cos(b), -math.sin(b)) * largo * progreso;
    canvas.drawLine(centro, salida, rayo..color = grados == reto.grados ? _luz : PaletaNeon.rosaAcento);
    if (progreso >= 1) {
      canvas.drawArc(Rect.fromCircle(center: centro, radius: 34), -b, b, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = PaletaNeon.ambarCanales);
      _texto(canvas, '$grados°', centro + Offset(math.cos(b / 2) * 56, -math.sin(b / 2) * 56), 14, PaletaNeon.ambarCanales);
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tamano, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorRebote anterior) => true;
}

/// Cuadrícula con el espejo en medio: la figura a la izquierda, lo que
/// se dibuja a la derecha. Al comprobar, los sobrantes en rosa y los que
/// faltan con borde.
class PintorSimetria extends CustomPainter {
  final RetoRebote reto;
  final Set<Celda> dibujadas;
  final bool comprobado;

  PintorSimetria({required this.reto, required this.dibujadas, required this.comprobado});

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width / reto.columnas;
    Rect rectDe(Celda c) => Rect.fromLTWH(c.columna * lado, c.fila * lado, lado, lado);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF14102A));
    final rejilla = Paint()
      ..color = PaletaNeon.violetaBase.withOpacity(0.5)
      ..strokeWidth = 1;
    for (var c = 0; c <= reto.columnas; c++) {
      canvas.drawLine(Offset(c * lado, 0), Offset(c * lado, size.height), rejilla);
    }
    for (var f = 0; f <= reto.filas; f++) {
      canvas.drawLine(Offset(0, f * lado), Offset(size.width, f * lado), rejilla);
    }
    for (final celda in reto.figura) {
      canvas.drawRect(rectDe(celda).deflate(2), Paint()..color = PaletaNeon.ambarCanales);
    }
    final reflejo = reto.reflejo;
    for (final celda in dibujadas) {
      final sobra = comprobado && !reflejo.contains(celda);
      canvas.drawRect(rectDe(celda).deflate(2),
          Paint()..color = sobra ? PaletaNeon.rosaAcento.withOpacity(0.8) : const Color(0xFF7CF2FF).withOpacity(0.85));
    }
    if (comprobado) {
      for (final celda in reflejo.difference(dibujadas)) {
        canvas.drawRect(
            rectDe(celda).deflate(3),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = PaletaNeon.exitoSuave);
      }
    }
    // El espejo.
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height),
        Paint()
          ..color = const Color(0xFFB9E6FF)
          ..strokeWidth = 4);
    canvas.drawLine(Offset(x, 0), Offset(x, size.height),
        Paint()
          ..color = const Color(0xFFB9E6FF).withOpacity(0.3)
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  @override
  bool shouldRepaint(PintorSimetria anterior) => true;
}
