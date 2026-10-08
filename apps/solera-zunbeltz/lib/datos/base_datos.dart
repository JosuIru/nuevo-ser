import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/agenda.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/aviso_campo.dart';
import '../modelos/entrada_actividad.dart';
import '../modelos/constantes.dart' show estadoTareaPorDefecto;
import '../modelos/convenio.dart';
import '../modelos/finca.dart';
import '../modelos/peticion_tarea.dart';
import '../utiles/geodesia.dart';
import 'espacio_generado.dart';
import 'esquema_sincronizable.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/registro_actividad.dart';
import '../modelos/registro_comercializacion.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../modelos/validacion_producto.dart';
import '../modelos/zona_finca.dart';
import '../utiles/tarea_periodica.dart';
import '../utiles/uid.dart';

part 'base_datos_comunicacion.dart';
part 'base_datos_agenda.dart';
part 'base_datos_convenio.dart';
part 'base_datos_sync.dart';

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
/// v8 añade responsable y creadora por persona del espacio a las tareas.
/// v9 sincroniza todo el espacio: `uid` + `actualizado_ms` en todas las
/// tablas de [tablasSincronizables], lápidas de borrado, cursores y
/// actividad recibida; y crea las tablas de la economía del convenio
/// (presupuesto, fianza), el acompañamiento, las incidencias de
/// cumplimiento, las peticiones y los avisos de campo.
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

  /// Para tests de pantallas: hace que el singleton use [db] (p. ej. ffi en
  /// memoria) en vez de abrir el fichero del móvil.
  @visibleForTesting
  static void inyectarParaTests(Database db) => instancia._basedatos = db;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    // En web la BD vive en IndexedDB y la "ruta" es solo su nombre.
    final ruta = kIsWeb
        ? 'solera_zunbeltz.db'
        : path_lib.join((await getApplicationDocumentsDirectory()).path,
            'solera_zunbeltz.db');
    _basedatos = await openDatabase(
      ruta,
      version: versionEsquema,
      onConfigure: (db) async {
        // ON DELETE CASCADE / SET NULL requieren FKs activas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await crearEsquemaV1(db);
        await migrarDesde(db, 1);
      },
      onUpgrade: (db, anterior, actual) => migrarDesde(db, anterior),
    );
    return _basedatos!;
  }

  static const int versionEsquema = 10;

  /// Aplica en orden las migraciones posteriores a [anterior]. Lo usan la
  /// apertura de la BD (alta y subida de versión) y los tests.
  static Future<void> migrarDesde(Database db, int anterior) async {
    if (anterior < 2) await aplicarMigracionV2(db);
    if (anterior < 3) await aplicarMigracionV3(db);
    if (anterior < 4) await aplicarMigracionV4(db);
    if (anterior < 5) await aplicarMigracionV5(db);
    if (anterior < 6) await aplicarMigracionV6(db);
    if (anterior < 7) await aplicarMigracionV7(db);
    if (anterior < 8) await aplicarMigracionV8(db);
    if (anterior < 9) await aplicarMigracionV9(db);
    if (anterior < 10) await aplicarMigracionV10(db);
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
    await db
        .execute('ALTER TABLE tareas_mantenimiento ADD COLUMN zona_id INTEGER');
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

  /// Migración v8 → v9: sincronización de todo el espacio y tablas nuevas
  /// del convenio tester. Aditiva.
  @visibleForTesting
  static Future<void> aplicarMigracionV9(Database db) async {
    // Tablas nuevas. Todas con uid + actualizado_ms desde el principio.
    const columnasSync =
        "uid TEXT NOT NULL DEFAULT '', actualizado_ms INTEGER NOT NULL DEFAULT 0";
    const fkProyecto =
        'FOREIGN KEY (proyecto_id) REFERENCES proyectos_test(id) ON DELETE CASCADE';
    await db.execute('''
      CREATE TABLE partidas_presupuesto (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        proyecto_id INTEGER NOT NULL,
        categoria TEXT NOT NULL DEFAULT '',
        concepto TEXT NOT NULL DEFAULT '',
        asumido_por TEXT NOT NULL DEFAULT 'tester',
        es_amortizacion INTEGER NOT NULL DEFAULT 0,
        importe_centimos INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        $fkProyecto
      )
    ''');
    await db.execute('''
      CREATE TABLE movimientos_fianza (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        proyecto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'deposito',
        importe_centimos INTEGER NOT NULL DEFAULT 0,
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        $fkProyecto
      )
    ''');
    await db.execute('''
      CREATE TABLE acompanamientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        proyecto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'reunion',
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        descripcion TEXT NOT NULL DEFAULT '',
        asistencia TEXT NOT NULL DEFAULT 'propuesta',
        horas REAL,
        notas TEXT NOT NULL DEFAULT '',
        $fkProyecto
      )
    ''');
    await db.execute('''
      CREATE TABLE incidencias_cumplimiento (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        proyecto_id INTEGER NOT NULL,
        nivel TEXT NOT NULL DEFAULT 'leve',
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        descripcion TEXT NOT NULL DEFAULT '',
        retencion_centimos INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        $fkProyecto
      )
    ''');
    await db.execute('''
      CREATE TABLE peticiones (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        autor_uid TEXT NOT NULL DEFAULT '',
        finca_id INTEGER,
        punto_id INTEGER,
        titulo TEXT NOT NULL DEFAULT '',
        descripcion TEXT NOT NULL DEFAULT '',
        urgente INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        respuesta TEXT NOT NULL DEFAULT '',
        tarea_uid TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL,
        FOREIGN KEY (punto_id) REFERENCES puntos_infraestructura(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE avisos (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        autor_uid TEXT NOT NULL DEFAULT '',
        finca_id INTEGER,
        punto_id INTEGER,
        categoria TEXT NOT NULL DEFAULT 'instalaciones',
        gravedad TEXT NOT NULL DEFAULT 'aviso',
        titulo TEXT NOT NULL DEFAULT '',
        descripcion TEXT NOT NULL DEFAULT '',
        estado TEXT NOT NULL DEFAULT 'abierto',
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL,
        FOREIGN KEY (punto_id) REFERENCES puntos_infraestructura(id) ON DELETE SET NULL
      )
    ''');

    // Columnas nuevas del proyecto (convenio art. 7-8) y de los apuntes.
    for (final sentencia in [
      "ALTER TABLE proyectos_test ADD COLUMN persona_uid TEXT NOT NULL DEFAULT ''",
      "ALTER TABLE proyectos_test ADD COLUMN estado TEXT NOT NULL DEFAULT 'abierto'",
      'ALTER TABLE proyectos_test ADD COLUMN cerrado_ms INTEGER',
      'ALTER TABLE proyectos_test ADD COLUMN porcentaje_beneficio_zunbeltz INTEGER NOT NULL DEFAULT 25',
      'ALTER TABLE proyectos_test ADD COLUMN porcentaje_perdida_zunbeltz INTEGER NOT NULL DEFAULT 50',
      'ALTER TABLE proyectos_test ADD COLUMN valoracion_zunbeltz INTEGER',
      'ALTER TABLE proyectos_test ADD COLUMN valoracion_tester INTEGER',
      "ALTER TABLE apuntes_economicos ADD COLUMN asumido_por TEXT NOT NULL DEFAULT 'tester'",
      'ALTER TABLE apuntes_economicos ADD COLUMN es_amortizacion INTEGER NOT NULL DEFAULT 0',
    ]) {
      await db.execute(sentencia);
    }

    // uid + actualizado_ms en las tablas que ya existían. Las filas previas
    // quedan "pendientes de subir" (marca = ahora) para la primera sync.
    final ahora = DateTime.now().millisecondsSinceEpoch;
    for (final tabla in const [
      'fincas',
      'zonas_finca',
      'puntos_infraestructura',
      'proyectos_test',
      'registros_actividad',
      'apuntes_economicos',
      'registros_comercializacion',
      'validaciones_producto',
    ]) {
      await db.execute(
          "ALTER TABLE $tabla ADD COLUMN uid TEXT NOT NULL DEFAULT ''");
      await db.execute(
          'ALTER TABLE $tabla ADD COLUMN actualizado_ms INTEGER NOT NULL DEFAULT 0');
    }
    // Solo las tablas que existen en la v9: las de versiones posteriores se
    // crean ya con uid en su propia migración.
    const tablasHastaV9 = {
      'fincas',
      'zonas_finca',
      'puntos_infraestructura',
      'proyectos_test',
      'registros_actividad',
      'apuntes_economicos',
      'registros_comercializacion',
      'validaciones_producto',
      'partidas_presupuesto',
      'movimientos_fianza',
      'acompanamientos',
      'incidencias_cumplimiento',
      'peticiones',
      'avisos',
    };
    final uidsFijosUsados = <String>{};
    for (final tabla in tablasSincronizables
        .where((descriptor) => tablasHastaV9.contains(descriptor.tabla))) {
      final columnas = tabla.tabla == 'fincas' ? ['id', 'nombre'] : ['id'];
      for (final fila in await db.query(tabla.tabla,
          columns: columnas, orderBy: 'id')) {
        var uidFijo = tabla.tabla == 'fincas'
            ? uidsFincasSembradas[fila['nombre']]
            : null;
        // Dos fincas con el mismo nombre sembrado (posible antes de la v9)
        // no pueden compartir uid: el índice único fallaría y la BD no
        // volvería a abrir. Solo la primera se queda el fijo.
        if (uidFijo != null && !uidsFijosUsados.add(uidFijo)) uidFijo = null;
        await db.update(
          tabla.tabla,
          {
            'uid': uidFijo ?? generarUid(),
            // Las sembradas existen igual en todos los móviles: con marca
            // mínima, la versión del servidor (quizá ya corregida) gana
            // siempre a la copia de un móvil que se actualiza tarde.
            'actualizado_ms': uidFijo != null ? marcaSembrado : ahora,
          },
          where: 'id = ?',
          whereArgs: [fila['id']],
        );
      }
      await db.execute(
          'CREATE UNIQUE INDEX idx_${tabla.tabla}_uid ON ${tabla.tabla}(uid)');
    }

    // Lápidas de lo borrado en este móvil, pendientes de subir.
    await db.execute('''
      CREATE TABLE borrados_sync (
        tipo TEXT NOT NULL,
        uid TEXT NOT NULL,
        borrado_ms INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (tipo, uid)
      )
    ''');
    // Cursores de sincronización (revisión, actividad, última subida…).
    await db.execute('''
      CREATE TABLE estado_sync (
        clave TEXT PRIMARY KEY,
        valor INTEGER NOT NULL DEFAULT 0
      )
    ''');
    // Registro de actividad del espacio recibido del servidor (solo lo
    // recibe coordinación). Es de solo lectura: no se sube.
    await db.execute('''
      CREATE TABLE actividad_espacio (
        id INTEGER PRIMARY KEY,
        momento_ms INTEGER NOT NULL DEFAULT 0,
        persona_uid TEXT NOT NULL DEFAULT '',
        persona_nombre TEXT NOT NULL DEFAULT '',
        accion TEXT NOT NULL DEFAULT '',
        tipo TEXT NOT NULL DEFAULT '',
        uid TEXT NOT NULL DEFAULT '',
        etiqueta TEXT NOT NULL DEFAULT '',
        contexto TEXT NOT NULL DEFAULT '',
        detalle TEXT NOT NULL DEFAULT '',
        origen TEXT NOT NULL DEFAULT 'app'
      )
    ''');
  }

  /// Migración v9 → v10: agenda de contactos, rendimientos de referencia y
  /// escenarios de la calculadora de transformación. Aditiva.
  @visibleForTesting
  static Future<void> aplicarMigracionV10(Database db) async {
    const columnasSync =
        "uid TEXT NOT NULL DEFAULT '', actualizado_ms INTEGER NOT NULL DEFAULT 0";
    await db.execute('''
      CREATE TABLE contactos (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        autor_uid TEXT NOT NULL DEFAULT '',
        nombre TEXT NOT NULL DEFAULT '',
        tipo TEXT NOT NULL DEFAULT 'otro',
        telefono TEXT NOT NULL DEFAULT '',
        correo TEXT NOT NULL DEFAULT '',
        localidad TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE rendimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        nombre TEXT NOT NULL DEFAULT '',
        rendimiento_canal REAL NOT NULL DEFAULT 0,
        rendimiento_producto REAL NOT NULL DEFAULT 100,
        fuente TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE escenarios_transformacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT, $columnasSync,
        proyecto_id INTEGER NOT NULL,
        nombre TEXT NOT NULL DEFAULT '',
        peso_vivo_kg REAL NOT NULL DEFAULT 0,
        animales INTEGER NOT NULL DEFAULT 1,
        rendimiento_canal REAL NOT NULL DEFAULT 0,
        rendimiento_producto REAL NOT NULL DEFAULT 100,
        precio_kg_centimos INTEGER NOT NULL DEFAULT 0,
        coste_sacrificio_centimos INTEGER NOT NULL DEFAULT 0,
        coste_transformacion_kg_centimos INTEGER NOT NULL DEFAULT 0,
        otros_costes_centimos INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT '',
        fecha_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (proyecto_id) REFERENCES proyectos_test(id) ON DELETE CASCADE
      )
    ''');
    for (final tabla in const [
      'contactos',
      'rendimientos',
      'escenarios_transformacion',
    ]) {
      await db.execute('CREATE UNIQUE INDEX idx_${tabla}_uid ON $tabla(uid)');
    }
  }

  // ─── Fincas ─────────────────────────────────────────────

  /// [uid] fijo solo para las fincas sembradas (ver [uidsFincasSembradas]).
  Future<int> guardarFinca(Finca finca, {String? uid}) async {
    final db = await basedatos;
    return _insertarSincronizable(db, 'fincas', finca.toMap()..remove('id'),
        uid: uid);
  }

  Future<void> actualizarFinca(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('fincas', id, cambios);

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

  /// Borra la finca con sus zonas, puntos, tareas y seguimiento (lápidas
  /// incluidas, para que el borrado llegue al resto de móviles).
  Future<void> borrarFinca(int id) => _borrarSincronizable('fincas', id);

  // ─── Puntos de infraestructura ──────────────────────────

  Future<int> guardarPunto(PuntoInfraestructura punto, {String? uid}) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'puntos_infraestructura', punto.toMap()..remove('id'),
        uid: uid);
  }

  Future<void> actualizarPunto(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('puntos_infraestructura', id, cambios);

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

  Future<void> borrarPunto(int id) =>
      _borrarSincronizable('puntos_infraestructura', id);

  // ─── Zonas (recintos dibujados) ─────────────────────────

  Future<int> guardarZona(ZonaFinca zona) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'zonas_finca', zona.toMap()..remove('id'));
  }

  Future<void> actualizarZona(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('zonas_finca', id, cambios);

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
    final filas = await db.query('zonas_finca',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ZonaFinca.fromMap(filas.first);
  }

  /// Borra la zona y desancla sus tareas, que se conservan como tareas de
  /// finca. Equivale al ON DELETE SET NULL que SQLite no deja añadir por
  /// ALTER TABLE, y va en transacción para no dejar tareas apuntando a una
  /// zona que ya no existe.
  Future<void> borrarZona(int id) => _borrarSincronizable('zonas_finca', id);

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
    final ahora = DateTime.now();
    final fila = tarea.toMap()..remove('id');
    // Sin marca de tiempo, la sincronización la tomaría por antigua y podría
    // retirarla antes de haberla subido.
    if (tarea.actualizadoMs == 0) {
      fila['actualizado_ms'] = ahora.millisecondsSinceEpoch;
    }
    return db.transaction((txn) async {
      final id = await txn.insert('tareas_mantenimiento', fila);
      // Dada de alta ya hecha: también toca la siguiente.
      if (tarea.estado == 'hecha') {
        await _insertarSiguientePeriodica(txn, tarea, ahora);
      }
      return id;
    });
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

  /// Borra la tarea y deja lápida para pedir al servidor que la borre
  /// también (solo lo acepta de quien puede editar cualquier tarea).
  Future<void> borrarTarea(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      final filas = await txn.query('tareas_mantenimiento',
          columns: ['uid'], where: 'id = ?', whereArgs: [id], limit: 1);
      if (filas.isNotEmpty) {
        await txn.insert(
          'borrados_sync',
          {
            'tipo': 'tarea',
            'uid': filas.first['uid'],
            'borrado_ms': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await txn
          .delete('tareas_mantenimiento', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Borra una tarea sin lápida: la ha retirado o rechazado el servidor.
  Future<void> borrarTareaSinLapida(int id) async {
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
    return db.transaction<int?>((txn) async {
      final filas = await txn.query('tareas_mantenimiento',
          where: 'id = ?', whereArgs: [id], limit: 1);
      if (filas.isEmpty) return null;
      final tarea = TareaMantenimiento.fromMap(filas.first);
      final ahora = DateTime.now();
      // Solo cuenta el primer cierre: un doble toque no genera dos.
      final cerradas = await txn.update('tareas_mantenimiento',
          {'estado': 'hecha', 'actualizado_ms': ahora.millisecondsSinceEpoch},
          where: "id = ? AND estado != 'hecha'", whereArgs: [id]);
      if (cerradas == 0) return null;
      return _insertarSiguientePeriodica(txn, tarea, ahora);
    });
  }

  /// Inserta la siguiente instancia de una tarea periódica recién cerrada,
  /// salvo que ya exista (la generó otro móvil o el servidor). Devuelve su
  /// id, o `null` si no toca.
  Future<int?> _insertarSiguientePeriodica(
      DatabaseExecutor db, TareaMantenimiento tarea, DateTime ahora) async {
    if (!tarea.esRecurrente) return null;
    final uidSiguiente = uidSiguientePeriodica(tarea.uid);
    final existentes = await db.query('tareas_mantenimiento',
        columns: ['id'], where: 'uid = ?', whereArgs: [uidSiguiente], limit: 1);
    if (existentes.isNotEmpty) return null;
    final siguiente = TareaMantenimiento(
      uid: uidSiguiente,
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
      fechaObjetivoMs: fechaSiguientePeriodica(
              fechaObjetivoMs: tarea.fechaObjetivoMs,
              dias: tarea.recurrenciaDias!,
              ahora: ahora)
          .millisecondsSinceEpoch,
      fechaCreacionMs: ahora.millisecondsSinceEpoch,
      recurrenciaDias: tarea.recurrenciaDias,
      // La misma instancia la genera también el servidor al aceptar el
      // cierre (mismo uid): con marca mínima, la copia de este móvil nunca
      // pisa la del servidor ni cuenta como un cambio rechazado (una tester
      // no puede crear tareas). Si el servidor no la tiene, se sube igual.
      actualizadoMs: 1,
    );
    return db.insert('tareas_mantenimiento', siguiente.toMap()..remove('id'));
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
  ///
  /// Con [anclajeDelServidor] el punto y la zona de [remota] (ya resueltos a
  /// ids locales por `uid`) mandan; sin él (servidor anterior a la v0.3,
  /// que no los manda) se conserva el anclaje local.
  Future<void> upsertTareaRemota(TareaMantenimiento remota,
      {bool forzar = false, bool anclajeDelServidor = false}) async {
    final db = await basedatos;
    final existente = await db.query('tareas_mantenimiento',
        where: 'uid = ?', whereArgs: [remota.uid], limit: 1);
    final mapa = remota.toMap()..remove('id');
    if (existente.isEmpty) {
      await db.insert('tareas_mantenimiento', mapa);
      return;
    }
    final local = TareaMantenimiento.fromMap(existente.first);
    if (!forzar && remota.actualizadoMs <= local.actualizadoMs) return;
    mapa.remove('uid');
    if (!anclajeDelServidor) {
      mapa
        ..['punto_id'] = local.puntoId
        ..['zona_id'] = local.zonaId;
    }
    // Las fotos no viajan: se conservan las de este móvil.
    mapa
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
    return _insertarSincronizable(
        db, 'registros_actividad', registro.toMap()..remove('id'));
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

  Future<void> borrarRegistro(int id) =>
      _borrarSincronizable('registros_actividad', id);

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
    return _insertarSincronizable(
        db, 'apuntes_economicos', apunte.toMap()..remove('id'));
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

  Future<void> borrarApunte(int id) =>
      _borrarSincronizable('apuntes_economicos', id);

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
    return _insertarSincronizable(
        db, 'proyectos_test', proyecto.toMap()..remove('id'));
  }

  Future<void> actualizarProyecto(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('proyectos_test', id, cambios);

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

  /// Borra el proyecto con todo su seguimiento.
  Future<void> borrarProyecto(int id) =>
      _borrarSincronizable('proyectos_test', id);

  // ─── Comercialización ───────────────────────────────────

  Future<int> guardarComercializacion(RegistroComercializacion registro) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'registros_comercializacion', registro.toMap()..remove('id'));
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

  Future<void> borrarComercializacion(int id) =>
      _borrarSincronizable('registros_comercializacion', id);

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
    return _insertarSincronizable(
        db, 'validaciones_producto', validacion.toMap()..remove('id'));
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

  Future<void> borrarValidacion(int id) =>
      _borrarSincronizable('validaciones_producto', id);

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
    await guardarFinca(
        Finca(
          nombre: 'Zunbeltz',
          latitud: 42.7872,
          longitud: -1.9450,
          superficieHa: 231,
          notas: 'Datos de ejemplo · superficie pública, centroide aproximado.',
        ),
        uid: uidsFincasSembradas['Zunbeltz']);
    await guardarFinca(
        Finca(
          nombre: 'La Planilla',
          latitud: 42.8010,
          longitud: -1.9720,
          superficieHa: 197,
          notas: 'Datos de ejemplo · superficie pública, centroide aproximado.',
        ),
        uid: uidsFincasSembradas['La Planilla']);
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
    // Ya sincronizado: las fincas las manda el servidor. Sembrarlas aquí
    // dejaría unas que nunca suben (marca mínima) y que el servidor no
    // conoce.
    if (await leerEstadoSync('revision') > 0) return false;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final idPorFinca = <String, int>{};
    for (final f in fincasEspacio) {
      final id = await guardarFinca(
          Finca(
            nombre: f.nombre,
            latitud: f.latitud,
            longitud: f.longitud,
            superficieHa: f.superficieHa,
            recintosSigpac: f.recintosSigpac,
            notas: f.notas,
          ),
          uid: uidSembrado('finca', f.nombre));
      idPorFinca[f.nombre] = id;
    }
    final uidsPuntos = <String>[];
    for (final p in puntosEspacio) {
      final fincaId = idPorFinca[p.finca];
      if (fincaId == null) continue;
      await guardarPunto(
          PuntoInfraestructura(
            fincaId: fincaId,
            tipo: p.tipo,
            nombre: p.nombre,
            latitud: p.latitud,
            longitud: p.longitud,
            estado: p.estado,
            notas: p.notas,
            fechaCreacionMs: ahora,
          ),
          uid: uidSembrado('punto', '${p.finca} ${p.nombre}'));
      uidsPuntos.add(uidSembrado('punto', '${p.finca} ${p.nombre}'));
    }
    // Lo sembrado es igual en todos los móviles: con marca mínima sube si el
    // servidor no lo tiene, pero nunca pisa la versión del servidor (quizá
    // ya corregida por coordinación) ni resucita una finca borrada allí.
    final db = await basedatos;
    final uidsFincas = [
      for (final f in fincasEspacio) uidSembrado('finca', f.nombre),
    ];
    await db.update('fincas', {'actualizado_ms': marcaSembrado},
        where: 'uid IN (${List.filled(uidsFincas.length, '?').join(',')})',
        whereArgs: uidsFincas);
    if (uidsPuntos.isNotEmpty) {
      await db.update('puntos_infraestructura', {'actualizado_ms': marcaSembrado},
          where: 'uid IN (${List.filled(uidsPuntos.length, '?').join(',')})',
          whereArgs: uidsPuntos);
    }
    return true;
  }

  /// `actualizado_ms` de lo sembrado: más viejo que cualquier cambio real,
  /// pero mayor que 0 para que la primera sincronización lo suba.
  static const marcaSembrado = 1;

  /// Carga un juego de **datos de demostración** (dos proyectos de test con
  /// producción, comercialización, validación de producto e ingresos/gastos
  /// con categorías e IVA) para ver la app con datos sin teclearlos. No hace
  /// nada si ya hay proyectos. Devuelve true si sembró.
  Future<bool> sembrarDemostracionSiVacia() async {
    await sembrarFincasDemoSiVacia();
    final fincas = await listarFincas();
    final ahora = DateTime.now();
    // Puntos y tareas van por separado (su propia comprobación de vacío)
    // para que una BD con proyectos pero sin mapa también los reciba.
    final sembroInfraestructura =
        await _sembrarInfraestructuraDemo(fincas, ahora);
    final sembroComunicacion = await _sembrarComunicacionDemo(fincas, ahora);
    if ((await listarProyectos()).isNotEmpty) {
      return sembroInfraestructura || sembroComunicacion;
    }
    final fincaId = fincas.isEmpty ? 0 : (fincas.first.id ?? 0);
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
      RegistroActividad(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'alimentacion',
          cantidad: 1200,
          fechaMs: hace(120),
          lote: 'Rebaño A'),
      RegistroActividad(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'paricion',
          cantidad: 18,
          fechaMs: hace(100)),
      RegistroActividad(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'producto',
          cantidad: 320,
          fechaMs: hace(40)),
    ]) {
      await guardarRegistro(r);
    }
    for (final v in [
      RegistroComercializacion(
          proyectoId: p1,
          fechaMs: hace(60),
          producto: 'Queso curado',
          canal: 'directa',
          cantidad: 40,
          unidad: 'uds',
          precioUnitarioCentimos: 1200,
          ingresoCentimos: 48000,
          ivaPorcentaje: 10),
      RegistroComercializacion(
          proyectoId: p1,
          fechaMs: hace(30),
          producto: 'Queso curado',
          canal: 'mercado',
          cantidad: 55,
          unidad: 'uds',
          precioUnitarioCentimos: 1300,
          ingresoCentimos: 71500,
          ivaPorcentaje: 10),
      RegistroComercializacion(
          proyectoId: p1,
          fechaMs: hace(10),
          producto: 'Requesón',
          canal: 'tienda',
          cantidad: 30,
          unidad: 'uds',
          precioUnitarioCentimos: 450,
          ingresoCentimos: 13500,
          ivaPorcentaje: 4),
    ]) {
      await guardarComercializacion(v);
    }
    for (final val in [
      ValidacionProducto(
          proyectoId: p1,
          fechaMs: hace(70),
          descripcion: 'Curación a 60 días',
          resultado: 'validado',
          valoracion: 4),
      ValidacionProducto(
          proyectoId: p1,
          fechaMs: hace(20),
          descripcion: 'Formato cuña 250 g',
          resultado: 'ajustar',
          valoracion: 3),
    ]) {
      await guardarValidacion(val);
    }
    for (final g in [
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'gasto',
          categoria: 'alimentacion',
          concepto: 'Pienso y forraje',
          importeCentimos: 42000,
          ivaPorcentaje: 10,
          fechaMs: hace(115)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'gasto',
          categoria: 'sanidad',
          concepto: 'Veterinario',
          importeCentimos: 9000,
          ivaPorcentaje: 21,
          fechaMs: hace(80)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'gasto',
          categoria: 'insumos',
          concepto: 'Cuajo y sal',
          importeCentimos: 6000,
          ivaPorcentaje: 21,
          fechaMs: hace(50)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'gasto',
          categoria: 'mano_obra',
          concepto: 'Jornales',
          importeCentimos: 30000,
          fechaMs: hace(25)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p1,
          tipo: 'ingreso',
          categoria: 'ayuda',
          concepto: 'Prima PAC / ecorégimen',
          importeCentimos: 28000,
          fechaMs: hace(90)),
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
    await guardarRegistro(RegistroActividad(
        fincaId: fincaId,
        proyectoId: p2,
        tipo: 'producto',
        cantidad: 180,
        fechaMs: hace(20)));
    for (final v in [
      RegistroComercializacion(
          proyectoId: p2,
          fechaMs: hace(35),
          producto: 'Cesta de verdura',
          canal: 'directa',
          cantidad: 25,
          unidad: 'uds',
          precioUnitarioCentimos: 1500,
          ingresoCentimos: 37500,
          ivaPorcentaje: 4),
      RegistroComercializacion(
          proyectoId: p2,
          fechaMs: hace(7),
          producto: 'Tomate',
          canal: 'restauracion',
          cantidad: 60,
          unidad: 'kg',
          precioUnitarioCentimos: 250,
          ingresoCentimos: 15000,
          ivaPorcentaje: 4),
    ]) {
      await guardarComercializacion(v);
    }
    await guardarValidacion(ValidacionProducto(
        proyectoId: p2,
        fechaMs: hace(15),
        descripcion: 'Variedad de tomate local',
        resultado: 'validado',
        valoracion: 5));
    for (final g in [
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p2,
          tipo: 'gasto',
          categoria: 'insumos',
          concepto: 'Semilla y plantel',
          importeCentimos: 12000,
          ivaPorcentaje: 10,
          fechaMs: hace(85)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p2,
          tipo: 'gasto',
          categoria: 'maquinaria',
          concepto: 'Gasoil motoazada',
          importeCentimos: 8000,
          ivaPorcentaje: 21,
          fechaMs: hace(40)),
      ApunteEconomico(
          fincaId: fincaId,
          proyectoId: p2,
          tipo: 'gasto',
          categoria: 'alquiler',
          concepto: 'Cesión de parcela',
          importeCentimos: 24000,
          fechaMs: hace(60)),
    ]) {
      await guardarApunte(g);
    }

    await _sembrarConvenioDemo(p1, ahora);
    return true;
  }

  /// Avisos y una petición de ejemplo para la bandeja de Hoy. No hace nada si
  /// ya hay avisos. Devuelve true si sembró.
  Future<bool> _sembrarComunicacionDemo(
      List<Finca> fincas, DateTime ahora) async {
    if ((await listarAvisos()).isNotEmpty) return false;
    final fincaId = fincas.isEmpty ? null : fincas.first.id;
    int hace(int horas) =>
        ahora.subtract(Duration(hours: horas)).millisecondsSinceEpoch;
    await guardarAviso(AvisoCampo(
        fincaId: fincaId,
        categoria: categoriaAvisoGanado,
        gravedad: gravedadAlarma,
        titulo: 'Oveja coja en el lote de la borda',
        descripcion: 'Ejemplo de demostración.',
        fechaMs: hace(2)));
    await guardarAviso(AvisoCampo(
        fincaId: fincaId,
        categoria: categoriaAvisoInstalaciones,
        titulo: 'Gotea el abrevadero de la borda',
        descripcion: 'Ejemplo de demostración.',
        fechaMs: hace(20)));
    await guardarAviso(AvisoCampo(
        categoria: categoriaAvisoNoticias,
        titulo: 'Feria de ganado: inscripción abierta',
        descripcion: 'Ejemplo de demostración.',
        fechaMs: hace(30)));
    await guardarPeticion(PeticionTarea(
        fincaId: fincaId,
        titulo: 'Hace falta pienso para la semana que viene',
        urgente: true,
        fechaCreacionMs: hace(5)));
    return true;
  }

  /// Presupuesto, fianza y acompañamiento de ejemplo para un proyecto.
  Future<void> _sembrarConvenioDemo(int proyectoId, DateTime ahora) async {
    int hace(int dias) =>
        ahora.subtract(Duration(days: dias)).millisecondsSinceEpoch;
    for (final (categoria, asumidoPor, euros, amortizacion) in const [
      ('ganado', 'tester', 3000, false),
      ('alimentacion', 'tester', 1800, false),
      ('sanidad', 'tester', 400, false),
      ('infraestructuras', 'zunbeltz', 6000, true),
      ('transformacion', 'zunbeltz', 2500, false),
    ]) {
      await guardarPartidaPresupuesto(PartidaPresupuesto(
          proyectoId: proyectoId,
          categoria: categoria,
          asumidoPor: asumidoPor,
          esAmortizacion: amortizacion,
          importeCentimos: euros * 100));
    }
    await guardarMovimientoFianza(MovimientoFianza(
        proyectoId: proyectoId, importeCentimos: 85000, fechaMs: hace(150)));
    for (final (tipo, dias, asistencia) in const [
      ('formacion', 140, 'asistida'),
      ('reunion', 120, 'asistida'),
      ('reunion', 90, 'asistida'),
      ('visita_finca', 100, 'asistida'),
      ('asesoramiento', 60, 'asistida'),
      ('mercado', 30, 'no_asistida'),
    ]) {
      await guardarAcompanamiento(Acompanamiento(
          proyectoId: proyectoId,
          tipo: tipo,
          asistencia: asistencia,
          fechaMs: hace(dias)));
    }
  }

  /// Puntos y tareas **de ejemplo** alrededor del centroide de cada finca,
  /// para que el mapa, el tablero y la pantalla Hoy no salgan vacíos en la
  /// demostración. No son el inventario real (BLOQUEOS A4): las notas lo
  /// dicen. No hace nada si ya hay puntos. Devuelve true si sembró.
  Future<bool> _sembrarInfraestructuraDemo(
      List<Finca> fincas, DateTime ahora) async {
    if ((await listarPuntos()).isNotEmpty) return false;
    const notaEjemplo = 'Ejemplo de demostración — no es el inventario real.';
    final creado = ahora.millisecondsSinceEpoch;
    int enDias(int dias) =>
        ahora.add(Duration(days: dias)).millisecondsSinceEpoch;

    // (tipo, nombre, desplazamiento lat, desplazamiento long, estado)
    const puntosPorFinca = [
      [
        ('abrevadero', 'Abrevadero de la borda', 0.0030, -0.0040, 'operativo'),
        ('manga', 'Manga de manejo', -0.0020, 0.0025, 'revisar'),
        ('cierre', 'Cierre del cercado norte', 0.0055, 0.0010, 'averiado'),
        ('almacen', 'Almacén de pienso', -0.0008, -0.0012, 'operativo'),
      ],
      [
        ('balsa', 'Balsa', 0.0025, 0.0035, 'operativo'),
        ('refugio', 'Refugio', -0.0030, -0.0020, 'operativo'),
      ],
    ];
    final idsPunto = <String, int>{};
    for (var indice = 0;
        indice < fincas.length && indice < puntosPorFinca.length;
        indice++) {
      final finca = fincas[indice];
      if (finca.id == null || finca.latitud == null || finca.longitud == null) {
        continue;
      }
      for (final (tipo, nombre, desplazamientoLat, desplazamientoLong, estado)
          in puntosPorFinca[indice]) {
        idsPunto[nombre] = await guardarPunto(PuntoInfraestructura(
          fincaId: finca.id!,
          tipo: tipo,
          nombre: nombre,
          latitud: finca.latitud! + desplazamientoLat,
          longitud: finca.longitud! + desplazamientoLong,
          estado: estado,
          notas: notaEjemplo,
          fechaCreacionMs: creado,
        ));
      }
    }
    if (fincas.isEmpty || fincas.first.id == null) return idsPunto.isNotEmpty;
    final fincaPrincipal = fincas.first.id!;

    for (final tarea in [
      TareaMantenimiento(
          fincaId: fincaPrincipal,
          puntoId: idsPunto['Cierre del cercado norte'],
          titulo: 'Reparar alambrada caída',
          descripcion: 'Dos postes rotos tras el viento.',
          prioridad: 'alta',
          fechaObjetivoMs: enDias(-2),
          fechaCreacionMs: creado),
      TareaMantenimiento(
          fincaId: fincaPrincipal,
          puntoId: idsPunto['Almacén de pienso'],
          titulo: 'Comprar pienso',
          prioridad: 'alta',
          fechaObjetivoMs: enDias(1),
          fechaCreacionMs: creado),
      TareaMantenimiento(
          fincaId: fincaPrincipal,
          puntoId: idsPunto['Abrevadero de la borda'],
          titulo: 'Limpiar abrevadero',
          prioridad: 'media',
          fechaObjetivoMs: enDias(3),
          recurrenciaDias: 14,
          fechaCreacionMs: creado),
      TareaMantenimiento(
          fincaId: fincaPrincipal,
          puntoId: idsPunto['Manga de manejo'],
          titulo: 'Revisar cancela de la manga',
          estado: 'en_curso',
          fechaObjetivoMs: enDias(5),
          fechaCreacionMs: creado),
      TareaMantenimiento(
          fincaId: fincaPrincipal,
          titulo: 'Inscripción en la feria de ganado',
          descripcion: 'Plazo de inscripción.',
          prioridad: 'media',
          fechaObjetivoMs: enDias(10),
          fechaCreacionMs: creado),
    ]) {
      await guardarTarea(tarea);
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
