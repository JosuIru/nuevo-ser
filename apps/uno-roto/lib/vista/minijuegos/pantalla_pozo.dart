import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/pozo.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Un entero con el signo menos tipográfico (−4, no -4).
String conSigno(int n) => n < 0 ? '−${-n}' : '$n';

/// El pozo — segunda sala de Rexán. Se toca la planta donde acabará el
/// ascensor y el ascensor hace el viaje de verdad, orden a orden. La
/// primera respuesta es la que cuenta; el viaje enseña dónde para. En la
/// distancia entre dos plantas, se elige entre cuatro números.
class PantallaPozo extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaPozo({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaPozo> createState() => _PantallaPozoState();
}

class _PantallaPozoState extends State<PantallaPozo>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_pozo';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.pozo);
  static const _tipos = [
    TipoPozo.viaje,
    TipoPozo.viaje,
    TipoPozo.viaje,
    TipoPozo.viaje,
    TipoPozo.espejo,
    TipoPozo.distancia,
  ];

  late final GeneradorPozo _generador;
  late final AnimationController _viaje = AnimationController(vsync: this);
  late RetoPozo _reto;
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
    _generador = GeneradorPozo(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _viaje.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], nivel: _nivel, dificultad: _enNivel.dificultad);
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _viaje.value = 0;
  }

  /// Las paradas del ascensor en este reto.
  List<int> get _paradas => switch (_reto.tipo) {
        TipoPozo.viaje => recorrido(_reto.inicio, _reto.ordenes),
        TipoPozo.espejo => [0, _reto.respuesta],
        TipoPozo.distancia => [_reto.plantas.first, _reto.plantas.last],
      };

  /// Plantas que se ven: lo que recorre y un poco de margen.
  (int, int) get _rango {
    final todas = [..._paradas, ..._reto.plantas, 0];
    var abajo = todas.reduce(math.min) - 2;
    var arriba = todas.reduce(math.max) + 2;
    while (arriba - abajo < 12) {
      arriba++;
      abajo--;
    }
    return (abajo, arriba);
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

  Future<void> _elegirPlanta(int planta) async {
    if (_resuelto || _reto.tipo == TipoPozo.distancia) return;
    HapticFeedback.selectionClick();
    final acierta = planta == _reto.respuesta;
    _registrar(acierta);
    setState(() {
      _elegida = planta;
      _resuelto = true;
      _lineaRexan = null;
    });
    sonar('efecto_tablon');
    _viaje.duration = Duration(milliseconds: 550 * math.max(1, _paradas.length - 1));
    await _viaje.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _datosLinea = {
        'r': conSigno(_reto.respuesta),
        't': conSigno(planta),
        'd': '${_reto.respuesta.abs()}',
        'e': '${planta.abs()}',
        'f': _reto.plantas.isEmpty ? '' : conSigno(_reto.plantas.first),
      };
      if (acierta) {
        anotarAcierto();
        _lineaRexan = 'Planta {r}. Justo donde dijiste.';
      } else {
        anotarFallo();
        _lineaRexan = _reto.tipo == TipoPozo.espejo
            ? 'La {f} está a {d} plantas del suelo; la {t}, a {e}. La del otro lado es la {r}.'
            : 'El ascensor para en la {r}, no en la {t}.';
      }
    });
    sonar(acierta ? 'efecto_acierto' : 'efecto_error');
    await _siguiente();
  }

  Future<void> _elegirOpcion(int opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuesta;
    _registrar(acierta);
    final [a, b] = _reto.plantas;
    setState(() {
      _elegida = opcion;
      _datosLinea = {'a': conSigno(math.min(a, b)), 'b': conSigno(math.max(a, b)), 'r': '${_reto.respuesta}'};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = '{r} plantas, pasando por el suelo.';
      } else {
        anotarFallo();
        _lineaRexan = 'Cuenta las plantas de la {a} a la {b}, pasando por el suelo.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    _viaje.duration = const Duration(milliseconds: 1200);
    await _viaje.forward(from: 0);
    await _siguiente();
  }

  Future<void> _siguiente() async {
    await Future.delayed(const Duration(milliseconds: 2200));
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
    final linea = _terminada
        ? _texto('Seis viajes a oscuras sin perderte. La mina ya tiene luz.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = switch (_reto.tipo) {
      TipoPozo.viaje => _texto('Sales de la planta {p}. ¿Dónde acaba el ascensor? Toca la planta.', locale,
          {'p': conSigno(_reto.inicio)}),
      TipoPozo.espejo => _texto(
          'Baja o sube a la planta que está a la misma distancia del suelo que la {p}, al otro lado.',
          locale,
          {'p': conSigno(_reto.plantas.single)}),
      TipoPozo.distancia => _texto('¿Cuántas plantas hay de la {a} a la {b}?', locale,
          {'a': conSigno(_reto.plantas.first), 'b': conSigno(_reto.plantas.last)}),
    };
    final (abajo, arriba) = _rango;
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
              key: const ValueKey('pregunta-pozo'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 15, height: 1.35)),
          if (_reto.ordenes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [for (final orden in _reto.ordenes) _FichaOrden(orden: orden, locale: locale)],
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, restricciones) {
                final lienzo = restricciones.biggest;
                return GestureDetector(
                  key: const ValueKey('pozo'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) {
                    final alto = lienzo.height / (arriba - abajo + 1);
                    final planta = arriba - (d.localPosition.dy / alto).floor();
                    _elegirPlanta(planta.clamp(abajo, arriba));
                  },
                  child: AnimatedBuilder(
                    animation: _viaje,
                    builder: (_, __) => CustomPaint(
                      size: lienzo,
                      painter: PintorPozo(
                        abajo: abajo,
                        arriba: arriba,
                        paradas: _paradas,
                        progreso: _resuelto || _viaje.value > 0 ? _viaje.value : 0,
                        elegida: _reto.tipo == TipoPozo.distancia ? null : _elegida,
                        marcadas: _reto.plantas,
                        mostrarDistancia: _reto.tipo == TipoPozo.distancia && _resuelto,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_reto.tipo == TipoPozo.distancia) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final opcion in _reto.opciones)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        key: ValueKey('opcion-$opcion'),
                        onTap: () => _elegirOpcion(opcion),
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
                          child: Text('$opcion',
                              style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 22)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Una orden del panel. Los Signos llevan icono y rótulo propios.
class _FichaOrden extends StatelessWidget {
  final Orden orden;
  final Locale locale;

  const _FichaOrden({required this.orden, required this.locale});

  @override
  Widget build(BuildContext contexto) {
    final esSigno = orden.tipo == TipoOrden.invertido || orden.tipo == TipoOrden.eco;
    final color = switch (orden.tipo) {
      TipoOrden.invertido => PaletaNeon.rosaAcento,
      TipoOrden.eco => PaletaNeon.azulNeon,
      TipoOrden.dobleNegacion => PaletaNeon.exitoSuave,
      TipoOrden.mover => PaletaNeon.ambarCanales,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: esSigno
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(orden.tipo == TipoOrden.invertido ? Icons.swap_vert : Icons.replay, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                traducirNarrativa(orden.tipo == TipoOrden.invertido ? 'invierte la siguiente' : 'repite la anterior',
                    locale),
                style: TextStyle(color: color, fontSize: 12),
              ),
            ])
          : Text(orden.etiqueta, style: TextStyle(color: color, fontSize: 18)),
    );
  }
}

/// El pozo de la mina: plantas numeradas, el suelo (0) iluminado, roca
/// oscura por debajo, y la cabina que viaja parada a parada.
class PintorPozo extends CustomPainter {
  final int abajo;
  final int arriba;
  final List<int> paradas;
  final double progreso;
  final int? elegida;
  final List<int> marcadas;
  final bool mostrarDistancia;

  PintorPozo({
    required this.abajo,
    required this.arriba,
    required this.paradas,
    required this.progreso,
    required this.elegida,
    required this.marcadas,
    required this.mostrarDistancia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plantas = arriba - abajo + 1;
    final alto = size.height / plantas;
    double yDe(num planta) => (arriba - planta + 0.5) * alto;
    final pozo = Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height);

    // Cielo arriba del suelo, roca debajo.
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, yDe(0) + alto / 2),
        Paint()..color = const Color(0xFF1A1440));
    canvas.drawRect(Rect.fromLTRB(0, yDe(0) + alto / 2, size.width, size.height),
        Paint()..color = const Color(0xFF0B0716));
    canvas.drawRect(pozo, Paint()..color = Colors.black.withOpacity(0.35));

    for (var planta = abajo; planta <= arriba; planta++) {
      final y = yDe(planta);
      final esSuelo = planta == 0;
      final marcada = marcadas.contains(planta);
      final esElegida = planta == elegida;
      canvas.drawLine(Offset(pozo.left, y + alto / 2), Offset(pozo.right, y + alto / 2),
          Paint()
            ..color = (esSuelo ? PaletaNeon.ambarCanales : PaletaNeon.violetaBase).withOpacity(esSuelo ? 0.9 : 0.4)
            ..strokeWidth = esSuelo ? 2.5 : 1);
      if (esElegida || marcada) {
        canvas.drawRect(Rect.fromLTRB(pozo.left, y - alto / 2 + 1, pozo.right, y + alto / 2 - 1),
            Paint()..color = (esElegida ? PaletaNeon.ambarCanales : PaletaNeon.azulNeon).withOpacity(0.2));
      }
      final tamano = math.min(14.0, alto * 0.7);
      _texto(canvas, conSigno(planta), Offset(pozo.left - 22, y),
          esSuelo ? PaletaNeon.ambarCanales : PaletaNeon.textoTenue, tamano);
    }

    // Distancia: se iluminan las plantas entre las dos.
    if (mostrarDistancia && marcadas.length == 2) {
      final desde = marcadas.reduce(math.min);
      final hasta = marcadas.reduce(math.max);
      final visibles = ((hasta - desde) * progreso).floor();
      for (var k = 1; k <= visibles; k++) {
        _texto(canvas, '$k', Offset(pozo.right + 18, yDe(desde + k)), PaletaNeon.exitoSuave, math.min(13.0, alto * 0.7));
      }
    }

    // La cabina, entre paradas.
    final tramos = paradas.length - 1;
    double posicion;
    if (tramos <= 0 || mostrarDistancia) {
      posicion = paradas.first.toDouble();
    } else {
      final t = (progreso * tramos).clamp(0.0, tramos.toDouble());
      final i = t.floor().clamp(0, tramos - 1);
      final local = Curves.easeInOut.transform(t - i);
      posicion = paradas[i] + (paradas[i + 1] - paradas[i]) * local;
    }
    final cabina = Rect.fromCenter(center: Offset(pozo.center.dx, yDe(posicion)),
        width: pozo.width * 0.7, height: math.max(alto * 0.8, 14));
    canvas.drawLine(Offset(pozo.center.dx, 0), Offset(pozo.center.dx, cabina.top),
        Paint()
          ..color = PaletaNeon.grisMetal.withOpacity(0.5)
          ..strokeWidth = 1.5);
    canvas.drawRRect(RRect.fromRectAndRadius(cabina, const Radius.circular(3)),
        Paint()..color = PaletaNeon.grisMetal);
    canvas.drawRect(cabina.deflate(3), Paint()..color = PaletaNeon.ambarCanales.withOpacity(0.8));
  }

  void _texto(Canvas canvas, String texto, Offset centro, Color color, double tamano) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorPozo anterior) => true;
}
