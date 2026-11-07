import '../datos/catalogos_generados/catalogo_denominaciones_pan.dart';
import 'composicion_receta.dart';

/// Denominación del catálogo por su id; null si la receta no tiene.
DenominacionPan? denominacionPorId(String id) {
  for (final denominacion in catalogoDenominacionesPan) {
    if (denominacion.id == id) return denominacion;
  }
  return null;
}

/// True si la sal **estimada** supera el máximo de la denominación (RD
/// 308/2019, art. 11.2.c, por cloruros). Es un aviso, nunca una
/// certificación: la cifra legal sale del laboratorio.
bool salSuperaMaximo(ComposicionReceta composicion, String denominacionId) {
  final maximo = denominacionPorId(denominacionId)?.salMaximaGramosPor100g;
  return maximo != null && composicion.salEstimadaGramosPor100g > maximo;
}
