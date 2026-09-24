import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/redes.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Las redes — segunda sala de Rexán. Predecir y comprobar: se elige la
/// red de la que es más probable sacar un pez ámbar y la máquina la echa
/// veinte veces. Cuenta la decisión, no la tanda. En el nivel 3, la
/// probabilidad escrita como fracción, decimal o porcentaje.
class PantallaRedes extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaRedes({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaRedes> createState() => _PantallaRedesState();
}

class _PantallaRedesState extends State<PantallaRedes>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_redes';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.redes);
  static const _lances = 20;

  late final math.Random _azar;
  late final GeneradorRedes _generador;
  late final AnimationController _tanda = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));
  late RetoRedes _reto;
  int _ronda = 1;
  int? _elegida;
  String? _opcionElegida;
  List<bool> _resultados = const [];
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
    _azar = math.Random(widget.semilla);
    _generador = GeneradorRedes(azar: _azar);
    _nuevoReto();
  }

  @override
  void dispose() {
    _tanda.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_nivel, dificultad: _enNivel.dificultad);
    _elegida = null;
    _opcionElegida = null;
    _resultados = const [];
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _tanda.value = 0;
  }

  void _registrar(bool acierto) {
    if (_yaRegistrado) return;
    _yaRegistrado = true;
    widget.registro?.registrar(
      idHabilidad: _reto.idHabilidad,
      acierto: acierto,
      dificultad: 0.8 + 0.3 * _enNivel.dificultad,
      duracion: DateTime.now().difference(_inicio),
    );
  }

  Future<void> _elegirRed(int indice) async {
    if (_resuelto || _tanda.isAnimating) return;
    HapticFeedback.selectionClick();
    final acierta = indice == _reto.mejor;
    _registrar(acierta);
    final red = _reto.redes[indice];
    setState(() {
      _elegida = indice;
      _resuelto = true;
      _resultados = lanzar(red, _lances, _azar);
      _lineaRexan = 'Echamos la red veinte veces…';
      _datosLinea = const {};
    });
    sonar('efecto_tap');
    await _tanda.forward(from: 0);
    if (!mounted) return;
    final ambar = _resultados.where((r) => r).length;
    final mejor = _reto.redes[_reto.mejor!];
    setState(() {
      _datosLinea = {
        'k': '$ambar',
        'a': '${red.ambar}',
        't': '${red.total}',
        'ma': '${mejor.ambar}',
        'mt': '${mejor.total}',
      };
      if (acierta) {
        anotarAcierto();
        // Pocos ámbar con la red buena: el azar no juzga la decisión.
        _lineaRexan = ambar / _lances < red.probabilidad - 0.12
            ? 'Esta vez sólo {k} de 20. Mala tanda, buena decisión: {a} de cada {t} era la mejor red.'
            : 'Buena red: {a} de cada {t}. Han salido {k} ámbar de 20.';
      } else {
        anotarFallo();
        _lineaRexan = 'Han salido {k} de 20, pero la mejor era la de {ma} de cada {mt}: tocaba a más.';
      }
    });
    sonar(acierta ? 'efecto_acierto' : 'efecto_error');
    await _siguiente(const Duration(milliseconds: 2600));
  }

  Future<void> _elegirOpcion(String opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuesta;
    _registrar(acierta);
    final red = _reto.redes.single;
    setState(() {
      _opcionElegida = opcion;
      _datosLinea = {'a': '${red.ambar}', 't': '${red.total}', 'o': opcion};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = '{o}: {a} de cada {t}. Da igual cómo se escriba.';
      } else {
        anotarFallo();
        _lineaRexan = '{o} no es {a} de cada {t}. Prueba otra.';
      }
    });
    if (acierta) {
      sonar('efecto_acierto');
      await _siguiente(const Duration(milliseconds: 1800));
    } else {
      sonar('efecto_error');
    }
  }

  Future<void> _siguiente(Duration espera) async {
    await Future.delayed(espera);
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
    final notacion = _reto.tipo == TipoRetoRedes.notacion;
    final linea = _terminada
        ? _texto('Seis redes echadas. Hay peces ámbar para todas las farolas del muelle.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = notacion
        ? _texto('De {t} peces, {a} son ámbar. ¿Qué probabilidad hay de sacar uno ámbar?', locale,
            {'t': '${_reto.redes.single.total}', 'a': '${_reto.redes.single.ambar}'})
        : _texto('¿De qué red es más probable sacar un pez ámbar?', locale);
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
              key: const ValueKey('pregunta-redes'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < _reto.redes.length; i++)
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('red-$i'),
                      onTap: notacion ? null : () => _elegirRed(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Expanded(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: PintorRed(
                                  red: _reto.redes[i],
                                  semilla: _ronda * 10 + i,
                                  elegida: _elegida == i,
                                  mejor: _resuelto && !notacion && _reto.mejor == i,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _texto('{a} ámbar de {t}', locale,
                                  {'a': '${_reto.redes[i].ambar}', 't': '${_reto.redes[i].total}'}),
                              style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (notacion)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: [
                for (final opcion in _reto.opciones)
                  GestureDetector(
                    key: ValueKey('opcion-$opcion'),
                    onTap: () => _elegirOpcion(opcion),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _opcionElegida == opcion
                              ? [PaletaNeon.ambarCanales.withOpacity(0.35), PaletaNeon.ambarCanales.withOpacity(0.1)]
                              : [const Color(0xFF2A1A55), PaletaNeon.fondoMedio],
                        ),
                        border: Border.all(color: PaletaNeon.violetaNeon.withOpacity(0.45)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(opcion,
                          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 22)),
                    ),
                  ),
              ],
            )
          else
            SizedBox(
              height: 64,
              child: AnimatedBuilder(
                animation: _tanda,
                builder: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: PintorTanda(
                    resultados: _resultados,
                    visibles: (_resultados.length * _tanda.value).floor(),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Una red redonda con sus peces: los ámbar brillan, los demás son
/// azules. La posición de cada pez es fija para cada red (semilla).
class PintorRed extends CustomPainter {
  final Red red;
  final int semilla;
  final bool elegida;
  final bool mejor;

  PintorRed({required this.red, required this.semilla, required this.elegida, required this.mejor});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = math.min(size.width, size.height) * 0.46;
    final borde = mejor
        ? PaletaNeon.exitoSuave
        : (elegida ? PaletaNeon.ambarCanales : PaletaNeon.textoTenue.withOpacity(0.6));
    canvas.drawCircle(centro, radio, Paint()..color = const Color(0xFF0B2146));
    // Malla de la red.
    final malla = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;
    for (var k = -6; k <= 6; k++) {
      final d = k * radio / 6;
      final h = math.sqrt(math.max(0, radio * radio - d * d));
      canvas.drawLine(centro + Offset(d - h * 0.2, -h), centro + Offset(d + h * 0.2, h), malla);
      canvas.drawLine(centro + Offset(-h, d - h * 0.2), centro + Offset(h, d + h * 0.2), malla);
    }
    canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = elegida || mejor ? 3 : 2
          ..color = borde);
    // Peces repartidos por la red.
    final azar = math.Random(semilla * 7919 + red.total);
    final tamano = radio * (red.total > 12 ? 0.11 : 0.15);
    for (var i = 0; i < red.total; i++) {
      final angulo = azar.nextDouble() * math.pi * 2;
      final distancia = math.sqrt(azar.nextDouble()) * (radio - tamano * 1.6);
      final posicion = centro + Offset(math.cos(angulo), math.sin(angulo)) * distancia;
      _pez(canvas, posicion, tamano, i < red.ambar, azar.nextBool());
    }
  }

  void _pez(Canvas canvas, Offset centro, double tamano, bool ambar, bool haciaIzquierda) {
    final color = ambar ? PaletaNeon.ambarCanales : const Color(0xFF4D86C9);
    final s = haciaIzquierda ? -1.0 : 1.0;
    final cuerpo = Rect.fromCenter(center: centro, width: tamano * 2, height: tamano * 1.1);
    canvas.drawOval(cuerpo, Paint()..color = color);
    final cola = Path()
      ..moveTo(centro.dx - s * tamano * 0.9, centro.dy)
      ..lineTo(centro.dx - s * tamano * 1.5, centro.dy - tamano * 0.5)
      ..lineTo(centro.dx - s * tamano * 1.5, centro.dy + tamano * 0.5)
      ..close();
    canvas.drawPath(cola, Paint()..color = color);
    if (ambar) {
      canvas.drawCircle(centro, tamano * 1.4,
          Paint()
            ..color = PaletaNeon.ambarCanales.withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  @override
  bool shouldRepaint(PintorRed anterior) => true;
}

/// Los veinte lances en fila: cada uno, un pez ámbar o azul, y la cuenta.
class PintorTanda extends CustomPainter {
  final List<bool> resultados;
  final int visibles;

  PintorTanda({required this.resultados, required this.visibles});

  @override
  void paint(Canvas canvas, Size size) {
    if (resultados.isEmpty) return;
    final paso = size.width / resultados.length;
    for (var i = 0; i < visibles; i++) {
      final centro = Offset((i + 0.5) * paso, size.height * 0.35);
      canvas.drawCircle(centro, paso * 0.32,
          Paint()..color = resultados[i] ? PaletaNeon.ambarCanales : const Color(0xFF4D86C9));
    }
    final ambar = resultados.take(visibles).where((r) => r).length;
    final pintor = TextPainter(
      text: TextSpan(
          text: '$ambar / $visibles',
          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, Offset((size.width - pintor.width) / 2, size.height * 0.7));
  }

  @override
  bool shouldRepaint(PintorTanda anterior) => true;
}
