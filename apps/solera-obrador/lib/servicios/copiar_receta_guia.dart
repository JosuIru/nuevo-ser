// «Copiar a mis recetas»: crea una receta del obrador a partir de una receta
// base de la guía, en gramos. Cada ingrediente se casa por nombre con los
// del obrador; si no existe, se crea desde `ingredientes_base.csv` con sus
// alérgenos habituales y una nota para revisarlos con la ficha del
// proveedor (los alérgenos de la receta los calcula siempre la app).

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_guia_recetas.dart';
import '../dominio/guia_obrador.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';

/// Nota que llevan los ingredientes creados desde la guía.
const String notaIngredienteDesdeGuia =
    'Creado desde la guía del obrador con los alérgenos habituales: '
    'revísalo con la ficha del proveedor.';

/// Resultado de la copia: la receta nueva y los ingredientes que hubo que
/// crear (para avisar a la persona).
typedef RecetaCopiada = ({int recetaId, List<String> ingredientesCreados});

/// Crea la receta [recetaGuia] con [gramosHarina] o [gramosMasa] (uno de los
/// dos). Las cantidades se redondean al gramo (a la décima por debajo de
/// 10 g, para la levadura y la sal).
Future<RecetaCopiada> copiarRecetaGuia(
  RecetaGuia recetaGuia, {
  double? gramosHarina,
  double? gramosMasa,
  BaseDatosSoleraObrador? baseDatos,
}) async {
  final datos = baseDatos ?? BaseDatosSoleraObrador.instancia;
  final gramosPorBase = gramosRecetaGuia(recetaGuia.id,
      gramosHarina: gramosHarina, gramosMasa: gramosMasa);
  final existentes = {
    for (final ingrediente in await datos.listarIngredientes())
      normalizarTextoGuia(ingrediente.nombre.trim()): ingrediente.id!
  };
  final creados = <String>[];
  final idPorBase = <String, int>{};
  for (final baseId in gramosPorBase.keys) {
    final base = ingredienteBasePorId(baseId);
    final nombre = base?.nombre ?? baseId;
    final existente = existentes[normalizarTextoGuia(nombre)];
    if (existente != null) {
      idPorBase[baseId] = existente;
      continue;
    }
    idPorBase[baseId] = await datos.guardarIngrediente(Ingrediente(
      nombre: nombre,
      alergenos: base?.alergenos ?? const {},
      trazas: base?.trazas ?? const {},
      salGramosPor100g: base?.salGramosPor100g ?? 0,
      notas: notaIngredienteDesdeGuia,
    ));
    existentes[normalizarTextoGuia(nombre)] = idPorBase[baseId]!;
    creados.add(nombre);
  }
  final recetaId = await datos.guardarReceta(Receta(
    nombre: recetaGuia.nombre,
    denominacion: recetaGuia.denominacion,
    mermaCoccionPorcentaje: recetaGuia.mermaCoccionPorcentaje,
    esSubreceta: recetaGuia.esSubreceta,
    notas: 'Copiada de la guía del obrador (orientativa). '
        '${recetaGuia.notas}',
  ));
  await datos.guardarLineasReceta(recetaId, [
    for (final MapEntry(key: baseId, value: gramos) in gramosPorBase.entries)
      LineaReceta(
        recetaId: recetaId,
        ingredienteId: idPorBase[baseId],
        gramos: redondearGramosGuia(gramos),
      ),
  ]);
  return (recetaId: recetaId, ingredientesCreados: creados);
}

/// Al gramo; a la décima por debajo de 10 g.
double redondearGramosGuia(double gramos) =>
    gramos < 10 ? (gramos * 10).roundToDouble() / 10 : gramos.roundToDouble();
