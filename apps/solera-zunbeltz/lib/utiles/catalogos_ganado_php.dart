import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';

/// Los catálogos del ganado (especies, sexos, estados de un animal, tipos
/// de movimiento y de manejo, clases de medicamento) como fichero PHP para
/// la página Ganado del panel. Lo escribe `tool/generar_plantillas_php.dart`;
/// un test comprueba que el fichero del plugin está al día.
String catalogosGanadoComoPhp() {
  String cadena(String texto) =>
      "'${texto.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
  final lineas = StringBuffer()
    ..writeln('<?php')
    ..writeln('/**')
    ..writeln(' * Catálogos del ganado (castellano) para el panel.')
    ..writeln(' *')
    ..writeln(
        ' * GENERADO desde apps/solera-zunbeltz/lib/modelos/ (constantes.dart,')
    ..writeln(' * ganado.dart, ganado_ecologico.dart) con')
    ..writeln(
        ' * `dart run tool/generar_plantillas_php.dart`. No editar a mano.')
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

  constante('SZS_ESPECIES_GANADO', especiesGanado);
  constante('SZS_SEXOS_ANIMAL', sexosAnimal);
  constante('SZS_ESTADOS_ANIMAL', estadosAnimal);
  constante('SZS_TIPOS_MOVIMIENTO_GANADO', tiposMovimientoGanado);
  constante('SZS_TIPOS_EVENTO_GANADO', tiposEventoGanado);
  constante('SZS_CLASES_MEDICAMENTO', clasesMedicamento);
  lineas.writeln('const SZS_TIPOS_EVENTO_CON_MEDICAMENTO = array(');
  for (final tipo in tiposEventoConMedicamento) {
    lineas.writeln('\t${cadena(tipo)},');
  }
  lineas.writeln(');');
  return lineas.toString();
}
