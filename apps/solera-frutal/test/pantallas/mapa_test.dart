import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_frutal/modelos/parcela.dart';
import 'package:solera_frutal/pantallas/pantalla_mapa.dart';

void main() {
  test('el mapa se centra en las parcelas con ubicación', () {
    final centro = centroDeParcelas([
      Parcela(nombre: 'A', especieId: 'nogal', latitud: 42, longitud: -2),
      Parcela(nombre: 'B', especieId: 'nogal', latitud: 44, longitud: -4),
      Parcela(nombre: 'Sin', especieId: 'nogal'),
    ]);
    expect((centro.latitude, centro.longitude), (43, -3));
    expect(centroDeParcelas([]).latitude, 40.4);
  });

  test('el logo placeholder existe y está declarado', () {
    expect(File('assets/icono-logo-frutal.png').existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('assets/icono-logo-frutal.png'));
  });
}
