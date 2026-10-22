import 'package:flutter_test/flutter_test.dart';
import 'package:solera_apicola/utiles/numeros_formulario.dart';

void main() {
  group('leerEntero', () {
    test('lee enteros y rechaza decimales o lo ambiguo', () {
      expect(leerEntero('12'), 12);
      expect(leerEntero(' 3 '), 3);
      expect(leerEntero('12,5'), isNull);
      expect(leerEntero('1.200'), isNull);
      expect(leerEntero('doce'), isNull);
      expect(leerEntero(''), isNull);
    });
  });

  group('validadores', () {
    test('vacío siempre vale', () {
      expect(validarImporteOpcional(''), isNull);
      expect(validarCantidadOpcional(null), isNull);
      expect(validarEnteroOpcional('  '), isNull);
      expect(validarDecimalOpcional(''), isNull);
    });

    test('importe a la española', () {
      expect(validarImporteOpcional('1.200,50'), isNull);
      expect(validarImporteOpcional('12.5'), isNull);
      expect(validarImporteOpcional('12,5x'), textoNumeroNoValido);
    });

    test('cantidad ambigua avisa', () {
      expect(validarCantidadOpcional('12,5'), isNull);
      expect(validarCantidadOpcional('1.200'), textoNumeroNoValido);
    });

    test('superficie con punto decimal', () {
      expect(validarDecimalOpcional('1.200'), isNull);
      expect(validarDecimalOpcional('1,2,3'), textoNumeroNoValido);
    });
  });
}
