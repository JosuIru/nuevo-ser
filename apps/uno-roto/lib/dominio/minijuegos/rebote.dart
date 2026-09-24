import 'dart:math' as math;

import 'canales.dart' show Celda;

/// Rebote (segunda sala de Rexán): los focos de la Industria están
/// desviados. Hay que medir ángulos y llevar la luz hasta los receptores
/// rebotando en espejos.
///
/// 1. Medir un ángulo con el transportador (MED.04) y clasificarlo:
///    agudo, recto, obtuso o llano (GEO.01).
/// 2. El láser: el rayo baja, rebota en el espejo del suelo con el mismo
///    ángulo con el que llegó y sube a la diana. ¿Con qué ángulo hay que
///    dispararlo? Y: llega con 40°, ¿con cuántos sale? (MED.04)
/// 3. Simetría (GEO.07): dibujar el reflejo de una figura al otro lado
///    del espejo.
///
/// Los Destellos (el monstruo) se cruzan en el camino del rayo y se lo
/// tragan si pasa por encima: en el láser, algunos ángulos malos acaban
/// en uno.
enum TipoRebote { medir, clasificar, laser, reflexion, simetria }

enum TipoAngulo { agudo, recto, obtuso, llano }

TipoAngulo clasificarAngulo(int grados) => grados < 90
    ? TipoAngulo.agudo
    : grados == 90
        ? TipoAngulo.recto
        : grados < 180
            ? TipoAngulo.obtuso
            : TipoAngulo.llano;

/// El láser: emisor en la pared izquierda a [alturaEmisor], espejo en el
/// suelo, diana en la pared derecha (a [ancho]) a [alturaDiana].
class Laser {
  final double ancho;
  final double alturaEmisor;
  final double alturaDiana;

  const Laser(this.ancho, this.alturaEmisor, this.alturaDiana);

  /// Altura a la que llega a la pared derecha un rayo disparado hacia
  /// abajo con [grados] respecto a la horizontal (tras un rebote).
  double alturaDeLlegada(int grados) {
    final t = math.tan(grados * math.pi / 180);
    return ancho * t - alturaEmisor;
  }

  /// Dónde toca el suelo (el espejo).
  double puntoDeRebote(int grados) => alturaEmisor / math.tan(grados * math.pi / 180);
}

class RetoRebote {
  final TipoRebote tipo;

  /// Medir y clasificar: el ángulo dibujado. Reflexión: el de llegada.
  final int grados;

  final Laser? laser;

  /// Simetría: la figura (a la izquierda del espejo) y columnas totales.
  final Set<Celda> figura;
  final int columnas;
  final int filas;

  /// Destello en el camino (láser): posición (x, y) en el mundo.
  final (double, double)? destello;

  /// Respuesta numérica (medir, láser, reflexión) o índice de TipoAngulo.
  final int respuesta;
  final List<int> opciones;

  const RetoRebote({
    required this.tipo,
    required this.respuesta,
    this.grados = 0,
    this.laser,
    this.figura = const {},
    this.columnas = 0,
    this.filas = 0,
    this.destello,
    this.opciones = const [],
  });

  String get idHabilidad => switch (tipo) {
        TipoRebote.clasificar => 'GEO.01',
        TipoRebote.simetria => 'GEO.07',
        _ => 'MED.04',
      };

  /// Simetría: la figura reflejada en el espejo (entre la columna
  /// columnas/2 − 1 y columnas/2).
  Set<Celda> get reflejo => {
        for (final celda in figura) Celda(celda.fila, columnas - 1 - celda.columna),
      };
}

class GeneradorRebote {
  final math.Random _azar;

