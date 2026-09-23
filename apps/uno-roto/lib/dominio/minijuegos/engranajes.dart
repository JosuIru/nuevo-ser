import 'dart:math' as math;

/// Engranajes (segunda sala de Rexán): la grúa del Puerto sólo arranca
/// cuando las marcas rojas de sus ruedas coinciden.
///
/// - MCM (DIV.07): ruedas engranadas de a y b dientes, con una marca
///   arriba. ¿Tras cuántos dientes vuelven las dos marcas arriba a la
///   vez? El mínimo común múltiplo.
/// - MCD (DIV.06): dos cabos de a y b metros, cortados en trozos iguales
///   lo más largos posible. El máximo común divisor.
/// - Oxidado (DIV.07, nivel 3): una rueda cubierta de óxido; se sabe
///   cuándo coinciden y hay que elegir cuántos dientes tiene.
///
/// Se responde eligiendo entre cuatro opciones: la buena y los errores
/// típicos (multiplicar, sumar, confundir MCD con MCM).
enum TipoEngranaje { mcm, mcd, oxidado }

int mcd(int a, int b) => b == 0 ? a.abs() : mcd(b, a % b);
int mcm(int a, int b) => a ~/ mcd(a, b) * b;
int mcmDeTodos(Iterable<int> numeros) => numeros.reduce(mcm);

class RetoEngranajes {
  final TipoEngranaje tipo;

  /// Dientes de cada rueda (MCM, oxidado) o metros de cada cabo (MCD).
  /// En el oxidado, la rueda oxidada es la última.
  final List<int> numeros;

  /// Oxidado: tras cuántos dientes coinciden (el dato que se da).
  final int? coincidencia;

  final int respuesta;

  /// Cuatro valores distintos, barajados, con la respuesta entre ellos.
  final List<int> opciones;

  const RetoEngranajes({
    required this.tipo,
    required this.numeros,
    required this.respuesta,
    required this.opciones,
    this.coincidencia,
  });

  String get idHabilidad => tipo == TipoEngranaje.mcd ? 'DIV.06' : 'DIV.07';
}

class GeneradorEngranajes {
  final math.Random _azar;

  GeneradorEngranajes({math.Random? azar}) : _azar = azar ?? math.Random();

  /// Tamaños de rueda por dificultad: de tablas conocidas a números con
  /// factores escondidos.
  static const _ruedas = {
    1: [2, 3, 4, 5, 6, 8, 9, 10, 12],
    2: [4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20],
    3: [6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24],
  };

  static const _maximoMcm = {1: 36, 2: 90, 3: 144};

  RetoEngranajes generar(TipoEngranaje tipo, {int dificultad = 1}) {
    final nivel = dificultad.clamp(1, 3);
    return switch (tipo) {
      TipoEngranaje.mcm => _mcm(nivel),
      TipoEngranaje.mcd => _mcd(nivel),
      TipoEngranaje.oxidado => _oxidado(nivel),
    };
  }

  RetoEngranajes _mcm(int nivel) {
    final ruedas = _ruedas[nivel]!;
    for (var intento = 0; intento < 400; intento++) {
      final a = ruedas[_azar.nextInt(ruedas.length)];
      final b = ruedas[_azar.nextInt(ruedas.length)];
      if (a == b || a % b == 0 || b % a == 0) continue; // demasiado fácil
      final resultado = mcm(a, b);
      if (resultado > _maximoMcm[nivel]!) continue;
      // Que no sea siempre el producto: en dificultad 2-3, casi siempre
      // comparten un factor (el error de multiplicar se nota).
      if (nivel >= 2 && mcd(a, b) == 1 && _azar.nextDouble() < 0.75) continue;
      return RetoEngranajes(
        tipo: TipoEngranaje.mcm,
        numeros: [a, b],
        respuesta: resultado,
        opciones: _opciones(resultado, [a * b, a + b, mcd(a, b), resultado * 2]),
      );
    }
    return RetoEngranajes(
        tipo: TipoEngranaje.mcm,
        numeros: const [4, 6],
        respuesta: 12,
        opciones: _opciones(12, [24, 10, 2]));
  }

