import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/retos_calculo.dart';
import '../../dominio/minijuegos/salto.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Salto — máquina de Rexán al estilo Geometry Dash. Tocar = saltar.
/// La cuenta y lo que hay en cada puerta se ven desde que se cruza la
/// anterior: da tiempo a pensar aunque el juego vaya rápido. Chocar
/// devuelve a la última marca, sin "game over" ni contador de intentos.
class PantallaSalto extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaSalto({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaSalto> createState() => _PantallaSaltoState();
}

class _PantallaSaltoState extends State<PantallaSalto>
    with SingleTickerProviderStateMixin, MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_salto';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.salto);
  static const _puertasPorRonda = 5;

  late final PartidaSalto _partida;
  late final Ticker _ticker;
  Duration _ultimo = Duration.zero;
  bool _empezado = false;
  bool _terminada = false;
  bool _pausado = false;
  double _destello = 0; // 1 → 0 tras un choque
  int _ronda = 1;
  String? _lineaRexan;
  DateTime _inicioRonda = DateTime.now();

  @override
  void initState() {
    super.initState();
    final habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (habilidadesConRetoCalculo.contains(id)) id,
    ];
    _partida = PartidaSalto(
      habilidades: habilidades.isEmpty ? ['ARI.01'] : habilidades,
      dificultad: widget.dificultad,
      azar: math.Random(widget.semilla),
    );
    _ticker = createTicker(_alPasarTiempo);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _alPasarTiempo(Duration transcurrido) {
    // Paso de física por tiempo real, acotado (una pausa del sistema no
    // teletransporta al Fragmento).
    final dt = ((transcurrido - _ultimo).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _ultimo = transcurrido;
    if (_terminada || _pausado) return;
    final evento = _partida.avanzar(dt);
    switch (evento) {
      case EventoSalto.choquePincho:
      case EventoSalto.choquePuerta:
        HapticFeedback.mediumImpact();
        sonar(evento == EventoSalto.choquePuerta ? 'efecto_error' : 'efecto_tablon');
        if (evento == EventoSalto.choquePuerta) anotarFallo();
        _lineaRexan = evento == EventoSalto.choquePuerta
            ? 'Esa puerta no era. Desde la marca.'
            : 'Otra vez desde la marca.';
        _destello = 1;
        _partida.reaparecer();
      case EventoSalto.pasaPuerta:
        HapticFeedback.selectionClick();
        sonar('efecto_tap');
        anotarAcierto();
        _lineaRexan = null;
        if (_partida.puertasPasadas % _puertasPorRonda == 0) _cerrarRonda();
      case EventoSalto.nada:
        break;
    }
    _destello = math.max(0, _destello - dt * 2.5);
    setState(() {});
  }

  void _cerrarRonda() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicioRonda);
    _partida.cerrarRonda().forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * widget.dificultad,
        duracion: duracion,
      );
    });
    _inicioRonda = DateTime.now();
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      _ticker.stop();
      return;
    }
    _ronda++;
    _partida.cambiarNivel(_ronda);
    _lineaRexan = _ronda == 2
        ? 'Cinco puertas. Ahora vienen cajas y fosos: salta o súbete encima.'
        : 'Cinco más. Trampolines, más pinchos y cuentas que siguen a la anterior.';
  }

  void _tocar() {
    if (_terminada) return;
    if (!_empezado) {
      _empezado = true;
      _ultimo = Duration.zero;
      _ticker.start();
      return;
    }
    _partida.saltar();
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final puerta = _partida.puertaSiguiente;
    final linea = _terminada
        ? 'Quince puertas. El Fragmento se para a mirar la ciudad.'
        : _lineaRexan ??
            (_empezado ? _definicion.lineaRexan : 'Toca para empezar. Toca para saltar.');
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _partida.puertaSiguiente.reto.idHabilidad,
      dificultadEjemplo: widget.dificultad,
      enunciadoActual: _partida.puertaSiguiente.reto.enunciado,
      alPausar: () => _pausado = true,
      alReanudar: () => _pausado = false,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: traducirNarrativa(linea, locale),
      terminada: _terminada,
      child: Column(
        children: [
          _Cuenta(
            enunciado: puerta.reto.enunciado
                .replaceAll('{antes}', traducirNarrativa('la de antes', locale)),
            encadenada: puerta.encadenada,
            arriba: puerta.valorArriba,
            abajo: puerta.valorAbajo,
            puertasEnRonda: _partida.puertasPasadas % _puertasPorRonda,
            puertasPorRonda: _puertasPorRonda,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              key: const ValueKey('pista-salto'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _tocar(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: PintorSalto(partida: _partida, destello: _destello),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Cuenta extends StatelessWidget {
  final String enunciado;
  final bool encadenada;
  final int arriba;
  final int abajo;
  final int puertasEnRonda;
  final int puertasPorRonda;

  const _Cuenta({
    required this.enunciado,
    required this.encadenada,
    required this.arriba,
    required this.abajo,
    required this.puertasEnRonda,
    required this.puertasPorRonda,
  });

  Widget _hoja(IconData icono, int valor) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: PaletaNeon.textoTenue),
          const SizedBox(width: 4),
          Text('$valor',
              style: const TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 20)),
        ],
      );

  @override
  Widget build(BuildContext contexto) => Row(
        children: [
          if (encadenada)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.link, size: 20, color: PaletaNeon.ambarCanales),
            ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$enunciado = ?',
                style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 22),
              ),
            ),
          ),
          _hoja(Icons.arrow_upward, arriba),
          const SizedBox(width: 14),
          _hoja(Icons.arrow_downward, abajo),
          const SizedBox(width: 12),
          Text('$puertasEnRonda / $puertasPorRonda',
              style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12)),
        ],
      );
}

