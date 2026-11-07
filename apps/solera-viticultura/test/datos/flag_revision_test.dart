import 'package:flutter_test/flutter_test.dart';
import 'package:solera_viticultura/datos/catalogos_generados/flag_revision.dart';

void main() {
  test('flag falso mientras ninguna persona experta firme todas las filas', () {
    // Solo cuenta como firma un `revisado_por` que empiece por `asesor:` o
    // `persona:`. Una fuente pública, una cita o `revision-ia:` no retiran el
    // banner de datos provisionales (ver scripts/pendientes/README.md).
    expect(catalogosCompletamenteRevisados, isFalse);
  });
}
