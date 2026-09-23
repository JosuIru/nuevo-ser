import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/esclusas.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';
import 'pantalla_recreativa.dart';

/// Esclusas — segunda sala de Rexán. Las barquitas bajan por el canal y
/// hay que decidir antes de que lleguen a la compuerta: abrir la esclusa
/// de su rango, tocar la mayor de una pareja o las de un trío en orden.
/// Si una llega abajo sin decidir, Rexán la sube otra vez (no cuenta).
class PantallaEsclusas extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final int? semilla;

  const PantallaEsclusas({
    super.key,
    required this.registro,
    required this.dificultad,
    this.semilla,
  });

  @override
  State<PantallaEsclusas> createState() => _PantallaEsclusasState();
}

class _PantallaEsclusasState extends State<PantallaEsclusas>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_esclusas';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.esclusas);

  late final math.Random _azar;
  late final Ticker _ticker;
  late PartidaEsclusas _partida;
  Duration _ultimo = Duration.zero;
  int _ronda = 1;
  bool _terminada = false;
  bool _pausado = false;
  bool _entreRondas = false;
  String? _lineaRexan;
  Map<String, String> _datosLinea = const {};
  DateTime _inicioRonda = DateTime.now();

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  @override
  void initState() {
    super.initState();
    _azar = math.Random(widget.semilla);
    _nuevaRonda();
    _ticker = createTicker(_alPasarTiempo)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _nuevaRonda() {
    _partida = PartidaEsclusas(nivel: _nivel, dificultad: _enNivel.dificultad, azar: _azar);
    _inicioRonda = DateTime.now();
    _entreRondas = false;
  }

  void _alPasarTiempo(Duration transcurrido) {
    final dt = ((transcurrido - _ultimo).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _ultimo = transcurrido;
    if (_terminada || _pausado || _entreRondas) return;
    final evento = _partida.avanzar(dt);
    if (evento == EventoEsclusas.devuelta) {
      _lineaRexan = 'Se te ha escapado. Te la subo otra vez.';
      _datosLinea = const {};
    }
    setState(() {});
  }

  void _tratar(EventoEsclusas evento) {
    switch (evento) {
      case EventoEsclusas.acierto:
        HapticFeedback.selectionClick();
        sonar('efecto_tap');
        anotarAcierto();
        _lineaRexan = null;
      case EventoEsclusas.fallo:
        HapticFeedback.vibrate();
        sonar('efecto_error');
        anotarFallo();
        _explicarFallo();
      case EventoEsclusas.rondaTerminada:
        anotarAcierto();
        _cerrarRonda();
      case EventoEsclusas.nada || EventoEsclusas.devuelta:
        break;
    }
  }

  void _explicarFallo() {
    final barca = _partida.ultimaEquivocada?.etiqueta ?? '';
    _datosLinea = {'b': barca};
    _lineaRexan = switch (_partida.carga.tipo) {
      TipoCarga.suelta => 'Esa esclusa no es la suya: {b} no está en ese tramo.',
      TipoCarga.pareja => '{b} no es la mayor de las dos.',
      TipoCarga.trio => 'Esa no tocaba: {b} no es la más pequeña de las que quedan. Empieza otra vez.',
    };
  }

  void _cerrarRonda() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicioRonda);
    _partida.resultadoRonda().forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * _enNivel.dificultad,
        duracion: duracion,
      );
    });
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      _ticker.stop();
      return;
    }
    _entreRondas = true;
    _lineaRexan = _ronda == 1
        ? 'Ahora vienen atadas de dos en dos. Toca la que vale más.'
        : 'Ahora de tres en tres. De la más pequeña a la más grande.';
    _datosLinea = const {};
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _ronda++;
        _nuevaRonda();
      });
    });
  }

  void _abrir(int indice) {
    if (_entreRondas || _terminada) return;
    setState(() => _tratar(_partida.abrir(indice)));
  }

  void _tocar(int indice) {
    if (_entreRondas || _terminada || _partida.yaPasada(indice)) return;
    setState(() => _tratar(_partida.tocar(indice)));
  }

  String _texto(String plantilla, Locale locale, [Map<String, String> datos = const {}]) {
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final carga = _partida.carga;
    final linea = _terminada
        ? _texto('Tres tandas por las esclusas. El canal queda en calma.', locale)
        : _texto(_lineaRexan ?? _definicion.lineaRexan, locale, _datosLinea);
    final instruccion = switch (carga.tipo) {
      TipoCarga.suelta => 'Abre la esclusa de su tramo antes de que llegue abajo.',
      TipoCarga.pareja => 'Toca la que vale más.',
      TipoCarga.trio => 'Tócalas de la más pequeña a la más grande.',
    };
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: carga.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: linea,
      terminada: _terminada,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _texto(instruccion, locale),
                  style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 15),
                ),
              ),
              Text('${_partida.cargasHechas} / ${PartidaEsclusas.cargasPorRonda}',
                  style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, restricciones) {
                final alto = restricciones.maxHeight;
                final ancho = restricciones.maxWidth;
                const altoBarca = 74.0;
                final y = (alto - altoBarca - 16) * _partida.posicion;
                final numero = carga.barcas.length;
                final anchoBarca = math.min(116.0, (ancho - 24) / numero - 10);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: RelojAmbiente(
                        periodo: const Duration(seconds: 2),
                        builder: (_, fase) => CustomPaint(
                          painter: PintorCanalEsclusas(fase: fase, peligro: _partida.posicion),
                        ),
                      ),
                    ),
                    // La cuerda de los Comparadores (parejas y tríos).
                    if (numero > 1)
                      Positioned(
                        left: (ancho - numero * (anchoBarca + 10)) / 2 + anchoBarca / 2,
                        right: (ancho - numero * (anchoBarca + 10)) / 2 + anchoBarca / 2 + 10,
                        top: y + altoBarca * 0.62,
                        child: Container(height: 2, color: const Color(0xFFD9B77A)),
                      ),
                    for (var i = 0; i < numero; i++)
                      Positioned(
                        left: (ancho - numero * (anchoBarca + 10)) / 2 + i * (anchoBarca + 10),
                        top: y,
                        width: anchoBarca,
                        height: altoBarca,
                        child: AnimatedOpacity(
                          opacity: _partida.yaPasada(i) ? 0.25 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            key: ValueKey('barca-$i'),
                            onTap: carga.tipo == TipoCarga.suelta ? null : () => _tocar(i),
                            child: CustomPaint(
                              painter: PintorBarquita(etiqueta: carga.barcas[i].etiqueta),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (carga.tipo == TipoCarga.suelta)
            Row(
              children: [
                for (final (indice, texto) in [
                  (0, _texto('menos de {u}', locale, {'u': '${_partida.esclusas.numerador}/${_partida.esclusas.denominador}'})),
                  (1, _texto('entre {u} y 1', locale, {'u': '${_partida.esclusas.numerador}/${_partida.esclusas.denominador}'})),
                  (2, _texto('más de 1', locale)),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Compuerta(
                        key: ValueKey('esclusa-$indice'),
                        texto: texto,
                        alPulsar: () => _abrir(indice),
                      ),
                    ),
                  ),
              ],
            )
          else
            const SizedBox(height: 58),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Compuerta extends StatelessWidget {
  final String texto;
  final VoidCallback alPulsar;

  const _Compuerta({super.key, required this.texto, required this.alPulsar});

  @override
  Widget build(BuildContext contexto) => GestureDetector(
        onTap: alPulsar,
        child: Container(
          height: 58,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A4370), Color(0xFF221A40)],
            ),
            border: Border.all(color: PaletaNeon.azulNeon.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 15)),
          ),
        ),
      );
}

