import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';

/// Una venta de planta (una salida con importe), con su especie.
class VentaPlanta {
  const VentaPlanta(
      {required this.fechaMs,
      required this.especieId,
      required this.cantidad,
      required this.baseCentimos,
      this.cliente = ''});

  final int fechaMs;
  final String especieId;
  final int cantidad;
  final int baseCentimos;
  final String cliente;
}

/// Totales de un periodo (céntimos): ventas de planta (de las salidas) más
/// los apuntes del libro. Orientativo: no es una liquidación de impuestos.
class ResumenEconomico {
  ResumenEconomico._();

  int ventasBase = 0;
  int otrosIngresosBase = 0;
  int gastosBase = 0;
  int ivaRepercutido = 0;
  int ivaSoportado = 0;
  int compensacionesReagp = 0;

  int get ingresosBase => ventasBase + otrosIngresosBase;

  /// Ingresos menos gastos, sin impuestos.
  int get resultado => ingresosBase - gastosBase;

  /// Base de las ventas de planta por especie.
  final Map<String, int> ventasPorEspecie = {};

  /// Gastos por categoría.
  final Map<String, int> gastosPorCategoria = {};

  /// Calcula el resumen. Las ventas toman el IVA o la compensación de la
  /// configuración fiscal **actual** (no se guardan con la salida): si se
  /// cambia de régimen, cambia el cálculo de todo el periodo.
  static ResumenEconomico calcular({
    required Iterable<ApunteEconomico> apuntes,
    required Iterable<VentaPlanta> ventas,
    required ConfiguracionFiscal configuracion,
  }) {
    final resumen = ResumenEconomico._();
    final (tipoIva, compensacion) = configuracion.impuestosVentaPlanta();
    for (final venta in ventas) {
      resumen.ventasBase += venta.baseCentimos;
      resumen.ivaRepercutido += (venta.baseCentimos * tipoIva / 100).round();
      resumen.compensacionesReagp +=
          (venta.baseCentimos * compensacion / 100).round();
      resumen.ventasPorEspecie.update(
          venta.especieId, (valor) => valor + venta.baseCentimos,
          ifAbsent: () => venta.baseCentimos);
    }
    for (final apunte in apuntes) {
      if (apunte.esIngreso) {
        resumen.otrosIngresosBase += apunte.baseCentimos;
        resumen.ivaRepercutido += apunte.cuotaIvaCentimos;
        resumen.compensacionesReagp += apunte.compensacionReagpCentimos;
      } else {
        resumen.gastosBase += apunte.baseCentimos;
        resumen.ivaSoportado += apunte.cuotaIvaCentimos;
        resumen.gastosPorCategoria.update(
            apunte.categoria, (valor) => valor + apunte.baseCentimos,
            ifAbsent: () => apunte.baseCentimos);
      }
    }
    return resumen;
  }
}
