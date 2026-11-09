import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

void main() {
  test('ida y vuelta [[lat,lng]] con latitud primero', () {
    final vertices = [
      const LatLng(42.7, -1.6),
      const LatLng(42.71, -1.6),
      const LatLng(42.71, -1.59),
    ];
    final json = codificarContorno(vertices);
    expect(json, '[[42.7,-1.6],[42.71,-1.6],[42.71,-1.59]]');
    expect(leerContorno(json), vertices);
    expect(tieneArea(vertices), isTrue);
  });

  test('lee lo que guardan Zunbeltz, Ganadera y Monte, y tolera basura', () {
    expect(leerContorno(contornoVacio), isEmpty);
    expect(leerContorno(null), isEmpty);
    expect(leerContorno(''), isEmpty);
    expect(leerContorno('no es json'), isEmpty);
    expect(leerContorno('{"type":"Polygon"}'), isEmpty);
    expect(leerContorno('[[42.7,-1.6],["x",1],[3],[42.8,-1.5]]'),
        [const LatLng(42.7, -1.6), const LatLng(42.8, -1.5)]);
    expect(tieneArea(leerContorno('[[1,1],[2,2]]')), isFalse);
  });
}
