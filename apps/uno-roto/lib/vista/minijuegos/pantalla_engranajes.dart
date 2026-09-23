import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/engranajes.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Engranajes — segunda sala de Rexán. Se elige un número entre cuatro y
/// la máquina lo prueba de verdad: las ruedas giran esos dientes (¿han
/// vuelto las marcas arriba?) o los cabos se cortan en trozos de ese
/// largo (¿sobra algo?). El primer intento de cada reto es el que cuenta
/// para la maestría; después se puede probar otros para ver qué pasa.
///
/// Niveles (seis rondas en tres tramos): MCM con dos ruedas; MCD con
/// cabos; y la rueda oxidada o tres ruedas.
class PantallaEngranajes extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaEngranajes({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaEngranajes> createState() => _PantallaEngranajesState();
}

class _PantallaEngranajesState extends State<PantallaEngranajes>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_engranajes';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.engranajes);

  late final GeneradorEngranajes _generador;
  late final AnimationController _giro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));
  late RetoEngranajes _reto;
  int _ronda = 1;
  int? _probado;
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
    _generador = GeneradorEngranajes(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    final dificultad = _enNivel.dificultad;
    _reto = switch (_nivel) {
      1 => _enNivel.extra > 0
          ? _generador.tresRuedas(dificultad: dificultad)
          : _generador.generar(TipoEngranaje.mcm, dificultad: dificultad),
      2 => _generador.generar(TipoEngranaje.mcd, dificultad: dificultad),
      // Nivel 3: la rueda oxidada y, en la otra ronda, tres ruedas.
      _ => _ronda.isOdd
          ? _generador.tresRuedas(dificultad: dificultad)
          : _generador.generar(TipoEngranaje.oxidado, dificultad: dificultad),
    };
    _probado = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _giro.value = 0;
  }

  Future<void> _probar(int valor) async {
    if (_resuelto || _giro.isAnimating) return;
    HapticFeedback.selectionClick();
    final acierta = valor == _reto.respuesta;
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
      _probado = valor;
      _lineaRexan = null;
    });
    sonar('efecto_tablon');
    await _giro.forward(from: 0);
    if (!mounted) return;
    setState(() {
      if (acierta) {
        _resuelto = true;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          TipoEngranaje.mcd => 'Trozos de {n} m y no sobra nada. Más largos no salen.',
          _ => 'Clac. Las marcas arriba a la vez: la grúa arranca.',
        };
        _datosLinea = {'n': '$valor'};
      } else {
        anotarFallo();
        _explicarFallo(valor);
      }
    });
    if (acierta) {
      sonar('efecto_acierto');
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      setState(() {
        if (_ronda >= _definicion.rondasPorPartida) {
          _terminada = true;
        } else {
          _ronda++;
          _nuevoReto();
        }
      });
    } else {
      sonar('efecto_error');
    }
  }

  /// Rexán dice qué ha pasado con el número probado (sin dar la buena).
  void _explicarFallo(int valor) {
    switch (_reto.tipo) {
      case TipoEngranaje.mcm:
        final sinVueltaEntera = _reto.numeros.where((n) => valor % n != 0).toList();
        if (sinVueltaEntera.isNotEmpty) {
          _lineaRexan = 'Con {v}, la rueda de {n} no ha dado vueltas enteras: su marca no está arriba.';
          _datosLinea = {'v': '$valor', 'n': '${sinVueltaEntera.first}'};
        } else {
          _lineaRexan = 'Coinciden en {v}, sí. Pero antes ya se habían juntado.';
          _datosLinea = {'v': '$valor'};
        }
      case TipoEngranaje.mcd:
        final [a, b] = _reto.numeros;
        if (a % valor != 0 || b % valor != 0) {
          _lineaRexan = 'Con trozos de {v} m, sobra un pedazo de cabo.';
          _datosLinea = {'v': '$valor'};
        } else {
          _lineaRexan = 'Salen iguales y no sobra nada, pero se pueden cortar más largos.';
          _datosLinea = const {};
        }
      case TipoEngranaje.oxidado:
        _lineaRexan = 'Con {v} dientes coincidirían tras {m}, no tras {c}.';
        _datosLinea = {
          'v': '$valor',
          'm': '${mcm(_reto.numeros.first, valor)}',
          'c': '${_reto.coincidencia}',
        };
    }
  }

  String _enunciado(Locale locale) {
    final (plantilla, datos) = switch (_reto.tipo) {
      TipoEngranaje.mcm when _reto.numeros.length == 3 => (
          'Ruedas de {a}, {b} y {c} dientes. ¿Tras cuántos dientes vuelven las tres marcas arriba?',
          {'a': '${_reto.numeros[0]}', 'b': '${_reto.numeros[1]}', 'c': '${_reto.numeros[2]}'},
        ),
      TipoEngranaje.mcm => (
          'Ruedas de {a} y {b} dientes. ¿Tras cuántos dientes vuelven las dos marcas arriba?',
          {'a': '${_reto.numeros[0]}', 'b': '${_reto.numeros[1]}'},
        ),
      TipoEngranaje.mcd => (
          'Cabos de {a} m y {b} m. ¿Cuánto mide el trozo más largo que corta los dos sin que sobre?',
          {'a': '${_reto.numeros[0]}', 'b': '${_reto.numeros[1]}'},
        ),
      TipoEngranaje.oxidado => (
          'Una rueda de {a} dientes y otra oxidada. Sus marcas coinciden tras {c} dientes. ¿Cuántos dientes tiene la oxidada?',
          {'a': '${_reto.numeros[0]}', 'c': '${_reto.coincidencia}'},
        ),
    };
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    var linea = traducirNarrativa(
        _terminada
            ? 'Seis arranques. La grúa ya carga sola; tú a descansar.'
            : _lineaRexan ?? _definicion.lineaRexan,
        locale);
    _datosLinea.forEach((clave, valor) => linea = linea.replaceAll('{$clave}', valor));
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
          Text(
            _enunciado(locale),
            key: const ValueKey('enunciado-engranajes'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _giro,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _reto.tipo == TipoEngranaje.mcd
                    ? PintorCabos(
                        cabos: _reto.numeros,
                        trozo: _probado,
                        progreso: _giro.value,
                      )
                    : PintorRuedas(
                        dientes: [
                          for (var i = 0; i < _reto.numeros.length; i++)
                            // La oxidada gira con los dientes que se prueban.
                            _reto.tipo == TipoEngranaje.oxidado && i == 1
                                ? (_probado ?? 0)
                                : _reto.numeros[i],
                        ],
                        oxidada: _reto.tipo == TipoEngranaje.oxidado,
                        // La oxidada: giran hasta donde de verdad
                        // coincidirían con la rueda probada.
                        dientesGirados: _reto.tipo == TipoEngranaje.oxidado
                            ? (_probado == null ? 0 : mcm(_reto.numeros.first, _probado!))
                            : (_probado ?? 0),
                        progreso: _giro.value,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              for (final opcion in _reto.opciones)
                _BotonOpcion(
                  key: ValueKey('opcion-$opcion'),
                  valor: opcion,
                  unidad: _reto.tipo == TipoEngranaje.mcd ? ' m' : '',
                  elegida: _probado == opcion,
                  alPulsar: _resuelto ? null : () => _probar(opcion),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BotonOpcion extends StatelessWidget {
  final int valor;
  final String unidad;
  final bool elegida;
  final VoidCallback? alPulsar;

  const _BotonOpcion({
    super.key,
    required this.valor,
    required this.unidad,
    required this.elegida,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext contexto) => GestureDetector(
        onTap: alPulsar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: elegida
                  ? [PaletaNeon.ambarCanales.withOpacity(0.35), PaletaNeon.ambarCanales.withOpacity(0.12)]
                  : [const Color(0xFF2A1A55), PaletaNeon.fondoMedio],
            ),
            border: Border.all(
                color: elegida ? PaletaNeon.ambarCanales : PaletaNeon.violetaNeon.withOpacity(0.45)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$valor$unidad',
              style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 22)),
        ),
      );
}

/// Ruedas dentadas engranadas en fila, cada una con su marca roja. Al
/// probar un número, giran esos dientes (las vecinas en sentido
/// contrario); si una marca acaba arriba, brilla en verde.
class PintorRuedas extends CustomPainter {
  final List<int> dientes;
  final bool oxidada;
  final int dientesGirados;
  final double progreso;

  PintorRuedas({
    required this.dientes,
    required this.oxidada,
    required this.dientesGirados,
    required this.progreso,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Radio proporcional a los dientes (así engranan), escalado al hueco.
    final radiosBase = [for (final d in dientes) 6.0 + math.max(d, 4) * 1.6];
    final anchoTotal = radiosBase.fold(0.0, (s, r) => s + 2 * r);
    final escala = math.min(size.width * 0.92 / anchoTotal, size.height * 0.8 / (2 * radiosBase.reduce(math.max)));
    var x = (size.width - anchoTotal * escala) / 2;
    final t = Curves.easeInOutCubic.transform(progreso);
    for (var i = 0; i < dientes.length; i++) {
      final radio = radiosBase[i] * escala;
      final centro = Offset(x + radio, size.height / 2);
      x += 2 * radio;
      final esOxidada = oxidada && i == dientes.length - 1;
      final numeroDientes = dientes[i];
      final vueltas = numeroDientes == 0 ? 0.0 : dientesGirados / numeroDientes;
      final sentido = i.isEven ? 1 : -1;
      final angulo = sentido * vueltas * t * math.pi * 2;
      final marcaArriba = progreso >= 1 && numeroDientes > 0 && dientesGirados % numeroDientes == 0;
      _rueda(canvas, centro, radio, numeroDientes == 0 ? 12 : numeroDientes, angulo,
          oxidada: esOxidada, marcaArriba: marcaArriba && dientesGirados > 0);
      // El número de dientes, debajo (la oxidada lo esconde hasta probar).
      final etiqueta = esOxidada && numeroDientes == 0 ? '?' : '$numeroDientes';
      _texto(canvas, etiqueta, centro + Offset(0, radio + 14),
          esOxidada ? const Color(0xFFD08A4E) : PaletaNeon.textoPrincipal);
    }
    // El puntero fijo arriba: ahí tienen que volver las marcas.
    canvas.drawLine(Offset(0, size.height / 2 - radiosBase.reduce(math.max) * escala - 10),
        Offset(size.width, size.height / 2 - radiosBase.reduce(math.max) * escala - 10),
        Paint()
          ..color = PaletaNeon.textoTenue.withOpacity(0.15)
          ..strokeWidth = 1);
  }

  void _rueda(Canvas canvas, Offset centro, double radio, int numeroDientes, double angulo,
      {required bool oxidada, required bool marcaArriba}) {
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(angulo);
    // Dientes contables: altos y estrechos sobre un círculo base, para
    // que una rueda de 4 se vea como una rueda de 4.
    final alto = radio * 0.22;
    final raiz = radio - alto;
    Offset polar(double r, double a) =>
        Offset(math.cos(a - math.pi / 2) * r, math.sin(a - math.pi / 2) * r);
    final paso = math.pi * 2 / numeroDientes;
    final cuerpo = Path();
    for (var d = 0; d < numeroDientes; d++) {
      final centroDiente = d * paso;
      final baseMitad = paso * 0.22;
      final puntaMitad = paso * 0.14 * (raiz / radio);
      final puntos = [
        polar(raiz, centroDiente - paso / 2),
        polar(raiz, centroDiente - baseMitad),
        polar(radio, centroDiente - puntaMitad),
        polar(radio, centroDiente + puntaMitad),
        polar(raiz, centroDiente + baseMitad),
      ];
      if (d == 0) cuerpo.moveTo(puntos.first.dx, puntos.first.dy);
      // El tramo de círculo base entre dientes, suave.
      cuerpo.arcTo(Rect.fromCircle(center: Offset.zero, radius: raiz),
          centroDiente - paso / 2 - math.pi / 2, paso / 2 - baseMitad, false);
      for (final punto in puntos.skip(2)) {
        cuerpo.lineTo(punto.dx, punto.dy);
      }
      cuerpo.arcTo(Rect.fromCircle(center: Offset.zero, radius: raiz),
          centroDiente + baseMitad - math.pi / 2, paso / 2 - baseMitad, false);
    }
    cuerpo.close();
    final colores = oxidada
        ? const [Color(0xFFB0683A), Color(0xFF5A2E16)]
        : const [Color(0xFFB9B2DE), Color(0xFF4A4370)];
    canvas.drawPath(
        cuerpo,
        Paint()
          ..shader = RadialGradient(colors: colores)
              .createShader(Rect.fromCircle(center: Offset.zero, radius: radio)));
    canvas.drawPath(
        cuerpo,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.black.withOpacity(0.4));
    // Cubo central y radios.
    canvas.drawCircle(Offset.zero, radio * 0.28, Paint()..color = const Color(0xFF2A2250));
    canvas.drawCircle(Offset.zero, radio * 0.1, Paint()..color = PaletaNeon.grisMetal);
    // La marca roja, en el diente de arriba.
    final marca = Offset(0, -(raiz - radio * 0.14));
    canvas.drawCircle(marca, radio * 0.09 + 2,
        Paint()..color = marcaArriba ? PaletaNeon.exitoSuave : const Color(0xFFE0453A));
    if (oxidada) {
      // Manchas de óxido.
      final mancha = Paint()..color = const Color(0xFF7A3A18).withOpacity(0.7);
      for (var i = 0; i < 5; i++) {
        final a = i * 1.3;
        canvas.drawCircle(Offset(math.cos(a) * radio * 0.55, math.sin(a) * radio * 0.55),
            radio * 0.08, mancha);
      }
    }
    canvas.restore();
    if (marcaArriba) {
      canvas.drawCircle(centro + Offset(0, -(radio * 0.64)), radio * 0.2,
          Paint()
            ..color = PaletaNeon.exitoSuave.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: 15)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorRuedas anterior) => true;
}

/// Dos cabos a escala. Al probar un largo, las marcas de corte aparecen
/// una a una; si al final sobra un pedazo, se ve en rosa.
class PintorCabos extends CustomPainter {
  final List<int> cabos;
  final int? trozo;
  final double progreso;

  PintorCabos({required this.cabos, required this.trozo, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final largoMaximo = cabos.reduce(math.max);
    final margen = 16.0;
    final escala = (size.width - 2 * margen) / largoMaximo;
    for (var i = 0; i < cabos.length; i++) {
      final y = size.height * (0.32 + 0.36 * i);
      final largo = cabos[i];
      final fin = margen + largo * escala;
      final cuerda = Paint()
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(colors: [Color(0xFFD9B77A), Color(0xFF9C7A40)])
            .createShader(Rect.fromLTWH(margen, y - 5, largo * escala, 10));
      canvas.drawLine(Offset(margen, y), Offset(fin, y), cuerda);
      // Trenzado: rayitas oblicuas.
      final trenza = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 1;
      for (var x = margen + 4; x < fin - 2; x += 6) {
        canvas.drawLine(Offset(x, y - 4), Offset(x + 3, y + 4), trenza);
      }
      _texto(canvas, '$largo m', Offset(fin - 18, y - 20), PaletaNeon.textoTenue);

      final corte = trozo;
      if (corte == null || corte <= 0) continue;
      final cortesTotales = largo ~/ corte;
      final visibles = (cortesTotales * progreso).floor();
      final tijera = Paint()
        ..color = PaletaNeon.ambarCanales
        ..strokeWidth = 2;
      for (var c = 1; c <= visibles; c++) {
        final x = margen + c * corte * escala;
        if (c * corte >= largo) break;
        canvas.drawLine(Offset(x, y - 12), Offset(x, y + 12), tijera);
      }
      final sobra = largo % corte;
      if (progreso >= 1 && sobra > 0) {
        canvas.drawLine(
            Offset(fin - sobra * escala, y),
            Offset(fin, y),
            Paint()
              ..strokeWidth = 12
              ..strokeCap = StrokeCap.round
              ..color = PaletaNeon.rosaAcento.withOpacity(0.75));
        _texto(canvas, '+$sobra m', Offset(fin - sobra * escala / 2, y + 20), PaletaNeon.rosaAcento);
      }
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: 13)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorCabos anterior) => true;
}
