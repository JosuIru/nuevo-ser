import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show filaCsvAString;
import 'package:path/path.dart' as ruta;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';

/// Una tabla de la BD en CSV (pura): cabecera con todas las columnas que
/// aparecen y una fila por registro; nulos como vacío.
String tablaACsv(List<Map<String, Object?>> filas) {
  final columnas = <String>[];
  for (final fila in filas) {
    for (final columna in fila.keys) {
      if (!columnas.contains(columna)) columnas.add(columna);
    }
  }
  final lineas = [
    filaCsvAString(columnas),
    for (final fila in filas)
      filaCsvAString([
        for (final columna in columnas) '${fila[columna] ?? ''}',
      ]),
  ];
  return '${lineas.join('\n')}\n';
}

/// **Hard limit 4**: los datos son del ganadero. Escribe un CSV por tabla en
/// una carpeta temporal y abre la hoja de compartir con todos.
Future<void> exportarTodosLosDatos() async {
  final volcado = await BaseDatosSoleraGanadera.instancia.volcarTodo();
  final carpeta = Directory(ruta.join((await getTemporaryDirectory()).path,
      'larrea_ganadera_${DateTime.now().millisecondsSinceEpoch}'));
  await carpeta.create(recursive: true);
  final ficheros = <XFile>[];
  for (final MapEntry(key: tabla, value: filas) in volcado.entries) {
    final fichero = File(ruta.join(carpeta.path, '$tabla.csv'));
    await fichero.writeAsString(tablaACsv(filas));
    ficheros.add(XFile(fichero.path, mimeType: 'text/csv'));
  }
  await Share.shareXFiles(ficheros, subject: 'Larrea Ganadera');
}
