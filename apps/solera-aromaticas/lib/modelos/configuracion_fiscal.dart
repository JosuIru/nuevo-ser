/// Regímenes de IVA que la app sabe apuntar.
const List<String> regimenesIva = ['sin_elegir', 'reagp', 'general'];

/// Compensación del REAGP para entregas de productos agrícolas, en %.
/// **PROVISIONAL**. Fuente leída el 2026-11-07 por la vertical Frutal: Ley
/// 37/1992 del IVA, art. 130.Cinco, texto consolidado,
/// https://www.boe.es/buscar/pdf/1992/BOE-A-1992-28740-consolidado.pdf
/// (12 % agrícolas y forestales). Lo confirma el asesor fiscal.
const double compensacionReagpAgricolaPorcentaje = 12;

/// IVA que la app propone en régimen general para la venta de planta.
/// **PROVISIONAL, por verificar**: 10 % si la planta va a la alimentación
/// (Ley 37/1992, art. 91.Uno.1.1.º); con otro destino puede ser el general.
const int tipoIvaVentaPlantaPorDefecto = 10;

/// IVA que la app propone para el aceite esencial y el hidrolato.
/// **PROVISIONAL, por verificar**: el tipo general a falta de una regla
/// leída; depende del destino (aromatizante alimentario, cosmético, químico).
const int tipoIvaVentaDestiladoPorDefecto = 21;

/// Venta de planta (fresca o seca): producto agrícola de la explotación.
const String categoriaVentaPlanta = 'venta_planta';

/// Ventas de lo destilado. La destilación **puede ser transformación** y
/// quedar fuera del REAGP: por verificar con el asesor fiscal. La app nunca
/// les pone compensación REAGP.
const List<String> categoriasVentaDestilado = [
  'venta_aceite_esencial',
  'venta_hidrolato',
];

/// Configuración fiscal del titular (tabla de una sola fila).
class ConfiguracionFiscal {
  ConfiguracionFiscal({this.id, this.regimenIva = 'sin_elegir'});

  final int? id;

  /// Uno de [regimenesIva].
  final String regimenIva;

  bool get estaConfigurada => regimenIva != 'sin_elegir';
  bool get esReagp => regimenIva == 'reagp';

  /// (tipo de IVA, % de compensación) que se proponen para un ingreso de
  /// [categoria]. Solo la venta de planta lleva compensación REAGP; lo
  /// destilado, IVA (también en REAGP: es lo conservador mientras no se
  /// aclare si es transformación). Sin régimen elegido, nada.
  (int, double) impuestosVenta(String categoria) {
    if (!estaConfigurada) return (0, 0);
    if (categoria == categoriaVentaPlanta) {
      return esReagp
          ? (0, compensacionReagpAgricolaPorcentaje)
          : (tipoIvaVentaPlantaPorDefecto, 0);
    }
    if (categoriasVentaDestilado.contains(categoria)) {
      return (tipoIvaVentaDestiladoPorDefecto, 0);
    }
    return (0, 0);
  }

  /// En REAGP, la venta de lo destilado necesita el aviso de «por verificar».
  bool avisoTransformacion(String categoria) =>
      esReagp && categoriasVentaDestilado.contains(categoria);

  Map<String, Object?> toMap() => {'id': id, 'regimen_iva': regimenIva};

  factory ConfiguracionFiscal.fromMap(Map<String, Object?> mapa) =>
      ConfiguracionFiscal(
        id: mapa['id'] as int?,
        regimenIva: regimenesIva.contains(mapa['regimen_iva'])
            ? mapa['regimen_iva'] as String
            : 'sin_elegir',
      );
}
