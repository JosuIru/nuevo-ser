import 'dart:math' as math;

import 'canales.dart' show Celda, Direccion;
import 'retos_calculo.dart';

/// Serpiente (máquina de Rexán): en el tablero hay varios números y sólo
/// uno es la respuesta del reto. Comer el bueno la hace crecer; comer
/// otro no la castiga: el número desaparece y cuenta como fallo. Los
/// bordes se atraviesan y puede cruzarse consigo misma: no muere nunca.
enum EventoSerpiente { nada, correcto, incorrecto }

class PartidaSerpiente {
  static const columnas = 11;
  static const filas = 15;

  final math.Random _azar;
  final GeneradorRetosCalculo _generador;
  final List<String> habilidades;
  final int dificultad;

  List<Celda> cuerpo = [];
  Direccion direccion = Direccion.derecha;
  Direccion? _siguienteDireccion;
  late RetoCalculo reto;
  final Map<Celda, int> numeros = {};

  int correctosEnRonda = 0;
  final Map<String, int> fallosPorHabilidad = {};
  final Map<String, int> aciertosPorHabilidad = {};

  PartidaSerpiente({
    required this.habilidades,
    required this.dificultad,
    math.Random? azar,
  })  : _azar = azar ?? math.Random(),
        _generador = GeneradorRetosCalculo(azar: azar) {
    cuerpo = [const Celda(7, 3), const Celda(7, 2), const Celda(7, 1)];
    nuevoReto();
  }

  Celda get cabeza => cuerpo.first;

  void girar(Direccion nueva) {
    // No se puede dar media vuelta sobre sí misma de golpe.
    if (nueva.dFila == -direccion.dFila && nueva.dColumna == -direccion.dColumna) return;
    _siguienteDireccion = nueva;
  }

  void nuevoReto() {
    final habilidad = habilidades[_azar.nextInt(habilidades.length)];
    reto = _generador.generar(habilidad, dificultad: dificultad);
    numeros.clear();
    final valores = [reto.respuesta, ...reto.distractores];
    final libres = [
      for (var f = 0; f < filas; f++)
        for (var c = 0; c < columnas; c++)
          if (!cuerpo.contains(Celda(f, c)) &&
              (f - cabeza.fila).abs() + (c - cabeza.columna).abs() > 3)
            Celda(f, c),
    ]..shuffle(_azar);
    for (var i = 0; i < valores.length; i++) {
      numeros[libres[i]] = valores[i];
    }
  }

  EventoSerpiente avanzar() {
    final siguiente = _siguienteDireccion;
    if (siguiente != null) {
      direccion = siguiente;
      _siguienteDireccion = null;
    }
    final nueva = Celda(
      (cabeza.fila + direccion.dFila) % filas,
      (cabeza.columna + direccion.dColumna) % columnas,
    );
    cuerpo.insert(0, nueva);
    final valor = numeros.remove(nueva);
    if (valor == null) {
      cuerpo.removeLast();
      return EventoSerpiente.nada;
    }
    if (valor == reto.respuesta) {
      // Crece (no se quita la cola) y llega otro reto.
      correctosEnRonda++;
      aciertosPorHabilidad[reto.idHabilidad] =
          (aciertosPorHabilidad[reto.idHabilidad] ?? 0) + 1;
      nuevoReto();
      return EventoSerpiente.correcto;
    }
    cuerpo.removeLast();
    fallosPorHabilidad[reto.idHabilidad] =
        (fallosPorHabilidad[reto.idHabilidad] ?? 0) + 1;
    return EventoSerpiente.incorrecto;
  }

  /// Resultado por habilidad de la ronda (acierto con ≤ 1 fallo) y
  /// reinicio de los contadores.
  Map<String, bool> cerrarRonda() {
    final resultado = {
      for (final habilidad in {...aciertosPorHabilidad.keys, ...fallosPorHabilidad.keys})
        habilidad: (fallosPorHabilidad[habilidad] ?? 0) <= 1,
    };
    correctosEnRonda = 0;
    aciertosPorHabilidad.clear();
    fallosPorHabilidad.clear();
    return resultado;
  }
}
