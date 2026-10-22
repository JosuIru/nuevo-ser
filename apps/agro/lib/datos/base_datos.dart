import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/cosecha.dart';
import '../modelos/finca.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/planta.dart';
import '../modelos/tercero.dart';
import '../modelos/titular.dart';
import '../modelos/track.dart';
import '../modelos/tratamiento.dart';

/// Acceso a la base de datos local de la app Agro. Singleton con
/// inicialización perezosa: la primera lectura crea/migra la BD.
///
/// **Convención**: las migraciones nunca son destructivas. Cualquier
/// agricultor en campo lleva años de cosechas registradas — perder un
/// dato por una actualización es inaceptable. Cada subida de versión
/// es un paso aditivo en `_aplicarMigraciones`. Ese es el principio
/// que las apps fósiles/naturaleza ya siguen y este monorepo respeta.
/// Fichero de la BD dentro de la carpeta de documentos.
const String nombreFicheroBaseDatosAgro = 'agro.db';

/// Versión del esquema (`version:` de openDatabase). Subirla cada vez
/// que se añada un paso en `_aplicarMigraciones`. Nunca destructivo.
/// v7 añade la tabla `facturas` que usa pantalla_facturas — antes estaba
/// declarada en _aplicarMigraciones pero la versión seguía en 6, así que
/// la tabla no llegaba a crearse y la pantalla de facturas fallaba en
/// silencio.
const int versionEsquemaAgro = 7;

