import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:solera_viticultura/datos/base_datos.dart';

void main() {
  sqfliteFfiInit();

  late Database baseDatos;

  setUp(() async {
    baseDatos = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1, onCreate: (db, _) => crearEsquemaCompleto(db)));
  });

  tearDown(() => baseDatos.close());

  test('todas las tablas de registros existen en el esquema', () async {
    for (final tabla in tablasConRegistrosViticultura) {
      await baseDatos.rawQuery('SELECT 1 FROM $tabla LIMIT 1');
    }
  });

  test('recién creada está vacía; con un registro, ya no', () async {
    expect(await baseDatosSinRegistros(baseDatos), isTrue);
    await baseDatos.insert('vinedos',
        {'nombre': 'Prueba', 'fecha_creacion_ms': 0});
    expect(await baseDatosSinRegistros(baseDatos), isFalse);
  });
}
