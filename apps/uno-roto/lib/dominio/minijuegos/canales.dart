import 'dart:collection';
import 'dart:math' as math;

import '../problema_espejo.dart' show Fraccion;

/// Canales (máquina de Rexán): comecocos matemático. El niño recorre un
/// laberinto de los Canales y recoge sólo los números que cumplen la
/// regla. Dos sombras lentas lo buscan: si lo pillan, vuelve a la
/// salida (sin vidas, sin castigo). Comerse un número que no cumple
/// cuenta como fallo y Rexán dice por qué.

// ─── Laberintos ──────────────────────────────────────────────────────

/// '#' muro, '.' canal, 'S' salida del niño, 'G' guarida de sombras.
const laberintosCanales = <List<String>>[
  [
    '###########',
    '#....#....#',
    '#.##.#.##.#',
    '#.........#',
    '#.##.#.##.#',
    '#....#....#',
    '###.###.###',
    '#....G....#',
    '#.##.#.##.#',
    '#...S.....#',
    '#.##.#.##.#',
    '#....#....#',
    '###########',
  ],
  [
    '###########',
    '#.........#',
    '#.#.###.#.#',
    '#.#..G..#.#',
    '#.##.#.##.#',
    '#....#....#',
    '##.#####.##',
    '#....S....#',
    '#.###.###.#',
    '#...#.#...#',
    '###.#.#.###',
    '#.........#',
    '###########',
  ],
  [
    '###########',
    '#...#.#...#',
    '#.#.#.#.#.#',
    '#.#.....#.#',
    '#.###.###.#',
    '#....G....#',
    '#.##.#.##.#',
    '#....#....#',
    '##.#.S.#.##',
    '#..#...#..#',
    '#.##.#.##.#',
    '#.........#',
    '###########',
  ],
];

class Celda {
  final int fila;
  final int columna;

  const Celda(this.fila, this.columna);

  Celda mas(Direccion direccion) =>
      Celda(fila + direccion.dFila, columna + direccion.dColumna);

  @override
  bool operator ==(Object otra) =>
      otra is Celda && otra.fila == fila && otra.columna == columna;

  @override
  int get hashCode => fila * 1000 + columna;

  @override
  String toString() => '($fila,$columna)';
}

enum Direccion {
  arriba(-1, 0),
  abajo(1, 0),
  izquierda(0, -1),
  derecha(0, 1);

  final int dFila;
  final int dColumna;

  const Direccion(this.dFila, this.dColumna);
}

class LaberintoCanales {
  final List<String> filas;

  const LaberintoCanales(this.filas);

  int get alto => filas.length;
  int get ancho => filas.first.length;

  bool esCanal(Celda celda) =>
      celda.fila >= 0 &&
      celda.fila < alto &&
      celda.columna >= 0 &&
      celda.columna < ancho &&
      filas[celda.fila][celda.columna] != '#';

  Celda _buscar(String marca) {
    for (var fila = 0; fila < alto; fila++) {
      final columna = filas[fila].indexOf(marca);
      if (columna >= 0) return Celda(fila, columna);
    }
    throw StateError('El laberinto no tiene "$marca"');
  }

  Celda get salida => _buscar('S');
  Celda get guarida => _buscar('G');

  List<Celda> get canales => [
        for (var fila = 0; fila < alto; fila++)
          for (var columna = 0; columna < ancho; columna++)
            if (esCanal(Celda(fila, columna))) Celda(fila, columna),
      ];

  List<Celda> vecinos(Celda celda) => [
        for (final direccion in Direccion.values)
          if (esCanal(celda.mas(direccion))) celda.mas(direccion),
      ];

  /// Canales alcanzables desde [origen] (para comprobar que el
  /// laberinto no tiene zonas aisladas).
  Set<Celda> alcanzables(Celda origen) {
    final vistos = <Celda>{origen};
    final cola = Queue<Celda>()..add(origen);
    while (cola.isNotEmpty) {
      for (final vecino in vecinos(cola.removeFirst())) {
        if (vistos.add(vecino)) cola.add(vecino);
      }
    }
    return vistos;
  }

