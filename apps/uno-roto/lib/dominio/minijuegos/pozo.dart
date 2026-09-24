import 'dart:math' as math;

/// El pozo (segunda sala de Rexán): la mina de la Montaña tiene plantas
/// por encima y por debajo del suelo (la 0). El ascensor funciona con
/// órdenes con signo; está a oscuras, así que hay que saber adónde va.
///
/// 1. Una o dos órdenes: sumar y restar enteros (ARI.04).
/// 2. Cadenas con los Signos (el monstruo): el Invertido da la vuelta a la
///    orden siguiente, el Eco repite la anterior y la Doble negación
///    −(−5) sube (ARI.04).
/// 3. Valor absoluto (ARI.05): la planta a la misma distancia del suelo
///    que otra, y cuántas plantas hay entre dos.
enum TipoOrden { mover, dobleNegacion, invertido, eco }

class Orden {
  final TipoOrden tipo;

  /// Mover: cuánto (con signo). Doble negación: el número de dentro, que
  /// acaba sumando (−(−5) = +5).
  final int valor;

  const Orden(this.tipo, [this.valor = 0]);

  String get etiqueta => switch (tipo) {
        TipoOrden.mover => valor >= 0 ? '+$valor' : '−${-valor}',
        TipoOrden.dobleNegacion => '−(−$valor)',
        TipoOrden.invertido => '⇅',
        TipoOrden.eco => '↻',
      };
}

enum TipoPozo { viaje, espejo, distancia }

class RetoPozo {
  final TipoPozo tipo;
  final int inicio;
  final List<Orden> ordenes;

  /// Espejo: la planta de referencia. Distancia: las dos plantas.
  final List<int> plantas;

  final int respuesta;

  /// Distancia: cuatro opciones.
  final List<int> opciones;

  const RetoPozo({
    required this.tipo,
    required this.inicio,
    required this.ordenes,
    required this.respuesta,
    this.plantas = const [],
    this.opciones = const [],
  });

  String get idHabilidad => tipo == TipoPozo.viaje ? 'ARI.04' : 'ARI.05';
}

/// Las plantas por las que pasa el ascensor, empezando por [inicio].
List<int> recorrido(int inicio, List<Orden> ordenes) {
  final paradas = [inicio];
  var actual = inicio;
  var invertir = false;
  var ultimo = 0;
  for (final orden in ordenes) {
    int paso;
    switch (orden.tipo) {
      case TipoOrden.invertido:
        invertir = true;
        continue;
      case TipoOrden.mover:
        paso = orden.valor;
      case TipoOrden.dobleNegacion:
        paso = orden.valor;
      case TipoOrden.eco:
        paso = ultimo;
    }
    if (invertir) {
      paso = -paso;
      invertir = false;
    }
    actual += paso;
    ultimo = paso;
    paradas.add(actual);
  }
  return paradas;
}

class GeneradorPozo {
  final math.Random _azar;

  GeneradorPozo({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  int _limite(int dificultad) => dificultad == 1 ? 10 : 15;

  RetoPozo generar(TipoPozo tipo, {required int nivel, int dificultad = 1}) {
    final limite = _limite(dificultad);
    switch (tipo) {
      case TipoPozo.viaje:
        for (var intento = 0; intento < 1000; intento++) {
          final inicio = nivel == 1 && _azar.nextBool() ? 0 : _entre(-limite ~/ 2, limite ~/ 2);
          final ordenes = nivel == 1 ? _ordenesSimples() : _ordenesConSignos(dificultad);
          final paradas = recorrido(inicio, ordenes);
          if (paradas.any((p) => p.abs() > limite)) continue;
          // Que cruce el suelo al menos una vez: ahí está la dificultad.
          if (!paradas.any((p) => p < 0) || !paradas.any((p) => p > 0)) continue;
          return RetoPozo(tipo: tipo, inicio: inicio, ordenes: ordenes, respuesta: paradas.last);
        }
        return const RetoPozo(
            tipo: TipoPozo.viaje, inicio: 2, ordenes: [Orden(TipoOrden.mover, -5)], respuesta: -3);
      case TipoPozo.espejo:
        var referencia = _entre(2, limite - 2);
        if (_azar.nextBool()) referencia = -referencia;
        return RetoPozo(
            tipo: tipo, inicio: 0, ordenes: const [], plantas: [referencia], respuesta: -referencia);
      case TipoPozo.distancia:
        final a = _entre(-limite + 1, -1);
        final b = _entre(1, limite - 1);
        final respuesta = b - a;
        final plantas = _azar.nextBool() ? [a, b] : [b, a];
        // Errores típicos: restar los números sin signo, contar las
        // plantas incluyendo las dos, sumar con signo.
        final opciones = <int>{respuesta, (b - a.abs()).abs(), respuesta + 1, a + b}
          ..removeWhere((o) => o <= 0);
        var extra = 2;
        while (opciones.length < 4) {
          opciones.add(respuesta + extra++);
        }
        return RetoPozo(
          tipo: tipo,
          inicio: 0,
          ordenes: const [],
          plantas: plantas,
          respuesta: respuesta,
          opciones: opciones.take(4).toList()..shuffle(_azar),
        );
    }
  }

  int _movimiento(int maximo) {
    final v = _entre(1, maximo);
    return _azar.nextBool() ? v : -v;
  }

  List<Orden> _ordenesSimples() => [
        for (var i = 0; i < _entre(1, 2); i++) Orden(TipoOrden.mover, _movimiento(9)),
      ];

  List<Orden> _ordenesConSignos(int dificultad) {
    final ordenes = <Orden>[Orden(TipoOrden.mover, _movimiento(8))];
    final cuantas = _entre(2, 3);
    for (var i = 0; i < cuantas; i++) {
      final tirada = _azar.nextDouble();
      if (dificultad >= 2 && tirada < 0.25 && ordenes.last.tipo != TipoOrden.invertido) {
        ordenes.add(const Orden(TipoOrden.invertido));
        ordenes.add(Orden(TipoOrden.mover, _movimiento(8)));
      } else if (tirada < 0.45) {
        ordenes.add(Orden(TipoOrden.dobleNegacion, _entre(2, 7)));
      } else if (tirada < 0.6) {
        ordenes.add(const Orden(TipoOrden.eco));
      } else {
        ordenes.add(Orden(TipoOrden.mover, _movimiento(8)));
      }
    }
    return ordenes;
  }
}
