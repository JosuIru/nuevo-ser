// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/frutal/especies_frutal.csv
// Generado: 2026-11-07
// Filas: 7 (0 firmadas por persona, 1 con alguna revisión, 6 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-frutal && dart run tool/compilar_catalogos.dart

class EspecieCatalogo {
  const EspecieCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipoFruto,
    required this.polinizacion,
    required this.colmenasPorHaMinimo,
    required this.colmenasPorHaMaximo,
    required this.notas,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipoFruto;
  final String polinizacion;
  final double? colmenasPorHaMinimo;
  final double? colmenasPorHaMaximo;
  final String notas;
}

const List<EspecieCatalogo> catalogoEspecies = [
  EspecieCatalogo(
      id: 'almendro',
      nombre: 'Almendro',
      nombreCientifico: 'Prunus dulcis',
      tipoFruto: 'cascara',
      polinizacion: 'entomofila',
      colmenasPorHaMinimo: 2.5,
      colmenasPorHaMaximo: 5.0,
      notas:
          'Muchas variedades tradicionales son autoincompatibles y necesitan polinizadora y abejas'),
  EspecieCatalogo(
      id: 'avellano',
      nombre: 'Avellano',
      nombreCientifico: 'Corylus avellana',
      tipoFruto: 'cascara',
      polinizacion: 'anemofila',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas:
          'Polinización por el viento; las variedades suelen necesitar polinizadoras compatibles'),
  EspecieCatalogo(
      id: 'nogal',
      nombre: 'Nogal',
      nombreCientifico: 'Juglans regia',
      tipoFruto: 'cascara',
      polinizacion: 'anemofila',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas:
          'Polinización por el viento; la dicogamia (flores masculinas y femeninas a destiempo) puede exigir polinizadoras'),
  EspecieCatalogo(
      id: 'castano',
      nombre: 'Castaño',
      nombreCientifico: 'Castanea sativa',
      tipoFruto: 'cascara',
      polinizacion: 'mixta',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas: 'Muchas variedades son autoestériles'),
  EspecieCatalogo(
      id: 'pistachero',
      nombre: 'Pistachero',
      nombreCientifico: 'Pistacia vera',
      tipoFruto: 'cascara',
      polinizacion: 'anemofila',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas:
          'Especie dioica: hacen falta pies machos que florezcan a la vez que las hembras'),
  EspecieCatalogo(
      id: 'hueso',
      nombre: 'Frutal de hueso',
      nombreCientifico: 'Prunus spp.',
      tipoFruto: 'fresco',
      polinizacion: 'entomofila',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas:
          'Cerezo, ciruelo, melocotonero, albaricoquero: la compatibilidad depende de la variedad'),
  EspecieCatalogo(
      id: 'pepita',
      nombre: 'Frutal de pepita',
      nombreCientifico: 'Malus domestica, Pyrus communis',
      tipoFruto: 'fresco',
      polinizacion: 'entomofila',
      colmenasPorHaMinimo: null,
      colmenasPorHaMaximo: null,
      notas:
          'Manzano y peral: la mayoría de variedades necesitan polinizadora'),
];
