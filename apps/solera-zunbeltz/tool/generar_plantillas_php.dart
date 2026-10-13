// Escribe las tareas tipo de la app en el plugin de WordPress, para que el
// panel de coordinación ofrezca las mismas al crear una tarea:
//
//   dart run tool/generar_plantillas_php.dart
//
// Hay que ejecutarlo tras cambiar lib/modelos/plantillas_tarea.dart (el test
// test/plantillas_presupuesto_test.dart avisa si se olvida).

import 'dart:io';

import 'package:solera_zunbeltz/utiles/plantillas_php.dart';

const rutaPlugin =
    '../../wp-plugin/solera-zunbeltz-sync/includes/plantillas-tarea.php';

void main() {
  File(rutaPlugin).writeAsStringSync(plantillasTareaComoPhp());
  stdout.writeln('Escrito $rutaPlugin');
}
