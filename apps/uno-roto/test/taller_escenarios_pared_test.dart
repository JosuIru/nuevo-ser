import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/datos/dibujos_taller.dart';
import 'package:uno_roto/vista/escenarios_ilustrados.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_pared.dart';

Future<String> _png(Directory carpeta, String nombre) async {
  final fichero = File('${carpeta.path}/$nombre.png');
  final pixeles = Uint8List(8 * 4 * 4);
  for (var i = 0; i < pixeles.length; i += 4) {
    pixeles
      ..[i] = 220
      ..[i + 1] = 120
      ..[i + 2] = 60
      ..[i + 3] = 255;
  }
  final lista = <ui.Image>[];
  ui.decodeImageFromPixels(pixeles, 8, 4, ui.PixelFormat.rgba8888, lista.add);
  while (lista.isEmpty) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fichero.writeAsBytesSync((await lista.first.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List());
  return fichero.path;
}

void main() {
  late Directory carpeta;
  setUp(() => carpeta = Directory.systemTemp.createTempSync('taller'));
  tearDown(() {
    for (final coleccion in coleccionesDelTaller) {
      coleccion.rutas.value = const {};
    }
    carpeta.deleteSync(recursive: true);
  });

  testWidgets('el dibujo del distrito hace de paisaje, encendido y apagado', (tester) async {
    await tester.runAsync(() async {
      final ruta = await _png(carpeta, 'mercado');
      dibujosDistritos.rutas.value = {'mercado': ruta};
      await EscenariosIlustrados.cargar('mercado');
      expect(EscenariosIlustrados.esDibujo('mercado'), isTrue);
      final encendido = EscenariosIlustrados.encendido('mercado')!;
      final apagado = EscenariosIlustrados.apagado('mercado')!;
      expect(encendido.width, 8);
      // La versión apagada es el mismo dibujo, más oscuro.
      final luz = (await encendido.toByteData())!.getUint8(0);
      final sombra = (await apagado.toByteData())!.getUint8(0);
      expect(sombra, lessThan(luz ~/ 2));
      // Al quitar el dibujo, se vuelve al original (en los tests no hay
      // asset: sin escenario, y ya no es dibujo).
      dibujosDistritos.rutas.value = const {};
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(EscenariosIlustrados.esDibujo('mercado'), isFalse);
    });
  });

  testWidgets('la pared cuelga los dibujos de todas las colecciones con su nombre', (tester) async {
    final rutas = (await tester.runAsync(() async => [
          await _png(carpeta, 'fugas'),
          await _png(carpeta, 'sora'),
          await _png(carpeta, 'telar'),
        ]))!;
    await tester.pumpWidget(const MaterialApp(home: PantallaPared()));
    expect(find.textContaining('De momento está vacía'), findsOneWidget);
    dibujosMonstruos.rutas.value = {'fugas': rutas[0]};
    dibujosPersonajes.rutas.value = {'sora': rutas[1]};
    dibujosMaquinas.rutas.value = {'telar': rutas[2]};
    await tester.pump();
    expect(dibujosColgados().map((d) => d.nombre), containsAll(['Las Fugas', 'Sora', 'El telar']));
    expect(find.byWidgetPredicate((w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('cartel-')),
        findsNWidgets(3));
    expect(find.textContaining('la mejor pared'), findsOneWidget);
  });
}
