import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';

/// Lo que se sabe de una receta a partir de sus líneas: alérgenos, coste,
/// sal estimada e ingredientes por peso. Las subrecetas se despliegan en
/// proporción a los gramos usados.
///
/// **Hard limit**: la sal y los alérgenos son lo que dicen las fichas de los
/// ingredientes. No sustituyen un análisis de laboratorio ni declaran un
/// producto apto para nadie.
class ComposicionReceta {
  ComposicionReceta._({
    required this.gramosMasa,
    required this.gramosProductoCocido,
    required this.piezas,
    required this.alergenos,
    required this.trazas,
    required this.costeCentimosMasa,
    required this.gramosSal,
    required this.gramosPorIngrediente,
  });

  /// Peso de la masa cruda (suma de líneas).
  final double gramosMasa;

  /// Peso tras la merma de cocción.
  final double gramosProductoCocido;
  final int piezas;
  final Set<String> alergenos;

  /// «Puede contener», sin repetir lo que ya está en [alergenos].
  final Set<String> trazas;
  final double costeCentimosMasa;
  final double gramosSal;

  /// Ingrediente → gramos en la masa, con las subrecetas desplegadas.
  final Map<int, double> gramosPorIngrediente;

  double get costeCentimosPieza => piezas == 0 ? 0 : costeCentimosMasa / piezas;

  double get gramosPorPieza => piezas == 0 ? 0 : gramosProductoCocido / piezas;

  /// Sal estimada en el producto acabado, en g por 100 g.
  double get salEstimadaGramosPor100g =>
      gramosProductoCocido == 0 ? 0 : gramosSal / gramosProductoCocido * 100;

  /// Ingredientes en orden decreciente de peso (como pide la etiqueta).
  List<int> get ingredientesPorPeso => gramosPorIngrediente.keys.toList()
    ..sort(
        (a, b) => gramosPorIngrediente[b]!.compareTo(gramosPorIngrediente[a]!));

  /// Calcula la composición de [recetaId].
  ///
  /// Lanza [StateError] si una receta se contiene a sí misma (directa o
  /// indirectamente) o si falta una receta o un ingrediente referido.
  factory ComposicionReceta.calcular({
    required int recetaId,
    required Map<int, Receta> recetas,
    required Map<int, List<LineaReceta>> lineasPorReceta,
    required Map<int, Ingrediente> ingredientes,
  }) {
    final gramosPorIngrediente = <int, double>{};

    double gramosDeMasa(int id, Set<int> enCurso) {
      if (!enCurso.add(id)) {
        throw StateError('La receta $id se contiene a sí misma');
      }
      var total = 0.0;
      for (final linea in lineasPorReceta[id] ?? const <LineaReceta>[]) {
        total += linea.gramos;
      }
      enCurso.remove(id);
      return total;
    }

    void desplegar(int id, double factor, Set<int> enCurso) {
      if (!recetas.containsKey(id)) throw StateError('Falta la receta $id');
      if (!enCurso.add(id)) {
        throw StateError('La receta $id se contiene a sí misma');
      }
      for (final linea in lineasPorReceta[id] ?? const <LineaReceta>[]) {
        final gramos = linea.gramos * factor;
        final ingredienteId = linea.ingredienteId;
        if (ingredienteId != null) {
          if (!ingredientes.containsKey(ingredienteId)) {
            throw StateError('Falta el ingrediente $ingredienteId');
          }
          gramosPorIngrediente.update(ingredienteId, (valor) => valor + gramos,
              ifAbsent: () => gramos);
        } else {
          final subrecetaId = linea.subrecetaId!;
          final masaSubreceta = gramosDeMasa(subrecetaId, {...enCurso});
          if (masaSubreceta > 0) {
            desplegar(subrecetaId, gramos / masaSubreceta, enCurso);
          }
        }
      }
      enCurso.remove(id);
    }

    desplegar(recetaId, 1, <int>{});
    final receta = recetas[recetaId]!;
    final alergenos = <String>{};
    final trazas = <String>{};
    var coste = 0.0;
    var sal = 0.0;
    var masa = 0.0;
    gramosPorIngrediente.forEach((ingredienteId, gramos) {
      final ingrediente = ingredientes[ingredienteId]!;
      alergenos.addAll(ingrediente.alergenos);
      trazas.addAll(ingrediente.trazas);
      coste += ingrediente.precioCentimosPorKg * gramos / 1000;
      sal += ingrediente.salGramosPor100g * gramos / 100;
      masa += gramos;
    });
    final factorCoccion = 1 - receta.mermaCoccionPorcentaje.clamp(0, 99) / 100;
    return ComposicionReceta._(
      gramosMasa: masa,
      gramosProductoCocido: masa * factorCoccion,
      piezas: receta.piezasPorMasa,
      alergenos: alergenos,
      trazas: trazas.difference(alergenos),
      costeCentimosMasa: coste,
      gramosSal: sal,
      gramosPorIngrediente: gramosPorIngrediente,
    );
  }
}
