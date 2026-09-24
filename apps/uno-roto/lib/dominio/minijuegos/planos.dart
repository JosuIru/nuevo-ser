import 'dart:math' as math;

import 'canales.dart' show Celda;

/// Planos (segunda sala de Rexán): en las Afueras se construyen casas
/// nuevas y los planos se han mojado. Se redibuja cada habitación sobre
/// una cuadrícula (cada cuadro, 1 m²) con la medida que pide el encargo.
///
/// Encargos, uno por ronda (seis rondas en tres tramos):
/// 1. Área dada, cualquier rectángulo (GEO.03).
/// 2. Área dada con el menor perímetro posible, o perímetro dado con la
///    mayor área posible (GEO.02): mismo perímetro, áreas distintas.
/// 3. Triángulo (la mitad del rectángulo que lo contiene, GEO.04) y
///    encargos en dm² (MED.05: 1 m² = 100 dm²).
///
/// La Maleza (el monstruo) ocupa cuadros donde no se puede construir; en
/// dificultad alta crece mientras se piensa. No castiga: cambia el
/// problema. Construir encima no es un error de matemáticas.
enum TipoEncargo { area, areaMinimoPerimetro, perimetroMaximaArea, triangulo, unidades }

enum ResultadoPlano { bien, areaDistinta, perimetroDistinto, noOptimo, sobreMaleza, fuera }

class Rectangulo {
  final int columna;
  final int fila;
  final int ancho;
  final int alto;

  const Rectangulo(this.columna, this.fila, this.ancho, this.alto);

  /// Entre dos cuadros cualesquiera (esquinas opuestas), en cualquier orden.
  factory Rectangulo.entre(Celda a, Celda b) => Rectangulo(
        math.min(a.columna, b.columna),
        math.min(a.fila, b.fila),
        (a.columna - b.columna).abs() + 1,
        (a.fila - b.fila).abs() + 1,
      );

  int get area => ancho * alto;
  int get perimetro => 2 * (ancho + alto);

  Iterable<Celda> get celdas sync* {
    for (var f = fila; f < fila + alto; f++) {
      for (var c = columna; c < columna + ancho; c++) {
        yield Celda(f, c);
      }
    }
  }
}

class Encargo {
  final TipoEncargo tipo;

  /// Área en m² (area, areaMinimoPerimetro, triangulo), perímetro en m
  /// (perimetroMaximaArea) o área en dm² (unidades).
  final int valor;

  const Encargo(this.tipo, this.valor);

  String get idHabilidad => switch (tipo) {
        TipoEncargo.area => 'GEO.03',
        TipoEncargo.areaMinimoPerimetro || TipoEncargo.perimetroMaximaArea => 'GEO.02',
        TipoEncargo.triangulo => 'GEO.04',
        TipoEncargo.unidades => 'MED.05',
      };

  /// El área que tiene que tener el rectángulo dibujado (en m²).
  int? get areaPedida => switch (tipo) {
        TipoEncargo.area || TipoEncargo.areaMinimoPerimetro => valor,
        TipoEncargo.triangulo => valor * 2,
        TipoEncargo.unidades => valor ~/ 100,
        TipoEncargo.perimetroMaximaArea => null,
      };
}

class PartidaPlanos {
  static const columnas = 10;
  static const filas = 8;

  final math.Random _azar;
  final int dificultad;
  final Set<Celda> maleza = {};
  late final Encargo encargo;

  /// Si la maleza crece durante la ronda (nivel 3 en dificultad alta).
  final bool malezaViva;

  PartidaPlanos({
    required TipoEncargo tipo,
    required this.dificultad,
    this.malezaViva = false,
    math.Random? azar,
  }) : _azar = azar ?? math.Random() {
    for (var intento = 0; intento < 200; intento++) {
      final candidato = _encargo(tipo);
      maleza
        ..clear()
        ..addAll(_sembrarMaleza());
      if (_hayHuecoParaLaSolucion(candidato)) {
        encargo = candidato;
        return;
      }
    }
    maleza.clear();
    encargo = _encargo(tipo);
  }

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  /// Pares (ancho, alto) que caben en la cuadrícula.
  static Iterable<(int, int)> medidasPosibles() sync* {
    for (var ancho = 1; ancho <= columnas; ancho++) {
      for (var alto = 1; alto <= filas; alto++) {
        yield (ancho, alto);
      }
    }
  }

