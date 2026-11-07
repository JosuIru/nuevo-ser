import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';

void main() {
  // Harina 1 €/kg con gluten; agua; sal 0,50 €/kg; sésamo con trazas de
  // frutos de cáscara; mantequilla con lácteos.
  final ingredientes = {
    1: Ingrediente(
        id: 1,
        nombre: 'Harina',
        alergenos: {'gluten'},
        precioCentimosPorKg: 100),
    2: Ingrediente(id: 2, nombre: 'Agua'),
    3: Ingrediente(
        id: 3, nombre: 'Sal', precioCentimosPorKg: 50, salGramosPor100g: 100),
    4: Ingrediente(
        id: 4,
        nombre: 'Sésamo',
        alergenos: {'sesamo'},
        trazas: {'frutos_cascara', 'gluten'}),
    5: Ingrediente(
        id: 5,
        nombre: 'Mantequilla',
        alergenos: {'lacteos'},
        precioCentimosPorKg: 1000),
  };
  final recetas = {
    10: Receta(
        id: 10, nombre: 'Pan', piezasPorMasa: 4, mermaCoccionPorcentaje: 20),
    20: Receta(id: 20, nombre: 'Cobertura', esSubreceta: true),
    30: Receta(id: 30, nombre: 'Pan con cobertura', piezasPorMasa: 2),
    40: Receta(id: 40, nombre: 'Bucle A'),
    41: Receta(id: 41, nombre: 'Bucle B'),
  };
  final lineas = {
    10: [
      LineaReceta(recetaId: 10, ingredienteId: 1, gramos: 1000),
      LineaReceta(recetaId: 10, ingredienteId: 2, gramos: 700),
      LineaReceta(recetaId: 10, ingredienteId: 3, gramos: 20),
    ],
    20: [
      LineaReceta(recetaId: 20, ingredienteId: 4, gramos: 50),
      LineaReceta(recetaId: 20, ingredienteId: 5, gramos: 50),
    ],
    30: [
      LineaReceta(recetaId: 30, ingredienteId: 1, gramos: 500),
      LineaReceta(recetaId: 30, subrecetaId: 20, gramos: 20),
    ],
    40: [LineaReceta(recetaId: 40, subrecetaId: 41, gramos: 10)],
    41: [LineaReceta(recetaId: 41, subrecetaId: 40, gramos: 10)],
  };

  ComposicionReceta calcular(int id) => ComposicionReceta.calcular(
      recetaId: id,
      recetas: recetas,
      lineasPorReceta: lineas,
      ingredientes: ingredientes);

  test('masa, merma, coste por pieza y sal estimada', () {
    final pan = calcular(10);
    expect(pan.gramosMasa, 1720);
    expect(pan.gramosProductoCocido, closeTo(1376, 1e-9));
    expect(pan.gramosPorPieza, closeTo(344, 1e-9));
    // 1 kg de harina (100 c) + 20 g de sal (1 c) = 101 c / 4 piezas.
    expect(pan.costeCentimosPieza, closeTo(25.25, 1e-9));
    // 20 g de sal / 1376 g de pan × 100.
    expect(pan.salEstimadaGramosPor100g, closeTo(1.4535, 1e-3));
    expect(pan.alergenos, {'gluten'});
    expect(pan.ingredientesPorPeso, [1, 2, 3]);
  });

  test('la subreceta se despliega en proporción y hereda alérgenos', () {
    final conCobertura = calcular(30);
    // 20 g de una cobertura de 100 g: 10 g de sésamo y 10 g de mantequilla.
    expect(conCobertura.gramosPorIngrediente[4], closeTo(10, 1e-9));
    expect(conCobertura.gramosPorIngrediente[5], closeTo(10, 1e-9));
    expect(conCobertura.alergenos, {'gluten', 'sesamo', 'lacteos'});
    // El gluten ya está declarado: no se repite como traza.
    expect(conCobertura.trazas, {'frutos_cascara'});
  });

  test('una receta que se contiene a sí misma se detecta', () {
    expect(() => calcular(40), throwsStateError);
  });

  test('una receta que no existe se detecta', () {
    expect(() => calcular(99), throwsStateError);
  });
}
