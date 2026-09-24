import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/caja_negra.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// La caja negra — segunda sala de Rexán. Experimentar es gratis (hasta
/// agotar los intentos); cuenta la predicción final, en el primer
/// intento. La pregunta es por un número mayor que los que se pueden
/// probar: hay que haber entendido la regla.
class PantallaCajaNegra extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaCajaNegra({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaCajaNegra> createState() => _PantallaCajaNegraState();
}

class _PantallaCajaNegraState extends State<PantallaCajaNegra>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_caja_negra';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.cajaNegra);
  static const _tipos = [
    TipoCaja.directa,
    TipoCaja.directa,
    TipoCaja.directa,
    TipoCaja.directa,
    TipoCaja.inversa,
    TipoCaja.gemelas,
  ];

  late final GeneradorCaja _generador;
  late RetoCaja _reto;

  /// Filas de la tabla: entrada y salida (null si se lo tragó un Mudo).
  final List<(int, int?)> _filas = [];
  int _experimentosUsados = 0;
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
    _generador = GeneradorCaja(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], nivel: _nivel, dificultad: _enNivel.dificultad);
    _filas
      ..clear()
      ..addAll([for (final x in _reto.filasIniciales) (x, _reto.regla.aplicar(x))]);
    _experimentosUsados = 0;
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
  }

  bool get _quedanExperimentos => _experimentosUsados < _reto.experimentos;

  void _meter(int x) {
    if (_resuelto || !_quedanExperimentos || _filas.any((f) => f.$1 == x)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _experimentosUsados++;
      if (x == _reto.mudo) {
        _filas.add((x, null));
        _lineaRexan = 'Glup. Ese se lo ha tragado: es un Mudo.';
        sonar('efecto_tablon');
      } else {
        _filas.add((x, _reto.regla.aplicar(x)));
        _lineaRexan = null;
        sonar('efecto_tap');
      }
      _datosLinea = const {};
    });
  }

  Future<void> _responder(int opcion) async {
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
      _datosLinea = {'v': '$opcion', 'y': '${_reto.dato}'};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = 'Clic. La caja se abre.';
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoCaja.directa => 'Con esa respuesta, alguna fila de la tabla no cuadra. Compruébalas todas.',
          TipoCaja.inversa => 'Mete {v} en la regla de la tabla: ¿sale {y}?',
          TipoCaja.gemelas => 'Si el rojo pesa {v}, alguna de las dos balanzas no cuadra.',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await Future.delayed(const Duration(milliseconds: 1700));
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
    final gemelas = _reto.tipo == TipoCaja.gemelas;
    final linea = _terminada
        ? _texto('Seis cajas abiertas. En la Montaña ya nadie les tiene miedo.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = switch (_reto.tipo) {
      TipoCaja.directa => _texto('Si entra {n}, ¿qué sale?', locale, {'n': '${_reto.dato}'}),
      TipoCaja.inversa => _texto('Ha salido {n}. ¿Qué número entró?', locale, {'n': '${_reto.dato}'}),
      TipoCaja.gemelas => _texto('¿Cuánto pesa el saco rojo?', locale),
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
          Expanded(
            child: gemelas
                ? CustomPaint(
                    size: Size.infinite,
                    painter: PintorGemelas(
                      pesoRojos: _reto.regla.a,
                      suma: _reto.dato,
                      diferencia: _reto.dato2!,
                      abierta: _resuelto,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey('pensando-${_filas.length}-$_resuelto'),
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 700),
                          builder: (_, pensando, __) => CustomPaint(
                            size: Size.infinite,
                            painter: PintorCaja(pensando: pensando, abierta: _resuelto),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(flex: 4, child: _Tabla(filas: _filas, locale: locale)),
                    ],
                  ),
          ),
          if (!gemelas) ...[
            const SizedBox(height: 8),
            Text(
              _texto('Prueba números ({n} intentos)', locale,
                  {'n': '${_reto.experimentos - _experimentosUsados}'}),
              style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.85), fontSize: 12, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final x in _reto.probables)
                  GestureDetector(
                    key: ValueKey('probar-$x'),
                    onTap: () => _meter(x),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _filas.any((f) => f.$1 == x)
                            ? PaletaNeon.fondoProfundo
                            : const Color(0xFF2A1A55),
                        border: Border.all(
                            color: PaletaNeon.violetaNeon
                                .withOpacity(_quedanExperimentos && !_filas.any((f) => f.$1 == x) ? 0.6 : 0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$x',
                          style: TextStyle(
                              color: PaletaNeon.textoPrincipal
                                  .withOpacity(_filas.any((f) => f.$1 == x) ? 0.35 : 1),
                              fontSize: 15)),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(pregunta,
              key: const ValueKey('pregunta-caja'),
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 17)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: [
              for (final opcion in _reto.opciones)
                GestureDetector(
                  key: ValueKey('opcion-$opcion'),
                  onTap: () => _responder(opcion),
                  child: Container(
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
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Tabla extends StatelessWidget {
  final List<(int, int?)> filas;
  final Locale locale;

  const _Tabla({required this.filas, required this.locale});

  @override
  Widget build(BuildContext contexto) {
    TextStyle estilo(double opacidad) =>
        TextStyle(color: PaletaNeon.textoPrincipal.withOpacity(opacidad), fontSize: 18);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoProfundo.withOpacity(0.7),
        border: Border.all(color: PaletaNeon.violetaBase.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(children: [
            for (final titulo in ['ENTRA', 'SALE'])
              Expanded(
                child: Text(traducirNarrativa(titulo, locale),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 11, letterSpacing: 2)),
              ),
          ]),
          const Divider(color: PaletaNeon.violetaBase, height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final (entra, sale) in filas)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Expanded(child: Text('$entra', textAlign: TextAlign.center, style: estilo(1))),
                      Expanded(
                          child: Text(sale == null ? '—' : '$sale',
                              textAlign: TextAlign.center, style: estilo(sale == null ? 0.4 : 1))),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La caja de hierro: tolva arriba, tubo abajo, remaches y tres luces
/// que parpadean mientras piensa. Abierta, la tapa se levanta.
class PintorCaja extends CustomPainter {
  final double pensando;
  final bool abierta;

  PintorCaja({required this.pensando, required this.abierta});

  @override
  void paint(Canvas canvas, Size size) {
    final lado = math.min(size.width * 0.8, size.height * 0.62);
    final caja = Rect.fromCenter(center: size.center(Offset.zero), width: lado, height: lado);
    // Tolva.
    final tolva = Path()
      ..moveTo(caja.center.dx - lado * 0.22, caja.top - lado * 0.2)
      ..lineTo(caja.center.dx + lado * 0.22, caja.top - lado * 0.2)
      ..lineTo(caja.center.dx + lado * 0.08, caja.top)
      ..lineTo(caja.center.dx - lado * 0.08, caja.top)
      ..close();
    canvas.drawPath(tolva, Paint()..color = const Color(0xFF4A4370));
    // Tubo de salida.
    canvas.drawRect(Rect.fromLTWH(caja.right - 4, caja.bottom - lado * 0.3, lado * 0.18, lado * 0.12),
        Paint()..color = const Color(0xFF4A4370));
    // Cuerpo.
    canvas.drawRRect(
      RRect.fromRectAndRadius(caja, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A355E), Color(0xFF14102A)],
        ).createShader(caja),
    );
    final remache = Paint()..color = PaletaNeon.grisMetal.withOpacity(0.6);
    for (final esquina in [caja.topLeft, caja.topRight, caja.bottomLeft, caja.bottomRight]) {
      final dentro = Offset(esquina.dx + (esquina.dx < caja.center.dx ? 10 : -10),
          esquina.dy + (esquina.dy < caja.center.dy ? 10 : -10));
      canvas.drawCircle(dentro, 3, remache);
    }
    // Luces: parpadean mientras piensa; verdes si está abierta.
    for (var i = 0; i < 3; i++) {
      final encendida = abierta || (pensando < 1 && ((pensando * 6).floor() + i) % 3 == 0);
      final color = abierta ? PaletaNeon.exitoSuave : PaletaNeon.ambarCanales;
      final centro = Offset(caja.center.dx + (i - 1) * lado * 0.22, caja.center.dy + lado * 0.1);
      canvas.drawCircle(centro, lado * 0.06, Paint()..color = color.withOpacity(encendida ? 1 : 0.2));
      if (encendida) {
        canvas.drawCircle(centro, lado * 0.12,
            Paint()
              ..color = color.withOpacity(0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
    }
    // Signo de interrogación grabado (o abierta).
    final pintor = TextPainter(
      text: TextSpan(
          text: abierta ? '' : '?',
          style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.5), fontSize: lado * 0.28)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, Offset(caja.center.dx - pintor.width / 2, caja.top + lado * 0.08));
  }

  @override
  bool shouldRepaint(PintorCaja anterior) =>
      anterior.pensando != pensando || anterior.abierta != abierta;
}

/// Las gemelas: dos balanzas en equilibrio. En la primera, los sacos
/// rojos y el azul frente a sus pesas; en la segunda, un rojo frente al
/// azul más la diferencia.
class PintorGemelas extends CustomPainter {
  final int pesoRojos;
  final int suma;
  final int diferencia;
  final bool abierta;

  PintorGemelas({
    required this.pesoRojos,
    required this.suma,
    required this.diferencia,
    required this.abierta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mitad = size.height / 2;
    _balanza(canvas, Rect.fromLTWH(0, 0, size.width, mitad),
        izquierda: [for (var i = 0; i < pesoRojos; i++) true, false], derecha: '$suma');
    _balanza(canvas, Rect.fromLTWH(0, mitad, size.width, mitad),
        izquierda: [true], derecha: '+$diferencia', derechaSaco: true);
  }

  void _balanza(Canvas canvas, Rect zona,
      {required List<bool> izquierda, required String derecha, bool derechaSaco = false}) {
    final fulcro = Offset(zona.center.dx, zona.top + zona.height * 0.35);
    final brazo = zona.width * 0.36;
    final linea = Paint()
      ..color = const Color(0xFFB9B2DE)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(fulcro, Offset(fulcro.dx, zona.bottom - 8), linea..strokeWidth = 3);
    canvas.drawLine(fulcro - Offset(brazo, 0), fulcro + Offset(brazo, 0), linea..strokeWidth = 4);
    canvas.drawCircle(fulcro, 6, Paint()..color = abierta ? PaletaNeon.exitoSuave : PaletaNeon.violetaNeon);
    final platoIzquierdo = fulcro + Offset(-brazo, zona.height * 0.28);
    final platoDerecho = fulcro + Offset(brazo, zona.height * 0.28);
    for (final plato in [platoIzquierdo, platoDerecho]) {
      canvas.drawLine(plato - Offset(zona.width * 0.13, 0), plato + Offset(zona.width * 0.13, 0), linea..strokeWidth = 3);
    }
    // Sacos a la izquierda (rojos y azul).
    final anchoSaco = zona.width * 0.07;
    for (var i = 0; i < izquierda.length; i++) {
      final x = platoIzquierdo.dx - (izquierda.length - 1) * anchoSaco * 0.6 + i * anchoSaco * 1.2;
      _saco(canvas, Offset(x, platoIzquierdo.dy), anchoSaco,
          izquierda[i] ? const Color(0xFFD65A48) : const Color(0xFF4D86C9));
    }
    // A la derecha: pesas con su número (y el azul en la segunda).
    var x = platoDerecho.dx;
    if (derechaSaco) {
      _saco(canvas, Offset(x - anchoSaco * 0.8, platoDerecho.dy), anchoSaco, const Color(0xFF4D86C9));
      x += anchoSaco * 0.6;
    }
    final pesa = Rect.fromCenter(center: Offset(x, platoDerecho.dy - 14), width: anchoSaco * 1.6, height: 26);
    canvas.drawRRect(RRect.fromRectAndRadius(pesa, const Radius.circular(4)),
        Paint()..color = const Color(0xFF2E7FA8));
    final pintor = TextPainter(
      text: TextSpan(text: derecha, style: const TextStyle(color: Colors.white, fontSize: 15)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, pesa.center - Offset(pintor.width / 2, pintor.height / 2));
  }

  void _saco(Canvas canvas, Offset base, double ancho, Color color) {
    final saco = Path()
      ..moveTo(base.dx - ancho * 0.2, base.dy - ancho * 1.3)
      ..quadraticBezierTo(base.dx - ancho * 0.7, base.dy - ancho * 0.5, base.dx - ancho * 0.5, base.dy)
      ..lineTo(base.dx + ancho * 0.5, base.dy)
      ..quadraticBezierTo(base.dx + ancho * 0.7, base.dy - ancho * 0.5, base.dx + ancho * 0.2, base.dy - ancho * 1.3)
      ..close();
    canvas.drawPath(saco, Paint()..color = color);
  }

  @override
  bool shouldRepaint(PintorGemelas anterior) => true;
}
