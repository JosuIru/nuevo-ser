import 'dart:math' as math;

import 'canales.dart' show Celda, Direccion;
import 'retos_calculo.dart';

/// Serpiente (máquina de Rexán): en el tablero hay varios números y sólo
/// uno es la respuesta del reto. Comer el bueno la hace crecer; comer
/// otro no la castiga: el número desaparece y cuenta como fallo. Los
/// bordes se atraviesan y puede cruzarse consigo misma: no muere nunca.
///
/// Niveles (uno por ronda): 1, tablero libre; 2, muros (chocar sólo la
/// frena hasta que gire); 3, muros y números que se mueven.
enum EventoSerpiente { nada, correcto, incorrecto, muro }

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
  final Set<Celda> muros = {};

  /// 1-3: ver la cabecera.
  int nivel = 1;
  int _ticks = 0;

  int correctosEnRonda = 0;
  final Map<String, int> fallosPorHabilidad = {};
  final Map<String, int> aciertosPorHabilidad = {};

  /// «Sin prisas»: los números del nivel 3 se quedan quietos.
  final bool sinPrisas;

  PartidaSerpiente({
    required this.habilidades,
    required this.dificultad,
    this.sinPrisas = false,
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
              !muros.contains(Celda(f, c)) &&
              (f - cabeza.fila).abs() + (c - cabeza.columna).abs() > 3)
            Celda(f, c),
    ]..shuffle(_azar);
    for (var i = 0; i < valores.length; i++) {
      numeros[libres[i]] = valores[i];
    }
  }

  Celda _vecina(Celda celda, Direccion hacia) => Celda(
        (celda.fila + hacia.dFila) % filas,
        (celda.columna + hacia.dColumna) % columnas,
      );

  /// Sube de nivel: pone los muros (nivel 2+) y recoloca los números
  /// para que ninguno quede debajo de un muro.
  void cambiarNivel(int nuevoNivel) {
    nivel = nuevoNivel;
    muros.clear();
    if (nivel >= 2) _levantarMuros(nivel >= 3 ? 6 : 4);
    final valores = numeros.values.toList();
    numeros.clear();
    final libres = _celdasLibres()..shuffle(_azar);
    for (var i = 0; i < valores.length; i++) {
      numeros[libres[i]] = valores[i];
    }
  }

  List<Celda> _celdasLibres() => [
        for (var f = 0; f < filas; f++)
          for (var c = 0; c < columnas; c++)
            if (!cuerpo.contains(Celda(f, c)) &&
                !muros.contains(Celda(f, c)) &&
                !numeros.containsKey(Celda(f, c)) &&
                (f - cabeza.fila).abs() + (c - cabeza.columna).abs() > 3)
              Celda(f, c),
      ];

  /// Tramos rectos de 3-4 celdas, separados entre sí (ninguna celda de
  /// un muro toca, ni en diagonal, otro muro): así nunca encierran una
  /// zona y siempre se puede girar.
  void _levantarMuros(int cuantos) {
    var intentos = 0;
    var puestos = 0;
    while (puestos < cuantos && intentos++ < 500) {
      final horizontal = _azar.nextBool();
      final largo = 3 + _azar.nextInt(2);
      final fila = 1 + _azar.nextInt(filas - 2);
      final columna = 1 + _azar.nextInt(columnas - 2);
      final tramo = [
        for (var i = 0; i < largo; i++)
          horizontal ? Celda(fila, columna + i) : Celda(fila + i, columna),
      ];
      final cabe = tramo.every((celda) =>
          celda.fila < filas - 1 &&
          celda.columna < columnas - 1 &&
          !cuerpo.contains(celda) &&
          (celda.fila - cabeza.fila).abs() + (celda.columna - cabeza.columna).abs() > 3 &&
          !_tocaMuro(celda));
      if (!cabe) continue;
      muros.addAll(tramo);
      puestos++;
    }
  }

  bool _tocaMuro(Celda celda) {
    for (var df = -1; df <= 1; df++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (muros.contains(Celda(celda.fila + df, celda.columna + dc))) return true;
      }
    }
    return false;
  }

  /// Nivel 3: cada cuatro pasos cada número se desplaza a una casilla
  /// vecina libre (si la hay).
  void _moverNumeros() {
    final movidos = <Celda, int>{};
    for (final MapEntry(key: celda, value: valor) in numeros.entries) {
      final opciones = [
        for (final hacia in Direccion.values)
          if (!muros.contains(_vecina(celda, hacia)) &&
              !cuerpo.contains(_vecina(celda, hacia)) &&
              !numeros.containsKey(_vecina(celda, hacia)) &&
              !movidos.containsKey(_vecina(celda, hacia)) &&
              _vecina(celda, hacia) != _vecina(cabeza, direccion))
            _vecina(celda, hacia),
      ];
      final destino = opciones.isEmpty ? celda : opciones[_azar.nextInt(opciones.length)];
      movidos[movidos.containsKey(destino) ? celda : destino] = valor;
    }
    numeros
      ..clear()
      ..addAll(movidos);
  }

  EventoSerpiente avanzar() {
    final siguiente = _siguienteDireccion;
    if (siguiente != null) {
      direccion = siguiente;
      _siguienteDireccion = null;
    }
    _ticks++;
    if (nivel >= 3 && !sinPrisas && _ticks % 4 == 0) _moverNumeros();
    final nueva = _vecina(cabeza, direccion);
    if (muros.contains(nueva)) return EventoSerpiente.muro;
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
