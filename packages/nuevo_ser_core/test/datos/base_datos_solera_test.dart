import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:path/path.dart' as path_lib;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// BD de prueba: v1 crea `ajustes`, v2 añade `notas`, v3 añade una columna.
class _BaseDatosPrueba extends BaseDatosSolera {
  _BaseDatosPrueba(this.directorio, {this.version = 3});

  final Directory directorio;
  final int version;
  final List<int> pasosEjecutados = [];

  @override
  String get nombreFichero => 'prueba.db';

  @override
  int get versionEsquema => version;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactoryFfi;

  @override
  Future<String> rutaFichero() async =>
      path_lib.join(directorio.path, nombreFichero);

  @override
  Future<void> crearEsquemaInicial(DatabaseExecutor db) async {
    await db.execute(
        'CREATE TABLE ajustes (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT)');
  }

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => {
        2: (db) async {
          pasosEjecutados.add(2);
          await db.execute(
              'CREATE TABLE notas (id INTEGER PRIMARY KEY, texto TEXT)');
        },
        3: (db) async {
          pasosEjecutados.add(3);
          await db.execute('ALTER TABLE notas ADD COLUMN fecha_ms INTEGER');
        },
      }..removeWhere((clave, _) => clave > version);
}

Future<List<String>> _columnas(Database db, String tabla) async =>
    (await db.rawQuery('PRAGMA table_info($tabla)'))
        .map((fila) => fila['name'] as String)
        .toList();

void main() {
  sqfliteFfiInit();
  late Directory directorio;

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('base_datos_solera_');
  });
  tearDown(() async {
    if (await directorio.exists()) await directorio.delete(recursive: true);
  });

  test('BD nueva: esquema inicial y todos los pasos', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), 3);
    expect(baseDatos.pasosEjecutados, [2, 3]);
    expect(await _columnas(db, 'notas'), contains('fecha_ms'));
    await baseDatos.cerrar();
  });

  test('BD en v2 solo ejecuta el paso 3 y conserva las filas', () async {
    final vieja = _BaseDatosPrueba(directorio, version: 2);
    final dbVieja = await vieja.basedatos;
    await dbVieja.insert('notas', {'id': 1, 'texto': 'primera'});
    await vieja.cerrar();

    final nueva = _BaseDatosPrueba(directorio);
    final db = await nueva.basedatos;
    expect(nueva.pasosEjecutados, [3]);
    expect((await db.query('notas')).single['texto'], 'primera');
    await nueva.cerrar();
  });

  test('accesos simultáneos comparten una sola conexión', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    final conexiones = await Future.wait(
        [baseDatos.basedatos, baseDatos.basedatos, baseDatos.basedatos]);
    expect(conexiones.toSet(), hasLength(1));
    expect(baseDatos.pasosEjecutados, [2, 3]);
    await baseDatos.cerrar();
  });

  test('cerrar libera la conexión y el siguiente acceso la reabre', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    final primera = await baseDatos.basedatos;
    await baseDatos.cerrar();
    expect(primera.isOpen, isFalse);
    final segunda = await baseDatos.basedatos;
    expect(segunda.isOpen, isTrue);
    await baseDatos.cerrar();
  });

  test('las claves foráneas están activadas', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    final db = await baseDatos.basedatos;
    final fila = await db.rawQuery('PRAGMA foreign_keys');
    expect(fila.single.values.single, 1);
    await baseDatos.cerrar();
  });

  test('guardarFilaUnica inserta la primera vez y luego actualiza', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    final idPrimero =
        await baseDatos.guardarFilaUnica('ajustes', {'id': 99, 'nombre': 'a'});
    final idSegundo =
        await baseDatos.guardarFilaUnica('ajustes', {'nombre': 'b'});
    expect(idSegundo, idPrimero);
    final filas = await (await baseDatos.basedatos).query('ajustes');
    expect(filas.single['nombre'], 'b');
    await baseDatos.cerrar();
  });

  test('guardados simultáneos de la fila única no la duplican', () async {
    final baseDatos = _BaseDatosPrueba(directorio);
    await Future.wait([
      for (var indice = 0; indice < 5; indice++)
        baseDatos.guardarFilaUnica('ajustes', {'nombre': 'n$indice'}),
    ]);
    final filas = await (await baseDatos.basedatos).query('ajustes');
    expect(filas, hasLength(1));
    await baseDatos.cerrar();
  });

  test('un paso que falta se detecta al abrir', () async {
    final baseDatos = _BaseDatosSinPaso(directorio);
    await expectLater(baseDatos.basedatos, throwsStateError);
  });
}

class _BaseDatosSinPaso extends _BaseDatosPrueba {
  _BaseDatosSinPaso(super.directorio);

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion =>
      {2: (db) async {}}; // falta el 3
}
