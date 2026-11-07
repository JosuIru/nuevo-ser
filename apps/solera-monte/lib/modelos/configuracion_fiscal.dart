/// Regímenes que la app sabe distinguir. **PROVISIONAL**: lo confirma el
/// asesor fiscal (BLOQUEOS-PENDIENTES.md).
/// - `particular_reagp`: propietario particular en el régimen especial de la
///   agricultura, ganadería y pesca (Ley 37/1992, arts. 124-134).
/// - `particular_general`: propietario particular en régimen general de IVA.
/// - `comunidad_montes`: comunidad de montes vecinales en mano común (tiene
///   un régimen propio en el Impuesto sobre Sociedades: **por verificar**).
/// - `entidad_local`: junta vecinal, concejo o ayuntamiento (contabilidad
///   pública; el IVA de sus ventas, **por verificar**).
const List<String> regimenesFiscalesMonte = [
  'sin_elegir',
  'particular_reagp',
  'particular_general',
  'comunidad_montes',
  'entidad_local',
];

/// Compensación del REAGP para productos agrícolas **y forestales**, en %.
/// **PROVISIONAL**. Ley 37/1992 del IVA, art. 130.Cinco.1.º, texto
/// consolidado (https://www.boe.es/buscar/act.php?id=BOE-A-1992-28740,
/// última actualización publicada el 07/10/2026, leído el 2026-11-07): «El
/// 12 por 100, en las entregas de productos naturales obtenidos en
/// explotaciones agrícolas o forestales». Si la madera en pie o un
/// aprovechamiento vecinal es «entrega de productos naturales» de la
/// explotación lo confirma el asesor fiscal.
const double compensacionReagpForestalPorcentaje = 12;

/// IVA que la app propone en régimen general para la madera y la leña.
/// **PROVISIONAL, por verificar**: el tipo general, a falta de una regla
/// leída que dé otro.
const int tipoIvaVentaForestalPorDefecto = 21;

/// Ventas de producto forestal de la explotación: las únicas a las que la
/// app propone la compensación REAGP.
const List<String> categoriasVentaForestal = ['venta_madera', 'venta_lena'];

/// Ingresos que pueden ser cesión o arrendamiento (pastos, caza, lotes
/// vecinales) y no entrega de producto: la app no propone nada y avisa.
const List<String> categoriasIngresoDudosas = [
  'pastos',
  'caza',
  'lotes_vecinales',
  'hongos_frutos',
  'otros_aprovechamientos',
];

/// (tipo de IVA, % de compensación) que se proponen para un ingreso de
/// [categoria] con [regimen]. Solo la venta de madera o leña lleva algo; en
/// comunidades y entidades locales, nada (por verificar).
(int, double) impuestosVenta(String regimen, String categoria) {
  if (!categoriasVentaForestal.contains(categoria)) return (0, 0);
  return switch (regimen) {
    'particular_reagp' => (0, compensacionReagpForestalPorcentaje),
    'particular_general' => (tipoIvaVentaForestalPorDefecto, 0),
    _ => (0, 0),
  };
}

/// El ingreso necesita el aviso de «por verificar con el asesor».
bool necesitaAvisoFiscal(String regimen, String categoria) =>
    regimen == 'sin_elegir' ||
    regimen == 'comunidad_montes' ||
    regimen == 'entidad_local' ||
    categoriasIngresoDudosas.contains(categoria);
