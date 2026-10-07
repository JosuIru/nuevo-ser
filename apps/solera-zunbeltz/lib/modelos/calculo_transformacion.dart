/// Calculadora de transformación: de un animal (o lote) de X kg vivos a kg
/// de producto vendible, ingreso, costes y margen. Sirve para comparar
/// caminos (vender en canal, despiece y venta directa, elaborado…).
///
/// Los porcentajes no vienen de serie: se apuntan en cada caso o se parte
/// de un rendimiento de referencia que pone coordinación en el WordPress.
class CalculoTransformacion {
  CalculoTransformacion({
    this.pesoVivoKg = 0,
    this.animales = 1,
    this.rendimientoCanalPorcentaje = 0,
    this.rendimientoProductoPorcentaje = 100,
    this.precioKgCentimos = 0,
    this.costeSacrificioCentimos = 0,
    this.costeTransformacionKgCentimos = 0,
    this.otrosCostesCentimos = 0,
  });

  /// Peso vivo de cada animal.
  final double pesoVivoKg;
  final int animales;

  /// kg de canal por cada 100 kg vivos.
  final double rendimientoCanalPorcentaje;

  /// kg de producto vendible por cada 100 kg de canal (100 = canal entera).
  final double rendimientoProductoPorcentaje;

  /// Precio de venta por kg de producto.
  final int precioKgCentimos;

  /// Matadero, por animal.
  final int costeSacrificioCentimos;

  /// Despiece, elaboración, envasado… por kg de producto.
  final int costeTransformacionKgCentimos;

  /// Transporte, etiquetas, tasas… del total.
  final int otrosCostesCentimos;

  double get kgVivosTotales => pesoVivoKg * animales;
  double get kgCanal => kgVivosTotales * rendimientoCanalPorcentaje / 100;
  double get kgProducto => kgCanal * rendimientoProductoPorcentaje / 100;

  int get ingresoCentimos => (kgProducto * precioKgCentimos).round();

  int get costesCentimos =>
      costeSacrificioCentimos * animales +
      (kgProducto * costeTransformacionKgCentimos).round() +
      otrosCostesCentimos;

  int get margenCentimos => ingresoCentimos - costesCentimos;

  /// A cuánto sale cada kg vivo por este camino (para comparar con vender
  /// el animal en vivo).
  int get margenPorKgVivoCentimos =>
      kgVivosTotales <= 0 ? 0 : (margenCentimos / kgVivosTotales).round();
}
