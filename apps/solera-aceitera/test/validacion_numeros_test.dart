import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aceitera/utiles/validacion_numeros.dart';

void main() {
  group('validarNumeroOpcional', () {
    test('vacío vale', () {
      expect(validarNumeroOpcional(null), isNull);
      expect(validarNumeroOpcional('  '), isNull);
    });

    test('coma o punto decimal valen', () {
      expect(validarNumeroOpcional('12,5'), isNull);
      expect(validarNumeroOpcional('12.5'), isNull);
    });

    test('texto que no se entiende avisa', () {
      expect(validarNumeroOpcional('doce'), textoNumeroNoValido);
      expect(validarNumeroOpcional('1,2,3'), textoNumeroNoValido);
      expect(validarNumeroOpcional('-3'), textoNumeroNoValido);
    });

    test('«1.200» en kg es ambiguo y avisa', () {
      expect(validarNumeroOpcional('1.200', nullSiAmbiguo: true),
          textoNumeroNoValido);
      expect(validarNumeroOpcional('1200', nullSiAmbiguo: true), isNull);
    });
  });

  test('validarImporteOpcional lee millares a la española', () {
    expect(validarImporteOpcional('1.200,50'), isNull);
    expect(validarImporteOpcional('1.200'), isNull);
    expect(validarImporteOpcional('1,200,50'), textoNumeroNoValido);
  });
}
