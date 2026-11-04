import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  test('coma decimal y punto de millares', () {
    expect(formatearNumero(0, decimales: 1), '0,0');
    expect(formatearNumero(1234.5, decimales: 2), '1.234,50');
    expect(formatearNumero(1234567), '1.234.567');
    expect(formatearNumero(999.999, decimales: 2), '1.000,00');
    expect(formatearNumero(-1234.5, decimales: 1), '-1.234,5');
    expect(formatearNumero(-0.001, decimales: 2), '0,00');
  });

  test('euros', () {
    expect(formatearEuros(12.5), '12,50 €');
  });
}
