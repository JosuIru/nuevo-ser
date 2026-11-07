import '../modelos/apunte_economico.dart';

/// Totales de un periodo del libro de ingresos y gastos (céntimos).
/// Orientativo: no es una liquidación de impuestos ni la contabilidad de
/// una entidad local.
class ResumenEconomico {
  ResumenEconomico._();

  int ingresosBase = 0;
  int gastosBase = 0;
  int ivaRepercutido = 0;
  int ivaSoportado = 0;
  int compensacionesReagp = 0;

  /// Ingresos menos gastos, sin impuestos.
  int get resultado => ingresosBase - gastosBase;

  /// Base por categoría (ingresos y gastos por separado).
  final Map<String, int> ingresosPorCategoria = {};
  final Map<String, int> gastosPorCategoria = {};

  /// Base por rodal (sin rodal: clave null).
  final Map<int?, int> ingresosPorRodal = {};
  final Map<int?, int> gastosPorRodal = {};

  /// Margen (ingresos − gastos imputados) de un rodal.
  int margenRodal(int? rodalId) =>
      (ingresosPorRodal[rodalId] ?? 0) - (gastosPorRodal[rodalId] ?? 0);

  static void _sumar<K>(Map<K, int> mapa, K clave, int valor) =>
      mapa.update(clave, (actual) => actual + valor, ifAbsent: () => valor);

  static ResumenEconomico calcular(Iterable<ApunteEconomico> apuntes) {
    final resumen = ResumenEconomico._();
    for (final apunte in apuntes) {
      if (apunte.esIngreso) {
        resumen.ingresosBase += apunte.baseCentimos;
        resumen.ivaRepercutido += apunte.cuotaIvaCentimos;
        resumen.compensacionesReagp += apunte.compensacionReagpCentimos;
        _sumar(resumen.ingresosPorCategoria, apunte.categoria,
            apunte.baseCentimos);
        _sumar(resumen.ingresosPorRodal, apunte.rodalId, apunte.baseCentimos);
      } else {
        resumen.gastosBase += apunte.baseCentimos;
        resumen.ivaSoportado += apunte.cuotaIvaCentimos;
        _sumar(
            resumen.gastosPorCategoria, apunte.categoria, apunte.baseCentimos);
        _sumar(resumen.gastosPorRodal, apunte.rodalId, apunte.baseCentimos);
      }
    }
    return resumen;
  }
}
