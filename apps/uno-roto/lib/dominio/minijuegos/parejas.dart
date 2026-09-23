import 'dart:math' as math;

import '../problema_espejo.dart' show Fraccion;

/// Parejas (máquina de Rexán): cartas boca arriba con el mismo valor
/// escrito de maneras distintas — 1/2, 2/4, 0,5, 50 %. El niño toca dos
/// que valen lo mismo y se retiran. Boca arriba a propósito: así un
/// fallo es de matemáticas, no de memoria, y la maestría es honesta.
///
/// Cada pareja ejercita una habilidad:
/// - FR.09: fracción ↔ fracción equivalente.
/// - DEC.08: fracción ↔ decimal.
/// - PROP.05: fracción ↔ porcentaje.
class CartaPareja {
  final int idPareja;
  final String etiqueta;

  const CartaPareja({required this.idPareja, required this.etiqueta});
}

class TableroParejas {
  final List<CartaPareja> cartas;

  /// Habilidad de cada pareja (por [CartaPareja.idPareja]).
  final Map<int, String> habilidadDePareja;

  /// Cartas sin pareja (nivel 3): escrituras de un error típico que
  /// parecen de algún valor del tablero y no lo son. Se quedan al final.
  final Set<int> trampas;

  final Set<int> retiradas = {};
  int intentosFallidos = 0;

  /// Fallos atribuidos a la habilidad de la primera carta tocada: es la
  /// que el niño intentaba emparejar.
  final Map<String, int> fallosPorHabilidad = {};

  TableroParejas({
    required this.cartas,
    required this.habilidadDePareja,
    this.trampas = const {},
  });

  bool get completo => retiradas.length == cartas.length - trampas.length;

  /// Acierto del tablero para la maestría: como mucho un intento fallido.
  bool get acierto => intentosFallidos <= 1;

  /// Resultado por habilidad presente en el tablero (acierto con como
  /// mucho un fallo en esa habilidad): lo que se registra en la maestría.
  Map<String, bool> get aciertoPorHabilidad => {
        for (final habilidad in habilidadDePareja.values.toSet())
          habilidad: (fallosPorHabilidad[habilidad] ?? 0) <= 1,
      };

  /// Intenta emparejar las cartas en las posiciones [a] y [b].
  bool emparejar(int a, int b) {
    if (a == b || retiradas.contains(a) || retiradas.contains(b)) return false;
    if (cartas[a].idPareja == cartas[b].idPareja) {
      retiradas.addAll([a, b]);
      return true;
    }
    intentosFallidos++;
    final habilidad = habilidadDePareja[cartas[a].idPareja];
    if (habilidad != null) {
      fallosPorHabilidad[habilidad] = (fallosPorHabilidad[habilidad] ?? 0) + 1;
    }
    return false;
  }
}

String _decimal(Fraccion valor) {
  final texto = valor.valor.toStringAsFixed(2).replaceAll('.', ',');
  // 0,50 → 0,5 ; 0,25 se queda.
  return texto.endsWith('0') ? texto.substring(0, texto.length - 1) : texto;
}

class GeneradorParejas {
  final math.Random _azar;

  GeneradorParejas({int? semilla}) : _azar = math.Random(semilla);

  /// Valores con decimal y porcentaje exactos y cortos (décimas, cuartos,
  /// quintos, medios).
  static const _valoresExactos = <Fraccion>[
    Fraccion(1, 2), Fraccion(1, 4), Fraccion(3, 4), Fraccion(1, 5),
    Fraccion(2, 5), Fraccion(3, 5), Fraccion(4, 5), Fraccion(1, 10),
    Fraccion(3, 10), Fraccion(7, 10), Fraccion(9, 10), Fraccion(1, 20),
  ];

  /// Valores para equivalencias de fracciones (se permiten tercios y
  /// sextos: no hace falta decimal exacto).
  static const _valoresFraccion = <Fraccion>[
    Fraccion(1, 2), Fraccion(1, 3), Fraccion(2, 3), Fraccion(1, 4),
    Fraccion(3, 4), Fraccion(1, 5), Fraccion(2, 5), Fraccion(1, 6),
    Fraccion(5, 6), Fraccion(3, 8),
  ];

