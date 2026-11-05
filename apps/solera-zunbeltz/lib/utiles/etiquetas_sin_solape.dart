import 'dart:ui' show Offset, Rect, Size;

/// Un rótulo que se quiere pintar en el mapa: dónde cae su centro en
/// pantalla, cuánto ocupa y su prioridad (menor = más importante).
class RotuloMapa<T> {
  const RotuloMapa({
    required this.clave,
    required this.centro,
    required this.tamano,
    required this.prioridad,
  });

  final T clave;
  final Offset centro;
  final Size tamano;
  final num prioridad;

  Rect get caja => Rect.fromCenter(
      center: centro, width: tamano.width, height: tamano.height);
}

/// Claves de los rótulos que caben sin pisarse: se colocan por prioridad y
/// uno se queda fuera si choca con otro ya colocado (con [margen] de aire)
/// o con un [obstaculos] (marcadores, botones, zonas tapadas por la hoja).
/// A igual prioridad, gana el que viene antes en la lista.
Set<T> rotulosSinSolape<T>(List<RotuloMapa<T>> rotulos,
    {double margen = 4, List<Rect> obstaculos = const []}) {
  final ordenados = [
    for (var indice = 0; indice < rotulos.length; indice++)
      (indice: indice, rotulo: rotulos[indice]),
  ]..sort((a, b) {
      final porPrioridad = a.rotulo.prioridad.compareTo(b.rotulo.prioridad);
      return porPrioridad != 0 ? porPrioridad : a.indice.compareTo(b.indice);
    });
  final colocadas = <Rect>[...obstaculos];
  final visibles = <T>{};
  for (final (indice: _, :rotulo) in ordenados) {
    final caja = rotulo.caja.inflate(margen / 2);
    if (colocadas.any((otra) => otra.overlaps(caja))) continue;
    colocadas.add(caja);
    visibles.add(rotulo.clave);
  }
  return visibles;
}
