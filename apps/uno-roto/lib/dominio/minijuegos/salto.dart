import 'dart:math' as math;

import 'retos_calculo.dart';

/// Salto (máquina de Rexán): corredor rítmico al estilo Geometry Dash.
/// El Fragmento corre solo; tocar = saltar. Hay obstáculos y, cada tramo,
/// una puerta doble: arriba (subiendo a una plataforma) o abajo (por el
/// suelo), cada una con un número. Sólo se pasa por la de la respuesta
/// correcta. Chocar no es "game over": se reaparece en la última marca.
///
/// Niveles (uno por ronda):
/// 1. Pinchos (dobles desde dificultad 2).
/// 2. Más pinchos, cajas (se saltan o se sube encima) y fosos.
/// 3. Además trampolines ante fosos anchos, pinchos triples (dificultad 3)
///    y puertas encadenadas: la cuenta parte del resultado de la anterior.
///
/// Unidades de mundo: x a la derecha, y hacia arriba, suelo en y = 0.
enum TipoObstaculo { pinchos, caja, foso, trampolin }

class Obstaculo {
  final TipoObstaculo tipo;

  /// Borde izquierdo.
  final double x;

  /// Pinchos: uno por unidad. Caja y trampolín: 1. Foso: el hueco.
  final double ancho;

  const Obstaculo(this.tipo, this.x, this.ancho);

  double get fin => x + ancho;
}

class PuertaDoble {
  /// x de la puerta (las dos hojas están a la misma x).
  final double x;
  final RetoCalculo reto;
  final bool correctaArriba;

  /// La cuenta usa el resultado de la puerta anterior (`{antes}` en el
  /// enunciado). Es un reto de lógica, no mide una habilidad del mapa:
  /// hay que acertarla para pasar, pero no se registra en la maestría.
  final bool encadenada;

  const PuertaDoble({
    required this.x,
    required this.reto,
    required this.correctaArriba,
    this.encadenada = false,
  });

  int get valorArriba => correctaArriba ? reto.respuesta : reto.distractores.first;
  int get valorAbajo => correctaArriba ? reto.distractores.first : reto.respuesta;

  /// Plataforma de acceso a la hoja de arriba (una sola dirección: se
  /// aterriza desde arriba; por debajo se pasa).
  double get inicioPlataforma => x - 6;
  double get finPlataforma => x + 2;
}

enum EventoSalto { nada, pasaPuerta, choquePincho, choquePuerta }

class PartidaSalto {
  static const alturaPlataforma = 2.2;
  static const lado = 0.9; // el cubo del Fragmento
  static const gravedad = -45.0;
  static const impulso = 15.0;
  static const impulsoTrampolin = 22.5;
  static const altoCaja = 1.0;
  static const largoTramo = 34.0;

  /// Por debajo de esta altura los pinchos pinchan (el dibujo mide 1:
  /// la caja de choque perdona el roce con la punta).
  static const alturaPeligroPincho = 0.5;

  final math.Random _azar;
  final GeneradorRetosCalculo _generador;
  final List<String> habilidades;
  final int dificultad;
  final double velocidad;

  /// Nivel con el que se generan los tramos nuevos (1-3).
  int nivel;

  final List<Obstaculo> obstaculos = [];
  final List<PuertaDoble> puertas = [];

  double x = 0;
  double y = 0;
  double vy = 0;
  bool enSuelo = true;

  /// Giro del cubo en el aire (radianes), como en el clásico.
  double giro = 0;

  /// Punto de reaparición (justo después de la última puerta pasada).
  double marca = 0;
  int puertasPasadas = 0;

  /// Índices de puertas ya intentadas (sólo el primer intento cuenta).
  final Set<int> _intentadas = {};
  final Map<String, int> fallosPorHabilidad = {};
  final Map<String, int> aciertosPorHabilidad = {};

  PartidaSalto({
    required this.habilidades,
    required this.dificultad,
    this.nivel = 1,
    math.Random? azar,
  })  : _azar = azar ?? math.Random(),
        _generador = GeneradorRetosCalculo(azar: azar),
        velocidad = switch (dificultad) { 1 => 6.0, 2 => 7.0, _ => 8.0 } {
    _anadirTramo();
    _anadirTramo();
  }

  /// La siguiente puerta por cruzar.
  PuertaDoble get puertaSiguiente => puertas[puertasPasadas];

  /// Sube de nivel y rehace lo que aún no se ve (lo que queda a más de
  /// diez unidades y las puertas por cruzar), para que el cambio se note
  /// desde el tramo siguiente.
  void cambiarNivel(int nuevoNivel) {
    if (nuevoNivel == nivel) return;
    nivel = nuevoNivel;
    final corte = x + 10;
    obstaculos.removeWhere((o) => o.x > corte);
    puertas.removeRange(puertasPasadas, puertas.length);
    _anadirTramo();
    _anadirTramo();
  }

