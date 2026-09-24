import 'dart:math' as math;

/// El telar (segunda sala de Rexán): los tejedores del Mercado cruzan
/// hilos para multiplicar fracciones y cortan cintas para dividirlas.
///
/// 1. Fracción por natural (FR.18): 3 telas de 2/5 de metro.
/// 2. Fracción por fracción (FR.19) con el modelo de área: un hilo a 3/4
///    del ancho y otro a 2/3 del alto; lo que se cruza es 3/4 × 2/3.
/// 3. Dividir (FR.20, FR.21): repartir 3/4 de tela entre 3; ¿cuántas
///    cintas de 1/4 salen de 3/2?
///
/// Las Polillas (el monstruo) se comen la tela que sobra: dejan agujeros
/// donde no hay que mirar.
enum TipoTelar { porNatural, porFraccion, dividirNatural, dividirFraccion }

class RetoTelar {
  final TipoTelar tipo;

  /// Los números del reto: [n, d, k] (por natural, dividir natural),
  /// [a, b, c, d] (por fracción) o [a, b, c] (a/b entre cintas de 1/c).
  final List<int> datos;

  final String respuesta;
  final List<String> opciones;

  const RetoTelar({required this.tipo, required this.datos, required this.respuesta, required this.opciones});

  String get idHabilidad => switch (tipo) {
        TipoTelar.porNatural => 'FR.18',
        TipoTelar.porFraccion => 'FR.19',
        TipoTelar.dividirNatural => 'FR.20',
        TipoTelar.dividirFraccion => 'FR.21',
      };
}

/// Valor de "a/b" o de un entero escrito.
double valorEscrito(String texto) {
  if (!texto.contains('/')) return double.parse(texto);
  final [a, b] = texto.split('/').map(int.parse).toList();
  return a / b;
}

class GeneradorTelar {
  final math.Random _azar;

  GeneradorTelar({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoTelar generar(TipoTelar tipo, {int dificultad = 1}) {
    for (var intento = 0; intento < 500; intento++) {
      final reto = _intentar(tipo, dificultad);
      if (reto != null) return reto;
    }
    throw StateError('telar: $tipo');
  }

  RetoTelar? _intentar(TipoTelar tipo, int dificultad) {
    final maximoD = dificultad == 1 ? 6 : 10;
    switch (tipo) {
      case TipoTelar.porNatural:
        final d = _entre(3, maximoD);
        final n = _entre(1, d - 1);
        final k = _entre(2, dificultad == 1 ? 4 : 6);
        return _reto(tipo, [n, d, k], '${n * k}/$d', [
          '${n * k}/${d * k}', // multiplicar arriba y abajo
          '$n/${d * k}', // multiplicar el de abajo
          '${n + k}/$d', // sumar
        ]);
      case TipoTelar.porFraccion:
        final b = _entre(2, dificultad == 1 ? 4 : 6);
        final d = _entre(2, dificultad == 1 ? 4 : 6);
        final a = _entre(1, b - 1);
        final c = _entre(1, d - 1);
        return _reto(tipo, [a, b, c, d], '${a * c}/${b * d}', [
          '${a + c}/${b + d}', // sumar arriba y abajo
          '${a * c}/${b + d}', // multiplicar sólo arriba
          '${a * d}/${b * c}', // en cruz, como al dividir
        ]);
      case TipoTelar.dividirNatural:
        final d = _entre(2, maximoD);
        final n = _entre(1, d - 1);
        final k = _entre(2, 4);
        return _reto(tipo, [n, d, k], '$n/${d * k}', [
          '${n * k}/$d', // multiplicar en vez de dividir
          '$n/${d + k}', // sumar al de abajo
          '${n * k}/${d * k}', // el mismo valor escrito de otra forma: no vale
        ]);
      case TipoTelar.dividirFraccion:
        // a/b de tela en cintas de 1/c: salen a·c/b (entero).
        final c = _entre(2, dificultad == 1 ? 4 : 8);
        final b = _entre(2, 4);
        final a = _entre(b + 1, b * 3);
        if ((a * c) % b != 0) return null;
        final cintas = a * c ~/ b;
        return _reto(tipo, [a, b, c], '$cintas', [
          '${a * b ~/ math.max(1, c)}', // dar la vuelta a la que no es
          '${a + c}',
          '${cintas + b}',
        ]);
    }
  }

  RetoTelar? _reto(TipoTelar tipo, List<int> datos, String respuesta, List<String> errores) {
    final valores = <double>{valorEscrito(respuesta)};
    final opciones = <String>[respuesta];
    for (final error in errores) {
      final v = valorEscrito(error);
      if (v <= 0 || valores.any((x) => (x - v).abs() < 1e-9)) continue;
      valores.add(v);
      opciones.add(error);
    }
    var extra = 1;
    while (opciones.length < 4) {
      final base = valorEscrito(respuesta);
      final texto = respuesta.contains('/')
          ? '${int.parse(respuesta.split('/')[0]) + extra}/${respuesta.split('/')[1]}'
          : '${base.round() + extra}';
      final v = valorEscrito(texto);
      if (!valores.any((x) => (x - v).abs() < 1e-9)) {
        valores.add(v);
        opciones.add(texto);
      }
      extra++;
    }
    return RetoTelar(tipo: tipo, datos: datos, respuesta: respuesta, opciones: opciones.take(4).toList()..shuffle(_azar));
  }
}
