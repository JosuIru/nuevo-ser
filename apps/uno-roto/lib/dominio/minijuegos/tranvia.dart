import 'dart:math' as math;

/// El tranvía (segunda sala de Rexán): una línea que recorre una recta
/// numérica con paradas en cada décima (o en cada unidad).
///
/// 1. Situar (DEC.01): llevar el tranvía a la parada 1,3.
/// 2. Redondear (DEC.09): el viajero va a 2,46; ¿en qué parada baja, la
///    más cercana? (a la unidad en dificultad 1; a la décima después).
/// 3. Los Revisores (el monstruo) piden el billete con una cuenta:
///    3 viajes de 1,25 € (DEC.05), el 0,6 de 2,5 € (DEC.06), 7,5 € entre
///    3 (DEC.07). La trampa: la coma en otro sitio.
///
/// Todo se guarda en centésimas para no pelearse con los decimales.
enum TipoTranvia { situar, redondear, multiplicar, multiplicarDecimales, dividir }

class RetoTranvia {
  final TipoTranvia tipo;

  /// Paradas: desde, hasta y paso, en centésimas (p. ej. 0, 200, 10).
  final int desde;
  final int hasta;
  final int paso;

  /// Situar: la parada pedida. Redondear: dónde va el viajero.
  final int valor;

  /// Revisores: los números de la cuenta (en centésimas o enteros).
  final List<int> datos;

  /// Situar y redondear: la parada buena (centésimas). Revisores: el
  /// resultado en centésimas.
  final int respuesta;

  /// Revisores: cuatro resultados en centésimas.
  final List<int> opciones;

  const RetoTranvia({
    required this.tipo,
    required this.respuesta,
    this.desde = 0,
    this.hasta = 0,
    this.paso = 10,
    this.valor = 0,
    this.datos = const [],
    this.opciones = const [],
  });

  String get idHabilidad => switch (tipo) {
        TipoTranvia.situar => 'DEC.01',
        TipoTranvia.redondear => 'DEC.09',
        TipoTranvia.multiplicar => 'DEC.05',
        TipoTranvia.multiplicarDecimales => 'DEC.06',
        TipoTranvia.dividir => 'DEC.07',
      };
}

/// 125 → "1,25"; 250 → "2,5"; 300 → "3".
String enDecimal(int centesimas) {
  final signo = centesimas < 0 ? '−' : '';
  final c = centesimas.abs();
  final enteros = c ~/ 100;
  final resto = c % 100;
  if (resto == 0) return '$signo$enteros';
  final texto = resto.toString().padLeft(2, '0');
  return '$signo$enteros,${texto.endsWith('0') ? texto[0] : texto}';
}

class GeneradorTranvia {
  final math.Random _azar;

  GeneradorTranvia({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoTranvia generar(TipoTranvia tipo, {int dificultad = 1}) {
    switch (tipo) {
      case TipoTranvia.situar:
        // Paradas cada décima de 0 a 2 (o de 1 a 3).
        final desde = dificultad == 1 ? 0 : 100 * _entre(0, 1);
        final valor = desde + 10 * _entre(1, 19);
        return RetoTranvia(tipo: tipo, desde: desde, hasta: desde + 200, paso: 10, valor: valor, respuesta: valor);
      case TipoTranvia.redondear:
        if (dificultad == 1) {
          // A la unidad: paradas 0..10; el viajero en décimas (sin ,5).
          int valor;
          do {
            valor = 10 * _entre(1, 99);
          } while (valor % 100 == 50 || valor % 100 == 0);
          return RetoTranvia(
              tipo: tipo, desde: 0, hasta: 1000, paso: 100, valor: valor, respuesta: ((valor + 50) ~/ 100) * 100);
        }
        // A la décima: paradas de una unidad; el viajero en centésimas (sin x,x5).
        final unidad = 100 * _entre(0, 4);
        int valor;
        do {
          valor = unidad + _entre(1, 99);
        } while (valor % 10 == 5 || valor % 10 == 0);
        return RetoTranvia(
            tipo: tipo, desde: unidad, hasta: unidad + 100, paso: 10, valor: valor, respuesta: ((valor + 5) ~/ 10) * 10);
      case TipoTranvia.multiplicar:
        // k viajes de p € (p en centésimas, múltiplo de 5).
        final k = _entre(2, dificultad == 1 ? 4 : 6);
        final p = 5 * _entre(21, dificultad == 1 ? 60 : 99);
        final r = k * p;
        return _revisor(tipo, [k, p], r, [r ~/ 10, r * 10, p + k * 100]);
      case TipoTranvia.multiplicarDecimales:
        // a × b con a en décimas (0,2..0,9) y b en décimas o centésimas.
        final a = 10 * _entre(2, 9);
        final b = 10 * _entre(11, dificultad == 1 ? 40 : 90);
        final r = a * b ~/ 100;
        if ((a * b) % 100 != 0) return generar(tipo, dificultad: dificultad);
        return _revisor(tipo, [a, b], r, [r * 10, r ~/ 10, b - a]);
      case TipoTranvia.dividir:
        // p € entre k (exacto en centésimas).
        final k = _entre(2, dificultad == 1 ? 4 : 6);
        final r = 5 * _entre(10, dificultad == 1 ? 60 : 99);
        final p = r * k;
        return _revisor(tipo, [p, k], r, [r * 10, r ~/ 10, p - k * 100]);
    }
  }

  RetoTranvia _revisor(TipoTranvia tipo, List<int> datos, int respuesta, List<int> errores) {
    final opciones = <int>{respuesta};
    for (final error in errores) {
      if (opciones.length == 4) break;
      if (error > 0) opciones.add(error);
    }
    var extra = 5;
    while (opciones.length < 4) {
      opciones.add(respuesta + extra);
      extra += 5;
    }
    return RetoTranvia(tipo: tipo, datos: datos, respuesta: respuesta, opciones: opciones.toList()..shuffle(_azar));
  }
}
