import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/utiles/web_sin_conexion.dart';

void main() {
  group('ficheroEntraEnPrecache', () {
    test('guarda la app, sus recursos y el motor general de CanvasKit', () {
      for (final ruta in [
        'index.html',
        'main.dart.js',
        'flutter_bootstrap.js',
        'manifest.json',
        'sqlite3.wasm',
        'sqflite_sw.js',
        'assets/AssetManifest.bin',
        'assets/fonts/MaterialIcons-Regular.otf',
        'icons/Icon-192.png',
        'canvaskit/canvaskit.js',
        'canvaskit/canvaskit.wasm',
      ]) {
        expect(ficheroEntraEnPrecache(ruta), isTrue, reason: ruta);
      }
    });

    test('deja fuera los otros motores, símbolos y el propio service worker',
        () {
      for (final ruta in [
        'canvaskit/chromium/canvaskit.wasm',
        'canvaskit/skwasm.wasm',
        'canvaskit/canvaskit.js.symbols',
        'main.dart.js.map',
        'sw_zunbeltz.js',
        'flutter_service_worker.js',
        'version.json',
      ]) {
        expect(ficheroEntraEnPrecache(ruta), isFalse, reason: ruta);
      }
    });
  });

  test(
      'la versión cambia con un fichero guardado o con el motor, no con los símbolos',
      () {
    final base = {
      'main.dart.js': [1, 2, 3],
      'canvaskit/chromium/canvaskit.wasm': [4],
      'canvaskit/canvaskit.js.symbols': [5],
    };
    final version = versionSinConexion(base);
    expect(versionSinConexion({...base}), version);
    expect(
        versionSinConexion({
          ...base,
          'main.dart.js': [1, 2, 4]
        }),
        isNot(version));
    expect(
        versionSinConexion({
          ...base,
          'canvaskit/chromium/canvaskit.wasm': [9]
        }),
        isNot(version));
    expect(
        versionSinConexion({
          ...base,
          'canvaskit/canvaskit.js.symbols': [9]
        }),
        version);
  });

  test('rellena la plantilla real del service worker', () {
    final plantilla = File('web/sw_zunbeltz.js').readAsStringSync();
    final relleno = rellenarServiceWorker(plantilla, 'abc123',
        ficherosPrecache(['main.dart.js', 'index.html', 'version.json']));
    expect(relleno, contains("const VERSION = 'abc123';"));
    expect(relleno,
        contains("const FICHEROS = [\n  'index.html',\n  'main.dart.js',\n];"));
    expect(relleno, isNot(contains(marcaVersionSinConexion)));
    expect(
        () => rellenarServiceWorker(relleno, 'x', const []), throwsStateError);
  });

  test('el arranque de Flutter no registra su service worker', () {
    final arranque = File('web/flutter_bootstrap.js').readAsStringSync();
    expect(arranque, contains('_flutter.loader.load()'));
    expect(arranque, isNot(contains('serviceWorkerSettings:')));
  });
}
