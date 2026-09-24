import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/datos/dibujos_taller.dart';
import 'package:uno_roto/dominio/limpiador_dibujo.dart';
import 'package:uno_roto/vista/minijuegos/monstruo_maquina.dart';

/// Papel con sombra (de 200 a 250 de brillo, algo de ruido), un trazo de
/// lápiz gris oscuro y una mancha roja de cera.
PixelesDibujo _fotoDePapel() {
  const ancho = 60, alto = 40;
  final rgba = Uint8List(ancho * alto * 4);
  for (var y = 0; y < alto; y++) {
    for (var x = 0; x < ancho; x++) {
      final i = (y * ancho + x) * 4;
      var gris = 200 + (x * 50 ~/ ancho) + ((x * 7 + y * 13) % 5);
      var (r, g, b) = (gris, gris, gris - 4);
      if (x >= 20 && x < 30 && y >= 10 && y < 13) (r, g, b) = (70, 70, 75); // lápiz
      if (x >= 35 && x < 40 && y >= 20 && y < 25) (r, g, b) = (210, 40, 40); // cera roja
      rgba
        ..[i] = r
        ..[i + 1] = g
        ..[i + 2] = b
        ..[i + 3] = 255;
    }
  }
  return PixelesDibujo(rgba, ancho, alto);
}

int _alfa(PixelesDibujo p, int x, int y) => p.rgba[(y * p.ancho + x) * 4 + 3];

void main() {
  test('quita el papel aunque tenga sombra y deja lápiz y color, recortado', () {
    final limpio = quitarPapel(_fotoDePapel())!;
    // Recortado alrededor de lo dibujado (de x 20 a 39, de y 10 a 24) con margen.
    expect(limpio.ancho, lessThan(30));
    expect(limpio.alto, lessThan(22));
    var opacos = 0;
    var transparentes = 0;
    for (var y = 0; y < limpio.alto; y++) {
      for (var x = 0; x < limpio.ancho; x++) {
        final a = _alfa(limpio, x, y);
        if (a == 255) opacos++;
        if (a == 0) transparentes++;
      }
    }
    // 30 píxeles de lápiz y 25 de cera, enteros; casi todo lo demás, fuera.
    expect(opacos, inInclusiveRange(55, 70));
    expect(transparentes, greaterThan(limpio.ancho * limpio.alto * 0.7));
  });

  test('una foto sólo de papel no tiene dibujo', () {
    const ancho = 20, alto = 20;
    final rgba = Uint8List(ancho * alto * 4);
    for (var i = 0; i < rgba.length; i += 4) {
      rgba
        ..[i] = 240
        ..[i + 1] = 240
        ..[i + 2] = 236
        ..[i + 3] = 255;
    }
    expect(quitarPapel(PixelesDibujo(rgba, ancho, alto)), isNull);
  });

  testWidgets('de la foto al PNG limpio', (tester) async {
    await tester.runAsync(() async {
      final foto = _fotoDePapel();
      final completer = <ui.Image>[];
      ui.decodeImageFromPixels(foto.rgba, foto.ancho, foto.alto, ui.PixelFormat.rgba8888, completer.add);
      while (completer.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      final png = (await completer.first.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      final limpio = await limpiarDibujo(png);
      expect(limpio, isNotNull);
      final imagen = (await (await ui.instantiateImageCodec(limpio!)).getNextFrame()).image;
      expect(imagen.width, lessThan(foto.ancho));
      expect(imagen.height, lessThan(foto.alto));
    });
  });

  testWidgets('el monstruo de la máquina pasa a ser el dibujo del niño', (tester) async {
    final carpeta = Directory.systemTemp.createTempSync('dibujos');
    addTearDown(() => carpeta.deleteSync(recursive: true));
    final fichero = File('${carpeta.path}/fugas.png');
    await tester.runAsync(() async {
      final foto = _fotoDePapel();
      final lista = <ui.Image>[];
      ui.decodeImageFromPixels(foto.rgba, foto.ancho, foto.alto, ui.PixelFormat.rgba8888, lista.add);
      while (lista.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fichero.writeAsBytesSync((await lista.first.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List());
    });
    dibujosMonstruos.rutas.value = const {};
    addTearDown(() => dibujosMonstruos.rutas.value = const {});
    await tester.pumpWidget(const MaterialApp(home: Center(child: MonstruoMaquina(familia: FamiliaMonstruo.fugas))));
    expect(find.byKey(const ValueKey('dibujo-monstruo')), findsNothing);
    dibujosMonstruos.rutas.value = {'fugas': fichero.path};
    await tester.pump();
    expect(find.byKey(const ValueKey('dibujo-monstruo')), findsOneWidget);
    // Otra familia no cambia.
    await tester.pumpWidget(const MaterialApp(home: Center(child: MonstruoMaquina(familia: FamiliaMonstruo.polillas))));
    expect(find.byKey(const ValueKey('dibujo-monstruo')), findsNothing);
  });
}
