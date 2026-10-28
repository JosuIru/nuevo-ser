// Deja la versión web lista para abrirse sin cobertura: pone en el service
// worker (`sw_zunbeltz.js`, copiado de `web/` por `flutter build web`) la
// versión del build y la lista de ficheros que guarda en el navegador.
//
//   dart run tool/preparar_web_sin_conexion.dart build/web
//
// Lo llaman tool/construir_demo_web.sh y el construir_app_web.sh del
// plugin justo después de compilar. Sin este paso el service worker no se
// instala (la plantilla no tiene lista).

import 'dart:io';

import 'package:path/path.dart' as path_lib;
import 'package:solera_zunbeltz/utiles/web_sin_conexion.dart';

void main(List<String> argumentos) {
  if (argumentos.length != 1) {
    stderr.writeln(
        'Uso: dart run tool/preparar_web_sin_conexion.dart <carpeta del build web>');
    exit(64);
  }
  final carpeta = Directory(argumentos.single);
  final ficheroServiceWorker =
      File(path_lib.join(carpeta.path, 'sw_zunbeltz.js'));
  if (!ficheroServiceWorker.existsSync()) {
    stderr.writeln(
        'No está ${ficheroServiceWorker.path}: ¿se ha compilado la web?');
    exit(1);
  }
  final contenidos = <String, List<int>>{};
  for (final entidad in carpeta.listSync(recursive: true)) {
    if (entidad is! File) continue;
    final ruta = path_lib
        .relative(entidad.path, from: carpeta.path)
        .replaceAll(Platform.pathSeparator, '/');
    contenidos[ruta] = entidad.readAsBytesSync();
  }
  final version = versionSinConexion(contenidos);
  final ficheros = ficherosPrecache(contenidos.keys);
  ficheroServiceWorker.writeAsStringSync(rellenarServiceWorker(
      ficheroServiceWorker.readAsStringSync(), version, ficheros));
  stdout.writeln('Sin conexión: ${ficheros.length} ficheros, versión $version');
}
