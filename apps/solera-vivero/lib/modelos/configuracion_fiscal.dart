/// Regímenes de IVA que la app sabe apuntar.
const List<String> regimenesIva = ['sin_elegir', 'reagp', 'general'];

/// Compensación del REAGP en entregas de productos naturales de
/// explotaciones agrícolas o forestales, en %. **PROVISIONAL**. Fuente
/// leída el 2026-11-07: Ley 37/1992 del IVA, art. 130.Cinco.1.º, texto
/// consolidado (última modificación 07/10/2026),
/// https://www.boe.es/buscar/act.php?id=BOE-A-1992-28740.
/// Que un vivero entre en el REAGP (art. 124 y 125: explotaciones que
/// «obtengan directamente productos naturales, vegetales» de sus cultivos;
/// exclusiones del art. 126) lo decide el asesor fiscal: **por verificar**.
const double compensacionReagpAgricolaPorcentaje = 12;

/// Tipo de IVA que la app propone en una venta de planta en régimen
/// general. **PROVISIONAL**. Fuente leída el 2026-11-07: Ley 37/1992,
/// art. 91.Uno.1.8.º («las flores, las plantas vivas de carácter ornamental,
/// así como las semillas, bulbos, esquejes y otros productos de origen
/// exclusivamente vegetal susceptibles de ser utilizados en su obtención») y
/// 91.Uno.1.3.º (semillas y materiales vegetales de reproducción para
/// actividades agrícolas o forestales): 10 %. Lo confirma el asesor fiscal.
const int tipoIvaVentaPlantaPorDefecto = 10;

/// Configuración fiscal del vivero (tabla de una sola fila).
class ConfiguracionFiscal {
  ConfiguracionFiscal({this.id, this.regimenIva = 'sin_elegir'});

  final int? id;

  /// Uno de [regimenesIva].
  final String regimenIva;

  bool get estaConfigurada => regimenIva != 'sin_elegir';
  bool get esReagp => regimenIva == 'reagp';

  /// (tipo de IVA, % de compensación) de una venta de planta. En REAGP no
  /// hay IVA repercutido sino compensación; en general, IVA; sin elegir,
  /// ninguno de los dos.
  (int, double) impuestosVentaPlanta() => switch (regimenIva) {
        'reagp' => (0, compensacionReagpAgricolaPorcentaje),
        'general' => (tipoIvaVentaPlantaPorDefecto, 0),
        _ => (0, 0),
      };

  Map<String, Object?> toMap() => {'id': id, 'regimen_iva': regimenIva};

  factory ConfiguracionFiscal.fromMap(Map<String, Object?> mapa) =>
      ConfiguracionFiscal(
        id: mapa['id'] as int?,
        regimenIva: regimenesIva.contains(mapa['regimen_iva'])
            ? mapa['regimen_iva'] as String
            : 'sin_elegir',
      );
}