  /// Primer paso del camino más corto de [desde] a [hasta].
  Celda? primerPasoHacia(Celda desde, Celda hasta) {
    if (desde == hasta) return null;
    final previo = <Celda, Celda>{};
    final cola = Queue<Celda>()..add(desde);
    final vistos = <Celda>{desde};
    while (cola.isNotEmpty) {
      final actual = cola.removeFirst();
      if (actual == hasta) break;
      for (final vecino in vecinos(actual)) {
        if (vistos.add(vecino)) {
          previo[vecino] = actual;
          cola.add(vecino);
        }
      }
    }
    if (!previo.containsKey(hasta)) return null;
    var paso = hasta;
    while (previo[paso] != desde) {
      paso = previo[paso]!;
    }
    return paso;
  }
}

// ─── Reglas ──────────────────────────────────────────────────────────

class NumeroCanal {
  final String etiqueta;
  final bool cumple;

  const NumeroCanal(this.etiqueta, {required this.cumple});
}

class ReglaCanales {
  final String idHabilidad;

  /// Texto de la regla (castellano, se traduce con `traducirNarrativa`;
  /// `{n}` se sustituye después).
  final String texto;
  final int? parametro;
  final List<NumeroCanal> Function(
      math.Random azar, int cuantos, double proporcion) _generar;

  const ReglaCanales._(this.idHabilidad, this.texto, this.parametro, this._generar);

  /// [cuantos] números sin repetir; [proporcion] de ellos cumple la
  /// regla (la mitad por defecto, como en Canales).
  List<NumeroCanal> generar(math.Random azar, int cuantos,
          {double proporcion = 0.5}) =>
      _generar(azar, cuantos, proporcion);

  /// Regla para [idHabilidad] a la [dificultad] dada, o null si esa
  /// habilidad no tiene regla de Canales.
  static ReglaCanales? para(String idHabilidad, int dificultad, math.Random azar) {
    switch (idHabilidad) {
      case 'DIV.01':
        final n = [
          [2, 3, 5],
          [3, 4, 6],
          [6, 7, 8, 9],
        ][dificultad.clamp(1, 3) - 1];
        final divisor = n[azar.nextInt(n.length)];
        return ReglaCanales._('DIV.01', 'Sólo múltiplos de {n}.', divisor,
            // Hasta 20 veces el divisor: da números de sobra también para
            // los tableros de Minas (hasta 42 casillas).
            (azar, cuantos, p) => _enteros(azar, cuantos, p, 2,
                math.max(20 * divisor, 40), (x) => x % divisor == 0));
      case 'DIV.04':
        final divisor = [4, 6, 9][azar.nextInt(3)];
        return ReglaCanales._('DIV.04', 'Sólo divisibles entre {n}.', divisor,
            (azar, cuantos, p) => _enteros(azar, cuantos, p, 12, 200,
                (x) => x % divisor == 0));
      case 'DIV.03':
        final divisor = [2, 5, 10][azar.nextInt(3)];
        return ReglaCanales._('DIV.03', 'Sólo divisibles entre {n}.', divisor,
            (azar, cuantos, p) => _enteros(azar, cuantos, p, 10, 200,
                (x) => x % divisor == 0));
      case 'DIV.02':
        // Números con muchos divisores, para que haya minas de sobra.
        final n = [
          [36, 48, 60],
          [60, 72, 84, 90],
          [96, 120, 180],
        ][dificultad.clamp(1, 3) - 1];
        final numero = n[azar.nextInt(n.length)];
        return ReglaCanales._('DIV.02', 'Sólo divisores de {n}.', numero,
            (azar, cuantos, p) => _divisoresDe(azar, cuantos, p, numero));
      case 'DIV.05':
        final maximo = dificultad >= 2 ? 60 : 40;
        return ReglaCanales._('DIV.05', 'Sólo números primos.', null,
            (azar, cuantos, p) =>
                _enteros(azar, cuantos, p, 2, maximo, _esPrimo));
      case 'DEC.02':
        return ReglaCanales._('DEC.02', 'Sólo decimales mayores que 0,5.', null,
            (azar, cuantos, p) => _decimales(azar, cuantos, p, dificultad));
      case 'FR.03':
        return ReglaCanales._('FR.03', 'Sólo fracciones mayores que 1/2.', null,
            (azar, cuantos, p) => _fracciones(azar, cuantos, p, dificultad));
    }
    return null;
  }

