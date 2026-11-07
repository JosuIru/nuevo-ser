import '../modelos/apunte_economico.dart';

/// Tipo de IVA que la app propone para una categoría (editable).
/// PROVISIONAL, leído en la LIVA consolidada (BOE-A-1992-28740) el
/// 2026-11-07, pendiente del asesor fiscal:
/// - manzana: fruta natural, 4 % (art. 91.Dos.1.1.º);
/// - sidra y txakoli: bebidas alcohólicas, fuera de los reducidos → 21 %
///   (art. 91.Uno.1.1.º a);
/// - txotx: comidas y bebidas para consumir en el acto, 10 %
///   (art. 91.Uno.2.2.º);
/// - fitosanitarios: plaguicidas de uso fitosanitario, 10 % (art. 91.Uno.1.3.º).
int tipoIvaPropuesto(String categoria) => switch (categoria) {
      'venta_manzana' || 'compra_manzana' => 4,
      'venta_txotx' || 'fitosanitarios' => 10,
      _ => 21,
    };

/// Si se propone la compensación del REAGP: solo en la venta de manzana
/// propia sin transformar de un titular en el REAGP (LIVA art. 130.Tres y
/// Cinco.1.º, 12 %). Elaborar sidra para venderla es transformación y queda
/// fuera del régimen (art. 126.Uno.1.º).
bool compensacionPropuesta(String categoria, String regimenFiscal) =>
    regimenFiscal == 'reagp' && categoriasActividadAgraria.contains(categoria);

/// Totales de un periodo del libro de ingresos y gastos (en céntimos).
class ResumenEconomico {
  ResumenEconomico._({
    required this.ingresosBase,
    required this.gastosBase,
    required this.ivaRepercutido,
    required this.ivaSoportado,
    required this.compensacionesCobradas,
    required this.compensacionesPagadas,
    required this.ingresosActividadAgraria,
    required this.basePorCategoria,
  });

  final int ingresosBase;
  final int gastosBase;
  final int ivaRepercutido;
  final int ivaSoportado;

  /// Compensaciones del REAGP cobradas al vender manzana.
  final int compensacionesCobradas;

  /// Compensaciones pagadas al comprar manzana a un agricultor en el REAGP.
  final int compensacionesPagadas;

  /// Base de los ingresos de actividad agraria (venta de manzana).
  final int ingresosActividadAgraria;
  final Map<String, int> basePorCategoria;

  int get resultado => ingresosBase - gastosBase;

  /// Base de los ingresos de transformación y servicios (sidra, txotx…).
  int get ingresosTransformacion => ingresosBase - ingresosActividadAgraria;

  /// IVA repercutido menos soportado: orientativo, no es una liquidación.
  int get diferenciaIva => ivaRepercutido - ivaSoportado;

  factory ResumenEconomico.calcular(Iterable<ApunteEconomico> apuntes) {
    var ingresos = 0,
        gastos = 0,
        repercutido = 0,
        soportado = 0,
        cobradas = 0,
        pagadas = 0,
        agraria = 0;
    final porCategoria = <String, int>{};
    for (final apunte in apuntes) {
      if (apunte.esIngreso) {
        ingresos += apunte.baseCentimos;
        repercutido += apunte.cuotaIvaCentimos;
        cobradas += apunte.compensacionReagpCentimos;
        if (categoriasActividadAgraria.contains(apunte.categoria)) {
          agraria += apunte.baseCentimos;
        }
      } else {
        gastos += apunte.baseCentimos;
        soportado += apunte.cuotaIvaCentimos;
        pagadas += apunte.compensacionReagpCentimos;
      }
      porCategoria.update(
          apunte.categoria, (suma) => suma + apunte.baseCentimos,
          ifAbsent: () => apunte.baseCentimos);
    }
    return ResumenEconomico._(
      ingresosBase: ingresos,
      gastosBase: gastos,
      ivaRepercutido: repercutido,
      ivaSoportado: soportado,
      compensacionesCobradas: cobradas,
      compensacionesPagadas: pagadas,
      ingresosActividadAgraria: agraria,
      basePorCategoria: porCategoria,
    );
  }
}
