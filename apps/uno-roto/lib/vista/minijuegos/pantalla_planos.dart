import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart' show Celda;
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/planos.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Planos — segunda sala de Rexán. Se arrastra el dedo sobre la
/// cuadrícula (o se tocan dos esquinas) para dibujar la habitación y se
/// entrega. Sólo cuenta la primera entrega de cada encargo; mover las
/// esquinas mientras se piensa no es un intento.
class PantallaPlanos extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaPlanos({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaPlanos> createState() => _PantallaPlanosState();
}

class _PantallaPlanosState extends State<PantallaPlanos>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_planos';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.planos);

  /// Un encargo por ronda: dos de área, dos de valla, triángulo y dm².
  static const _encargos = [
    TipoEncargo.area,
    TipoEncargo.area,
    TipoEncargo.areaMinimoPerimetro,
    TipoEncargo.perimetroMaximaArea,
    TipoEncargo.triangulo,
    TipoEncargo.unidades,
  ];

  late final math.Random _azar;
  late PartidaPlanos _partida;
  Timer? _crecimiento;
  Rectangulo? _plano;
  Celda? _esquina;
  int _ronda = 1;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _terminada = false;
  bool _pausado = false;
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
    _nuevoEncargo();
  }

  @override
  void dispose() {
    _crecimiento?.cancel();
    super.dispose();
  }

  void _nuevoEncargo() {
    final malezaViva = _nivel >= 3 && (_enNivel.dificultad >= 3 || _enNivel.extra > 0);
    _partida = PartidaPlanos(
      tipo: _encargos[_ronda - 1],
      dificultad: _enNivel.dificultad,
      malezaViva: malezaViva,
      azar: _azar,
    );
    _plano = null;
    _esquina = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = malezaViva ? 'Esta maleza crece mientras piensas. No hay prisa, pero no para.' : null;
    _datosLinea = const {};
    _inicio = DateTime.now();
    _crecimiento?.cancel();
    if (malezaViva) {
      _crecimiento = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted || _pausado || _resuelto) return;
        final nueva = _partida.crecerMaleza();
        if (nueva == null) return;
        setState(() {
          // Si ha crecido debajo de lo dibujado, el plano sigue ahí: al
          // entregar, Rexán avisará de la maleza.
        });
      });
    }
  }

  Celda? _celdaEn(Offset posicion, Size lienzo) {
    final lado = lienzo.width / PartidaPlanos.columnas;
    final columna = (posicion.dx / lado).floor();
    final fila = (posicion.dy / lado).floor();
    if (columna < 0 || fila < 0 || columna >= PartidaPlanos.columnas || fila >= PartidaPlanos.filas) {
      return null;
    }
    return Celda(fila, columna);
  }

  void _alEmpezarArrastre(Offset posicion, Size lienzo) {
    final celda = _celdaEn(posicion, lienzo);
    if (celda == null || _resuelto) return;
    setState(() {
      _esquina = celda;
      _plano = Rectangulo.entre(celda, celda);
    });
  }

  void _alArrastrar(Offset posicion, Size lienzo) {
    final celda = _celdaEn(posicion, lienzo);
    final esquina = _esquina;
    if (celda == null || esquina == null || _resuelto) return;
    setState(() => _plano = Rectangulo.entre(esquina, celda));
  }

  /// Sin arrastrar: primer toque, una esquina; segundo, la opuesta.
  void _alTocar(Offset posicion, Size lienzo) {
    final celda = _celdaEn(posicion, lienzo);
    if (celda == null || _resuelto) return;
    HapticFeedback.selectionClick();
    setState(() {
      final esquina = _esquina;
      if (esquina == null || _plano == null || _plano!.area > 1) {
        _esquina = celda;
        _plano = Rectangulo.entre(celda, celda);
      } else {
        _plano = Rectangulo.entre(esquina, celda);
      }
    });
  }

  Future<void> _entregar() async {
    final plano = _plano;
    if (plano == null || _resuelto) return;
    final resultado = _partida.evaluar(plano);
    if (resultado == ResultadoPlano.sobreMaleza || resultado == ResultadoPlano.fuera) {
      // No es un error de matemáticas: no se registra.
      setState(() {
        _lineaRexan = 'Ahí hay maleza: no se puede construir encima. Muévelo.';
        _datosLinea = const {};
      });
      return;
    }
    final acierta = resultado == ResultadoPlano.bien;
    if (!_yaRegistrado) {
      _yaRegistrado = true;
      widget.registro?.registrar(
        idHabilidad: _partida.encargo.idHabilidad,
        acierto: acierta,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: DateTime.now().difference(_inicio),
      );
    }
    setState(() {
      _datosLinea = {
        'a': '${plano.area}',
        'p': '${plano.perimetro}',
        'P': '${_partida.encargo.valor}',
        't': _medio(plano.area),
      };
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = 'Sellado. Esa casa se puede construir.';
      } else {
        anotarFallo();
        _lineaRexan = switch (resultado) {
          ResultadoPlano.perimetroDistinto => 'Esa valla mide {p} m, no {P}.',
          ResultadoPlano.noOptimo when _partida.encargo.tipo == TipoEncargo.perimetroMaximaArea =>
            'Con {P} m de valla cabe un huerto más grande.',
          ResultadoPlano.noOptimo => 'Tiene {a} m², sí, pero lleva {p} m de valla. Se puede con menos.',
          _ when _partida.encargo.tipo == TipoEncargo.triangulo =>
            'Ese triángulo tiene {t} m²: la mitad del rectángulo de {a}.',
          _ => 'Esa habitación tiene {a} m². El encargo pide otra cosa.',
        };
      }
    });
    if (acierta) {
      HapticFeedback.heavyImpact();
      sonar('efecto_acierto');
      await Future.delayed(const Duration(milliseconds: 1700));
      if (!mounted) return;
      setState(() {
        if (_ronda >= _definicion.rondasPorPartida) {
          _terminada = true;
          _crecimiento?.cancel();
        } else {
          _ronda++;
          _nuevoEncargo();
        }
      });
    } else {
      HapticFeedback.vibrate();
      sonar('efecto_error');
    }
  }

  static String _medio(int area) =>
      area.isEven ? '${area ~/ 2}' : '${area ~/ 2},5';

  String _texto(String plantilla, Locale locale, [Map<String, String> datos = const {}]) {
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  String _textoEncargo(Locale locale) {
    final valor = '${_partida.encargo.valor}';
    return switch (_partida.encargo.tipo) {
      TipoEncargo.area => _texto('Una habitación de {v} m².', locale, {'v': valor}),
      TipoEncargo.areaMinimoPerimetro =>
        _texto('Una habitación de {v} m² con la menor valla posible.', locale, {'v': valor}),
      TipoEncargo.perimetroMaximaArea =>
        _texto('Con {v} m de valla, el huerto más grande posible.', locale, {'v': valor}),
      TipoEncargo.triangulo =>
        _texto('Un tejado triangular de {v} m²: dibuja el rectángulo que lo contiene.', locale, {'v': valor}),
      TipoEncargo.unidades => _texto('Una habitación de {v} dm².', locale, {'v': valor}),
    };
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final plano = _plano;
    final esTriangulo = _partida.encargo.tipo == TipoEncargo.triangulo;
    final linea = _terminada
        ? _texto('Seis planos sellados. Las Afueras ya tienen barrio.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.encargo.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: linea,
      terminada: _terminada,
      child: Column(
        children: [
          Text(
            _textoEncargo(locale),
            key: const ValueKey('encargo-planos'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 17, height: 1.35),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: PartidaPlanos.columnas / PartidaPlanos.filas,
                child: LayoutBuilder(
                  builder: (_, restricciones) {
                    final lienzo = restricciones.biggest;
                    return GestureDetector(
                      key: const ValueKey('cuadricula-planos'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _alEmpezarArrastre(d.localPosition, lienzo),
                      onPanUpdate: (d) => _alArrastrar(d.localPosition, lienzo),
                      onTapUp: (d) => _alTocar(d.localPosition, lienzo),
                      child: CustomPaint(
                        size: lienzo,
                        painter: PintorPlano(
                          maleza: _partida.maleza,
                          plano: plano,
                          triangulo: esTriangulo,
                          sellado: _resuelto,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            plano == null
                ? _texto('Arrastra el dedo de una esquina a la otra.', locale)
                : esTriangulo
                    ? _texto('Rectángulo: {a} m² · Tejado: {t} m²', locale,
                        {'a': '${plano.area}', 't': _medio(plano.area)})
                    : _texto('Área: {a} m² · Valla: {p} m', locale,
                        {'a': '${plano.area}', 'p': '${plano.perimetro}'}),
            key: const ValueKey('medidas-planos'),
            style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 16),
          ),
          const SizedBox(height: 10),
          BotonMinijuego(
            texto: traducirNarrativa('ENTREGAR', locale),
            alPulsar: plano == null || _resuelto ? null : _entregar,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Papel de plano: fondo azul, cuadrícula blanca, la maleza en verde neón
/// y la habitación dibujada con sus medidas en los lados. En los tejados,
/// el triángulo (media habitación) en ámbar. Sellado: un sello verde.
class PintorPlano extends CustomPainter {
  final Set<Celda> maleza;
  final Rectangulo? plano;
  final bool triangulo;
  final bool sellado;

  PintorPlano({
    required this.maleza,
    required this.plano,
    required this.triangulo,
    required this.sellado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width / PartidaPlanos.columnas;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF123A6E));
    final linea = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 1;
    for (var c = 0; c <= PartidaPlanos.columnas; c++) {
      canvas.drawLine(Offset(c * lado, 0), Offset(c * lado, size.height), linea);
    }
    for (var f = 0; f <= PartidaPlanos.filas; f++) {
      canvas.drawLine(Offset(0, f * lado), Offset(size.width, f * lado), linea);
    }

    // Maleza: matas de hierba neón.
    final hierba = Paint()
      ..color = const Color(0xFF6BE38A)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final celda in maleza) {
      final base = Offset((celda.columna + 0.5) * lado, (celda.fila + 0.85) * lado);
      canvas.drawRect(Rect.fromLTWH(celda.columna * lado, celda.fila * lado, lado, lado),
          Paint()..color = const Color(0xFF1E5A3A).withOpacity(0.8));
      for (final (dx, alto) in [(-0.22, 0.5), (-0.08, 0.65), (0.06, 0.55), (0.2, 0.45)]) {
        canvas.drawLine(base + Offset(dx * lado, 0),
            base + Offset(dx * lado * 1.6, -alto * lado), hierba);
      }
    }

    final dibujado = plano;
    if (dibujado == null) return;
    final rect = Rect.fromLTWH(dibujado.columna * lado, dibujado.fila * lado,
        dibujado.ancho * lado, dibujado.alto * lado);
    final pisaMaleza = dibujado.celdas.any(maleza.contains);
    final color = pisaMaleza ? PaletaNeon.rosaAcento : Colors.white;
    canvas.drawRect(rect, Paint()..color = color.withOpacity(0.14));
    if (triangulo) {
      final tejado = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.top)
        ..close();
      canvas.drawPath(tejado, Paint()..color = PaletaNeon.ambarCanales.withOpacity(0.55));
      canvas.drawPath(
          tejado,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = PaletaNeon.ambarCanales);
    }
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color);
    // Cotas: el ancho arriba y el alto a la izquierda.
    _texto(canvas, '${dibujado.ancho} m', Offset(rect.center.dx, rect.top - 9));
    _texto(canvas, '${dibujado.alto} m', Offset(rect.left - 16, rect.center.dy));
    if (sellado) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(-0.25);
      final sello = Rect.fromCenter(center: Offset.zero, width: math.max(60, rect.width * 0.7), height: 30);
      canvas.drawRRect(
          RRect.fromRectAndRadius(sello, const Radius.circular(6)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = PaletaNeon.exitoSuave);
      canvas.drawPath(
          Path()
            ..moveTo(-9, 0)
            ..lineTo(-2, 7)
            ..lineTo(11, -7),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round
            ..color = PaletaNeon.exitoSuave);
      canvas.restore();
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro,
      {Color color = Colors.white, double tamano = 12}) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorPlano anterior) => true;
}
