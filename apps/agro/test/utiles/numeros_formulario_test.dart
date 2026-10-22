import 'package:agro/utiles/numeros_formulario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarImporteObligatorio', () {
    test('acepta importes a la española', () {
      expect(validarImporteObligatorio('1.200,50'), isNull);
      expect(validarImporteObligatorio('12,5'), isNull);
      expect(validarImporteObligatorio('12.5'), isNull);
    });
    test('avisa si falta, no se entiende o es cero', () {
      expect(validarImporteObligatorio(''), 'Importe obligatorio');
      expect(validarImporteObligatorio('doce'), startsWith('Importe no válido'));
      expect(validarImporteObligatorio('0'), 'Mayor que cero');
    });
  });

  group('validarImporteOpcional', () {
    test('vacío vale, basura no', () {
      expect(validarImporteOpcional(''), isNull);
      expect(validarImporteOpcional('21,00'), isNull);
      expect(validarImporteOpcional('1,2,3'), startsWith('Importe no válido'));
    });
  });

  group('validarNumeroOpcional', () {
    test('cantidad ambigua se avisa', () {
      expect(validarNumeroOpcional('1.200', nullSiAmbiguo: true),
          startsWith('Número no válido'));
      expect(validarNumeroOpcional('1.200,5', nullSiAmbiguo: true), isNull);
    });
    test('superficie con punto decimal vale', () {
      expect(validarNumeroOpcional('1.5'), isNull);
      expect(validarNumeroOpcional('-2'), 'No puede ser negativo');
    });
  });

  test('numeroParaEditar pone coma decimal y no deja «1.234» ambiguo', () {
    expect(numeroParaEditar(1.234), '1,234');
    expect(numeroParaEditar(1200), '1200');
  });
}