  /// Tres ruedas (nivel alto de MCM): se reutiliza el tipo mcm.
  RetoEngranajes tresRuedas({int dificultad = 2}) {
    final nivel = dificultad.clamp(1, 3);
    final ruedas = _ruedas[nivel]!;
    for (var intento = 0; intento < 600; intento++) {
      final elegidas = {for (var i = 0; i < 3; i++) ruedas[_azar.nextInt(ruedas.length)]}.toList();
      if (elegidas.length < 3) continue;
      final resultado = mcmDeTodos(elegidas);
      if (resultado > _maximoMcm[nivel]! * 2 || resultado == elegidas.reduce(math.max)) continue;
      final [a, b, c] = elegidas;
      return RetoEngranajes(
        tipo: TipoEngranaje.mcm,
        numeros: elegidas,
        respuesta: resultado,
        opciones: _opciones(resultado, [a * b * c, mcm(a, b), mcm(b, c), a + b + c, resultado * 2]),
      );
    }
    return tresRuedasPorDefecto;
  }

  static final tresRuedasPorDefecto = RetoEngranajes(
    tipo: TipoEngranaje.mcm,
    numeros: const [2, 3, 4],
    respuesta: 12,
    opciones: const [12, 24, 9, 6],
  );

  RetoEngranajes _mcd(int nivel) {
    final maximoCabo = switch (nivel) { 1 => 36, 2 => 60, _ => 96 };
    for (var intento = 0; intento < 400; intento++) {
      final trozo = 2 + _azar.nextInt(nivel == 1 ? 7 : 11); // 2..8 o 2..12
      final k1 = 2 + _azar.nextInt(5);
      final k2 = 2 + _azar.nextInt(5);
      if (k1 == k2 || mcd(k1, k2) != 1) continue; // si no, el MCD sería mayor
      final a = trozo * k1;
      final b = trozo * k2;
      if (a > maximoCabo || b > maximoCabo) continue;
      // Un divisor común más pequeño (cortes iguales pero no los más
      // largos): el error de quedarse corto.
      final divisoresComunes = [
        for (var d = 1; d < trozo; d++)
          if (trozo % d == 0) d,
      ];
      final pequeno = divisoresComunes.isEmpty ? 1 : divisoresComunes.last;
      return RetoEngranajes(
        tipo: TipoEngranaje.mcd,
        numeros: [a, b],
        respuesta: trozo,
        opciones: _opciones(trozo, [pequeno, mcm(a, b), (a - b).abs(), math.min(a, b)]),
      );
    }
    return RetoEngranajes(
        tipo: TipoEngranaje.mcd,
        numeros: const [24, 36],
        respuesta: 12,
        opciones: _opciones(12, [6, 72, 24]));
  }

  RetoEngranajes _oxidado(int nivel) {
    final ruedas = _ruedas[nivel]!;
    for (var intento = 0; intento < 600; intento++) {
      final a = ruedas[_azar.nextInt(ruedas.length)];
      final b = ruedas[_azar.nextInt(ruedas.length)];
      if (a == b) continue;
      final coincidencia = mcm(a, b);
      if (coincidencia > _maximoMcm[nivel]! || coincidencia == a) continue;
      // Distractores: tamaños de la estantería que NO dan esa coincidencia
      // con la rueda a (así sólo hay una respuesta buena).
      final malos = [
        for (final candidata in ruedas)
          if (candidata != b && mcm(a, candidata) != coincidencia) candidata,
      ]..shuffle(_azar);
      if (malos.length < 3) continue;
      // La única buena entre las cuatro: ningún otro tamaño de las
      // opciones puede dar la misma coincidencia.
      final opciones = [b, ...malos.take(3)]..shuffle(_azar);
      return RetoEngranajes(
        tipo: TipoEngranaje.oxidado,
        numeros: [a, b],
        coincidencia: coincidencia,
        respuesta: b,
        opciones: opciones,
      );
    }
    return RetoEngranajes(
        tipo: TipoEngranaje.oxidado,
        numeros: const [4, 6],
        coincidencia: 12,
        respuesta: 6,
        opciones: const [6, 8, 5, 10]);
  }

  /// La respuesta y tres errores distintos, positivos y distintos de
  /// ella; si faltan, vecinos cercanos.
  List<int> _opciones(int respuesta, List<int> errores) {
    final elegidas = <int>{respuesta};
    for (final error in errores) {
      if (elegidas.length == 4) break;
      if (error > 0) elegidas.add(error);
    }
    var desfase = 1;
    while (elegidas.length < 4) {
      final vecino = respuesta + (desfase.isOdd ? desfase : -desfase);
      if (vecino > 0) elegidas.add(vecino);
      desfase++;
    }
    return elegidas.toList()..shuffle(_azar);
  }
}
