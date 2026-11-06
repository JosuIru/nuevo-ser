import 'package:concejo/dominio/persona.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final finMandato = DateTime(2027, 3, 1);
  final ane = Persona(
      uid: 'ane', nombre: 'Ane', rol: Rol.mesa, mandatoHasta: finMandato);

  test('el cargo de mesa caduca solo: nadie se queda por olvido', () {
    expect(ane.esMesaEn(DateTime(2027, 2, 28)), isTrue);
    expect(ane.rolEn(DateTime(2027, 3, 2)), Rol.vecina);
  });

  test('días que quedan de mandato, para avisar de que toca rotar', () {
    expect(ane.diasDeMandatoEn(DateTime(2027, 2, 19)), 10);
    expect(ane.diasDeMandatoEn(DateTime(2027, 4, 1)), 0);
    expect(const Persona(uid: 'x', nombre: 'X').diasDeMandatoEn(DateTime(2027)),
        isNull);
  });
}
