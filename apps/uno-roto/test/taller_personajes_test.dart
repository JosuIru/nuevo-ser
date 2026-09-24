import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/dibujos_taller.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/catalogo_escenas.dart';
import 'package:uno_roto/dominio/personajes_taller.dart';
import 'package:uno_roto/dominio/plano_escena.dart';
import 'package:uno_roto/dominio/voz_personaje.dart';
import 'package:uno_roto/vista/personajes/retratos.dart';
import 'package:uno_roto/vista/pestana_personajes.dart';

/// La primera escena en la que habla [voz].
String _flagDeUnaEscenaCon(VozPersonaje voz) => CatalogoEscenas.todas
    .firstWhere((escena) => escena.planos.any((plano) => plano is PlanoDialogo && plano.voz == voz))
    .flagDeSalida;

Future<String> _pngDePrueba(Directory carpeta) async {
  final fichero = File('${carpeta.path}/dibujo.png');
  final pixeles = Uint8List(4 * 4 * 4)..fillRange(0, 64, 200);
  final lista = <ui.Image>[];
  ui.decodeImageFromPixels(pixeles, 4, 4, ui.PixelFormat.rgba8888, lista.add);
  while (lista.isEmpty) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fichero.writeAsBytesSync((await lista.first.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List());
  return fichero.path;
}

void main() {
  test('sin escenas vistas no se conoce a nadie', () {
    expect(personajesConocidos(const {}), isEmpty);
  });

  test('se conoce a quien ha hablado en una escena ya vista', () {
    final conocidos = personajesConocidos({_flagDeUnaEscenaCon(VozPersonaje.sora)});
    expect(conocidos, contains('sora'));
    // Los Fragmentos no son personajes del taller.
    expect(conocidos.every((id) => personajesDelTaller.any((p) => p.id == id)), isTrue);
  });

  test('todos los personajes del taller hablan en alguna escena', () {
    final todos = personajesConocidos({
      for (final escena in CatalogoEscenas.todas) escena.flagDeSalida,
    });
    for (final personaje in personajesDelTaller) {
      expect(todos, contains(personaje.id), reason: personaje.id);
    }
  });

  testWidgets('el retrato pasa a ser el dibujo del niño', (tester) async {
    final carpeta = Directory.systemTemp.createTempSync('dibujos');
    addTearDown(() => carpeta.deleteSync(recursive: true));
    final ruta = (await tester.runAsync(() => _pngDePrueba(carpeta)))!;
    addTearDown(() => dibujosPersonajes.rutas.value = const {});
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(width: 100, height: 120, child: RetratoPersonaje(voz: VozPersonaje.rexan))));
    expect(find.byKey(const ValueKey('dibujo-personaje')), findsNothing);
    dibujosPersonajes.rutas.value = {'rexan': ruta};
    await tester.pump();
    expect(find.byKey(const ValueKey('dibujo-personaje')), findsOneWidget);
  });

  testWidgets('la pestaña enseña a los conocidos con su botón y al resto como ???', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioProgreso();
    await tester.runAsync(() => repositorio.activarFlagNarrativo(_flagDeUnaEscenaCon(VozPersonaje.sora)));
    final conocidos = personajesConocidos({_flagDeUnaEscenaCon(VozPersonaje.sora)});
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PestanaPersonajes(repositorio: repositorio))));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.text('Sora'), findsOneWidget);
    expect(find.byKey(const ValueKey('dibujar-sora')), findsOneWidget);
    expect(find.text('???'), findsNWidgets(personajesDelTaller.length - conocidos.length));
  });
}
