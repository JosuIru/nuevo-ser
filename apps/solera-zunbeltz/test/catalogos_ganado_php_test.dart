import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/catalogos_ganado_php.dart';

void main() {
  test('el PHP del ganado lleva especies, tipos y clases de medicamento', () {
    final php = catalogosGanadoComoPhp();
    expect(php, contains("'vacuno' => 'Vacuno'"));
    expect(php, contains("'traslado' => 'Cambio de pieza'"));
    expect(php, contains("'antiparasitario' => 'Antiparasitario'"));
    expect(php, contains("'saneamiento',"));
  });

  test('el panel de WordPress tiene los mismos catálogos del ganado', () {
    final enPlugin = File(
            '../../wp-plugin/solera-zunbeltz-sync/includes/catalogos-ganado.php')
        .readAsStringSync();
    expect(enPlugin, catalogosGanadoComoPhp(),
        reason: 'ejecuta: dart run tool/generar_plantillas_php.dart');
  });
}
