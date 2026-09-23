import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/constantes.dart' show estadoTareaPorDefecto;
import '../modelos/finca.dart';
import '../utiles/geodesia.dart';
import 'espacio_generado.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/registro_actividad.dart';
import '../modelos/registro_comercializacion.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../modelos/validacion_producto.dart';
import '../modelos/zona_finca.dart';
import '../utiles/uid.dart';

/// Acceso a la base de datos local de Solera Zunbeltz. Singleton con
/// inicialización perezosa: la primera lectura crea la BD.
///
/// **Convención de la suite Solera**: las migraciones nunca son
/// destructivas. Cada subida de versión es un paso aditivo en `onUpgrade`.
///
/// v1 arranca con el módulo de gestión de fincas (FZ-2/FZ-3): `fincas`,
/// `puntos_infraestructura` y `tareas_mantenimiento`.
/// v2 añade el seguimiento del testaje: `registros_actividad` (alimentación,
/// pariciones, productos) y `apuntes_economicos` (ingresos/gastos).
/// v3 introduce el proceso de test por persona tester: `proyectos_test`,
/// `registros_comercializacion` y `validaciones_producto`, y cuelga el
/// seguimiento del proyecto (columna `proyecto_id`).
/// v4 añade el desglose por categorías e IVA al libro económico.
/// v5 añade las zonas dibujadas sobre el mapa (`zonas_finca`) y permite
/// anclar una tarea a una zona (columna `zona_id` en tareas).
/// v6 añade la periodicidad de una tarea (`recurrencia_dias` en tareas):
/// rellenar comederos, revisar vallados… tareas que se repiten cada N días.
/// v7 añade `uid` (clave estable entre dispositivos) y `actualizado_ms`
/// (para last-write-wins) a las tareas, de cara a la sincronización con el
/// WordPress de Zunbeltz (ver `servicios/cliente_sync_zunbeltz.dart`).
class BaseDatosSoleraZunbeltz {
  static final BaseDatosSoleraZunbeltz instancia =
      BaseDatosSoleraZunbeltz._interno();
  factory BaseDatosSoleraZunbeltz() => instancia;
  BaseDatosSoleraZunbeltz._interno();

