import 'dart:math' as math;

import '../problema_espejo.dart' show Fraccion;

/// Puentes (máquina de Rexán): cubrir un hueco con tablones cuya suma
/// sea EXACTA. Si falta, el carro se para en el borde; si sobra, el
/// tablón no encaja. Ejercita la suma de fracciones (FR.14 mismo
/// denominador, FR.16 distinto) y de decimales (DEC.04).
///
/// El puente roto (FR.15, FR.17): el puente sale montado con todos los
/// tablones y sobra un trozo. Hay que quitar justo lo que sobra: el
/// largo del puente menos el del hueco.
enum ModoPuente {
  mismoDenominador,
  distintoDenominador,
  decimales,
  restaMismoDenominador,
  restaDistintoDenominador,
}

extension ModoPuenteHabilidad on ModoPuente {
  String get idHabilidad => switch (this) {
        ModoPuente.mismoDenominador => 'FR.14',
        ModoPuente.distintoDenominador => 'FR.16',
        ModoPuente.decimales => 'DEC.04',
        ModoPuente.restaMismoDenominador => 'FR.15',
        ModoPuente.restaDistintoDenominador => 'FR.17',
      };

  /// El puente roto: se empieza con todo montado y se quitan tablones.
  bool get esResta =>
      this == ModoPuente.restaMismoDenominador || this == ModoPuente.restaDistintoDenominador;

  static ModoPuente? paraHabilidad(String idHabilidad) => switch (idHabilidad) {
        'FR.14' => ModoPuente.mismoDenominador,
        'FR.16' => ModoPuente.distintoDenominador,
        'DEC.04' => ModoPuente.decimales,
        'FR.15' => ModoPuente.restaMismoDenominador,
        'FR.17' => ModoPuente.restaDistintoDenominador,
        _ => null,
      };
}

enum ResultadoPuente { vacio, corto, exacto, largo }

class RetoPuente {
  final ModoPuente modo;
  final Fraccion hueco;

  /// Tablones disponibles (solución + distractores), ya barajados.
  final List<Fraccion> tablones;

  /// Una combinación que resuelve el reto (para pistas y tests).
  final List<Fraccion> solucion;

  const RetoPuente({
    required this.modo,
    required this.hueco,
    required this.tablones,
    required this.solucion,
  });

  /// Cómo se escribe una medida en este reto: fracción o decimal con
  /// coma ("1,2").
  String etiqueta(Fraccion medida) => modo == ModoPuente.decimales
      ? etiquetaDecimal(medida)
      : medida.etiqueta;
}

String etiquetaDecimal(Fraccion medida) {
  final cifras = medida.denominador == 100 ? 2 : 1;
  return medida.valor.toStringAsFixed(cifras).replaceAll('.', ',');
}

int _mcd(int a, int b) => b == 0 ? a.abs() : _mcd(b, a % b);
int _mcm(int a, int b) => a ~/ _mcd(a, b) * b;

/// Suma exacta de fracciones, simplificada.
Fraccion sumaExacta(Iterable<Fraccion> sumandos) {
  var numerador = 0;
  var denominador = 1;
  for (final sumando in sumandos) {
    final comun = _mcm(denominador, sumando.denominador);
    numerador = numerador * (comun ~/ denominador) +
        sumando.numerador * (comun ~/ sumando.denominador);
    denominador = comun;
  }
  final divisor = _mcd(numerador, denominador);
  return divisor == 0
      ? const Fraccion(0, 1)
      : Fraccion(numerador ~/ divisor, denominador ~/ divisor);
}

ResultadoPuente probarPuente(Fraccion hueco, List<Fraccion> colocados) {
  if (colocados.isEmpty) return ResultadoPuente.vacio;
  final total = sumaExacta(colocados);
  final diferencia = total.numerador * hueco.denominador -
      hueco.numerador * total.denominador;
  if (diferencia == 0) return ResultadoPuente.exacto;
  return diferencia < 0 ? ResultadoPuente.corto : ResultadoPuente.largo;
}

class GeneradorPuentes {
  final math.Random _azar;

  GeneradorPuentes({int? semilla}) : _azar = math.Random(semilla);

