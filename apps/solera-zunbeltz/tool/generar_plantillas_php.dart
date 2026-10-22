// Escribe en el plugin de WordPress lo que el panel de coordinación
// comparte con la app: las tareas tipo y los catálogos del convenio y del
// ganado.
//
//   dart run tool/generar_plantillas_php.dart
//
// Hay que ejecutarlo tras cambiar lib/modelos/plantillas_tarea.dart o los
// catálogos del convenio de lib/modelos/constantes.dart (los tests
// test/plantillas_presupuesto_test.dart y test/catalogos_convenio_php_test.dart
// avisan si se olvida).

import 'dart:io';

import 'package:solera_zunbeltz/utiles/catalogos_convenio_php.dart';
import 'package:solera_zunbeltz/utiles/catalogos_ganado_php.dart';
import 'package:solera_zunbeltz/utiles/plantillas_php.dart';

const rutaPlugin = '../../wp-plugin/solera-zunbeltz-sync/includes/';

void main() {
  for (final (fichero, contenido) in [
    ('plantillas-tarea.php', plantillasTareaComoPhp()),
    ('catalogos-convenio.php', catalogosConvenioComoPhp()),
    ('catalogos-ganado.php', catalogosGanadoComoPhp()),
  ]) {
    File(rutaPlugin + fichero).writeAsStringSync(contenido);
    stdout.writeln('Escrito $rutaPlugin$fichero');
  }
}
