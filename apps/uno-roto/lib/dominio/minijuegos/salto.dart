import 'dart:math' as math;

import 'retos_calculo.dart';

/// Salto (máquina de Rexán): corredor rítmico al estilo Geometry Dash.
/// El Fragmento corre solo; tocar = saltar. Hay pinchos y, cada tramo,
/// una puerta doble: arriba (subiendo a una plataforma) o abajo (por el
/// suelo), cada una con un número. Sólo se pasa por la de la respuesta
/// correcta. Chocar no es "game over": se reaparece en la última marca.
///
/// Unidades de mundo: x a la derecha, y hacia arriba, suelo en y = 0.
class Pincho {
  final double x; // borde izquierdo; 1 de ancho, 1 de alto
  const Pincho(this.x);
}

class PuertaDoble {
  /// x de la puerta (las dos hojas están a la misma x).
  final double x;
  final RetoCalculo reto;
  final bool correctaArriba;

  const PuertaDoble({required this.x, required this.reto, required this.correctaArriba});

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
  static const largoTramo = 34.0;

  final math.Random _azar;
  final GeneradorRetosCalculo _generador;
  final List<String> habilidades;
  final int dificultad;
  final double velocidad;

  final List<Pincho> pinchos = [];
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
    math.Random? azar,
  })  : _azar = azar ?? math.Random(),
        _generador = GeneradorRetosCalculo(azar: azar),
        velocidad = switch (dificultad) { 1 => 6.0, 2 => 7.0, _ => 8.0 } {
    for (var i = 0; i < 3; i++) {
      _anadirTramo();
    }
  }

  /// La siguiente puerta por cruzar.
  PuertaDoble get puertaSiguiente => puertas[puertasPasadas];

  void _anadirTramo() {
    final inicio = puertas.isEmpty ? 0.0 : puertas.last.x + 3;
    final xPuerta = inicio + largoTramo;
    // Pinchos en la parte libre del tramo (lejos de la plataforma).
    var xPincho = inicio + 8 + _azar.nextDouble() * 3;
    final limite = xPuerta - 12;
    while (xPincho < limite) {
      pinchos.add(Pincho(xPincho));
      if (dificultad >= 2 && _azar.nextDouble() < 0.35) {
        pinchos.add(Pincho(xPincho + 1)); // pincho doble
      }
      xPincho += 7 + _azar.nextDouble() * 5;
    }
    final habilidad = habilidades[_azar.nextInt(habilidades.length)];
    puertas.add(PuertaDoble(
      x: xPuerta,
      reto: _generador.generar(habilidad, dificultad: dificultad),
      correctaArriba: _azar.nextBool(),
    ));
  }

  void saltar() {
    if (!enSuelo) return;
    vy = impulso;
    enSuelo = false;
  }

  bool _sobrePlataforma(double posicionX) => puertas.any((p) =>
      posicionX + lado > p.inicioPlataforma && posicionX < p.finPlataforma);

  EventoSalto avanzar(double dt) {
    final xAntes = x;
    final yAntes = y;
    x += velocidad * dt;
    vy += gravedad * dt;
    y += vy * dt;
    enSuelo = false;

    // Aterrizar en una plataforma (sólo cayendo y desde arriba).
    if (vy <= 0 &&
        yAntes >= alturaPlataforma - 0.05 &&
        y <= alturaPlataforma &&
        _sobrePlataforma(x)) {
      y = alturaPlataforma;
      vy = 0;
      enSuelo = true;
    }
    if (y <= 0) {
      y = 0;
      vy = 0;
      enSuelo = true;
    }
    giro = enSuelo ? (giro / (math.pi / 2)).roundToDouble() * (math.pi / 2) : giro + 7.5 * dt;

    // Pinchos (caja algo más pequeña que el dibujo: perdona el roce).
    for (final pincho in pinchos) {
      if (x + lado > pincho.x + 0.25 && x < pincho.x + 0.75 && y < 0.6) {
        return EventoSalto.choquePincho;
      }
    }

    // Puerta: al cruzar su x, ¿por qué carril va?
    final puerta = puertaSiguiente;
    if (xAntes + lado <= puerta.x && x + lado > puerta.x) {
      final vaArriba = y >= alturaPlataforma - 0.1;
      final indice = puertasPasadas;
      final habilidad = puerta.reto.idHabilidad;
      final acierta = vaArriba == puerta.correctaArriba;
      if (_intentadas.add(indice)) {
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