  void _anadirTramo() {
    final inicio = puertas.isEmpty ? 0.0 : puertas.last.x + 3;
    final xPuerta = inicio + largoTramo;
    final finAnterior = obstaculos.fold(-100.0, (maximo, o) => math.max(maximo, o.fin));
    var xObstaculo = math.max(inicio + 8 + _azar.nextDouble() * 3, finAnterior + 6);
    // Lejos de la plataforma: da tiempo a decidir la puerta.
    final limite = xPuerta - 13;
    while (xObstaculo < limite) {
      final fin = _colocarObstaculo(xObstaculo, espacioHastaPuerta: xPuerta - xObstaculo);
      final separacion = nivel == 1 ? 7 + _azar.nextDouble() * 5 : 5 + _azar.nextDouble() * 4;
      xObstaculo = fin + separacion;
    }
    puertas.add(_puertaNueva(xPuerta));
  }

  /// Pone un obstáculo (o un grupo) en [x] y devuelve dónde acaba.
  double _colocarObstaculo(double x, {required double espacioHastaPuerta}) {
    final tirada = _azar.nextDouble();
    // Trampolín + foso ancho: el trampolín lanza muy alto y muy lejos,
    // así que sólo cabe lejos de la plataforma de la puerta.
    if (nivel >= 3 && tirada < 0.2 && espacioHastaPuerta > 20) {
      obstaculos.add(Obstaculo(TipoObstaculo.trampolin, x, 1));
      obstaculos.add(Obstaculo(TipoObstaculo.foso, x + 1.2, 3.8));
      return x + 5;
    }
    if (nivel >= 2 && tirada < 0.42) {
      obstaculos.add(Obstaculo(TipoObstaculo.caja, x, 1));
      return x + 1;
    }
    if (nivel >= 2 && tirada < 0.62) {
      obstaculos.add(Obstaculo(TipoObstaculo.foso, x, 2));
      return x + 2;
    }
    // Pinchos: triples sólo a la velocidad más alta (a menos velocidad el
    // salto apenas los cubre); dobles, más a menudo en niveles altos.
    final int cuantos;
    if (nivel >= 3 && dificultad >= 3 && _azar.nextDouble() < 0.4) {
      cuantos = 3;
    } else if (dificultad >= 2 || nivel >= 2) {
      cuantos = _azar.nextDouble() < (nivel >= 3 ? 0.55 : 0.35) ? 2 : 1;
    } else {
      cuantos = 1;
    }
    obstaculos.add(Obstaculo(TipoObstaculo.pinchos, x, cuantos.toDouble()));
    return x + cuantos;
  }

  PuertaDoble _puertaNueva(double xPuerta) {
    final anterior = puertas.isEmpty ? null : puertas.last;
    if (nivel >= 3 && anterior != null && !anterior.encadenada && _azar.nextDouble() < 0.5) {
      return PuertaDoble(
        x: xPuerta,
        reto: _retoEncadenado(anterior.reto),
        correctaArriba: _azar.nextBool(),
        encadenada: true,
      );
    }
    final habilidad = habilidades[_azar.nextInt(habilidades.length)];
    return PuertaDoble(
      x: xPuerta,
      reto: _generador.generar(habilidad, dificultad: dificultad),
      correctaArriba: _azar.nextBool(),
    );
  }

  /// "{antes} + 7", "{antes} × 2", "{antes} − 3" o "{antes} ÷ 2" sobre la
  /// respuesta de la puerta anterior. El distractor es la misma operación
  /// hecha sobre la respuesta equivocada de antes (el error de quien no se
  /// acuerda bien), o un resultado muy cercano.
  RetoCalculo _retoEncadenado(RetoCalculo anterior) {
    final antes = anterior.respuesta;
    final falsoAntes = anterior.distractores.first;
    final sumando = 3 + _azar.nextInt(7);
    final restando = 2 + _azar.nextInt(4);
    final operaciones = <(String, int Function(int))>[
      ('{antes} + $sumando', (valor) => valor + sumando),
      ('{antes} × 2', (valor) => valor * 2),
      if (antes > restando + 2) ('{antes} − $restando', (valor) => valor - restando),
      if (antes.isEven && antes >= 4) ('{antes} ÷ 2', (valor) => valor ~/ 2),
    ];
    final (enunciado, operar) = operaciones[_azar.nextInt(operaciones.length)];
    final respuesta = operar(antes);
    final esDivision = enunciado.contains('÷');
    final distractores = <int>{
      if (!esDivision || falsoAntes.isEven) operar(falsoAntes),
      respuesta + 1,
      respuesta - 1,
      respuesta + 2,
    }..removeWhere((valor) => valor <= 0 || valor == respuesta);
    return RetoCalculo(
      idHabilidad: anterior.idHabilidad,
      enunciado: enunciado,
      respuesta: respuesta,
      distractores: distractores.take(3).toList(),
    );
  }

