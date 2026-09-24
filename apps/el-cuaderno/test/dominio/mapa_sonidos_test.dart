import 'package:el_cuaderno/dominio/mapa_sonidos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la distancia sale del radio en tres anillos iguales', () {
    expect(MarcaSonido(x: 0.1, y: 0.1, tipo: TipoSonido.hojas).distancia, DistanciaSonido.cerca);
    expect(MarcaSonido(x: 0, y: -0.5, tipo: TipoSonido.pajaro).distancia, DistanciaSonido.media);
    expect(MarcaSonido(x: 0.9, y: 0, tipo: TipoSonido.maquina).distancia, DistanciaSonido.lejos);
  });

  test('las coordenadas se recortan a [-1, 1]', () {
    final marca = MarcaSonido(x: 3, y: -7, tipo: TipoSonido.viento);
    expect(marca.x, 1.0);
    expect(marca.y, -1.0);
    expect(marca.radio, 1.0);
  });

  test('quitar retira la marca más cercana dentro de la tolerancia', () {
    final mapa = MapaSonidos()
      ..marcar(MarcaSonido(x: 0.5, y: 0.5, tipo: TipoSonido.agua))
      ..marcar(MarcaSonido(x: 0.55, y: 0.5, tipo: TipoSonido.insecto));
    expect(mapa.quitarCercaDe(0.56, 0.5), isTrue);
    expect(mapa.marcas.single.tipo, TipoSonido.agua);
    expect(mapa.quitarCercaDe(-0.5, -0.5), isFalse);
  });

  test('conteo por distancia y tipos presentes', () {
    final mapa = MapaSonidos()
      ..marcar(MarcaSonido(x: 0, y: 0.1, tipo: TipoSonido.noSe))
      ..marcar(MarcaSonido(x: 0.8, y: 0, tipo: TipoSonido.pajaro))
      ..marcar(MarcaSonido(x: -0.9, y: 0, tipo: TipoSonido.pajaro));
    expect(mapa.conteoPorDistancia, {
      DistanciaSonido.cerca: 1,
      DistanciaSonido.media: 0,
      DistanciaSonido.lejos: 2,
    });
    expect(mapa.tiposPresentes, [TipoSonido.pajaro, TipoSonido.noSe]);
    mapa.deshacer();
    expect(mapa.marcas, hasLength(2));
  });
}
