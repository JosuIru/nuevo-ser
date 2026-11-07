import '../modelos/apunte_economico.dart';

/// Totales de un periodo del libro de ingresos y gastos (céntimos).
/// Orientativo: no es una liquidación de impuestos.
class ResumenEconomico {
  ResumenEconomico._();

  int ingresosBase = 0;
  int gastosBase = 0;
  int ivaRepercutido = 0;
  int ivaSoportado = 0;
  int compensacionesReagp = 0;

  /// Ingresos menos gastos, sin impuestos.
  int get resultado => ingresosBase - gastosBase;

  /// Base de ingresos por parcela (sin parcela: clave null).
  final Map<int?, int> ingresosPorParcela = {};
  final Map<int?, int> gastosPorParcela = {};

  /// Base por categoría (ingresos y gastos): las ventas por canal.
  final Map<String, int> basePorCategoria = {};

  /// Margen (ingresos − gastos imputados) de una parcela.
  int margenParcela(int? parcelaId) =>
      (ingresosPorParcela[parcelaId] ?? 0) - (gastosPorParcela[parcelaId] ?? 0);

  static ResumenEconomico calcular(Iterable<ApunteEconomico> apuntes) {
    final resumen = ResumenEconomico._();
    for (final apunte in apuntes) {
      resumen.basePorCategoria.update(
          apunte.categoria, (valor) => valor + apunte.baseCentimos,
          ifAbsent: () => apunte.baseCentimos);
      if (apunte.esIngreso) {
        resumen.ingresosBase += apunte.baseCentimos;
        resumen.ivaRepercutido += apunte.cuotaIvaCentimos;
        resumen.compensacionesReagp += apunte.compensacionReagpCentimos;
        resumen.ingresosPorParcela.update(
            apunte.parcelaId, (valor) => valor + apunte.baseCentimos,
            ifAbsent: () => apunte.baseCentimos);
      } else {
        resumen.gastosBase += apunte.baseCentimos;
        resumen.ivaSoportado += apunte.cuotaIvaCentimos;
        resumen.gastosPorParcela.update(
            apunte.parcelaId, (valor) => valor + apunte.baseCentimos,
            ifAbsent: () => apunte.baseCentimos);
      }
    }
    return resumen;
  }
}
