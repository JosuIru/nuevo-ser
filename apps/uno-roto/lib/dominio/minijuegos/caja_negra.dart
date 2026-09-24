import 'dart:math' as math;

/// La caja negra (segunda sala de Rexán): una caja de la Montaña traga
/// números y escupe otros. Si adivinas su regla, se abre.
///
/// - Se ven dos filas de la tabla y se puede experimentar con los números
///   del 1 al 10 (pocos experimentos). La pregunta es siempre por un
///   número del 11 al 20: no se puede probar, hay que haber entendido la
///   regla (FUN.01).
/// 1. Una operación: +k, ×k, −k.
/// 2. Dos pasos: a·x + b.
/// 3. Al revés («ha salido 17, ¿qué entró?») y Las gemelas: dos sacos y
///    dos balanzas, un sistema 2×2 (ALG.03).
///
/// Los Mudos (el monstruo): algún número de la fila se lo traga sin
/// devolver nada. Gasta un experimento; no es un error.
enum TipoCaja { directa, inversa, gemelas }

class Regla {
  final int a;
  final int b;

  const Regla(this.a, this.b);

  int aplicar(int x) => a * x + b;
}

class RetoCaja {
  final TipoCaja tipo;
  final Regla regla;

  /// Filas conocidas de entrada (las salidas salen de la regla).
  final List<int> filasIniciales;

  /// Números que se pueden meter para experimentar.
  final List<int> probables;

  /// Número que se traga (Mudo), o null.
  final int? mudo;

  final int experimentos;

  /// Directa: el que entra. Inversa: el que sale. Gemelas: suma.
  final int dato;

  /// Gemelas: la diferencia (rojo − azul).
  final int? dato2;

  final int respuesta;
  final List<int> opciones;

  const RetoCaja({
    required this.tipo,
    required this.regla,
    required this.filasIniciales,
    required this.probables,
    required this.experimentos,
    required this.dato,
    required this.respuesta,
    required this.opciones,
    this.mudo,
    this.dato2,
  });

  String get idHabilidad => tipo == TipoCaja.gemelas ? 'ALG.03' : 'FUN.01';
}

class GeneradorCaja {
  final math.Random _azar;

  GeneradorCaja({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoCaja generar(TipoCaja tipo, {required int nivel, int dificultad = 1}) {
    if (tipo == TipoCaja.gemelas) return _gemelas(dificultad);
    final regla = nivel <= 1 ? _reglaSimple() : _reglaDosPasos(dificultad);
    // Se empieza donde la salida ya es positiva (reglas con resta).
    var minimo = 1;
    while (regla.aplicar(minimo) < 1) {
      minimo++;
    }
    final probables = [for (var x = minimo; x < minimo + 10; x++) x];
    final iniciales = ([...probables]..shuffle(_azar)).take(2).toList()..sort();
    final mudo = dificultad >= 2
        ? (probables.where((x) => !iniciales.contains(x)).toList()..shuffle(_azar)).first
        : null;
    final experimentos = switch (dificultad) { 1 => 4, 2 => 3, _ => 2 };
    final n = _entre(minimo + 10, minimo + 19);
    if (tipo == TipoCaja.directa) {
      final respuesta = regla.aplicar(n);
      // Errores típicos: la diferencia de la primera fila como si fuera
      // "+algo", olvidar el segundo paso, uno de más.
      final primera = iniciales.first;
      final falsaSuma = n + (regla.aplicar(primera) - primera);
      return RetoCaja(
        tipo: tipo,
        regla: regla,
        filasIniciales: iniciales,
        probables: probables,
        mudo: mudo,
        experimentos: experimentos,
        dato: n,
        respuesta: respuesta,
        opciones: _opciones(respuesta, [falsaSuma, regla.a * n, respuesta + regla.a, respuesta - 1]),
      );
    }
    final salida = regla.aplicar(n);
    return RetoCaja(
      tipo: TipoCaja.inversa,
      regla: regla,
      filasIniciales: iniciales,
      probables: probables,
      mudo: mudo,
      experimentos: experimentos,
      dato: salida,
      respuesta: n,
      opciones: _opciones(n, [
        salida - regla.b, // restó pero no dividió
        if (regla.a != 0 && salida % regla.a == 0) salida ~/ regla.a, // dividió sin restar
        regla.aplicar(salida), // la aplicó hacia delante
        n + 1,
      ]),
    );
  }

  Regla _reglaSimple() => switch (_azar.nextInt(3)) {
        0 => Regla(1, _entre(2, 9)),
        1 => Regla(_entre(2, 5), 0),
        _ => Regla(1, -_entre(1, 3)),
      };

  Regla _reglaDosPasos(int dificultad) =>
      Regla(_entre(2, dificultad >= 3 ? 6 : 4), _entre(1, 9) * (dificultad >= 3 && _azar.nextBool() ? -1 : 1));

  /// Dos sacos: rojo + azul = S y rojo − azul = D (dificultad 3: dos
  /// rojos + azul). ¿Cuánto pesa el rojo?
  RetoCaja _gemelas(int dificultad) {
    final azul = _entre(1, 9);
    final rojo = azul + _entre(1, 8);
    final dosRojos = dificultad >= 3;
    final suma = (dosRojos ? 2 * rojo : rojo) + azul;
    final diferencia = rojo - azul;
    return RetoCaja(
      tipo: TipoCaja.gemelas,
      regla: Regla(dosRojos ? 2 : 1, 0),
      filasIniciales: const [],
      probables: const [],
      experimentos: 0,
      dato: suma,
      dato2: diferencia,
      respuesta: rojo,
      opciones: _opciones(rojo, [
        azul, // el otro saco
        suma - diferencia, // restar sin repartir
        (suma + diferencia) ~/ 2 == rojo ? suma ~/ 2 : (suma + diferencia) ~/ 2,
        rojo + 1,
      ]),
    );
  }

  List<int> _opciones(int respuesta, List<int> errores) {
    final elegidas = <int>{respuesta};
    for (final error in errores) {
      if (elegidas.length == 4) break;
      if (error > 0) elegidas.add(error);
    }
    var desfase = 2;
    while (elegidas.length < 4) {
      final vecino = respuesta + (desfase.isEven ? desfase : -desfase);
      if (vecino > 0) elegidas.add(vecino);
      desfase++;
    }
    return elegidas.toList()..shuffle(_azar);
  }
}
