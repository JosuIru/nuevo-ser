// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/ganadera/parametros_ecoregimen.csv
// Generado: 2026-11-07
// Filas: 2 (0 firmadas por persona, 2 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-ganadera && dart run tool/compilar_catalogos.dart

class ParametrosEcoregimen {
  const ParametrosEcoregimen(
      {required this.tipoPasto,
      required this.cargaMinima,
      required this.cargaMaxima,
      required this.cargaMinimaReducida,
      required this.diasMinimos,
      required this.diasMinimosReducidos,
      required this.articulo});

  final String tipoPasto;
  final double cargaMinima;
  final double cargaMaxima;
  final double cargaMinimaReducida;
  final int diasMinimos;
  final int diasMinimosReducidos;
  final String articulo;
}

const List<ParametrosEcoregimen> catalogoParametrosEcoregimen = [
  ParametrosEcoregimen(
      tipoPasto: 'humedo',
      cargaMinima: 0.4,
      cargaMaxima: 2.0,
      cargaMinimaReducida: 0.2,
      diasMinimos: 120,
      diasMinimosReducidos: 90,
      articulo: 'RD 1048/2022 art. 30.2'),
  ParametrosEcoregimen(
      tipoPasto: 'mediterraneo',
      cargaMinima: 0.2,
      cargaMaxima: 1.2,
      cargaMinimaReducida: 0.1,
      diasMinimos: 120,
      diasMinimosReducidos: 90,
      articulo: 'RD 1048/2022 art. 30.2'),
];
