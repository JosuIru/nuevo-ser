import 'dart:math' as math;

import 'canales.dart' show Celda;

/// La flota (máquina de Rexán): hundir la flota con las coordenadas
/// cantadas en cálculo ("columna: 25 % de 8; fila: 3/4 de 8"). Tocar la
/// casilla correcta es la decisión que cuenta; si se equivoca, se le
/// enseña cuál era y el disparo se hace igual (sin castigo).
enum ResultadoDisparo { agua, tocado, hundido }

class Barco {
  final List<Celda> casillas;
  final Set<Celda> tocadas = {};

  Barco(this.casillas);

  bool get hundido => tocadas.length == casillas.length;
}

/// Coordenada escrita como cálculo cuyo resultado es [valor] (1..8).
class CoordenadaCantada {
  final String idHabilidad;
  final String expresion;
  final int valor;

  const CoordenadaCantada(this.idHabilidad, this.expresion, this.valor);
}

class PartidaFlota {
  static const lado = 8;
  static const longitudes = [3, 2, 2];

  final math.Random _azar;
  final List<String> habilidades;
  final int dificultad;
  final List<Barco> barcos = [];
  final Map<Celda, ResultadoDisparo> disparos = {};

  late CoordenadaCantada columna;
  late CoordenadaCantada fila;
  int fallos = 0;
  final Map<String, int> fallosPorHabilidad = {};
  final Set<String> habilidadesUsadas = {};

  PartidaFlota({required this.habilidades, required this.dificultad, math.Random? azar})
      : _azar = azar ?? math.Random() {
    _colocarFlota();
    nuevoObjetivo();
  }

  Celda get objetivo => Celda(fila.valor - 1, columna.valor - 1);

  bool get flotaHundida => barcos.every((barco) => barco.hundido);

  void _colocarFlota() {
    final ocupadas = <Celda>{};
    for (final longitud in longitudes) {
      while (true) {
        final horizontal = _azar.nextBool();
        final f = _azar.nextInt(horizontal ? lado : lado - longitud + 1);
        final c = _azar.nextInt(horizontal ? lado - longitud + 1 : lado);
        final casillas = [
          for (var i = 0; i < longitud; i++)
            horizontal ? Celda(f, c + i) : Celda(f + i, c),
        ];
        if (casillas.any(ocupadas.contains)) continue;
        ocupadas.addAll(casillas);
        barcos.add(Barco(casillas));
        break;
      }
    }
  }

  /// Rexán elige el siguiente objetivo: a menudo cerca de los barcos que
  /// quedan (si no, la partida no avanza), a veces agua.
  void nuevoObjetivo() {
    final libres = [
      for (var f = 0; f < lado; f++)
        for (var c = 0; c < lado; c++)
          if (!disparos.containsKey(Celda(f, c))) Celda(f, c),
    ];
    final conBarco = libres
        .where((celda) => barcos.any((b) => b.casillas.contains(celda)))
        .toList();
    final celda = conBarco.isNotEmpty && _azar.nextDouble() < 0.65
        ? conBarco[_azar.nextInt(conBarco.length)]
        : libres[_azar.nextInt(libres.length)];
    columna = cantar(celda.columna + 1);
    fila = cantar(celda.fila + 1);
  }

  /// [valor] (1..8) escrito como porcentaje o fracción de una cantidad.
  CoordenadaCantada cantar(int valor) {
    final habilidad = habilidades[_azar.nextInt(habilidades.length)];
    habilidadesUsadas.add(habilidad);
    if (habilidad == 'FR.22') {
      // valor = n/d de cantidad, con cantidad = valor·d/n entera.
      for (var intento = 0; intento < 50; intento++) {
        final d = [2, 3, 4][_azar.nextInt(dificultad >= 2 ? 3 : 2)];
        final n = 1 + _azar.nextInt(d - 1);
        if ((valor * d) % n != 0) continue;
        final cantidad = valor * d ~/ n;
        return CoordenadaCantada('FR.22', '$n/$d de $cantidad', valor);
      }
      return CoordenadaCantada('FR.22', '1/2 de ${valor * 2}', valor);
    }
    // PROP.04: valor = p % de cantidad.
    final porcentajes = dificultad >= 2 ? [10, 20, 25, 50] : [10, 50];
    for (var intento = 0; intento < 50; intento++) {
      final p = porcentajes[_azar.nextInt(porcentajes.length)];
      if ((valor * 100) % p != 0) continue;
      final cantidad = valor * 100 ~/ p;
      if (cantidad > 80) continue;
      return CoordenadaCantada('PROP.04', '$p % de $cantidad', valor);
    }
    return CoordenadaCantada('PROP.04', '50 % de ${valor * 2}', valor);
  }

  /// El niño toca [celda]. Devuelve si acertó la coordenada; el disparo
  /// se hace siempre al objetivo verdadero.
  (bool, ResultadoDisparo) tocar(Celda celda) {
    final acierta = celda == objetivo;
    if (!acierta) {
      fallos++;
      for (final coordenada in [columna, fila]) {
        fallosPorHabilidad[coordenada.idHabilidad] =
            (fallosPorHabilidad[coordenada.idHabilidad] ?? 0) + 1;
      }
    }
    final resultado = _disparar(objetivo);
    return (acierta, resultado);
  }

  ResultadoDisparo _disparar(Celda celda) {
    for (final barco in barcos) {
      if (barco.casillas.contains(celda)) {
        barco.tocadas.add(celda);
        final resultado =
            barco.hundido ? ResultadoDisparo.hundido : ResultadoDisparo.tocado;
        disparos[celda] = resultado;
        if (barco.hundido) {
          for (final casilla in barco.casillas) {
            disparos[casilla] = ResultadoDisparo.hundido;
          }
        }
        return resultado;
      }
    }
    disparos[celda] = ResultadoDisparo.agua;
    return ResultadoDisparo.agua;
  }

  /// Resultado por habilidad para la maestría (acierto con ≤ 1 fallo).
  Map<String, bool> get aciertoPorHabilidad => {
        for (final habilidad in habilidadesUsadas)
          habilidad: (fallosPorHabilidad[habilidad] ?? 0) <= 1,
      };
}
