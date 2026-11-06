import 'dart:convert';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/debate.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  test('el pueblo de ejemplo va y vuelve por JSON sin perder nada', () {
    final original = estadoDeEjemplo(hoy: _hoy)
      ..firmarActa('txoko')
      ..aportar('fiestas', TipoAportacion.duda, '¿Y la charanga?',
          anonima: true);
    final texto = jsonEncode(instantaneaAJson(original, revision: 7));
    final leido = jsonDecode(texto) as Map<String, dynamic>;
    expect(leido['revision'], 7);

    final copia =
        instantaneaDesdeJson(leido, personaActualUid: 'ane', reloj: () => _hoy);
    expect(jsonEncode(instantaneaAJson(copia, revision: 7)), texto);
    expect(copia.acta('txoko').firmadaPor('ane'), isTrue);
    expect(copia.urna('txoko').papeletas, hasLength(4));
    expect(
        copia.consentimiento('comunal').objeciones.single.autorUid, 'josean');
  });
}
