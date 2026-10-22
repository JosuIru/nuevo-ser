import 'package:flutter_test/flutter_test.dart';
import 'package:solera_quesera/utiles/validar_numero.dart';

void main() {
  group('avisoNumeroNoValido', () {
    test('vacío no avisa (el campo es opcional)', () {
      expect(avisoNumeroNoValido(null), isNull);
      expect(avisoNumeroNoValido('  '), isNull);
    });

    test('acepta la coma decimal y el punto decimal', () {
      expect(avisoNumeroNoValido('12,5'), isNull);
      expect(avisoNumeroNoValido('6.4'), isNull);
    });

    test('avisa si el texto no es un número', () {
      expect(avisoNumeroNoValido('doce'), textoNumeroNoValido);
      expect(avisoNumeroNoValido('12,5,3'), textoNumeroNoValido);
    });

    test('cantidades: «1.200» es ambiguo y avisa; importes: son millares', () {
      expect(avisoNumeroNoValido('1.200', nullSiAmbiguo: true), textoNumeroNoValido);
      expect(avisoNumeroNoValido('1.200,50', nullSiAmbiguo: true), isNull);
      expect(avisoNumeroNoValido('1.200', puntoDeMillares: true), isNull);
    });
  });
}