  /// Constructor para tests: inyecta una BD ya abierta (p. ej. ffi en
  /// memoria) con el esquema aplicado vía [crearEsquemaV1].
  @visibleForTesting
  BaseDatosSoleraZunbeltz.paraTests(Database db) : _basedatos = db;

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, 'solera_zunbeltz.db');
    _basedatos = await openDatabase(
      ruta,
      version: 8,
      onConfigure: (db) async {
        // ON DELETE CASCADE / SET NULL requieren FKs activas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await crearEsquemaV1(db);
        await aplicarMigracionV2(db);
        await aplicarMigracionV3(db);
        await aplicarMigracionV4(db);
        await aplicarMigracionV5(db);
        await aplicarMigracionV6(db);
        await aplicarMigracionV7(db);
        await aplicarMigracionV8(db);
      },
      onUpgrade: (db, anterior, actual) async {
        if (anterior < 2) await aplicarMigracionV2(db);
        if (anterior < 3) await aplicarMigracionV3(db);
        if (anterior < 4) await aplicarMigracionV4(db);
        if (anterior < 5) await aplicarMigracionV5(db);
        if (anterior < 6) await aplicarMigracionV6(db);
        if (anterior < 7) await aplicarMigracionV7(db);
        if (anterior < 8) await aplicarMigracionV8(db);
      },
    );
    return _basedatos!;
  }

  /// Crea el esquema v1. Público y estático para reutilizarlo en tests con
  /// una BD ffi en memoria.
  @visibleForTesting
  static Future<void> crearEsquemaV1(Database db) async {
    await db.execute('''
      CREATE TABLE fincas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        latitud REAL,
        longitud REAL,
        superficie_ha REAL NOT NULL DEFAULT 0,
        recintos_sigpac TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE puntos_infraestructura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        finca_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'abrevadero',
        nombre TEXT NOT NULL DEFAULT '',
        latitud REAL,
        longitud REAL,
        estado TEXT NOT NULL DEFAULT 'operativo',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_puntos_finca ON puntos_infraestructura(finca_id)');

    await db.execute('''
      CREATE TABLE tareas_mantenimiento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        finca_id INTEGER NOT NULL,
        punto_id INTEGER,
        titulo TEXT NOT NULL DEFAULT '',
        descripcion TEXT NOT NULL DEFAULT '',
        responsable TEXT NOT NULL DEFAULT '',
        prioridad TEXT NOT NULL DEFAULT 'media',
        estado TEXT NOT NULL DEFAULT 'pendiente',
        fecha_objetivo_ms INTEGER,
        rutas_fotos_antes_json TEXT NOT NULL DEFAULT '[]',
        rutas_fotos_despues_json TEXT NOT NULL DEFAULT '[]',
        coste_centimos INTEGER,
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE,
        FOREIGN KEY (punto_id) REFERENCES puntos_infraestructura(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_tareas_finca ON tareas_mantenimiento(finca_id)');
    await db.execute(
        'CREATE INDEX idx_tareas_punto ON tareas_mantenimiento(punto_id)');
  }

  /// Migración v1 → v2: seguimiento del testaje. Aditiva (no destructiva).
  @visibleForTesting
  static Future<void> aplicarMigracionV2(Database db) async {
    await db.execute('''
      CREATE TABLE registros_actividad (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        finca_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'alimentacion',
        cantidad REAL NOT NULL DEFAULT 0,
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        lote TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_actividad_finca ON registros_actividad(finca_id)');

    await db.execute('''
      CREATE TABLE apuntes_economicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        finca_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'gasto',
        concepto TEXT NOT NULL DEFAULT '',
        importe_centimos INTEGER NOT NULL DEFAULT 0,
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_apuntes_finca ON apuntes_economicos(finca_id)');
  }

  /// Migración v2 → v3: proceso de test por persona tester. Aditiva.
  @visibleForTesting
  static Future<void> aplicarMigracionV3(Database db) async {
    await db.execute('''
      CREATE TABLE proyectos_test (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        persona TEXT NOT NULL DEFAULT '',
        actividad TEXT NOT NULL DEFAULT '',
        finca_id INTEGER,
        fecha_inicio_ms INTEGER,
        fecha_fin_ms INTEGER,
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE registros_comercializacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proyecto_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        producto TEXT NOT NULL DEFAULT '',
        canal TEXT NOT NULL DEFAULT 'directa',
        cantidad REAL NOT NULL DEFAULT 0,
        unidad TEXT NOT NULL DEFAULT 'uds',
        precio_unitario_centimos INTEGER NOT NULL DEFAULT 0,
        ingreso_centimos INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (proyecto_id) REFERENCES proyectos_test(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_comercial_proyecto ON registros_comercializacion(proyecto_id)');

    await db.execute('''
      CREATE TABLE validaciones_producto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proyecto_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        descripcion TEXT NOT NULL DEFAULT '',
        resultado TEXT NOT NULL DEFAULT 'validado',
        valoracion INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (proyecto_id) REFERENCES proyectos_test(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_validacion_proyecto ON validaciones_producto(proyecto_id)');

    // El seguimiento existente se cuelga del proyecto (columna nullable;
    // SQLite no permite añadir FK por ALTER, se respeta por código).
    await db.execute(
        'ALTER TABLE registros_actividad ADD COLUMN proyecto_id INTEGER');
    await db.execute(
        'ALTER TABLE apuntes_economicos ADD COLUMN proyecto_id INTEGER');
  }

  /// Migración v3 → v4: desglose por categorías e IVA. Aditiva.
  @visibleForTesting
  static Future<void> aplicarMigracionV4(Database db) async {
    await db.execute(
        "ALTER TABLE apuntes_economicos ADD COLUMN categoria TEXT NOT NULL DEFAULT ''");
    await db.execute(
        'ALTER TABLE apuntes_economicos ADD COLUMN iva_porcentaje INTEGER NOT NULL DEFAULT 0');
    await db.execute(
        'ALTER TABLE registros_comercializacion ADD COLUMN iva_porcentaje INTEGER NOT NULL DEFAULT 0');
  }

  /// Migración v4 → v5: zonas dibujadas sobre el mapa (recintos) y anclaje
  /// de tareas a una zona. Aditiva.
  ///
  /// Los vértices van como JSON en la propia fila: un polígono se lee y se
  /// escribe siempre entero, nunca por vértice, así que una tabla hija solo
  /// añadiría *joins* sin ganar nada.
  @visibleForTesting
  static Future<void> aplicarMigracionV5(Database db) async {
    await db.execute('''
      CREATE TABLE zonas_finca (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        finca_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'parcela_pasto',
        nombre TEXT NOT NULL DEFAULT '',
        vertices_json TEXT NOT NULL DEFAULT '[]',
        superficie_ha_calculada REAL NOT NULL DEFAULT 0,
        superficie_ha_oficial REAL,
        estado TEXT NOT NULL DEFAULT 'en_uso',
        recinto_sigpac TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_zonas_finca ON zonas_finca(finca_id)');

    // Una tarea puede anclarse a un punto, a una zona o a ninguno (tarea de
    // finca). Columna nullable; SQLite no permite añadir FK por ALTER, así
    // que el SET NULL al borrar la zona se hace por código en [borrarZona].
    await db.execute(
        'ALTER TABLE tareas_mantenimiento ADD COLUMN zona_id INTEGER');
    await db.execute(
        'CREATE INDEX idx_tareas_zona ON tareas_mantenimiento(zona_id)');
  }

  /// Migración v5 → v6: periodicidad de una tarea de mantenimiento. Aditiva.
  @visibleForTesting
  static Future<void> aplicarMigracionV6(Database db) async {
    await db.execute(
        'ALTER TABLE tareas_mantenimiento ADD COLUMN recurrencia_dias INTEGER');
  }

  /// Migración v6 → v7: sincronización de tareas con el WordPress de
  /// Zunbeltz. Añade `uid` (clave estable entre dispositivos, generada en
  /// el cliente) y `actualizado_ms` (para el merge last-write-wins). Las
  /// filas ya existentes no tienen `uid` — se rellena aquí, fila a fila,
  /// porque SQLite no admite un `DEFAULT` distinto por fila en un
  /// `ALTER TABLE`.
  @visibleForTesting
  static Future<void> aplicarMigracionV7(Database db) async {
    await db.execute(
        "ALTER TABLE tareas_mantenimiento ADD COLUMN uid TEXT NOT NULL DEFAULT ''");
    await db.execute(
        'ALTER TABLE tareas_mantenimiento ADD COLUMN actualizado_ms INTEGER NOT NULL DEFAULT 0');
    final filas = await db.query('tareas_mantenimiento',
        columns: ['id', 'fecha_creacion_ms'], where: "uid = ''");
    for (final fila in filas) {
      await db.update(
        'tareas_mantenimiento',
        {
          'uid': generarUid(),
          'actualizado_ms': (fila['fecha_creacion_ms'] as int?) ?? 0,
        },
        where: 'id = ?',
        whereArgs: [fila['id']],
      );
    }
    await db.execute(
        'CREATE UNIQUE INDEX idx_tareas_uid ON tareas_mantenimiento(uid)');
  }

  /// Migración v7 → v8: roles. La tarea guarda a quién está asignada y
  /// quién la creó por `uid` de persona del espacio (las da de alta la
  /// coordinación en el WordPress). Aditiva: las tareas previas quedan con
  /// ambos vacíos y conservan el responsable en texto libre.
  @visibleForTesting
  static Future<void> aplicarMigracionV8(Database db) async {
    await db.execute(
        "ALTER TABLE tareas_mantenimiento ADD COLUMN responsable_uid TEXT NOT NULL DEFAULT ''");
    await db.execute(
        "ALTER TABLE tareas_mantenimiento ADD COLUMN creado_por_uid TEXT NOT NULL DEFAULT ''");
    await db.execute(
        'CREATE INDEX idx_tareas_responsable_uid ON tareas_mantenimiento(responsable_uid)');
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
    final filas =
        await db.query('fincas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Finca.fromMap(filas.first);
  }

  Future<void> borrarFinca(int id) async {
    final db = await basedatos;
    await db.delete('fincas', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Puntos de infraestructura ──────────────────────────

  Future<int> guardarPunto(PuntoInfraestructura punto) async {
    final db = await basedatos;
    return db.insert('puntos_infraestructura', punto.toMap()..remove('id'));
  }

  Future<void> actualizarPunto(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('puntos_infraestructura', cambios,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarPuntoCoords(
      int id, double latitud, double longitud) async {
    await actualizarPunto(id, {'latitud': latitud, 'longitud': longitud});
  }

  Future<List<PuntoInfraestructura>> listarPuntos({int? fincaId}) async {
    final db = await basedatos;
    final filas = fincaId == null
        ? await db.query('puntos_infraestructura',
            orderBy: 'fecha_creacion_ms DESC')
        : await db.query('puntos_infraestructura',
            where: 'finca_id = ?',
            whereArgs: [fincaId],
            orderBy: 'fecha_creacion_ms DESC');
    return filas.map(PuntoInfraestructura.fromMap).toList();
  }

  Future<PuntoInfraestructura?> obtenerPunto(int id) async {
    final db = await basedatos;
    final filas = await db.query('puntos_infraestructura',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return PuntoInfraestructura.fromMap(filas.first);
  }

  Future<void> borrarPunto(int id) async {
    final db = await basedatos;
    await db.delete('puntos_infraestructura', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Zonas (recintos dibujados) ─────────────────────────

  Future<int> guardarZona(ZonaFinca zona) async {
    final db = await basedatos;
    return db.insert('zonas_finca', zona.toMap()..remove('id'));
  }

  Future<void> actualizarZona(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('zonas_finca', cambios, where: 'id = ?', whereArgs: [id]);
  }

  /// Sustituye el trazado de una zona y recalcula su superficie orientativa.
  Future<void> actualizarTrazadoZona(int id, List<LatLng> vertices) async {
    await actualizarZona(id, {
      'vertices_json': ZonaFinca.codificarVertices(vertices),
      'superficie_ha_calculada': superficieHectareas(vertices),
    });
  }

  Future<List<ZonaFinca>> listarZonas({int? fincaId}) async {
    final db = await basedatos;
    final filas = fincaId == null
        ? await db.query('zonas_finca', orderBy: 'fecha_creacion_ms DESC')
        : await db.query('zonas_finca',
            where: 'finca_id = ?',
            whereArgs: [fincaId],
            orderBy: 'fecha_creacion_ms DESC');
    return filas.map(ZonaFinca.fromMap).toList();
  }

  Future<ZonaFinca?> obtenerZona(int id) async {
    final db = await basedatos;
    final filas =
        await db.query('zonas_finca', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ZonaFinca.fromMap(filas.first);
  }

  /// Borra la zona y desancla sus tareas, que se conservan como tareas de
  /// finca. Equivale al ON DELETE SET NULL que SQLite no deja añadir por
  /// ALTER TABLE, y va en transacción para no dejar tareas apuntando a una
  /// zona que ya no existe.
  Future<void> borrarZona(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.update('tareas_mantenimiento', {'zona_id': null},
          where: 'zona_id = ?', whereArgs: [id]);
      await txn.delete('zonas_finca', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Suma de superficies (ha) de las zonas de una finca, o de todas. Usa la
  /// oficial de SIGPAC cuando existe y la calculada cuando no.
  Future<double> superficieTotalZonasHa({int? fincaId}) async {
    final zonas = await listarZonas(fincaId: fincaId);
    var total = 0.0;
    for (final zona in zonas) {
      total += zona.superficieHa;
    }
    return total;
  }

  // ─── Tareas de mantenimiento ────────────────────────────

  Future<int> guardarTarea(TareaMantenimiento tarea) async {
    final db = await basedatos;
    return db.insert('tareas_mantenimiento', tarea.toMap()..remove('id'));
  }

  /// Actualiza una tarea y marca `actualizado_ms` a ahora (salvo que
  /// `cambios` ya lo incluya), para que la sincronización sepa que esta
  /// versión es más reciente que la que hubiera en el servidor.
  Future<void> actualizarTarea(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    final conMarca = cambios.containsKey('actualizado_ms')
        ? cambios
        : {...cambios, 'actualizado_ms': DateTime.now().millisecondsSinceEpoch};
    await db.update('tareas_mantenimiento', conMarca,
        where: 'id = ?', whereArgs: [id]);
  }

  /// Lista tareas con filtros opcionales acumulables (finca, punto, zona,
  /// estado, responsable por nombre o por uid). Sin filtros devuelve todas, las más recientes primero.
  Future<List<TareaMantenimiento>> listarTareas({
    int? fincaId,
    int? puntoId,
    int? zonaId,
    String? estado,
    String? responsable,
    String? responsableUid,
  }) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (fincaId != null) {
      condiciones.add('finca_id = ?');
      args.add(fincaId);
    }
    if (puntoId != null) {
      condiciones.add('punto_id = ?');
      args.add(puntoId);
    }
    if (zonaId != null) {
      condiciones.add('zona_id = ?');
      args.add(zonaId);
    }
    if (estado != null) {
      condiciones.add('estado = ?');
      args.add(estado);
    }
    if (responsable != null) {
      condiciones.add('responsable = ?');
      args.add(responsable);
    }
    if (responsableUid != null) {
      condiciones.add('responsable_uid = ?');
      args.add(responsableUid);
    }
    final filas = await db.query(
      'tareas_mantenimiento',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha_creacion_ms DESC',
    );
    return filas.map(TareaMantenimiento.fromMap).toList();
  }

  Future<TareaMantenimiento?> obtenerTarea(int id) async {
    final db = await basedatos;
    final filas = await db.query('tareas_mantenimiento',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return TareaMantenimiento.fromMap(filas.first);
  }

  /// Busca una tarea por su clave de sincronización. Usado por
  /// `ClienteSyncZunbeltz` para saber si una tarea que llega del servidor
  /// ya existía en local (y desde cuándo) antes de fusionarla.
  Future<TareaMantenimiento?> obtenerTareaPorUid(String uid) async {
    final db = await basedatos;
    final filas = await db.query('tareas_mantenimiento',
        where: 'uid = ?', whereArgs: [uid], limit: 1);
    if (filas.isEmpty) return null;
    return TareaMantenimiento.fromMap(filas.first);
  }

  Future<void> borrarTarea(int id) async {
    final db = await basedatos;
    await db.delete('tareas_mantenimiento', where: 'id = ?', whereArgs: [id]);
  }

  /// Marca una tarea como hecha. Si es recurrente ([TareaMantenimiento.esRecurrente])
  /// genera en la misma transacción la siguiente instancia pendiente, con la
  /// fecha objetivo desplazada `recurrenciaDias` a partir de la de hoy (o de
  /// la fecha objetivo original si es posterior a hoy) — sin fotos ni coste,
  /// que son de cada ocurrencia. Devuelve el id de la tarea generada, o
  /// `null` si la tarea no era recurrente.
  Future<int?> marcarTareaHecha(int id) async {
    final db = await basedatos;
    final tarea = await obtenerTarea(id);
    if (tarea == null) return null;
    return db.transaction<int?>((txn) async {
      final ahoraMs = DateTime.now().millisecondsSinceEpoch;
      await txn.update(
          'tareas_mantenimiento', {'estado': 'hecha', 'actualizado_ms': ahoraMs},
          where: 'id = ?', whereArgs: [id]);
      if (!tarea.esRecurrente) return null;
      final ahora = DateTime.now();
      final base = tarea.fechaObjetivoMs != null &&
              tarea.fechaObjetivoMs! > ahora.millisecondsSinceEpoch
          ? DateTime.fromMillisecondsSinceEpoch(tarea.fechaObjetivoMs!)
          : ahora;
      final siguiente = TareaMantenimiento(
        fincaId: tarea.fincaId,
        puntoId: tarea.puntoId,
        zonaId: tarea.zonaId,
        titulo: tarea.titulo,
        descripcion: tarea.descripcion,
        responsable: tarea.responsable,
        responsableUid: tarea.responsableUid,
        creadoPorUid: tarea.creadoPorUid,
        prioridad: tarea.prioridad,
        estado: estadoTareaPorDefecto,
        fechaObjetivoMs: base
            .add(Duration(days: tarea.recurrenciaDias!))
            .millisecondsSinceEpoch,
        fechaCreacionMs: ahora.millisecondsSinceEpoch,
        recurrenciaDias: tarea.recurrenciaDias,
      );
      return txn.insert('tareas_mantenimiento', siguiente.toMap()..remove('id'));
    });
  }

  /// Todas las tareas con lo necesario para sincronizar (incluye `uid` y
  /// `actualizado_ms`). Sin filtrar por "sucia"/"limpia": el volumen de
  /// tareas de un espacio test es pequeño y sincronizar todo cada vez es
  /// más simple y más difícil de dejar desincronizado por error.
  Future<List<TareaMantenimiento>> tareasParaSincronizar() => listarTareas();

  /// Inserta o actualiza (por `uid`) una tarea que llega del servidor al
  /// sincronizar, ya con `fincaId` resuelto a un id local (ver
  /// `ClienteSyncZunbeltz`, que empareja por nombre de finca — el único
  /// dato de finca que viaja, porque fincas/puntos/zonas no se
  /// sincronizan todavía). Sólo escribe si la versión remota es más
  /// reciente (`actualizado_ms` mayor) que la que ya hay en local, para no
  /// pisar una edición local más nueva que aún no se ha subido. Una tarea
  /// nueva llega con `puntoId` y `zonaId` a `null`: el anclaje a un
  /// punto/zona concreto es local a cada dispositivo mientras esos
  /// catálogos no se sincronicen.
  ///
  /// Con [forzar] se escribe la versión remota aunque la local sea más
  /// reciente: el servidor ha rechazado o ajustado el cambio local por
  /// permisos y su versión es la buena.
  Future<void> upsertTareaRemota(TareaMantenimiento remota,
      {bool forzar = false}) async {
    final db = await basedatos;
    final existente = await db.query('tareas_mantenimiento',
        where: 'uid = ?', whereArgs: [remota.uid], limit: 1);
    final mapa = remota.toMap()
      ..remove('id')
      ..['punto_id'] = null
      ..['zona_id'] = null;
    if (existente.isEmpty) {
      await db.insert('tareas_mantenimiento', mapa);
      return;
    }
    final local = TareaMantenimiento.fromMap(existente.first);
    if (!forzar && remota.actualizadoMs <= local.actualizadoMs) return;
    mapa.remove('uid');
    // Lo que no viaja (anclaje a punto/zona, fotos) se conserva: el
    // servidor no lo conoce y lo mandaría vacío.
    mapa
      ..['punto_id'] = local.puntoId
      ..['zona_id'] = local.zonaId
      ..['rutas_fotos_antes_json'] = local.rutasFotosAntesJson
      ..['rutas_fotos_despues_json'] = local.rutasFotosDespuesJson;
    await db.update('tareas_mantenimiento', mapa,
        where: 'uid = ?', whereArgs: [remota.uid]);
  }

  /// Cuenta las tareas que no están hechas (pendiente / en curso / bloqueada).
  Future<int> contarTareasAbiertas() async {
    final db = await basedatos;
    final resultado = await db.rawQuery(
        "SELECT COUNT(*) AS n FROM tareas_mantenimiento WHERE estado != 'hecha'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  // ─── Registros de actividad (seguimiento) ──────────────

  Future<int> guardarRegistro(RegistroActividad registro) async {
    final db = await basedatos;
    return db.insert('registros_actividad', registro.toMap()..remove('id'));
  }

  Future<List<RegistroActividad>> listarRegistros({
    int? fincaId,
    int? proyectoId,
    String? tipo,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: tipo,
        desdeMs: desdeMs,
        hastaMs: hastaMs);
    final filas = await db.query(
      'registros_actividad',
      where: filtro.where,
      whereArgs: filtro.args,
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(RegistroActividad.fromMap).toList();
  }

  Future<void> borrarRegistro(int id) async {
    final db = await basedatos;
    await db.delete('registros_actividad', where: 'id = ?', whereArgs: [id]);
  }

  /// Suma de cantidades de actividad de un tipo (kg de alimentación, nº de
  /// pariciones, uds comercializadas) con filtros opcionales de finca y fechas.
  Future<double> sumarCantidadActividad(
    String tipo, {
    int? fincaId,
    int? proyectoId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: tipo,
        desdeMs: desdeMs,
        hastaMs: hastaMs);
    final resultado = await db.rawQuery(
      'SELECT COALESCE(SUM(cantidad), 0) AS total FROM registros_actividad'
      '${filtro.where == null ? '' : ' WHERE ${filtro.where}'}',
      filtro.args,
    );
    final total = resultado.first['total'];
    return (total as num).toDouble();
  }

  // ─── Apuntes económicos (seguimiento) ───────────────────

  Future<int> guardarApunte(ApunteEconomico apunte) async {
    final db = await basedatos;
    return db.insert('apuntes_economicos', apunte.toMap()..remove('id'));
  }

  Future<List<ApunteEconomico>> listarApuntes({
    int? fincaId,
    int? proyectoId,
    String? tipo,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: tipo,
        desdeMs: desdeMs,
        hastaMs: hastaMs);
    final filas = await db.query(
      'apuntes_economicos',
      where: filtro.where,
      whereArgs: filtro.args,
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteEconomico.fromMap).toList();
  }

  Future<void> borrarApunte(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_economicos', where: 'id = ?', whereArgs: [id]);
  }

  /// Suma de importes (en céntimos) de un tipo de apunte (ingreso / gasto)
  /// con filtros opcionales de finca y fechas.
  Future<int> sumarImporteEconomico(
    String tipo, {
    int? fincaId,
    int? proyectoId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: tipo,
        desdeMs: desdeMs,
        hastaMs: hastaMs);
    final resultado = await db.rawQuery(
      'SELECT COALESCE(SUM(importe_centimos), 0) AS total FROM apuntes_economicos'
      '${filtro.where == null ? '' : ' WHERE ${filtro.where}'}',
      filtro.args,
    );
    return (resultado.first['total'] as num).toInt();
  }

  /// Construye el WHERE común de seguimiento (proyecto + finca + tipo + fechas).
  _FiltroSql _filtroSeguimiento({
    int? fincaId,
    int? proyectoId,
    String? tipo,
    int? desdeMs,
    int? hastaMs,
  }) {
    final condiciones = <String>[];
    final args = <Object?>[];
    if (proyectoId != null) {
      condiciones.add('proyecto_id = ?');
      args.add(proyectoId);
    }
    if (fincaId != null) {
      condiciones.add('finca_id = ?');
      args.add(fincaId);
    }
    if (tipo != null) {
      condiciones.add('tipo = ?');
      args.add(tipo);
    }
    if (desdeMs != null) {
      condiciones.add('fecha_ms >= ?');
      args.add(desdeMs);
    }
    if (hastaMs != null) {
      condiciones.add('fecha_ms <= ?');
      args.add(hastaMs);
    }
    return _FiltroSql(
      condiciones.isEmpty ? null : condiciones.join(' AND '),
      args.isEmpty ? null : args,
    );
  }

  // ─── Proyectos de test ──────────────────────────────────

  Future<int> guardarProyecto(ProyectoTest proyecto) async {
    final db = await basedatos;
    return db.insert('proyectos_test', proyecto.toMap()..remove('id'));
  }

  Future<void> actualizarProyecto(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('proyectos_test', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProyectoTest>> listarProyectos() async {
    final db = await basedatos;
    final filas = await db.query('proyectos_test', orderBy: 'nombre ASC');
    return filas.map(ProyectoTest.fromMap).toList();
  }

  Future<ProyectoTest?> obtenerProyecto(int id) async {
    final db = await basedatos;
    final filas = await db.query('proyectos_test',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ProyectoTest.fromMap(filas.first);
  }

  Future<void> borrarProyecto(int id) async {
    final db = await basedatos;
    await db.delete('proyectos_test', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Comercialización ───────────────────────────────────

  Future<int> guardarComercializacion(RegistroComercializacion registro) async {
    final db = await basedatos;
    return db.insert('registros_comercializacion', registro.toMap()..remove('id'));
  }

  Future<List<RegistroComercializacion>> listarComercializacion({
    int? proyectoId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        proyectoId: proyectoId, desdeMs: desdeMs, hastaMs: hastaMs);
    final filas = await db.query('registros_comercializacion',
        where: filtro.where, whereArgs: filtro.args, orderBy: 'fecha_ms DESC');
    return filas.map(RegistroComercializacion.fromMap).toList();
  }

  Future<void> borrarComercializacion(int id) async {
    final db = await basedatos;
    await db
        .delete('registros_comercializacion', where: 'id = ?', whereArgs: [id]);
  }

  /// Suma de ingresos (céntimos) de comercialización del proyecto/periodo.
  Future<int> sumarIngresoComercializacion({
    int? proyectoId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        proyectoId: proyectoId, desdeMs: desdeMs, hastaMs: hastaMs);
    final resultado = await db.rawQuery(
      'SELECT COALESCE(SUM(ingreso_centimos), 0) AS total FROM registros_comercializacion'
      '${filtro.where == null ? '' : ' WHERE ${filtro.where}'}',
      filtro.args,
    );
    return (resultado.first['total'] as num).toInt();
  }

  // ─── Validación de producto ─────────────────────────────

  Future<int> guardarValidacion(ValidacionProducto validacion) async {
    final db = await basedatos;
    return db.insert('validaciones_producto', validacion.toMap()..remove('id'));
  }

  Future<List<ValidacionProducto>> listarValidaciones({int? proyectoId}) async {
    final db = await basedatos;
    final filas = proyectoId == null
        ? await db.query('validaciones_producto', orderBy: 'fecha_ms DESC')
        : await db.query('validaciones_producto',
            where: 'proyecto_id = ?',
            whereArgs: [proyectoId],
            orderBy: 'fecha_ms DESC');
    return filas.map(ValidacionProducto.fromMap).toList();
  }

  Future<void> borrarValidacion(int id) async {
    final db = await basedatos;
    await db.delete('validaciones_producto', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Rentabilidad por proyecto ──────────────────────────

  /// Análisis económico de un proyecto: ingresos (comercialización + apuntes),
  /// gastos y balance del periodo.
  Future<RentabilidadProyecto> rentabilidadProyecto(
    int proyectoId, {
    int? desdeMs,
    int? hastaMs,
  }) async {
    final ingresosComercial = await sumarIngresoComercializacion(
        proyectoId: proyectoId, desdeMs: desdeMs, hastaMs: hastaMs);
    final ingresosApuntes = await sumarImporteEconomico('ingreso',
        proyectoId: proyectoId, desdeMs: desdeMs, hastaMs: hastaMs);
    final gastos = await sumarImporteEconomico('gasto',
        proyectoId: proyectoId, desdeMs: desdeMs, hastaMs: hastaMs);
    return RentabilidadProyecto(
      ingresosComercializacionCentimos: ingresosComercial,
      ingresosApuntesCentimos: ingresosApuntes,
      gastosCentimos: gastos,
    );
  }

  /// Desglose de importes (céntimos) por categoría para un tipo de apunte
  /// (gasto / ingreso) de un proyecto/periodo. Devuelve categoría → total.
  Future<Map<String, int>> desglosePorCategoria(
    String tipo, {
    int? proyectoId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final filtro = _filtroSeguimiento(
        proyectoId: proyectoId, tipo: tipo, desdeMs: desdeMs, hastaMs: hastaMs);
    final filas = await db.rawQuery(
      'SELECT categoria, COALESCE(SUM(importe_centimos), 0) AS total FROM apuntes_economicos'
      '${filtro.where == null ? '' : ' WHERE ${filtro.where}'}'
      ' GROUP BY categoria ORDER BY total DESC',
      filtro.args,
    );
    final mapa = <String, int>{};
    for (final f in filas) {
      mapa[(f['categoria'] as String?) ?? ''] = (f['total'] as num).toInt();
    }
    return mapa;
  }

  // ─── Semilla de ejemplo ─────────────────────────────────

  /// Inserta las dos fincas de Zunbeltz si la BD está vacía. **Son datos de
  /// ejemplo** con superficies públicas y centroides aproximados; las fincas,
  /// recintos e infraestructuras reales se cargan con el equipo de Zunbeltz
  /// (ver BLOQUEOS-PENDIENTES, A4/A5). Devuelve true si sembró.
  Future<bool> sembrarFincasDemoSiVacia() async {
    final existentes = await listarFincas();
    if (existentes.isNotEmpty) return false;
    await guardarFinca(Finca(
      nombre: 'Zunbeltz',
      latitud: 42.7872,
      longitud: -1.9450,
      superficieHa: 231,
      notas: 'Datos de ejemplo · superficie pública, centroide aproximado.',
    ));
    await guardarFinca(Finca(
      nombre: 'La Planilla',
      latitud: 42.8010,
      longitud: -1.9720,
      superficieHa: 197,
      notas: 'Datos de ejemplo · superficie pública, centroide aproximado.',
    ));
    return true;
  }

  /// Siembra el **espacio real** (fincas + puntos de infraestructura) desde
  /// los CSV compilados (`espacio_generado.dart`) si la BD no tiene fincas.
  /// Es el seed que se entrega de serie a los testadores. Devuelve true si
  /// sembró. Cuando Zunbeltz aporte los puntos, se rellenan los CSV y se
  /// recompila con `dart run tool/compilar_espacio.dart`.
  Future<bool> sembrarEspacioRealSiVacia() async {
    if (fincasEspacio.isEmpty) return false;
    if ((await listarFincas()).isNotEmpty) return false;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final idPorFinca = <String, int>{};
    for (final f in fincasEspacio) {
      final id = await guardarFinca(Finca(
        nombre: f.nombre,
        latitud: f.latitud,
        longitud: f.longitud,
        superficieHa: f.superficieHa,
        recintosSigpac: f.recintosSigpac,
        notas: f.notas,
      ));
      idPorFinca[f.nombre] = id;
    }
    for (final p in puntosEspacio) {
      final fincaId = idPorFinca[p.finca];
      if (fincaId == null) continue;
      await guardarPunto(PuntoInfraestructura(
        fincaId: fincaId,
        tipo: p.tipo,
        nombre: p.nombre,
        latitud: p.latitud,
        longitud: p.longitud,
        estado: p.estado,
        notas: p.notas,
        fechaCreacionMs: ahora,
      ));
    }
    return true;
  }

  /// Carga un juego de **datos de demostración** (dos proyectos de test con
  /// producción, comercialización, validación de producto e ingresos/gastos
  /// con categorías e IVA) para ver la app con datos sin teclearlos. No hace
  /// nada si ya hay proyectos. Devuelve true si sembró.
  Future<bool> sembrarDemostracionSiVacia() async {
    if ((await listarProyectos()).isNotEmpty) return false;
    await sembrarFincasDemoSiVacia();
    final fincas = await listarFincas();
    final fincaId = fincas.isEmpty ? 0 : (fincas.first.id ?? 0);
    final ahora = DateTime.now();
    int hace(int dias) =>
        ahora.subtract(Duration(days: dias)).millisecondsSinceEpoch;
    final creado = ahora.millisecondsSinceEpoch;

    // ── Proyecto 1: quesería (rentable) ──
    final p1 = await guardarProyecto(ProyectoTest(
      nombre: 'Quesería de prueba',
      persona: 'Maite Etxeberria',
      actividad: 'Ovino de leche · quesería',
      fincaId: fincaId,
      fechaInicioMs: hace(150),
      fechaCreacionMs: creado,
    ));
    for (final r in [
      RegistroActividad(fincaId: fincaId, proyectoId: p1, tipo: 'alimentacion', cantidad: 1200, fechaMs: hace(120), lote: 'Rebaño A'),
      RegistroActividad(fincaId: fincaId, proyectoId: p1, tipo: 'paricion', cantidad: 18, fechaMs: hace(100)),
      RegistroActividad(fincaId: fincaId, proyectoId: p1, tipo: 'producto', cantidad: 320, fechaMs: hace(40)),
    ]) {
      await guardarRegistro(r);
    }
    for (final v in [
      RegistroComercializacion(proyectoId: p1, fechaMs: hace(60), producto: 'Queso curado', canal: 'directa', cantidad: 40, unidad: 'uds', precioUnitarioCentimos: 1200, ingresoCentimos: 48000, ivaPorcentaje: 10),
      RegistroComercializacion(proyectoId: p1, fechaMs: hace(30), producto: 'Queso curado', canal: 'mercado', cantidad: 55, unidad: 'uds', precioUnitarioCentimos: 1300, ingresoCentimos: 71500, ivaPorcentaje: 10),
      RegistroComercializacion(proyectoId: p1, fechaMs: hace(10), producto: 'Requesón', canal: 'tienda', cantidad: 30, unidad: 'uds', precioUnitarioCentimos: 450, ingresoCentimos: 13500, ivaPorcentaje: 4),
    ]) {
      await guardarComercializacion(v);
    }
    for (final val in [
      ValidacionProducto(proyectoId: p1, fechaMs: hace(70), descripcion: 'Curación a 60 días', resultado: 'validado', valoracion: 4),
      ValidacionProducto(proyectoId: p1, fechaMs: hace(20), descripcion: 'Formato cuña 250 g', resultado: 'ajustar', valoracion: 3),
    ]) {
      await guardarValidacion(val);
    }
    for (final g in [
      ApunteEconomico(fincaId: fincaId, proyectoId: p1, tipo: 'gasto', categoria: 'alimentacion', concepto: 'Pienso y forraje', importeCentimos: 42000, ivaPorcentaje: 10, fechaMs: hace(115)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p1, tipo: 'gasto', categoria: 'sanidad', concepto: 'Veterinario', importeCentimos: 9000, ivaPorcentaje: 21, fechaMs: hace(80)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p1, tipo: 'gasto', categoria: 'insumos', concepto: 'Cuajo y sal', importeCentimos: 6000, ivaPorcentaje: 21, fechaMs: hace(50)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p1, tipo: 'gasto', categoria: 'mano_obra', concepto: 'Jornales', importeCentimos: 30000, fechaMs: hace(25)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p1, tipo: 'ingreso', categoria: 'ayuda', concepto: 'Prima PAC / ecorégimen', importeCentimos: 28000, fechaMs: hace(90)),
    ]) {
      await guardarApunte(g);
    }

    // ── Proyecto 2: huerta (más ajustado) ──
    final p2 = await guardarProyecto(ProyectoTest(
      nombre: 'Huerta de prueba',
      persona: 'Iñaki Larrea',
      actividad: 'Horticultura ecológica',
      fincaId: fincaId,
      fechaInicioMs: hace(90),
      fechaCreacionMs: creado,
    ));
    await guardarRegistro(RegistroActividad(fincaId: fincaId, proyectoId: p2, tipo: 'producto', cantidad: 180, fechaMs: hace(20)));
    for (final v in [
      RegistroComercializacion(proyectoId: p2, fechaMs: hace(35), producto: 'Cesta de verdura', canal: 'directa', cantidad: 25, unidad: 'uds', precioUnitarioCentimos: 1500, ingresoCentimos: 37500, ivaPorcentaje: 4),
      RegistroComercializacion(proyectoId: p2, fechaMs: hace(7), producto: 'Tomate', canal: 'restauracion', cantidad: 60, unidad: 'kg', precioUnitarioCentimos: 250, ingresoCentimos: 15000, ivaPorcentaje: 4),
    ]) {
      await guardarComercializacion(v);
    }
    await guardarValidacion(ValidacionProducto(proyectoId: p2, fechaMs: hace(15), descripcion: 'Variedad de tomate local', resultado: 'validado', valoracion: 5));
    for (final g in [
      ApunteEconomico(fincaId: fincaId, proyectoId: p2, tipo: 'gasto', categoria: 'insumos', concepto: 'Semilla y plantel', importeCentimos: 12000, ivaPorcentaje: 10, fechaMs: hace(85)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p2, tipo: 'gasto', categoria: 'maquinaria', concepto: 'Gasoil motoazada', importeCentimos: 8000, ivaPorcentaje: 21, fechaMs: hace(40)),
      ApunteEconomico(fincaId: fincaId, proyectoId: p2, tipo: 'gasto', categoria: 'alquiler', concepto: 'Cesión de parcela', importeCentimos: 24000, fechaMs: hace(60)),
    ]) {
      await guardarApunte(g);
    }

    return true;
  }
}

/// Cláusula WHERE construida (texto + argumentos) o `null` si no hay filtros.
class _FiltroSql {
  _FiltroSql(this.where, this.args);

  final String? where;
  final List<Object?>? args;
}
