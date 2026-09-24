import 'dart:math' as math;

/// Retos de cálculo con respuesta entera y distractores que son los
/// errores típicos de cada habilidad (no números al azar): así elegir
/// mal dice algo de lo que el niño aún confunde. Los usan Serpiente
/// (varios números en el tablero) y La flota (coordenadas cantadas).
class RetoCalculo {
  final String idHabilidad;
  final String enunciado;
  final int respuesta;
  final List<int> distractores;

  const RetoCalculo({
    required this.idHabilidad,
    required this.enunciado,
    required this.respuesta,
    required this.distractores,
  });
}

const habilidadesConRetoCalculo = {'ARI.01', 'OP.01', 'ARI.02', 'FR.22', 'PROP.04', 'ARI.04', 'OP.02', 'OP.03'};

/// -3 → "−3": el signo menos tipográfico, como en El pozo.
String conSignoMenos(int valor) => valor < 0 ? '−${-valor}' : '$valor';

class GeneradorRetosCalculo {
  final math.Random _azar;

  GeneradorRetosCalculo({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoCalculo generar(String idHabilidad, {int dificultad = 1}) {
    switch (idHabilidad) {
      case 'OP.01':
        return _jerarquia(dificultad);
      case 'ARI.02':
        return _potencia(dificultad);
      case 'FR.22':
        return _fraccionDeCantidad(dificultad);
      case 'PROP.04':
        return _porcentaje(dificultad);
      case 'ARI.04':
        return _conSigno(dificultad);
      case 'OP.02':
        return _jerarquiaConFraccion(dificultad);
      case 'OP.03':
        return _jerarquiaConDecimal(dificultad);
      default:
        return _suma(dificultad);
    }
  }

  RetoCalculo _suma(int dificultad) {
    final maximo = [10, 30, 60][dificultad.clamp(1, 3) - 1];
    final a = _entre(2, maximo);
    final b = _entre(2, maximo);
    return _reto('ARI.01', '$a + $b', a + b, [a + b + 1, a + b - 1, a + b + 10]);
  }

  RetoCalculo _jerarquia(int dificultad) {
    final a = _entre(2, 9);
    final b = _entre(2, 9);
    final c = _entre(2, dificultad >= 2 ? 9 : 5);
    if (dificultad >= 2 && _azar.nextBool()) {
      // (a + b) × c: el error típico es olvidar el paréntesis.
      return _reto('OP.01', '($a + $b) × $c', (a + b) * c,
          [a + b * c, (a + b) * c + c, a * c + b]);
    }
    // a + b × c: el error típico es operar de izquierda a derecha.
    return _reto('OP.01', '$a + $b × $c', a + b * c,
        [(a + b) * c, a * b + c, a + b + c]);
  }

  RetoCalculo _potencia(int dificultad) {
    final base = _entre(2, dificultad >= 2 ? 6 : 4);
    final exponente = dificultad >= 3 ? _entre(2, 3) : 2;
    final valor = math.pow(base, exponente).toInt();
    final superindice = exponente == 2 ? '²' : '³';
    // Error típico: base × exponente.
    return _reto('ARI.02', '$base$superindice', valor,
        [base * exponente, valor + base, base + exponente]);
  }

  RetoCalculo _fraccionDeCantidad(int dificultad) {
    final denominador = [2, 3, 4, 5][_azar.nextInt(dificultad >= 2 ? 4 : 2)];
    final numerador = _entre(1, denominador - 1);
    final cantidad = denominador * _entre(2, dificultad >= 2 ? 8 : 5);
    final respuesta = cantidad * numerador ~/ denominador;
    // Error típico: quedarse en cantidad ÷ denominador.
    return _reto('FR.22', '$numerador/$denominador de $cantidad', respuesta,
        [cantidad ~/ denominador, cantidad - respuesta, respuesta + numerador]);
  }

  RetoCalculo _porcentaje(int dificultad) {
    final porcentajes = dificultad >= 2 ? [10, 20, 25, 50, 75] : [10, 50];
    final porcentaje = porcentajes[_azar.nextInt(porcentajes.length)];
    final paso = 100 ~/ _mcd(porcentaje, 100);
    final cantidad = paso * _entre(1, dificultad >= 2 ? 6 : 4);
    final respuesta = cantidad * porcentaje ~/ 100;
    return _reto('PROP.04', '$porcentaje % de $cantidad', respuesta,
        [cantidad - respuesta, porcentaje, respuesta * 2]);
  }

  /// Sumas y restas que cruzan el cero: −3 + 5, 4 − 9, −2 − 6. Los
  /// errores típicos son perder el signo y restar en vez de sumar.
  RetoCalculo _conSigno(int dificultad) {
    final maximo = [9, 15, 25][dificultad.clamp(1, 3) - 1];
    final a = _entre(1, maximo);
    final b = _entre(1, maximo);
    switch (_azar.nextInt(dificultad == 1 ? 2 : 3)) {
      case 0:
        // a − b con b > a: se baja por debajo de cero.
        final (menor, mayor) = a == b ? (a, a + 2) : (math.min(a, b), math.max(a, b));
        return _reto('ARI.04', '$menor − $mayor', menor - mayor,
            [mayor - menor, menor + mayor, menor - mayor - 1], conNegativos: true);
      case 1:
        // −a + b.
        return _reto('ARI.04', '−$a + $b', b - a, [a - b, -(a + b), a + b], conNegativos: true);
      default:
        // −a − b.
        return _reto('ARI.04', '−$a − $b', -(a + b), [a + b, b - a, a - b], conNegativos: true);
    }
  }

  /// Jerarquía con una fracción y resultado entero: "3 + 2/5 × 10" o
  /// "12 × 3/4 − 5". El error típico es operar de izquierda a derecha u
  /// olvidar dividir entre el denominador.
  RetoCalculo _jerarquiaConFraccion(int dificultad) {
    final denominador = [2, 3, 4, 5][_azar.nextInt(dificultad >= 2 ? 4 : 2)];
    final numerador = _entre(1, denominador - 1);
    final factor = denominador * _entre(2, dificultad >= 2 ? 5 : 3);
    final producto = numerador * factor ~/ denominador;
    final fraccion = '$numerador/$denominador';
    if (_azar.nextBool() || producto <= 2) {
      final a = _entre(2, 9);
      return _reto('OP.02', '$a + $fraccion × $factor', a + producto,
          [a * factor + producto, a + numerador * factor, a + factor ~/ denominador]);
    }
    final b = _entre(1, producto - 1);
    return _reto('OP.02', '$factor × $fraccion − $b', producto - b,
        [numerador * factor - b, producto + b, factor - b]);
  }

  /// Jerarquía con un decimal y resultado entero: "4 + 2,5 × 2" o
  /// "20 − 1,5 × 4". Errores: de izquierda a derecha y leer el decimal
  /// sin la coma.
  RetoCalculo _jerarquiaConDecimal(int dificultad) {
    final decimas = [5, 15, 25, 2, 4, 12][_azar.nextInt(dificultad >= 2 ? 6 : 3)];
    // Un factor que deja el producto entero.
    final paso = 10 ~/ _mcd(decimas, 10);
    final factor = paso * _entre(1, dificultad >= 2 ? 4 : 2);
    final producto = decimas * factor ~/ 10;
    final decimal = '${decimas ~/ 10},${decimas % 10}';
    final a = _entre(2, 9);
    if (_azar.nextBool()) {
      return _reto('OP.03', '$a + $decimal × $factor', a + producto,
          [(a * 10 + decimas) * factor ~/ 10, a + decimas * factor, a + factor]);
    }
    final total = producto + a;
    return _reto('OP.03', '$total − $decimal × $factor', a,
        [(total * 10 - decimas) * factor ~/ 10, total + producto, total - factor]);
  }

  static int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);

  RetoCalculo _reto(String id, String enunciado, int respuesta, List<int> errores,
      {bool conNegativos = false}) {
    // Distractores distintos, positivos y distintos de la respuesta; si
    // un error típico coincide, se completa con vecinos cercanos.
    final distractores = <int>{};
    for (final valor in errores) {
      if ((conNegativos || valor > 0) && valor != respuesta) distractores.add(valor);
    }
    var desfase = 2;
    while (distractores.length < 3) {
      final vecino = respuesta + (desfase.isEven ? desfase ~/ 2 : -(desfase ~/ 2));
      if ((conNegativos || vecino > 0) && vecino != respuesta) distractores.add(vecino);
      desfase++;
    }
    return RetoCalculo(
      idHabilidad: id,
      enunciado: enunciado,
      respuesta: respuesta,
      distractores: distractores.take(3).toList(),
    );
  }
}