/// El canal visto desde arriba: agua que baja, orillas de piedra y la
/// compuerta al fondo, que se enciende en rosa cuando la barca se acerca.
class PintorCanalEsclusas extends CustomPainter {
  final Animation<double>? fase;
  final double peligro;

  PintorCanalEsclusas({this.fase, required this.peligro}) : super(repaint: fase);

  @override
  void paint(Canvas canvas, Size size) {
    final t = fase?.value ?? 0;
    final agua = Rect.fromLTWH(10, 0, size.width - 20, size.height);
    canvas.drawRect(
      agua,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B2146), Color(0xFF0A1433)],
        ).createShader(agua),
    );
    // Corriente: rayas cortas que bajan.
    final raya = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
    for (var i = 0; i < 26; i++) {
      final azar = math.Random(i * 13 + 1);
      final x = agua.left + azar.nextDouble() * agua.width;
      final y = ((azar.nextDouble() + t) % 1) * size.height;
      raya.color = PaletaNeon.azulNeon.withOpacity(0.12 + 0.12 * azar.nextDouble());
      canvas.drawLine(Offset(x, y), Offset(x, y + 10 + azar.nextDouble() * 10), raya);
    }
    // Orillas.
    final piedra = Paint()..color = const Color(0xFF2A1D52);
    canvas.drawRect(Rect.fromLTWH(0, 0, 10, size.height), piedra);
    canvas.drawRect(Rect.fromLTWH(size.width - 10, 0, 10, size.height), piedra);
    // La compuerta del fondo.
    final alerta = ((peligro - 0.65) / 0.35).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 8, size.width, 8),
      Paint()..color = Color.lerp(const Color(0xFF6F6893), PaletaNeon.rosaAcento, alerta)!,
    );
  }

  @override
  bool shouldRepaint(PintorCanalEsclusas anterior) => anterior.peligro != peligro;
}

/// Una barquita de papel vista de lado, con su número en el casco.
class PintorBarquita extends CustomPainter {
  final String etiqueta;

  PintorBarquita({required this.etiqueta});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Vela triangular (el pliegue del papel).
    final vela = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.78, h * 0.5)
      ..lineTo(w * 0.22, h * 0.5)
      ..close();
    canvas.drawPath(vela, Paint()..color = const Color(0xFFD8D2EE));
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h * 0.5),
        Paint()
          ..color = const Color(0xFF9A93C0)
          ..strokeWidth = 1);
    // Casco.
    final casco = Path()
      ..moveTo(0, h * 0.48)
      ..lineTo(w, h * 0.48)
      ..lineTo(w * 0.84, h * 0.96)
      ..lineTo(w * 0.16, h * 0.96)
      ..close();
    canvas.drawPath(
        casco,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2EEFF), Color(0xFFB9B2DE)],
          ).createShader(Rect.fromLTWH(0, h * 0.48, w, h * 0.5)));
    final pintor = TextPainter(
      text: TextSpan(
        text: etiqueta,
        style: TextStyle(
          color: PaletaNeon.fondoProfundo,
          fontSize: etiqueta.length > 4 ? 16 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    pintor.paint(canvas, Offset((w - pintor.width) / 2, h * 0.72 - pintor.height / 2));
  }

  @override
  bool shouldRepaint(PintorBarquita anterior) => anterior.etiqueta != etiqueta;
}