  /// Divisores de [numero] (tantos como pida [proporcion], o todos si no
  /// hay tantos) y el resto hasta [cuantos] con no divisores de 2 a
  /// [numero]: sobre todo múltiplos de algún divisor, que son la trampa
  /// ("24 no divide a 36 aunque 12 sí").
  static List<NumeroCanal> _divisoresDe(math.Random azar, int cuantos, double proporcion, int numero) {
    final divisores = [for (var d = 1; d <= numero; d++) if (numero % d == 0) d]..shuffle(azar);
    final minas = divisores.take(math.min((cuantos * proporcion).ceil(), divisores.length));
    final noDivisores = [for (var x = 2; x <= numero; x++) if (numero % x != 0) x]..shuffle(azar);
    final trampas = noDivisores.where((x) => x.isEven || x % 3 == 0).toList();
    final resto = [...trampas, ...noDivisores.where((x) => !trampas.contains(x))].take(cuantos - minas.length);
    return [
      for (final d in minas) NumeroCanal('$d', cumple: true),
      for (final x in resto) NumeroCanal('$x', cumple: false),
    ]..shuffle(azar);
  }

  static bool _esPrimo(int x) {
    if (x < 2) return false;
    for (var d = 2; d * d <= x; d++) {
      if (x % d == 0) return false;
    }
    return true;
  }

  /// [proporcion] de [cuantos] (redondeando arriba) que cumple y el resto
  /// que no, sin repetir.
  static List<NumeroCanal> _mezcla(math.Random azar, int cuantos,
      double proporcion, NumeroCanal Function() candidato) {
    final queCumplen = (cuantos * proporcion).ceil();
    final vistos = <String>{};
    final si = <NumeroCanal>[];
    final no = <NumeroCanal>[];
    for (var intento = 0;
        intento < 2000 && (si.length < queCumplen || no.length < cuantos - queCumplen);
        intento++) {
      final numero = candidato();
      if (!vistos.add(numero.etiqueta)) continue;
      if (numero.cumple && si.length < queCumplen) si.add(numero);
      if (!numero.cumple && no.length < cuantos - queCumplen) no.add(numero);
    }
    return [...si, ...no]..shuffle(azar);
  }

  static List<NumeroCanal> _enteros(math.Random azar, int cuantos,
          double proporcion, int minimo, int maximo, bool Function(int) cumple) =>
      _mezcla(azar, cuantos, proporcion, () {
        final x = minimo + azar.nextInt(maximo - minimo + 1);
        return NumeroCanal('$x', cumple: cumple(x));
      });

  static List<NumeroCanal> _decimales(
          math.Random azar, int cuantos, double proporcion, int dificultad) =>
      _mezcla(azar, cuantos, proporcion, () {
        // Dificultad 2+: centésimas y casos engañosos (0,45 frente a 0,5).
        if (dificultad >= 2 && azar.nextBool()) {
          final centesimas = 5 + azar.nextInt(91);
          if (centesimas == 50) return const NumeroCanal('0,50', cumple: false);
          final texto =
              '0,${centesimas.toString().padLeft(2, '0')}';
          return NumeroCanal(texto, cumple: centesimas > 50);
        }
        // Décimas de 0,1 a 1,9: también hay que ver que 1,2 > 0,5.
        final decimas = 1 + azar.nextInt(19);
        return NumeroCanal('${decimas ~/ 10},${decimas % 10}',
            cumple: decimas > 5);
      });

  static List<NumeroCanal> _fracciones(
          math.Random azar, int cuantos, double proporcion, int dificultad) =>
      _mezcla(azar, cuantos, proporcion, () {
        final maximo = dificultad >= 2 ? 12 : 8;
        final denominador = 3 + azar.nextInt(maximo - 2);
        final numerador = 1 + azar.nextInt(denominador - 1);
        final fraccion = Fraccion(numerador, denominador);
        // La mitad exacta no cumple "mayor que": se evita por clara.
        if (numerador * 2 == denominador) {
          return NumeroCanal(fraccion.etiqueta, cumple: false);
        }
        return NumeroCanal(fraccion.etiqueta, cumple: numerador * 2 > denominador);
      });
}

// ─── Partida ─────────────────────────────────────────────────────────

enum EventoCanales { nada, recogido, noCumplia, pillado, laberintoTerminado }

/// Niveles (uno por laberinto): 1, dos sombras; 2, tres; 3, tres y una
/// de ellas (la primera) siempre persigue, con más números trampa.
class PartidaCanales {
  final LaberintoCanales laberinto;
  final ReglaCanales regla;
  final int dificultad;
  final int nivel;
  final math.Random _azar;

