import 'dart:math' as math;

import '../problema_espejo.dart' show Fraccion;

/// Encaje (máquina de Rexán): Tetris de fracciones. Caen barras cuya
/// anchura es una fracción de la fila; una fila llena es exactamente
/// una unidad y se vacía. Sin puntos ni "game over": si la pila llega
/// arriba, Rexán vacía el tablero y se sigue.
///
/// La fila mide [columnasEncaje] = 12 celdas: caben medios, tercios,
/// cuartos, sextos y doceavos.
const int columnasEncaje = 12;
const int filasEncaje = 14;

int _mcd(int a, int b) => b == 0 ? a.abs() : _mcd(b, a % b);

/// Fracción simplificada de [celdas] doceavos (p. ej. 4 → 1/3).
Fraccion fraccionDeCeldas(int celdas) {
  final divisor = _mcd(celdas, columnasEncaje);
  return Fraccion(celdas ~/ divisor, columnasEncaje ~/ divisor);
}

class PiezaEncaje {
  /// Valor real de la pieza (simplificado).
  final Fraccion valor;

  /// Cómo se escribe: puede ser una fracción equivalente (2/4 por 1/2).
  final Fraccion etiqueta;

  const PiezaEncaje({required this.valor, required this.etiqueta});

  int get celdas => columnasEncaje * valor.numerador ~/ valor.denominador;
}

/// Un trozo ya encajado en una fila, para pintarlo con su etiqueta.
class TrozoEncajado {
  final int inicio;
  final PiezaEncaje pieza;

  const TrozoEncajado({required this.inicio, required this.pieza});

  int get fin => inicio + pieza.celdas;
}

enum ResultadoCaida { sigueCayendo, encajada, tableroVaciado }

class TableroEncaje {
  /// Filas de abajo (0) arriba; cada una, sus trozos encajados.
  final List<List<TrozoEncajado>> filas =
      List.generate(filasEncaje, (_) => <TrozoEncajado>[]);

  PiezaEncaje? piezaActual;

  /// Columna izquierda y fila (desde abajo) de la pieza que cae.
  int columna = 0;
  int altura = filasEncaje - 1;

  /// Unidades completadas (filas llenas) en la partida.
  int unidades = 0;

  /// Veces que Rexán ha tenido que vaciar el tablero.
  int vaciados = 0;

  /// Fila (desde abajo) de la última unidad completada, para el destello.
  int? ultimaFilaCompletada;

  /// Altura a la que quedaría la pieza si se soltara ahora (la sombra).
  int? get alturaDeCaida {
    final pieza = piezaActual;
    if (pieza == null) return null;
    var fila = altura;
    while (_cabeEn(fila - 1, columna, pieza.celdas)) {
      fila--;
    }
    return fila;
  }

  bool _ocupada(int fila, int celda) =>
      filas[fila].any((trozo) => celda >= trozo.inicio && celda < trozo.fin);

  bool _cabeEn(int fila, int columnaIzquierda, int celdas) {
    if (fila < 0) return false;
    for (var celda = columnaIzquierda; celda < columnaIzquierda + celdas; celda++) {
      if (_ocupada(fila, celda)) return false;
    }
    return true;
  }

  int celdasOcupadas(int fila) =>
      filas[fila].fold(0, (suma, trozo) => suma + trozo.pieza.celdas);

  /// Lo que le falta a la fila para ser una unidad, o null si está vacía.
  Fraccion? faltaEnFila(int fila) {
    final ocupadas = celdasOcupadas(fila);
    if (ocupadas == 0) return null;
    return fraccionDeCeldas(columnasEncaje - ocupadas);
  }

  /// Pone una pieza nueva arriba, centrada. Si no cabe, Rexán vacía el
  /// tablero y la pieza entra igual.
  ResultadoCaida entrar(PiezaEncaje pieza) {
    piezaActual = pieza;
    columna = (columnasEncaje - pieza.celdas) ~/ 2;
    altura = filasEncaje - 1;
    if (!_cabeEn(altura, columna, pieza.celdas)) {
      for (final fila in filas) {
        fila.clear();
      }
      vaciados++;
      return ResultadoCaida.tableroVaciado;
    }
    return ResultadoCaida.sigueCayendo;
  }

