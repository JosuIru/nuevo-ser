import '../modelos/apunte_economico.dart';

/// Totales de un periodo del libro de ingresos y gastos (en céntimos).
/// Orientativo: no es una liquidación de IVA ni de IRPF.
class ResumenEconomico {
  ResumenEconomico._({
    required this.ingresosBase,
    required this.gastosBase,
    required this.ivaRepercutido,
    required this.compensacionReagp,
    required this.ivaSoportado,
    required this.basePorCategoria,
  });

  final int ingresosBase;
  final int gastosBase;

  /// IVA cobrado en ventas del régimen general.
  final int ivaRepercutido;

  /// Compensación a tanto alzado cobrada en ventas del REAGP (la paga el
  /// comprador; no es IVA repercutido).
  final int compensacionReagp;

  /// IVA pagado en gastos. En el REAGP **no se deduce**: se enseña para que
  /// el asesor lo vea.
  final int ivaSoportado;

  /// Categoría → suma de bases.
  final Map<String, int> basePorCategoria;

  /// Ingresos menos gastos, sin IVA ni compensación.
  int get resultado => ingresosBase - gastosBase;

  factory ResumenEconomico.calcular(Iterable<ApunteEconomico> apuntes) {
    var ingresos = 0, gastos = 0, repercutido = 0, compensacion = 0;
    var soportado = 0;
    final porCategoria = <String, int>{};
    for (final apunte in apuntes) {
      if (apunte.esIngreso) {
        ingresos += apunte.baseCentimos;
        if (apunte.esReagp) {
          compensacion += apunte.cuotaCentimos;
        } else {
          repercutido += apunte.cuotaCentimos;
        }
      } else {
        gastos += apunte.baseCentimos;
        soportado += apunte.cuotaCentimos;
      }
      porCategoria.update(
          apunte.categoria, (suma) => suma + apunte.baseCentimos,
          ifAbsent: () => apunte.baseCentimos);
    }
    return ResumenEconomico._(
      ingresosBase: ingresos,
      gastosBase: gastos,
      ivaRepercutido: repercutido,
      compensacionReagp: compensacion,
      ivaSoportado: soportado,
      basePorCategoria: porCategoria,
    );
  }
}
