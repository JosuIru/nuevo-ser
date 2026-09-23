import 'dart:math' as math;

/// Balanza (máquina de Rexán): la ecuación es una balanza. A la
/// izquierda, [bolsasIzquierda] bolsas de x y [pesasIzquierda] pesas
/// sueltas; a la derecha, lo mismo con sus números. El niño propone un
/// valor de x, pesa y ve hacia dónde se inclina. El primer "pesar" de
/// cada ecuación es el que cuenta para la maestría.
///
/// ALG.01: a·x + b = c (sin bolsas a la derecha).
/// ALG.02: a·x + b = d·x + e (bolsas en los dos lados).
class EcuacionBalanza {
  final String idHabilidad;
  final int bolsasIzquierda;
  final int pesasIzquierda;
  final int bolsasDerecha;
  final int pesasDerecha;
  final int solucion;

  const EcuacionBalanza({
    required this.idHabilidad,
    required this.bolsasIzquierda,
    required this.pesasIzquierda,
    required this.bolsasDerecha,
    required this.pesasDerecha,
    required this.solucion,
  });

  int izquierda(int x) => bolsasIzquierda * x + pesasIzquierda;
  int derecha(int x) => bolsasDerecha * x + pesasDerecha;

  /// Negativo: baja la izquierda (pesa más). 0: equilibrio.
  int inclinacion(int x) => derecha(x) - izquierda(x);

  String get texto {
    String lado(int bolsas, int pesas) {
      final partes = [
        if (bolsas > 0) bolsas == 1 ? 'x' : '${bolsas}x',
        if (pesas > 0 || bolsas == 0) '$pesas',
      ];
      return partes.join(' + ');
    }

    return '${lado(bolsasIzquierda, pesasIzquierda)} = '
        '${lado(bolsasDerecha, pesasDerecha)}';
  }
}

class GeneradorBalanza {
  final math.Random _azar;

  GeneradorBalanza({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  /// [dificultad] 1-3; [extra] (niveles altos) agranda aún más los
  /// números. La x nunca pasa de 20: el selector llega a 30.
  EcuacionBalanza generar(String idHabilidad, {int dificultad = 1, int extra = 0}) {
    final x = _entre(1, switch (dificultad) { 1 => 8, 2 => 12, _ => 15 } + 3 * extra)
        .clamp(1, 20);
    if (idHabilidad == 'ALG.02') {
      final d = _entre(1, dificultad >= 3 ? 4 : 3);
      final a = d + _entre(1, 3); // a > d: x sale positiva
      final b = _entre(0, dificultad >= 3 ? 15 : 10);
      final e = (a - d) * x + b;
      return EcuacionBalanza(
        idHabilidad: 'ALG.02',
        bolsasIzquierda: a,
        pesasIzquierda: b,
        bolsasDerecha: d,
        pesasDerecha: e,
        solucion: x,
      );
    }
    final a = _entre(1, switch (dificultad) { 1 => 3, 2 => 5, _ => 6 });
    final b = _entre(0, switch (dificultad) { 1 => 9, 2 => 15, _ => 20 });
    return EcuacionBalanza(
      idHabilidad: 'ALG.01',
      bolsasIzquierda: a,
      pesasIzquierda: b,
      bolsasDerecha: 0,
      pesasDerecha: a * x + b,
      solucion: x,
    );
  }
}
