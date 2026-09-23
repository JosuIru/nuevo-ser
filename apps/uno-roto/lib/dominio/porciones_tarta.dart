import 'dart:math' as math;

/// Lógica pura de "cortar la tarta" (doc 16, eje A — verbo
/// manipulativo para FR.07): la tarta está partida en [denominador]
/// trozos iguales y el niño la sirve pasando el dedo alrededor,
/// empezando arriba (las 12) y en el sentido de las agujas del reloj.
///
/// Devuelve cuántos trozos quedan servidos para un [anguloRecorrido]
/// en radianes desde las 12. Redondea al trozo más cercano — el dedo no
/// es preciso y el niño piensa en trozos, no en grados — y queda entre
/// 0 y [denominador].
int porcionesServidas(double anguloRecorrido, int denominador) {
  if (denominador <= 0) return 0;
  final vueltaCompleta = 2 * math.pi;
  final fraccionDeVuelta = (anguloRecorrido / vueltaCompleta).clamp(0.0, 1.0);
  return (fraccionDeVuelta * denominador).round().clamp(0, denominador);
}

/// Ángulo (radianes, desde las 12 en sentido horario, en [0, 2π)) del
/// punto [dx],[dy] relativo al centro de la tarta. Pantalla: y crece
/// hacia abajo.
double anguloDesdeLasDoce(double dx, double dy) {
  final angulo = math.atan2(dx, -dy);
  return angulo < 0 ? angulo + 2 * math.pi : angulo;
}

/// Sigue al dedo alrededor de la tarta: lo servido llega hasta donde
/// está el dedo (lo natural para un niño: "hasta aquí"), no se suma
/// gesto a gesto. La única excepción es cruzar las 12: si la tarta está
/// casi llena y el dedo sigue en sentido horario, se queda llena; si
/// está casi vacía y el dedo retrocede, se queda vacía. Así no salta de
/// llena a vacía (ni al revés) por pasar por arriba.
class RecorridoTarta {
  double _anguloServido = 0;
  double? _ultimoAngulo;

  double get anguloAcumulado => _anguloServido;

  static const _vuelta = 2 * math.pi;

  /// Empieza un gesto: todavía no cambia lo servido.
  void empezar(double angulo) => _ultimoAngulo = angulo;

  void mover(double angulo) {
    final anterior = _ultimoAngulo;
    _ultimoAngulo = angulo;
    if (anterior != null) {
      var giro = angulo - anterior;
      if (giro > math.pi) giro -= _vuelta;
      if (giro < -math.pi) giro += _vuelta;
      final cruzaLasDoceHaciaDelante =
          giro > 0 && anterior > angulo; // p. ej. 350° → 10°
      final cruzaLasDoceHaciaAtras =
          giro < 0 && anterior < angulo; // p. ej. 10° → 350°
      if (cruzaLasDoceHaciaDelante && _anguloServido > _vuelta / 2) {
        _anguloServido = _vuelta;
        return;
      }
      if (cruzaLasDoceHaciaAtras && _anguloServido < _vuelta / 2) {
        _anguloServido = 0;
        return;
      }
      // Tras quedarse llena o vacía, sólo se mueve cuando el dedo
      // vuelve a su lado de las 12.
      if (_anguloServido == _vuelta && angulo < math.pi) return;
      if (_anguloServido == 0 && angulo > math.pi && giro < 0) return;
    }
    _anguloServido = angulo;
  }

  void terminar() => _ultimoAngulo = null;

  /// Deja servidos exactamente [porciones] trozos de [denominador]
  /// (para demos y pistas).
  void fijarPorciones(int porciones, int denominador) {
    _anguloServido = _vuelta * porciones / denominador;
  }
}