/// Vista lateral: suelo de neón, pinchos, plataformas, puertas dobles y
/// el cubo del Fragmento girando en el aire.
class PintorSalto extends CustomPainter {
  final PartidaSalto partida;
  final double destello;

  PintorSalto({required this.partida, required this.destello});

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / 9; // 9 unidades de mundo a lo ancho
    final suelo = size.height * 0.8;
    final camaraX = partida.x - 1.6;
    Offset punto(double x, double y) =>
        Offset((x - camaraX) * escala, suelo - y * escala);

    _pintarFondo(canvas, size, camaraX, escala, suelo);

    // Suelo: baldosas de dos tonos que corren con el Fragmento (se nota
    // el avance aunque no haya obstáculos a la vista).
    canvas.drawRect(Rect.fromLTRB(0, suelo, size.width, size.height),
        Paint()..color = PaletaNeon.fondoProfundo);
    final baldosaClara = Paint()..color = PaletaNeon.fondoMedio;
    final junta = Paint()
      ..color = PaletaNeon.violetaBase.withOpacity(0.7)
      ..strokeWidth = 1.5;
    for (var baldosa = camaraX.floorToDouble(); baldosa < camaraX + 10; baldosa += 1) {
      final izquierda = punto(baldosa, 0).dx;
      if (baldosa.toInt().isEven) {
        canvas.drawRect(
            Rect.fromLTRB(izquierda, suelo, izquierda + escala, size.height), baldosaClara);
      }
      canvas.drawLine(Offset(izquierda, suelo), Offset(izquierda, size.height), junta);
    }
    canvas.drawLine(Offset(0, suelo), Offset(size.width, suelo),
        Paint()
          ..color = PaletaNeon.violetaNeon
          ..strokeWidth = 2.5);
    canvas.drawLine(Offset(0, suelo), Offset(size.width, suelo),
        Paint()
          ..color = PaletaNeon.violetaNeon.withOpacity(0.4)
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    final visibleHasta = camaraX + 10;
    for (final puerta in partida.puertas) {
      if (puerta.finPlataforma < camaraX || puerta.inicioPlataforma > visibleHasta) continue;
      _pintarPuerta(canvas, puerta, punto, escala);
    }
    for (final obstaculo in partida.obstaculos) {
      if (obstaculo.fin < camaraX || obstaculo.x > visibleHasta) continue;
      switch (obstaculo.tipo) {
        case TipoObstaculo.pinchos:
          _pintarPinchos(canvas, obstaculo, punto);
        case TipoObstaculo.caja:
          _pintarCaja(canvas, obstaculo, punto, escala);
        case TipoObstaculo.foso:
          _pintarFoso(canvas, obstaculo, punto, size);
        case TipoObstaculo.trampolin:
          _pintarTrampolin(canvas, obstaculo, punto, escala);
      }
    }

    // El cubo del Fragmento: ámbar, girando en el aire.
    const lado = PartidaSalto.lado;
    final centro = punto(partida.x + lado / 2, partida.y + lado / 2);
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(partida.giro);
    final cubo = Rect.fromCenter(center: Offset.zero, width: lado * escala, height: lado * escala);
    canvas.drawRRect(RRect.fromRectAndRadius(cubo, Radius.circular(escala * 0.12)),
        Paint()..color = PaletaNeon.ambarCanales);
    canvas.drawRRect(
        RRect.fromRectAndRadius(cubo.deflate(escala * 0.22), Radius.circular(escala * 0.06)),
        Paint()..color = PaletaNeon.fondoProfundo.withOpacity(0.85));
    canvas.restore();
    canvas.drawCircle(centro, lado * escala * 0.9,
        Paint()
          ..color = PaletaNeon.ambarCanales.withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    if (destello > 0) {
      canvas.drawRect(Offset.zero & size,
          Paint()..color = PaletaNeon.rosaAcento.withOpacity(0.22 * destello));
    }
  }

  /// Cielo, estrellas y dos filas de edificios en parallax: cuanto más
  /// lejos, más despacio. Todo sale de la posición de la cámara, así que
  /// el fondo es siempre el mismo en el mismo sitio.
  void _pintarFondo(
      Canvas canvas, Size size, double camaraX, double escala, double suelo) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07041A), Color(0xFF1A0E3C)],
        ).createShader(Offset.zero & size),
    );

    // Estrellas (casi quietas).
    final estrella = Paint()..color = Colors.white.withOpacity(0.55);
    final desplazamientoEstrellas = camaraX * escala * 0.04;
    for (var i = 0; i < 40; i++) {
      final azar = math.Random(i * 7919);
      final x = (azar.nextDouble() * size.width * 1.5 - desplazamientoEstrellas) %
          (size.width * 1.5);
      final y = azar.nextDouble() * suelo * 0.55;
      canvas.drawCircle(Offset(x, y), 0.6 + azar.nextDouble() * 0.9, estrella);
    }

    _pintarEdificios(canvas, size, camaraX, escala, suelo,
        velocidad: 0.18,
        anchoBloque: 1.6,
        altoMaximo: 4.2,
        color: const Color(0xFF1C1244),
        ventana: PaletaNeon.violetaNeon.withOpacity(0.35),
        semilla: 11);
    _pintarEdificios(canvas, size, camaraX, escala, suelo,
        velocidad: 0.45,
        anchoBloque: 1.3,
        altoMaximo: 3.0,
        color: const Color(0xFF120A2C),
        ventana: PaletaNeon.ambarCanales.withOpacity(0.55),
        semilla: 29);
  }

  void _pintarEdificios(
    Canvas canvas,
    Size size,
    double camaraX,
    double escala,
    double suelo, {
    required double velocidad,
    required double anchoBloque,
    required double altoMaximo,
    required Color color,
    required Color ventana,
    required int semilla,
  }) {
    final camaraCapa = camaraX * velocidad;
    final primero = (camaraCapa / anchoBloque).floor();
    final cuantos = (9 / anchoBloque).ceil() + 2;
    final relleno = Paint()..color = color;
    final luz = Paint()..color = ventana;
    for (var i = primero; i < primero + cuantos; i++) {
      final azar = math.Random(i * 104729 + semilla);
      final alto = altoMaximo * (0.35 + 0.65 * azar.nextDouble());
      final ancho = anchoBloque * (0.7 + 0.3 * azar.nextDouble());
      final izquierda = (i * anchoBloque - camaraCapa) * escala;
      final rect = Rect.fromLTWH(izquierda, suelo - alto * escala, ancho * escala, alto * escala);
      canvas.drawRect(rect, relleno);
      // Ventanas encendidas al azar.
      final lado = escala * 0.12;
      for (var fila = 0; fila < (alto / 0.45).floor(); fila++) {
        for (var columna = 0; columna < (ancho / 0.4).floor(); columna++) {
          if (azar.nextDouble() > 0.35) continue;
          canvas.drawRect(
            Rect.fromLTWH(rect.left + (columna * 0.4 + 0.15) * escala,
                rect.top + (fila * 0.45 + 0.2) * escala, lado, lado * 1.3),
            luz,
          );
        }
      }
    }
  }

  void _pintarPinchos(
      Canvas canvas, Obstaculo pinchos, Offset Function(double, double) punto) {
    final relleno = Paint()..color = PaletaNeon.rosaAcento.withOpacity(0.85);
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..color = PaletaNeon.textoPrincipal.withOpacity(0.6)
      ..strokeWidth = 1.2;
    for (var i = 0; i < pinchos.ancho.round(); i++) {
      final izquierda = pinchos.x + i;
      final triangulo = Path()
        ..moveTo(punto(izquierda, 0).dx, punto(izquierda, 0).dy)
        ..lineTo(punto(izquierda + 0.5, 1).dx, punto(izquierda + 0.5, 1).dy)
        ..lineTo(punto(izquierda + 1, 0).dx, punto(izquierda + 1, 0).dy)
        ..close();
      canvas.drawPath(triangulo, relleno);
      canvas.drawPath(triangulo, borde);
    }
  }

  /// Caja de neón: se salta o se aterriza encima.
  void _pintarCaja(Canvas canvas, Obstaculo caja,
      Offset Function(double, double) punto, double escala) {
    final rect = Rect.fromPoints(
        punto(caja.x, PartidaSalto.altoCaja), punto(caja.fin, 0));
    canvas.drawRect(rect, Paint()..color = PaletaNeon.fondoMedio);
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = PaletaNeon.azulNeon;
    canvas.drawRect(rect.deflate(1), borde);
    // Aspa interior: se lee como caja a cualquier tamaño.
    final interior = rect.deflate(escala * 0.18);
    final aspa = Paint()
      ..color = PaletaNeon.azulNeon.withOpacity(0.45)
      ..strokeWidth = 1.5;
    canvas.drawLine(interior.topLeft, interior.bottomRight, aspa);
    canvas.drawLine(interior.topRight, interior.bottomLeft, aspa);
    // Tapa luminosa: aquí se puede pisar.
    canvas.drawLine(rect.topLeft, rect.topRight,
        Paint()
          ..color = PaletaNeon.ambarCanales
          ..strokeWidth = 2);
  }

  /// Foso: un corte negro en el suelo con bordes rosados.
  void _pintarFoso(Canvas canvas, Obstaculo foso,
      Offset Function(double, double) punto, Size size) {
    final izquierda = punto(foso.x, 0);
    final derecha = punto(foso.fin, 0);
    canvas.drawRect(Rect.fromLTRB(izquierda.dx, izquierda.dy - 1, derecha.dx, size.height),
        Paint()..color = const Color(0xFF05030A));
    final borde = Paint()
      ..color = PaletaNeon.rosaAcento.withOpacity(0.8)
      ..strokeWidth = 2;
    canvas.drawLine(izquierda, Offset(izquierda.dx, size.height), borde);
    canvas.drawLine(derecha, Offset(derecha.dx, size.height), borde);
  }

  /// Trampolín: base con muelle y placa verde; lanza solo.
  void _pintarTrampolin(Canvas canvas, Obstaculo trampolin,
      Offset Function(double, double) punto, double escala) {
    final placa = Rect.fromPoints(
        punto(trampolin.x, 0.42), punto(trampolin.fin, 0.28));
    final muelle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = PaletaNeon.textoTenue;
    final zigzag = Path()..moveTo(placa.center.dx, placa.bottom);
    const tramos = 4;
    for (var i = 1; i <= tramos; i++) {
      final dy = placa.bottom + (punto(0, 0).dy - placa.bottom) * i / tramos;
      zigzag.lineTo(placa.center.dx + (i.isOdd ? 1 : -1) * escala * 0.22, dy);
    }
    canvas.drawPath(zigzag, muelle);
    canvas.drawRRect(RRect.fromRectAndRadius(placa, Radius.circular(escala * 0.06)),
        Paint()..color = PaletaNeon.exitoSuave);
    canvas.drawCircle(placa.center, escala * 0.55,
        Paint()
          ..color = PaletaNeon.exitoSuave.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  void _pintarPuerta(Canvas canvas, PuertaDoble puerta,
      Offset Function(double, double) punto, double escala) {
    const alto = PartidaSalto.alturaPlataforma;
    // Plataforma de acceso a la hoja de arriba.
    final plataforma = Rect.fromPoints(
        punto(puerta.inicioPlataforma, alto), punto(puerta.finPlataforma, alto - 0.3));
    canvas.drawRect(plataforma, Paint()..color = PaletaNeon.fondoMedio);
    canvas.drawLine(plataforma.topLeft, plataforma.topRight,
        Paint()
          ..color = PaletaNeon.ambarCanales
          ..strokeWidth = 2);
    // Las dos hojas con su número.
    for (final (arriba, valor) in [(true, puerta.valorArriba), (false, puerta.valorAbajo)]) {
      final rect = arriba
          ? Rect.fromPoints(punto(puerta.x, alto + 2.8), punto(puerta.x + 0.6, alto))
          : Rect.fromPoints(punto(puerta.x, alto - 0.3), punto(puerta.x + 0.6, 0));
      canvas.drawRect(rect, Paint()..color = PaletaNeon.violetaBase.withOpacity(0.35));
      canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = PaletaNeon.violetaNeon);
      final texto = TextPainter(
        text: TextSpan(
          text: '$valor',
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: escala * 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // El número, delante de la hoja (se lee antes de llegar).
      texto.paint(canvas,
          Offset(rect.left - texto.width - escala * 0.25, rect.center.dy - texto.height / 2));
    }
  }

  @override
  bool shouldRepaint(PintorSalto anterior) => true;
}
