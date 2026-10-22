import 'package:flutter_test/flutter_test.dart';
import 'package:solera_arbolado_urbano/utiles/numeros_formulario.dart';

void main() {
  group('medidaDesdeTexto', () {
    test('lee coma y punto decimales; vacío es null', () {
      expect(medidaDesdeTexto('12,5'), 12.5);
      expect(medidaDesdeTexto('12.5'), 12.5);
      expect(medidaDesdeTexto(' 140 '), 140);
      expect(medidaDesdeTexto(''), isNull);
    });

    test('lo que no se entiende es null', () {
      expect(medidaDesdeTexto('1,2,3,4'), isNull);
      expect(medidaDesdeTexto('12..5'), isNull);
    });
  });

  group('validarMedidaOpcional', () {
    test('vacío y números válidos pasan', () {
      expect(validarMedidaOpcional(null), isNull);
      expect(validarMedidaOpcional('  '), isNull);
      expect(validarMedidaOpcional('3,75'), isNull);
    });

    test('un número que no se entiende avisa', () {
      expect(validarMedidaOpcional('12..5'), textoNumeroNoValido);
    });
  });
}
