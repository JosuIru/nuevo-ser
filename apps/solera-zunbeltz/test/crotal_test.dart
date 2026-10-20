import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/crotal.dart';

void main() {
  group('interpretarCodigoCrotal', () {
    test('un crotal completo se reconoce tal cual', () {
      final lectura = interpretarCodigoCrotal('ES012345678901');
      expect(lectura.identificacion, 'ES012345678901');
      expect(lectura.reconocido, isTrue);
    });

    test('minúsculas, espacios y guiones se limpian', () {
      expect(interpretarCodigoCrotal(' es 0123-4567.8901 ').identificacion,
          'ES012345678901');
    });

    test('solo los 12 dígitos: se antepone ES', () {
      final lectura = interpretarCodigoCrotal('012345678901');
      expect(lectura.identificacion, 'ES012345678901');
      expect(lectura.reconocido, isTrue);
    });

    test('lectura RFID con país numérico 724 pasa a ES', () {
      final lectura = interpretarCodigoCrotal('724012345678901');
      expect(lectura.identificacion, 'ES012345678901');
      expect(lectura.reconocido, isTrue);
    });

    test('otro país de la lista (Francia) conserva su prefijo', () {
      expect(interpretarCodigoCrotal('FR123456789012').identificacion,
          'FR123456789012');
      expect(interpretarCodigoCrotal('250123456789012').identificacion,
          'FR123456789012');
    });

    test('15 dígitos con país desconocido no se reconocen', () {
      final lectura = interpretarCodigoCrotal('999012345678901');
      expect(lectura.reconocido, isFalse);
      expect(lectura.identificacion, '999012345678901');
    });

    test('lo que no tiene forma de crotal se devuelve limpio sin reconocer',
        () {
      final lectura = interpretarCodigoCrotal('https://ejemplo.test/abc');
      expect(lectura.reconocido, isFalse);
      expect(lectura.identificacion, 'HTTPS:EJEMPLOTESTABC');
    });

    test('vacío o solo separadores no da nada', () {
      expect(interpretarCodigoCrotal('  - ').identificacion, '');
      expect(interpretarCodigoCrotal('').reconocido, isFalse);
    });
  });
}
