// Utilidades de los tests de contrato de la base de datos.
//
// Este fichero es idéntico en las seis apps Larrea (agro y las cinco
// verticales `solera-*`). Es a propósito: fija el contrato común que la
// futura `BaseDatosSolera` de `nuevo_ser_core` tendrá que cumplir. Cuando
// exista esa clase, este soporte puede subir al core junto a ella.
//
// Cómo se prueba sin tocar `lib/`: las apps abren la BD con
// `openDatabase(ruta)` usando la fábrica global de sqflite y calculan la
// ruta con `getApplicationDocumentsDirectory()` (path_provider). En el test:
//   * la fábrica global pasa a ser `databaseFactoryFfi` (sqlite de escritorio);
//   * el canal de path_provider se simula y devuelve un directorio temporal
//     nuevo en cada test, así que cada test arranca con la BD vacía.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path_lib;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Canal por el que path_provider pregunta las carpetas a la plataforma.
const MethodChannel canalPathProvider = MethodChannel(
  'plugins.flutter.io/path_provider',
);

bool _fabricaFfiConfigurada = false;

/// Directorio temporal que hace de «documentos de la app» durante un test.
class EntornoBaseDatosTemporal {
  late Directory directorio;

  /// Llamar en `setUp`. Crea el directorio y redirige path_provider y la
  /// fábrica global de sqflite a él.
  Future<void> preparar() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (!_fabricaFfiConfigurada) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _fabricaFfiConfigurada = true;
    }
    directorio = await Directory.systemTemp.createTemp('contrato_bd_');
    await databaseFactoryFfi.setDatabasesPath(directorio.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          canalPathProvider,
          (llamada) async => directorio.path,
        );
  }

  /// Llamar en `tearDown`, después de cerrar la BD de la app.
  Future<void> limpiar() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalPathProvider, null);
    if (await directorio.exists()) await directorio.delete(recursive: true);
  }

  String ruta(String nombreFichero) =>
      path_lib.join(directorio.path, nombreFichero);
}

/// Un paso del historial de migraciones tal como lo describe el código de
/// `_aplicarMigraciones`: tablas que aparecen y columnas que se añaden.
class CambioEsquema {
  final List<String> tablasNuevas;
  final Map<String, List<String>> columnasNuevas;

  const CambioEsquema({
    this.tablasNuevas = const [],
    this.columnasNuevas = const {},
  });
}

/// Nombre → columnas de cada tabla de usuario de [baseDatos].
Future<Map<String, Set<String>>> leerColumnasPorTabla(
  Database baseDatos,
) async {
  final detalle = await leerDetalleColumnasPorTabla(baseDatos);
  return {
    for (final entrada in detalle.entries)
      entrada.key: entrada.value.keys.toSet(),
  };
}

/// Nombre de tabla → (columna → «tipo|notnull|default») para comparar dos
/// esquemas sin depender del orden de las columnas (un ALTER TABLE ADD
/// COLUMN las deja al final; el esquema nuevo, donde toque).
Future<Map<String, Map<String, String>>> leerDetalleColumnasPorTabla(
  Database baseDatos,
) async {
  final tablas = await baseDatos.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
  );
  final resultado = <String, Map<String, String>>{};
  for (final fila in tablas) {
    final nombreTabla = fila['name'] as String;
    final columnas = await baseDatos.rawQuery(
      'PRAGMA table_info($nombreTabla)',
    );
    resultado[nombreTabla] = {
      for (final columna in columnas)
        columna['name'] as String:
            '${(columna['type'] as String).toUpperCase()}|'
            '${columna['notnull']}|${columna['dflt_value']}|'
            'pk${columna['pk']}',
    };
  }
  return resultado;
}

/// Índices creados a mano (los automáticos de SQLite se excluyen).
Future<Set<String>> leerNombresIndices(Database baseDatos) async {
  final filas = await baseDatos.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'index' "
    "AND name NOT LIKE 'sqlite_%'",
  );
  return filas.map((fila) => fila['name'] as String).toSet();
}

/// Columnas por tabla que resultan de ejecutar [sentenciasEsquemaV1] en una
/// BD en memoria. Así el esquema v1 se escribe una sola vez (como SQL) y las
/// columnas se deducen de él.
Future<Map<String, Set<String>>> columnasDeEsquemaV1(
  List<String> sentenciasEsquemaV1,
) async {
  sqfliteFfiInit();
  final baseDatosMemoria = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(singleInstance: false),
  );
  try {
    for (final sentencia in sentenciasEsquemaV1) {
      await baseDatosMemoria.execute(sentencia);
    }
    return await leerColumnasPorTabla(baseDatosMemoria);
  } finally {
    await baseDatosMemoria.close();
  }
}

