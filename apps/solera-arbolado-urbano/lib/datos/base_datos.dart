import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/arbol.dart';
import '../modelos/incidencia.dart';
import '../modelos/inspeccion.dart';
import '../modelos/poda.dart';
import '../modelos/tecnico.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona.dart';

/// Nombre del fichero de la base de datos (en la carpeta de documentos).
const String nombreFicheroBaseDatosArbolado = 'solera_arbolado_urbano.db';

/// Versión del esquema que abre la app (`version:` de openDatabase). La
/// usa también la copia de seguridad para rechazar copias más nuevas.
const int versionEsquemaArbolado = 2;

/// Acceso a la base de datos local de Solera Arbolado Urbano. Singleton
/// con inicialización perezosa: la primera lectura crea la BD.
///
/// Convención del monorepo: las migraciones nunca son destructivas. Un
/// ayuntamiento lleva décadas de inventario de arbolado público —
/// perder un dato por una actualización es inaceptable.
///
/// v1 arranca con esquema completo: zonas + árboles + 4 eventos
/// (inspeccion / poda / tratamiento / incidencia) + tecnicos +
/// ayuntamiento (single-row).
class BaseDatosSoleraArbolado {
  static final BaseDatosSoleraArbolado instancia = BaseDatosSoleraArbolado._interno();
  factory BaseDatosSoleraArbolado() => instancia;
  BaseDatosSoleraArbolado._interno();

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, nombreFicheroBaseDatosArbolado);
    _basedatos = await openDatabase(
      ruta,
      version: versionEsquemaArbolado,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _crearEsquemaInicial(db);
        await _crearEsquemaV2(db);
      },
      onUpgrade: (db, viejaVersion, nuevaVersion) async {
        if (viejaVersion < 2) {
          await _crearEsquemaV2(db);
        }
      },
    );
    return _basedatos!;
  }

  // ─── Zonas ────────────────────────────────────────────────

  Future<int> guardarZona(Zona z) async {
    final db = await basedatos;
    return db.insert('zonas', z.toMap()..remove('id'));
  }

  Future<void> actualizarZona(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('zonas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Zona>> listarZonas() async {
    final db = await basedatos;
    final filas = await db.query('zonas', orderBy: 'nombre ASC');
    return filas.map(Zona.fromMap).toList();
  }

  Future<Zona?> obtenerZona(int id) async {
    final db = await basedatos;
    final filas = await db.query('zonas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Zona.fromMap(filas.first);
  }

  Future<void> borrarZona(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.update('arboles', {'zona_id': null}, where: 'zona_id = ?', whereArgs: [id]);
      await txn.delete('zonas', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Árboles ──────────────────────────────────────────────

  Future<int> guardarArbol(Arbol a) async {
    final db = await basedatos;
    return db.insert('arboles', a.toMap()..remove('id'));
  }

  Future<void> actualizarArbol(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('arboles', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Arbol>> listarArboles({int? zonaId}) async {
    final db = await basedatos;
    final filas = zonaId == null
        ? await db.query('arboles', orderBy: 'identificador_municipal ASC')
        : await db.query('arboles',
            where: 'zona_id = ?',
            whereArgs: [zonaId],
            orderBy: 'identificador_municipal ASC');
    return filas.map(Arbol.fromMap).toList();
  }

  Future<Arbol?> obtenerArbol(int id) async {
    final db = await basedatos;
    final filas = await db.query('arboles', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Arbol.fromMap(filas.first);
  }

  Future<Arbol?> obtenerArbolPorIdentificadorMunicipal(String identificador) async {
    final db = await basedatos;
    final filas = await db.query('arboles',
        where: 'identificador_municipal = ?', whereArgs: [identificador], limit: 1);
    if (filas.isEmpty) return null;
    return Arbol.fromMap(filas.first);
  }

  Future<Arbol?> obtenerArbolPorQrPayload(String payload) async {
    final db = await basedatos;
    final filas = await db.query('arboles',
        where: 'qr_payload = ? AND qr_payload != \'\'', whereArgs: [payload], limit: 1);
    if (filas.isEmpty) return null;
    return Arbol.fromMap(filas.first);
  }

  Future<void> borrarArbol(int id) async {
    final db = await basedatos;
    await db.delete('arboles', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> contarArbolesPorEstado({int? zonaId}) async {
    final db = await basedatos;
    final where = zonaId == null ? null : 'zona_id = ?';
    final args = zonaId == null ? null : [zonaId];
    final filas = await db.rawQuery(
      'SELECT estado, COUNT(*) AS n FROM arboles'
      '${where != null ? ' WHERE $where' : ''}'
      ' GROUP BY estado',
      args,
    );
    return {for (final f in filas) (f['estado'] as String): (f['n'] as int)};
  }

  // ─── Inspecciones ─────────────────────────────────────────

  Future<int> guardarInspeccion(Inspeccion i) async {
    final db = await basedatos;
    return db.insert('inspecciones', i.toMap()..remove('id'));
  }

  Future<List<Inspeccion>> listarInspeccionesDeArbol(int arbolId) async {
    final db = await basedatos;
    final filas = await db.query('inspecciones',
        where: 'arbol_id = ?', whereArgs: [arbolId], orderBy: 'fecha_ms DESC');
    return filas.map(Inspeccion.fromMap).toList();
  }

  Future<List<Inspeccion>> listarInspeccionesPorZonaYRango({
    required int? zonaId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = zonaId == null
        ? await db.rawQuery(
            'SELECT i.* FROM inspecciones i '
            'INNER JOIN arboles a ON i.arbol_id = a.id '
            'WHERE i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT i.* FROM inspecciones i '
            'INNER JOIN arboles a ON i.arbol_id = a.id '
            'WHERE a.zona_id = ? AND i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [zonaId, desdeMs, hastaMs],
          );
    return filas.map(Inspeccion.fromMap).toList();
  }

  // ─── Podas ────────────────────────────────────────────────

  Future<int> guardarPoda(Poda p) async {
    final db = await basedatos;
    return db.insert('podas', p.toMap()..remove('id'));
  }

  Future<List<Poda>> listarPodasDeArbol(int arbolId) async {
    final db = await basedatos;
    final filas = await db.query('podas',
        where: 'arbol_id = ?', whereArgs: [arbolId], orderBy: 'fecha_ms DESC');
    return filas.map(Poda.fromMap).toList();
  }

  Future<List<Poda>> listarPodasPorZonaYRango({
    required int? zonaId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = zonaId == null
        ? await db.rawQuery(
            'SELECT p.* FROM podas p '
            'INNER JOIN arboles a ON p.arbol_id = a.id '
            'WHERE p.fecha_ms BETWEEN ? AND ? '
            'ORDER BY p.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT p.* FROM podas p '
            'INNER JOIN arboles a ON p.arbol_id = a.id '
            'WHERE a.zona_id = ? AND p.fecha_ms BETWEEN ? AND ? '
            'ORDER BY p.fecha_ms ASC',
            [zonaId, desdeMs, hastaMs],
          );
    return filas.map(Poda.fromMap).toList();
  }

  // ─── Tratamientos ─────────────────────────────────────────

  Future<int> guardarTratamiento(Tratamiento t) async {
    final db = await basedatos;
    return db.insert('tratamientos', t.toMap()..remove('id'));
  }

  Future<List<Tratamiento>> listarTratamientosDeArbol(int arbolId) async {
    final db = await basedatos;
    final filas = await db.query('tratamientos',
        where: 'arbol_id = ?', whereArgs: [arbolId], orderBy: 'fecha_ms DESC');
    return filas.map(Tratamiento.fromMap).toList();
  }

  Future<List<Tratamiento>> listarTratamientosPorZonaYRango({
    required int? zonaId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = zonaId == null
        ? await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN arboles a ON t.arbol_id = a.id '
            'WHERE t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT t.* FROM tratamientos t '
            'INNER JOIN arboles a ON t.arbol_id = a.id '
            'WHERE a.zona_id = ? AND t.fecha_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_ms ASC',
            [zonaId, desdeMs, hastaMs],
          );
    return filas.map(Tratamiento.fromMap).toList();
  }

  // ─── Incidencias ──────────────────────────────────────────

  Future<int> guardarIncidencia(Incidencia i) async {
    final db = await basedatos;
    return db.insert('incidencias', i.toMap()..remove('id'));
  }

  Future<void> actualizarIncidencia(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('incidencias', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Incidencia>> listarIncidenciasDeArbol(int arbolId) async {
    final db = await basedatos;
    final filas = await db.query('incidencias',
        where: 'arbol_id = ?', whereArgs: [arbolId], orderBy: 'fecha_ms DESC');
    return filas.map(Incidencia.fromMap).toList();
  }

  Future<List<Incidencia>> listarIncidenciasAbiertas({int? zonaId}) async {
    final db = await basedatos;
    const base =
        'SELECT i.* FROM incidencias i INNER JOIN arboles a ON i.arbol_id = a.id WHERE i.resuelta = 0';
    final filas = zonaId == null
        ? await db.rawQuery('$base ORDER BY i.fecha_ms DESC')
        : await db.rawQuery('$base AND a.zona_id = ? ORDER BY i.fecha_ms DESC', [zonaId]);
    return filas.map(Incidencia.fromMap).toList();
  }

  Future<List<Incidencia>> listarIncidenciasPorZonaYRango({
    required int? zonaId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = zonaId == null
        ? await db.rawQuery(
            'SELECT i.* FROM incidencias i '
            'INNER JOIN arboles a ON i.arbol_id = a.id '
            'WHERE i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT i.* FROM incidencias i '
            'INNER JOIN arboles a ON i.arbol_id = a.id '
            'WHERE a.zona_id = ? AND i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [zonaId, desdeMs, hastaMs],
          );
    return filas.map(Incidencia.fromMap).toList();
  }

  // ─── Técnicos ─────────────────────────────────────────────

  Future<int> guardarTecnico(Tecnico t) async {
    final db = await basedatos;
    return db.insert('tecnicos', t.toMap()..remove('id'));
  }

  Future<void> actualizarTecnico(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('tecnicos', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tecnico>> listarTecnicos({bool soloActivos = false}) async {
    final db = await basedatos;
    final where = soloActivos ? 'activo = 1' : null;
    final filas = await db.query('tecnicos', where: where, orderBy: 'nombre ASC');
    return filas.map(Tecnico.fromMap).toList();
  }

  Future<Tecnico?> obtenerTecnico(int id) async {
    final db = await basedatos;
    final filas = await db.query('tecnicos', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Tecnico.fromMap(filas.first);
  }

  // ─── Ayuntamiento (single-row) ────────────────────────────

  Future<Ayuntamiento> obtenerAyuntamiento() async {
    final db = await basedatos;
    final filas = await db.query('ayuntamientos', limit: 1);
    if (filas.isEmpty) return Ayuntamiento();
    return Ayuntamiento.fromMap(filas.first);
  }

  Future<void> guardarAyuntamiento(Ayuntamiento a) async {
    final db = await basedatos;
    final actual = await obtenerAyuntamiento();
    final mapa = a.toMap()..remove('id');
    if (actual.id != null) {
      await db.update('ayuntamientos', mapa, where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('ayuntamientos', mapa);
    }
  }

  Future<void> cerrar() async {
    await _basedatos?.close();
    _basedatos = null;
  }
}

// ─── Esquema inicial v1 ─────────────────────────────────────

Future<void> _crearEsquemaInicial(Database db) async {
  await db.execute('''
    CREATE TABLE zonas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      codigo_municipal TEXT NOT NULL DEFAULT '',
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 3050327,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE arboles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      zona_id INTEGER,
      identificador_municipal TEXT NOT NULL UNIQUE,
      qr_payload TEXT NOT NULL DEFAULT '',
      especie_id TEXT NOT NULL DEFAULT '',
      edad_estimada_anos INTEGER,
      fecha_plantacion_ms INTEGER,
      perimetro_tronco_cm REAL,
      altura_estimada_metros REAL,
      riesgo_vta INTEGER,
      estado TEXT NOT NULL DEFAULT 'sano',
      tipo_alcorque_id TEXT NOT NULL DEFAULT '',
      latitud REAL,
      longitud REAL,
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (zona_id) REFERENCES zonas(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_arboles_zona ON arboles (zona_id)');
  await db.execute('CREATE INDEX idx_arboles_estado ON arboles (estado)');
  await db.execute('CREATE INDEX idx_arboles_identificador ON arboles (identificador_municipal)');
  await db.execute('CREATE INDEX idx_arboles_qr ON arboles (qr_payload)');

  await db.execute('''
    CREATE TABLE inspecciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      estado TEXT NOT NULL DEFAULT 'sano',
      riesgo_vta INTEGER,
      fenologia TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_inspecciones_arbol_fecha ON inspecciones (arbol_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE podas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      tipo_poda_id TEXT NOT NULL DEFAULT '',
      volumen_restos_m3 REAL,
      motivo TEXT NOT NULL DEFAULT '',
      rutas_fotos_antes_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_despues_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_podas_arbol_fecha ON podas (arbol_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      sustancia_activa_id TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      motivo_id_plaga TEXT NOT NULL DEFAULT '',
      lote_producto TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_tratamientos_arbol_fecha ON tratamientos (arbol_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      descripcion TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_incidencias_arbol_fecha ON incidencias (arbol_id, fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE tecnicos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      empresa_contratista TEXT NOT NULL DEFAULT '',
      cif_empresa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      carnet_aplicador TEXT NOT NULL DEFAULT '',
      nivel_carnet_aplicador TEXT NOT NULL DEFAULT '',
      activo INTEGER NOT NULL DEFAULT 1
    )
  ''');

  await db.execute('''
    CREATE TABLE ayuntamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      cif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      municipio TEXT NOT NULL DEFAULT '',
      provincia TEXT NOT NULL DEFAULT '',
      codigo_postal TEXT NOT NULL DEFAULT '',
      nombre_concejal TEXT NOT NULL DEFAULT '',
      concejalia TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT ''
    )
  ''');
}

/// Esquema v2 — tabla de facturas (aditivo).
Future<void> _crearEsquemaV2(Database db) async {
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
