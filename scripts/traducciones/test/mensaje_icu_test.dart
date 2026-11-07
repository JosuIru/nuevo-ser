import 'package:test/test.dart';
import 'package:traducciones/src/mensaje_icu.dart';

void main() {
  group('compararEstructuraIcu acepta', () {
    test('texto sin placeholders', () {
      expect(compararEstructuraIcu('Hola', 'Kaixo'), isNull);
    });

    test('mismos placeholders en otro orden', () {
      expect(
        compararEstructuraIcu(
            'Decisión: del {desde} al {hasta}', 'Erabakia: {hasta} {desde}'),
        isNull,
      );
    });

    test('plural con otros casos pero con other', () {
      expect(
        compararEstructuraIcu(
          '{cantidad, plural, =1{Una persona} other{{cantidad} personas}}',
          '{cantidad, plural, other{{cantidad} pertsona}}',
        ),
        isNull,
      );
    });

    test('apóstrofos literales (catalán)', () {
      expect(
        compararEstructuraIcu('La app de {nombre}', "L'aplicació d'{nombre}"),
        isNull,
      );
    });

    test('plural incrustado en texto con más placeholders', () {
      const espanol =
          '{total, plural, =1{Ha participado una persona} other{Han participado {total} personas}}: {app} en la app y {papel} en persona.';
      const euskera =
          '{total, plural, =1{Pertsona batek hartu du parte} other{{total} pertsonak hartu dute parte}}: {app} aplikazioan eta {papel} aurrez aurre.';
      expect(compararEstructuraIcu(espanol, euskera), isNull);
    });
  });

  group('compararEstructuraIcu rechaza', () {
    test('placeholder renombrado', () {
      expect(compararEstructuraIcu('Desde el {fecha}', 'Data: {data}'),
          allOf(isNotNull, contains('fecha')));
    });

    test('placeholder que falta', () {
      expect(compararEstructuraIcu('Del {desde} al {hasta}', 'Del {desde}'),
          contains('hasta'));
    });

    test('placeholder que sobra', () {
      expect(
          compararEstructuraIcu('Hola', 'Kaixo {nombre}'), contains('nombre'));
    });

    test('llaves desequilibradas', () {
      expect(
          compararEstructuraIcu('Hola {nombre}', 'Kaixo {nombre'), isNotNull);
    });

    test('plural convertido en placeholder simple', () {
      expect(
        compararEstructuraIcu(
            '{n, plural, =1{uno} other{{n} varios}}', '{n} batzuk'),
        contains('plural'),
      );
    });

    test('plural sin caso other', () {
      expect(
        compararEstructuraIcu(
            '{n, plural, =1{uno} other{{n} varios}}', '{n, plural, =1{bat}}'),
        contains('other'),
      );
    });

    test('plural con un caso inventado', () {
      expect(
        compararEstructuraIcu(
            '{n, plural, other{{n}}}', '{n, plural, muchos{{n}} other{{n}}}'),
        contains('muchos'),
      );
    });

    test('select con casos distintos', () {
      expect(
        compararEstructuraIcu(
          '{genero, select, femenino{ella} masculino{él} other{elle}}',
          '{genero, select, emakumea{hura} other{hura}}',
        ),
        contains('select'),
      );
    });
  });

  group('analizarMensajeIcu', () {
    test('lanza ErrorIcu con llave de cierre sobrante', () {
      expect(() => analizarMensajeIcu('Hola}'), throwsA(isA<ErrorIcu>()));
    });

    test('lanza ErrorIcu con nombre de placeholder vacío', () {
      expect(() => analizarMensajeIcu('Hola {}'), throwsA(isA<ErrorIcu>()));
    });
  });
}
