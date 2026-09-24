import 'dart:math' as math;

/// Depósitos (segunda sala de Rexán): la Industria necesita agua para
/// enfriar las máquinas. Hay depósitos con forma de caja y tapas de
/// tubería redondas.
///
/// 1. Cubos (GEO.06): un depósito de 4 × 3 × 2 con su cuadrícula; ¿cuántos
///    cubitos caben? Se llena por capas.
/// 2. Litros (MED.02): un depósito de 30 × 20 × 10 cm; ¿cuántos litros
///    caben? 1 dm³ = 1 litro = 1000 cm³.
/// 3. Tuberías (GEO.05): la valla alrededor de una tapa de radio 3
///    (2 · 3,14 · r) o la chapa para taparla (3,14 · r²).
///
/// Las Fugas (el monstruo) vacían lo que se pide de más: si la respuesta
/// es mayor que lo que cabe, el agua se sale por el borde.
///
/// Las tuberías van en centésimas (π ≈ 3,14); el resto, en enteros.
enum TipoDeposito { cubos, litros, vallaCirculo, areaCirculo }

class RetoDeposito {
  final TipoDeposito tipo;

  /// Cubos y litros: [largo, ancho, alto] (en cubitos o en cm).
  /// Tuberías: [radio].
  final List<int> datos;

  /// Cubos: cubitos. Litros: litros. Tuberías: centésimas.
  final int respuesta;
  final List<int> opciones;

  const RetoDeposito({required this.tipo, required this.datos, required this.respuesta, required this.opciones});

  bool get enCentesimas => tipo == TipoDeposito.vallaCirculo || tipo == TipoDeposito.areaCirculo;

  String get idHabilidad => switch (tipo) {
        TipoDeposito.cubos => 'GEO.06',
        TipoDeposito.litros => 'MED.02',
        TipoDeposito.vallaCirculo || TipoDeposito.areaCirculo => 'GEO.05',
      };
}

class GeneradorDepositos {
  final math.Random _azar;

  GeneradorDepositos({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoDeposito generar(TipoDeposito tipo, {int dificultad = 1}) {
    switch (tipo) {
      case TipoDeposito.cubos:
        final maximo = dificultad == 1 ? 4 : (dificultad == 2 ? 6 : 8);
        final largo = _entre(2, maximo);
        final ancho = _entre(2, maximo);
        final alto = _entre(2, dificultad == 1 ? 3 : 5);
        final volumen = largo * ancho * alto;
        return _reto(tipo, [largo, ancho, alto], volumen, [
          largo + ancho + alto, // sumar las tres medidas
          largo * ancho, // una sola capa
          2 * (largo * ancho + largo * alto + ancho * alto), // la chapa de fuera
        ]);
      case TipoDeposito.litros:
        // Medidas en cm, múltiplos de 10: el volumen sale en litros enteros.
        final maximo = dificultad == 1 ? 4 : 8;
        final largo = 10 * _entre(2, maximo);
        final ancho = 10 * _entre(1, maximo);
        final alto = 10 * _entre(1, dificultad == 1 ? 3 : 6);
        final centimetrosCubicos = largo * ancho * alto;
        final litros = centimetrosCubicos ~/ 1000;
        return _reto(tipo, [largo, ancho, alto], litros, [
          litros * 10, // dividir entre 100 en vez de entre 1000
          litros * 1000 > 99999 ? litros * 100 : litros * 1000, // no pasar a litros
          largo + ancho + alto, // sumar las medidas
        ]);
      case TipoDeposito.vallaCirculo:
      case TipoDeposito.areaCirculo:
        // Sin el 2: con radio 2 la valla y el área dan lo mismo (12,56).
        const radios = [3, 4, 5, 6, 8, 10];
        final radio = radios[_entre(0, dificultad == 1 ? 2 : radios.length - 1)];
        final valla = 628 * radio; // 2 · 3,14 · r
        final area = 314 * radio * radio; // 3,14 · r²
        if (tipo == TipoDeposito.vallaCirculo) {
          return _reto(tipo, [radio], valla, [
            area, // la otra fórmula
            628 * 2 * radio, // el diámetro en vez del radio
            600 * radio, // π = 3
          ]);
        }
        return _reto(tipo, [radio], area, [
          valla, // la otra fórmula
          314 * 2 * radio, // 3,14 · 2 · r: el doble en vez del cuadrado
          314 * 4 * radio * radio, // el diámetro al cuadrado
        ]);
    }
  }

  RetoDeposito _reto(TipoDeposito tipo, List<int> datos, int respuesta, List<int> errores) {
    final opciones = <int>{respuesta};
    for (final error in errores) {
      if (opciones.length == 4) break;
      if (error > 0) opciones.add(error);
    }
    final paso = tipo == TipoDeposito.vallaCirculo || tipo == TipoDeposito.areaCirculo ? 314 : 1;
    var extra = 1;
    while (opciones.length < 4) {
      opciones.add(respuesta + extra * paso);
      extra++;
    }
    return RetoDeposito(tipo: tipo, datos: datos, respuesta: respuesta, opciones: opciones.toList()..shuffle(_azar));
  }
}
