import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

void main() {
  test('lee polígono, parcela y subparcela con rótulos', () {
    expect(partesRecintoSigpac('Pol. 24 parc. 2 subp. M'), ['24', '2', 'M']);
    expect(partesRecintoSigpac('Yerri · pol. 24 parc. 2'), ['24', '2']);
    expect(partesRecintoSigpac('Polígono 13, parcela 1, subparcela c'),
        ['13', '1', 'C']);
  });

  test('lee la forma corta con guiones o barras', () {
    expect(partesRecintoSigpac('24-2-M'), ['24', '2', 'M']);
    expect(partesRecintoSigpac('13 / 1'), ['13', '1']);
  });

  test('lo que no entiende lo devuelve como null', () {
    expect(partesRecintoSigpac(''), isNull);
    expect(partesRecintoSigpac('Recinto 31:201:0:0:24:2:5'), isNull);
  });
}
