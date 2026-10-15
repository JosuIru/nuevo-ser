import 'package:latlong2/latlong.dart';

/// Operaciones para ajustar el contorno de una zona ya dibujada sin
/// rehacerlo entero: mover una esquina, quitarla o añadir una en mitad de
/// un lado. El contorno es la lista de esquinas sin repetir la primera al
/// final; el lado `i` va de la esquina `i` a la `i + 1` (el último cierra
/// con la primera). Todas devuelven una lista nueva y, si el índice no
/// existe, la misma.

/// Una zona necesita al menos tres esquinas.
const int esquinasMinimas = 3;

List<LatLng> moverEsquina(List<LatLng> esquinas, int indice, LatLng nueva) {
  if (indice < 0 || indice >= esquinas.length) return esquinas;
  return [...esquinas]..[indice] = nueva;
}

bool sePuedeQuitarEsquina(List<LatLng> esquinas) =>
    esquinas.length > esquinasMinimas;

List<LatLng> quitarEsquina(List<LatLng> esquinas, int indice) {
  if (indice < 0 || indice >= esquinas.length) return esquinas;
  if (!sePuedeQuitarEsquina(esquinas)) return esquinas;
  return [...esquinas]..removeAt(indice);
}

LatLng _puntoMedio(LatLng desde, LatLng hasta) => LatLng(
    (desde.latitude + hasta.latitude) / 2,
    (desde.longitude + hasta.longitude) / 2);

/// Punto medio de cada lado, en el orden de los lados.
List<LatLng> puntosMedios(List<LatLng> esquinas) => [
      for (var lado = 0; lado < esquinas.length; lado++)
        _puntoMedio(esquinas[lado], esquinas[(lado + 1) % esquinas.length]),
    ];

/// Dónde queda la esquina nueva al partir el lado [lado].
int posicionEsquinaInsertada(int numeroEsquinas, int lado) => lado + 1;

List<LatLng> insertarEsquinaEnLado(List<LatLng> esquinas, int lado) {
  if (lado < 0 || lado >= esquinas.length) return esquinas;
  return [...esquinas]..insert(posicionEsquinaInsertada(esquinas.length, lado),
      puntosMedios(esquinas)[lado]);
}
