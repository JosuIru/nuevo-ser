import '../modelos/apunte_economico.dart';
import '../modelos/constantes.dart';
import '../modelos/convenio.dart';

/// Lo previsto y lo imputado de una partida del anexo II.
class FilaPartida {
  const FilaPartida(
      {required this.partida, required this.previsto, required this.real});

  /// Código del catálogo o texto propio; vacío = gastos sin partida.
  final String partida;
  final int previsto;
  final int real;
}

/// Un bloque del anexo II (I. Costes directos…) con sus partidas.
class BloquePartidas {
  const BloquePartidas({required this.bloque, required this.partidas});

  final String bloque;
  final List<FilaPartida> partidas;

  int get previsto => partidas.fold(0, (suma, fila) => suma + fila.previsto);
  int get real => partidas.fold(0, (suma, fila) => suma + fila.real);
  bool get vacio => partidas.isEmpty;
}

/// Previsto (presupuesto) frente a imputado (gastos apuntados y cuotas del
/// inventario) por bloque y partida. Salen todos los bloques del catálogo,
/// en su orden, aunque estén vacíos, y después los que no conoce esta
/// versión. Dentro de un bloque, las partidas van en el orden del catálogo
/// y luego las propias por nombre; los gastos sin partida, al final.
List<BloquePartidas> compararPartidas({
  required List<PartidaPresupuesto> presupuesto,
  required List<ApunteEconomico> apuntes,
}) {
  final previstos = <String, Map<String, int>>{};
  final reales = <String, Map<String, int>>{};
  for (final partida in presupuesto) {
    previstos.putIfAbsent(partida.categoria, () => {}).update(
        partida.partida, (total) => total + partida.importeCentimos,
        ifAbsent: () => partida.importeCentimos);
  }
  for (final apunte in apuntes) {
    if (apunte.tipo == 'ingreso') continue;
    reales.putIfAbsent(apunte.categoria, () => {}).update(
        apunte.partida, (total) => total + apunte.importeCentimos,
        ifAbsent: () => apunte.importeCentimos);
  }
  final bloques = [
    for (final opcion in categoriasGasto) opcion.codigo,
    for (final codigo in {...previstos.keys, ...reales.keys})
      if (!categoriasGasto.any((opcion) => opcion.codigo == codigo)) codigo,
  ];
  return [
    for (final bloque in bloques)
      BloquePartidas(
          bloque: bloque,
          partidas: () {
            final catalogo = partidasDe(bloque);
            final claves = {
              ...?previstos[bloque]?.keys,
              ...?reales[bloque]?.keys,
            }.toList()
              ..sort((a, b) {
                int orden(String clave) {
                  if (clave.isEmpty) return 1 << 20;
                  final indice =
                      catalogo.indexWhere((opcion) => opcion.codigo == clave);
                  return indice < 0 ? 1 << 10 : indice;
                }

                final porOrden = orden(a).compareTo(orden(b));
                return porOrden != 0
                    ? porOrden
                    : a.toLowerCase().compareTo(b.toLowerCase());
              });
            return [
              for (final clave in claves)
                FilaPartida(
                  partida: clave,
                  previsto: previstos[bloque]?[clave] ?? 0,
                  real: reales[bloque]?[clave] ?? 0,
                ),
            ];
          }()),
  ];
}
