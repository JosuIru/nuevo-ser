import 'package:concejo/dominio/acta.dart';
import 'package:flutter_test/flutter_test.dart';

final _ahora = DateTime(2026, 11, 10, 12);

void main() {
  test('es borrador hasta que firman dos personas distintas', () {
    var acta = const Acta(asuntoUid: 'txoko');
    expect(acta.definitiva, isFalse);
    acta = acta.firmar(
        personaUid: 'ane', ahora: _ahora, compromisosUids: const ['c1']);
    expect(acta.definitiva, isFalse);
    expect(acta.compromisosAlFirmarUids, isNull);
    expect(
      () => acta
          .firmar(personaUid: 'ane', ahora: _ahora, compromisosUids: const []),
      throwsStateError,
    );
    acta = acta.firmar(
        personaUid: 'mikel', ahora: _ahora, compromisosUids: const ['c1']);
    expect(acta.definitiva, isTrue);
    expect(acta.compromisosAlFirmarUids, ['c1']);
  });

  test('una firma se retira mientras falte la otra, no después', () {
    final unaFirma = const Acta(asuntoUid: 'txoko')
        .firmar(personaUid: 'ane', ahora: _ahora, compromisosUids: const []);
    expect(unaFirma.retirarFirma('ane').tieneFirmas, isFalse);
    expect(() => unaFirma.retirarFirma('mikel'), throwsStateError);

    final firmada = unaFirma
        .firmar(personaUid: 'mikel', ahora: _ahora, compromisosUids: const []);
    expect(() => firmada.retirarFirma('ane'), throwsStateError);
    expect(
      () => firmada
          .firmar(personaUid: 'iker', ahora: _ahora, compromisosUids: const []),
      throwsStateError,
    );
  });
}
