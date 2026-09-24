import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/hornada.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// La hornada — segunda sala de Rexán. Se tocan los trozos de pan para
/// meterlos en la caja (tocar otra vez los saca) y se entrega. En el
/// pedido de leer, la caja ya viene hecha y se elige cómo se escribe.
/// Cuenta la primera entrega de cada pedido.
class PantallaHornada extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaHornada({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaHornada> createState() => _PantallaHornadaState();
}

class _PantallaHornadaState extends State<PantallaHornada>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_hornada';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.hornada);
  static const _tipos = [
    TipoPedido.parte,
    TipoPedido.leer,
    TipoPedido.impropia,
    TipoPedido.mixto,
    TipoPedido.amplificar,
    TipoPedido.simplificar,
  ];

  late final GeneradorHornada _generador;
  late PedidoHornada _pedido;

  /// Trozos en la caja: (pan, trozo).
  final Set<(int, int)> _enCaja = {};
  String? _opcionElegida;
  int _ronda = 1;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _terminada = false;
  String? _lineaRexan;
  Map<String, String> _datosLinea = const {};
  DateTime _inicio = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  bool get _leer => _pedido.tipo == TipoPedido.leer;

  @override
  void initState() {
    super.initState();
    _generador = GeneradorHornada(azar: math.Random(widget.semilla));
    _nuevoPedido();
  }

  void _nuevoPedido() {
    _pedido = _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _enCaja.clear();
    if (_leer) {
      for (var t = 0; t < _pedido.trozos; t++) {
        _enCaja.add((0, t));
      }
    }
    _opcionElegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = switch (_pedido.tipo) {
      TipoPedido.impropia || TipoPedido.mixto => 'Ojo, que los Impropios parecen poca cosa.',
      TipoPedido.amplificar || TipoPedido.simplificar => 'Esta bandeja no está cortada como el pedido. Piénsalo.',
      _ => null,
    };
    _datosLinea = const {};
    _inicio = DateTime.now();
  }

  void _registrar(bool acierto) {
    if (_yaRegistrado) return;
    _yaRegistrado = true;
    widget.registro?.registrar(
      idHabilidad: _pedido.idHabilidad,
      acierto: acierto,
      dificultad: 0.8 + 0.3 * _enNivel.dificultad,
      duracion: DateTime.now().difference(_inicio),
    );
  }

  void _tocarTrozo((int, int)? trozo) {
    if (trozo == null || _resuelto || _leer) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (!_enCaja.remove(trozo)) _enCaja.add(trozo);
    });
  }

  Future<void> _entregar() async {
    if (_resuelto || _enCaja.isEmpty) return;
    final puestos = _enCaja.length;
    final acierta = puestos == _pedido.trozos;
    _registrar(acierta);
    setState(() {
      _datosLinea = {'k': '$puestos', 'd': '${_pedido.cortes}'};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = '{k} trozos de {d}: justo el pedido. A la caja.';
      } else {
        anotarFallo();
        _lineaRexan = puestos > _pedido.trozos
            ? 'Llevas {k} trozos de {d}: te has pasado.'
            : 'Llevas {k} trozos de {d}: falta pan.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _siguiente();
  }

  Future<void> _elegirOpcion(String opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _pedido.escrito;
    _registrar(acierta);
    setState(() {
      _opcionElegida = opcion;
      _datosLinea = {'k': '${_pedido.trozos}', 'd': '${_pedido.cortes}'};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = '{k} trozos de los {d} de un pan: {k}/{d}.';
      } else {
        anotarFallo();
        _lineaRexan = 'Cuenta los trozos de la caja (arriba) y en cuántos está cortado el pan (abajo).';
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
        _nuevoPedido();
      }
    });
  }

  String _texto(String plantilla, Locale locale, [Map<String, String> datos = const {}]) {
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  /// "2 y 3/4" con la conjunción del idioma.
  String _escrito(String escrito, Locale locale) =>
      escrito.replaceAll(' y ', ' ${traducirNarrativa('y', locale)} ');

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? _texto('Seis pedidos servidos. Huele a pan en todos los Tejados.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = _leer
        ? _texto('¿Cuánto pan hay en la caja?', locale)
        : _texto('Pedido: {p} de pan. Toca los trozos para meterlos en la caja.', locale,
            {'p': _escrito(_pedido.escrito, locale)});
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _pedido.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: linea,
      terminada: _terminada,
      child: Column(
        children: [
          Text(pregunta,
              key: const ValueKey('pregunta-hornada'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, restricciones) {
                final lienzo = restricciones.biggest;
                final pintor = PintorBandeja(pedido: _pedido, enCaja: _enCaja, pista: ofrecerPista);
                return GestureDetector(
                  key: const ValueKey('bandeja'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _tocarTrozo(pintor.trozoEn(d.localPosition, lienzo)),
                  child: CustomPaint(size: lienzo, painter: pintor),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_leer)
            Row(
              children: [
                for (final opcion in _pedido.opciones)
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
                    ),
                  ),
              ],
            )
          else
            BotonMinijuego(
              texto: traducirNarrativa('ENTREGAR', locale),
              alPulsar: _resuelto || _enCaja.isEmpty ? null : _entregar,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// La bandeja: panes redondos cortados en [PedidoHornada.cortes] trozos.
/// Los de la caja, tostados y con borde; los demás, más claros. No se
/// escribe cuántos hay puestos: se cuentan.
class PintorBandeja extends CustomPainter {
  final PedidoHornada pedido;
  final Set<(int, int)> enCaja;

  /// Pista (tras dos fallos): cada trozo lleva escrito cuánto es, 1/d.
  final bool pista;

  PintorBandeja({required this.pedido, required this.enCaja, this.pista = false});

  (Offset, double) _pan(int indice, Size size) {
    final panes = pedido.panes;
    final radio = math.min(size.width / (panes * 2.3), size.height * 0.42);
    final paso = size.width / panes;
    return (Offset(paso * (indice + 0.5), size.height / 2), radio);
  }

  /// El trozo bajo el dedo, o null.
  (int, int)? trozoEn(Offset posicion, Size size) {
    for (var p = 0; p < pedido.panes; p++) {
      final (centro, radio) = _pan(p, size);
      final vector = posicion - centro;
      if (vector.distance > radio) continue;
      var angulo = math.atan2(vector.dy, vector.dx) + math.pi / 2;
      if (angulo < 0) angulo += math.pi * 2;
      return (p, (angulo / (math.pi * 2) * pedido.cortes).floor() % pedido.cortes);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // La bandeja de horno.
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(4, size.height * 0.08, size.width - 8, size.height * 0.84),
            const Radius.circular(12)),
        Paint()..color = const Color(0xFF3A2E3E));
    for (var p = 0; p < pedido.panes; p++) {
      final (centro, radio) = _pan(p, size);
      for (var t = 0; t < pedido.cortes; t++) {
        final inicio = t / pedido.cortes * math.pi * 2 - math.pi / 2;
        final barrido = math.pi * 2 / pedido.cortes;
        final dentro = enCaja.contains((p, t));
        final rect = Rect.fromCircle(center: centro, radius: radio);
        canvas.drawArc(
            rect,
            inicio,
            barrido,
            true,
            Paint()
              ..shader = RadialGradient(
                colors: dentro
                    ? const [Color(0xFFB8702E), Color(0xFF6B3A12)]
                    : const [Color(0xFFF2DDB0), Color(0xFFD9B77A)],
              ).createShader(rect));
        canvas.drawArc(
            rect,
            inicio,
            barrido,
            true,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = dentro ? 2.5 : 1.5
              ..color = dentro ? PaletaNeon.ambarCanales : const Color(0xFF6B4A14));
      }
      // Corteza.
      canvas.drawCircle(
          centro,
          radio,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFF8A5A2A));
      if (pista) {
        for (var t = 0; t < pedido.cortes; t++) {
          final angulo = (t + 0.5) / pedido.cortes * math.pi * 2 - math.pi / 2;
          final posicion = centro + Offset(math.cos(angulo), math.sin(angulo)) * radio * 0.62;
          final texto = TextPainter(
            text: TextSpan(
                text: '1/${pedido.cortes}',
                style: TextStyle(
                    color: const Color(0xFF3A2208),
                    fontSize: math.max(8, math.min(12, radio / pedido.cortes * 1.4)),
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr,
          )..layout();
          texto.paint(canvas, posicion - Offset(texto.width / 2, texto.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(PintorBandeja anterior) => true;
}
