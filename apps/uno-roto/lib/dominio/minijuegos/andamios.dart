import 'dart:math' as math;

/// Andamios (segunda sala de Rexán): para subir a arreglar las farolas de
/// la Montaña hacen falta plataformas cuadradas y escaleras justas.
///
/// 1. Plataformas (ARI.03): una plataforma cuadrada de 49 m²; ¿de cuánto
///    es el lado? (la raíz exacta).
/// 2. Escaleras (GEO.08): la farola está a 8 m y el pie de la escalera a
///    6 m de la pared; ¿qué escalera llega justa? (ternas pitagóricas).
/// 3. Apoyar (GEO.08): la escalera mide 10 y tiene que subir 8; ¿a qué
///    distancia de la pared se apoya?
///
/// Los Vértigos (el monstruo) son ráfagas de viento: si la medida no es
/// justa, la escalera se tambalea. Sin caídas.
enum TipoAndamio { plataforma, escalera, apoyar }

class RetoAndamio {
  final TipoAndamio tipo;

  /// Plataforma: [área]. Escalera: [alto, distancia]. Apoyar: [escalera, alto].
  final List<int> datos;

  final int respuesta;
  final List<int> opciones;

  const RetoAndamio({required this.tipo, required this.datos, required this.respuesta, required this.opciones});

  String get idHabilidad => tipo == TipoAndamio.plataforma ? 'ARI.03' : 'GEO.08';
}

/// Ternas pitagóricas (cateto, cateto, hipotenusa) sin escalar.
const ternasPitagoricas = [
  [3, 4, 5],
  [5, 12, 13],
  [8, 15, 17],
  [7, 24, 25],
];

class GeneradorAndamios {
  final math.Random _azar;

  GeneradorAndamios({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  /// (alto, distancia, escalera) de una terna escalada, al azar en qué
  /// cateto va contra la pared.
  (int, int, int) _terna(int dificultad) {
    final base = dificultad == 1 ? ternasPitagoricas[0] : ternasPitagoricas[_entre(0, dificultad == 2 ? 1 : 3)];
    final maximoFactor = base[2] <= 5 ? (dificultad == 1 ? 2 : 4) : 1;
    final factor = _entre(1, maximoFactor);
    final [a, b, c] = [for (final lado in base) lado * factor];
    return _azar.nextBool() ? (math.max(a, b), math.min(a, b), c) : (math.min(a, b), math.max(a, b), c);
  }

  RetoAndamio generar(TipoAndamio tipo, {int dificultad = 1}) {
    switch (tipo) {
      case TipoAndamio.plataforma:
        final lado = _entre(dificultad == 1 ? 2 : 4, dificultad == 1 ? 9 : (dificultad == 2 ? 12 : 15));
        final area = lado * lado;
        return _reto(tipo, [area], lado, [
          if (area.isEven) area ~/ 2, // dividir entre 2
          lado + 1,
          lado - 1,
          lado + 2,
        ]);
      case TipoAndamio.escalera:
        final (alto, distancia, escalera) = _terna(dificultad);
        return _reto(tipo, [alto, distancia], escalera, [
          alto + distancia, // sumar los dos catetos
          math.max(alto, distancia) + 1,
          escalera + 1,
          escalera - 1,
        ]);
      case TipoAndamio.apoyar:
        final (alto, distancia, escalera) = _terna(dificultad);
        return _reto(tipo, [escalera, alto], distancia, [
          escalera - alto, // restar sin elevar
          distancia + 1,
          distancia - 1,
          distancia + 2,
        ]);
    }
  }

  RetoAndamio _reto(TipoAndamio tipo, List<int> datos, int respuesta, List<int> errores) {
    final opciones = <int>{respuesta};
    for (final error in errores) {
      if (opciones.length == 4) break;
      if (error > 0) opciones.add(error);
    }
    var extra = 3;
    while (opciones.length < 4) {
      opciones.add(respuesta + extra);
      extra++;
    }
    return RetoAndamio(tipo: tipo, datos: datos, respuesta: respuesta, opciones: opciones.toList()..shuffle(_azar));
  }
}
