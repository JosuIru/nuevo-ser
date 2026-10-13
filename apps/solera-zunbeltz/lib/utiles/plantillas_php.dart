import '../modelos/plantillas_tarea.dart';

/// Las tareas tipo ([plantillasTarea]) como fichero PHP para el panel de
/// coordinación del plugin, que las ofrece al escribir el título de una
/// tarea. Lo escribe `tool/generar_plantillas_php.dart`; un test comprueba
/// que el fichero del plugin está al día.
String plantillasTareaComoPhp() {
  String cadena(String texto) =>
      "'${texto.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
  final lineas = StringBuffer()
    ..writeln('<?php')
    ..writeln('/**')
    ..writeln(' * Tareas tipo de Zunbeltz (ganado e instalaciones) para el panel:')
    ..writeln(' * título => periodicidad sugerida en días (0 = puntual; PROVISIONAL).')
    ..writeln(' *')
    ..writeln(' * GENERADO desde apps/solera-zunbeltz/lib/modelos/plantillas_tarea.dart')
    ..writeln(' * con `dart run tool/generar_plantillas_php.dart`. No editar a mano.')
    ..writeln(' *')
    ..writeln(' * @package SoleraZunbeltzSync')
    ..writeln(' */')
    ..writeln()
    ..writeln("if ( ! defined( 'ABSPATH' ) ) {")
    ..writeln('\texit;')
    ..writeln('}')
    ..writeln()
    ..writeln('const SZS_PLANTILLAS_TAREA = array(');
  for (final plantilla in plantillasTarea) {
    final dias = plantilla.recurrenciaDias ?? 0;
    final titulos = plantilla.subtipos.isEmpty
        ? [plantilla.titulo('es')]
        : [for (final subtipo in plantilla.subtipos) plantilla.titulo('es', subtipo)];
    for (final titulo in titulos) {
      lineas.writeln('\t${cadena(titulo)} => $dias,');
    }
  }
  lineas.writeln(');');
  return lineas.toString();
}