  Encargo _encargo(TipoEncargo tipo) {
    final maximoArea = switch (dificultad) { 1 => 24, 2 => 36, _ => 48 };
    switch (tipo) {
      case TipoEncargo.area:
        // Un área con al menos dos formas de hacerla (no sólo 1 × n).
        while (true) {
          final area = _entre(6, maximoArea);
          if (_formas(area).length >= 2) return Encargo(tipo, area);
        }
      case TipoEncargo.areaMinimoPerimetro:
        // Con varias formas y que el óptimo no sea la primera que se piensa.
        while (true) {
          final area = _entre(8, maximoArea);
          if (_formas(area).length >= 3) return Encargo(tipo, area);
        }
      case TipoEncargo.perimetroMaximaArea:
        while (true) {
          final perimetro = 2 * _entre(5, dificultad == 1 ? 9 : 13);
          if (areaMaxima(perimetro) != null) return Encargo(tipo, perimetro);
        }
      case TipoEncargo.triangulo:
        while (true) {
          final area = _entre(3, maximoArea ~/ 2);
          if (_formas(area * 2).isNotEmpty) return Encargo(tipo, area);
        }
      case TipoEncargo.unidades:
        while (true) {
          final area = _entre(4, maximoArea);
          if (_formas(area).isNotEmpty) return Encargo(tipo, area * 100);
        }
    }
  }

  /// Formas (ancho, alto) con esa área que caben en la cuadrícula.
  static List<(int, int)> _formas(int area) => [
        for (final (ancho, alto) in medidasPosibles())
          if (ancho * alto == area) (ancho, alto),
      ];

  /// El menor perímetro con el que se puede hacer [area] en la cuadrícula.
  static int? perimetroMinimo(int area) {
    final formas = _formas(area);
    if (formas.isEmpty) return null;
    return formas.map((f) => 2 * (f.$1 + f.$2)).reduce(math.min);
  }

  /// La mayor área que cabe con exactamente [perimetro] metros de valla.
  static int? areaMaxima(int perimetro) {
    int? mejor;
    for (final (ancho, alto) in medidasPosibles()) {
      if (2 * (ancho + alto) != perimetro) continue;
      if (mejor == null || ancho * alto > mejor) mejor = ancho * alto;
    }
    return mejor;
  }

  /// Las medidas que resuelven el encargo (las óptimas donde se pide).
  List<(int, int)> get medidasBuenas => [
        for (final (ancho, alto) in medidasPosibles())
          if (_medidaBuena(ancho, alto)) (ancho, alto),
      ];

  bool _medidaBuena(int ancho, int alto) {
    final area = ancho * alto;
    final perimetro = 2 * (ancho + alto);
    return switch (encargo.tipo) {
      TipoEncargo.area || TipoEncargo.unidades || TipoEncargo.triangulo =>
        area == encargo.areaPedida,
      TipoEncargo.areaMinimoPerimetro =>
        area == encargo.valor && perimetro == perimetroMinimo(encargo.valor),
      TipoEncargo.perimetroMaximaArea =>
        perimetro == encargo.valor && area == areaMaxima(encargo.valor),
    };
  }

  Set<Celda> _sembrarMaleza() {
    final cuantas = switch (dificultad) { 1 => 0, 2 => 5, _ => 8 };
    final celdas = <Celda>{};
    while (celdas.length < cuantas) {
      celdas.add(Celda(_azar.nextInt(filas), _azar.nextInt(columnas)));
    }
    return celdas;
  }

  /// Hay sitio para alguna solución buena sin pisar maleza.
  bool _hayHuecoParaLaSolucion(Encargo candidato) {
    final guardado = maleza.toSet();
    final anterior = _encargoProvisional;
    _encargoProvisional = candidato;
    try {
      return solucionesColocables().isNotEmpty;
    } finally {
      _encargoProvisional = anterior;
      maleza
        ..clear()
        ..addAll(guardado);
    }
  }

  Encargo? _encargoProvisional;

  Encargo get _encargoActual => _encargoProvisional ?? encargo;

  /// Rectángulos buenos que se pueden colocar ahora mismo.
  List<Rectangulo> solucionesColocables() {
    final encargoActual = _encargoActual;
    final buenas = [
      for (final (ancho, alto) in medidasPosibles())
        if (_medidaBuenaPara(encargoActual, ancho, alto)) (ancho, alto),
    ];
    return [
      for (final (ancho, alto) in buenas)
        for (var fila = 0; fila + alto <= filas; fila++)
          for (var columna = 0; columna + ancho <= columnas; columna++)
            if (!Rectangulo(columna, fila, ancho, alto).celdas.any(maleza.contains))
              Rectangulo(columna, fila, ancho, alto),
    ];
  }

