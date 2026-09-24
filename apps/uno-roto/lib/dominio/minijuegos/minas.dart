import 'dart:math' as math;

import 'canales.dart' show ReglaCanales;

/// Minas (máquina de Rexán): buscaminas de divisibilidad. Cada casilla
/// lleva su número a la vista y la regla dice dónde están las minas
/// ("las minas son los múltiplos de 3"). Abrir es afirmar "segura";
/// marcar es afirmar "mina". Se comprueba al momento y, si se equivoca,
/// se enseña la verdad: marcar una segura la abre; abrir una mina, Rexán
/// la desactiva. Sin "game over".
///
/// Como en el clásico, cada casilla abierta dice cuántas minas tiene
/// alrededor: el niño puede cruzar su cuenta con la lógica del tablero.
enum EstadoCasilla { tapada, abierta, marcada, desactivada }

enum ResultadoJugada { ninguno, bien, fallo }

class CasillaMina {
  final String etiqueta;
  final bool esMina;
  EstadoCasilla estado = EstadoCasilla.tapada;

  CasillaMina({required this.etiqueta, required this.esMina});

  bool get resuelta => estado != EstadoCasilla.tapada;
}

/// Texto de la regla de minas por habilidad (castellano; `{n}` se
/// sustituye después).
const textosReglaMinas = <String, String>{
  'DIV.01': 'Las minas: múltiplos de {n}.',
  'DIV.02': 'Las minas: divisores de {n}.',
  'DIV.03': 'Las minas: divisibles entre {n}.',
  'DIV.04': 'Las minas: divisibles entre {n}.',
  'DIV.05': 'Las minas: números primos.',
};

class TableroMinas {
  final int filas;
  final int columnas;
  final List<CasillaMina> casillas;
  final ReglaCanales regla;
  int fallos = 0;

  TableroMinas({
    required this.filas,
    required this.columnas,
    required this.casillas,
    required this.regla,
  });

  factory TableroMinas.generar({
    required String idHabilidad,
    required int dificultad,
    int extra = 0,
    math.Random? azar,
  }) {
    final aleatorio = azar ?? math.Random();
    final regla = ReglaCanales.para(idHabilidad, dificultad, aleatorio) ??
        ReglaCanales.para('DIV.01', dificultad, aleatorio)!;
    final filas = dificultad >= 2 ? 7 : 6;
    final columnas = dificultad >= 2 ? 6 : 5;
    final numeros =
        regla.generar(aleatorio, filas * columnas, proporcion: 0.35 + 0.05 * extra);
    return TableroMinas(
      filas: filas,
      columnas: columnas,
      casillas: [
        for (final numero in numeros)
          CasillaMina(etiqueta: numero.etiqueta, esMina: numero.cumple),
      ],
      regla: regla,
    );
  }

  String get textoRegla =>
      textosReglaMinas[regla.idHabilidad] ?? 'Las minas: múltiplos de {n}.';

  List<int> vecinas(int indice) {
    final fila = indice ~/ columnas;
    final columna = indice % columnas;
    return [
      for (var df = -1; df <= 1; df++)
        for (var dc = -1; dc <= 1; dc++)
          if ((df != 0 || dc != 0) &&
              fila + df >= 0 &&
              fila + df < filas &&
              columna + dc >= 0 &&
              columna + dc < columnas)
            (fila + df) * columnas + columna + dc,
    ];
  }

  int minasAlrededor(int indice) =>
      vecinas(indice).where((vecina) => casillas[vecina].esMina).length;

  ResultadoJugada abrir(int indice) {
    final casilla = casillas[indice];
    if (casilla.resuelta) return ResultadoJugada.ninguno;
    if (casilla.esMina) {
      casilla.estado = EstadoCasilla.desactivada;
      fallos++;
      return ResultadoJugada.fallo;
    }
    casilla.estado = EstadoCasilla.abierta;
    return ResultadoJugada.bien;
  }

  ResultadoJugada marcar(int indice) {
    final casilla = casillas[indice];
    if (casilla.resuelta) return ResultadoJugada.ninguno;
    if (casilla.esMina) {
      casilla.estado = EstadoCasilla.marcada;
      return ResultadoJugada.bien;
    }
    casilla.estado = EstadoCasilla.abierta;
    fallos++;
    return ResultadoJugada.fallo;
  }

  int get pendientes => casillas.where((c) => !c.resuelta).length;
  bool get completo => pendientes == 0;

  /// Acierto del tablero para la maestría: como mucho dos fallos en
  /// treinta y tantas decisiones.
  bool get acierto => fallos <= 2;
}