  GeneradorRebote({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoRebote generar(TipoRebote tipo, {int dificultad = 1}) {
    final paso = switch (dificultad) { 1 => 15, 2 => 5, _ => 5 };
    switch (tipo) {
      case TipoRebote.medir:
        final grados = paso * _entre(1, 170 ~/ paso);
        // Error típico: leer la escala al revés (180 − x).
        return RetoRebote(
          tipo: tipo,
          grados: grados,
          respuesta: grados,
          opciones: _opciones(grados, [180 - grados, grados + paso * 2, grados - paso * 2]),
        );
      case TipoRebote.clasificar:
        final tipoAngulo = TipoAngulo.values[_azar.nextInt(4)];
        final grados = switch (tipoAngulo) {
          TipoAngulo.agudo => paso * _entre(1, 89 ~/ paso),
          TipoAngulo.recto => 90,
          TipoAngulo.obtuso => 90 + paso * _entre(1, 89 ~/ paso),
          TipoAngulo.llano => 180,
        };
        return RetoRebote(
          tipo: tipo,
          grados: grados,
          respuesta: tipoAngulo.index,
          opciones: [for (final t in TipoAngulo.values) t.index],
        );
      case TipoRebote.laser:
        final angulos = dificultad == 1 ? const [30, 45, 60] : const [20, 30, 35, 40, 45, 50, 55, 60, 70];
        for (var intento = 0; intento < 500; intento++) {
          final grados = angulos[_azar.nextInt(angulos.length)];
          final ancho = 10.0;
          final alturaEmisor = 1.0 + _azar.nextInt(4);
          final laser = Laser(ancho, alturaEmisor, 0);
          final alturaDiana = laser.alturaDeLlegada(grados);
          if (alturaDiana < 1 || alturaDiana > 9) continue;
          final real = Laser(ancho, alturaEmisor, alturaDiana);
          final otros = [for (final a in angulos) if (a != grados) a]..shuffle(_azar);
          final opciones = [grados, ...otros.take(3)]..shuffle(_azar);
          // Un Destello en el camino de una opción mala (y lejos del bueno).
          final mala = otros.first;
          final xRebote = real.puntoDeRebote(mala);
          final destello = xRebote < ancho - 1 ? (xRebote + 1.2, 1.2 * math.tan(mala * math.pi / 180)) : null;
          return RetoRebote(
            tipo: tipo,
            laser: real,
            respuesta: grados,
            opciones: opciones,
            destello: destello,
          );
        }
        return RetoRebote(tipo: tipo, laser: const Laser(10, 2, 8), respuesta: 45, opciones: const [45, 30, 60, 20]);
      case TipoRebote.reflexion:
        final grados = paso * _entre(2, 80 ~/ paso);
        // Errores: el suplementario (180 − x) y el complementario (90 − x).
        return RetoRebote(
          tipo: tipo,
          grados: grados,
          respuesta: grados,
          opciones: _opciones(grados, [180 - grados, 90 - grados, grados + 10]),
        );
      case TipoRebote.simetria:
        const columnas = 8;
        const filas = 6;
        final cuantas = dificultad == 1 ? 4 : (dificultad == 2 ? 6 : 8);
        final figura = <Celda>{Celda(_entre(1, filas - 2), _entre(1, 3))};
        while (figura.length < cuantas) {
          final base = figura.elementAt(_azar.nextInt(figura.length));
          final vecina = [
            Celda(base.fila + 1, base.columna),
            Celda(base.fila - 1, base.columna),
            Celda(base.fila, base.columna + 1),
            Celda(base.fila, base.columna - 1),
          ][_azar.nextInt(4)];
          if (vecina.fila < 0 || vecina.fila >= filas || vecina.columna < 0 || vecina.columna >= columnas ~/ 2) {
            continue;
          }
          figura.add(vecina);
        }
        return RetoRebote(
          tipo: tipo,
          figura: figura,
          columnas: columnas,
          filas: filas,
          respuesta: 0,
        );
    }
  }

  List<int> _opciones(int respuesta, List<int> errores) {
    final elegidas = <int>{respuesta};
    for (final error in errores) {
      if (elegidas.length == 4) break;
      if (error > 0 && error <= 180) elegidas.add(error);
    }
    // Vecinos a un lado y a otro, alternando (con un ángulo pequeño, los
    // de abajo no valen y hay que seguir por arriba).
    for (var k = 1; elegidas.length < 4; k++) {
      final vecino = respuesta + (k.isOdd ? 5 * ((k + 1) ~/ 2) : -5 * (k ~/ 2));
      if (vecino > 0 && vecino <= 180) elegidas.add(vecino);
    }
    return elegidas.toList()..shuffle(_azar);
  }
}
