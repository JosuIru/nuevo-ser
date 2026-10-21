import '../modelos/constantes.dart';

/// Los catálogos del convenio (bloques y partidas de gasto, quién asume,
/// movimientos de fianza, niveles de incidencia y tipos de acompañamiento)
/// como fichero PHP para el panel de coordinación del plugin, que edita el
/// convenio con las mismas opciones que la app. Lo escribe
/// `tool/generar_plantillas_php.dart`; un test comprueba que el fichero del
/// plugin está al día.
String catalogosConvenioComoPhp() {
  String cadena(String texto) =>
      "'${texto.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
  final lineas = StringBuffer()
    ..writeln('<?php')
    ..writeln('/**')
    ..writeln(' * Catálogos del convenio tester (castellano) para el panel: bloques y')
    ..writeln(' * partidas de gasto, quién asume, movimientos de fianza, niveles de')
    ..writeln(' * incidencia y tipos de acompañamiento.')
    ..writeln(' *')
    ..writeln(' * GENERADO desde apps/solera-zunbeltz/lib/modelos/constantes.dart')
    ..writeln(' * con `dart run tool/generar_plantillas_php.dart`. No editar a mano.')
    ..writeln(' *')
    ..writeln(' * @package SoleraZunbeltzSync')
    ..writeln(' */')
    ..writeln()
    ..writeln("if ( ! defined( 'ABSPATH' ) ) {")
    ..writeln('\texit;')
    ..writeln('}')
    ..writeln();

  void constante(String nombre, List<OpcionCatalogo> opciones) {
    lineas.writeln('const $nombre = array(');
    for (final opcion in opciones) {
      lineas.writeln('\t${cadena(opcion.codigo)} => ${cadena(opcion.es)},');
    }
    lineas
      ..writeln(');')
      ..writeln();
  }

  constante('SZS_BLOQUES_GASTO', categoriasGasto);
  lineas.writeln('const SZS_PARTIDAS_GASTO = array(');
  for (final bloque in categoriasGasto) {
    lineas.writeln('\t${cadena(bloque.codigo)} => array(');
    for (final partida in partidasGasto[bloque.codigo] ?? const []) {
      lineas.writeln('\t\t${cadena(partida.codigo)} => ${cadena(partida.es)},');
    }
    lineas.writeln('\t),');
  }
  lineas
    ..writeln(');')
    ..writeln()
    ..writeln('const SZS_PARTIDAS_ASUMIDAS_POR_TESTER = array(');
  for (final partida in partidasAsumidasPorTester) {
    lineas.writeln('\t${cadena(partida)},');
  }
  lineas
    ..writeln(');')
    ..writeln();
  constante('SZS_ASUMIDO_POR', asumidoPorOpciones);
  constante('SZS_TIPOS_MOVIMIENTO_FIANZA', tiposMovimientoFianza);
  constante('SZS_NIVELES_INCIDENCIA', nivelesIncidencia);
  constante('SZS_TIPOS_ACOMPANAMIENTO', tiposAcompanamiento);
  return lineas.toString();
}
