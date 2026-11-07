import 'package:pendientes/pendientes.dart';
import 'package:test/test.dart';

void main() {
  group('clasificarResponsables', () {
    test('detecta el asesor fiscal', () {
      expect(
          clasificarResponsables('Libro económico (modelo 347 + REAGP)'),
          contains(Responsable.asesorFiscal));
    });

    test('detecta OCA como palabra, no dentro de otra', () {
      expect(clasificarResponsables('Validar con el técnico OCA'),
          contains(Responsable.tecnicoOca));
      expect(clasificarResponsables('Se coloca la foca en la boca'),
          isNot(contains(Responsable.tecnicoOca)));
    });

    test('detecta al técnico de seguridad alimentaria (obrador)', () {
      expect(
          clasificarResponsables(
              'Técnico de seguridad alimentaria — cuaderno de autocontrol y alérgenos'),
          contains(Responsable.tecnicoSeguridadAlimentaria));
      expect(clasificarResponsables('Guía de prácticas correctas de higiene'),
          contains(Responsable.tecnicoSeguridadAlimentaria));
    });

    test('ignora mayúsculas y tildes', () {
      expect(clasificarResponsables('ASESORIA LINGUISTICA en euskera'),
          contains(Responsable.asesoriaLinguistica));
      expect(clasificarResponsables('validación agronómica'),
          contains(Responsable.asesorAgronomo));
    });

    test('puede devolver varios responsables', () {
      final responsables = clasificarResponsables(
          'Libro de movimientos del aceite (AICA) y cierre fiscal REAGP');
      expect(responsables,
          containsAll([Responsable.auditorAica, Responsable.asesorFiscal]));
    });

    test('sin coincidencias devuelve sinClasificar', () {
      expect(clasificarResponsables('Algo muy genérico'),
          [Responsable.sinClasificar]);
    });
  });

  test('quitarTildes normaliza a minúsculas sin diacríticos', () {
    expect(quitarTildes('Áéíóú Ññ Üü'), 'aeiou nn uu');
  });
}