/// Columnas esperadas en la versión [version] según v1 + historial.
Map<String, Set<String>> columnasDeclaradasEnVersion({
  required Map<String, Set<String>> columnasV1,
  required Map<int, CambioEsquema> historial,
  required Map<String, Set<String>> columnasActuales,
  required int version,
}) {
  final columnas = {
    for (final entrada in columnasV1.entries) entrada.key: {...entrada.value},
  };
  for (var paso = 2; paso <= version; paso++) {
    final cambio = historial[paso];
    if (cambio == null) continue;
    for (final tabla in cambio.tablasNuevas) {
      columnas[tabla] = _columnasAlCrearTabla(
        tabla: tabla,
        versionCreacion: paso,
        historial: historial,
        columnasActuales: columnasActuales,
      );
    }
    for (final entrada in cambio.columnasNuevas.entries) {
      columnas.putIfAbsent(entrada.key, () => {}).addAll(entrada.value);
    }
  }
  return columnas;
}

/// Columnas que tenía [tabla] al nacer: las actuales menos las que le
/// añadieron migraciones posteriores.
Set<String> _columnasAlCrearTabla({
  required String tabla,
  required int versionCreacion,
  required Map<int, CambioEsquema> historial,
  required Map<String, Set<String>> columnasActuales,
}) {
  final columnas = {...?columnasActuales[tabla]};
  for (final entrada in historial.entries) {
    if (entrada.key <= versionCreacion) continue;
    columnas.removeAll(entrada.value.columnasNuevas[tabla] ?? const []);
  }
  return columnas;
}

/// Crea en [ruta] una BD como la habría dejado la app en [version]:
/// esquema v1 literal + cada paso del historial hasta [version]. Las tablas
/// que nacen en pasos posteriores a v1 se crean sin tipos (solo nombres de
/// columna): basta para comprobar que la migración no las pisa ni pierde
/// filas, y evita copiar aquí todo el SQL de la app.
///
/// Inserta [filasPorTabla] (en orden) y cierra la BD.
Future<void> crearBaseDatosHistorica({
  required String ruta,
  required int version,
  required List<String> sentenciasEsquemaV1,
  required Map<int, CambioEsquema> historial,
  required Map<String, Set<String>> columnasActuales,
  required Map<String, Map<String, Object?>> filasPorTabla,
}) async {
  final baseDatosHistorica = await databaseFactoryFfi.openDatabase(
    ruta,
    options: OpenDatabaseOptions(
      version: version,
      singleInstance: false,
      onCreate: (baseDatos, _) async {
        for (final sentencia in sentenciasEsquemaV1) {
          await baseDatos.execute(sentencia);
        }
        for (var paso = 2; paso <= version; paso++) {
          final cambio = historial[paso];
          if (cambio == null) continue;
          for (final tabla in cambio.tablasNuevas) {
            final columnas = _columnasAlCrearTabla(
              tabla: tabla,
              versionCreacion: paso,
              historial: historial,
              columnasActuales: columnasActuales,
            )..remove('id');
            final definicion = [
              'id INTEGER PRIMARY KEY AUTOINCREMENT',
              ...columnas,
            ].join(', ');
            await baseDatos.execute('CREATE TABLE $tabla ($definicion)');
          }
          for (final entrada in cambio.columnasNuevas.entries) {
            for (final columna in entrada.value) {
              await baseDatos.execute(
                'ALTER TABLE ${entrada.key} ADD COLUMN $columna',
              );
            }
          }
        }
      },
    ),
  );
  for (final entrada in filasPorTabla.entries) {
    await baseDatosHistorica.insert(entrada.key, entrada.value);
  }
  await baseDatosHistorica.close();
}

/// Comprueba que cada fila de [filasPorTabla] sigue en [baseDatos] con sus
/// valores originales.
Future<void> comprobarFilasConservadas(
  Database baseDatos,
  Map<String, Map<String, Object?>> filasPorTabla,
) async {
  for (final entrada in filasPorTabla.entries) {
    final filas = await baseDatos.query(entrada.key);
    expect(filas, hasLength(1), reason: 'filas de ${entrada.key}');
    for (final valor in entrada.value.entries) {
      expect(
        filas.single[valor.key],
        valor.value,
        reason: '${entrada.key}.${valor.key}',
      );
    }
  }
}
