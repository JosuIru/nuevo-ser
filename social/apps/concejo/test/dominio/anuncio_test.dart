import 'package:concejo/dominio/anuncio.dart';
import 'package:flutter_test/flutter_test.dart';

final _publicado = DateTime(2026, 11, 10, 9);

Anuncio _anuncio({
  String titulo = 'Corte de agua el jueves',
  String texto = 'De 9 a 12, por la obra de la calle Mayor.',
  DateTime? hasta,
}) =>
    Anuncio(
      uid: 'an1',
      titulo: titulo,
      texto: texto,
      autorUid: 'ane',
      publicado: _publicado,
      hasta: hasta,
    );

void main() {
  test('basta un título; el texto puede ir vacío', () {
    expect(_anuncio().problemas(_publicado), isEmpty);
    expect(_anuncio(texto: '').problemas(_publicado), isEmpty);
    expect(_anuncio(titulo: '  ').problemas(_publicado),
        [ProblemaAnuncio.faltaTitulo]);
  });

  test('título y texto tienen un largo máximo (contando letras, no bytes)', () {
    expect(
        _anuncio(titulo: 'ñ' * Anuncio.largoMaximoTitulo).problemas(_publicado),
        isEmpty);
    expect(
        _anuncio(titulo: 'x' * (Anuncio.largoMaximoTitulo + 1))
            .problemas(_publicado),
        [ProblemaAnuncio.tituloLargo]);
    expect(
        _anuncio(texto: 'x' * (Anuncio.largoMaximoTexto + 1))
            .problemas(_publicado),
        [ProblemaAnuncio.textoLargo]);
  });

  test('la fecha «hasta» no puede haber pasado', () {
    expect(
        _anuncio(hasta: DateTime(2026, 11, 10)).problemas(_publicado), isEmpty);
    expect(_anuncio(hasta: DateTime(2026, 11, 9)).problemas(_publicado),
        [ProblemaAnuncio.hastaPasado]);
  });

  test('sigue en el tablón hasta el final del día «hasta»', () {
    final anuncio = _anuncio(hasta: DateTime(2026, 11, 12));
    expect(anuncio.vigenteEn(DateTime(2026, 11, 12, 23, 59)), isTrue);
    expect(anuncio.vigenteEn(DateTime(2026, 11, 13)), isFalse);
    expect(_anuncio().vigenteEn(DateTime(2030)), isTrue);
  });

  test('retirado ya no está vigente; la mesa dice por qué', () {
    final retirado = _anuncio().retirar(motivo: ' Repetido ');
    expect(retirado.retirado, isTrue);
    expect(retirado.motivoRetirada, 'Repetido');
    expect(retirado.vigenteEn(_publicado), isFalse);
    expect(() => retirado.retirar(motivo: ''), throwsStateError);
  });

  test('fijar y desfijar', () {
    expect(_anuncio().conFijado(true).fijado, isTrue);
    expect(_anuncio().conFijado(true).conFijado(false).fijado, isFalse);
    expect(
        () => _anuncio().retirar(motivo: '').conFijado(true), throwsStateError);
  });
}
