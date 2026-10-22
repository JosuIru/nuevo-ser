import 'package:flutter_test/flutter_test.dart';
import 'package:solera_viticultura/utiles/validadores_numero.dart';

void main() {
  group('validarImporteOpcional', () {
    test('vacío vale', () {
      expect(validarImporteOpcional(''), isNull);
      expect(validarImporteOpcional(null), isNull);
    });
    test('importes a la española valen', () {
      expect(validarImporteOpcional('1.200,50'), isNull);
      expect(validarImporteOpcional('12,5'), isNull);
      expect(validarImporteOpcional('12.50'), isNull);
    });
    test('lo que no se entiende avisa', () {
      expect(validarImporteOpcional('doce'), textoNumeroNoValido);
      expect(validarImporteOpcional('1,2,3'), textoNumeroNoValido);
    });
  });

  group('validarCantidadOpcional', () {
    test('«1.200» es ambiguo y avisa', () {
      expect(validarCantidadOpcional('1.200'), textoNumeroNoValido);
    });
    test('con coma decimal o sin separador vale', () {
      expect(validarCantidadOpcional('1200'), isNull);
      expect(validarCantidadOpcional('2,5'), isNull);
    });
  });

  group('validarMedidaOpcional', () {
    test('un punto suelto es decimal', () {
      expect(validarMedidaOpcional('1.200'), isNull);
      expect(validarMedidaOpcional('x'), textoNumeroNoValido);
    });
  });
}