  /// [habilidades]: las practicadas que tienen pareja (FR.09, DEC.08,
  /// PROP.05). [dificultad] 1-3: más parejas y amplificaciones mayores.
  /// [conTrampa]: una carta más, sin pareja (ver [TableroParejas.trampas]).
  TableroParejas generar(List<String> habilidades,
      {int dificultad = 1, bool conTrampa = false}) {
    final validas = habilidades
        .where((id) => const {'FR.09', 'DEC.08', 'PROP.05'}.contains(id))
        .toList();
    if (validas.isEmpty) validas.add('FR.09');
    final numeroParejas = dificultad >= 2 ? 8 : 6;
    final usados = <double>{};
    final cartas = <CartaPareja>[];
    final habilidadDePareja = <int, String>{};
    for (var id = 0; cartas.length < numeroParejas * 2; id++) {
      final habilidad = validas[_azar.nextInt(validas.length)];
      final catalogo =
          habilidad == 'FR.09' ? _valoresFraccion : _valoresExactos;
      final valor = catalogo[_azar.nextInt(catalogo.length)];
      // Un valor por tablero: si no, dos parejas se podrían cruzar.
      if (!usados.add(valor.valor)) {
        if (id > 500) break;
        continue;
      }
      final (izquierda, derecha) = _escrituras(habilidad, valor, dificultad);
      habilidadDePareja[id] = habilidad;
      cartas
        ..add(CartaPareja(idPareja: id, etiqueta: izquierda))
        ..add(CartaPareja(idPareja: id, etiqueta: derecha));
    }
    if (conTrampa) {
      final trampa = _cartaTrampa(cartas, habilidadDePareja, usados);
      if (trampa != null) cartas.add(trampa);
    }
    cartas.shuffle(_azar);
    return TableroParejas(
      cartas: cartas,
      habilidadDePareja: habilidadDePareja,
      trampas: {
        for (var i = 0; i < cartas.length; i++)
          if (cartas[i].idPareja == idTrampa) i,
      },
    );
  }

  static const idTrampa = -1;

  /// El error típico sobre un valor del tablero: 1/4 → "1,4" o "14 %"
  /// (pegar las cifras), 1/3 → "2/4" (sumar uno arriba y abajo). Sólo
  /// si su valor no coincide con ninguno del tablero.
  CartaPareja? _cartaTrampa(
      List<CartaPareja> cartas, Map<int, String> habilidadDePareja, Set<double> usados) {
    final ids = habilidadDePareja.keys.toList()..shuffle(_azar);
    for (final id in ids) {
      final etiqueta = cartas.firstWhere((c) => c.idPareja == id).etiqueta;
      final partes = etiqueta.split('/');
      if (partes.length != 2) continue;
      final n = int.parse(partes[0]);
      final d = int.parse(partes[1]);
      final (texto, valor) = switch (habilidadDePareja[id]) {
        'DEC.08' => ('$n,$d', double.parse('$n.$d')),
        'PROP.05' => ('$n$d %', int.parse('$n$d') / 100),
        _ => ('${n + 1}/${d + 1}', (n + 1) / (d + 1)),
      };
      if (usados.any((usado) => (usado - valor).abs() < 1e-9)) continue;
      if (cartas.any((c) => c.etiqueta == texto)) continue;
      return CartaPareja(idPareja: idTrampa, etiqueta: texto);
    }
    return null;
  }

  (String, String) _escrituras(String habilidad, Fraccion valor, int dificultad) {
    switch (habilidad) {
      case 'DEC.08':
        return (valor.etiqueta, _decimal(valor));
      case 'PROP.05':
        final porcentaje = (valor.valor * 100).round();
        return (valor.etiqueta, '$porcentaje %');
      default: // FR.09
        final maximoFactor = dificultad >= 3 ? 6 : (dificultad == 2 ? 4 : 3);
        final factor = 2 + _azar.nextInt(maximoFactor - 1);
        return (
          valor.etiqueta,
          Fraccion(valor.numerador * factor, valor.denominador * factor).etiqueta,
        );
    }
  }
}
