import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/nivelar.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';
import 'pantalla_recreativa.dart';

/// Nivelar — segunda sala de Rexán. Las pilas de contenedores de la
/// cubierta son un gráfico de barras. Se responde eligiendo entre cuatro
/// números; al acertar, la cubierta lo demuestra: las pilas se igualan
/// (media), se ordenan (mediana) o se iluminan (moda, lectura). El barco
/// se escora con el oleaje según lo desigual que vaya la carga.
class PantallaNivelar extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaNivelar({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaNivelar> createState() => _PantallaNivelarState();
}

class _PantallaNivelarState extends State<PantallaNivelar>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_nivelar';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.nivelar);
  static const _preguntas = [
    TipoPregunta.leerPila,
    TipoPregunta.diferencia,
    TipoPregunta.media,
    TipoPregunta.media,
    TipoPregunta.mediana,
    TipoPregunta.moda,
  ];

  late final GeneradorNivelar _generador;
  late final AnimationController _demostracion = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  late RetoNivelar _reto;
  int _ronda = 1;
  int? _elegida;
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
    _generador = GeneradorNivelar(azar: math.Random(widget.semilla));
    _nuevoReto();
  }

  @override
  void dispose() {
    _demostracion.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(_preguntas[_ronda - 1], dificultad: _enNivel.dificultad);
    _elegida = null;
    _yaRegistrado = false;
    _resuelto = false;
    _lineaRexan = null;
    _inicio = DateTime.now();
    _demostracion.value = 0;
  }

  Future<void> _elegir(int opcion) async {
    if (_resuelto) return;
    HapticFeedback.selectionClick();
    final acierta = opcion == _reto.respuestaEnMedios;
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
          TipoPregunta.media => 'Eso es. Mira: moviendo contenedores, todas quedan igual.',
          TipoPregunta.mediana => 'Ordenadas, la del medio manda.',
          TipoPregunta.moda => 'La que más se repite. El barco lo agradece.',
          _ => 'Bien leído.',
        };
      } else {
        anotarFallo();
        _lineaRexan = switch (_reto.tipo) {
          TipoPregunta.leerPila => 'Cuenta otra vez los contenedores de esa pila, con el eje de al lado.',
          TipoPregunta.diferencia => 'Resta: la pila alta menos la baja.',
          TipoPregunta.media => 'Con esa altura sobran o faltan contenedores. Suma todos y reparte.',
          TipoPregunta.mediana => 'Primero ordénalas de menor a mayor; luego mira la del medio.',
          TipoPregunta.moda => 'La moda es la altura que más se repite, no la más alta.',
        };
      }
    });
    if (!acierta) {
      sonar('efecto_error');
      return;
    }
    sonar('efecto_acierto');
    await _demostracion.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1400));
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

  String _pregunta(Locale locale) {
    String letra(int i) => String.fromCharCode(65 + i);
    final (plantilla, datos) = switch (_reto.tipo) {
      TipoPregunta.leerPila => ('¿Cuántos contenedores hay en la pila {x}?', {'x': letra(_reto.senaladas.single)}),
      TipoPregunta.diferencia => (
          '¿Cuántos contenedores más tiene la pila {x} que la {y}?',
          {'x': letra(_reto.senaladas[0]), 'y': letra(_reto.senaladas[1])},
        ),
      TipoPregunta.media => ('Si igualas todas las pilas moviendo contenedores, ¿a qué altura quedan?', <String, String>{}),
      TipoPregunta.mediana => ('Ordena las pilas de menor a mayor. ¿Cuánto mide la del medio?', <String, String>{}),
      TipoPregunta.moda => ('¿Qué altura se repite más?', <String, String>{}),
    };
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = traducirNarrativa(
        _terminada
            ? 'Seis cargas repartidas. El barco sale derecho del puerto.'
            : _lineaRexan ?? _definicion.lineaRexan,
        locale);
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
          Text(_pregunta(locale),
              key: const ValueKey('pregunta-nivelar'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 16, height: 1.35)),
          const SizedBox(height: 8),
          Expanded(
            child: RelojAmbiente(
              periodo: const Duration(milliseconds: 3200),
              builder: (_, oleaje) => AnimatedBuilder(
                animation: _demostracion,
                builder: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: PintorCubierta(
                    reto: _reto,
                    oleaje: oleaje,
                    demostracion: _resuelto ? Curves.easeInOut.transform(_demostracion.value) : 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: [
              for (final opcion in _reto.opcionesEnMedios)
                GestureDetector(
                  key: ValueKey('opcion-$opcion'),
                  onTap: () => _elegir(opcion),
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
                    child: Text(enMedios(opcion),
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

/// La cubierta del barco: un eje con alturas, las pilas de contenedores
/// con su letra, y el casco que se escora con el oleaje. [demostracion]
/// (0→1) enseña la respuesta: nivelar, ordenar o iluminar.
class PintorCubierta extends CustomPainter {
  final RetoNivelar reto;
  final Animation<double>? oleaje;
  final double demostracion;

  PintorCubierta({required this.reto, this.oleaje, required this.demostracion})
      : super(repaint: oleaje);

  static const _colores = [
    Color(0xFFB45656),
    Color(0xFF3F74D8),
    Color(0xFFE3A457),
    Color(0xFF6BB38A),
    Color(0xFF8F8CD6),
    Color(0xFFD9848C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pilas = reto.pilas;
    final n = pilas.length;
    // Alturas que se dibujan (con la demostración aplicada).
    final alturas = <double>[
      for (final p in pilas)
        reto.tipo == TipoPregunta.media ? p + (reto.media - p) * demostracion : p.toDouble(),
    ];
    // Orden en pantalla: la mediana se ordena al demostrar.
    final orden = List.generate(n, (i) => i);
    if (reto.tipo == TipoPregunta.mediana && demostracion > 0.5) {
      orden.sort((a, b) => pilas[a].compareTo(pilas[b]));
    }

    // Escora: según lo desigual de lo que se ve.
    final t = oleaje?.value ?? 0;
    final escora = math.sin(t * math.pi * 2) * math.min(0.07, desequilibrio(alturas) * 0.018);

    final margenEje = 26.0;
    final baseY = size.height * 0.84;
    final altoUnidad = (baseY - 14) / 10;
    final anchoPila = (size.width - margenEje - 16) / n;

    canvas.save();
    canvas.translate(size.width / 2, baseY);
    canvas.rotate(escora);
    canvas.translate(-size.width / 2, -baseY);

    // Eje con las alturas.
    final eje = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.35)
      ..strokeWidth = 1;
    for (var h = 0; h <= 9; h++) {
      final y = baseY - h * altoUnidad;
      canvas.drawLine(Offset(margenEje - 4, y), Offset(size.width - 8, y),
          eje..color = PaletaNeon.textoTenue.withOpacity(h == 0 ? 0.5 : 0.1));
      _texto(canvas, '$h', Offset(margenEje - 14, y), 11, PaletaNeon.textoTenue);
    }

    for (var posicion = 0; posicion < n; posicion++) {
      final i = orden[posicion];
      final izquierda = margenEje + posicion * anchoPila + anchoPila * 0.14;
      final ancho = anchoPila * 0.72;
      final altura = alturas[i];
      final color = _colores[i % _colores.length];
      final entera = altura.floor();
      for (var c = 0; c < altura.ceil(); c++) {
        final fraccion = c < entera ? 1.0 : altura - entera;
        if (fraccion <= 0) continue;
        final caja = Rect.fromLTWH(izquierda, baseY - (c + fraccion) * altoUnidad + 1, ancho, fraccion * altoUnidad - 2);
        canvas.drawRect(
            caja,
            Paint()
              ..shader = LinearGradient(colors: [color, Color.lerp(color, Colors.black, 0.35)!])
                  .createShader(caja));
        // Nervios del contenedor.
        final nervio = Paint()
          ..color = Colors.black.withOpacity(0.25)
          ..strokeWidth = 1;
        for (var k = 1; k < 4; k++) {
          final x = caja.left + caja.width * k / 4;
          canvas.drawLine(Offset(x, caja.top + 2), Offset(x, caja.bottom - 2), nervio);
        }
      }
      // Resaltar lo que pregunta o lo que demuestra.
      final resaltada = reto.senaladas.contains(i) ||
          (demostracion > 0.5 &&
              ((reto.tipo == TipoPregunta.moda && pilas[i] * 2 == reto.respuestaEnMedios) ||
                  (reto.tipo == TipoPregunta.mediana &&
                      (posicion == n ~/ 2 || (n.isEven && posicion == n ~/ 2 - 1)))));
      if (resaltada) {
        canvas.drawRect(
            Rect.fromLTWH(izquierda - 3, baseY - altura * altoUnidad - 3, ancho + 6, altura * altoUnidad + 3),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = PaletaNeon.ambarCanales);
      }
      _texto(canvas, String.fromCharCode(65 + i), Offset(izquierda + ancho / 2, baseY + 12), 13,
          PaletaNeon.textoPrincipal);
    }

    // El casco.
    final casco = Path()
      ..moveTo(4, baseY + 22)
      ..lineTo(size.width - 4, baseY + 22)
      ..lineTo(size.width - 24, size.height)
      ..lineTo(24, size.height)
      ..close();
    canvas.drawPath(
        casco,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B3A2A), Color(0xFF2E1810)],
          ).createShader(Rect.fromLTWH(0, baseY + 22, size.width, size.height - baseY)));
    canvas.restore();

    // Agua por encima de todo, abajo: no se escora.
    final agua = Rect.fromLTWH(0, size.height - 10, size.width, 10);
    canvas.drawRect(agua, Paint()..color = const Color(0xFF123A6E).withOpacity(0.9));
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tamano, Color color) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: color, fontSize: tamano)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorCubierta anterior) => true;
}
