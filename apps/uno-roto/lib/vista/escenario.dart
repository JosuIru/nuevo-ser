import 'dart:math' as math;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../dominio/ambiente_cielo.dart';
import '../dominio/taller_ciudad.dart';
import '../nucleo/paleta.dart';

/// Escenario urbano nocturno con atmósfera específica por distrito.
///
/// El parámetro [idDistrito] selecciona qué se pinta en primer plano y
/// qué paleta de cielo se usa. La mecánica común (lunas, estrellas,
/// niebla del [AmbienteCielo], lluvia) está compartida; los elementos
/// diferenciadores (agua de los canales, grúas del puerto, chimeneas de
/// industria, hierba de las afueras…) se delegan en el dispatcher
/// [_pintarBaseDistrito].
///
/// [nivelRestauracion] varía entre 0 (noche apagada) y 1 (ciudad bien
/// iluminada): más Fragmentos derrotados → más ventanas encendidas y
/// estrellas más brillantes. Progresión diegética sin números visibles.
///
/// [ambiente] caracteriza el cielo (lunas, niebla, lluvia) — usado por
/// las variantes de entrenamiento del Arco 1 (doc 07 §1.8) para que
/// cada noche se distinga visualmente. Algunos distritos (Canales,
/// Puerto) añaden una niebla mínima por encima del ambiente.
class PintorEscenario extends CustomPainter {
  final double fasePulso;
  final double nivelRestauracion;
  final AmbienteCielo ambiente;

  /// Fase 0..1 del controlador de lluvia, periodo corto. Se ignora si
  /// [AmbienteCielo.intensidadLluvia] es 0.
  final double fasePulsoLluvia;

  /// Identificador del distrito (`tejados`, `canales`, `mercado`,
  /// `industria`, `puerto`, `afueras`). Default `tejados` para que las
  /// pantallas no-cazadero usen el fondo neutro original.
  final String idDistrito;

  /// Ids de [PiezaCiudad] que el niño ya restauró en el taller
  /// (doc 16, eje B). Las de ESTE distrito se pintan encendidas por
  /// encima de la base — el antes/después visible al volver a cazar.
  final Set<String> piezasRestauradas;

