import 'dart:io';

import 'package:traducciones/traducciones.dart';

const textoDeUso = '''
Revisor de traducciones para nativos (ARB ⇄ hoja CSV)

Uso:
  dart run traducciones exportar <dir_arb> <lengua> <salida.csv>
  dart run traducciones importar <dir_arb> <lengua> <entrada.csv>
  dart run traducciones estado   <dir_arb>

Ejemplo:
  dart run traducciones exportar ../../social/apps/concejo/lib/l10n eu concejo_eu.csv
''';

/// Códigos de salida: 0 bien, 1 hubo filas rechazadas, 2 error, 64 mal uso.
void main(List<String> argumentos) {
  if (argumentos.isEmpty) {
    stderr.write(textoDeUso);
    exit(64);
  }
  final orden = argumentos.first;
  final parametros = argumentos.skip(1).toList();
  try {
    switch ((orden, parametros.length)) {
      case ('exportar', 3):
        final numeroDeCadenas = exportarHoja(
            Directory(parametros[0]), parametros[1], File(parametros[2]));
        stdout
            .writeln('Exportadas $numeroDeCadenas cadenas a ${parametros[2]}');
      case ('importar', 3):
        exit(_importar(parametros[0], parametros[1], parametros[2]));
      case ('estado', 1):
        _mostrarEstado(parametros[0]);
      default:
        stderr.write(textoDeUso);
        exit(64);
    }
  } on ArgumentError catch (error) {
    stderr.writeln('Error: ${error.message}');
    exit(2);
  } on FormatException catch (error) {
    stderr.writeln('Error: ${error.message}');
    exit(2);
  } on FileSystemException catch (error) {
    stderr.writeln('Error: ${error.message} (${error.path})');
    exit(2);
  }
}

int _importar(String rutaDirectorio, String lengua, String rutaHoja) {
  final resultado =
      importarHoja(Directory(rutaDirectorio), lengua, File(rutaHoja));
  stdout.writeln('Aplicadas: ${resultado.aplicadas.length}'
      '${resultado.aplicadas.isEmpty ? '' : ' (${resultado.aplicadas.join(', ')})'}');
  stdout.writeln('Revisadas sin cambios: ${resultado.revisadasSinCambios}');
  stdout
      .writeln('Filas no revisadas (ignoradas): ${resultado.filasNoRevisadas}');
  if (resultado.aplicadas.isNotEmpty) {
    stdout.writeln('Escrito ${resultado.archivo.path}');
  } else {
    stdout.writeln('Sin cambios en ${resultado.archivo.path}');
  }
  if (resultado.rechazadas.isEmpty) return 0;
  stdout
      .writeln('\nRechazadas (${resultado.rechazadas.length}, no aplicadas):');
  for (final rechazo in resultado.rechazadas) {
    stdout.writeln('  - $rechazo');
  }
  return 1;
}

void _mostrarEstado(String rutaDirectorio) {
  final resumenes = resumirDirectorio(Directory(rutaDirectorio));
  if (resumenes.isEmpty) {
    stdout.writeln('No hay lenguas traducidas aparte del español.');
    return;
  }
  const anchoColumna = 9;
  String columna(Object valor) => '$valor'.padLeft(anchoColumna);
  stdout.writeln('lengua${columna('total')}${columna('faltan')}'
      '${columna('iguales')}${columna('sobran')}${columna('errores')}');
  for (final resumen in resumenes) {
    stdout.writeln('${resumen.lengua.padRight(6)}${columna(resumen.total)}'
        '${columna(resumen.faltan)}${columna(resumen.igualesAlEspanol)}'
        '${columna(resumen.sobrantes)}${columna(resumen.conErrorDeEstructura)}');
  }
  stdout.writeln('\niguales = idénticas al español; sobran = claves que ya no '
      'existen en español; errores = placeholders o ICU distintos del español.');
}
