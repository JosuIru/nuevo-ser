import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/servicios/sincronizacion_segundo_plano.dart';

void main() {
  test('en segundo plano no se sincroniza si se acaba de hacer', () {
    final ahora = DateTime(2026, 10, 6, 12);
    expect(tocaSincronizar(null, ahora), isTrue, reason: 'nunca se ha sincronizado');
    expect(
        tocaSincronizar(
            ahora.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch, ahora),
        isFalse,
        reason: 'la app abierta acaba de sincronizar');
    expect(
        tocaSincronizar(
            ahora.subtract(const Duration(minutes: 20)).millisecondsSinceEpoch, ahora),
        isTrue);
  });
}