  void saltar() {
    if (!enSuelo) return;
    vy = impulso;
    enSuelo = false;
  }

  bool _sobrePlataforma(double posicionX) => puertas.any((p) =>
      posicionX + lado > p.inicioPlataforma && posicionX < p.finPlataforma);

  /// Sobre un foso cuenta el centro del cubo: pisar el borde no hace caer.
  bool _sobreFoso(double posicionX) {
    final centro = posicionX + lado / 2;
    return obstaculos.any(
        (o) => o.tipo == TipoObstaculo.foso && centro > o.x && centro < o.fin);
  }

  EventoSalto avanzar(double dt) {
    final xAntes = x;
    final yAntes = y;
    x += velocidad * dt;
    vy += gravedad * dt;
    y += vy * dt;
    enSuelo = false;

    // Aterrizar en una plataforma o en una caja (sólo cayendo y desde arriba).
    if (vy <= 0) {
      if (yAntes >= alturaPlataforma - 0.05 && y <= alturaPlataforma && _sobrePlataforma(x)) {
        y = alturaPlataforma;
        vy = 0;
        enSuelo = true;
      }
      for (final caja in obstaculos) {
        if (caja.tipo == TipoObstaculo.caja &&
            yAntes >= altoCaja - 0.05 &&
            y <= altoCaja &&
            x + lado > caja.x &&
            x < caja.fin) {
          y = altoCaja;
          vy = 0;
          enSuelo = true;
        }
      }
    }
    // El suelo, salvo encima de un foso (si se ha hundido poco, el borde
    // lo recoge: perdona llegar justo).
    if (y <= 0 && yAntes >= -0.4 && !_sobreFoso(x)) {
      y = 0;
      vy = 0;
      enSuelo = true;
    }
    if (y < -1.5) return EventoSalto.choquePincho; // al fondo del foso

    giro = enSuelo ? (giro / (math.pi / 2)).roundToDouble() * (math.pi / 2) : giro + 7.5 * dt;

    for (final obstaculo in obstaculos) {
      if (obstaculo.fin < x - 1 || obstaculo.x > x + 2) continue;
      switch (obstaculo.tipo) {
        case TipoObstaculo.pinchos:
          if (x + lado > obstaculo.x + 0.3 &&
              x < obstaculo.fin - 0.3 &&
              y < alturaPeligroPincho &&
              y > -0.5) {
            return EventoSalto.choquePincho;
          }
        case TipoObstaculo.caja:
          // Contra el lado de la caja (no encima): choque.
          if (x + lado > obstaculo.x + 0.1 && x < obstaculo.fin - 0.1 && y < altoCaja - 0.2) {
            return EventoSalto.choquePincho;
          }
        case TipoObstaculo.trampolin:
          if (enSuelo && y == 0 && x + lado > obstaculo.x && x < obstaculo.fin) {
            vy = impulsoTrampolin;
            enSuelo = false;
          }
        case TipoObstaculo.foso:
          break;
      }
    }

    // Puerta: al cruzar su x, ¿por qué carril va?
    final puerta = puertaSiguiente;
    if (xAntes + lado <= puerta.x && x + lado > puerta.x) {
      final vaArriba = y >= alturaPlataforma - 0.1;
      final indice = puertasPasadas;
      final habilidad = puerta.reto.idHabilidad;
      final acierta = vaArriba == puerta.correctaArriba;
      if (_intentadas.add(indice) && !puerta.encadenada) {
        final mapa = acierta ? aciertosPorHabilidad : fallosPorHabilidad;
        mapa[habilidad] = (mapa[habilidad] ?? 0) + 1;
      }
      if (!acierta) return EventoSalto.choquePuerta;
      puertasPasadas++;
      marca = puerta.x + 2.5;
      _anadirTramo();
      return EventoSalto.pasaPuerta;
    }
    return EventoSalto.nada;
  }

  /// Tras un choque: de vuelta a la última marca, en el suelo.
  void reaparecer() {
    x = marca;
    y = 0;
    vy = 0;
    giro = 0;
    enSuelo = true;
  }

  /// Resultado por habilidad de la ronda (acierto con ≤ 1 fallo en el
  /// primer intento de sus puertas) y reinicio de los contadores.
  Map<String, bool> cerrarRonda() {
    final resultado = {
      for (final habilidad in {...aciertosPorHabilidad.keys, ...fallosPorHabilidad.keys})
        habilidad: (fallosPorHabilidad[habilidad] ?? 0) <= 1,
    };
    aciertosPorHabilidad.clear();
    fallosPorHabilidad.clear();
    return resultado;
  }
}
