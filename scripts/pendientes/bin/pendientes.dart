import 'dart:io';

import 'package:pendientes/pendientes.dart';

const String _ayuda = '''
Tablero de pendientes del monorepo.

Uso: dart run bin/pendientes.dart [--raiz <ruta>] [--html <archivo>]

  --raiz   raíz del monorepo (por defecto, dos niveles por encima de este paquete)
  --html   escribe además la página HTML en ese archivo
           (por defecto salida/pendientes.html)
  --solo-terminal  no escribe HTML
''';

void main(List<String> argumentos) {
  if (argumentos.contains('-h') || argumentos.contains('--help')) {
    stdout.write(_ayuda);
    return;
  }
  final directorioPaquete = File.fromUri(Platform.script).parent.parent.path;
  final raiz = _valorDe(argumentos, '--raiz') ??
      Directory('$directorioPaquete/../..').absolute.uri.normalizePath()
          .toFilePath()
          .replaceAll(RegExp(r'/$'), '');
  final rutaHtml =
      _valorDe(argumentos, '--html') ?? '$directorioPaquete/salida/pendientes.html';

  final inventario = recolectar(raiz);
  stdout.write(informeTerminal(inventario));

  if (!argumentos.contains('--solo-terminal')) {
    final archivoHtml = File(rutaHtml)..parent.createSync(recursive: true);
    archivoHtml.writeAsStringSync(informeHtml(inventario));
    stdout.writeln('\nHTML: ${archivoHtml.absolute.path}');
  }
}

String? _valorDe(List<String> argumentos, String opcion) {
  final indice = argumentos.indexOf(opcion);
  return indice >= 0 && indice + 1 < argumentos.length
      ? argumentos[indice + 1]
      : null;
}
