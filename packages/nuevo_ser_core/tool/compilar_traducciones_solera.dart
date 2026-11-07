// Genera lib/src/i18n/solera_l10n.dart a partir de
// content/solera/traducciones.csv (textos comunes) y de
// content/solera/traducciones/<app>.csv (los de cada app, con claves que
// empiezan por el prefijo de la app). Columnas: clave,es,eu,ca,gl.
//
// Textos con datos: marcadores {nombre} en el CSV y
// SoleraL10n.tf('clave', {'nombre': valor}).
//
// Uso, desde packages/nuevo_ser_core:
//   dart run tool/compilar_traducciones_solera.dart
//
// Reglas:
// - Si a una clave le falta el euskera, el catalán o el gallego, sale en
//   castellano (nunca la clave en bruto).
// - Toda clave tiene que tener castellano.
// - Las claves no pueden llevar «$»: Dart interpolaría la variable dentro de
//   la clave y no se encontraría nunca. Para textos con datos, traduce la
//   parte fija y concatena: '${SoleraL10n.t('error')}: $e'.
// - No puede haber claves repetidas.
//
// test/i18n/solera_l10n_test.dart comprueba que el fichero generado está al
// día con el CSV y que todas las claves usadas en las apps existen.

import 'dart:io';

const rutaCsv = '../../content/solera/traducciones.csv';
const carpetaCsvPorApp = '../../content/solera/traducciones';
const rutaSalida = 'lib/src/i18n/solera_l10n.dart';
const idiomas = ['es', 'eu', 'ca', 'gl'];

void main() {
  final fichero = File(rutaCsv);
  if (!fichero.existsSync()) {
    stderr.writeln('No encontrado: $rutaCsv (ejecuta desde packages/nuevo_ser_core)');
    exit(1);
  }
  final codigo = generarCodigoSoleraL10n(leerCsvsDeTraducciones());
  File(rutaSalida).writeAsStringSync(codigo);
  stdout.writeln('✅ $rutaSalida generado');
}

/// El CSV común seguido de los de cada app (por orden alfabético), como un
/// único CSV: cada fichero lleva su cabecera, que se salta al unirlos.
String leerCsvsDeTraducciones() {
  final ficheros = [
    File(rutaCsv),
    if (Directory(carpetaCsvPorApp).existsSync())
      ...(Directory(carpetaCsvPorApp)
              .listSync()
              .whereType<File>()
              .where((fichero) => fichero.path.endsWith('.csv'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path))),
  ];
  final unido = StringBuffer();
  for (final (indice, fichero) in ficheros.indexed) {
    final lineas = fichero.readAsStringSync().split('\n');
    unido.writeln((indice == 0 ? lineas : lineas.skip(1)).join('\n'));
  }
  return unido.toString();
}

