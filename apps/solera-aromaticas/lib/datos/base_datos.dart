import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/titular.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosAromaticas = 'solera_aromaticas.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaAromaticas = 1;

/// Base de datos local de Larrea Aromáticas. La apertura, el cerrojo, las FK y las
/// migraciones las pone BaseDatosSolera (core). **Migraciones aditivas**:
/// un cambio de esquema es un paso nuevo; nunca se edita lo publicado.
class BaseDatosSoleraAromaticas extends BaseDatosSolera {
  static final BaseDatosSoleraAromaticas instancia = BaseDatosSoleraAromaticas._interno();
  factory BaseDatosSoleraAromaticas() => instancia;
  BaseDatosSoleraAromaticas._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosAromaticas;

  @override
  int get versionEsquema => versionEsquemaAromaticas;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    await db.execute('''
      CREATE TABLE titulares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        nif TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  Future<Titular> obtenerTitular() async {
    final db = await basedatos;
    final filas = await db.query('titulares', limit: 1);
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }
}
