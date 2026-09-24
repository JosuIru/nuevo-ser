import 'dart:math' as math;

/// Nivelar (segunda sala de Rexán): los contenedores del muelle están mal
/// repartidos y el barco se escora. Las pilas son un gráfico de barras.
///
/// 1. Leer el gráfico (EST.01): cuántos hay en una pila, cuántos más
///    tiene una que otra.
/// 2. La media (EST.03): «si las igualas, ¿a qué altura quedan?». Mover
///    contenedores de las altas a las bajas no cambia la media: al
///    acertar, se ve cómo se nivelan.
/// 3. Mediana y moda (EST.04): ordenar y mirar la del medio; la altura
///    que más se repite.
///
/// El Oleaje (el monstruo) escora el barco según lo desigual que va la
/// carga; nivelado, el barco va derecho. Es ambiente, no castigo.
enum TipoPregunta { leerPila, diferencia, media, mediana, moda }

class RetoNivelar {
  final TipoPregunta tipo;
  final List<int> pilas;

  /// Pilas a las que se refiere la pregunta (leer, diferencia).
  final List<int> senaladas;

  /// La respuesta en medios contenedores (para la media 5,5 → 11).
  final int respuestaEnMedios;

  /// Cuatro opciones en medios, barajadas.
  final List<int> opcionesEnMedios;

  const RetoNivelar({
    required this.tipo,
    required this.pilas,
    required this.senaladas,
    required this.respuestaEnMedios,
    required this.opcionesEnMedios,
  });

  String get idHabilidad => switch (tipo) {
        TipoPregunta.leerPila || TipoPregunta.diferencia => 'EST.01',
        TipoPregunta.media => 'EST.03',
        TipoPregunta.mediana || TipoPregunta.moda => 'EST.04',
      };

  double get media => pilas.reduce((a, b) => a + b) / pilas.length;
}

/// 11 medios → "5,5"; 10 → "5".
String enMedios(int medios) => medios.isEven ? '${medios ~/ 2}' : '${medios ~/ 2},5';

class GeneradorNivelar {
  final math.Random _azar;

  GeneradorNivelar({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoNivelar generar(TipoPregunta tipo, {int dificultad = 1}) {
    for (var intento = 0; intento < 1000; intento++) {
      final reto = _intentar(tipo, dificultad);
      if (reto != null) return reto;
    }
    throw StateError('Nivelar: no se pudo generar $tipo');
  }

  List<int> _pilas(int cuantas) => [for (var i = 0; i < cuantas; i++) _entre(1, 9)];

  RetoNivelar? _intentar(TipoPregunta tipo, int dificultad) {
    switch (tipo) {
      case TipoPregunta.leerPila:
        final pilas = _pilas(dificultad == 1 ? 4 : 5);
        final i = _azar.nextInt(pilas.length);
        final v = pilas[i];
        return _reto(tipo, pilas, [i], v * 2, [v + 1, v - 1, pilas[(i + 1) % pilas.length], v + 2]);
      case TipoPregunta.diferencia:
        final pilas = _pilas(dificultad == 1 ? 4 : 5);
        final i = _azar.nextInt(pilas.length);
        final j = (i + 1 + _azar.nextInt(pilas.length - 1)) % pilas.length;
        if (pilas[i] <= pilas[j]) return null;
        final d = pilas[i] - pilas[j];
        return _reto(tipo, pilas, [i, j], d * 2, [pilas[i] + pilas[j], pilas[i], d + 1, d - 1]);
      case TipoPregunta.media:
        final cuantas = dificultad == 1 ? 4 : 5;
        final pilas = _pilas(cuantas);
        final suma = pilas.reduce((a, b) => a + b);
        // Media entera (dificultad 1-2) o con medio (dificultad 3).
        final medios = suma * 2 / cuantas;
        if (medios != medios.roundToDouble()) return null;
        final respuesta = medios.round();
        if (dificultad < 3 && respuesta.isOdd) return null;
        if (pilas.toSet().length < 3) return null;
        final ordenadas = [...pilas]..sort();
        final mediana = ordenadas[cuantas ~/ 2];
        return _reto(tipo, pilas, const [], respuesta, [
          mediana * 2, // la del medio no es la media
          suma * 2 ~/ (cuantas - 1), // repartir entre una menos
          (ordenadas.last - ordenadas.first) * 2, // el rango
          respuesta + 2,
        ]);
      case TipoPregunta.mediana:
        final cuantas = dificultad >= 3 ? 6 : 5;
        final pilas = _pilas(cuantas);
        final ordenadas = [...pilas]..sort();
        final respuesta = cuantas.isOdd
            ? ordenadas[cuantas ~/ 2] * 2
            : ordenadas[cuantas ~/ 2 - 1] + ordenadas[cuantas ~/ 2];
        final sinOrdenar = pilas[cuantas ~/ 2] * 2; // la del medio sin ordenar
        if (sinOrdenar == respuesta) return null;
        final media = (pilas.reduce((a, b) => a + b) * 2 / cuantas).round();
        return _reto(tipo, pilas, const [], respuesta,
            [sinOrdenar, media, ordenadas.last * 2, respuesta + 2]);
      case TipoPregunta.moda:
        final pilas = _pilas(dificultad == 1 ? 5 : 6);
        final cuentas = <int, int>{};
        for (final p in pilas) {
          cuentas[p] = (cuentas[p] ?? 0) + 1;
        }
        final maximo = cuentas.values.reduce(math.max);
        final modas = cuentas.entries.where((e) => e.value == maximo).map((e) => e.key).toList();
        if (maximo < 2 || modas.length != 1) return null; // una sola moda, clara
        final moda = modas.single;
        final masAlta = pilas.reduce(math.max);
        if (masAlta == moda) return null;
        return _reto(tipo, pilas, const [], moda * 2,
            [masAlta * 2, maximo * 2, pilas.first * 2, (moda + 1) * 2]);
    }
  }

  RetoNivelar? _reto(TipoPregunta tipo, List<int> pilas, List<int> senaladas, int respuesta,
      List<int> errores) {
    final opciones = <int>{respuesta};
    for (final error in errores) {
      if (opciones.length == 4) break;
      if (error > 0) opciones.add(error);
    }
    var desfase = 2;
    while (opciones.length < 4) {
      final vecino = respuesta + (desfase.isEven ? desfase : -desfase);
      if (vecino > 0) opciones.add(vecino);
      desfase++;
    }
    return RetoNivelar(
      tipo: tipo,
      pilas: pilas,
      senaladas: senaladas,
      respuestaEnMedios: respuesta,
      opcionesEnMedios: opciones.toList()..shuffle(_azar),
    );
  }
}

/// Cuánto se escora el barco: la desviación típica de las pilas.
double desequilibrio(List<num> pilas) {
  final media = pilas.fold<double>(0, (suma, p) => suma + p) / pilas.length;
  final varianza =
      pilas.fold<double>(0, (suma, p) => suma + (p - media) * (p - media)) / pilas.length;
  return math.sqrt(varianza);
}
