import '../modelos/partida_planta.dart';
import '../modelos/repicado.dart';
import '../modelos/salida.dart';

/// Plantas vivas que quedan en una partida: las iniciales menos las mermas,
/// las repicadas a otras partidas y las que han salido. Nunca negativo.
int plantasDisponibles(
  PartidaPlanta partida, {
  required Iterable<Repicado> repicados,
  required Iterable<Salida> salidas,
}) {
  final repicadas = repicados
      .where((repicado) => repicado.partidaOrigenId == partida.id)
      .fold<int>(0, (suma, repicado) => suma + repicado.cantidad);
  final vendidas = salidas
      .where((salida) => salida.partidaId == partida.id)
      .fold<int>(0, (suma, salida) => suma + salida.cantidad);
  final disponibles =
      partida.cantidadInicial - partida.mermas - repicadas - vendidas;
  return disponibles < 0 ? 0 : disponibles;
}

/// Porcentaje de mermas sobre lo inicial (para el seguimiento de la
/// germinación y del arraigo). Nulo si la partida empezó vacía.
double? porcentajeMermas(PartidaPlanta partida) => partida.cantidadInicial <= 0
    ? null
    : partida.mermas * 100 / partida.cantidadInicial;

/// Fila del stock: plantas disponibles por especie, variedad y formato.
class FilaStock {
  const FilaStock({
    required this.especieId,
    required this.variedad,
    required this.formato,
    required this.disponibles,
    required this.listasParaVenta,
    required this.numeroPartidas,
  });

  final String especieId;
  final String variedad;
  final String formato;
  final int disponibles;

  /// De las disponibles, las de partidas marcadas como listas para venta.
  final int listasParaVenta;
  final int numeroPartidas;
}

/// Agrupa las partidas con plantas por especie, variedad y formato. Las
/// partidas agotadas no salen.
List<FilaStock> resumenStock({
  required Iterable<PartidaPlanta> partidas,
  required Iterable<Repicado> repicados,
  required Iterable<Salida> salidas,
}) {
  final listaRepicados = repicados.toList();
  final listaSalidas = salidas.toList();
  final acumulado = <(String, String, String), List<int>>{};
  for (final partida in partidas) {
    final disponibles = plantasDisponibles(partida,
        repicados: listaRepicados, salidas: listaSalidas);
    if (disponibles == 0) continue;
    final clave = (partida.especieId, partida.variedad, partida.formato);
    final fila = acumulado.putIfAbsent(clave, () => [0, 0, 0]);
    fila[0] += disponibles;
    if (partida.listaParaVenta) fila[1] += disponibles;
    fila[2] += 1;
  }
  final filas = [
    for (final entrada in acumulado.entries)
      FilaStock(
        especieId: entrada.key.$1,
        variedad: entrada.key.$2,
        formato: entrada.key.$3,
        disponibles: entrada.value[0],
        listasParaVenta: entrada.value[1],
        numeroPartidas: entrada.value[2],
      ),
  ];
  filas.sort((a, b) {
    final porEspecie = a.especieId.compareTo(b.especieId);
    if (porEspecie != 0) return porEspecie;
    final porVariedad = a.variedad.compareTo(b.variedad);
    return porVariedad != 0 ? porVariedad : a.formato.compareTo(b.formato);
  });
  return filas;
}
