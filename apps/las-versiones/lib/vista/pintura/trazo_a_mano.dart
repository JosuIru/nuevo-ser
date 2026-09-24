import 'dart:math';
import 'dart:ui';

/// Herramientas de dibujo «pintado a mano» (doc 11 §1.1.1): nada de
/// líneas rectas perfectas ni superficies planas. Todo es
/// determinista con semilla, así que un objeto se dibuja siempre
/// igual y no «tiembla» al repintar.

/// Línea que pasa por [puntos] con un temblor suave de pulso humano.
/// [amplitud] en píxeles; con 0 sale la poligonal exacta.
Path trazoAMano(List<Offset> puntos, {int semilla = 0, double amplitud = 1.2}) {
  final camino = Path();
  if (puntos.isEmpty) return camino;
  final azar = Random(semilla);
  camino.moveTo(puntos.first.dx, puntos.first.dy);
  for (var i = 1; i < puntos.length; i++) {
    final desde = puntos[i - 1];
    final hasta = puntos[i];
    final longitud = (hasta - desde).distance;
    final pasos = max(2, (longitud / 14).round());
    final normal = longitud == 0
        ? Offset.zero
        : Offset(-(hasta.dy - desde.dy), hasta.dx - desde.dx) / longitud;
    for (var paso = 1; paso <= pasos; paso++) {
      final t = paso / pasos;
      final punto = Offset.lerp(desde, hasta, t)!;
      // Sin temblor en el extremo: las esquinas se cierran donde deben.
      final temblor = paso == pasos ? 0.0 : (azar.nextDouble() * 2 - 1) * amplitud;
      final destino = punto + normal * temblor;
      camino.lineTo(destino.dx, destino.dy);
    }
  }
  return camino;
}

/// Contorno de un rectángulo dibujado a mano.
Path rectanguloAMano(Rect rectangulo, {int semilla = 0, double amplitud = 1.2}) {
  return trazoAMano([
    rectangulo.topLeft,
    rectangulo.topRight,
    rectangulo.bottomRight,
    rectangulo.bottomLeft,
    rectangulo.topLeft,
  ], semilla: semilla, amplitud: amplitud)
    ..close();
}

/// Lados de un papel que pueden estar rasgados.
enum LadoPapel { arriba, derecha, abajo, izquierda }

/// Silueta de un papel con los [ladosRasgados] irregulares (paseo
/// aleatorio con semilla) y los demás rectos a mano. [profundidad] es
/// cuánto entra el rasgado hacia dentro, en píxeles.
Path papelRasgado(
  Rect rectangulo, {
  Set<LadoPapel> ladosRasgados = const {LadoPapel.abajo},
  int semilla = 0,
  double profundidad = 6,
}) {
  final azar = Random(semilla);
  final esquinas = [
    rectangulo.topLeft,
    rectangulo.topRight,
    rectangulo.bottomRight,
    rectangulo.bottomLeft,
  ];
  final camino = Path()..moveTo(esquinas[0].dx, esquinas[0].dy);
  for (var indice = 0; indice < 4; indice++) {
    final lado = LadoPapel.values[indice];
    final desde = esquinas[indice];
    final hasta = esquinas[(indice + 1) % 4];
    final longitud = (hasta - desde).distance;
    final direccion = (hasta - desde) / longitud;
    // Normal hacia dentro del rectángulo (recorrido en sentido horario).
    final haciaDentro = Offset(-direccion.dy, direccion.dx);
    if (!ladosRasgados.contains(lado)) {
      for (var paso = 1; paso <= 6; paso++) {
        final punto = Offset.lerp(desde, hasta, paso / 6)!;
        final temblor = paso == 6 ? 0.0 : (azar.nextDouble() * 2 - 1) * 0.8;
        final destino = punto + haciaDentro * temblor;
        camino.lineTo(destino.dx, destino.dy);
      }
      continue;
    }
    var entrada = profundidad / 2;
    var recorrido = 0.0;
    while (recorrido < longitud) {
      recorrido = min(longitud, recorrido + 2 + azar.nextDouble() * 5);
      // Paseo aleatorio acotado: el borde nunca sale del papel ni se
      // come más de [profundidad].
      entrada = (entrada + (azar.nextDouble() * 2 - 1) * profundidad * 0.45)
          .clamp(0.0, profundidad);
      final enElExtremo = recorrido >= longitud;
      final punto = desde +
          direccion * recorrido +
          haciaDentro * (enElExtremo ? 0.0 : entrada);
      camino.lineTo(punto.dx, punto.dy);
    }
  }
  return camino..close();
}

/// Grano de papel: motas y fibras cortas semitransparentes dentro de
/// [rectangulo]. [densidad] = motas por cada 1000 px².
void pintarGrano(
  Canvas lienzo,
  Rect rectangulo, {
  required Color color,
  int semilla = 0,
  double densidad = 1.2,
}) {
  final azar = Random(semilla);
  final cantidad = (rectangulo.width * rectangulo.height / 1000 * densidad).round();
  final pincel = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  for (var i = 0; i < cantidad; i++) {
    final punto = Offset(
      rectangulo.left + azar.nextDouble() * rectangulo.width,
      rectangulo.top + azar.nextDouble() * rectangulo.height,
    );
    pincel.color = color.withValues(alpha: 0.03 + azar.nextDouble() * 0.07);
    if (azar.nextDouble() < 0.18) {
      // Fibra: trazo corto con ángulo al azar.
      final angulo = azar.nextDouble() * pi;
      final largo = 2 + azar.nextDouble() * 6;
      pincel.strokeWidth = 0.6;
      lienzo.drawLine(
          punto, punto + Offset(cos(angulo), sin(angulo)) * largo, pincel);
    } else {
      pincel.strokeWidth = 0.8 + azar.nextDouble() * 1.4;
      lienzo.drawPoints(PointMode.points, [punto], pincel);
    }
  }
}
