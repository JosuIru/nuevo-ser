import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/taller.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// El taller del relojero — segunda sala de Rexán. En los bancos de
/// piezas no se ve el total mientras se trabaja (se calcula, no se ajusta
/// a ojo); al entregar, la báscula, la regla o la probeta enseñan cuánto
/// se llevaba. El reloj avanza las agujas hasta la hora buena. Cuenta la
/// primera entrega de cada encargo.
class PantallaTaller extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaTaller({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaTaller> createState() => _PantallaTallerState();
}

class _PantallaTallerState extends State<PantallaTaller>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_taller';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.taller);
  static const _bancos = [
    Banco.regla,
    Banco.bascula,
    Banco.probetas,
    Banco.reloj,
    Banco.bascula,
    Banco.reloj,
  ];

  late final GeneradorTaller _generador;
  late final AnimationController _agujas = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));
  late RetoTaller _reto;
  final List<Pieza> _puestas = [];
  int? _entregado;
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

  @override
  void initState() {
    super.initState();
    _generador = GeneradorTaller(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _agujas.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_bancos[_ronda - 1], dificultad: _enNivel.dificultad);
    _puestas.clear();
    _entregado = null;
    _opcionElegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _agujas.value = 0;
  }

  int get _total => _puestas.fold(0, (suma, p) => suma + p.valor);

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

  Future<void> _entregar() async {
    if (_resuelto || _puestas.isEmpty) return;
    final total = _total;
    final acierta = total == _reto.objetivoBase;
    _registrar(acierta);
    setState(() {
      _entregado = total;
      _datosLinea = {
        'x': enUnidadesMixtas(_reto.banco, total),
        'd': enUnidadesMixtas(_reto.banco, (total - _reto.objetivoBase).abs()),
      };
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = 'Justo lo que pedían. Al cliente.';
      } else {
        anotarFallo();
        _lineaRexan = total > _reto.objetivoBase
            ? 'Llevas {x}: sobran {d}. Quita algo.'
            : 'Llevas {x}: faltan {d}. Añade algo.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _siguiente();
  }

  Future<void> _elegirHora(String opcion) async {
    if (_resuelto || _agujas.isAnimating) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.opcionBuena;
    _registrar(acierta);
    setState(() {
      _opcionElegida = opcion;
      _datosLinea = {'h': _reto.opcionBuena!, 'o': opcion};
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = 'Las {h}. En hora.';
      } else {
        anotarFallo();
        _lineaRexan = '{o} no. Recuerda: 60 minutos hacen una hora.';
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _agujas.forward(from: 0);
    await _siguiente();
  }

  Future<void> _siguiente() async {
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
    final reloj = _reto.banco == Banco.reloj;
    final linea = _terminada
        ? _texto('Seis encargos servidos. El taller cierra a su hora.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final pregunta = switch (_reto.banco) {
      Banco.regla => _texto('Corta una varilla de {o}.', locale, {'o': _reto.objetivo}),
      Banco.bascula => _texto('Pon en la báscula {o}.', locale, {'o': _reto.objetivo}),
      Banco.probetas => _texto('Llena la probeta con {o}.', locale, {'o': _reto.objetivo}),
      Banco.reloj => _texto('Son las {h}. ¿Qué hora será dentro de {s}?', locale,
          {'h': horaDe(_reto.inicio), 's': enUnidadesMixtas(Banco.reloj, _reto.suma)}),
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
              key: const ValueKey('pregunta-taller'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 17, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _agujas,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: reloj
                    ? PintorReloj(
                        minutos: _reto.inicio + (_resuelto ? _reto.suma * Curves.easeInOut.transform(_agujas.value) : 0).round())
                    : PintorBanco(
                        banco: _reto.banco,
                        objetivo: _reto.objetivoBase,
                        entregado: _entregado,
                        piezas: _puestas.length,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (reloj)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3,
              children: [
                for (final opcion in _reto.opciones)
                  GestureDetector(
                    key: ValueKey('opcion-$opcion'),
                    onTap: () => _elegirHora(opcion),
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
                          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 24, letterSpacing: 1)),
                    ),
                  ),
              ],
            )
          else ...[
            // Lo que hay puesto (se quita tocando).
            SizedBox(
              height: 44,
              child: _puestas.isEmpty
                  ? Center(
                      child: Text(_texto('Toca las piezas de abajo para ponerlas.', locale),
                          style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.7), fontSize: 13)))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 0; i < _puestas.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              key: ValueKey('puesta-$i'),
                              onTap: _resuelto
                                  ? null
                                  : () => setState(() {
                                        _puestas.removeAt(i);
                                        _entregado = null;
                                      }),
                              child: Chip(
                                label: Text(_puestas[i].etiqueta,
                                    style: const TextStyle(color: PaletaNeon.fondoProfundo, fontSize: 14)),
                                backgroundColor: PaletaNeon.ambarCanales,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pieza in _reto.piezas)
                  GestureDetector(
                    key: ValueKey('pieza-${pieza.etiqueta}'),
                    onTap: _resuelto
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _puestas.add(pieza);
                              _entregado = null;
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF5A5480), Color(0xFF2A2250)],
                        ),
                        border: Border.all(color: PaletaNeon.grisMetal.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(pieza.etiqueta,
                          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 16)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            BotonMinijuego(
              texto: traducirNarrativa('ENTREGAR', locale),
              alPulsar: _resuelto || _puestas.isEmpty ? null : _entregar,
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// El banco de trabajo: una varilla junto a la regla, la báscula de aguja
/// o la probeta graduada. Hasta entregar, sólo se ven las piezas; al
/// entregar, la medida real frente a la pedida.
class PintorBanco extends CustomPainter {
  final Banco banco;
  final int objetivo;
  final int? entregado;
  final int piezas;

  PintorBanco({required this.banco, required this.objetivo, required this.entregado, required this.piezas});

  @override
  void paint(Canvas canvas, Size size) {
    switch (banco) {
      case Banco.regla:
        _regla(canvas, size);
      case Banco.bascula:
        _bascula(canvas, size);
      case Banco.probetas:
        _probeta(canvas, size);
      case Banco.reloj:
        break;
    }
  }

  void _regla(Canvas canvas, Size size) {
    final maximo = math.max(300, math.max(objetivo, entregado ?? 0));
    final escala = (size.width - 20) / maximo;
    final y = size.height * 0.45;
    // La regla de madera, graduada cada 10 cm.
    canvas.drawRect(Rect.fromLTWH(10, y, maximo * escala, 22), Paint()..color = const Color(0xFFD9B77A));
    for (var c = 0; c <= maximo; c += 10) {
      final x = 10 + c * escala;
      canvas.drawLine(Offset(x, y), Offset(x, y + (c % 50 == 0 ? 12 : 6)),
          Paint()
            ..color = const Color(0xFF3A2608)
            ..strokeWidth = 1);
      if (c % 100 == 0) _texto(canvas, '${c ~/ 100} m', Offset(x, y + 32), const Color(0xFFE8E2D0), 11);
    }
    final medida = entregado;
    if (medida != null) {
      canvas.drawRect(Rect.fromLTWH(10, y - 16, medida * escala, 10),
          Paint()..color = medida == objetivo ? PaletaNeon.exitoSuave : PaletaNeon.rosaAcento);
    }
    // Marca de lo pedido, sólo al entregar.
    if (medida != null) {
      final x = 10 + objetivo * escala;
      canvas.drawLine(Offset(x, y - 24), Offset(x, y + 22),
          Paint()
            ..color = PaletaNeon.ambarCanales
            ..strokeWidth = 2);
    }
  }

  void _bascula(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.7);
    final radio = math.min(size.width * 0.35, size.height * 0.5);
    canvas.drawArc(Rect.fromCircle(center: centro, radius: radio), math.pi, math.pi, true,
        Paint()..color = const Color(0xFFE8E2D0));
    canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFF8A6A2E));
    // La aguja: en medio (equilibrio) si es justo; a un lado si sobra o falta.
    final medida = entregado;
    var angulo = -math.pi / 2;
    if (medida != null) {
      final diferencia = ((medida - objetivo) / math.max(objetivo, 1)).clamp(-1.0, 1.0);
      angulo += diferencia * 1.2;
    }
    canvas.drawLine(centro, centro + Offset(math.cos(angulo), math.sin(angulo)) * radio * 0.9,
        Paint()
          ..color = medida == null ? PaletaNeon.grisMetal : (medida == objetivo ? PaletaNeon.exitoSuave : PaletaNeon.rosaAcento)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(centro, 6, Paint()..color = const Color(0xFF3A2608));
    // El platillo con las pesas puestas.
    final platillo = Rect.fromCenter(center: Offset(centro.dx, size.height * 0.12), width: radio * 1.4, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(platillo, const Radius.circular(5)), Paint()..color = PaletaNeon.grisMetal);
    for (var i = 0; i < math.min(piezas, 12); i++) {
      canvas.drawRect(
          Rect.fromLTWH(platillo.left + 6 + i * (platillo.width - 12) / 12, platillo.top - 14, (platillo.width - 12) / 13, 14),
          Paint()..color = const Color(0xFF2E7FA8));
    }
  }

  void _probeta(Canvas canvas, Size size) {
    final ancho = size.width * 0.22;
    final probeta = Rect.fromLTWH((size.width - ancho) / 2, size.height * 0.05, ancho, size.height * 0.88);
    final maximo = math.max(3000, math.max(objetivo, entregado ?? 0));
    // Graduación cada medio litro.
    for (var ml = 0; ml <= maximo; ml += 500) {
      final y = probeta.bottom - ml / maximo * probeta.height;
      canvas.drawLine(Offset(probeta.right, y), Offset(probeta.right + 10, y),
          Paint()
            ..color = const Color(0xFFE8E2D0)
            ..strokeWidth = 1);
      if (ml % 1000 == 0) _texto(canvas, '${ml ~/ 1000} l', Offset(probeta.right + 24, y), const Color(0xFFE8E2D0), 11);
    }
    final medida = entregado;
    if (medida != null) {
      final alto = medida / maximo * probeta.height;
      canvas.drawRect(Rect.fromLTWH(probeta.left, probeta.bottom - alto, probeta.width, alto),
          Paint()..color = (medida == objetivo ? const Color(0xFF7CF2FF) : PaletaNeon.rosaAcento).withOpacity(0.6));
      final yObjetivo = probeta.bottom - objetivo / maximo * probeta.height;
      canvas.drawLine(Offset(probeta.left - 8, yObjetivo), Offset(probeta.right, yObjetivo),
          Paint()
            ..color = PaletaNeon.ambarCanales
            ..strokeWidth = 2);
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(probeta, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFB9E6FF));
  }

  void _texto(Canvas canvas, String texto, Offset centro, Color color, double tamano) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorBanco anterior) => true;
}

/// Reloj de pared con agujas y la hora digital debajo.
class PintorReloj extends CustomPainter {
  final int minutos;

  PintorReloj({required this.minutos});

  @override
  void paint(Canvas canvas, Size size) {
    final radio = math.min(size.width, size.height * 0.85) * 0.45;
    final centro = Offset(size.width / 2, radio + 8);
    canvas.drawCircle(centro, radio, Paint()..color = const Color(0xFFE8E2D0));
    canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = const Color(0xFF8A6A2E));
    for (var h = 1; h <= 12; h++) {
      final a = h / 12 * math.pi * 2 - math.pi / 2;
      _texto(canvas, '$h', centro + Offset(math.cos(a), math.sin(a)) * radio * 0.8, radio * 0.16);
    }
    for (var m = 0; m < 60; m++) {
      final a = m / 60 * math.pi * 2 - math.pi / 2;
      final interior = radio * (m % 5 == 0 ? 0.9 : 0.94);
      canvas.drawLine(centro + Offset(math.cos(a), math.sin(a)) * interior,
          centro + Offset(math.cos(a), math.sin(a)) * radio * 0.98,
          Paint()
            ..color = const Color(0xFF3A2608)
            ..strokeWidth = m % 5 == 0 ? 2 : 1);
    }
    final m = minutos % (24 * 60);
    final aHora = ((m / 60) % 12) / 12 * math.pi * 2 - math.pi / 2;
    final aMinuto = (m % 60) / 60 * math.pi * 2 - math.pi / 2;
    canvas.drawLine(centro, centro + Offset(math.cos(aHora), math.sin(aHora)) * radio * 0.5,
        Paint()
          ..color = const Color(0xFF14102A)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(centro, centro + Offset(math.cos(aMinuto), math.sin(aMinuto)) * radio * 0.78,
        Paint()
          ..color = const Color(0xFF14102A)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(centro, 6, Paint()..color = PaletaNeon.rosaAcento);
    _texto(canvas, horaDe(m), Offset(size.width / 2, centro.dy + radio + 22), 22, color: PaletaNeon.ambarCanales);
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tamano, {Color color = const Color(0xFF14102A)}) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorReloj anterior) => anterior.minutos != minutos;
}
