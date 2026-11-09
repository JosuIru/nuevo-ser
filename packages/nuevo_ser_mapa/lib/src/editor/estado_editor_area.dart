// Estado del editor de áreas, sin Flutter: qué esquinas hay, cuál está
// elegida y el historial para deshacer. La pantalla solo lo pinta.
//
// Junta las dos formas de marcar un área que había en la suite:
// - dibujar y ajustar tocando el mapa (Larrea Zunbeltz, `pantalla_fincas`);
// - caminar el perímetro añadiendo la posición del GPS (Ganadera y Monte).
//
// Un solo modo: tocar el mapa AÑADE una esquina al final, salvo que haya una
// esquina elegida, que entonces se MUEVE ahí. Como en Zunbeltz, no se
// arrastra: el arrastre del marcador compite con el del mapa.

import 'package:latlong2/latlong.dart';

import '../geometria/edicion_contorno.dart';
import '../geometria/geodesia.dart';

class EstadoEditorArea {
  EstadoEditorArea([List<LatLng> inicial = const []])
      : _esquinas = List.unmodifiable(inicial);

  List<LatLng> _esquinas;
  final List<List<LatLng>> _historial = [];
  int? _elegida;

  List<LatLng> get esquinas => _esquinas;

  /// Índice de la esquina elegida para moverla o quitarla.
  int? get elegida => _elegida;

  bool get puedeDeshacer => _historial.isNotEmpty;
  bool get esArea => _esquinas.length >= esquinasMinimas;
  bool get puedeQuitarElegida =>
      _elegida != null && sePuedeQuitarEsquina(_esquinas);

  double get hectareas => superficieHectareas(_esquinas);

  /// Perímetro cerrado si es un área; si no, lo andado hasta ahora.
  double get perimetro => perimetroMetros(_esquinas);

  void _cambiar(List<LatLng> nuevas) {
    if (identical(nuevas, _esquinas)) return;
    _historial.add(_esquinas);
    _esquinas = List.unmodifiable(nuevas);
  }

  /// Toque en el mapa: mueve la esquina elegida (y la suelta) o añade una.
  void tocarMapa(LatLng punto) {
    final elegida = _elegida;
    if (elegida != null) {
      _cambiar(moverEsquina(_esquinas, elegida, punto));
      _elegida = null;
    } else {
      _cambiar([..._esquinas, punto]);
    }
  }

  /// Esquina con la posición del GPS (caminando el perímetro). Siempre al
  /// final: aquí no se mueve la elegida.
  void anadirPosicion(LatLng posicion) {
    _elegida = null;
    _cambiar([..._esquinas, posicion]);
  }

  /// Toque en una esquina: la elige, o la suelta si ya lo estaba.
  void elegir(int indice) {
    if (indice < 0 || indice >= _esquinas.length) return;
    _elegida = _elegida == indice ? null : indice;
  }

  void soltar() => _elegida = null;

  /// «+» en mitad del lado [lado]: esquina nueva, ya elegida para moverla.
  void insertarEnLado(int lado) {
    if (_esquinas.length < 2) return;
    final antes = _esquinas;
    _cambiar(insertarEsquinaEnLado(_esquinas, lado));
    if (!identical(antes, _esquinas)) {
      _elegida = posicionEsquinaInsertada(antes.length, lado);
    }
  }

  void quitarElegida() {
    final elegida = _elegida;
    if (elegida == null) return;
    // Mientras no es un área se puede quitar cualquiera; después, con
    // las tres mínimas.
    final nuevas = _esquinas.length <= esquinasMinimas
        ? ([..._esquinas]..removeAt(elegida))
        : quitarEsquina(_esquinas, elegida);
    _cambiar(nuevas);
    _elegida = null;
  }

  /// Sustituye todo (área importada de un fichero).
  void reemplazar(List<LatLng> nuevas) {
    _elegida = null;
    _cambiar(nuevas);
  }

  void borrarTodo() {
    if (_esquinas.isEmpty) return;
    _elegida = null;
    _cambiar(const []);
  }

  void deshacer() {
    if (_historial.isEmpty) return;
    _esquinas = _historial.removeLast();
    _elegida = null;
  }
}
