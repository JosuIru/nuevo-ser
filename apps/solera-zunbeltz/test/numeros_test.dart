import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/utiles/numeros.dart';

void main() {
  test('decimales con coma o con punto', () {
    expect(leerNumero('12,5'), 12.5);
    expect(leerNumero(' 12.5 '), 12.5);
    expect(leerNumero('0,04'), 0.04);
    expect(leerNumero('-3,2'), -3.2);
  });

  test('millares y decimales a la española', () {
    expect(leerNumero('1.200,50'), 1200.5);
    expect(leerNumero('1.234.567'), 1234567);
    expect(leerNumero('1,200.50'), 1200.5, reason: 'formato inglés completo');
    expect(leerNumero('1 200,50 €'), 1200.5);
  });

  test('un punto con tres cifras: millares solo en importes', () {
    expect(leerNumero('1.200', puntoDeMillares: true), 1200);
    expect(leerNumero('42.795'), 42.795, reason: 'coordenadas y kilos');
    expect(leerNumero('12.50', puntoDeMillares: true), 12.5);
    expect(leerNumero('0.500', puntoDeMillares: true), 0.5,
        reason: 'con un cero delante no son millares');
    expect(leerNumero('1.200', nullSiAmbiguo: true), isNull,
        reason: '«1.200 kg» puede ser 1,2 o 1200: se pregunta');
    expect(leerNumero('1,2', nullSiAmbiguo: true), 1.2);
    expect(leerNumero('1200', nullSiAmbiguo: true), 1200);
  });

  test('lo que no se entiende da null, no 0', () {
    expect(leerNumero(''), isNull);
    expect(leerNumero('   '), isNull);
    expect(leerNumero('abc'), isNull);
    expect(leerNumero('42,79,1'), isNull);
    expect(leerNumero('1.2.3'), isNull);
    expect(leerNumero('12,5kg'), isNull);
  });

  test('céntimos', () {
    expect(centimosDesdeTexto('1.200,00'), 120000);
    expect(centimosDesdeTexto('19,99'), 1999);
    expect(centimosDesdeTexto('0,1'), 10);
    expect(centimosDesdeTexto('x'), isNull);
  });
}
