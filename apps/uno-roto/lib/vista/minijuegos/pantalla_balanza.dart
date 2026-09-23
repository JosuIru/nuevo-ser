import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/ayudas_maquinas.dart';
import '../../dominio/minijuegos/balanza.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
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
    with SingleTickerProviderStateMixin, MusicaDeMaquina {
  @override
  String get idMusica => 'musica_maquina_balanza';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.balanza);

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
          Curves.easeOutBack.transform(_animacion.value);

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
        vsync: this, duration: const Duration(milliseconds: 650));
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
        dificultad: widget.dificultad);
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
        dificultad: 0.8 + 0.3 * widget.dificultad,
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
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          if (_ronda >= _definicion.rondasPorPartida) {
            _terminada = true;
          } else {
            _ronda++;
            _nuevaEcuacion();
          }
        });
      });
    } else {
      HapticFeedback.lightImpact();
      sonar('efecto_tablon');
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
    final medioBrazo = size.width * 0.4;
    final angulo = inclinacion * 0.28;
    final estructura = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(fulcro, Offset(fulcro.dx, size.height * 0.95), estructura);
    final izquierda = fulcro +
        Offset(-medioBrazo * math.cos(angulo), -medioBrazo * math.sin(angulo));
    final derecha = fulcro +
        Offset(medioBrazo * math.cos(angulo), medioBrazo * math.sin(angulo));
    canvas.drawLine(izquierda, derecha, estructura);
    canvas.drawCircle(
        fulcro,
        6,
        Paint()
          ..color = equilibrada ? PaletaNeon.exitoSuave : PaletaNeon.violetaNeon);
    _platillo(canvas, izquierda, ecuacion.bolsasIzquierda,
        ecuacion.pesasIzquierda, medioBrazo * 0.95);
    _platillo(canvas, derecha, ecuacion.bolsasDerecha, ecuacion.pesasDerecha,
        medioBrazo * 0.95);
  }

  void _platillo(Canvas canvas, Offset colgadoDe, int bolsas, int pesas, double ancho) {
    final base = colgadoDe + const Offset(0, 70);
    final cuerda = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(colgadoDe, base + Offset(-ancho / 2, 0), cuerda);
    canvas.drawLine(colgadoDe, base + Offset(ancho / 2, 0), cuerda);
    canvas.drawLine(base + Offset(-ancho / 2, 0), base + Offset(ancho / 2, 0),
        Paint()
          ..color = PaletaNeon.textoTenue
          ..strokeWidth = 3);

    // Objetos apilados sobre el platillo: primero las bolsas, luego pesas.
    const ladoPesa = 16.0;
    const anchoBolsa = 28.0;
    final objetos = <(bool, double)>[
      for (var i = 0; i < bolsas; i++) (true, anchoBolsa),
      for (var i = 0; i < pesas; i++) (false, ladoPesa),
    ];
    var x = base.dx - ancho / 2 + 4;
    var y = base.dy - 2;
    var alturaFila = 0.0;
    for (final (esBolsa, anchoObjeto) in objetos) {
      if (x + anchoObjeto > base.dx + ancho / 2 - 4) {
        x = base.dx - ancho / 2 + 4;
        y -= alturaFila + 2;
        alturaFila = 0;
      }
      if (esBolsa) {
        final rect = Rect.fromLTWH(x, y - 30, anchoObjeto, 30);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)),
            Paint()..color = PaletaNeon.ambarCanales.withOpacity(0.85));
        final texto = TextPainter(
          text: const TextSpan(
              text: 'x',
              style: TextStyle(
                  color: PaletaNeon.fondoProfundo,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          textDirection: TextDirection.ltr,
        )..layout();
        texto.paint(canvas, rect.center - Offset(texto.width / 2, texto.height / 2));
        alturaFila = math.max(alturaFila, 30);
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y - ladoPesa, ladoPesa, ladoPesa),
            Paint()..color = PaletaNeon.azulNeon.withOpacity(0.75));
        alturaFila = math.max(alturaFila, ladoPesa);
      }
      x += anchoObjeto + 2;
    }
  }

  @override
  bool shouldRepaint(PintorBalanzaEcuacion anterior) => true;
}
