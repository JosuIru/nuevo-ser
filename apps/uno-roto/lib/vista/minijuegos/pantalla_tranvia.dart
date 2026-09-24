import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/tranvia.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// El tranvía — segunda sala de Rexán. Se toca la vía para parar el
/// tranvía en una parada (la más cercana al dedo) y el tranvía va hasta
/// allí; en los Revisores se elige el billete entre cuatro. Cuenta el
/// primer intento de cada reto.
class PantallaTranvia extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaTranvia({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaTranvia> createState() => _PantallaTranviaState();
}

class _PantallaTranviaState extends State<PantallaTranvia>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_tranvia';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.tranvia);
  static const _tipos = [
    TipoTranvia.situar,
    TipoTranvia.situar,
    TipoTranvia.redondear,
    TipoTranvia.redondear,
    TipoTranvia.multiplicar,
    TipoTranvia.dividir,
  ];

  late final GeneradorTranvia _generador;
  late final AnimationController _viaje = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
  late RetoTranvia _reto;
  int _ronda = 1;
  int? _parada;
  int? _opcion;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _terminada = false;
  String? _lineaRexan;
  Map<String, String> _datosLinea = const {};
  DateTime _inicio = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  bool get _esRevisor =>
      _reto.tipo != TipoTranvia.situar && _reto.tipo != TipoTranvia.redondear;

  @override
  void initState() {
    super.initState();
    _generador = GeneradorTranvia(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _viaje.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    var tipo = _tipos[_ronda - 1];
    // En dificultad alta, el revisor de multiplicar pide decimal por decimal.
    if (tipo == TipoTranvia.multiplicar && _enNivel.dificultad >= 2) tipo = TipoTranvia.multiplicarDecimales;
    _reto = _generador.generar(tipo, dificultad: _enNivel.dificultad);
    _parada = null;
    _opcion = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = _esRevisor ? 'Sube un Revisor. Billete, por favor.' : null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _viaje.value = 0;
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

  Future<void> _parar(double fraccion) async {
    if (_resuelto || _esRevisor || _viaje.isAnimating) return;
    final paradas = (_reto.hasta - _reto.desde) ~/ _reto.paso;
    final indice = (fraccion * paradas).round().clamp(0, paradas);
    final parada = _reto.desde + indice * _reto.paso;
    HapticFeedback.selectionClick();
    final acierta = parada == _reto.respuesta;
    _registrar(acierta);
    setState(() => _parada = parada);
    sonar('efecto_tap');
    await _viaje.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _datosLinea = {'p': enDecimal(parada), 'r': enDecimal(_reto.respuesta), 'v': enDecimal(_reto.valor)};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = _reto.tipo == TipoTranvia.redondear
            ? '{v} está más cerca de {r}. Parada.'
            : 'Parada {r}. Todos abajo.';
      } else {
        anotarFallo();
        _lineaRexan = _reto.tipo == TipoTranvia.redondear
            ? 'Paramos en {p}, pero {v} queda más cerca de otra parada.'
            : 'Esta es la {p}. Busca la {r}.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _siguiente();
  }

  Future<void> _elegir(int opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuesta;
    _registrar(acierta);
    setState(() {
      _opcion = opcion;
      _datosLinea = {'o': enDecimal(opcion)};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = '{o} €. El Revisor se baja contento.';
      } else {
        anotarFallo();
        _lineaRexan = '{o} € no. Mira bien dónde va la coma.';
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
    await Future.delayed(const Duration(milliseconds: 1800));
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
        ? _texto('Seis viajes sin perder ni una parada. Última estación.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = switch (_reto.tipo) {
      TipoTranvia.situar => _texto('Lleva el tranvía a la parada {v}. Toca la vía.', locale, {'v': enDecimal(_reto.valor)}),
      TipoTranvia.redondear => _texto(
          _reto.paso == 100
              ? 'El viajero va a {v}. ¿En qué parada (número entero) baja, la más cercana?'
              : 'El viajero va a {v}. ¿En qué parada de décimas baja, la más cercana?',
          locale,
          {'v': enDecimal(_reto.valor)}),
      TipoTranvia.multiplicar => _texto('Billete: {k} viajes de {p} €. ¿Cuánto es?', locale, {'k': '${d[0]}', 'p': enDecimal(d[1])}),
      TipoTranvia.multiplicarDecimales =>
        _texto('Billete: el {a} del precio de {b} €. ¿Cuánto es?', locale, {'a': enDecimal(d[0]), 'b': enDecimal(d[1])}),
      TipoTranvia.dividir =>
        _texto('Billete: {p} € entre {k} viajeros. ¿Cuánto paga cada uno?', locale, {'p': enDecimal(d[0]), 'k': '${d[1]}'}),
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
              key: const ValueKey('pregunta-tranvia'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, restricciones) {
                final lienzo = restricciones.biggest;
                return GestureDetector(
                  key: const ValueKey('via'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (detalles) {
                    final margen = PintorVia.margen;
                    _parar(((detalles.localPosition.dx - margen) / (lienzo.width - 2 * margen)).clamp(0.0, 1.0));
                  },
                  child: AnimatedBuilder(
                    animation: _viaje,
                    builder: (_, __) => CustomPaint(
                      size: lienzo,
                      painter: PintorVia(reto: _reto, parada: _parada, progreso: _viaje.value, revisor: _esRevisor),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_esRevisor) ...[
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
                              colors: _opcion == opcion
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
                              child: Text('${enDecimal(opcion)} €',
                                  style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 20)),
                            ),
                          ),
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

/// La vía como recta numérica: paradas, rótulos, el viajero (al
/// redondear) y el tranvía que viaja hasta la parada elegida. Con un
/// Revisor, el billete en grande.
class PintorVia extends CustomPainter {
  static const margen = 24.0;

  final RetoTranvia reto;
  final int? parada;
  final double progreso;
  final bool revisor;

  PintorVia({required this.reto, required this.parada, required this.progreso, required this.revisor});

  @override
  void paint(Canvas canvas, Size size) {
    if (revisor) {
      _billete(canvas, size);
      return;
    }
    final y = size.height * 0.62;
    final largo = size.width - 2 * margen;
    double xDe(int centesimas) => margen + (centesimas - reto.desde) / (reto.hasta - reto.desde) * largo;
    // Raíles.
    for (final dy in [-4.0, 4.0]) {
      canvas.drawLine(Offset(margen - 10, y + dy), Offset(size.width - margen + 10, y + dy),
          Paint()
            ..color = PaletaNeon.grisMetal
            ..strokeWidth = 2);
    }
    // Paradas y rótulos (cada parada, rótulo en las enteras y medias).
    final paradas = (reto.hasta - reto.desde) ~/ reto.paso;
    for (var i = 0; i <= paradas; i++) {
      final valor = reto.desde + i * reto.paso;
      final x = xDe(valor);
      final entera = valor % 100 == 0;
      final media = valor % 50 == 0;
      canvas.drawLine(Offset(x, y - (entera ? 18 : 10)), Offset(x, y + 10),
          Paint()
            ..color = entera ? PaletaNeon.textoPrincipal : PaletaNeon.textoTenue
            ..strokeWidth = entera ? 2 : 1);
      // Rótulos sólo en las unidades y las medias: el resto se cuenta.
      if (entera || media) {
        _texto(canvas, enDecimal(valor), Offset(x, y + 26), entera ? 13 : 11,
            entera ? PaletaNeon.textoPrincipal : PaletaNeon.textoTenue);
      }
    }
    // El viajero (redondear): una marca con su número.
    if (reto.tipo == TipoTranvia.redondear) {
      final x = xDe(reto.valor);
      canvas.drawCircle(Offset(x, y - 30), 7, Paint()..color = PaletaNeon.rosaAcento);
      canvas.drawLine(Offset(x, y - 23), Offset(x, y - 6),
          Paint()
            ..color = PaletaNeon.rosaAcento
            ..strokeWidth = 2);
      _texto(canvas, enDecimal(reto.valor), Offset(x, y - 48), 13, PaletaNeon.rosaAcento);
    }
    // El tranvía: sale del principio y va a la parada elegida.
    final destino = parada;
    final xTranvia = destino == null
        ? xDe(reto.desde)
        : xDe(reto.desde) + (xDe(destino) - xDe(reto.desde)) * Curves.easeInOut.transform(progreso);
    final cuerpo = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(xTranvia, y - 16), width: 46, height: 22), const Radius.circular(6));
    canvas.drawRRect(cuerpo, Paint()..color = PaletaNeon.ambarCanales);
    for (final dx in [-12.0, 0.0, 12.0]) {
      canvas.drawRect(Rect.fromCenter(center: Offset(xTranvia + dx, y - 19), width: 8, height: 7),
          Paint()..color = const Color(0xFF14102A));
    }
    canvas.drawLine(Offset(xTranvia, y - 27), Offset(xTranvia + 8, y - 44),
        Paint()
          ..color = PaletaNeon.grisMetal
          ..strokeWidth = 1.5);
  }

  void _billete(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.7, height: size.height * 0.5);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()..color = const Color(0xFFE8E2D0));
    // Troquel del billete.
    for (var y = rect.top + 8; y < rect.bottom - 4; y += 10) {
      canvas.drawCircle(Offset(rect.left + 18, y), 2.5, Paint()..color = const Color(0xFF14102A));
    }
    // La gorra del Revisor.
    final gorra = Path()
      ..moveTo(rect.right - 70, rect.top + 50)
      ..quadraticBezierTo(rect.right - 45, rect.top + 14, rect.right - 20, rect.top + 50)
      ..close();
    canvas.drawPath(gorra, Paint()..color = const Color(0xFF2B2F63));
    canvas.drawRect(Rect.fromLTWH(rect.right - 76, rect.top + 48, 62, 6), Paint()..color = const Color(0xFF14102A));
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tamano, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorVia anterior) => true;
}
