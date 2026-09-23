import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/puentes.dart';
import '../../dominio/problema_espejo.dart' show Fraccion;
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Puentes — máquina de Rexán. El niño cubre un hueco con tablones y
/// prueba el puente: el carro sólo cruza si la suma es exacta. Si
/// falta, se para en el borde; si sobra, el último tablón no encaja.
///
/// En dificultad 1-2 los tablones se dibujan a escala (apoyo visual);
/// en 3 todos miden lo mismo en pantalla y sólo cuenta la etiqueta.
class PantallaPuentes extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;

  /// Habilidades practicadas de la máquina: deciden los modos (fracción
  /// con igual o distinto denominador, decimales).
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaPuentes({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaPuentes> createState() => _PantallaPuentesState();
}

class _PantallaPuentesState extends State<PantallaPuentes>
    with SingleTickerProviderStateMixin, MusicaDeMaquina {
  @override
  String get idMusica => 'musica_maquina_puentes';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.puentes);

  late final GeneradorPuentes _generador;
  late final AnimationController _controladorCarro;
  late final List<ModoPuente> _modos;

  int _ronda = 1;
  late RetoPuente _reto;
  final List<int> _colocados = []; // índices en _reto.tablones
  DateTime _inicioReto = DateTime.now();
  bool _yaRegistrado = false;
  ResultadoPuente? _ultimoResultado;
  bool _probando = false;
  bool _terminada = false;

  @override
  void initState() {
    super.initState();
    _generador = GeneradorPuentes(semilla: widget.semilla);
    _modos = [
      for (final id in widget.habilidadesPracticadas)
        if (ModoPuenteHabilidad.paraHabilidad(id) != null)
          ModoPuenteHabilidad.paraHabilidad(id)!,
    ];
    if (_modos.isEmpty) _modos.add(ModoPuente.mismoDenominador);
    _controladorCarro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _nuevoReto();
  }

  @override
  void dispose() {
    _controladorCarro.dispose();
    super.dispose();
  }

  void _nuevoReto() {
    _reto = _generador.generar(
      _modos[(_ronda - 1) % _modos.length],
      dificultad: widget.dificultad,
    );
    _colocados.clear();
    _inicioReto = DateTime.now();
    _yaRegistrado = false;
    _ultimoResultado = null;
    _controladorCarro.value = 0;
  }

  List<Fraccion> get _tablonesColocados =>
      [for (final indice in _colocados) _reto.tablones[indice]];

  void _colocar(int indice) {
    if (_probando) return;
    HapticFeedback.selectionClick();
    sonar('efecto_tablon');
    setState(() {
      _colocados.add(indice);
      _ultimoResultado = null;
      _controladorCarro.value = 0;
    });
  }

  void _quitar(int posicion) {
    if (_probando) return;
    HapticFeedback.selectionClick();
    setState(() {
      _colocados.removeAt(posicion);
      _ultimoResultado = null;
      _controladorCarro.value = 0;
    });
  }

  Future<void> _probar() async {
    if (_probando || _colocados.isEmpty) return;
    final resultado = probarPuente(_reto.hueco, _tablonesColocados);
    setState(() {
      _probando = true;
      _ultimoResultado = null;
    });
    if (!_yaRegistrado) {
      _yaRegistrado = true;
      // Sólo el primer intento de cada puente cuenta para la maestría:
      // es el que dice si el niño lo calculó.
      widget.registro?.registrar(
        idHabilidad: _reto.modo.idHabilidad,
        acierto: resultado == ResultadoPuente.exacto,
        dificultad: 0.8 + 0.3 * widget.dificultad,
        duracion: DateTime.now().difference(_inicioReto),
      );
    }
    await _controladorCarro.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _probando = false;
      _ultimoResultado = resultado;
    });
    if (resultado == ResultadoPuente.exacto) {
      HapticFeedback.heavyImpact();
      sonar('efecto_acierto');
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
    } else {
      HapticFeedback.vibrate();
      sonar('efecto_error');
    }
  }

  String _lineaResultado(Locale locale) {
    final linea = switch (_ultimoResultado) {
      ResultadoPuente.exacto => 'Justo. El carro pasa.',
      ResultadoPuente.corto => 'Falta un trozo: el carro se para en el borde.',
      ResultadoPuente.largo => 'Sobra: el último tablón no encaja.',
      _ => _ronda == 1
          ? _definicion.lineaRexan
          : 'Otro hueco. Mismas reglas.',
    };
    return traducirNarrativa(linea, locale);
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: _terminada
          ? traducirNarrativa(
              'Cinco puentes. Por hoy el Puerto está servido. Vuelve mañana si te apetece.',
              locale)
          : _lineaResultado(locale),
      terminada: _terminada,
      child: _terminada
          ? const SizedBox.shrink()
          : Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controladorCarro,
                    builder: (_, __) => CustomPaint(
                      size: Size.infinite,
                      painter: PintorPuente(
                        hueco: _reto.hueco,
                        etiquetaHueco: _reto.etiqueta(_reto.hueco),
                        colocados: _tablonesColocados,
                        etiquetas: [
                          for (final tablon in _tablonesColocados)
                            _reto.etiqueta(tablon)
                        ],
                        avanceCarro: _controladorCarro.value,
                        resultado: probarPuente(_reto.hueco, _tablonesColocados),
                        aEscala: widget.dificultad < 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _FilaTablones(
                  titulo: traducirNarrativa('En el puente', locale),
                  vacio: traducirNarrativa(
                      'Toca un tablón de abajo para ponerlo.', locale),
                  tablones: _tablonesColocados,
                  etiqueta: _reto.etiqueta,
                  escalaMaxima: _escalaMaxima,
                  aEscala: widget.dificultad < 3,
                  alTocar: _quitar,
                ),
                const SizedBox(height: 14),
                _FilaTablones(
                  titulo: traducirNarrativa('Tablones', locale),
                  vacio: '',
                  tablones: [
                    for (var i = 0; i < _reto.tablones.length; i++)
                      if (!_colocados.contains(i)) _reto.tablones[i],
                  ],
                  etiqueta: _reto.etiqueta,
                  escalaMaxima: _escalaMaxima,
                  aEscala: widget.dificultad < 3,
                  alTocar: (posicion) {
                    final libres = [
                      for (var i = 0; i < _reto.tablones.length; i++)
                        if (!_colocados.contains(i)) i,
                    ];
                    _colocar(libres[posicion]);
                  },
                ),
                const SizedBox(height: 20),
                BotonMinijuego(
                  texto: traducirNarrativa('PROBAR EL PUENTE', locale),
                  alPulsar: _colocados.isEmpty || _probando ? null : _probar,
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  /// Medida más larga del reto: fija la escala común de los tablones.
  double get _escalaMaxima => [
        _reto.hueco.valor,
        for (final tablon in _reto.tablones) tablon.valor,
      ].reduce(math.max);
}

class _FilaTablones extends StatelessWidget {
  final String titulo;
  final String vacio;
  final List<Fraccion> tablones;
  final String Function(Fraccion) etiqueta;
  final double escalaMaxima;
  final bool aEscala;
  final void Function(int posicion) alTocar;

  const _FilaTablones({
    required this.titulo,
    required this.vacio,
    required this.tablones,
    required this.etiqueta,
    required this.escalaMaxima,
    required this.aEscala,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext contexto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo.toUpperCase(),
          style: TextStyle(
            color: PaletaNeon.textoTenue.withOpacity(0.8),
            fontSize: 10,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 6),
        if (tablones.isEmpty && vacio.isNotEmpty)
          Text(
            vacio,
            style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.6),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        LayoutBuilder(
          builder: (_, restricciones) {
            final anchoMaximo = restricciones.maxWidth * 0.62;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < tablones.length; i++)
                  GestureDetector(
                    key: ValueKey('tablon-$titulo-$i'),
                    onTap: () => alTocar(i),
                    child: Container(
                      width: aEscala
                          ? math.max(44, anchoMaximo * tablones[i].valor / escalaMaxima)
                          : 64,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: PaletaNeon.ambarCanales.withOpacity(0.22),
                        border: Border.all(
                            color: PaletaNeon.ambarCanales.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        etiqueta(tablones[i]),
                        style: const TextStyle(
                          color: PaletaNeon.textoPrincipal,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Dos orillas, el hueco con su medida, los tablones colocados a escala
/// y el carro. El carro avanza hasta donde llega el puente: cruza si es
/// exacto, se para al final del tablero si es corto y no sale si sobra.
class PintorPuente extends CustomPainter {
  final Fraccion hueco;
  final String etiquetaHueco;
  final List<Fraccion> colocados;
  final List<String> etiquetas;
  final double avanceCarro;
  final ResultadoPuente resultado;
  final bool aEscala;

  PintorPuente({
    required this.hueco,
    required this.etiquetaHueco,
    required this.colocados,
    required this.etiquetas,
    required this.avanceCarro,
    required this.resultado,
    required this.aEscala,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final alturaTablero = size.height * 0.55;
    final anchoHueco = size.width * 0.56;
    final bordeIzquierdo = (size.width - anchoHueco) / 2;
    final bordeDerecho = bordeIzquierdo + anchoHueco;
    final pixelesPorUnidad = anchoHueco / hueco.valor;

    // Orillas.
    final pinturaOrilla = Paint()..color = PaletaNeon.fondoMedio;
    canvas.drawRect(
        Rect.fromLTRB(0, alturaTablero, bordeIzquierdo, size.height),
        pinturaOrilla);
    canvas.drawRect(
        Rect.fromLTRB(bordeDerecho, alturaTablero, size.width, size.height),
        pinturaOrilla);
    final pinturaCanto = Paint()
      ..color = PaletaNeon.violetaBase
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, alturaTablero),
        Offset(bordeIzquierdo, alturaTablero), pinturaCanto);
    canvas.drawLine(Offset(bordeDerecho, alturaTablero),
        Offset(size.width, alturaTablero), pinturaCanto);

    // Agua.
    canvas.drawRect(
      Rect.fromLTRB(bordeIzquierdo, size.height * 0.88, bordeDerecho, size.height),
      Paint()..color = PaletaNeon.azulNeon.withOpacity(0.18),
    );

    // Cota del hueco.
    final pinturaCota = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.7)
      ..strokeWidth = 1;
    final alturaCota = alturaTablero - 46;
    canvas.drawLine(Offset(bordeIzquierdo, alturaCota),
        Offset(bordeDerecho, alturaCota), pinturaCota);
    for (final x in [bordeIzquierdo, bordeDerecho]) {
      canvas.drawLine(
          Offset(x, alturaCota - 5), Offset(x, alturaCota + 5), pinturaCota);
    }
    _texto(canvas, etiquetaHueco, Offset(size.width / 2, alturaCota - 16),
        tamano: 18, color: PaletaNeon.textoPrincipal);

    // Tablones colocados, de izquierda a derecha. En dificultad 3 la
    // escala real sólo se revela al probar: antes, todos iguales, para
    // que el niño calcule en vez de ajustar a ojo.
    final revelarEscala = aEscala || avanceCarro > 0;
    var x = bordeIzquierdo;
    for (var i = 0; i < colocados.length; i++) {
      final ancho = revelarEscala
          ? colocados[i].valor * pixelesPorUnidad
          : 44.0;
      final sobresale = revelarEscala && x + ancho > bordeDerecho + 0.5;
      final rect = Rect.fromLTWH(x, alturaTablero - 10, ancho, 10);
      canvas.drawRect(
        rect,
        Paint()
          ..color = sobresale
              ? PaletaNeon.rosaAcento.withOpacity(0.7)
              : PaletaNeon.ambarCanales.withOpacity(0.85),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = PaletaNeon.fondoProfundo
          ..strokeWidth = 1.5,
      );
      if (ancho > 26) {
        _texto(canvas, etiquetas[i], Offset(rect.center.dx, alturaTablero + 14),
            tamano: 11, color: PaletaNeon.textoTenue);
      }
      x += ancho;
    }
    final finTablero = x;

    // Carro: sale de la orilla izquierda y llega hasta donde da el puente.
    final salida = bordeIzquierdo * 0.4;
    final llegada = switch (resultado) {
      ResultadoPuente.exacto => size.width - bordeIzquierdo * 0.4,
      ResultadoPuente.corto => finTablero - 14,
      ResultadoPuente.largo || ResultadoPuente.vacio => bordeIzquierdo - 14,
    };
    final xCarro = salida + (llegada - salida) * Curves.easeInOut.transform(avanceCarro);
    final carroBase = alturaTablero - 10;
    final rectCarro = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(xCarro, carroBase - 12), width: 28, height: 16),
      const Radius.circular(3),
    );
    canvas.drawRRect(rectCarro, Paint()..color = PaletaNeon.violetaNeon);
    for (final dx in [-8.0, 8.0]) {
      canvas.drawCircle(Offset(xCarro + dx, carroBase - 3), 3.5,
          Paint()..color = PaletaNeon.textoPrincipal);
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro,
      {required double tamano, required Color color}) {
    final pintor = TextPainter(
      text: TextSpan(
          text: texto,
          style: TextStyle(color: color, fontSize: tamano, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorPuente anterior) => true;
}
