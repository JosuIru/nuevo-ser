import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/telar.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// El telar — segunda sala de Rexán. Se elige el resultado entre cuatro;
/// al acertar, la tela lo enseña: las telas juntas, los hilos cruzados
/// teñidos, el reparto o las cintas cortadas. Cuenta el primer intento.
class PantallaTelar extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaTelar({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaTelar> createState() => _PantallaTelarState();
}

class _PantallaTelarState extends State<PantallaTelar>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_telar';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.telar);
  static const _tipos = [
    TipoTelar.porNatural,
    TipoTelar.porNatural,
    TipoTelar.porFraccion,
    TipoTelar.porFraccion,
    TipoTelar.dividirNatural,
    TipoTelar.dividirFraccion,
  ];

  late final GeneradorTelar _generador;
  late final AnimationController _tenido = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  late RetoTelar _reto;
  int _ronda = 1;
  String? _elegida;
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
    _generador = GeneradorTelar(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _tenido.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _tenido.value = 0;
  }

  Future<void> _elegir(String opcion) async {
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
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          TipoTelar.porFraccion => 'Lo que se cruza es el resultado: mira la tela.',
          TipoTelar.dividirFraccion => 'Cortadas y contadas.',
          _ => 'Tela medida. Al telar.',
        };
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoTelar.porNatural => 'Junta las telas: se suman los trozos, el tamaño del trozo no cambia.',
          TipoTelar.porFraccion => 'Por fracción: arriba por arriba y abajo por abajo. No se suma nada.',
          TipoTelar.dividirNatural => 'Repartir entre varios hace los trozos más pequeños: el de abajo crece.',
          TipoTelar.dividirFraccion => 'Cuenta cuántas cintas de ese largo caben en la tela.',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _tenido.forward(from: 0);
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
        ? _texto('Seis telas tejidas. Las Polillas se quedan sin cena.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale);
    final pregunta = switch (_reto.tipo) {
      TipoTelar.porNatural => _texto('{k} telas de {f} de metro. ¿Cuánta tela en total?', locale, {'k': '${d[2]}', 'f': '${d[0]}/${d[1]}'}),
      TipoTelar.porFraccion => _texto('Un hilo a {f} del ancho y otro a {g} del alto. ¿Cuánto es {f} × {g}?', locale,
          {'f': '${d[0]}/${d[1]}', 'g': '${d[2]}/${d[3]}'}),
      TipoTelar.dividirNatural => _texto('Reparte {f} de tela entre {k}. ¿Cuánto para cada uno?', locale,
          {'f': '${d[0]}/${d[1]}', 'k': '${d[2]}'}),
      TipoTelar.dividirFraccion => _texto('¿Cuántas cintas de 1/{c} de metro salen de {f} de metro?', locale,
          {'c': '${d[2]}', 'f': '${d[0]}/${d[1]}'}),
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
              key: const ValueKey('pregunta-telar'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _tenido,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: PintorTelar(reto: _reto, tenido: _tenido.value),
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
                        child: Text(opcion, style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 22)),
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

/// La tela del telar según el reto. [tenido] (0→1) enseña la respuesta.
class PintorTelar extends CustomPainter {
  final RetoTelar reto;
  final double tenido;

  PintorTelar({required this.reto, required this.tenido});

  static const _tela = Color(0xFFE8E2D0);
  static const _tinte = Color(0xFFD9848C);
  static const _hilo = Color(0xFF3F74D8);

  @override
  void paint(Canvas canvas, Size size) {
    switch (reto.tipo) {
      case TipoTelar.porNatural:
        _telas(canvas, size);
      case TipoTelar.porFraccion:
        _cruce(canvas, size);
      case TipoTelar.dividirNatural:
        _reparto(canvas, size);
      case TipoTelar.dividirFraccion:
        _cintas(canvas, size);
    }
  }

  void _tira(Canvas canvas, Rect rect, int partes, int tenidas, {Color color = _tinte}) {
    canvas.drawRect(rect, Paint()..color = _tela);
    final ancho = rect.width / partes;
    for (var i = 0; i < partes; i++) {
      final trozo = Rect.fromLTWH(rect.left + i * ancho, rect.top, ancho, rect.height);
      if (i < tenidas) canvas.drawRect(trozo.deflate(1), Paint()..color = color);
      canvas.drawRect(
          trozo,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFF6B4A14).withOpacity(0.5));
    }
  }

  void _polillas(Canvas canvas, Rect zona, int semilla) {
    final azar = math.Random(semilla);
    for (var i = 0; i < 3; i++) {
      final centro = Offset(zona.left + azar.nextDouble() * zona.width, zona.top + azar.nextDouble() * zona.height);
      canvas.drawCircle(centro, 3 + azar.nextDouble() * 3, Paint()..color = const Color(0xFF14102A));
    }
  }

  void _telas(Canvas canvas, Size size) {
    final [n, d, k] = reto.datos;
    final alto = math.min(34.0, size.height / (k + 3));
    final ancho = size.width * 0.9;
    for (var i = 0; i < k; i++) {
      final rect = Rect.fromLTWH(size.width * 0.05, 10 + i * (alto + 8), ancho, alto);
      _tira(canvas, rect, d, n);
      _polillas(canvas, Rect.fromLTRB(rect.left + ancho * n / d, rect.top, rect.right, rect.bottom), i + d);
    }
    if (tenido > 0) {
      // Todas juntas, una detrás de otra, en metros enteros.
      final total = n * k;
      final metros = (total / d).ceil();
      final y = 10 + k * (alto + 8) + 12;
      final anchoMetro = ancho / math.max(metros, 1);
      for (var m = 0; m < metros; m++) {
        final rect = Rect.fromLTWH(size.width * 0.05 + m * anchoMetro, y, anchoMetro - 4, alto);
        final tenidasAqui = math.min(d, math.max(0, total - m * d));
        _tira(canvas, rect, d, (tenidasAqui * tenido).round());
      }
    }
  }

  void _cruce(Canvas canvas, Size size) {
    final [a, b, c, d] = reto.datos;
    final lado = math.min(size.width, size.height) * 0.86;
    final origen = Offset((size.width - lado) / 2, (size.height - lado) / 2);
    final cuadro = origen & Size(lado, lado);
    canvas.drawRect(cuadro, Paint()..color = _tela);
    final anchoCelda = lado / b;
    final altoCelda = lado / d;
    for (var i = 0; i < b; i++) {
      for (var j = 0; j < d; j++) {
        final celda = Rect.fromLTWH(origen.dx + i * anchoCelda, origen.dy + lado - (j + 1) * altoCelda, anchoCelda, altoCelda);
        final enA = i < a;
        final enC = j < c;
        Color? color;
        if (enA && enC) {
          color = Color.lerp(_hilo.withOpacity(0.25), _tinte, tenido);
        } else if (enA || enC) {
          color = _hilo.withOpacity(0.18);
        }
        if (color != null) canvas.drawRect(celda.deflate(1), Paint()..color = color);
        canvas.drawRect(
            celda,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = const Color(0xFF6B4A14).withOpacity(0.4));
      }
    }
    // Los dos hilos.
    final hilo = Paint()
      ..color = _hilo
      ..strokeWidth = 3;
    final x = origen.dx + a * anchoCelda;
    final y = origen.dy + lado - c * altoCelda;
    canvas.drawLine(Offset(x, origen.dy - 6), Offset(x, origen.dy + lado + 6), hilo);
    canvas.drawLine(Offset(origen.dx - 6, y), Offset(origen.dx + lado + 6, y), hilo);
  }

  void _reparto(Canvas canvas, Size size) {
    final [n, d, k] = reto.datos;
    final rect = Rect.fromLTWH(size.width * 0.05, size.height * 0.2, size.width * 0.9, 44);
    _tira(canvas, rect, d, n);
    _polillas(canvas, Rect.fromLTRB(rect.left + rect.width * n / d, rect.top, rect.right, rect.bottom), n + d);
    if (tenido > 0) {
      // La parte teñida, cortada en k trozos iguales: uno para cada uno.
      final parte = rect.width * n / d;
      for (var i = 1; i < k; i++) {
        final x = rect.left + parte * i / k;
        canvas.drawLine(Offset(x, rect.top - 8 * tenido), Offset(x, rect.bottom + 8 * tenido),
            Paint()
              ..color = PaletaNeon.ambarCanales
              ..strokeWidth = 2.5);
      }
      final uno = Rect.fromLTWH(rect.left, rect.bottom + 28, parte / k, 44);
      canvas.drawRect(uno, Paint()..color = _tinte.withOpacity(tenido));
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom + 28, rect.width, 44),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = _tela.withOpacity(0.5 * tenido));
    }
  }

  void _cintas(Canvas canvas, Size size) {
    final [a, b, c] = reto.datos;
    final metros = (a / b).ceil();
    final anchoMetro = size.width * 0.9 / metros;
    final izquierda = size.width * 0.05;
    final y = size.height * 0.35;
    // Regla de metros y la tela de a/b.
    for (var m = 0; m <= metros; m++) {
      canvas.drawLine(Offset(izquierda + m * anchoMetro, y - 14), Offset(izquierda + m * anchoMetro, y + 60),
          Paint()
            ..color = PaletaNeon.textoTenue.withOpacity(0.4)
            ..strokeWidth = 1);
    }
    final largo = anchoMetro * a / b;
    final tela = Rect.fromLTWH(izquierda, y, largo, 44);
    canvas.drawRect(tela, Paint()..color = _tinte);
    if (tenido > 0) {
      final cinta = anchoMetro / c;
      final cortes = (largo / cinta).round();
      final visibles = (cortes * tenido).floor();
      for (var i = 1; i <= visibles; i++) {
        final x = izquierda + i * cinta;
        if (x > tela.right + 0.5) break;
        canvas.drawLine(Offset(x, y - 6), Offset(x, y + 50),
            Paint()
              ..color = PaletaNeon.ambarCanales
              ..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(PintorTelar anterior) => true;
}