class BaseDatosAgro {
  static final BaseDatosAgro instancia = BaseDatosAgro._interno();
  factory BaseDatosAgro() => instancia;
  BaseDatosAgro._interno();

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, nombreFicheroBaseDatosAgro);
    _basedatos = await openDatabase(
      ruta,
      // Esquema con migración escalonada (ver `versionEsquemaAgro`).
      version: versionEsquemaAgro,
      onConfigure: (db) async {
        // ON DELETE CASCADE en eventos hijos requiere FKs activas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _crearEsquemaInicial(db);
        await _aplicarMigraciones(db, desde: 1, hasta: version);
      },
      onUpgrade: (db, anterior, actual) async {
        await _aplicarMigraciones(db, desde: anterior, hasta: actual);
      },
    );
    return _basedatos!;
  }

  // ─── Fincas ─────────────────────────────────────────────

  Future<int> guardarFinca(Finca finca) async {
    final db = await basedatos;
    return db.insert('fincas', finca.toMap()..remove('id'));
  }

  Future<void> actualizarFinca(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('fincas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Finca>> listarFincas() async {
    final db = await basedatos;
    final filas = await db.query('fincas', orderBy: 'nombre ASC');
    return filas.map(Finca.fromMap).toList();
  }

  Future<Finca?> obtenerFinca(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'fincas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Finca.fromMap(filas.first);
  }

  /// Borra una finca y desasocia sus plantas (las deja como puntos
  /// sueltos). Las plantas no se borran — su historia es valiosa
  /// independientemente de que la finca exista o no como agrupación.
  Future<void> borrarFinca(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.update(
        'plantas',
        {'finca_id': null},
        where: 'finca_id = ?',
        whereArgs: [id],
      );
      await txn.delete('fincas', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Plantas ────────────────────────────────────────────

  Future<int> guardarPlanta(Planta planta) async {
    final db = await basedatos;
    return db.insert('plantas', planta.toMap()..remove('id'));
  }

  Future<void> actualizarPlanta(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('plantas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  /// Lista plantas filtrables por finca (`fincaId == null` aquí
  /// significa **todas las plantas**, sin filtro). Para listar sólo
  /// puntos sueltos (sin finca) usar `listarPuntosSueltos`.
  Future<List<Planta>> listarPlantas({int? fincaId}) async {
    final db = await basedatos;
    final filas = fincaId == null
        ? await db.query('plantas', orderBy: 'fecha_creacion_ms DESC')
        : await db.query(
            'plantas',
            where: 'finca_id = ?',
            whereArgs: [fincaId],
            orderBy: 'fecha_creacion_ms DESC',
          );
    return filas.map(Planta.fromMap).toList();
  }

  Future<List<Planta>> listarPuntosSueltos() async {
    final db = await basedatos;
    final filas = await db.query(
      'plantas',
      where: 'finca_id IS NULL',
      orderBy: 'fecha_creacion_ms DESC',
    );
    return filas.map(Planta.fromMap).toList();
  }

  Future<Planta?> obtenerPlanta(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'plantas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Planta.fromMap(filas.first);
  }

  Future<void> borrarPlanta(int id) async {
    final db = await basedatos;
    // Las FK ON DELETE CASCADE limpian eventos hijos automáticamente.
    await db.delete('plantas', where: 'id = ?', whereArgs: [id]);
  }

  /// Cuenta de plantas por finca (incluye `null` para puntos sueltos)
  /// agrupado por cultivo. Útil para resúmenes en pantalla principal.
  Future<Map<String, int>> contarPlantasPorCultivo({int? fincaId}) async {
    final db = await basedatos;
    final where = fincaId == null ? null : 'finca_id = ?';
    final whereArgs = fincaId == null ? null : [fincaId];
    final filas = await db.rawQuery(
      'SELECT cultivo_id, COUNT(*) AS n FROM plantas'
      '${where != null ? ' WHERE $where' : ''}'
      ' GROUP BY cultivo_id',
      whereArgs,
    );
    return {
      for (final f in filas) (f['cultivo_id'] as String): (f['n'] as int),
    };
  }

  // ─── Cosechas ───────────────────────────────────────────

  Future<int> guardarCosecha(Cosecha cosecha) async {
    final db = await basedatos;
    return db.insert('cosechas', cosecha.toMap()..remove('id'));
  }

  Future<void> actualizarCosecha(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('cosechas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Cosecha?> obtenerCosecha(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'cosechas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Cosecha.fromMap(filas.first);
  }

  Future<List<Cosecha>> listarCosechasDePlanta(int plantaId) async {
    final db = await basedatos;
    final filas = await db.query(
      'cosechas',
      where: 'planta_id = ?',
      whereArgs: [plantaId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(Cosecha.fromMap).toList();
  }

  Future<void> borrarCosecha(int id) async {
    final db = await basedatos;
    await db.delete('cosechas', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Observaciones ──────────────────────────────────────

  Future<int> guardarObservacion(Observacion observacion) async {
    final db = await basedatos;
    return db.insert('observaciones', observacion.toMap()..remove('id'));
  }

  Future<void> actualizarObservacion(
    int id,
    Map<String, Object?> cambios,
  ) async {
    final db = await basedatos;
    await db.update('observaciones', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Observacion?> obtenerObservacion(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'observaciones',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Observacion.fromMap(filas.first);
  }

  Future<List<Observacion>> listarObservacionesDePlanta(int plantaId) async {
    final db = await basedatos;
    final filas = await db.query(
      'observaciones',
      where: 'planta_id = ?',
      whereArgs: [plantaId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(Observacion.fromMap).toList();
  }

  Future<void> borrarObservacion(int id) async {
    final db = await basedatos;
    await db.delete('observaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Incidencias ────────────────────────────────────────

  Future<int> guardarIncidencia(Incidencia incidencia) async {
    final db = await basedatos;
    return db.insert('incidencias', incidencia.toMap()..remove('id'));
  }

  Future<void> actualizarIncidencia(
    int id,
    Map<String, Object?> cambios,
  ) async {
    final db = await basedatos;
    await db.update('incidencias', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Incidencia?> obtenerIncidencia(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'incidencias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Incidencia.fromMap(filas.first);
  }

  Future<List<Incidencia>> listarIncidenciasDePlanta(int plantaId) async {
    final db = await basedatos;
    final filas = await db.query(
      'incidencias',
      where: 'planta_id = ?',
      whereArgs: [plantaId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(Incidencia.fromMap).toList();
  }

  Future<List<Incidencia>> listarIncidenciasAbiertas({int? fincaId}) async {
    final db = await basedatos;
    const base =
        'SELECT i.* FROM incidencias i INNER JOIN plantas p ON i.planta_id = p.id WHERE i.resuelta = 0';
    final filas = fincaId == null
        ? await db.rawQuery('$base ORDER BY i.fecha_ms DESC')
        : await db.rawQuery(
            '$base AND p.finca_id = ? ORDER BY i.fecha_ms DESC',
            [fincaId],
          );
    return filas.map(Incidencia.fromMap).toList();
  }

  Future<void> borrarIncidencia(int id) async {
    final db = await basedatos;
    await db.delete('incidencias', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Tratamientos ──────────────────────────────────────

  Future<int> guardarTratamiento(Tratamiento tratamiento) async {
    final db = await basedatos;
    return db.insert('tratamientos', tratamiento.toMap()..remove('id'));
  }

  Future<void> actualizarTratamiento(
    int id,
    Map<String, Object?> cambios,
  ) async {
    final db = await basedatos;
    await db.update('tratamientos', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Tratamiento?> obtenerTratamiento(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'tratamientos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Tratamiento.fromMap(filas.first);
  }

  Future<List<Tratamiento>> listarTratamientosDePlanta(int plantaId) async {
    final db = await basedatos;
    final filas = await db.query(
      'tratamientos',
      where: 'planta_id = ?',
      whereArgs: [plantaId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(Tratamiento.fromMap).toList();
  }

  Future<void> borrarTratamiento(int id) async {
    final db = await basedatos;
    await db.delete('tratamientos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tratamiento>> listarTratamientosPorFincaYRango({
    required int? fincaId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = fincaId == null
        ? await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN plantas p ON t.planta_id = p.id '
            'WHERE p.finca_id IS NULL AND t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN plantas p ON t.planta_id = p.id '
            'WHERE p.finca_id = ? AND t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [fincaId, desdeMs, hastaMs],
          );
    return filas.map(Tratamiento.fromMap).toList();
  }

  // ─── Titular de la explotación (v4) ─────────────────────

  /// Devuelve el titular único, o un `Titular()` vacío si aún no se ha
  /// configurado. La pantalla de configuración usa el resultado para
  /// distinguir UI de alta vs UI de edición.
  Future<Titular> obtenerTitular() async {
    final db = await basedatos;
    final filas = await db.query('titulares', limit: 1);
    if (filas.isEmpty) return Titular();
    return Titular.fromMap(filas.first);
  }

  /// Upsert single-row del titular. Si ya existe, actualiza; si no,
  /// inserta. La tabla nunca debe tener más de una fila en v1.
  ///
  /// Envuelto en `txn` para que dos llamadas concurrentes no inserten
  /// dos filas (race detectada en audit: SELECT + INSERT no atómicos
  /// dejaban ver `actual.id == null` a ambas si llegaban a la vez).
  Future<void> guardarTitular(Titular titular) async {
    final db = await basedatos;
    final mapa = titular.toMap()..remove('id');
    await db.transaction((txn) async {
      final filas = await txn.query('titulares', limit: 1);
      if (filas.isNotEmpty) {
        final id = filas.first['id'] as int;
        await txn.update('titulares', mapa, where: 'id = ?', whereArgs: [id]);
      } else {
        await txn.insert('titulares', mapa);
      }
    });
  }

  // ─── Tracks de inspección (v3) ──────────────────────────

  Future<int> guardarTrack(Track track, List<TrackPunto> puntos) async {
    final db = await basedatos;
    return db.transaction<int>((txn) async {
      final id = await txn.insert('tracks', track.toMap()..remove('id'));
      for (final p in puntos) {
        await txn.insert('track_puntos', p.toMap(idTrack: id)..remove('id'));
      }
      return id;
    });
  }

  Future<List<Track>> listarTracks() async {
    final db = await basedatos;
    final filas = await db.query('tracks', orderBy: 'fecha_ms DESC');
    return filas.map(Track.fromMap).toList();
  }

  Future<List<TrackPunto>> obtenerPuntosTrack(int idTrack) async {
    final db = await basedatos;
    final filas = await db.query(
      'track_puntos',
      where: 'track_id = ?',
      whereArgs: [idTrack],
      orderBy: 'fecha_ms ASC',
    );
    return filas.map(TrackPunto.fromMap).toList();
  }

  Future<void> borrarTrack(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.delete('track_puntos', where: 'track_id = ?', whereArgs: [id]);
      await txn.delete('tracks', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Buffer de grabación incremental (sobrevive a crash/kill OS).

  Future<void> bufferarPuntoTrack({
    required int inicioMs,
    required TrackPunto punto,
  }) async {
    final db = await basedatos;
    await db.insert('track_grabacion_buffer', {
      'inicio_ms': inicioMs,
      'fecha_ms': punto.fechaMs,
      'latitud': punto.latitud,
      'longitud': punto.longitud,
      'altitud': punto.altitud,
      'precision': punto.precision,
    });
  }

  Future<List<TrackPunto>> recuperarBufferTrack({int? inicioMs}) async {
    final db = await basedatos;
    final filas = await db.query(
      'track_grabacion_buffer',
      where: inicioMs != null ? 'inicio_ms = ?' : null,
      whereArgs: inicioMs != null ? [inicioMs] : null,
      orderBy: 'fecha_ms ASC',
    );
    return filas
        .map(
          (f) => TrackPunto(
            fechaMs: f['fecha_ms'] as int,
            latitud: f['latitud'] as double,
            longitud: f['longitud'] as double,
            altitud: f['altitud'] as double?,
            precision: f['precision'] as double?,
          ),
        )
        .toList();
  }

  Future<List<int>> sesionesPendientesEnBuffer() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT DISTINCT inicio_ms FROM track_grabacion_buffer ORDER BY inicio_ms ASC',
    );
    return filas.map((f) => f['inicio_ms'] as int).toList();
  }

  Future<void> vaciarBufferTrack({int? inicioMs}) async {
    final db = await basedatos;
    await db.delete(
      'track_grabacion_buffer',
      where: inicioMs != null ? 'inicio_ms = ?' : null,
      whereArgs: inicioMs != null ? [inicioMs] : null,
    );
  }

  // ─── Terceros (clientes y proveedores) ──────────────────

  Future<int> guardarTercero(Tercero t) async {
    final db = await basedatos;
    return db.insert('terceros', t.toMap()..remove('id'));
  }

  Future<void> actualizarTercero(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('terceros', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tercero>> listarTerceros({String? tipo}) async {
    final db = await basedatos;
    final filas = tipo == null
        ? await db.query('terceros', orderBy: 'nombre ASC')
        : await db.rawQuery(
            'SELECT * FROM terceros WHERE tipo = ? OR tipo = ? ORDER BY nombre ASC',
            [tipo, 'ambos'],
          );
    return filas.map(Tercero.fromMap).toList();
  }

  Future<Tercero?> obtenerTercero(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'terceros',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Tercero.fromMap(filas.first);
  }

  Future<Tercero?> obtenerTerceroPorNif(String nif) async {
    final db = await basedatos;
    final filas = await db.query(
      'terceros',
      where: 'nif = ?',
      whereArgs: [nif],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Tercero.fromMap(filas.first);
  }

  Future<void> borrarTercero(int id) async {
    final db = await basedatos;
    await db.delete('terceros', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Configuración fiscal (single-row) ──────────────────

  Future<ConfiguracionFiscal> obtenerConfiguracionFiscal() async {
    final db = await basedatos;
    final filas = await db.query('configuraciones_fiscales', limit: 1);
    if (filas.isEmpty) return ConfiguracionFiscal();
    return ConfiguracionFiscal.fromMap(filas.first);
  }

  Future<void> guardarConfiguracionFiscal(ConfiguracionFiscal cf) async {
    final db = await basedatos;
    final actual = await obtenerConfiguracionFiscal();
    final mapa = cf.toMap()..remove('id');
    if (actual.id != null) {
      await db.update(
        'configuraciones_fiscales',
        mapa,
        where: 'id = ?',
        whereArgs: [actual.id],
      );
    } else {
      await db.insert('configuraciones_fiscales', mapa);
    }
  }

  // ─── Apuntes de ingreso ─────────────────────────────────

  Future<int> guardarApunteIngreso(ApunteIngreso a) async {
    final db = await basedatos;
    return db.insert('apuntes_ingreso', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteIngreso(
    int id,
    Map<String, Object?> cambios,
  ) async {
    final db = await basedatos;
    await db.update(
      'apuntes_ingreso',
      cambios,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ApunteIngreso?> obtenerApunteIngreso(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_ingreso',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return ApunteIngreso.fromMap(filas.first);
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoPorRango({
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_ingreso',
      where: 'fecha_ms BETWEEN ? AND ?',
      whereArgs: [desdeMs, hastaMs],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteIngreso.fromMap).toList();
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoPorAno(int ano) async {
    final desdeMs = DateTime(ano, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(ano + 1, 1, 1).millisecondsSinceEpoch - 1;
    return listarApuntesIngresoPorRango(desdeMs: desdeMs, hastaMs: hastaMs);
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoDeTercero(
    int terceroId,
  ) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_ingreso',
      where: 'tercero_id = ?',
      whereArgs: [terceroId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteIngreso.fromMap).toList();
  }

  Future<void> borrarApunteIngreso(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_ingreso', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Apuntes de gasto ────────────────────────────────────

  Future<int> guardarApunteGasto(ApunteGasto a) async {
    final db = await basedatos;
    return db.insert('apuntes_gasto', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteGasto(
    int id,
    Map<String, Object?> cambios,
  ) async {
    final db = await basedatos;
    await db.update('apuntes_gasto', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<ApunteGasto?> obtenerApunteGasto(int id) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_gasto',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return ApunteGasto.fromMap(filas.first);
  }

  Future<List<ApunteGasto>> listarApuntesGastoPorRango({
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_gasto',
      where: 'fecha_ms BETWEEN ? AND ?',
      whereArgs: [desdeMs, hastaMs],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteGasto.fromMap).toList();
  }

  Future<List<ApunteGasto>> listarApuntesGastoPorAno(int ano) async {
    final desdeMs = DateTime(ano, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(ano + 1, 1, 1).millisecondsSinceEpoch - 1;
    return listarApuntesGastoPorRango(desdeMs: desdeMs, hastaMs: hastaMs);
  }

  Future<List<ApunteGasto>> listarApuntesGastoDeTercero(int terceroId) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_gasto',
      where: 'tercero_id = ?',
      whereArgs: [terceroId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteGasto.fromMap).toList();
  }

  Future<void> borrarApunteGasto(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_gasto', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cerrar() async {
    await _basedatos?.close();
    _basedatos = null;
  }
}

// ─── Esquema y migraciones ────────────────────────────────

Future<void> _crearEsquemaInicial(Database db) async {
  await db.execute('''
    CREATE TABLE fincas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 6249021,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE plantas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      finca_id INTEGER,
      cultivo_id TEXT NOT NULL,
      variedad TEXT NOT NULL DEFAULT '',
      latitud REAL NOT NULL,
      longitud REAL NOT NULL,
      precision_metros REAL,
      fecha_plantacion_ms INTEGER,
      patron TEXT NOT NULL DEFAULT '',
      etiqueta TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_plantas_finca ON plantas (finca_id)');
  await db.execute('CREATE INDEX idx_plantas_cultivo ON plantas (cultivo_id)');
  await db.execute(
    'CREATE INDEX idx_plantas_creacion ON plantas (fecha_creacion_ms DESC)',
  );

  await db.execute('''
    CREATE TABLE cosechas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planta_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      kilos REAL,
      unidades INTEGER,
      calidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_cosechas_planta_fecha ON cosechas (planta_id, fecha_ms DESC)',
  );

  await db.execute('''
    CREATE TABLE observaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planta_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      salud INTEGER,
      etiquetas_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_observaciones_planta_fecha ON observaciones (planta_id, fecha_ms DESC)',
  );

  await db.execute('''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planta_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      diagnostico TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_incidencias_planta_fecha ON incidencias (planta_id, fecha_ms DESC)',
  );
  await db.execute(
    'CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)',
  );

  await db.execute('''
    CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planta_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      producto TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      motivo TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      incidencia_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE,
      FOREIGN KEY (incidencia_id) REFERENCES incidencias(id) ON DELETE SET NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_tratamientos_planta_fecha ON tratamientos (planta_id, fecha_ms DESC)',
  );

  // v3 — tablas de tracks. Las metemos también en el esquema fresh
  // para que una instalación nueva las tenga sin pasar por la
  // migración v2→v3.
  await _crearTablasTracks(db);
  await _crearTablaBufferTracks(db);

  // v4 — Cuaderno de Explotación Digital MAPA: titular único +
  // SIGPAC y superficie en fincas para listado de parcelas oficial.
  await _crearTablaTitular(db);
  await _ampliarFincasSigpac(db);

  // v5 — Datos MAPA en tratamientos: número de registro
  // fitosanitario, NIF aplicador, superficie tratada en hectáreas.
  await _ampliarTratamientosMapa(db);
}

Future<void> _crearTablaTitular(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS titulares (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      numero_regepa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      nombre_asesor TEXT NOT NULL DEFAULT '',
      nif_asesor TEXT NOT NULL DEFAULT '',
      numero_registro_asesor TEXT NOT NULL DEFAULT '',
      nombre_aplicador TEXT NOT NULL DEFAULT '',
      nif_aplicador TEXT NOT NULL DEFAULT '',
      carnet_aplicador TEXT NOT NULL DEFAULT '',
      nivel_carnet_aplicador TEXT NOT NULL DEFAULT ''
    )
  ''');
}

Future<void> _ampliarFincasSigpac(Database db) async {
  // Columnas SIGPAC requeridas para el cuaderno MAPA. La spec oficial
  // identifica una parcela por la quíntupla provincia/municipio/
  // polígono/parcela/recinto. En v1 lo guardamos como free-text por
  // si el agricultor lo tiene en distintos formatos; en F4 con
  // backend validamos contra la BBDD pública del SIGPAC.
  for (final col in const [
    "ALTER TABLE fincas ADD COLUMN sigpac_provincia TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE fincas ADD COLUMN sigpac_municipio TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE fincas ADD COLUMN sigpac_poligono TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE fincas ADD COLUMN sigpac_parcela TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE fincas ADD COLUMN sigpac_recinto TEXT NOT NULL DEFAULT ''",
    'ALTER TABLE fincas ADD COLUMN superficie_hectareas REAL',
  ]) {
    await _ejecutarSiNoExiste(db, col);
  }
}

Future<void> _ampliarTratamientosMapa(Database db) async {
  for (final col in const [
    "ALTER TABLE tratamientos ADD COLUMN numero_registro_fitosanitario TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE tratamientos ADD COLUMN nif_aplicador TEXT NOT NULL DEFAULT ''",
    'ALTER TABLE tratamientos ADD COLUMN superficie_tratada_hectareas REAL',
  ]) {
    await _ejecutarSiNoExiste(db, col);
  }
}

/// Ejecuta un ALTER TABLE ADD COLUMN tolerando el "duplicate column
/// name" de SQLite. Necesario porque el esquema fresh ya invoca las
/// mismas funciones que la migración escalonada.
Future<void> _ejecutarSiNoExiste(Database db, String sql) async {
  try {
    await db.execute(sql);
  } catch (e) {
    final msg = e.toString().toLowerCase();
    if (!msg.contains('duplicate column name')) rethrow;
  }
}

Future<void> _crearTablasTracks(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      nombre TEXT,
      duracion_ms INTEGER,
      distancia_metros REAL
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS track_puntos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      track_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      latitud REAL NOT NULL,
      longitud REAL NOT NULL,
      altitud REAL,
      precision REAL,
      FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_track_puntos_track ON track_puntos (track_id, fecha_ms)',
  );
}

Future<void> _crearTablaBufferTracks(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS track_grabacion_buffer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      inicio_ms INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      latitud REAL NOT NULL,
      longitud REAL NOT NULL,
      altitud REAL,
      precision REAL
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_buffer_inicio ON track_grabacion_buffer (inicio_ms, fecha_ms)',
  );
}

/// Aplica las migraciones de esquema en orden, desde la versión [desde]
/// (excluida) hasta [hasta] (incluida). Cada paso es idempotente y
/// nunca destructivo.
Future<void> _aplicarMigraciones(
  Database db, {
  required int desde,
  required int hasta,
}) async {
  for (var v = desde + 1; v <= hasta; v++) {
    switch (v) {
      case 2:
        // v2 — Foto del propio árbol/planta (no de eventos).
        // Útil para identificar la planta al volver: foto del tronco
        // con etiqueta, foto del árbol completo con marco visual.
        await _ejecutarSiNoExiste(
          db,
          "ALTER TABLE plantas ADD COLUMN rutas_fotos_json TEXT NOT NULL DEFAULT '[]'",
        );
        break;
      case 3:
        // v3 — Tracks de inspección (recorridos GPS por la finca).
        // Patrón heredado de fósiles/naturaleza: tabla tracks
        // (cabecera) + track_puntos (lista de fixes) + buffer de
        // grabación incremental que sobrevive a crash/kill OS y se
        // consolida al arrancar.
        await _crearTablasTracks(db);
        await _crearTablaBufferTracks(db);
        break;
      case 4:
        // v4 — Cuaderno de Explotación MAPA (RD 1311/2012).
        // Titular único de la explotación + SIGPAC y superficie en
        // fincas. La spec del SIEX identifica parcela como
        // provincia/municipio/polígono/parcela/recinto.
        await _crearTablaTitular(db);
        await _ampliarFincasSigpac(db);
        break;
      case 5:
        // v5 — Datos MAPA por tratamiento: número de registro
        // fitosanitario (BBDD MAPA), NIF aplicador (puede ser distinto
        // del titular), superficie tratada en hectáreas (puede ser
        // parcial de la finca).
        await _ampliarTratamientosMapa(db);
        break;
      case 6:
        // v6 — Libro económico (F3.5). Añade 4 tablas: terceros
        // (clientes/proveedores con NIF para modelo 347),
        // configuraciones_fiscales (régimen IRPF + IVA del titular,
        // single-row), apuntes_ingreso (ventas + ayudas PAC) y
        // apuntes_gasto (con sinergia opcional al cuaderno MAPA
        // vía tratamiento_id). Migración aditiva — el cuaderno MAPA
        // y el resto del libro de explotación no se tocan.
        await _crearTablasContabilidadV6(db);
        break;
      case 7:
        // v7 — Facturas emitidas con numeración secuencial.
        await _crearTablaFacturasV7(db);
        break;
    }
  }
}

// ─── Migración v6: contabilidad ───────────────────────────

Future<void> _crearTablasContabilidadV6(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS terceros (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      tipo TEXT NOT NULL DEFAULT 'ambos',
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_terceros_nif ON terceros (nif)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_terceros_tipo ON terceros (tipo)',
  );

  await db.execute('''
    CREATE TABLE IF NOT EXISTS configuraciones_fiscales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      regimen_irpf TEXT NOT NULL DEFAULT 'sin_elegir',
      regimen_iva TEXT NOT NULL DEFAULT 'sin_elegir',
      ano_fiscal_activo INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS apuntes_ingreso (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      concepto TEXT NOT NULL DEFAULT '',
      tipo_ingreso TEXT NOT NULL DEFAULT 'otro',
      importe_base_centimos INTEGER NOT NULL DEFAULT 0,
      iva_repercutido_centimos INTEGER NOT NULL DEFAULT 0,
      compensacion_reagp_centimos INTEGER NOT NULL DEFAULT 0,
      cantidad REAL,
      unidad TEXT NOT NULL DEFAULT '',
      tercero_id INTEGER,
      finca_id INTEGER,
      cultivo_id TEXT NOT NULL DEFAULT '',
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_ingresos_fecha ON apuntes_ingreso (fecha_ms DESC)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_ingresos_tipo ON apuntes_ingreso (tipo_ingreso)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_ingresos_tercero ON apuntes_ingreso (tercero_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_ingresos_cultivo ON apuntes_ingreso (cultivo_id)',
  );

  await db.execute('''
    CREATE TABLE IF NOT EXISTS apuntes_gasto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      concepto TEXT NOT NULL DEFAULT '',
      tipo_gasto TEXT NOT NULL DEFAULT 'otro',
      importe_base_centimos INTEGER NOT NULL DEFAULT 0,
      iva_soportado_centimos INTEGER NOT NULL DEFAULT 0,
      imputacion TEXT NOT NULL DEFAULT 'general',
      finca_id INTEGER,
      cultivo_id TEXT NOT NULL DEFAULT '',
      tercero_id INTEGER,
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      tratamiento_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL,
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (tratamiento_id) REFERENCES tratamientos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_gastos_fecha ON apuntes_gasto (fecha_ms DESC)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_gastos_tipo ON apuntes_gasto (tipo_gasto)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_gastos_tercero ON apuntes_gasto (tercero_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_gastos_cultivo ON apuntes_gasto (cultivo_id)',
  );
}

// ─── Migración v7: facturas ─────────────────────────────────

Future<void> _crearTablaFacturasV7(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS facturas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numero_factura TEXT NOT NULL,
      fecha_emision_ms INTEGER NOT NULL,
      fecha_vencimiento_ms INTEGER,
      fecha_pago_ms INTEGER,
      cliente_nombre TEXT NOT NULL DEFAULT '',
      cliente_nif TEXT NOT NULL DEFAULT '',
      cliente_direccion TEXT NOT NULL DEFAULT '',
      lineas_json TEXT NOT NULL DEFAULT '[]',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 10,
      total REAL NOT NULL DEFAULT 0,
      estado TEXT NOT NULL DEFAULT 'emitida',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');
}
