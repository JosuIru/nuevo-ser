import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/canales.dart' show Celda;
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/flota.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// La flota — máquina de Rexán. Rexán canta columna y fila en cálculo;
/// el niño toca la casilla. Si se equivoca, se le enseña cuál era y el
/// disparo se hace igual. Cada flota hundida registra maestría por
/// habilidad (acierto con como mucho un fallo).
class PantallaFlota extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaFlota({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaFlota> createState() => _PantallaFlotaState();
}

class _PantallaFlotaState extends State<PantallaFlota> with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_flota';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.flota);

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);

  /// Dificultad de las cuentas en esta ronda (sube con el nivel).
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  late final math.Random _azar;
  late final List<String> _habilidades;
  late PartidaFlota _partida;
  int _ronda = 1;
  Celda? _correccion;
  bool _esperando = false;
  bool _terminada = false;
  String? _lineaRexan;
  String _datoLinea = '';
  DateTime _inicio = DateTime.now();

  @override
  void initState() {
    super.initState();
    _azar = math.Random(widget.semilla);
    _habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (id == 'PROP.04' || id == 'FR.22') id,
    ];
    if (_habilidades.isEmpty) _habilidades.add('FR.22');
    _nuevaPartida();
  }

  void _nuevaPartida() {
    _partida = PartidaFlota(
        habilidades: _habilidades, dificultad: _enNivel.dificultad, azar: _azar);
    _inicio = DateTime.now();
    _correccion = null;
    _lineaRexan = null;
  }

  void _tocar(Celda celda) {
    if (_esperando || _terminada) return;
    final objetivo = _partida.objetivo;
    final (acierta, resultado) = _partida.tocar(celda);
    setState(() {
      _esperando = true;
      if (acierta) {
        HapticFeedback.selectionClick();
        _correccion = null;
        anotarAcierto();
        _lineaRexan = switch (resultado) {
          ResultadoDisparo.agua => 'Agua.',
          ResultadoDisparo.tocado => '¡Tocado!',
          ResultadoDisparo.hundido => 'Hundido.',
        };
      } else {
        HapticFeedback.vibrate();
        sonar('efecto_error');
        anotarFallo();
        _correccion = objetivo;
        _datoLinea = 'columna ${objetivo.columna + 1}, fila ${objetivo.fila + 1}';
        _lineaRexan = 'Era la casilla {dato}. Disparo ahí.';
      }
      if (resultado != ResultadoDisparo.agua) sonar('efecto_tablon');
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _esperando = false;
        _correccion = null;
        if (_partida.flotaHundida) {
          _terminarPartida();
        } else {
          _partida.nuevoObjetivo();
        }
      });
    });
  }

  void _terminarPartida() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicio);
    _partida.aciertoPorHabilidad.forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: duracion,
      );
    });
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      return;
    }
    _ronda++;
    _nuevaPartida();
    _lineaRexan = 'Flota hundida. La siguiente, mar adentro: cuentas más difíciles.';
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Dos flotas al fondo. El Puerto vuelve a estar en calma.'
        : _lineaRexan ?? _definicion.lineaRexan;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.columna.idHabilidad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan:
          traducirNarrativa(linea, locale).replaceAll('{dato}', _datoLinea),
      terminada: _terminada,
      child: Column(
        children: [
          _Coordenadas(
            columna: _partida.columna.expresion,
            fila: _partida.fila.expresion,
            textoColumna: traducirNarrativa('Columna', locale),
            textoFila: traducirNarrativa('Fila', locale),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (_, restricciones) {
                    final lienzo = restricciones.biggest;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (detalles) {
                        final celda = PintorFlota.celdaEn(
                            detalles.localPosition, lienzo);
                        if (celda != null) _tocar(celda);
                      },
                      child: CustomPaint(
                        size: lienzo,
                        painter: PintorFlota(
                            partida: _partida, correccion: _correccion),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Coordenadas extends StatelessWidget {
  final String columna;
  final String fila;
  final String textoColumna;
  final String textoFila;

  const _Coordenadas({
    required this.columna,
    required this.fila,
    required this.textoColumna,
    required this.textoFila,
  });

  Widget _dato(String etiqueta, String valor) => Expanded(
        child: Column(
          children: [
            Text(etiqueta.toUpperCase(),
                style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 2.5)),
            const SizedBox(height: 2),
            Text(valor,
                style: const TextStyle(
                    color: PaletaNeon.ambarCanales, fontSize: 20)),
          ],
        ),
      );

  @override
  Widget build(BuildContext contexto) =>
      Row(children: [_dato(textoColumna, columna), _dato(textoFila, fila)]);
}

/// Tablero 8×8 con números en los bordes (columnas arriba, filas a la
/// izquierda), los disparos hechos y, si hace falta, la casilla correcta.
class PintorFlota extends CustomPainter {
  final PartidaFlota partida;
  final Celda? correccion;

  PintorFlota({required this.partida, required this.correccion});

  static const _margen = 0.1; // fracción para los números de los bordes

  static Celda? celdaEn(Offset posicion, Size lienzo) {
    final inicio = lienzo.width * _margen;
    final lado = (lienzo.width - inicio) / PartidaFlota.lado;
    final columna = ((posicion.dx - inicio) / lado).floor();
    final fila = ((posicion.dy - inicio) / lado).floor();
    if (columna < 0 || fila < 0 || columna >= PartidaFlota.lado || fila >= PartidaFlota.lado) {
      return null;
    }
    return Celda(fila, columna);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final inicio = size.width * _margen;
    final lado = (size.width - inicio) / PartidaFlota.lado;
    Rect rectDe(Celda celda) => Rect.fromLTWH(
        inicio + celda.columna * lado, inicio + celda.fila * lado, lado, lado);

    for (var i = 0; i < PartidaFlota.lado; i++) {
      _texto(canvas, '${i + 1}', Offset(inicio + (i + 0.5) * lado, inicio / 2));
      _texto(canvas, '${i + 1}', Offset(inicio / 2, inicio + (i + 0.5) * lado));
    }
    final agua = Paint()..color = PaletaNeon.azulNeon.withOpacity(0.08);
    final linea = Paint()
      ..style = PaintingStyle.stroke
      ..color = PaletaNeon.violetaBase.withOpacity(0.5);
    for (var f = 0; f < PartidaFlota.lado; f++) {
      for (var c = 0; c < PartidaFlota.lado; c++) {
        final rect = rectDe(Celda(f, c)).deflate(1);
        canvas.drawRect(rect, agua);
        canvas.drawRect(rect, linea);
      }
    }
    partida.disparos.forEach((celda, resultado) {
      final rect = rectDe(celda).deflate(lado * 0.18);
      switch (resultado) {
        case ResultadoDisparo.agua:
          canvas.drawCircle(rect.center, lado * 0.12,
              Paint()..color = PaletaNeon.azulNeon.withOpacity(0.6));
        case ResultadoDisparo.tocado:
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)),
              Paint()..color = PaletaNeon.ambarCanales);
        case ResultadoDisparo.hundido:
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)),
              Paint()..color = PaletaNeon.rojoOxidado);
      }
    });
    final celdaCorrecta = correccion;
    if (celdaCorrecta != null) {
      canvas.drawRect(
        rectDe(celdaCorrecta).deflate(2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = PaletaNeon.exitoSuave,
      );
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro) {
    final pintor = TextPainter(
      text: TextSpan(
          text: texto,
          style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorFlota anterior) => true;
}
