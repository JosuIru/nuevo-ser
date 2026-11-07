// Qué se reparte en las cestas de una semana: la cosecha real con destino
// «cestas» si ya hay alguna; si no, la prevista por las siembras. Lógica pura.

import '../provisional_core/venta_directa/reparto_cestas.dart';

/// De dónde salen las existencias del reparto.
enum FuenteReparto { real, prevista, nada }

/// Existencias para [repartirCosecha]. Con cosecha real, por piezas los
/// cultivos que [porUnidades] dice y que tienen piezas apuntadas; el resto
/// en kilos. La prevista siempre en kilos. Ordenadas por id de cultivo
/// (el orden fija el turno de los empates).
({FuenteReparto fuente, List<ExistenciaReparto> existencias})
    existenciasParaReparto({
  required Map<int, ({double kg, int unidades})> real,
  required Map<int, double> prevista,
  required bool Function(int cultivoId) porUnidades,
}) {
  if (real.isNotEmpty) {
    final ids = real.keys.toList()..sort();
    return (
      fuente: FuenteReparto.real,
      existencias: [
        for (final id in ids)
          if (porUnidades(id) && real[id]!.unidades > 0)
            ExistenciaReparto(cultivoId: id, unidades: real[id]!.unidades)
          else if (real[id]!.kg > 0)
            ExistenciaReparto(cultivoId: id, kg: real[id]!.kg)
          else if (real[id]!.unidades > 0)
            ExistenciaReparto(cultivoId: id, unidades: real[id]!.unidades),
      ],
    );
  }
  if (prevista.isNotEmpty) {
    final ids = prevista.keys.toList()..sort();
    return (
      fuente: FuenteReparto.prevista,
      existencias: [
        for (final id in ids)
          if (prevista[id]! > 0)
            ExistenciaReparto(cultivoId: id, kg: prevista[id]!),
      ],
    );
  }
  return (fuente: FuenteReparto.nada, existencias: const []);
}
