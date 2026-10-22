import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/textos_ayuda_generador.dart';

Map<String, dynamic> _arb(String idioma) =>
    jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('las claves de la ayuda siguen el índice y llevan las versiones tester',
      () {
    final claves = clavesAyuda();
    expect(claves, contains('ayudaGrupoFincas'));
    expect(claves, contains('ayudaZonasTesterB'));
    expect(claves, isNot(contains('ayudaQueEsTesterB')));
    expect(claves.toSet().length, claves.length, reason: 'sin repetidas');
  });

  test('el PHP del plugin y el mapa Dart están al día con los ARB', () {
    final php = textosAyudaComoPhp(_arb('es'), _arb('eu'));
    expect(php, contains("'ayudaQueEsT' =>"));
    expect(
        File('../../wp-plugin/solera-zunbeltz-sync/includes/textos-ayuda.php')
            .readAsStringSync(),
        php,
        reason: 'ejecuta: dart run tool/generar_textos_ayuda.dart');
    expect(File('lib/pantallas/textos_ayuda_de_serie.dart').readAsStringSync(),
        textosAyudaComoDart(),
        reason: 'ejecuta: dart run tool/generar_textos_ayuda.dart');
  });
}
