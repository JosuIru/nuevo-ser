import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/ayudas_maquinas.dart';
import '../../dominio/minijuegos/balanza.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Balanza — máquina de Rexán. La ecuación se ve como una balanza con
/// bolsas de x y pesas. El niño propone x (− / +), pesa y ve hacia dónde
/// se inclina. El primer "pesar" de cada ecuación va a la maestría.
class PantallaBalanza extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaBalanza({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaBalanza> createState() => _PantallaBalanzaState();
}

class _PantallaBalanzaState extends State<PantallaBalanza>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_balanza';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.balanza);

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);

  /// Dificultad de las cuentas en esta ronda (sube con el nivel).
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  late final GeneradorBalanza _generador;
  late final AnimationController _animacion;
  late final List<String> _habilidades;
  late EcuacionBalanza _ecuacion;
  int _ronda = 1;
  int _propuesta = 1;
  double _inclinacionDesde = 0;
  double _inclinacionHasta = 0;
  bool _yaRegistrada = false;

  /// Despejar paso a paso: los pasos y cuántos se ven. Si se usa antes
  /// del primer "pesar", esa ecuación no cuenta para la maestría (ni a
  /// favor ni en contra).
  List<PasoBalanza>? _pasos;
  int _pasosVistos = 0;
  bool _ayudaUsada = false;
  bool _resuelta = false;
  bool _terminada = false;
  String? _lineaRexan;
  DateTime _inicio = DateTime.now();

  double get _inclinacion =>
      _inclinacionDesde +
      (_inclinacionHasta - _inclinacionDesde) *
          Curves.elasticOut.transform(_animacion.value);

  @override
  void initState() {
    super.initState();
    _generador = GeneradorBalanza(azar: math.Random(widget.semilla));
    _habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (id == 'ALG.01' || id == 'ALG.02') id,
    ];
    if (_habilidades.isEmpty) _habilidades.add('ALG.01');
    _animacion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _nuevaEcuacion();
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  void _nuevaEcuacion() {
    _ecuacion = _generador.generar(
        _habilidades[(_ronda - 1) % _habilidades.length],
        dificultad: _enNivel.dificultad,
        extra: _enNivel.extra);
    _propuesta = 1;
    _yaRegistrada = false;
    _pasos = null;
    _pasosVistos = 0;
    _ayudaUsada = false;
    _resuelta = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _inclinacionDesde = _inclinacionHasta = 0;
    _animacion.value = 1;
  }

  void _cambiar(int delta) {
    if (_resuelta) return;
    HapticFeedback.selectionClick();
    setState(() => _propuesta = (_propuesta + delta).clamp(0, 30));
  }

  void _pesar() {
    if (_resuelta) return;
    final diferencia = _ecuacion.inclinacion(_propuesta);
    if (!_yaRegistrada) {
      _yaRegistrada = true;
      if (!_ayudaUsada) widget.registro?.registrar(
        idHabilidad: _ecuacion.idHabilidad,
        acierto: diferencia == 0,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: DateTime.now().difference(_inicio),
      );
    }
    setState(() {
      _inclinacionDesde = _inclinacion;
      // Positiva: baja la derecha. Proporcional pero con tope.
      _inclinacionHasta = (diferencia / 6).clamp(-1.0, 1.0);
      if (diferencia == 0) {
        _resuelta = true;
        _lineaRexan = 'Equilibrio. x vale {x}.';
      } else {
        _lineaRexan = diferencia > 0
            ? 'Baja la derecha: con ese valor, la izquierda se queda corta.'
            : 'Baja la izquierda: con ese valor, la izquierda pesa demasiado.';
      }
    });
    _animacion.forward(from: 0);
    if (diferencia == 0) {
      HapticFeedback.heavyImpact();
      sonar('efecto_acierto');
      anotarAcierto();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          if (_ronda >= _definicion.rondasPorPartida) {
            _terminada = true;
          } else {
            final nivelAntes = _nivel;
            _ronda++;
            _nuevaEcuacion();
            if (_nivel != nivelAntes) _lineaRexan = 'Sube el nivel: cuentas algo más difíciles.';
          }
        });
      });
    } else {
      HapticFeedback.lightImpact();
      sonar('efecto_tablon');
      setState(anotarFallo);
    }
  }

  void _abrirPasos() {
    HapticFeedback.selectionClick();
    setState(() {
      _pasos = pasosDespejar(_ecuacion);
      _pasosVistos = 1;
      if (!_yaRegistrada) _ayudaUsada = true;
    });
  }

  void _siguientePaso() {
    HapticFeedback.selectionClick();
    setState(() => _pasosVistos++);
  }

  void _cerrarPasos() => setState(() => _pasos = null);

  /// La balanza que se dibuja: la del último paso visto, o la ecuación.
  EcuacionBalanza get _balanzaVisible {
    final pasos = _pasos;
    if (pasos == null) return _ecuacion;
    final paso = pasos[_pasosVistos - 1];
    return EcuacionBalanza(
      idHabilidad: _ecuacion.idHabilidad,
      bolsasIzquierda: paso.bolsasIzquierda,
      pesasIzquierda: paso.pesasIzquierda,
      bolsasDerecha: paso.bolsasDerecha,
      pesasDerecha: paso.pesasDerecha,
      solucion: _ecuacion.solucion,
    );
  }

  Widget _panelPasos(Locale locale) {
    final pasos = _pasos!;
    final ultimo = _pasosVistos >= pasos.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.9),
        border: Border.all(color: PaletaNeon.ambarCanales.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _pasosVistos; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}.',
                      style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${traducirNarrativa(pasos[i].plantilla, locale).replaceAll('{n}', '${pasos[i].valor}')}\n→ ${pasos[i].ecuacion}',
                      style: const TextStyle(
                          color: PaletaNeon.textoPrincipal, fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: ValueKey(ultimo ? 'pasos-cerrar' : 'pasos-siguiente'),
              onPressed: ultimo ? _cerrarPasos : _siguientePaso,
              child: Text(
                traducirNarrativa(ultimo ? 'VOLVER A LA BALANZA' : 'SIGUIENTE PASO', locale),
                style: const TextStyle(color: PaletaNeon.ambarCanales, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Seis ecuaciones, seis equilibrios. La balanza descansa.'
        : _lineaRexan ?? _definicion.lineaRexan;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _ecuacion.idHabilidad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: traducirNarrativa(linea, locale)
          .replaceAll('{x}', '${_ecuacion.solucion}'),
      terminada: _terminada,
      child: Column(
        children: [
          Text(
            _balanzaVisible.texto,
            style: const TextStyle(
              color: PaletaNeon.ambarCanales,
              fontSize: 24,
              letterSpacing: 1.5,
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _animacion,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: PintorBalanzaEcuacion(
                  ecuacion: _balanzaVisible,
                  // Durante los pasos siempre en equilibrio: es la idea.
                  inclinacion: _pasos != null ? 0 : _inclinacion,
                  equilibrada: _resuelta || _pasos != null,
                ),
              ),
            ),
          ),
          if (_pasos != null) ...[
            _panelPasos(locale),
            const SizedBox(height: 10),
          ] else if (!_resuelta)
            TextButton.icon(
              key: const ValueKey('pasos-abrir'),
              onPressed: _abrirPasos,
              icon: const Icon(Icons.lightbulb_outline, color: PaletaNeon.textoTenue, size: 18),
              label: Text(
                traducirNarrativa('AYÚDAME PASO A PASO', locale),
                style: const TextStyle(color: PaletaNeon.textoTenue, letterSpacing: 1.5),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BotonRedondo(
                  clave: 'menos', icono: Icons.remove, alPulsar: () => _cambiar(-1)),
              const SizedBox(width: 18),
              Text(
                'x = $_propuesta',
                key: const ValueKey('propuesta'),
                style: const TextStyle(
                  color: PaletaNeon.textoPrincipal,
                  fontSize: 26,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 18),
              _BotonRedondo(
                  clave: 'mas', icono: Icons.add, alPulsar: () => _cambiar(1)),
            ],
          ),
          const SizedBox(height: 14),
          BotonMinijuego(
            texto: traducirNarrativa('PESAR', locale),
            alPulsar: _resuelta ? null : _pesar,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  final String clave;
  final IconData icono;
  final VoidCallback alPulsar;

  const _BotonRedondo(
      {required this.clave, required this.icono, required this.alPulsar});

  @override
  Widget build(BuildContext contexto) => GestureDetector(
        key: ValueKey('boton-$clave'),
        onTap: alPulsar,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: PaletaNeon.violetaNeon),
          ),
          child: Icon(icono, color: PaletaNeon.textoPrincipal),
        ),
      );
}

/// Balanza con bolsas de x (sacos con "x") y pesas (cuadrados) en cada
/// platillo. [inclinacion] de −1 (izquierda abajo) a 1 (derecha abajo).
class PintorBalanzaEcuacion extends CustomPainter {
  final EcuacionBalanza ecuacion;
  final double inclinacion;
  final bool equilibrada;

  PintorBalanzaEcuacion({
    required this.ecuacion,
    required this.inclinacion,
    required this.equilibrada,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fulcro = Offset(size.width / 2, size.height * 0.3);
    // Brazo y platillos caben siempre en el ancho (con margen).
    final medioBrazo = size.width * 0.3;
    final anchoPlatillo = medioBrazo * 0.9;
    final angulo = inclinacion * 0.28;

    // Pie: columna con base triangular.
    final pie = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6F6893), Color(0xFFB9B2DE), Color(0xFF6F6893)],
      ).createShader(Rect.fromLTWH(fulcro.dx - 5, fulcro.dy, 10, size.height));
    canvas.drawRect(Rect.fromLTRB(fulcro.dx - 3, fulcro.dy, fulcro.dx + 3, size.height * 0.92), pie);
    final base = Path()
      ..moveTo(fulcro.dx - 36, size.height * 0.95)
      ..lineTo(fulcro.dx + 36, size.height * 0.95)
      ..lineTo(fulcro.dx + 10, size.height * 0.9)
      ..lineTo(fulcro.dx - 10, size.height * 0.9)
      ..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF4A4370));

    final izquierda = fulcro +
        Offset(-medioBrazo * math.cos(angulo), -medioBrazo * math.sin(angulo));
    final derecha = fulcro +
        Offset(medioBrazo * math.cos(angulo), medioBrazo * math.sin(angulo));
    // Brazo metálico.
    canvas.drawLine(
        izquierda,
        derecha,
        Paint()
          ..color = const Color(0xFFB9B2DE)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(
        izquierda,
        derecha,
        Paint()
          ..color = Colors.white.withOpacity(0.35)
          ..strokeWidth = 1.2);
    final colorFulcro = equilibrada ? PaletaNeon.exitoSuave : PaletaNeon.violetaNeon;
    canvas.drawCircle(fulcro, 12,
        Paint()
          ..color = colorFulcro.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(fulcro, 7, Paint()..color = colorFulcro);
    _platillo(canvas, izquierda, ecuacion.bolsasIzquierda,
        ecuacion.pesasIzquierda, anchoPlatillo);
    _platillo(canvas, derecha, ecuacion.bolsasDerecha, ecuacion.pesasDerecha,
        anchoPlatillo);
  }

  void _platillo(Canvas canvas, Offset colgadoDe, int bolsas, int pesas, double ancho) {
    final base = colgadoDe + const Offset(0, 70);
    final cuerda = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(colgadoDe, base + Offset(-ancho / 2, 0), cuerda);
    canvas.drawLine(colgadoDe, base + Offset(ancho / 2, 0), cuerda);
    // Platillo: un cuenco plano metálico.
    final cuenco = Path()
      ..moveTo(base.dx - ancho / 2, base.dy)
      ..quadraticBezierTo(base.dx, base.dy + 14, base.dx + ancho / 2, base.dy)
      ..close();
    canvas.drawPath(
        cuenco,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB9B2DE), Color(0xFF4A4370)],
          ).createShader(Rect.fromLTWH(base.dx - ancho / 2, base.dy, ancho, 14)));

    // Objetos apilados sobre el platillo: primero las bolsas, luego pesas.
    const ladoPesa = 15.0;
    const anchoBolsa = 26.0;
    final objetos = <(bool, double)>[
      for (var i = 0; i < bolsas; i++) (true, anchoBolsa),
      for (var i = 0; i < pesas; i++) (false, ladoPesa),
    ];
    var x = base.dx - ancho / 2 + 4;
    var y = base.dy - 1;
    var alturaFila = 0.0;
    for (final (esBolsa, anchoObjeto) in objetos) {
      if (x + anchoObjeto > base.dx + ancho / 2 - 4) {
        x = base.dx - ancho / 2 + 4;
        y -= alturaFila + 2;
        alturaFila = 0;
      }
      if (esBolsa) {
        _saco(canvas, Rect.fromLTWH(x, y - 30, anchoObjeto, 30));
        alturaFila = math.max(alturaFila, 30);
      } else {
        _pesa(canvas, Rect.fromLTWH(x, y - ladoPesa, ladoPesa, ladoPesa));
        alturaFila = math.max(alturaFila, ladoPesa);
      }
      x += anchoObjeto + 2;
    }
  }

  /// Saco atado arriba, con la x pintada.
  void _saco(Canvas canvas, Rect rect) {
    final cuello = rect.top + rect.height * 0.22;
    final saco = Path()
      ..moveTo(rect.center.dx - rect.width * 0.18, cuello)
      ..quadraticBezierTo(rect.left - 2, rect.top + rect.height * 0.55, rect.left + 2, rect.bottom)
      ..lineTo(rect.right - 2, rect.bottom)
      ..quadraticBezierTo(rect.right + 2, rect.top + rect.height * 0.55,
          rect.center.dx + rect.width * 0.18, cuello)
      ..close();
    canvas.drawPath(
        saco,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0C878), Color(0xFFA8732F)],
          ).createShader(rect));
    // Nudo y boca del saco.
    canvas.drawLine(Offset(rect.center.dx - rect.width * 0.2, cuello),
        Offset(rect.center.dx + rect.width * 0.2, cuello),
        Paint()
          ..color = const Color(0xFF6B4A14)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    final boca = Path()
      ..moveTo(rect.center.dx - rect.width * 0.14, cuello)
      ..lineTo(rect.center.dx - rect.width * 0.22, rect.top)
      ..lineTo(rect.center.dx + rect.width * 0.22, rect.top)
      ..lineTo(rect.center.dx + rect.width * 0.14, cuello)
      ..close();
    canvas.drawPath(boca, Paint()..color = const Color(0xFFD9A85A));
    final texto = TextPainter(
      text: const TextSpan(
          text: 'x',
          style: TextStyle(
              color: Color(0xFF3A2608), fontSize: 15, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(canvas,
        Offset(rect.center.dx - texto.width / 2, rect.top + rect.height * 0.62 - texto.height / 2));
  }

  /// Pesa de hierro: trapecio con asa y un brillo.
  void _pesa(Canvas canvas, Rect rect) {
    final cuerpo = Path()
      ..moveTo(rect.left + 2, rect.top + rect.height * 0.3)
      ..lineTo(rect.right - 2, rect.top + rect.height * 0.3)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    canvas.drawPath(
        cuerpo,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF2E7FA8), Color(0xFF8FE0FF), Color(0xFF2E7FA8)],
          ).createShader(rect));
    canvas.drawArc(Rect.fromLTWH(rect.left + rect.width * 0.28, rect.top, rect.width * 0.44, rect.height * 0.5),
        math.pi, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFF8FE0FF));
  }

  @override
  bool shouldRepaint(PintorBalanzaEcuacion anterior) => true;
}
