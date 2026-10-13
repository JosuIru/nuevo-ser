import 'apunte_economico.dart';
import 'constantes.dart';

/// Gastos de un proyecto o periodo agrupados como la hoja de seguimiento de
/// Zunbeltz: subtotal por bloque (I. Costes directos … VI. Amortización) y,
/// dentro de cada bloque, por partida.
class DesgloseGastos {
  DesgloseGastos._(this._totalPorBloque, this._totalPorPartida);

  factory DesgloseGastos.calcular(Iterable<ApunteEconomico> apuntes) {
    final totalPorBloque = <String, int>{};
    final totalPorPartida = <String, Map<String, int>>{};
    for (final apunte in apuntes) {
      if (apunte.tipo != 'gasto') continue;
      totalPorBloque.update(
          apunte.categoria, (total) => total + apunte.importeCentimos,
          ifAbsent: () => apunte.importeCentimos);
      totalPorPartida
          .putIfAbsent(apunte.categoria, () => {})
          .update(apunte.partida, (total) => total + apunte.importeCentimos,
              ifAbsent: () => apunte.importeCentimos);
    }
    return DesgloseGastos._(totalPorBloque, totalPorPartida);
  }

  final Map<String, int> _totalPorBloque;
  final Map<String, Map<String, int>> _totalPorPartida;

  bool get isEmpty => _totalPorBloque.isEmpty;
  bool get isNotEmpty => !isEmpty;

  int get totalCentimos =>
      _totalPorBloque.values.fold(0, (suma, total) => suma + total);

  /// Bloques con gasto, en el orden de la hoja (I → VI).
  List<String> get bloques => [
        for (final opcion in categoriasGasto)
          if (_totalPorBloque.containsKey(opcion.codigo)) opcion.codigo,
      ];

  int totalDe(String bloque) => _totalPorBloque[bloque] ?? 0;

  /// Partidas del bloque: primero las del catálogo en su orden, después las
  /// propias del proyecto de mayor a menor y, al final, lo apuntado sin
  /// partida (clave vacía).
  List<MapEntry<String, int>> partidasDe(String bloque) {
    final partidas = _totalPorPartida[bloque] ?? const {};
    final catalogo = partidasGasto[bloque] ?? const [];
    final codigosCatalogo = {for (final opcion in catalogo) opcion.codigo};
    final propias = partidas.entries
        .where((entrada) =>
            entrada.key.isNotEmpty && !codigosCatalogo.contains(entrada.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final opcion in catalogo)
        if (partidas.containsKey(opcion.codigo))
          MapEntry(opcion.codigo, partidas[opcion.codigo]!),
      ...propias,
      if (partidas.containsKey('')) MapEntry('', partidas['']!),
    ];
  }
}
