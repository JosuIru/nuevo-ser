/// Genera, a partir de los ARB, lo que la ayuda necesita fuera del ARB:
/// - `includes/textos-ayuda.php` del plugin: índice, apartados con versión
///   tester y los textos de serie en es/eu, para que coordinación los edite
///   en el panel y el servidor imprima el manual;
/// - `lib/pantallas/textos_ayuda_de_serie.dart`: un mapa clave → texto de
///   `AppLocalizations`, para que la pantalla pueda sustituir por clave lo
///   que baje del servidor.
///
/// Lo ejecuta `tool/generar_textos_ayuda.dart`; los tests avisan si los
/// ficheros generados no están al día. Dart puro (sin Flutter).
library;

import '../pantallas/indice_ayuda.dart';

/// Claves sueltas que la pantalla y el manual usan además de los apartados.
const List<String> clavesAyudaSueltas = [
  'ayudaIntro',
  'ayudaConsejo',
  'ayudaPie',
  'ayudaPerfilTester',
  'ayudaManualTester',
  'ajustesProvisional',
  'meteoOrientativo',
];

/// Todas las claves de texto de la ayuda, en el orden del índice.
List<String> clavesAyuda() {
  final claves = <String>[...clavesAyudaSueltas];
  indiceAyuda.forEach((grupo, apartados) {
    claves.add(grupo);
    for (final apartado in apartados) {
      claves
        ..add('${apartado}T')
        ..add('${apartado}B');
      if (apartadosConVersionTester.contains(apartado)) {
        claves
          ..add('${apartado}TesterT')
          ..add('${apartado}TesterB');
      }
    }
  });
  return claves;
}

String _php(String texto) =>
    "'${texto.replaceAll('\\', '\\\\').replaceAll("'", "\\'")}'";

/// El PHP con el índice y los textos de serie de los dos idiomas.
String textosAyudaComoPhp(
    Map<String, dynamic> arbEs, Map<String, dynamic> arbEu) {
  final salida = StringBuffer()
    ..writeln('<?php')
    ..writeln('/**')
    ..writeln(' * GENERADO desde los ARB de la app con')
    ..writeln(
        ' * `dart run tool/generar_textos_ayuda.dart` — NO editar a mano.')
    ..writeln(' *')
    ..writeln(
        ' * Índice de la ayuda, apartados con versión para tester y textos de')
    ..writeln(' * serie en castellano y euskera. Coordinación los cambia en')
    ..writeln(' * Solera Zunbeltz → Ayuda (includes/ayuda.php).')
    ..writeln(' *')
    ..writeln(' * @package SoleraZunbeltzSync')
    ..writeln(' */')
    ..writeln()
    ..writeln("if ( ! defined( 'ABSPATH' ) ) {")
    ..writeln('\texit;')
    ..writeln('}')
    ..writeln()
    ..writeln(
        '/** Grupo → claves de sus apartados (cada uno con T título y B cuerpo). */')
    ..writeln('const SZS_AYUDA_INDICE = array(');
  indiceAyuda.forEach((grupo, apartados) {
    salida.writeln(
        '\t${_php(grupo)} => array( ${apartados.map(_php).join(', ')} ),');
  });
  salida
    ..writeln(');')
    ..writeln()
    ..writeln(
        '/** Apartados que tienen además versión para tester (TesterT / TesterB). */')
    ..writeln(
        'const SZS_AYUDA_CON_TESTER = array( ${apartadosConVersionTester.map(_php).join(', ')} );')
    ..writeln()
    ..writeln('/** Claves sueltas (intro, rótulos, avisos del manual). */')
    ..writeln(
        'const SZS_AYUDA_CLAVES_SUELTAS = array( ${clavesAyudaSueltas.map(_php).join(', ')} );')
    ..writeln()
    ..writeln('/** Textos de serie, por idioma y clave. */')
    ..writeln('const SZS_AYUDA_TEXTOS_DE_SERIE = array(');
  for (final (idioma, arb) in [('es', arbEs), ('eu', arbEu)]) {
    salida.writeln('\t${_php(idioma)} => array(');
    for (final clave in clavesAyuda()) {
      final texto = arb[clave];
      if (texto is! String) {
        throw StateError('Falta "$clave" en el ARB $idioma');
      }
      salida.writeln('\t\t${_php(clave)} => ${_php(texto)},');
    }
    salida.writeln('\t),');
  }
  salida.writeln(');');
  return salida.toString();
}

/// El Dart con el mapa clave → texto de `AppLocalizations`.
String textosAyudaComoDart() {
  final salida = StringBuffer()
    ..writeln(
        '// GENERADO desde los ARB con `dart run tool/generar_textos_ayuda.dart`')
    ..writeln('// — NO editar a mano.')
    ..writeln()
    ..writeln("import '../l10n/app_localizations.dart';")
    ..writeln()
    ..writeln(
        '/// Textos de la ayuda que van dentro de la app, por clave del ARB. Lo')
    ..writeln('/// que coordinación cambie en el panel se superpone por clave')
    ..writeln('/// (`ServicioTextosAyuda`).')
    ..writeln(
        'Map<String, String> textosAyudaDeSerie(AppLocalizations t) => {');
  for (final clave in clavesAyuda()) {
    salida.writeln("      '$clave': t.$clave,");
  }
  salida.writeln('    };');
  return salida.toString();
}
