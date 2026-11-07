// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/ingredientes_base.csv
// Generado: 2026-11-07
// Filas: 28 (0 firmadas por persona, 0 con alguna revisión, 28 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class IngredienteBase {
  const IngredienteBase(
      {required this.id,
      required this.nombre,
      required this.alergenos,
      required this.trazas,
      required this.salGramosPor100g});

  final String id;
  final String nombre;
  final Set<String> alergenos;
  final Set<String> trazas;
  final double salGramosPor100g;
}

const List<IngredienteBase> catalogoIngredientesBase = [
  IngredienteBase(
      id: 'harina_trigo',
      nombre: 'Harina de trigo',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'harina_trigo_integral',
      nombre: 'Harina integral de trigo',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'harina_espelta',
      nombre: 'Harina de espelta',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'harina_centeno',
      nombre: 'Harina de centeno',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'harina_maiz',
      nombre: 'Harina de maíz',
      alergenos: {},
      trazas: {'gluten'},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'harina_arroz',
      nombre: 'Harina de arroz',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'copos_avena',
      nombre: 'Copos de avena',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'levadura_fresca',
      nombre: 'Levadura fresca de panadería',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'masa_madre',
      nombre: 'Masa madre',
      alergenos: {'gluten'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'agua',
      nombre: 'Agua',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'sal',
      nombre: 'Sal',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 100.0),
  IngredienteBase(
      id: 'azucar',
      nombre: 'Azúcar',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'miel',
      nombre: 'Miel',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'mantequilla',
      nombre: 'Mantequilla',
      alergenos: {'lacteos'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'leche',
      nombre: 'Leche entera',
      alergenos: {'lacteos'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'nata',
      nombre: 'Nata',
      alergenos: {'lacteos'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'huevo',
      nombre: 'Huevo',
      alergenos: {'huevos'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'aceite_oliva',
      nombre: 'Aceite de oliva virgen extra',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'manteca_cerdo',
      nombre: 'Manteca de cerdo',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'almendra',
      nombre: 'Almendra',
      alergenos: {'frutos_cascara'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'avellana',
      nombre: 'Avellana',
      alergenos: {'frutos_cascara'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'nuez',
      nombre: 'Nuez',
      alergenos: {'frutos_cascara'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'sesamo',
      nombre: 'Sésamo',
      alergenos: {'sesamo'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'pipas_girasol',
      nombre: 'Pipas de girasol',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'chocolate_negro',
      nombre: 'Chocolate negro',
      alergenos: {'soja'},
      trazas: {'lacteos', 'frutos_cascara'},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'cacao_polvo',
      nombre: 'Cacao en polvo',
      alergenos: {},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'pasas',
      nombre: 'Uvas pasas',
      alergenos: {'sulfitos'},
      trazas: {},
      salGramosPor100g: 0.0),
  IngredienteBase(
      id: 'mostaza',
      nombre: 'Mostaza',
      alergenos: {'mostaza'},
      trazas: {},
      salGramosPor100g: 4.0),
];
