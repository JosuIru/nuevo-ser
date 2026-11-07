// Siembras escalonadas: la misma siembra repetida cada pocos días para que
// haya cosecha de ese cultivo todas las semanas. Lógica pura.

import '../modelos/siembra.dart';

/// Fechas de una serie de [numero] siembras cada [intervaloDias] desde
/// [primera]. Por días de calendario (no se mueven con el cambio de hora).
List<DateTime> fechasEscalonadas({
  required DateTime primera,
  required int numero,
  required int intervaloDias,
}) {
  if (numero <= 0 || intervaloDias <= 0) return const [];
  return [
    for (var orden = 0; orden < numero; orden++)
      DateTime(
          primera.year, primera.month, primera.day + orden * intervaloDias),
  ];
}

/// Siembras planificadas de una serie a partir de una [plantilla]: misma
/// cantidad, bancal y cultivo; cada una con su fecha prevista y su inicio de
/// cosecha desplazado lo mismo. Todas comparten [serie].
List<Siembra> planificarSerieEscalonada({
  required Siembra plantilla,
  required int numero,
  required int intervaloDias,
  required String serie,
  List<int>? bancalesPorOrden,
}) {
  final primera =
      DateTime.fromMillisecondsSinceEpoch(plantilla.fechaPrevistaMs);
  final fechas = fechasEscalonadas(
      primera: primera, numero: numero, intervaloDias: intervaloDias);
  final desfaseCosecha = plantilla.inicioCosechaPrevistaMs == null
      ? null
      : (DateTime.fromMillisecondsSinceEpoch(plantilla.inicioCosechaPrevistaMs!)
                  .difference(primera)
                  .inHours /
              24)
          .round();
  return [
    for (var orden = 0; orden < fechas.length; orden++)
      Siembra(
        bancalId: bancalesPorOrden != null && orden < bancalesPorOrden.length
            ? bancalesPorOrden[orden]
            : plantilla.bancalId,
        cultivoId: plantilla.cultivoId,
        tipo: plantilla.tipo,
        fechaPrevistaMs: fechas[orden].millisecondsSinceEpoch,
        loteSemillaId: plantilla.loteSemillaId,
        cantidad: plantilla.cantidad,
        unidad: plantilla.unidad,
        superficieM2: plantilla.superficieM2,
        inicioCosechaPrevistaMs: desfaseCosecha == null
            ? null
            : DateTime(fechas[orden].year, fechas[orden].month,
                    fechas[orden].day + desfaseCosecha)
                .millisecondsSinceEpoch,
        kgPrevistos: plantilla.kgPrevistos,
        serieEscalonada: serie,
        notas: plantilla.notas,
      ),
  ];
}