  /// Mueve la pieza a [destino] (columna izquierda) sin atravesar trozos.
  void moverA(int destino) {
    final pieza = piezaActual;
    if (pieza == null) return;
    final objetivo = destino.clamp(0, columnasEncaje - pieza.celdas);
    final paso = objetivo > columna ? 1 : -1;
    while (columna != objetivo &&
        _cabeEn(altura, columna + paso, pieza.celdas)) {
      columna += paso;
    }
  }

  /// Baja una fila. Si no puede, la pieza se encaja donde está.
  ResultadoCaida bajar() {
    final pieza = piezaActual;
    if (pieza == null) return ResultadoCaida.encajada;
    if (_cabeEn(altura - 1, columna, pieza.celdas)) {
      altura--;
      return ResultadoCaida.sigueCayendo;
    }
    _encajar(pieza);
    return ResultadoCaida.encajada;
  }

  /// La deja caer del todo.
  ResultadoCaida soltar() {
    var resultado = bajar();
    while (resultado == ResultadoCaida.sigueCayendo) {
      resultado = bajar();
    }
    return resultado;
  }

  void _encajar(PiezaEncaje pieza) {
    filas[altura].add(TrozoEncajado(inicio: columna, pieza: pieza));
    piezaActual = null;
    // Filas llenas: fuera, y lo de encima baja.
    for (var fila = 0; fila < filas.length;) {
      if (celdasOcupadas(fila) == columnasEncaje) {
        ultimaFilaCompletada = fila;
        filas.removeAt(fila);
        filas.add(<TrozoEncajado>[]);
        unidades++;
      } else {
        fila++;
      }
    }
  }

  /// Hueco de la fila incompleta más baja, en celdas (0 si no hay).
  int huecoMasBajo() {
    for (var fila = 0; fila < filas.length; fila++) {
      final ocupadas = celdasOcupadas(fila);
      if (ocupadas > 0 && ocupadas < columnasEncaje) {
        return columnasEncaje - ocupadas;
      }
    }
    return 0;
  }
}

class GeneradorEncaje {
  final math.Random _azar;
  final int dificultad;

  /// 1-3, sube con las unidades. Nivel 2: piezas escritas con fracciones
  /// equivalentes también en dificultad 1. Nivel 3: además, las anchuras
  /// de la dificultad siguiente.
  int nivel = 1;

  GeneradorEncaje({required this.dificultad, int? semilla})
      : _azar = math.Random(semilla);

  /// Anchuras permitidas (en celdas de 12) por dificultad.
  List<int> get _anchuras => switch (math.min(3, dificultad + (nivel >= 3 ? 1 : 0))) {
        1 => const [3, 6, 9], // cuartos y medios
        2 => const [2, 3, 4, 6, 8, 9, 10], // + tercios y sextos
        _ => const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], // + doceavos
      };

  /// La mitad de las veces trae justo la pieza que cierra la fila
  /// incompleta más baja (si su anchura está permitida): así el juego
  /// fluye y el niño aprende a leer "lo que falta".
  PiezaEncaje siguiente(TableroEncaje tablero) {
    final hueco = tablero.huecoMasBajo();
    final int celdas;
    if (hueco > 0 && _anchuras.contains(hueco) && _azar.nextBool()) {
      celdas = hueco;
    } else {
      celdas = _anchuras[_azar.nextInt(_anchuras.length)];
    }
    final valor = fraccionDeCeldas(celdas);
    return PiezaEncaje(valor: valor, etiqueta: _etiqueta(valor));
  }

  /// Desde dificultad 2, una de cada tres piezas se escribe con una
  /// fracción equivalente (FR.09): 1/2 → 2/4, 3/6 o 6/12…
  Fraccion _etiqueta(Fraccion valor) {
    if ((dificultad < 2 && nivel < 2) || _azar.nextInt(3) != 0) return valor;
    final factores = [
      for (var factor = 2; factor <= 4; factor++)
        if (valor.denominador * factor <= columnasEncaje) factor,
    ];
    if (factores.isEmpty) return valor;
    final factor = factores[_azar.nextInt(factores.length)];
    return Fraccion(valor.numerador * factor, valor.denominador * factor);
  }
}