  bool _medidaBuenaPara(Encargo e, int ancho, int alto) {
    final area = ancho * alto;
    final perimetro = 2 * (ancho + alto);
    return switch (e.tipo) {
      TipoEncargo.area || TipoEncargo.unidades || TipoEncargo.triangulo => area == e.areaPedida,
      TipoEncargo.areaMinimoPerimetro => area == e.valor && perimetro == perimetroMinimo(e.valor),
      TipoEncargo.perimetroMaximaArea => perimetro == e.valor && area == areaMaxima(e.valor),
    };
  }

  /// La maleza crece un cuadro, sin cerrar nunca la última solución.
  Celda? crecerMaleza() {
    final libres = [
      for (var f = 0; f < filas; f++)
        for (var c = 0; c < columnas; c++)
          if (!maleza.contains(Celda(f, c))) Celda(f, c),
    ]..shuffle(_azar);
    for (final celda in libres) {
      maleza.add(celda);
      if (solucionesColocables().isNotEmpty) return celda;
      maleza.remove(celda);
    }
    return null;
  }

  ResultadoPlano evaluar(Rectangulo plano) {
    if (plano.columna < 0 ||
        plano.fila < 0 ||
        plano.columna + plano.ancho > columnas ||
        plano.fila + plano.alto > filas) {
      return ResultadoPlano.fuera;
    }
    if (plano.celdas.any(maleza.contains)) return ResultadoPlano.sobreMaleza;
    if (_medidaBuena(plano.ancho, plano.alto)) return ResultadoPlano.bien;
    return switch (encargo.tipo) {
      TipoEncargo.perimetroMaximaArea => plano.perimetro != encargo.valor
          ? ResultadoPlano.perimetroDistinto
          : ResultadoPlano.noOptimo,
      TipoEncargo.areaMinimoPerimetro => plano.area != encargo.valor
          ? ResultadoPlano.areaDistinta
          : ResultadoPlano.noOptimo,
      _ => ResultadoPlano.areaDistinta,
    };
  }
}

/// «Casa completa» (reto de la semana): tres habitaciones que no se pisen
/// entre sí ni pisen maleza y que sumen [total] m². Se genera a partir de
/// una solución, así que siempre hay al menos una.
class CasaCompleta {
  static const habitaciones = 3;

  final int total;
  final Set<Celda> maleza;
  final List<Rectangulo> solucion;

  const CasaCompleta({required this.total, required this.maleza, required this.solucion});

  factory CasaCompleta.generar({int dificultad = 1, math.Random? azar}) {
    final aleatorio = azar ?? math.Random();
    final maximo = switch (dificultad) { 1 => 36, 2 => 48, _ => 60 };
    while (true) {
      final ocupadas = <Celda>{};
      final solucion = <Rectangulo>[];
      for (var intento = 0; intento < 200 && solucion.length < habitaciones; intento++) {
        final ancho = 2 + aleatorio.nextInt(4);
        final alto = 2 + aleatorio.nextInt(3);
        final habitacion = Rectangulo(aleatorio.nextInt(PartidaPlanos.columnas - ancho + 1),
            aleatorio.nextInt(PartidaPlanos.filas - alto + 1), ancho, alto);
        if (habitacion.celdas.any(ocupadas.contains)) continue;
        solucion.add(habitacion);
        ocupadas.addAll(habitacion.celdas);
      }
      final total = solucion.fold(0, (suma, r) => suma + r.area);
      if (solucion.length < habitaciones || total < 20 || total > maximo) continue;
      final cuantas = switch (dificultad) { 1 => 0, 2 => 4, _ => 7 };
      final maleza = <Celda>{};
      while (maleza.length < cuantas) {
        final celda = Celda(aleatorio.nextInt(PartidaPlanos.filas), aleatorio.nextInt(PartidaPlanos.columnas));
        if (!ocupadas.contains(celda)) maleza.add(celda);
      }
      return CasaCompleta(total: total, maleza: maleza, solucion: solucion);
    }
  }

  /// Si [nueva] pisa alguna de las ya [puestas].
  static bool solapa(Rectangulo nueva, List<Rectangulo> puestas) {
    final celdas = nueva.celdas.toSet();
    return puestas.any((puesta) => puesta.celdas.any(celdas.contains));
  }

  static int suma(List<Rectangulo> puestas) => puestas.fold(0, (suma, r) => suma + r.area);
}
