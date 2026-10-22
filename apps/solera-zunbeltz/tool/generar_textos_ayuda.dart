// Escribe los textos de la ayuda donde hacen falta fuera del ARB: el PHP
// del plugin (para editarlos en el panel y servir el manual) y el mapa Dart
// por clave de la pantalla de Ayuda.
//
//   dart run tool/generar_textos_ayuda.dart
//
// Ejecutar tras cambiar un texto de ayuda en lib/l10n/app_es.arb o
// app_eu.arb (test/textos_ayuda_generados_test.dart avisa si se olvida).

import 'dart:convert';
import 'dart:io';

import 'package:solera_zunbeltz/utiles/textos_ayuda_generador.dart';

Map<String, dynamic> _arb(String idioma) =>
    jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const php = '../../wp-plugin/solera-zunbeltz-sync/includes/textos-ayuda.php';
  const dart = 'lib/pantallas/textos_ayuda_de_serie.dart';
  File(php).writeAsStringSync(textosAyudaComoPhp(_arb('es'), _arb('eu')));
  File(dart).writeAsStringSync(textosAyudaComoDart());
  stdout
    ..writeln('Escrito $php')
    ..writeln('Escrito $dart');
}
