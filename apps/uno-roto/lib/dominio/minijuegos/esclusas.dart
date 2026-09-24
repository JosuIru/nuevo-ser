import 'dart:math' as math;

/// Esclusas (segunda sala de Rexán): los números bajan por un canal de
/// los Canales como barquitas de papel y hay que decidir antes de que
/// lleguen abajo. Tres maneras de jugar, una por nivel:
///
/// 1. **Sueltas**: abrir la esclusa de su rango — «menos de a/d», «entre
///    a/d y 1», «más de 1» (FR.05 comparar con el mismo denominador;
///    FR.04 comparar con la unidad).
/// 2. **Parejas** (los Comparadores, atados de dos en dos): tocar la que
///    vale más (FR.06 mismo numerador; FR.07 cualesquiera).
/// 3. **Tríos**: tocarlas de menor a mayor (FR.08 fracciones; DEC.03
///    decimales).
///
/// Si un grupo llega abajo sin decidir, Rexán lo devuelve arriba: no es
/// un error de matemáticas y no cuenta. Sólo el primer intento de cada
/// grupo cuenta para la maestría.
enum TipoCarga { suelta, pareja, trio }

enum EventoEsclusas { nada, acierto, fallo, devuelta, rondaTerminada }

class Barca {
  /// Cómo va escrita (puede ser un disfraz: 6/8 por 3/4).
  final String etiqueta;
  final double valor;

  const Barca(this.etiqueta, this.valor);
}

class Carga {
  final TipoCarga tipo;
  final List<Barca> barcas;
  final String idHabilidad;

  /// Sueltas: índice de la esclusa buena (0, 1, 2).
  final int? esclusaBuena;

  const Carga({
    required this.tipo,
    required this.barcas,
    required this.idHabilidad,
    this.esclusaBuena,
  });

  /// Índices de las barcas de menor a mayor (tríos) o la mayor primero
  /// (parejas: sólo importa la primera).
  List<int> get ordenBueno {
    final indices = List.generate(barcas.length, (i) => i)
      ..sort((a, b) => barcas[a].valor.compareTo(barcas[b].valor));
    return tipo == TipoCarga.pareja ? indices.reversed.toList() : indices;
  }
}

/// Los tres rangos de las sueltas de una ronda: umbral a/d con el mismo
/// denominador que las barcas, y la unidad.
class Esclusas {
  final int numerador;
  final int denominador;

  const Esclusas(this.numerador, this.denominador);

  double get umbral => numerador / denominador;

  int indiceDe(double valor) => valor < umbral ? 0 : (valor < 1 ? 1 : 2);
}

class PartidaEsclusas {
  static const cargasPorRonda = 6;

  final math.Random _azar;
  final int dificultad;
  final int nivel;
  final double velocidad;

  late final Esclusas esclusas;
  late Carga carga;

  /// 0 arriba, 1 en la compuerta de abajo.
  double posicion = 0;

  /// Tríos: cuántas barcas del grupo ya han pasado en orden.
  int pasadasDelGrupo = 0;

  int cargasHechas = 0;
  bool _intentado = false;
  bool _falloEnGrupo = false;
  final Map<String, int> fallosPorHabilidad = {};
  final Map<String, int> aciertosPorHabilidad = {};

  /// Barca o esclusa del último fallo (para que Rexán explique).
  Barca? ultimaEquivocada;

  /// «Sin prisas»: las barcas se paran antes de la compuerta y esperan.
  final bool sinPrisas;

  /// Hasta dónde bajan las barcas con «sin prisas».
  static const topeSinPrisas = 0.8;

  PartidaEsclusas({
    required this.nivel,
    required this.dificultad,
    this.sinPrisas = false,
    math.Random? azar,
  })  : _azar = azar ?? math.Random(),
        velocidad = switch (dificultad) { 1 => 0.07, 2 => 0.09, _ => 0.11 } {
    final denominador = _denominadores[_azar.nextInt(_denominadores.length)];
    esclusas = Esclusas(2 + _azar.nextInt(denominador - 3), denominador);
    carga = _cargaNueva();
  }

  List<int> get _denominadores =>
      dificultad == 1 ? const [4, 5, 6, 8] : const [6, 8, 10, 12];

  bool get terminada => cargasHechas >= cargasPorRonda;

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  /// Disfraz (dificultad 3): la misma fracción amplificada.
  Barca _fraccion(int n, int d) {
    if (dificultad >= 3 && _azar.nextDouble() < 0.35) {
      final factor = _entre(2, 3);
      return Barca('${n * factor}/${d * factor}', n / d);
    }
    return Barca('$n/$d', n / d);
  }