  /// [dificultad] 1-3: más tablones en la solución y más distractores.
  /// [extra]: tablones distractores de más (niveles altos).
  RetoPuente generar(ModoPuente modo, {int dificultad = 1, int extra = 0}) {
    if (modo.esResta) return _puenteRoto(modo, dificultad);
    final piezasSolucion = dificultad >= 3 ? 3 : 2;
    final distractores = 1 + dificultad + extra;
    final solucion = switch (modo) {
      ModoPuente.mismoDenominador => _solucionMismoDenominador(piezasSolucion),
      ModoPuente.distintoDenominador =>
        _solucionDistintoDenominador(piezasSolucion, dificultad),
      ModoPuente.decimales => _solucionDecimales(piezasSolucion, dificultad),
      ModoPuente.restaMismoDenominador || ModoPuente.restaDistintoDenominador =>
        throw StateError('el puente roto se genera aparte'),
    };
    final hueco = modo == ModoPuente.decimales
        ? _enDecimos(sumaExacta(solucion), solucion.first.denominador)
        : sumaExacta(solucion);
    final tablones = [...solucion];
    var intentos = 0;
    while (tablones.length < solucion.length + distractores && intentos < 200) {
      intentos++;
      final candidato = _distractor(modo, solucion, dificultad);
      // Un distractor que sea por sí solo el hueco resolvería el reto
      // con un tablón: fuera.
      if (probarPuente(hueco, [candidato]) == ResultadoPuente.exacto) continue;
      tablones.add(candidato);
    }
    tablones.shuffle(_azar);
    return RetoPuente(
      modo: modo,
      hueco: hueco,
      tablones: tablones,
      solucion: solucion,
    );
  }

  /// Los tablones que llenan el hueco y uno o dos que sobran, todos
  /// montados. Ninguno de los que sobran mide por sí solo el hueco.
  RetoPuente _puenteRoto(ModoPuente modo, int dificultad) {
    final mismo = modo == ModoPuente.restaMismoDenominador;
    final base = mismo ? ModoPuente.mismoDenominador : ModoPuente.distintoDenominador;
    final solucion = mismo
        ? _solucionMismoDenominador(2)
        : _solucionDistintoDenominador(2, dificultad);
    final hueco = sumaExacta(solucion);
    final sobrantes = <Fraccion>[];
    var intentos = 0;
    while (sobrantes.length < (dificultad >= 2 ? 2 : 1) && intentos++ < 200) {
      final candidato = _distractor(base, solucion, dificultad);
      if (probarPuente(hueco, [candidato]) == ResultadoPuente.exacto) continue;
      sobrantes.add(candidato);
    }
    return RetoPuente(
      modo: modo,
      hueco: hueco,
      tablones: [...solucion, ...sobrantes]..shuffle(_azar),
      solucion: solucion,
    );
  }

  List<Fraccion> _solucionMismoDenominador(int piezas) {
    final denominador = [4, 5, 6, 8, 10][_azar.nextInt(5)];
    return [
      for (var i = 0; i < piezas; i++)
        Fraccion(1 + _azar.nextInt(denominador - 1), denominador),
    ];
  }

  List<Fraccion> _solucionDistintoDenominador(int piezas, int dificultad) {
    // Denominadores que dividen a 12 (o a 24 en dificultad 3): sumas
    // razonables de cabeza.
    final denominadores =
        dificultad >= 3 ? [3, 4, 6, 8, 12] : [2, 3, 4, 6, 12];
    for (var intento = 0; intento < 100; intento++) {
      final elegidos = [
        for (var i = 0; i < piezas; i++)
          denominadores[_azar.nextInt(denominadores.length)],
      ];
      if (elegidos.toSet().length < 2) continue; // si no, sería FR.14
      return [
        for (final denominador in elegidos)
          Fraccion(1 + _azar.nextInt(denominador - 1), denominador),
      ];
    }
    return const [Fraccion(1, 2), Fraccion(1, 3)];
  }

  List<Fraccion> _solucionDecimales(int piezas, int dificultad) {
    final denominador = dificultad >= 2 ? 100 : 10;
    final paso = denominador == 100 ? 5 : 1; // centésimas de 5 en 5
    return [
      for (var i = 0; i < piezas; i++)
        Fraccion(
            paso * (1 + _azar.nextInt((denominador * 2) ~/ paso - 1)), denominador),
    ];
  }

  Fraccion _distractor(ModoPuente modo, List<Fraccion> solucion, int dificultad) {
    final modelo = solucion[_azar.nextInt(solucion.length)];
    switch (modo) {
      case ModoPuente.mismoDenominador:
      case ModoPuente.restaMismoDenominador:
        return Fraccion(
            1 + _azar.nextInt(modelo.denominador - 1), modelo.denominador);
      case ModoPuente.distintoDenominador:
      case ModoPuente.restaDistintoDenominador:
        final denominadores =
            dificultad >= 3 ? [3, 4, 6, 8, 12] : [2, 3, 4, 6, 12];
        final denominador = denominadores[_azar.nextInt(denominadores.length)];
        return Fraccion(1 + _azar.nextInt(denominador - 1), denominador);
      case ModoPuente.decimales:
        final paso = modelo.denominador == 100 ? 5 : 1;
        return Fraccion(
            paso * (1 + _azar.nextInt((modelo.denominador * 2) ~/ paso - 1)),
            modelo.denominador);
    }
  }

  /// El hueco decimal se expresa en la misma unidad que los tablones
  /// (décimas o centésimas), sin simplificar: 12/10 → "1,2".
  Fraccion _enDecimos(Fraccion suma, int denominador) =>
      Fraccion(suma.numerador * (denominador ~/ suma.denominador), denominador);
}
