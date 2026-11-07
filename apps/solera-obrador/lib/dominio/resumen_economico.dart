import '../modelos/apunte_economico.dart';
import '../modelos/receta.dart';
import 'composicion_receta.dart';

/// Totales de un periodo del libro de ingresos y gastos (en céntimos).
class ResumenEconomico {
  ResumenEconomico._(this.ingresosBase, this.gastosBase, this.ivaRepercutido,
      this.ivaSoportado, this.basePorCategoria);

  final int ingresosBase;
  final int gastosBase;
  final int ivaRepercutido;
  final int ivaSoportado;

  /// Categoría → suma de bases (ingresos y gastos juntos: las categorías no
  /// se solapan).
  final Map<String, int> basePorCategoria;

  /// Ingresos menos gastos, sin IVA.
  int get resultado => ingresosBase - gastosBase;

  /// IVA repercutido menos soportado (orientativo, no es una liquidación).
  int get diferenciaIva => ivaRepercutido - ivaSoportado;

  factory ResumenEconomico.calcular(Iterable<ApunteEconomico> apuntes) {
    var ingresos = 0, gastos = 0, repercutido = 0, soportado = 0;
    final porCategoria = <String, int>{};
    for (final apunte in apuntes) {
      if (apunte.esIngreso) {
        ingresos += apunte.baseCentimos;
        repercutido += apunte.cuotaIvaCentimos;
      } else {
        gastos += apunte.baseCentimos;
        soportado += apunte.cuotaIvaCentimos;
      }
      porCategoria.update(
          apunte.categoria, (suma) => suma + apunte.baseCentimos,
          ifAbsent: () => apunte.baseCentimos);
    }
    return ResumenEconomico._(
        ingresos, gastos, repercutido, soportado, porCategoria);
  }
}

/// Margen por pieza (precio sin IVA − coste de ingredientes) y su % sobre el
/// precio. Null si la receta no tiene precio. Solo cuenta ingredientes:
/// energía, mano de obra y envases van aparte.
({double margenCentimos, double porcentaje})? margenPorPieza(
    Receta receta, ComposicionReceta composicion) {
  if (receta.precioVentaCentimosPieza <= 0) return null;
  final margen =
      receta.precioVentaCentimosPieza - composicion.costeCentimosPieza;
  return (
    margenCentimos: margen,
    porcentaje: margen / receta.precioVentaCentimosPieza * 100
  );
}
