/// Regímenes de IVA que la app sabe apuntar.
const List<String> regimenesIva = ['sin_elegir', 'reagp', 'general'];

/// Compensación del REAGP para entregas de productos agrícolas, en %.
/// **PROVISIONAL**. Fuente leída el 2026-11-07: Ley 37/1992 del IVA,
/// art. 130.Cinco, texto consolidado (última modificación 07/10/2026),
/// https://www.boe.es/buscar/pdf/1992/BOE-A-1992-28740-consolidado.pdf
/// (12 % agrícolas y forestales). Lo confirma el asesor fiscal.
const double compensacionReagpAgricolaPorcentaje = 12;

/// Tipo de IVA que la app propone por defecto en una venta de cosecha en
/// régimen general. **PROVISIONAL**. Fuente leída el 2026-11-07: Ley 37/1992,
/// art. 91.Dos.1.1.º (frutas que sean productos naturales según el Código
/// Alimentario, cuyo 3.22.07 lista almendra, avellana, castaña y nuez). El
/// **pistacho no figura** en esa lista: su tipo queda para el asesor fiscal.
const int tipoIvaVentaCosechaPorDefecto = 4;

/// Configuración fiscal del titular (tabla de una sola fila).
class ConfiguracionFiscal {
  ConfiguracionFiscal({this.id, this.regimenIva = 'sin_elegir'});

  final int? id;

  /// Uno de [regimenesIva].
  final String regimenIva;

  bool get estaConfigurada => regimenIva != 'sin_elegir';
  bool get esReagp => regimenIva == 'reagp';

  /// (tipo de IVA, % de compensación) que se proponen para una venta de
  /// cosecha. En REAGP no hay IVA repercutido sino compensación; en general,
  /// IVA; sin elegir, ninguno de los dos (la persona lo completa).
  (int, double) impuestosVentaCosecha() => switch (regimenIva) {
        'reagp' => (0, compensacionReagpAgricolaPorcentaje),
        'general' => (tipoIvaVentaCosechaPorDefecto, 0),
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
