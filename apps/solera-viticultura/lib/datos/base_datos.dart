import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/cepa.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/cosecha.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/tercero.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vinedo.dart';

/// Nombre del fichero de la BD en la carpeta de documentos. Lo usan
/// también las copias de seguridad: no cambiarlo.
const String nombreFicheroBaseDatosViticultura = 'solera_viticultura.db';

/// Versión del esquema (`version:` de `openDatabase`). Súbela con cada
/// migración: la copia de seguridad rechaza copias más nuevas que esto.
const int versionEsquemaBaseDatosViticultura = 3;

/// Acceso a la base de datos local de Solera Viticultura. Singleton
/// con inicialización perezosa: la primera lectura crea la BD.
///
/// **Convención**: las migraciones nunca son destructivas (heredada
/// de la suite Solera). Cualquier viticultor en campo lleva años de
/// cosechas, tratamientos y observaciones — perder un dato por una
/// actualización es inaceptable. Cada subida de versión es un paso
/// aditivo en `_aplicarMigraciones`.
///
/// v1 arranca con esquema completo (vinedos + cepas + 4 eventos +
/// titular). Tracks de inspección quedan fuera de v0.1 — se añadirán
/// cuando entre el chunk correspondiente.
class BaseDatosSoleraViticultura {
  static final BaseDatosSoleraViticultura instancia =
      BaseDatosSoleraViticultura._interno();
  factory BaseDatosSoleraViticultura() => instancia;
  BaseDatosSoleraViticultura._interno();

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, nombreFicheroBaseDatosViticultura);
    _basedatos = await openDatabase(
      ruta,
      version: versionEsquemaBaseDatosViticultura,
      onConfigure: (db) async {
        // ON DELETE CASCADE en eventos hijos requiere FKs activas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _crearEsquemaInicial(db);
        await _crearTablasContabilidadV2(db);
        await _crearTablasFacturasV3(db);
      },
      onUpgrade: (db, viejaVersion, nuevaVersion) async {
        if (viejaVersion < 2) {
          await _crearTablasContabilidadV2(db);
        }
        if (viejaVersion < 3) {
          await _crearTablasFacturasV3(db);
        }
      },
    );
    return _basedatos!;
  }

  // ─── Viñedos ────────────────────────────────────────────

  Future<int> guardarVinedo(Vinedo vinedo) async {
    final db = await basedatos;
    return db.insert('vinedos', vinedo.toMap()..remove('id'));
  }

  Future<void> actualizarVinedo(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('vinedos', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Vinedo>> listarVinedos() async {
    final db = await basedatos;
    final filas = await db.query('vinedos', orderBy: 'nombre ASC');
    return filas.map(Vinedo.fromMap).toList();
  }

  Future<Vinedo?> obtenerVinedo(int id) async {
    final db = await basedatos;
    final filas = await db.query('vinedos', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Vinedo.fromMap(filas.first);
  }

  /// Borra un viñedo y desasocia sus cepas (las deja como puntos
  /// sueltos). Las cepas no se borran — su historia es valiosa
  /// independientemente de que el viñedo exista o no como agrupación.
  Future<void> borrarVinedo(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.update('cepas', {'vinedo_id': null}, where: 'vinedo_id = ?', whereArgs: [id]);
      await txn.delete('vinedos', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Cepas ──────────────────────────────────────────────

  Future<int> guardarCepa(Cepa cepa) async {
    final db = await basedatos;
    return db.insert('cepas', cepa.toMap()..remove('id'));
  }

  Future<void> actualizarCepa(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('cepas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  /// Lista cepas filtrables por viñedo (`vinedoId == null` aquí
  /// significa **todas las cepas**, sin filtro). Para listar sólo
  /// puntos sueltos (sin viñedo) usar `listarPuntosSueltos`.
  Future<List<Cepa>> listarCepas({int? vinedoId}) async {
    final db = await basedatos;
    final filas = vinedoId == null
        ? await db.query('cepas', orderBy: 'fecha_creacion_ms DESC')
        : await db.query('cepas', where: 'vinedo_id = ?', whereArgs: [vinedoId], orderBy: 'fecha_creacion_ms DESC');
    return filas.map(Cepa.fromMap).toList();
  }

  Future<List<Cepa>> listarPuntosSueltos() async {
    final db = await basedatos;
    final filas = await db.query('cepas', where: 'vinedo_id IS NULL', orderBy: 'fecha_creacion_ms DESC');
    return filas.map(Cepa.fromMap).toList();
  }

  Future<Cepa?> obtenerCepa(int id) async {
    final db = await basedatos;
    final filas = await db.query('cepas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Cepa.fromMap(filas.first);
  }

  Future<void> borrarCepa(int id) async {
    final db = await basedatos;
    // Las FK ON DELETE CASCADE limpian eventos hijos automáticamente.
    await db.delete('cepas', where: 'id = ?', whereArgs: [id]);
  }

  /// Cuenta cepas agrupadas por variedad. Útil para el resumen del
  /// viñedo y del informe de campaña.
  Future<Map<String, int>> contarCepasPorVariedad({int? vinedoId}) async {
    final db = await basedatos;
    final where = vinedoId == null ? null : 'vinedo_id = ?';
    final whereArgs = vinedoId == null ? null : [vinedoId];
    final filas = await db.rawQuery(
      'SELECT variedad_id, COUNT(*) AS n FROM cepas'
      '${where != null ? ' WHERE $where' : ''}'
      ' GROUP BY variedad_id',
      whereArgs,
    );
    return {for (final f in filas) (f['variedad_id'] as String): (f['n'] as int)};
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
    final filas = await db.query('cosechas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Cosecha.fromMap(filas.first);
  }

  Future<List<Cosecha>> listarCosechasDeCepa(int cepaId) async {
    final db = await basedatos;
    final filas = await db.query('cosechas', where: 'cepa_id = ?', whereArgs: [cepaId], orderBy: 'fecha_ms DESC');
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

  Future<void> actualizarObservacion(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('observaciones', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Observacion?> obtenerObservacion(int id) async {
    final db = await basedatos;
    final filas = await db.query('observaciones', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Observacion.fromMap(filas.first);
  }

  Future<List<Observacion>> listarObservacionesDeCepa(int cepaId) async {
    final db = await basedatos;
    final filas = await db.query('observaciones', where: 'cepa_id = ?', whereArgs: [cepaId], orderBy: 'fecha_ms DESC');
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

  Future<void> actualizarIncidencia(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('incidencias', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Incidencia?> obtenerIncidencia(int id) async {
    final db = await basedatos;
    final filas = await db.query('incidencias', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Incidencia.fromMap(filas.first);
  }

  Future<List<Incidencia>> listarIncidenciasDeCepa(int cepaId) async {
    final db = await basedatos;
    final filas = await db.query('incidencias', where: 'cepa_id = ?', whereArgs: [cepaId], orderBy: 'fecha_ms DESC');
    return filas.map(Incidencia.fromMap).toList();
  }

  Future<List<Incidencia>> listarIncidenciasAbiertas({int? vinedoId}) async {
    final db = await basedatos;
    const base =
        'SELECT i.* FROM incidencias i INNER JOIN cepas c ON i.cepa_id = c.id WHERE i.resuelta = 0';
    final filas = vinedoId == null
        ? await db.rawQuery('$base ORDER BY i.fecha_ms DESC')
        : await db.rawQuery('$base AND c.vinedo_id = ? ORDER BY i.fecha_ms DESC', [vinedoId]);
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

  Future<void> actualizarTratamiento(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('tratamientos', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Tratamiento?> obtenerTratamiento(int id) async {
    final db = await basedatos;
    final filas = await db.query('tratamientos', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Tratamiento.fromMap(filas.first);
  }

  Future<List<Tratamiento>> listarTratamientosDeCepa(int cepaId) async {
    final db = await basedatos;
    final filas = await db.query('tratamientos', where: 'cepa_id = ?', whereArgs: [cepaId], orderBy: 'fecha_ms DESC');
    return filas.map(Tratamiento.fromMap).toList();
  }

  Future<void> borrarTratamiento(int id) async {
    final db = await basedatos;
    await db.delete('tratamientos', where: 'id = ?', whereArgs: [id]);
  }

  /// Lista tratamientos en un rango de fechas, filtrable por viñedo.
  /// Pensado para el libro oficial de tratamientos PAC (F1-7).
  Future<List<Tratamiento>> listarTratamientosPorVinedoYRango({
    required int? vinedoId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = vinedoId == null
        ? await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN cepas c ON t.cepa_id = c.id '
            'WHERE c.vinedo_id IS NULL AND t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN cepas c ON t.cepa_id = c.id '
            'WHERE c.vinedo_id = ? AND t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [vinedoId, desdeMs, hastaMs],
          );
    return filas.map(Tratamiento.fromMap).toList();
  }

  // ─── Titular de la explotación ──────────────────────────

  /// Devuelve el titular único, o un `Titular()` vacío si aún no se
  /// ha configurado. La pantalla de configuración (F1-7) usa el
  /// resultado para distinguir UI de alta vs UI de edición.
  Future<Titular> obtenerTitular() async {
    final db = await basedatos;
    final filas = await db.query('titulares', limit: 1);
    if (filas.isEmpty) return Titular();
    return Titular.fromMap(filas.first);
  }

  /// Upsert single-row del titular. Si ya existe, actualiza; si no,
  /// inserta. La tabla nunca debe tener más de una fila en v0.1.
  Future<void> guardarTitular(Titular titular) async {
    final db = await basedatos;
    final actual = await obtenerTitular();
    final mapa = titular.toMap()..remove('id');
    if (actual.id != null) {
      await db.update('titulares', mapa, where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('titulares', mapa);
    }
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
    final filas = await db.query('terceros', where: 'id = ?', whereArgs: [id], limit: 1);
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
      await db.update('configuraciones_fiscales', mapa,
          where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('configuraciones_fiscales', mapa);
    }
  }

  // ─── Apuntes de ingreso ─────────────────────────────────

  Future<int> guardarApunteIngreso(ApunteIngreso a) async {
    final db = await basedatos;
    return db.insert('apuntes_ingreso', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteIngreso(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('apuntes_ingreso', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<ApunteIngreso?> obtenerApunteIngreso(int id) async {
    final db = await basedatos;
    final filas = await db.query('apuntes_ingreso', where: 'id = ?', whereArgs: [id], limit: 1);
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

  Future<void> borrarApunteIngreso(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_ingreso', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Apuntes de gasto ────────────────────────────────────

  Future<int> guardarApunteGasto(ApunteGasto a) async {
    final db = await basedatos;
    return db.insert('apuntes_gasto', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteGasto(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('apuntes_gasto', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<ApunteGasto?> obtenerApunteGasto(int id) async {
    final db = await basedatos;
    final filas = await db.query('apuntes_gasto', where: 'id = ?', whereArgs: [id], limit: 1);
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

  Future<void> borrarApunteGasto(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_gasto', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cerrar() async {
    await _basedatos?.close();
    _basedatos = null;
  }

  Future<String> rutaBaseDatos() async {
    final db = await basedatos;
    return db.path;
  }

  Future<bool> estaVacia() async {
    final db = await basedatos;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hallazgos'));
    return (count ?? 0) == 0;
  }

  Future<void> reiniciar() async {
    await _basedatos?.close();
    _basedatos = null;
  }
}

// ─── Esquema inicial v1 ───────────────────────────────────

Future<void> _crearEsquemaInicial(Database db) async {
  await db.execute('''
    CREATE TABLE vinedos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 8202794,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      sigpac_provincia TEXT NOT NULL DEFAULT '',
      sigpac_municipio TEXT NOT NULL DEFAULT '',
      sigpac_poligono TEXT NOT NULL DEFAULT '',
      sigpac_parcela TEXT NOT NULL DEFAULT '',
      sigpac_recinto TEXT NOT NULL DEFAULT '',
      superficie_hectareas REAL
    )
  ''');

  await db.execute('''
    CREATE TABLE cepas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vinedo_id INTEGER,
      variedad_id TEXT NOT NULL,
      portainjerto_id TEXT NOT NULL DEFAULT '',
      latitud REAL NOT NULL,
      longitud REAL NOT NULL,
      precision_metros REAL,
      fecha_plantacion_ms INTEGER,
      etiqueta TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (vinedo_id) REFERENCES vinedos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_cepas_vinedo ON cepas (vinedo_id)');
  await db.execute('CREATE INDEX idx_cepas_variedad ON cepas (variedad_id)');
  await db.execute('CREATE INDEX idx_cepas_creacion ON cepas (fecha_creacion_ms DESC)');

  await db.execute('''
    CREATE TABLE cosechas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      kilos REAL,
      unidades INTEGER,
      calidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_cosechas_cepa_fecha ON cosechas (cepa_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE observaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      salud INTEGER,
      etiquetas_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_observaciones_cepa_fecha ON observaciones (cepa_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      diagnostico TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_incidencias_cepa_fecha ON incidencias (cepa_id, fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      producto TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      motivo TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      incidencia_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      numero_registro_fitosanitario TEXT NOT NULL DEFAULT '',
      nif_aplicador TEXT NOT NULL DEFAULT '',
      superficie_tratada_hectareas REAL,
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE,
      FOREIGN KEY (incidencia_id) REFERENCES incidencias(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_tratamientos_cepa_fecha ON tratamientos (cepa_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE titulares (
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

// ─── Migración v2: contabilidad (F1-12) ───────────────────

Future<void> _crearTablasContabilidadV2(Database db) async {
  await db.execute('''
    CREATE TABLE terceros (
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
  await db.execute('CREATE INDEX idx_terceros_nif ON terceros (nif)');
  await db.execute('CREATE INDEX idx_terceros_tipo ON terceros (tipo)');

  await db.execute('''
    CREATE TABLE configuraciones_fiscales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      regimen_irpf TEXT NOT NULL DEFAULT 'sin_elegir',
      regimen_iva TEXT NOT NULL DEFAULT 'sin_elegir',
      ano_fiscal_activo INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE apuntes_ingreso (
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
      vinedo_id INTEGER,
      variedad_id TEXT NOT NULL DEFAULT '',
      lote_vino TEXT NOT NULL DEFAULT '',
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (vinedo_id) REFERENCES vinedos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_ingresos_fecha ON apuntes_ingreso (fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_ingresos_tipo ON apuntes_ingreso (tipo_ingreso)');
  await db.execute('CREATE INDEX idx_ingresos_tercero ON apuntes_ingreso (tercero_id)');
  await db.execute('CREATE INDEX idx_ingresos_variedad ON apuntes_ingreso (variedad_id)');

  await db.execute('''
    CREATE TABLE apuntes_gasto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      concepto TEXT NOT NULL DEFAULT '',
      tipo_gasto TEXT NOT NULL DEFAULT 'otro',
      importe_base_centimos INTEGER NOT NULL DEFAULT 0,
      iva_soportado_centimos INTEGER NOT NULL DEFAULT 0,
      imputacion TEXT NOT NULL DEFAULT 'general',
      vinedo_id INTEGER,
      variedad_id TEXT NOT NULL DEFAULT '',
      tercero_id INTEGER,
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      tratamiento_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (vinedo_id) REFERENCES vinedos(id) ON DELETE SET NULL,
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (tratamiento_id) REFERENCES tratamientos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_gastos_fecha ON apuntes_gasto (fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_gastos_tipo ON apuntes_gasto (tipo_gasto)');
  await db.execute('CREATE INDEX idx_gastos_tercero ON apuntes_gasto (tercero_id)');
  await db.execute('CREATE INDEX idx_gastos_variedad ON apuntes_gasto (variedad_id)');
}


/// Esquema v3 — tabla de facturas (aditivo).
Future<void> _crearTablasFacturasV3(Database db) async {
  await db.execute("CREATE TABLE IF NOT EXISTS facturas (" +
    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
    "numero_factura TEXT NOT NULL," +
    "fecha_emision_ms INTEGER NOT NULL," +
    "fecha_vencimiento_ms INTEGER," +
    "fecha_pago_ms INTEGER," +
    "cliente_nombre TEXT NOT NULL DEFAULT ''," +
    "cliente_nif TEXT NOT NULL DEFAULT ''," +
    "cliente_direccion TEXT NOT NULL DEFAULT ''," +
    "lineas_json TEXT NOT NULL DEFAULT '[]'," +
    "base_imponible REAL NOT NULL DEFAULT 0," +
    "iva_porcentaje REAL NOT NULL DEFAULT 10," +
    "total REAL NOT NULL DEFAULT 0," +
    "estado TEXT NOT NULL DEFAULT 'emitida'," +
    "notas TEXT NOT NULL DEFAULT ''," +
    "fecha_creacion_ms INTEGER NOT NULL" +
  ")");
}
