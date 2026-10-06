// BD sqflite en memoria con el esquema completo, para tests. Cada llamada
// abre una BD nueva (sin estado compartido entre tests).

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';

Future<BaseDatosSoleraZunbeltz> abrirBdEnMemoria() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 8,
      // BD nueva por test: sin esto, todas las llamadas comparten la
      // misma BD en memoria y el estado se filtra entre tests.
      singleInstance: false,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async {
        await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV7(d);
        await BaseDatosSoleraZunbeltz.aplicarMigracionV8(d);
      },
    ),
  );
  return BaseDatosSoleraZunbeltz.paraTests(db);
}
