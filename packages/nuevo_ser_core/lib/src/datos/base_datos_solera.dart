import 'dart:async';

import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Paso de migración de la versión `n - 1` a la `n`.
typedef PasoMigracionSolera = Future<void> Function(Database db);

/// Plantilla común de la base de datos local de las apps Larrea (agro y
/// verticales `solera-*`). Resuelve lo que antes se copiaba a mano en cada
/// `lib/datos/base_datos.dart` (deuda R5 de la auditoría 2026-05-12):
///
/// * apertura perezosa **con cerrojo**: dos accesos simultáneos comparten
///   la misma apertura en vez de abrir dos conexiones;
/// * claves foráneas activadas en cada conexión;
/// * migraciones aditivas por pasos numerados: una BD nueva ejecuta el
///   esquema inicial y luego **todos** los pasos; una BD en la versión `n`
///   ejecuta solo los pasos `n + 1 … versionEsquema`;
/// * guardado de tablas de una sola fila (ajustes, configuración fiscal)
///   dentro de una transacción.
///
/// Cada app aporta el nombre del fichero (el de siempre: forma parte de las
/// copias de seguridad), el esquema inicial, los pasos y la fábrica de
/// sqflite. El core no depende del plugin sqflite: la app pasa
/// `databaseFactory` de `package:sqflite`, que en los tests se sustituye por
/// la de `sqflite_common_ffi`.
///
/// **Convención de la suite**: las migraciones nunca son destructivas. Un
/// cambio de esquema es un paso nuevo; nunca se edita el esquema inicial ni
/// un paso ya publicado.
abstract class BaseDatosSolera {
  /// Nombre del fichero dentro de la carpeta de documentos de la app.
  String get nombreFichero;

  /// Versión que se declara a `openDatabase`. Debe coincidir con el número
  /// del último paso de [pasosMigracion] (o 1 si no hay pasos).
  int get versionEsquema;

  /// Fábrica de sqflite. Se lee en el momento de abrir, no al construir.
  DatabaseFactory get fabricaBaseDatos;

  /// Esquema de la versión 1, tal y como se publicó.
  Future<void> crearEsquemaInicial(Database db);

  /// Pasos de migración: la clave es la versión a la que lleva el paso.
  /// Deben ser consecutivos desde 2 hasta [versionEsquema].
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  /// Ruta completa del fichero. Se puede sobrescribir (tests, escritorio).
  Future<String> rutaFichero() async {
    final directorio = await getApplicationDocumentsDirectory();
    return path_lib.join(directorio.path, nombreFichero);
  }

  Database? _baseDatosAbierta;
  Future<Database>? _aperturaEnCurso;

  /// La conexión, abierta (y creada o migrada) la primera vez que se pide.
  Future<Database> get basedatos {
    final abierta = _baseDatosAbierta;
    if (abierta != null) return Future.value(abierta);
    return _aperturaEnCurso ??= _abrir();
  }

  Future<Database> _abrir() async {
    try {
      _comprobarPasos();
      // Primero la ruta y después la fábrica, como hacían las apps: en los
      // tests de pantallas sin path_provider falla antes la ruta, y las
      // pantallas ya capturan ese error.
      final ruta = await rutaFichero();
      final baseDatos = await fabricaBaseDatos.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: versionEsquema,
          onConfigure: (db) async {
            // SQLite desactiva las FK en cada conexión: sin esto no se
            // respetan las cascadas.
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onCreate: (db, version) async {
            await crearEsquemaInicial(db);
            await _aplicarPasos(db, desde: 1, hasta: version);
          },
          onUpgrade: (db, anterior, actual) =>
              _aplicarPasos(db, desde: anterior, hasta: actual),
        ),
      );
      _baseDatosAbierta = baseDatos;
      return baseDatos;
    } finally {
      _aperturaEnCurso = null;
    }
  }

  Future<void> _aplicarPasos(
    Database db, {
    required int desde,
    required int hasta,
  }) async {
    for (var version = desde + 1; version <= hasta; version++) {
      await pasosMigracion[version]!(db);
    }
  }

  void _comprobarPasos() {
    for (var version = 2; version <= versionEsquema; version++) {
      if (!pasosMigracion.containsKey(version)) {
        throw StateError(
            '$nombreFichero: falta el paso de migración a la v$version');
      }
    }
    final sobrantes = pasosMigracion.keys.where((v) => v > versionEsquema);
    if (sobrantes.isNotEmpty) {
      throw StateError('$nombreFichero: hay pasos por encima de la versión '
          '$versionEsquema: ${sobrantes.join(', ')}');
    }
  }

  /// Guarda la única fila de [tabla] (la inserta si no hay ninguna o
  /// actualiza la primera) en una transacción. Devuelve su `id`. La clave
  /// `id` de [valores] se ignora.
  Future<int> guardarFilaUnica(
    String tabla,
    Map<String, Object?> valores,
  ) async {
    final db = await basedatos;
    final sinId = Map<String, Object?>.of(valores)..remove('id');
    return db.transaction((transaccion) async {
      final existente =
          await transaccion.query(tabla, columns: ['id'], limit: 1);
      if (existente.isEmpty) return transaccion.insert(tabla, sinId);
      final id = existente.first['id'] as int;
      await transaccion.update(tabla, sinId,
          where: 'id = ?', whereArgs: [id]);
      return id;
    });
  }

  /// Cierra la conexión; el siguiente acceso la reabre. Lo usan los tests y
  /// la copia de seguridad al restaurar.
  Future<void> cerrar() async {
    final pendiente = _aperturaEnCurso;
    if (pendiente != null) await pendiente;
    await _baseDatosAbierta?.close();
    _baseDatosAbierta = null;
  }
}