/// El código Dart de `SoleraL10n` para el contenido del CSV.
String generarCodigoSoleraL10n(String contenidoCsv) {
  final lineas = contenidoCsv
      .split('\n')
      .where((linea) => linea.trim().isNotEmpty && !linea.startsWith('#'))
      .toList();
  final cabeceras = _leerLineaCsv(lineas.first);
  final indiceClave = cabeceras.indexOf('clave');
  final indicesIdioma = {for (final idioma in idiomas) idioma: cabeceras.indexOf(idioma)};
  if (indiceClave < 0 || indicesIdioma.values.any((indice) => indice < 0)) {
    throw FormatException('Cabecera esperada: clave,${idiomas.join(',')}');
  }

  final textosPorIdioma = {for (final idioma in idiomas) idioma: <String, String>{}};
  for (final linea in lineas.skip(1)) {
    final campos = _leerLineaCsv(linea);
    String campo(int indice) => indice < campos.length ? campos[indice].trim() : '';
    final clave = campo(indiceClave);
    if (clave.contains(r'$')) {
      throw FormatException('Clave con «\$»: $clave');
    }
    if (textosPorIdioma['es']!.containsKey(clave)) {
      throw FormatException('Clave repetida: $clave');
    }
    if (campo(indicesIdioma['es']!).isEmpty) {
      throw FormatException('Clave sin castellano: $clave');
    }
    for (final idioma in idiomas) {
      final texto = campo(indicesIdioma[idioma]!);
      if (texto.isNotEmpty) textosPorIdioma[idioma]![clave] = texto;
    }
  }

  final codigo = StringBuffer()
    ..writeln('/// GENERADO — no editar a mano.')
    ..writeln('/// Sale de content/solera/traducciones.csv con')
    ..writeln('/// `dart run tool/compilar_traducciones_solera.dart` (desde packages/nuevo_ser_core).')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln('class SoleraL10n {')
    ..writeln('  SoleraL10n._();')
    ..writeln()
    ..writeln("  static String _idioma = 'es';")
    ..writeln('  static final ValueNotifier<int> notificador = ValueNotifier<int>(0);')
    ..writeln()
    ..writeln('  static String get idioma => _idioma;')
    ..writeln('  static set idioma(String c) {')
    ..writeln('    _idioma = c;')
    ..writeln('    notificador.value++;')
    ..writeln('  }')
    ..writeln()
    ..writeln('  /// Claves con texto en castellano (para tests).')
    ..writeln('  static const clavesDisponibles = <String>{')
    ..writeAll(textosPorIdioma['es']!.keys.map((clave) => "    '${_escapar(clave)}',\n"))
    ..writeln('  };')
    ..writeln()
    ..writeln('  /// Claves que tienen texto propio en [idioma] (para tests).')
    ..writeln('  static Set<String> clavesTraducidas(String idioma) => switch (idioma) {');
  for (final idioma in idiomas.skip(1)) {
    codigo.writeln("        '$idioma' => _textos${_capitalizar(idioma)}.keys.toSet(),");
  }
  codigo
    ..writeln('        _ => clavesDisponibles,')
    ..writeln('      };')
    ..writeln()
    ..writeln('  static String t(String clave, {String? idioma}) {')
    ..writeln('    switch (idioma ?? _idioma) {')
    ..writeln("      case 'eu': return _tEu(clave);")
    ..writeln("      case 'ca': return _tCa(clave);")
    ..writeln("      case 'gl': return _tGl(clave);")
    ..writeln('      default: return _tEs(clave);')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln()
    ..writeln('  /// Como [t], sustituyendo los marcadores `{nombre}` por sus valores:')
    ..writeln("  /// `tf('colmenas_n', {'n': 3})` con «{n} colmenas» da «3 colmenas».")
    ..writeln('  static String tf(String clave, Map<String, Object?> valores, {String? idioma}) {')
    ..writeln('    var texto = t(clave, idioma: idioma);')
    ..writeln('    valores.forEach((nombre, valor) {')
    ..writeln("      texto = texto.replaceAll('{\$nombre}', '\${valor ?? ''}');")
    ..writeln('    });')
    ..writeln('    return texto;')
    ..writeln('  }')
    ..writeln();

  // Un mapa constante por idioma. Hasta el 2026-11-07 era un `switch` por
  // idioma; con ~5.300 claves el compilador JIT de la VM se caía
  // (segmentation fault) al optimizarlo. Lo que falta en un idioma sale en
  // castellano; lo que falta en castellano, como la clave (el test lo impide).
  for (final idioma in idiomas) {
    final sufijo = _capitalizar(idioma);
    codigo.writeln(idioma == 'es'
        ? '  static String _tEs(String c) => _textosEs[c] ?? c;'
        : '  static String _t$sufijo(String c) => _textos$sufijo[c] ?? _tEs(c);');
  }
  codigo.writeln();
  for (final idioma in idiomas) {
    codigo.writeln('  static const _textos${_capitalizar(idioma)} = <String, String>{');
    textosPorIdioma[idioma]!.forEach((clave, texto) {
      codigo.writeln("    '${_escapar(clave)}': '${_escapar(texto)}',");
    });
    codigo
      ..writeln('  };')
      ..writeln();
  }
  codigo.writeln('}');
  return codigo.toString();
}

String _capitalizar(String texto) => texto[0].toUpperCase() + texto.substring(1);

/// Escapa un texto para un literal Dart entre comillas simples.
String _escapar(String texto) => texto
    .replaceAll('\\', '\\\\')
    .replaceAll("'", "\\'")
    .replaceAll('\n', '\\n')
    .replaceAll('\r', '')
    .replaceAll(r'$', r'\$');

/// Una línea de CSV con comillas («""» dentro de comillas es una comilla).
List<String> _leerLineaCsv(String linea) {
  final campos = <String>[];
  final campoActual = StringBuffer();
  var entreComillas = false;
  for (var i = 0; i < linea.length; i++) {
    final caracter = linea[i];
    if (caracter == '"') {
      if (entreComillas && i + 1 < linea.length && linea[i + 1] == '"') {
        campoActual.write('"');
        i++;
      } else {
        entreComillas = !entreComillas;
      }
    } else if (caracter == ',' && !entreComillas) {
      campos.add(campoActual.toString());
      campoActual.clear();
    } else {
      campoActual.write(caracter);
    }
  }
  campos.add(campoActual.toString());
  return campos;
}
