// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/sidra/dop_sidra_txakoli.csv
// Generado: 2026-11-07
// Filas: 8 (0 firmadas por persona, 8 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-sidra && dart run tool/compilar_catalogos.dart

class ProductoDop {
  const ProductoDop({
    required this.id,
    required this.nombre,
    required this.dop,
    required this.producto,
    required this.gradoMin,
    required this.acidezVolatilMaxGL,
    required this.sulfurosoTotalMaxMgL,
    required this.extractoSecoMinGL,
    required this.densidadMostoMin,
    required this.rendimientoMinPct,
    required this.rendimientoMaxPct,
    required this.rendimientoEsLimite,
    required this.fuente,
  });

  final String id;
  final String nombre;
  final String dop;
  final String producto;
  final double? gradoMin;
  final double? acidezVolatilMaxGL;
  final double? sulfurosoTotalMaxMgL;
  final double? extractoSecoMinGL;
  final double? densidadMostoMin;
  final double? rendimientoMinPct;
  final double? rendimientoMaxPct;
  final bool rendimientoEsLimite;
  final String fuente;
}

const List<ProductoDop> catalogoProductosDop = [
  ProductoDop(
      id: 'euskal_sagardoa',
      nombre: 'Euskal Sagardoa / Sidra del País Vasco',
      dop: 'euskal_sagardoa',
      producto: 'sidra',
      gradoMin: 5.0,
      acidezVolatilMaxGL: 2.2,
      sulfurosoTotalMaxMgL: 100.0,
      extractoSecoMinGL: 14.0,
      densidadMostoMin: 1045.0,
      rendimientoMinPct: 40.0,
      rendimientoMaxPct: 75.0,
      rendimientoEsLimite: false,
      fuente:
          'fuente_publica: pliego DOP Euskal Sagardoa (19/07/2024) ap. C.3.1, F.2 y F.3'),
  ProductoDop(
      id: 'euskal_sagardoa_gazi_gozoa',
      nombre: 'Euskal Sagardoa «Gazi-gozoa»',
      dop: 'euskal_sagardoa',
      producto: 'sidra',
      gradoMin: 4.5,
      acidezVolatilMaxGL: 1.22,
      sulfurosoTotalMaxMgL: 150.0,
      extractoSecoMinGL: 16.0,
      densidadMostoMin: 1045.0,
      rendimientoMinPct: 40.0,
      rendimientoMaxPct: 75.0,
      rendimientoEsLimite: false,
      fuente:
          'fuente_publica: pliego DOP Euskal Sagardoa (19/07/2024) ap. C.3.2, F.2 y F.3'),
  ProductoDop(
      id: 'euskal_sagardo_aparduna',
      nombre: 'Euskal Sagardo Aparduna / Sidra Espumosa del País Vasco',
      dop: 'euskal_sagardoa',
      producto: 'sidra',
      gradoMin: 4.5,
      acidezVolatilMaxGL: 2.2,
      sulfurosoTotalMaxMgL: 150.0,
      extractoSecoMinGL: 14.0,
      densidadMostoMin: 1045.0,
      rendimientoMinPct: 40.0,
      rendimientoMaxPct: 75.0,
      rendimientoEsLimite: false,
      fuente:
          'fuente_publica: pliego DOP Euskal Sagardoa (19/07/2024) ap. C.3.3, F.2 y F.3'),
  ProductoDop(
      id: 'sidra_asturias_natural',
      nombre: 'Sidra de Asturias · sidra natural',
      dop: 'sidra_asturias',
      producto: 'sidra',
      gradoMin: 5.0,
      acidezVolatilMaxGL: 2.2,
      sulfurosoTotalMaxMgL: 150.0,
      extractoSecoMinGL: null,
      densidadMostoMin: null,
      rendimientoMinPct: null,
      rendimientoMaxPct: 80.0,
      rendimientoEsLimite: true,
      fuente:
          'fuente_publica: pliego DOP Sidra de Asturias (asturias.es, DOP-Sidra-Normal25) ap. B.3 y rendimiento de extracción'),
  ProductoDop(
      id: 'sidra_asturias_espumosa',
      nombre: 'Sidra de Asturias · sidra natural espumosa',
      dop: 'sidra_asturias',
      producto: 'sidra',
      gradoMin: 5.5,
      acidezVolatilMaxGL: 2.2,
      sulfurosoTotalMaxMgL: 200.0,
      extractoSecoMinGL: null,
      densidadMostoMin: null,
      rendimientoMinPct: null,
      rendimientoMaxPct: 80.0,
      rendimientoEsLimite: true,
      fuente:
          'fuente_publica: pliego DOP Sidra de Asturias (asturias.es, DOP-Sidra-Normal25) ap. B.3 y rendimiento de extracción'),
  ProductoDop(
      id: 'bizkaiko_txakolina_blanco',
      nombre: 'Bizkaiko Txakolina · blanco',
      dop: 'bizkaiko_txakolina',
      producto: 'txakoli',
      gradoMin: 10.5,
      acidezVolatilMaxGL: 0.7,
      sulfurosoTotalMaxMgL: 180.0,
      extractoSecoMinGL: null,
      densidadMostoMin: null,
      rendimientoMinPct: null,
      rendimientoMaxPct: 70.0,
      rendimientoEsLimite: true,
      fuente:
          'fuente_publica: pliego Bizkaiko Txakolina consolidado (28/11/2024) ap. 2.a.1 y 5.1'),
  ProductoDop(
      id: 'arabako_txakolina_blanco',
      nombre: 'Arabako Txakolina · blanco',
      dop: 'arabako_txakolina',
      producto: 'txakoli',
      gradoMin: 9.5,
      acidezVolatilMaxGL: 0.8,
      sulfurosoTotalMaxMgL: 180.0,
      extractoSecoMinGL: null,
      densidadMostoMin: null,
      rendimientoMinPct: null,
      rendimientoMaxPct: 70.0,
      rendimientoEsLimite: true,
      fuente:
          'fuente_publica: pliego Arabako Txakolina consolidado (19/12/2024) ap. 2.a y 5'),
  ProductoDop(
      id: 'getariako_txakolina_blanco',
      nombre: 'Getariako Txakolina · blanco',
      dop: 'getariako_txakolina',
      producto: 'txakoli',
      gradoMin: 9.5,
      acidezVolatilMaxGL: 0.8,
      sulfurosoTotalMaxMgL: 180.0,
      extractoSecoMinGL: null,
      densidadMostoMin: null,
      rendimientoMinPct: null,
      rendimientoMaxPct: 72.0,
      rendimientoEsLimite: true,
      fuente:
          'fuente_publica: pliego Getariako Txakolina (29/06/2011) ap. 2.a y 5'),
];
