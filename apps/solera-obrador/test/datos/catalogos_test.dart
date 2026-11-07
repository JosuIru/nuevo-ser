import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_alergenos.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_controles_tipo.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_denominaciones_pan.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_ingredientes_base.dart';
import 'package:solera_obrador/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_obrador/dominio/comprobacion_denominacion.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/modelos/alergenos.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/modelos/registro_autocontrol.dart';

void main() {
  test('el catálogo de alérgenos coincide con los 14 del código', () {
    expect(catalogoAlergenos.map((alergeno) => alergeno.id).toList(),
        alergenosObligatorios);
  });

  test('los ingredientes base solo usan alérgenos válidos y ids únicos', () {
    final ids = <String>{};
    for (final base in catalogoIngredientesBase) {
      expect(ids.add(base.id), isTrue, reason: base.id);
      expect(
          alergenosObligatorios
              .toSet()
              .containsAll({...base.alergenos, ...base.trazas}),
          isTrue,
          reason: base.id);
    }
  });

  test('los controles tipo usan tipos de registro existentes', () {
    for (final control in catalogoControlesTipo) {
      expect(tiposRegistroAutocontrol, contains(control.tipo),
          reason: control.id);
    }
  });

  test('pan común: máximo de sal de 1,31 g / 100 g y aviso al superarlo', () {
    expect(denominacionPorId('pan_comun')!.salMaximaGramosPor100g, 1.31);
    expect(
        catalogoDenominacionesPan
            .every((denominacion) => denominacion.articulo.isNotEmpty),
        isTrue);
    ComposicionReceta pan(double gramosSal) => ComposicionReceta.calcular(
          recetaId: 1,
          recetas: {1: Receta(id: 1, nombre: 'Pan')},
          lineasPorReceta: {
            1: [
              LineaReceta(recetaId: 1, ingredienteId: 1, gramos: 1000),
              LineaReceta(recetaId: 1, ingredienteId: 2, gramos: gramosSal),
            ],
          },
          ingredientes: {
            1: Ingrediente(id: 1, nombre: 'Harina'),
            2: Ingrediente(id: 2, nombre: 'Sal', salGramosPor100g: 100),
          },
        );
    expect(salSuperaMaximo(pan(10), 'pan_comun'), isFalse);
    expect(salSuperaMaximo(pan(20), 'pan_comun'), isTrue);
    expect(salSuperaMaximo(pan(20), 'pan_multicereal'),
        isFalse); // sin máximo en el catálogo
  });

  test('sin firma de persona, el banner de provisionales sigue activo', () {
    expect(catalogosCompletamenteRevisados, isFalse);
  });
}