  late Celda jugador;
  Direccion? direccion;
  Direccion? direccionDeseada;
  late List<Celda> sombras;
  final Map<Celda, NumeroCanal> numeros = {};

  int recogidos = 0;
  int noCumplian = 0;
  int pillado = 0;
  int _ticks = 0;

  /// Número del último fallo (para que Rexán diga cuál era).
  NumeroCanal? ultimoFallo;

  PartidaCanales({
    required this.laberinto,
    required this.regla,
    required this.dificultad,
    this.nivel = 1,
    math.Random? azar,
  }) : _azar = azar ?? math.Random() {
    jugador = laberinto.salida;
    sombras = _posicionesIniciales();
    final libres = laberinto.canales
        .where((celda) =>
            celda != laberinto.salida &&
            celda != laberinto.guarida &&
            !laberinto.vecinos(laberinto.salida).contains(celda))
        .toList()
      ..shuffle(_azar);
    final cuantos = 8 + 2 * dificultad + (nivel >= 3 ? 2 : 0);
    final generados =
        regla.generar(_azar, cuantos, proporcion: nivel >= 3 ? 0.4 : 0.5);
    for (var i = 0; i < generados.length && i < libres.length; i++) {
      numeros[libres[i]] = generados[i];
    }
  }

  int get _cuantasSombras => nivel >= 2 ? 3 : 2;

  List<Celda> _posicionesIniciales() {
    final guarida = laberinto.guarida;
    final vecinas = laberinto.vecinos(guarida);
    return [
      for (var i = 0; i < _cuantasSombras; i++)
        i == 0 || vecinas.isEmpty ? guarida : vecinas[(i - 1) % vecinas.length],
    ];
  }

  /// La sombra que siempre persigue (nivel 3).
  bool esCazadora(int indice) => nivel >= 3 && indice == 0;

  int get pendientes => numeros.values.where((n) => n.cumple).length;
  bool get terminado => pendientes == 0;

  /// Acierto del laberinto para la maestría: como mucho un número que
  /// no cumplía.
  bool get acierto => noCumplian <= 1;

  /// Un paso de reloj. El niño avanza una celda por tick; las sombras,
  /// una cada 2 (dificultad 1-2) o cada tick y medio aprox. (3).
  EventoCanales avanzar() {
    if (terminado) return EventoCanales.laberintoTerminado;
    _ticks++;
    final deseada = direccionDeseada;
    if (deseada != null && laberinto.esCanal(jugador.mas(deseada))) {
      direccion = deseada;
    }
    final actual = direccion;
    if (actual != null && laberinto.esCanal(jugador.mas(actual))) {
      jugador = jugador.mas(actual);
    }
    var evento = _comer();
    if (_choca()) return _pillar();
    final cadaCuanto = dificultad >= 3 ? 3 : 2;
    final mueven = dificultad >= 3 ? _ticks % cadaCuanto != 0 : _ticks % cadaCuanto == 0;
    if (mueven) {
      sombras = [
        for (var i = 0; i < sombras.length; i++)
          esCazadora(i)
              ? laberinto.primerPasoHacia(sombras[i], jugador) ?? sombras[i]
              : _pasoSombra(sombras[i]),
      ];
      if (_choca()) return _pillar();
    }
    if (terminado) evento = EventoCanales.laberintoTerminado;
    return evento;
  }

  EventoCanales _comer() {
    final numero = numeros.remove(jugador);
    if (numero == null) return EventoCanales.nada;
    if (numero.cumple) {
      recogidos++;
      return EventoCanales.recogido;
    }
    noCumplian++;
    ultimoFallo = numero;
    return EventoCanales.noCumplia;
  }

  bool _choca() => sombras.contains(jugador);

  EventoCanales _pillar() {
    pillado++;
    jugador = laberinto.salida;
    direccion = null;
    direccionDeseada = null;
    sombras = _posicionesIniciales();
    return EventoCanales.pillado;
  }

  Celda _pasoSombra(Celda sombra) {
    // Dificultad 1: vagan. 2+: la mitad de las veces buscan al niño.
    if (dificultad >= 2 && _azar.nextBool()) {
      return laberinto.primerPasoHacia(sombra, jugador) ?? sombra;
    }
    final opciones = laberinto.vecinos(sombra);
    return opciones.isEmpty ? sombra : opciones[_azar.nextInt(opciones.length)];
  }
}
