import 'dart:math';

/// Qué clase de sonido marca el niño en el mapa. Pocas categorías y
/// abiertas: el mapa de sonidos es para **escuchar antes de nombrar**
/// (observar antes de interpretar, biblia §3.1). Por eso hay
/// «no sé qué es»: un sonido sin nombre también se apunta.
enum TipoSonido { pajaro, insecto, agua, viento, hojas, animal, persona, maquina, noSe }

/// Distancia cualitativa al centro del mapa (donde está el niño).
enum DistanciaSonido { cerca, media, lejos }

/// Una marca en el mapa. [x] e [y] van en [-1, 1] relativos al centro
/// (el niño): `y` negativo es «delante». Guardar coordenadas relativas
/// hace que el mapa no dependa del tamaño de pantalla.
class MarcaSonido {
  MarcaSonido({required double x, required double y, required this.tipo})
      : x = x.clamp(-1.0, 1.0),
        y = y.clamp(-1.0, 1.0);

  final double x;
  final double y;
  final TipoSonido tipo;

  double get radio => sqrt(x * x + y * y).clamp(0.0, 1.0);

  /// Tres anillos iguales: hasta un tercio del radio es cerca, hasta dos
  /// tercios media distancia, el resto lejos.
  DistanciaSonido get distancia {
    if (radio <= 1 / 3) return DistanciaSonido.cerca;
    if (radio <= 2 / 3) return DistanciaSonido.media;
    return DistanciaSonido.lejos;
  }
}

/// El mapa de un rato de escucha. Puro: la vista traduce toques a
/// coordenadas relativas y llama a [marcar] / [quitarCercaDe].
class MapaSonidos {
  final List<MarcaSonido> _marcas = [];

  List<MarcaSonido> get marcas => List.unmodifiable(_marcas);
  bool get estaVacio => _marcas.isEmpty;

  void marcar(MarcaSonido marca) => _marcas.add(marca);

  /// Quita la marca más cercana a (x, y) si está a menos de
  /// [tolerancia] (en la misma escala relativa). Devuelve si quitó algo.
  bool quitarCercaDe(double x, double y, {double tolerancia = 0.12}) {
    var indiceMasCercano = -1;
    var mejorDistancia = tolerancia;
    for (var indice = 0; indice < _marcas.length; indice++) {
      final marca = _marcas[indice];
      final distancia = sqrt(pow(marca.x - x, 2) + pow(marca.y - y, 2));
      if (distancia <= mejorDistancia) {
        mejorDistancia = distancia;
        indiceMasCercano = indice;
      }
    }
    if (indiceMasCercano < 0) return false;
    _marcas.removeAt(indiceMasCercano);
    return true;
  }

  void deshacer() {
    if (_marcas.isNotEmpty) _marcas.removeLast();
  }

  /// Cuántos sonidos hay a cada distancia. Es lo único que se resume:
  /// sin juicio, sin «muchos» ni «pocos».
  Map<DistanciaSonido, int> get conteoPorDistancia => {
        for (final distancia in DistanciaSonido.values)
          distancia: _marcas.where((m) => m.distancia == distancia).length,
      };

  /// Tipos distintos que aparecen, en el orden del enum.
  List<TipoSonido> get tiposPresentes => [
        for (final tipo in TipoSonido.values)
          if (_marcas.any((m) => m.tipo == tipo)) tipo,
      ];
}