  PintorEscenario({
    required this.fasePulso,
    required this.nivelRestauracion,
    this.ambiente = AmbienteCielo.neutro,
    this.fasePulsoLluvia = 0,
    this.idDistrito = 'tejados',
    this.piezasRestauradas = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    _pintarCielo(canvas, size);
    _pintarLunas(canvas, size);
    _pintarEstrellas(canvas, size);
    _pintarMontana(canvas, size);
    _pintarNiebla(canvas, size);
    _pintarBaseDistrito(canvas, size);
    _pintarPiezasRestauradas(canvas, size);
    _pintarLluvia(canvas, size);
  }

  // -------------------------------------------------------------------
  // PIEZAS RESTAURADAS EN EL TALLER (doc 16, eje B)
  // -------------------------------------------------------------------

  /// Pinta las piezas del distrito actual que el niño restauró. Van
  /// después de la base (encima de edificios) y antes de la lluvia.
  /// Tres primitivas cálidas, sin fanfarria: la luz basta.
  void _pintarPiezasRestauradas(Canvas canvas, Size size) {
    if (piezasRestauradas.isEmpty) return;
    for (final pieza in CatalogoTaller.delDistrito(idDistrito)) {
      if (!piezasRestauradas.contains(pieza.id)) continue;
      final centro = Offset(
        pieza.xEscena * size.width,
        pieza.yEscena * size.height,
      );
      switch (pieza.tipoVisual) {
        case TipoPiezaVisual.farol:
          _pintarFarolRestaurado(canvas, centro);
        case TipoPiezaVisual.ventanas:
          _pintarVentanasRestauradas(canvas, centro);
        case TipoPiezaVisual.guirnalda:
          _pintarGuirnaldaRestaurada(canvas, centro);
      }
    }
  }

  void _pintarFarolRestaurado(Canvas canvas, Offset centro) {
    final pulso = math.sin(fasePulso * 2 * math.pi) * 0.10 + 0.90;
    // Poste.
    final pinturaPoste = Paint()
      ..color = PaletaNeon.textoTenue.withOpacity(0.35)
      ..strokeWidth = 1.6;
    canvas.drawLine(centro, centro.translate(0, 26), pinturaPoste);
    // Halo cálido y cabeza del farol.
    final pinturaHalo = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.30 * pulso)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(centro, 12, pinturaHalo);
    final pinturaLuz = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.95 * pulso);
    canvas.drawCircle(centro, 3.2, pinturaLuz);
  }

  void _pintarVentanasRestauradas(Canvas canvas, Offset centro) {
    final pulso = math.sin(fasePulso * 2 * math.pi + 1.3) * 0.08 + 0.92;
    final pinturaVentana = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.80 * pulso);
    final pinturaHalo = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.16 * pulso)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    for (var indice = 0; indice < 3; indice++) {
      final esquina = centro.translate(indice * 11.0 - 11.0, 0);
      final rect = Rect.fromCenter(center: esquina, width: 6, height: 9);
      canvas.drawRect(rect.inflate(3), pinturaHalo);
      canvas.drawRect(rect, pinturaVentana);
    }
  }

  void _pintarGuirnaldaRestaurada(Canvas canvas, Offset centro) {
    // Siete lucecitas colgadas siguiendo una catenaria suave.
    const totalLuces = 7;
    const anchoTotal = 72.0;
    for (var indice = 0; indice < totalLuces; indice++) {
      final avance = indice / (totalLuces - 1); // 0..1
      final cordX = centro.dx + (avance - 0.5) * anchoTotal;
      // La curva cae 10 px en el centro (forma de cuerda colgada).
      final caida = 10.0 * (1 - (2 * avance - 1) * (2 * avance - 1));
      final punto = Offset(cordX, centro.dy + caida);
      final pulso =
          math.sin(fasePulso * 2 * math.pi + indice * 0.9) * 0.20 + 0.80;
      final pinturaHalo = Paint()
        ..color = PaletaNeon.ambarCanales.withOpacity(0.20 * pulso)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(punto, 5, pinturaHalo);
      final pinturaLuz = Paint()
        ..color = PaletaNeon.ambarCanales.withOpacity(0.85 * pulso);
      canvas.drawCircle(punto, 1.8, pinturaLuz);
    }
  }

  // -------------------------------------------------------------------
  // HELPERS DE PALETA Y AJUSTES POR DISTRITO
  // -------------------------------------------------------------------

  List<Color> _coloresCielo() {
    switch (idDistrito) {
      case 'canales':
        return [
          const Color(0xFF0C0925),
          const Color(0xFF1B1538),
          PaletaNeon.violetaBase.withOpacity(0.22),
        ];
      case 'mercado':
        return [
          const Color(0xFF1A0820),
          const Color(0xFF351528),
          const Color(0xFF6B2A38).withOpacity(0.45),
        ];
      case 'industria':
        return [
          const Color(0xFF071018),
          const Color(0xFF0C1825),
          const Color(0xFF1A3548).withOpacity(0.40),
        ];
      case 'puerto':
        return [
          const Color(0xFF03050E),
          const Color(0xFF080F1E),
          const Color(0xFF0E1A2E).withOpacity(0.85),
        ];
      case 'afueras':
        return [
          const Color(0xFF150C2B),
          const Color(0xFF271D55),
          const Color(0xFF463A85).withOpacity(0.40),
        ];
      case 'tejados':
      default:
        return [
          PaletaNeon.fondoProfundo,
          PaletaNeon.fondoMedio,
          PaletaNeon.violetaBase.withOpacity(0.35),
        ];
    }
  }

  /// Niebla mínima que el distrito impone aunque el [AmbienteCielo] sea
  /// neutro. Canales y Puerto siempre tienen niebla baja por lore.
  double _intensidadNieblaMinima() {
    switch (idDistrito) {
      case 'canales':
        return 0.45;
      case 'puerto':
        return 0.55;
      case 'industria':
        return 0.18;
      default:
        return 0.0;
    }
  }

  /// Escala vertical de los picos de la Montaña. Afueras la enseña más
  /// grande por estar al norte, en zona de horizonte abierto.
  double _escalaMontana() {
    switch (idDistrito) {
      case 'afueras':
        return 1.45;
      case 'puerto':
        return 1.10;
      default:
        return 1.0;
    }
  }

  bool _mostrarCumbreNevada() => idDistrito == 'afueras';

  // -------------------------------------------------------------------
  // CIELO, LUNAS, ESTRELLAS
  // -------------------------------------------------------------------

  void _pintarCielo(Canvas canvas, Size size) {
    final pintura = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _coloresCielo(),
        stops: const [0, 0.55, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, pintura);
  }

  void _pintarLunas(Canvas canvas, Size size) {
    if (!ambiente.mostrarLunas) return;
    final lineaHorizonte = size.height * 0.55;
    final pulsoSuave =
        (math.sin(fasePulso * 2 * math.pi) * 0.06 + 0.94).clamp(0.7, 1.0);

    _pintarLunaCreciente(
      canvas,
      centro: Offset(size.width * 0.78, lineaHorizonte - 90),
      radio: 22 * pulsoSuave,
      desplazamientoSombra: 7,
    );
    _pintarLunaCreciente(
      canvas,
      centro: Offset(size.width * 0.92, lineaHorizonte - 60),
      radio: 14 * pulsoSuave,
      desplazamientoSombra: 4.5,
    );
  }

  void _pintarLunaCreciente(
    Canvas canvas, {
    required Offset centro,
    required double radio,
    required double desplazamientoSombra,
  }) {
    final pinturaHalo = Paint()
      ..color = const Color(0xFFE8E0C8).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(centro, radio * 1.55, pinturaHalo);

    final pinturaLuna = Paint()
      ..color = const Color(0xFFF5ECC8).withOpacity(0.78);
    canvas.save();
    final rectClip = Rect.fromCircle(center: centro, radius: radio * 1.05);
    canvas.clipPath(Path()..addOval(rectClip));
    canvas.drawCircle(centro, radio, pinturaLuna);
    final pinturaSombra = Paint()
      ..color = PaletaNeon.fondoProfundo.withOpacity(0.96);
    canvas.drawCircle(
      centro.translate(-desplazamientoSombra, -desplazamientoSombra * 0.4),
      radio * 0.96,
      pinturaSombra,
    );
    canvas.restore();
  }

  void _pintarEstrellas(Canvas canvas, Size size) {
    // Afueras: cielo abierto, más estrellas que cualquier otro distrito.
    final factorDistrito = idDistrito == 'afueras' ? 1.6 : 1.0;
    final cantidad =
        (60 * ambiente.densidadEstrellas * factorDistrito).round();
    if (cantidad <= 0) return;
    final generador = math.Random(42);
    final pinturaEstrella = Paint()..color = PaletaNeon.textoTenue;
    final refuerzoBrillo = 0.5 + nivelRestauracion * 0.5;
    final atenuacionNiebla = 1.0 - ambiente.intensidadNiebla * 0.6;
    for (var indice = 0; indice < cantidad; indice++) {
      final cordX = generador.nextDouble() * size.width;
      final cordY = generador.nextDouble() * size.height * 0.6;
      final brilloBase = 0.25 + generador.nextDouble() * 0.45;
      final parpadeo =
          math.sin((fasePulso * 2 * math.pi) + indice * 1.3) * 0.15 + 0.85;
      pinturaEstrella.color = PaletaNeon.textoTenue.withOpacity(
        (brilloBase * parpadeo * refuerzoBrillo * atenuacionNiebla)
            .clamp(0.0, 1.0),
      );
      canvas.drawCircle(
        Offset(cordX, cordY),
        0.6 + generador.nextDouble() * 0.8,
        pinturaEstrella,
      );
    }
  }

  // -------------------------------------------------------------------
  // MONTAÑA
  // -------------------------------------------------------------------

  void _pintarMontana(Canvas canvas, Size size) {
    final lineaHorizonte = size.height * 0.55;
    final escala = _escalaMontana();
    final trazado = Path()
      ..moveTo(-10, lineaHorizonte + 40)
      ..lineTo(size.width * 0.18, lineaHorizonte - 30 * escala)
      ..lineTo(size.width * 0.28, lineaHorizonte - 10 * escala)
      ..lineTo(size.width * 0.42, lineaHorizonte - 70 * escala)
      ..lineTo(size.width * 0.55, lineaHorizonte - 25 * escala)
      ..lineTo(size.width * 0.68, lineaHorizonte - 50 * escala)
      ..lineTo(size.width * 0.82, lineaHorizonte - 15 * escala)
      ..lineTo(size.width + 10, lineaHorizonte + 20)
      ..lineTo(size.width + 10, lineaHorizonte + 80)
      ..lineTo(-10, lineaHorizonte + 80)
      ..close();

    final claridad = ambiente.claridadMontana.clamp(0.0, 1.5);
    final pintura = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PaletaNeon.violetaBase.withOpacity((0.45 * claridad).clamp(0.0, 1.0)),
          PaletaNeon.fondoProfundo
              .withOpacity((0.85 * claridad).clamp(0.0, 1.0)),
        ],
      ).createShader(trazado.getBounds());
    canvas.drawPath(trazado, pintura);

    if (_mostrarCumbreNevada()) {
      _pintarCumbreNevada(canvas, size, lineaHorizonte, escala);
    }
  }

  void _pintarCumbreNevada(
    Canvas canvas,
    Size size,
    double lineaHorizonte,
    double escala,
  ) {
    // Triangulito blanco hueso sobre el pico más alto (x=0.42). Da la
    // sensación de "cumbre nevada que aparece solo al amanecer" del
    // doc 11, atenuada por noche pero visible.
    final cima = Offset(size.width * 0.42, lineaHorizonte - 70 * escala);
    final flanco = 18.0 * escala;
    final altura = 14.0 * escala;
    final trazado = Path()
      ..moveTo(cima.dx - flanco, cima.dy + altura)
      ..lineTo(cima.dx, cima.dy)
      ..lineTo(cima.dx + flanco * 0.7, cima.dy + altura * 0.85)
      ..lineTo(cima.dx + flanco * 0.3, cima.dy + altura * 0.6)
      ..lineTo(cima.dx - flanco * 0.4, cima.dy + altura * 0.95)
      ..close();
    final pintura = Paint()
      ..color = const Color(0xFFE8E2D0).withOpacity(0.42);
    canvas.drawPath(trazado, pintura);
  }

  // -------------------------------------------------------------------
  // NIEBLA Y LLUVIA (compartidas, respetan ambiente + mínimo del distrito)
  // -------------------------------------------------------------------

  void _pintarNiebla(Canvas canvas, Size size) {
    final intensidad = math
        .max(ambiente.intensidadNiebla, _intensidadNieblaMinima())
        .clamp(0.0, 1.0);
    if (intensidad <= 0) return;
    final lineaHorizonte = size.height * 0.55;
    final desplazamientoX = math.sin(fasePulso * 2 * math.pi) * 18;

    final rectBanda = Rect.fromLTRB(
      -40,
      lineaHorizonte - 40,
      size.width + 40,
      lineaHorizonte + 120,
    );
    final pinturaBanda = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFB7B0D2).withOpacity(0.0),
          const Color(0xFFB7B0D2).withOpacity(0.55 * intensidad),
          const Color(0xFFB7B0D2).withOpacity(0.78 * intensidad),
        ],
        stops: const [0, 0.4, 1],
      ).createShader(rectBanda);
    canvas.save();
    canvas.translate(desplazamientoX * 0.4, 0);
    canvas.drawRect(rectBanda, pinturaBanda);
    canvas.restore();

    final generador = math.Random(7);
    final pinturaMancha = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    for (var indice = 0; indice < 6; indice++) {
      final cordX = generador.nextDouble() * (size.width + 80) - 40;
      final cordY = lineaHorizonte + generador.nextDouble() * 110 - 20;
      final radio = 60 + generador.nextDouble() * 90;
      final faseLocal = generador.nextDouble() * math.pi * 2;
      final desplazamientoLocal =
          math.sin(fasePulso * 2 * math.pi + faseLocal) * 12;
      pinturaMancha.color = const Color(0xFFCFC8DE)
          .withOpacity((0.18 + generador.nextDouble() * 0.18) * intensidad);
      canvas.drawCircle(
        Offset(cordX + desplazamientoLocal, cordY),
        radio,
        pinturaMancha,
      );
    }
  }

  void _pintarLluvia(Canvas canvas, Size size) {
    if (ambiente.intensidadLluvia <= 0) return;
    final intensidad = ambiente.intensidadLluvia.clamp(0.0, 1.0);
    final cantidadGotas = (110 * intensidad).round();
    final pinturaGota = Paint()
      ..color = PaletaNeon.azulNeon.withOpacity(0.42 * intensidad)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final generador = math.Random(91);
    final altura = size.height;
    final desplazamiento = fasePulsoLluvia * altura * 1.6;
    for (var indice = 0; indice < cantidadGotas; indice++) {
      final cordX = generador.nextDouble() * size.width;
      final desfase = generador.nextDouble() * altura;
      final cordYInicio = ((desfase + desplazamiento) % (altura + 60)) - 60;
      final largo = 8.0 + generador.nextDouble() * 10;
      const inclinacion = 2.0;
      canvas.drawLine(
        Offset(cordX, cordYInicio),
        Offset(cordX + inclinacion, cordYInicio + largo),
        pinturaGota,
      );
    }
  }

  // -------------------------------------------------------------------
  // DISPATCHER POR DISTRITO
  // -------------------------------------------------------------------

  void _pintarBaseDistrito(Canvas canvas, Size size) {
    switch (idDistrito) {
      case 'canales':
        _pintarBaseCanales(canvas, size);
        break;
      case 'mercado':
        _pintarBaseMercado(canvas, size);
        break;
      case 'industria':
        _pintarBaseIndustria(canvas, size);
        break;
      case 'puerto':
        _pintarBasePuerto(canvas, size);
        break;
      case 'afueras':
        _pintarBaseAfueras(canvas, size);
        break;
      case 'montana':
        _pintarBaseAfueras(canvas, size);
        break;
      case 'tejados':
      default:
        _pintarBaseTejados(canvas, size);
        break;
    }
  }

  // -------------------------------------------------------------------
  // TEJADOS — el de siempre.
  // -------------------------------------------------------------------

  void _pintarBaseTejados(Canvas canvas, Size size) {
    final lineaSuelo = size.height - 24;
    final alturas = [110.0, 160.0, 95.0, 200.0, 130.0, 175.0, 80.0, 145.0];
    final anchuras = [60.0, 45.0, 70.0, 55.0, 40.0, 65.0, 50.0, 75.0];
    var cursorX = -10.0;

    final pinturaEdificio = Paint()
      ..color = const Color(0xFF07041A)
      ..style = PaintingStyle.fill;
    final pinturaBordeNeon = Paint()
      ..color = PaletaNeon.violetaNeon.withOpacity(0.35)
      ..strokeWidth = 1;

    for (var indice = 0; indice < alturas.length; indice++) {
      final ancho = anchuras[indice % anchuras.length];
      final alto = alturas[indice];
      final rectEdificio = Rect.fromLTWH(
        cursorX,
        lineaSuelo - alto,
        ancho,
        alto + 40,
      );
      canvas.drawRect(rectEdificio, pinturaEdificio);
      canvas.drawLine(
        Offset(cursorX, lineaSuelo - alto),
        Offset(cursorX + ancho, lineaSuelo - alto),
        pinturaBordeNeon,
      );
      _pintarVentanasCalidas(
        canvas,
        rectEdificio,
        indice,
        const Color(0xFFFFD08A),
      );
      cursorX += ancho;
      if (cursorX > size.width) break;
    }

    if (ambiente.intensidadLluvia > 0) {
      _pintarSueloMojado(canvas, size, lineaSuelo);
    }
  }

  // -------------------------------------------------------------------
  // CANALES — agua oscura con reflejos quebrados, edificios de piedra
  // bajos, niebla baja, farolillos amarillo vela.
  // -------------------------------------------------------------------

  void _pintarBaseCanales(Canvas canvas, Size size) {
    final nivelAgua = size.height - 90; // El "suelo" es el agua.

    // Edificios de piedra a ambos lados. Más bajos, color piedra-violeta.
    final pinturaEdificio = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    final pinturaBorde = Paint()
      ..color = PaletaNeon.ambarCanales.withOpacity(0.18)
      ..strokeWidth = 1;
    const colorVelaCalida = Color(0xFFE8B85C);

    // Banda izquierda (3-4 edificios bajos).
    final alturasIzq = [85.0, 110.0, 75.0, 95.0];
    final anchurasIzq = [70.0, 55.0, 65.0, 60.0];
    var cursorIzq = -10.0;
    for (var indice = 0; indice < alturasIzq.length; indice++) {
      final alto = alturasIzq[indice];
      final ancho = anchurasIzq[indice];
      final rectEdificio = Rect.fromLTWH(
        cursorIzq,
        nivelAgua - alto,
        ancho,
        alto,
      );
      canvas.drawRect(rectEdificio, pinturaEdificio);
      canvas.drawLine(
        Offset(cursorIzq, nivelAgua - alto),
        Offset(cursorIzq + ancho, nivelAgua - alto),
        pinturaBorde,
      );
      _pintarVentanasCalidas(canvas, rectEdificio, indice + 100, colorVelaCalida);
      cursorIzq += ancho;
      if (cursorIzq > size.width * 0.42) break;
    }

    // Banda derecha (espejada).
    final alturasDer = [95.0, 80.0, 115.0, 70.0];
    final anchurasDer = [60.0, 70.0, 55.0, 65.0];
    var cursorDer = size.width + 10;
    for (var indice = 0; indice < alturasDer.length; indice++) {
      final alto = alturasDer[indice];
      final ancho = anchurasDer[indice];
      cursorDer -= ancho;
      final rectEdificio = Rect.fromLTWH(
        cursorDer,
        nivelAgua - alto,
        ancho,
        alto,
      );
      canvas.drawRect(rectEdificio, pinturaEdificio);
      canvas.drawLine(
        Offset(cursorDer, nivelAgua - alto),
        Offset(cursorDer + ancho, nivelAgua - alto),
        pinturaBorde,
      );
      _pintarVentanasCalidas(canvas, rectEdificio, indice + 200, colorVelaCalida);
      if (cursorDer < size.width * 0.58) break;
    }

    // Puente bajo cruzando el canal.
    _pintarPuente(canvas, size, nivelAgua);

    // Agua del canal con reflejos quebrados.
    _pintarAgua(canvas, size, nivelAgua, colorVelaCalida);

    // Farolillos colgando entre edificios (puntos cálidos pulsantes).
    _pintarFarolillos(canvas, size, nivelAgua, colorVelaCalida);
  }

  void _pintarPuente(Canvas canvas, Size size, double nivelAgua) {
    final centroX = size.width * 0.5;
    final anchoPuente = size.width * 0.32;
    const altura = 22.0;
    final trazado = Path()
      ..moveTo(centroX - anchoPuente / 2, nivelAgua)
      ..quadraticBezierTo(
        centroX,
        nivelAgua - altura * 1.6,
        centroX + anchoPuente / 2,
        nivelAgua,
      );
    final pinturaArco = Paint()
      ..color = const Color(0xFF3A3548)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(trazado, pinturaArco);
  }

  void _pintarAgua(
    Canvas canvas,
    Size size,
    double nivelAgua,
    Color colorReflejo,
  ) {
    // Banda de agua oscura.
    final rectAgua = Rect.fromLTWH(0, nivelAgua, size.width, size.height - nivelAgua);
    final pinturaAgua = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF080620).withOpacity(0.85),
          const Color(0xFF02010A).withOpacity(1.0),
        ],
      ).createShader(rectAgua);
    canvas.drawRect(rectAgua, pinturaAgua);

    // Reflejos verticales quebrados — uno por edificio principal.
    final generador = math.Random(13);
    final pinturaReflejo = Paint()
      ..color = colorReflejo.withOpacity(0.35)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var indice = 0; indice < 8; indice++) {
      final cordX = (size.width * 0.1) + generador.nextDouble() * size.width * 0.8;
      final largo = 22 + generador.nextDouble() * 30;
      // Ondulación: el reflejo "tiembla" vertical y horizontalmente.
      final fase = generador.nextDouble() * math.pi * 2;
      final desviacionX = math.sin(fasePulso * 2 * math.pi * 2 + fase) * 1.5;
      final cordYInicio = nivelAgua + 4;
      final cordYFin = cordYInicio + largo;
      pinturaReflejo.color = colorReflejo.withOpacity(
        (0.20 + math.sin(fasePulso * 2 * math.pi + fase) * 0.10).clamp(0.0, 1.0),
      );
      canvas.drawLine(
        Offset(cordX, cordYInicio),
        Offset(cordX + desviacionX, cordYFin),
        pinturaReflejo,
      );
    }

    // Brillo horizontal sutil sobre la superficie.
    final pinturaSuperficie = Paint()
      ..color = colorReflejo.withOpacity(0.10)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var indice = 0; indice < 12; indice++) {
      final cordX = (indice / 12) * size.width;
      final desfaseSinusoidal = math.sin(fasePulso * 2 * math.pi + indice) * 6;
      canvas.drawLine(
        Offset(cordX, nivelAgua + 2 + desfaseSinusoidal * 0.2),
        Offset(cordX + 30, nivelAgua + 2 + desfaseSinusoidal * 0.2),
        pinturaSuperficie,
      );
    }
  }

  void _pintarFarolillos(
    Canvas canvas,
    Size size,
    double nivelAgua,
    Color colorVela,
  ) {
    // Cinco farolillos colgando entre edificios, alturas distintas.
    final posicionesX = [0.18, 0.34, 0.5, 0.66, 0.82];
    final alturasY = [0.42, 0.38, 0.45, 0.40, 0.43];
    for (var indice = 0; indice < posicionesX.length; indice++) {
      final cordX = posicionesX[indice] * size.width;
      final cordY = alturasY[indice] * size.height;
      final pulso = math.sin(fasePulso * 2 * math.pi + indice * 0.7) * 0.15 + 0.85;

      // Halo blando.
      final pinturaHalo = Paint()
        ..color = colorVela.withOpacity(0.22 * pulso)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(cordX, cordY), 8, pinturaHalo);
      // Punto.
      final pinturaPunto = Paint()..color = colorVela.withOpacity(0.85 * pulso);
      canvas.drawCircle(Offset(cordX, cordY), 2.5, pinturaPunto);
      // Cuerda fina hacia arriba.
      final pinturaCuerda = Paint()
        ..color = colorVela.withOpacity(0.10)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(cordX, cordY - 3),
        Offset(cordX, cordY - 22),
        pinturaCuerda,
      );
    }
  }

  // -------------------------------------------------------------------
  // MERCADO — bazar nocturno cálido con toldos y farolillos densos.
  // -------------------------------------------------------------------

  void _pintarBaseMercado(Canvas canvas, Size size) {
    final lineaSuelo = size.height - 24;
    // Edificios bajos, todos similares en altura — bazar denso.
    final alturas = [70.0, 85.0, 60.0, 95.0, 75.0, 80.0, 65.0, 90.0, 70.0];
    final anchuras = [55.0, 48.0, 62.0, 50.0, 45.0, 58.0, 52.0, 60.0, 50.0];
    var cursorX = -10.0;

    final pinturaEdificio = Paint()
      ..color = const Color(0xFF1A0F18)
      ..style = PaintingStyle.fill;
    const colorRosaApagado = Color(0xFFE8859A);
    const colorAmbarMercado = Color(0xFFFFB05E);

    for (var indice = 0; indice < alturas.length; indice++) {
      final ancho = anchuras[indice % anchuras.length];
      final alto = alturas[indice];
      final rectEdificio = Rect.fromLTWH(
        cursorX,
        lineaSuelo - alto,
        ancho,
        alto + 40,
      );
      canvas.drawRect(rectEdificio, pinturaEdificio);
      // Toldo encima: rectángulo bajo inclinado con rayas.
      _pintarToldo(canvas, rectEdificio, indice, colorRosaApagado, colorAmbarMercado);
      _pintarVentanasCalidas(canvas, rectEdificio, indice + 300, colorAmbarMercado);
      cursorX += ancho;
      if (cursorX > size.width) break;
    }

    // Farolillos cálidos densos por toda la escena (alta densidad).
    _pintarFarolillosMercado(canvas, size);

    // Vapor vertical de cocinas en zonas concretas.
    _pintarVaporVertical(canvas, size, lineaSuelo, [0.22, 0.55, 0.78]);
  }

  void _pintarToldo(
    Canvas canvas,
    Rect edificio,
    int semilla,
    Color colorRayaA,
    Color colorRayaB,
  ) {
    // Toldo: rectángulo de altura 12 sobre el techo, con dos colores en
    // rayas verticales.
    const altura = 10.0;
    final rectToldo = Rect.fromLTWH(
      edificio.left - 4,
      edificio.top - altura,
      edificio.width + 8,
      altura,
    );
    final usarRosa = semilla.isEven;
    final colorBase = usarRosa ? colorRayaA : colorRayaB;
    final colorRaya = usarRosa ? colorRayaB : colorRayaA;
    final pinturaBase = Paint()..color = colorBase.withOpacity(0.55);
    canvas.drawRect(rectToldo, pinturaBase);
    final pinturaRaya = Paint()
      ..color = colorRaya.withOpacity(0.45)
      ..strokeWidth = 3;
    for (var cordX = rectToldo.left + 6;
        cordX < rectToldo.right;
        cordX += 12) {
      canvas.drawLine(
        Offset(cordX, rectToldo.top),
        Offset(cordX, rectToldo.bottom),
        pinturaRaya,
      );
    }
  }

  void _pintarFarolillosMercado(Canvas canvas, Size size) {
    // 14 farolillos repartidos a lo ancho y a varias alturas. Los colores
    // varían entre ámbar, rosa y dorado.
    final colores = [
      const Color(0xFFFFB05E), // ámbar mercado
      const Color(0xFFFF7ED0), // rosa
      const Color(0xFFFFD34A), // dorado
    ];
    final generador = math.Random(53);
    const cantidad = 18;
    for (var indice = 0; indice < cantidad; indice++) {
      final cordX = generador.nextDouble() * size.width;
      final cordY = size.height * (0.35 + generador.nextDouble() * 0.22);
      final color = colores[indice % colores.length];
      final pulso = math.sin(fasePulso * 2 * math.pi + indice * 0.5) * 0.20 + 0.80;
      final pinturaHalo = Paint()
        ..color = color.withOpacity(0.28 * pulso)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(cordX, cordY), 10, pinturaHalo);
      final pinturaPunto = Paint()..color = color.withOpacity(0.90 * pulso);
      canvas.drawCircle(Offset(cordX, cordY), 2.8, pinturaPunto);
    }
  }

  void _pintarVaporVertical(
    Canvas canvas,
    Size size,
    double lineaSuelo,
    List<double> posicionesNormalizadas,
  ) {
    // Columnas de vapor cálido subiendo desde el suelo.
    const colorVapor = Color(0xFFE8C8A0);
    for (var indice = 0; indice < posicionesNormalizadas.length; indice++) {
      final cordX = posicionesNormalizadas[indice] * size.width;
      final faseLocal = indice * 1.7;
      for (var paso = 0; paso < 5; paso++) {
        final altura = paso * 26.0;
        final desviacion =
            math.sin(fasePulso * 2 * math.pi + faseLocal + paso * 0.3) * 6;
        final radio = 14.0 + paso * 3.5;
        final opacidad = (0.18 - paso * 0.03).clamp(0.0, 1.0);
        final pintura = Paint()
          ..color = colorVapor.withOpacity(opacidad)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
        canvas.drawCircle(
          Offset(cordX + desviacion, lineaSuelo - altura - 10),
          radio,
          pintura,
        );
      }
    }
  }

  // -------------------------------------------------------------------
  // INDUSTRIA — chimeneas, naves bajas, neón teal frío, vapor vertical.
  // -------------------------------------------------------------------

  void _pintarBaseIndustria(Canvas canvas, Size size) {
    final lineaSuelo = size.height - 24;
    final pinturaEstructura = Paint()
      ..color = const Color(0xFF0A1018)
      ..style = PaintingStyle.fill;
    const colorNeonFrio = Color(0xFF7EE8D7);
    const colorVentanaIndustria = Color(0xFF9FE8D7);

    // Naves industriales: bajas y anchas, pocas ventanas grandes.
    final tramosNaves = [
      (cordX: -10.0, ancho: 130.0, alto: 70.0),
      (cordX: 120.0, ancho: 100.0, alto: 110.0),
      (cordX: 220.0, ancho: 145.0, alto: 85.0),
      (cordX: 365.0, ancho: 110.0, alto: 130.0),
      (cordX: 475.0, ancho: 90.0, alto: 75.0),
    ];
    for (final tramo in tramosNaves) {
      if (tramo.cordX > size.width) break;
      final rect = Rect.fromLTWH(
        tramo.cordX,
        lineaSuelo - tramo.alto,
        tramo.ancho,
        tramo.alto + 40,
      );
      canvas.drawRect(rect, pinturaEstructura);
      // Borde neón teal arriba.
      final pinturaBorde = Paint()
        ..color = colorNeonFrio.withOpacity(0.30)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(rect.left, rect.top),
        Offset(rect.right, rect.top),
        pinturaBorde,
      );
      // Ventanas grandes, pocas, tipo "ventana de fábrica" (una fila).
      _pintarVentanasFabrica(canvas, rect, colorVentanaIndustria);
    }

    // Chimeneas verticales con humo.
    _pintarChimenea(canvas, size, posicionX: size.width * 0.20, alturaTotal: 200);
    _pintarChimenea(canvas, size, posicionX: size.width * 0.62, alturaTotal: 240);
    _pintarChimenea(canvas, size, posicionX: size.width * 0.88, alturaTotal: 170);

    // Tuberías oblicuas conectando naves.
    final pinturaTuberia = Paint()
      ..color = const Color(0xFF3A3025)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.16, lineaSuelo - 50),
      Offset(size.width * 0.40, lineaSuelo - 30),
      pinturaTuberia,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, lineaSuelo - 80),
      Offset(size.width * 0.78, lineaSuelo - 60),
      pinturaTuberia,
    );
  }

  void _pintarVentanasFabrica(Canvas canvas, Rect edificio, Color colorVentana) {
    // Una sola fila de ventanas grandes a media altura del edificio.
    final cordY = edificio.top + edificio.height * 0.35;
    const tamanoX = 8.0;
    const tamanoY = 12.0;
    final pinturaVentana = Paint()..color = colorVentana.withOpacity(0.55);
    for (var cordX = edificio.left + 8;
        cordX < edificio.right - 8;
        cordX += 14) {
      canvas.drawRect(
        Rect.fromLTWH(cordX, cordY, tamanoX, tamanoY),
        pinturaVentana,
      );
    }
  }

  void _pintarChimenea(
    Canvas canvas,
    Size size, {
    required double posicionX,
    required double alturaTotal,
  }) {
    final lineaSuelo = size.height - 24;
    const ancho = 18.0;
    // Cuerpo cilíndrico simulado (rectángulo estrecho con borde).
    final rectCuerpo = Rect.fromLTWH(
      posicionX - ancho / 2,
      lineaSuelo - alturaTotal,
      ancho,
      alturaTotal,
    );
    final pinturaCuerpo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF1A1612),
          Color(0xFF2A2520),
          Color(0xFF1A1612),
        ],
      ).createShader(rectCuerpo);
    canvas.drawRect(rectCuerpo, pinturaCuerpo);

    // Banda roja oxidada en la parte alta.
    final pinturaBanda = Paint()..color = PaletaNeon.rojoOxidado.withOpacity(0.55);
    canvas.drawRect(
      Rect.fromLTWH(rectCuerpo.left, rectCuerpo.top + 6, ancho, 4),
      pinturaBanda,
    );

    // Humo vertical lento subiendo desde la boca.
    const colorHumo = Color(0xFFB0BCC8);
    for (var paso = 0; paso < 6; paso++) {
      final faseLocal = (posicionX * 0.013) + paso * 0.4;
      final desviacion =
          math.sin(fasePulso * 2 * math.pi + faseLocal) * (4 + paso * 1.2);
      final cordY = rectCuerpo.top - paso * 22 - 6;
      final radio = 12.0 + paso * 4;
      final opacidad = (0.30 - paso * 0.04).clamp(0.0, 1.0);
      final pintura = Paint()
        ..color = colorHumo.withOpacity(opacidad)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(
        Offset(posicionX + desviacion, cordY),
        radio,
        pintura,
      );
    }
  }

  // -------------------------------------------------------------------
  // PUERTO — mar oscuro, muelle de madera, grúas siluetadas, faro lejano.
  // -------------------------------------------------------------------

  void _pintarBasePuerto(Canvas canvas, Size size) {
    final lineaMuelle = size.height * 0.78;
    const colorAmbarLejano = Color(0xFFE8B85C);

    // Mar oscuro.
    _pintarMarPuerto(canvas, size, lineaMuelle);

    // Grúas en el horizonte (siluetas verticales con líneas oblicuas).
    _pintarGrua(canvas, size, posicionX: size.width * 0.12, altura: 130, mira: 1);
    _pintarGrua(canvas, size, posicionX: size.width * 0.27, altura: 110, mira: -1);
    _pintarGrua(canvas, size, posicionX: size.width * 0.85, altura: 100, mira: -1);

    // Faro lejano: punto cálido pulsante con halo amplio en el horizonte.
    _pintarFaro(canvas, size, posicionX: size.width * 0.52, posicionY: size.height * 0.50, color: colorAmbarLejano);

    // Muelle de madera: banda horizontal con líneas verticales (postes).
    _pintarMuelle(canvas, size, lineaMuelle);

    // Algunos edificios bajos del puerto al fondo, casi siluetas.
    final pinturaEdificio = Paint()
      ..color = const Color(0xFF050810)
      ..style = PaintingStyle.fill;
    final tramos = [
      (cordX: -10.0, ancho: 80.0, alto: 50.0),
      (cordX: 70.0, ancho: 60.0, alto: 70.0),
      (cordX: 130.0, ancho: 90.0, alto: 45.0),
      (cordX: size.width * 0.65, ancho: 75.0, alto: 60.0),
      (cordX: size.width * 0.78, ancho: 55.0, alto: 80.0),
    ];
    for (final tramo in tramos) {
      final rect = Rect.fromLTWH(
        tramo.cordX,
        lineaMuelle - tramo.alto,
        tramo.ancho,
        tramo.alto,
      );
      canvas.drawRect(rect, pinturaEdificio);
      // Una o dos ventanas tenues, ámbar lejano.
      _pintarVentanasFabrica(canvas, rect, colorAmbarLejano.withOpacity(0.65));
    }
  }

  void _pintarMarPuerto(Canvas canvas, Size size, double lineaMuelle) {
    final rectMar = Rect.fromLTWH(0, lineaMuelle, size.width, size.height - lineaMuelle);
    final pinturaMar = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF02030A).withOpacity(0.95),
          const Color(0xFF010108),
        ],
      ).createShader(rectMar);
    canvas.drawRect(rectMar, pinturaMar);

    // Línea horizontal del horizonte casi imperceptible.
    final pinturaHorizonte = Paint()
      ..color = const Color(0xFF0E1A2E).withOpacity(0.55)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(0, lineaMuelle + 1),
      Offset(size.width, lineaMuelle + 1),
      pinturaHorizonte,
    );
  }

  void _pintarGrua(
    Canvas canvas,
    Size size, {
    required double posicionX,
    required double altura,
    required int mira, // 1 derecha, -1 izquierda
  }) {
    final lineaSuelo = size.height * 0.78;
    final pintura = Paint()
      ..color = const Color(0xFF12161E)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;

    // Mástil vertical.
    canvas.drawLine(
      Offset(posicionX, lineaSuelo),
      Offset(posicionX, lineaSuelo - altura),
      pintura,
    );
    // Brazo horizontal arriba con inclinación.
    final brazoLargo = altura * 0.55;
    final puntoFinalX = posicionX + mira * brazoLargo;
    final puntoFinalY = lineaSuelo - altura + 10;
    canvas.drawLine(
      Offset(posicionX, lineaSuelo - altura + 4),
      Offset(puntoFinalX, puntoFinalY),
      pintura,
    );
    // Cable vertical desde la punta del brazo.
    final pinturaCable = Paint()
      ..color = const Color(0xFF12161E)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(puntoFinalX, puntoFinalY),
      Offset(puntoFinalX, puntoFinalY + altura * 0.35),
      pinturaCable,
    );
    // Contrapeso pequeño en el extremo opuesto.
    canvas.drawLine(
      Offset(posicionX, lineaSuelo - altura + 4),
      Offset(posicionX - mira * brazoLargo * 0.25, lineaSuelo - altura + 12),
      pintura,
    );
    // Luz puntual roja apagada en la cabina (sutil).
    final pinturaLuz = Paint()
      ..color = PaletaNeon.rojoOxidado.withOpacity(0.55);
    canvas.drawCircle(
      Offset(posicionX + mira * 6, lineaSuelo - altura + 12),
      1.4,
      pinturaLuz,
    );
  }

  void _pintarFaro(
    Canvas canvas,
    Size size, {
    required double posicionX,
    required double posicionY,
    required Color color,
  }) {
    final pulso = math.sin(fasePulso * 2 * math.pi * 0.7) * 0.5 + 0.5;
    final pinturaHaloAmplio = Paint()
      ..color = color.withOpacity(0.18 * (0.5 + pulso * 0.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(Offset(posicionX, posicionY), 28, pinturaHaloAmplio);
    final pinturaHaloMedio = Paint()
      ..color = color.withOpacity(0.30 * (0.5 + pulso * 0.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(posicionX, posicionY), 10, pinturaHaloMedio);
    final pinturaPunto = Paint()..color = color.withOpacity(0.95);
    canvas.drawCircle(Offset(posicionX, posicionY), 2.4, pinturaPunto);
  }

  void _pintarMuelle(Canvas canvas, Size size, double lineaMuelle) {
    const altura = 8.0;
    final rectMuelle = Rect.fromLTWH(
      0,
      lineaMuelle - altura,
      size.width,
      altura,
    );
    final pinturaMuelle = Paint()..color = const Color(0xFF2E1F12);
    canvas.drawRect(rectMuelle, pinturaMuelle);
    // Postes verticales que se hunden en el agua.
    final pinturaPoste = Paint()
      ..color = const Color(0xFF1F1408)
      ..strokeWidth = 2.5;
    for (var cordX = 20.0; cordX < size.width; cordX += 38) {
      canvas.drawLine(
        Offset(cordX, lineaMuelle),
        Offset(cordX, lineaMuelle + 16),
        pinturaPoste,
      );
    }
  }

  // -------------------------------------------------------------------
  // AFUERAS — horizonte abierto, hierba al borde, Montaña dominante.
  // -------------------------------------------------------------------

  void _pintarBaseAfueras(Canvas canvas, Size size) {
    final lineaSuelo = size.height - 24;
    // Pocos edificios y muy bajos al horizonte (silueta de pueblo lejano).
    final pinturaEdificio = Paint()
      ..color = const Color(0xFF0E0A1E)
      ..style = PaintingStyle.fill;
    final tramos = [
      (cordX: size.width * 0.06, ancho: 35.0, alto: 22.0),
      (cordX: size.width * 0.13, ancho: 28.0, alto: 30.0),
      (cordX: size.width * 0.20, ancho: 40.0, alto: 18.0),
      (cordX: size.width * 0.74, ancho: 30.0, alto: 25.0),
      (cordX: size.width * 0.82, ancho: 36.0, alto: 32.0),
    ];
    const colorVelaTenue = Color(0xFFE8C868);
    for (var indice = 0; indice < tramos.length; indice++) {
      final tramo = tramos[indice];
      final rect = Rect.fromLTWH(
        tramo.cordX,
        lineaSuelo - tramo.alto,
        tramo.ancho,
        tramo.alto + 24,
      );
      canvas.drawRect(rect, pinturaEdificio);
      // Una sola ventana ámbar tenue por edificio.
      final pinturaVentana = Paint()..color = colorVelaTenue.withOpacity(0.50);
      canvas.drawRect(
        Rect.fromLTWH(rect.left + rect.width * 0.4, rect.top + 4, 3, 4),
        pinturaVentana,
      );
    }

    // Banda de hierba al borde inferior.
    _pintarHierba(canvas, size, lineaSuelo);

    // Observatorio: pequeña cúpula con telescopio en el horizonte
    // (referencia doc 11: stone observatory).
    _pintarObservatorio(canvas, size, lineaSuelo);
  }

  void _pintarHierba(Canvas canvas, Size size, double lineaSuelo) {
    // Banda de hierba: muchas líneas finas verticales con leve oscilación.
    final generador = math.Random(29);
    final pinturaHierba = Paint()
      ..color = const Color(0xFF2A3528).withOpacity(0.65)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var indice = 0; indice < 120; indice++) {
      final cordX = generador.nextDouble() * size.width;
      final altura = 4.0 + generador.nextDouble() * 8;
      final fase = generador.nextDouble() * math.pi * 2;
      final desviacion = math.sin(fasePulso * 2 * math.pi + fase) * 1.3;
      canvas.drawLine(
        Offset(cordX, lineaSuelo + 16),
        Offset(cordX + desviacion, lineaSuelo + 16 - altura),
        pinturaHierba,
      );
    }
    // Banda oscura del suelo (tierra) bajo la hierba.
    final pinturaSuelo = Paint()..color = const Color(0xFF15121F).withOpacity(0.85);
    canvas.drawRect(
      Rect.fromLTWH(0, lineaSuelo + 14, size.width, size.height - lineaSuelo - 14),
      pinturaSuelo,
    );
  }

  void _pintarObservatorio(Canvas canvas, Size size, double lineaSuelo) {
    final cordX = size.width * 0.45;
    final cordY = lineaSuelo - 18;
    // Base rectangular.
    final pinturaBase = Paint()..color = const Color(0xFF1A1428);
    canvas.drawRect(
      Rect.fromLTWH(cordX - 14, cordY, 28, 18),
      pinturaBase,
    );
    // Cúpula (medio círculo).
    final pinturaCupula = Paint()..color = const Color(0xFF221A35);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cordX, cordY), radius: 14),
      math.pi,
      math.pi,
      false,
      pinturaCupula,
    );
    // Rendija de la cúpula.
    final pinturaRendija = Paint()
      ..color = const Color(0xFFE8C868).withOpacity(0.45)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(cordX - 4, cordY - 14),
      Offset(cordX + 4, cordY - 14),
      pinturaRendija,
    );
  }

  // -------------------------------------------------------------------
  // PRIMITIVAS COMPARTIDAS
  // -------------------------------------------------------------------

  void _pintarVentanasCalidas(
    Canvas canvas,
    Rect edificio,
    int semilla,
    Color colorBase,
  ) {
    final generadorPosicion = math.Random(semilla * 17 + 3);
    final generadorIntensidad = math.Random(semilla * 41 + 7);
    final pinturaVentana = Paint();
    const tamanoVentana = 3.5;
    const margen = 6.0;
    final umbralEncendido = 0.22 + nivelRestauracion * 0.48;

    for (var cordY = edificio.top + 12;
        cordY < edificio.bottom - margen;
        cordY += 10) {
      for (var cordX = edificio.left + margen;
          cordX < edificio.right - margen;
          cordX += 8) {
        final semillaPosicion = generadorPosicion.nextDouble();
        final intensidadBase = generadorIntensidad.nextDouble();
        if (semillaPosicion < umbralEncendido) {
          pinturaVentana.color = colorBase
              .withOpacity((0.4 + intensidadBase * 0.5).clamp(0.0, 1.0));
          canvas.drawRect(
            Rect.fromLTWH(cordX, cordY, tamanoVentana, tamanoVentana),
            pinturaVentana,
          );
        }
      }
    }
  }

  void _pintarSueloMojado(Canvas canvas, Size size, double lineaSuelo) {
    final intensidad = ambiente.intensidadLluvia.clamp(0.0, 1.0);
    final rectSuelo = Rect.fromLTRB(0, lineaSuelo - 6, size.width, size.height);
    final pinturaSuelo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PaletaNeon.azulNeon.withOpacity(0.0),
          PaletaNeon.azulNeon.withOpacity(0.18 * intensidad),
        ],
      ).createShader(rectSuelo);
    canvas.drawRect(rectSuelo, pinturaSuelo);
  }

  @override
  bool shouldRepaint(covariant PintorEscenario oldDelegate) {
    return oldDelegate.fasePulso != fasePulso ||
        oldDelegate.fasePulsoLluvia != fasePulsoLluvia ||
        oldDelegate.nivelRestauracion != nivelRestauracion ||
        oldDelegate.ambiente != ambiente ||
        oldDelegate.idDistrito != idDistrito ||
        !setEquals(oldDelegate.piezasRestauradas, piezasRestauradas);
  }
}
