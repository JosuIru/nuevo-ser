import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/catalogos_convenio_php.dart';

void main() {
  test('el PHP de los catálogos lleva bloques, partidas y tipos', () {
    final php = catalogosConvenioComoPhp();
    expect(php, contains("'directos' => 'I. Costes directos'"));
    expect(php, contains("'compra_alimento' => 'Compra de alimento'"));
    expect(php, contains("'retencion' => 'Retención'"));
    expect(php, contains("'muy_grave' => 'Muy grave'"));
    expect(php, contains("'visita_referencia' =>"));
    expect(php, contains("'animales',"));
  });

  test('el panel de WordPress tiene los mismos catálogos del convenio', () {
    final enPlugin = File(
            '../../wp-plugin/solera-zunbeltz-sync/includes/catalogos-convenio.php')
        .readAsStringSync();
    expect(enPlugin, catalogosConvenioComoPhp(),
        reason: 'ejecuta: dart run tool/generar_plantillas_php.dart');
  });
}