  Carga _cargaNueva() {
    switch (nivel) {
      case 1:
        final d = esclusas.denominador;
        int n;
        do {
          n = _entre(1, (d * 1.6).floor());
        } while (n == esclusas.numerador || n == d);
        final barca = _fraccion(n, d);
        return Carga(
          tipo: TipoCarga.suelta,
          barcas: [barca],
          idHabilidad: n > d ? 'FR.04' : 'FR.05',
          esclusaBuena: esclusas.indiceDe(barca.valor),
        );
      case 2:
        final mismoNumerador = _azar.nextBool();
        while (true) {
          final Barca a;
          final Barca b;
          if (mismoNumerador) {
            final n = _entre(1, 5);
            final d1 = _entre(n + 1, 12);
            final d2 = _entre(n + 1, 12);
            if (d1 == d2) continue;
            a = _fraccion(n, d1);
            b = _fraccion(n, d2);
          } else {
            final d1 = _entre(3, 12);
            final d2 = _entre(3, 12);
            final n1 = _entre(1, d1 - 1);
            final n2 = _entre(1, d2 - 1);
            if (n1 == n2 || d1 == d2) continue;
            a = _fraccion(n1, d1);
            b = _fraccion(n2, d2);
          }
          if ((a.valor - b.valor).abs() < 1e-9) continue;
          return Carga(
            tipo: TipoCarga.pareja,
            barcas: _azar.nextBool() ? [a, b] : [b, a],
            idHabilidad: mismoNumerador ? 'FR.06' : 'FR.07',
          );
        }
      default:
        final decimales = dificultad >= 2 && _azar.nextBool();
        final barcas = <Barca>[];
        final valores = <double>{};
        while (barcas.length < 3) {
          final Barca barca;
          if (decimales) {
            // Cifras de distinta longitud: el error de "0,45 > 0,5".
            final cifras = _entre(1, 3);
            final escala = math.pow(10, cifras).toInt();
            final entero = _entre(1, escala - 1);
            if (entero % 10 == 0 && cifras > 1) continue;
            barca = Barca('0,${entero.toString().padLeft(cifras, '0')}', entero / escala);
          } else {
            final d = _entre(3, 12);
            barca = _fraccion(_entre(1, d - 1), d);
          }
          if (valores.any((v) => (v - barca.valor).abs() < 1e-9)) continue;
          valores.add(barca.valor);
          barcas.add(barca);
        }
        return Carga(
          tipo: TipoCarga.trio,
          barcas: barcas,
          idHabilidad: decimales ? 'DEC.03' : 'FR.08',
        );
    }
  }

  /// El canal avanza. Si el grupo llega abajo sin decidir, vuelve arriba.
  EventoEsclusas avanzar(double dt) {
    if (terminada) return EventoEsclusas.nada;
    posicion += velocidad * dt;
    if (sinPrisas) {
      posicion = math.min(posicion, topeSinPrisas);
      return EventoEsclusas.nada;
    }
    if (posicion >= 1) {
      posicion = 0;
      pasadasDelGrupo = 0;
      return EventoEsclusas.devuelta;
    }
    return EventoEsclusas.nada;
  }

  /// Sueltas: abrir la esclusa [indice].
  EventoEsclusas abrir(int indice) {
    if (carga.tipo != TipoCarga.suelta || terminada) return EventoEsclusas.nada;
    if (indice == carga.esclusaBuena) return _grupoBien();
    ultimaEquivocada = carga.barcas.first;
    return _fallo();
  }

  /// Parejas y tríos: tocar la barca [indice].
  EventoEsclusas tocar(int indice) {
    if (carga.tipo == TipoCarga.suelta || terminada) return EventoEsclusas.nada;
    final esperada = carga.ordenBueno[pasadasDelGrupo];
    if (indice != esperada) {
      ultimaEquivocada = carga.barcas[indice];
      pasadasDelGrupo = 0; // el trío vuelve a empezar
      return _fallo();
    }
    pasadasDelGrupo++;
    final completo = carga.tipo == TipoCarga.pareja || pasadasDelGrupo == carga.barcas.length;
    return completo ? _grupoBien() : EventoEsclusas.acierto;
  }

  /// ¿Esta barca ya ha pasado (tríos a medio ordenar)?
  bool yaPasada(int indice) =>
      carga.tipo == TipoCarga.trio && carga.ordenBueno.take(pasadasDelGrupo).contains(indice);

  EventoEsclusas _fallo() {
    if (!_intentado) {
      _intentado = true;
      _falloEnGrupo = true;
      fallosPorHabilidad[carga.idHabilidad] = (fallosPorHabilidad[carga.idHabilidad] ?? 0) + 1;
    }
    return EventoEsclusas.fallo;
  }

  EventoEsclusas _grupoBien() {
    if (!_intentado && !_falloEnGrupo) {
      aciertosPorHabilidad[carga.idHabilidad] = (aciertosPorHabilidad[carga.idHabilidad] ?? 0) + 1;
    }
    cargasHechas++;
    _intentado = false;
    _falloEnGrupo = false;
    posicion = 0;
    pasadasDelGrupo = 0;
    if (terminada) return EventoEsclusas.rondaTerminada;
    carga = _cargaNueva();
    return EventoEsclusas.acierto;
  }

  /// Resultado por habilidad de la ronda (acierto con ≤ 1 fallo).
  Map<String, bool> resultadoRonda() => {
        for (final habilidad in {...aciertosPorHabilidad.keys, ...fallosPorHabilidad.keys})
          habilidad: (fallosPorHabilidad[habilidad] ?? 0) <= 1,
      };
}
