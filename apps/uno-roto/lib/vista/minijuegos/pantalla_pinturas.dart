import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/pinturas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Color de una mezcla de azul y amarillo: el tono va del azul al
/// amarillo pasando por los verdes según la proporción. Misma razón,
/// mismo color: así la razón se ve.
Color colorMezcla(int azul, int amarillo) {
  if (azul + amarillo == 0) return const Color(0xFF6F6893);
  final t = amarillo / (azul + amarillo);
  return HSVColor.fromAHSV(1, 220 - 170 * t, 0.7, 0.85).toColor();
}

/// Pinturas — segunda sala de Rexán. Cuenta la primera entrega de cada
/// encargo; después se puede corregir hasta acertar (el toldo gris se
/// repinta).
class PantallaPinturas extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaPinturas({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaPinturas> createState() => _PantallaPinturasState();
}

class _PantallaPinturasState extends State<PantallaPinturas>
    with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_pinturas';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.pinturas);
  static const _tipos = [
    TipoPintura.reconocer,
    TipoPintura.reconocer,
    TipoPintura.escalarTotal,
    TipoPintura.escalarParte,
    TipoPintura.escala,
    TipoPintura.rebaja,
  ];

  late final GeneradorPinturas _generador;
  late RetoPinturas _reto;
  int _ronda = 1;
  int _cantidad = 0;
  int? _elegida;
  bool _yaRegistrado = false;
  bool _resuelto = false;
  bool _destenido = false;
  bool _terminada = false;
  String? _lineaRexan;
  Map<String, String> _datosLinea = const {};
  DateTime _inicio = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  bool get _colorEnVivo => _enNivel.dificultad < 3;

  @override
  void initState() {
    super.initState();
    _generador = GeneradorPinturas(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_tipos[_ronda - 1], dificultad: _enNivel.dificultad);
    _cantidad = 0;
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _destenido = false;
    _lineaRexan = null;
    _datosLinea = const {};
    _inicio = DateTime.now();
  }

  /// Lo que hay en la cubeta (azul, amarillo) en los encargos de escalar.
  (int, int) get _cubeta => switch (_reto.tipo) {
        TipoPintura.escalarTotal => (_cantidad, math.max(0, _reto.dato - _cantidad)),
        TipoPintura.escalarParte => (_reto.dato, _cantidad),
        _ => (0, 0),
      };

  Future<void> _comprobar(int valor) async {
    if (_resuelto) return;
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
      _elegida = valor;
      _datosLinea = {
        'a': '${_reto.receta.azul}',
        'b': '${_reto.receta.amarillo}',
        'v': '$valor',
        'p': '${_reto.dato}',
        'k': '${_reto.dato2}',
      };
      if (acierta) {
        _resuelto = true;
        _destenido = false;
        anotarAcierto();
        _lineaRexan = switch (_reto.tipo) {
          TipoPintura.escala => 'Justo: el puesto está a {v} m.',
          TipoPintura.rebaja => 'Eso cuesta ahora: {v} €.',
          _ => 'El toldo recupera su color.',
        };
      } else {
        _destenido = true;
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoPintura.reconocer => 'Ese cubo no guarda la receta: {a} de azul por cada {b} de amarillo. El Desteñido se come el color.',
          TipoPintura.escalarTotal || TipoPintura.escalarParte =>
            'Con esa cuenta el verde no sale: la receta es {a} de azul por cada {b} de amarillo. Repinta.',
          TipoPintura.escala => 'Cada centímetro del plano son {k} m. Mide otra vez.',
          TipoPintura.rebaja => 'Calcula el {k} % de {p} € y réstalo.',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await Future.delayed(const Duration(milliseconds: 1900));
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

  Widget _opcion(String texto, int valor, Key clave) => GestureDetector(
        key: clave,
        onTap: () => _comprobar(valor),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _elegida == valor
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
              child: Text(texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 18)),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final receta = _reto.receta;
    final colorReceta = colorMezcla(receta.azul, receta.amarillo);
    final linea = _terminada
        ? _texto('Seis toldos pintados. El Mercado vuelve a tener color.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final datosPregunta = {
      'a': '${receta.azul}',
      'b': '${receta.amarillo}',
      't': '${_reto.dato}',
      'k': '${_reto.dato2}',
    };
    final pregunta = switch (_reto.tipo) {
      TipoPintura.reconocer => _texto('Receta: {a} de azul por cada {b} de amarillo. ¿Qué cubo da el mismo color?', locale, datosPregunta),
      TipoPintura.escalarTotal => _texto('Receta {a} : {b}. Hacen falta {t} botes en total. ¿Cuántos de azul?', locale, datosPregunta),
      TipoPintura.escalarParte => _texto('Receta {a} : {b}. Ya hay {t} botes de azul. ¿Cuántos de amarillo?', locale, datosPregunta),
      TipoPintura.escala => _texto('En el plano del Mercado, 1 cm son {k} m. El puesto está a {t} cm. ¿A cuántos metros?', locale, datosPregunta),
      TipoPintura.rebaja => _texto('Un bote de {t} € con un {k} % de descuento. ¿Cuánto cuesta ahora?', locale, datosPregunta),
    };
    final (azulCubeta, amarilloCubeta) = _cubeta;
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
          SizedBox(
            height: 70,
            child: CustomPaint(
              size: Size.infinite,
              painter: PintorToldo(
                color: _resuelto
                    ? colorReceta
                    : (_destenido ? const Color(0xFF6F6B78) : colorReceta.withOpacity(0.25)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(pregunta,
              key: const ValueKey('pregunta-pinturas'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 15, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_reto.tipo) {
              TipoPintura.reconocer => Row(
                  children: [
                    for (var i = 0; i < _reto.cubos.length; i++)
                      Expanded(
                        child: GestureDetector(
                          key: ValueKey('cubo-$i'),
                          onTap: () => _comprobar(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CustomPaint(
                                    size: Size.infinite,
                                    painter: PintorCubo(
                                      // Tapados hasta elegir: se calcula, no se mira.
                                      color: _elegida == null
                                          ? const Color(0xFF3A355E)
                                          : colorMezcla(_reto.cubos[i].$1, _reto.cubos[i].$2),
                                      elegido: _elegida == i,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _texto('{a} azul\n{b} amarillo', locale,
                                      {'a': '${_reto.cubos[i].$1}', 'b': '${_reto.cubos[i].$2}'}),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              TipoPintura.escalarTotal || TipoPintura.escalarParte => Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: PintorCubo(
                          color: _colorEnVivo || _resuelto
                              ? colorMezcla(azulCubeta, amarilloCubeta)
                              : const Color(0xFF6F6893),
                          elegido: false,
                          etiqueta: '$azulCubeta · $amarilloCubeta',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BotonCantidad(
                            clave: 'menos',
                            icono: Icons.remove,
                            alPulsar: () => setState(() => _cantidad = math.max(0, _cantidad - 1))),
                        const SizedBox(width: 16),
                        Text(
                          '$_cantidad',
                          key: const ValueKey('cantidad-pinturas'),
                          style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 28),
                        ),
                        const SizedBox(width: 16),
                        _BotonCantidad(
                            clave: 'mas',
                            icono: Icons.add,
                            alPulsar: () => setState(() => _cantidad = math.min(60, _cantidad + 1))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BotonMinijuego(
                      texto: traducirNarrativa('ENTREGAR', locale),
                      alPulsar: _resuelto ? null : () => _comprobar(_cantidad),
                    ),
                  ],
                ),
              _ => Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _reto.tipo == TipoPintura.escala
                            ? PintorPlanoMercado(centimetros: _reto.dato, metrosPorCm: _reto.dato2)
                            : PintorBoteRebajado(precio: _reto.dato, porcentaje: _reto.dato2, color: colorReceta),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.4,
                      children: [
                        for (final opcion in _reto.opciones)
                          _opcion(_reto.tipo == TipoPintura.escala ? '$opcion m' : '$opcion €', opcion,
                              ValueKey('opcion-$opcion')),
                      ],
                    ),
                  ],
                ),
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  final String clave;
  final IconData icono;
  final VoidCallback alPulsar;

  const _BotonCantidad({required this.clave, required this.icono, required this.alPulsar});

  @override
  Widget build(BuildContext contexto) => GestureDetector(
        key: ValueKey('pinturas-$clave'),
        onTap: alPulsar,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: PaletaNeon.violetaNeon),
          ),
          child: Icon(icono, color: PaletaNeon.textoPrincipal),
        ),
      );
}

/// El toldo del puesto: a rayas, del color de la receta cuando está bien
/// pintado, gris cuando se lo come el Desteñido.
class PintorToldo extends CustomPainter {
  final Color color;

  PintorToldo({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final franjas = 9;
    final ancho = size.width / franjas;
    for (var i = 0; i < franjas; i++) {
      final franja = Path()
        ..moveTo(i * ancho, 0)
        ..lineTo((i + 1) * ancho, 0)
        ..lineTo((i + 1) * ancho, size.height * 0.75)
        ..quadraticBezierTo((i + 0.5) * ancho, size.height, i * ancho, size.height * 0.75)
        ..close();
      canvas.drawPath(franja, Paint()..color = i.isEven ? color : const Color(0xFFE8E2D0).withOpacity(0.85));
    }
  }

  @override
  bool shouldRepaint(PintorToldo anterior) => anterior.color != color;
}

/// Un cubo de pintura visto de frente, con su color y, si se pide, lo
/// que lleva escrito.
class PintorCubo extends CustomPainter {
  final Color color;
  final bool elegido;
  final String? etiqueta;

  PintorCubo({required this.color, required this.elegido, this.etiqueta});

  @override
  void paint(Canvas canvas, Size size) {
    final ancho = math.min(size.width * 0.96, size.height * 0.95);
    final caja = Rect.fromCenter(center: size.center(Offset.zero), width: ancho, height: ancho * 0.95);
    final cuerpo = Path()
      ..moveTo(caja.left, caja.top + ancho * 0.12)
      ..lineTo(caja.right, caja.top + ancho * 0.12)
      ..lineTo(caja.right - ancho * 0.1, caja.bottom)
      ..lineTo(caja.left + ancho * 0.1, caja.bottom)
      ..close();
    canvas.drawPath(cuerpo, Paint()..color = const Color(0xFF8A8FA0));
    canvas.drawOval(Rect.fromLTWH(caja.left, caja.top, caja.width, ancho * 0.24), Paint()..color = color);
    canvas.drawOval(
        Rect.fromLTWH(caja.left, caja.top, caja.width, ancho * 0.24),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = elegido ? 3 : 1.5
          ..color = elegido ? PaletaNeon.ambarCanales : Colors.black.withOpacity(0.4));
    // Chorreón del color por fuera.
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(caja.left + ancho * 0.18, caja.top + ancho * 0.14, ancho * 0.12, ancho * 0.3),
            Radius.circular(ancho * 0.06)),
        Paint()..color = color);
    if (etiqueta != null) {
      final pintor = TextPainter(
        text: TextSpan(text: etiqueta, style: const TextStyle(color: Colors.white, fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      pintor.paint(canvas, Offset(caja.center.dx - pintor.width / 2, caja.center.dy + ancho * 0.12));
    }
  }

  @override
  bool shouldRepaint(PintorCubo anterior) =>
      anterior.color != color || anterior.elegido != elegido || anterior.etiqueta != etiqueta;
}

/// El plano del Mercado con su regla: una línea de [centimetros] cm con
/// las marcas, y la escala en la leyenda.
class PintorPlanoMercado extends CustomPainter {
  final int centimetros;
  final int metrosPorCm;

  PintorPlanoMercado({required this.centimetros, required this.metrosPorCm});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
        Paint()..color = const Color(0xFFE8E2D0));
    final margen = 24.0;
    final paso = (size.width - 2 * margen) / 12;
    final y = size.height * 0.55;
    final tinta = Paint()
      ..color = const Color(0xFF2B2F63)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(margen, y), Offset(margen + centimetros * paso, y), tinta);
    for (var c = 0; c <= centimetros; c++) {
      canvas.drawLine(Offset(margen + c * paso, y - 6), Offset(margen + c * paso, y + 6), tinta..strokeWidth = 1.5);
    }
    // Salida y puesto.
    canvas.drawCircle(Offset(margen, y), 7, Paint()..color = const Color(0xFF3F74D8));
    canvas.drawRect(Rect.fromCenter(center: Offset(margen + centimetros * paso, y), width: 16, height: 16),
        Paint()..color = const Color(0xFFB45656));
    final leyenda = TextPainter(
      text: TextSpan(
          text: '1 cm = $metrosPorCm m',
          style: const TextStyle(color: Color(0xFF2B2F63), fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    leyenda.paint(canvas, Offset(size.width - leyenda.width - 12, size.height - leyenda.height - 10));
    final medida = TextPainter(
      text: TextSpan(text: '$centimetros cm', style: const TextStyle(color: Color(0xFF2B2F63), fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    medida.paint(canvas, Offset(margen + centimetros * paso / 2 - medida.width / 2, y - 28));
  }

  @override
  bool shouldRepaint(PintorPlanoMercado anterior) => true;
}

/// Un bote de pintura con su etiqueta de precio y la de descuento.
class PintorBoteRebajado extends CustomPainter {
  final int precio;
  final int porcentaje;
  final Color color;

  PintorBoteRebajado({required this.precio, required this.porcentaje, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final alto = size.height * 0.8;
    final bote = Rect.fromCenter(center: size.center(Offset.zero), width: alto * 0.7, height: alto);
    canvas.drawRRect(RRect.fromRectAndRadius(bote, const Radius.circular(8)),
        Paint()..color = const Color(0xFF8A8FA0));
    canvas.drawRect(Rect.fromLTWH(bote.left, bote.top + alto * 0.3, bote.width, alto * 0.4),
        Paint()..color = color);
    for (final (texto, centro, fondo) in [
      ('$precio €', Offset(bote.center.dx, bote.center.dy), Colors.white),
      ('−$porcentaje %', Offset(bote.right + 34, bote.top + 20), PaletaNeon.rosaAcento),
    ]) {
      final pintor = TextPainter(
        text: TextSpan(text: texto, style: const TextStyle(color: Color(0xFF14102A), fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout();
      final etiqueta = Rect.fromCenter(center: centro, width: pintor.width + 14, height: pintor.height + 8);
      canvas.drawRRect(RRect.fromRectAndRadius(etiqueta, const Radius.circular(6)), Paint()..color = fondo);
      pintor.paint(canvas, etiqueta.center - Offset(pintor.width / 2, pintor.height / 2));
    }
  }

  @override
  bool shouldRepaint(PintorBoteRebajado anterior) => true;
}
