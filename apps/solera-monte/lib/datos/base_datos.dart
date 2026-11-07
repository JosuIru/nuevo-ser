import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/actuacion_plan.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/arbol_singular.dart';
import '../modelos/ejecucion.dart';
import '../modelos/incendios.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosMonte = 'solera_monte.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaMonte = 1;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaMonteV1 = [
  '''CREATE TABLE montes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL DEFAULT '',
    titular TEXT NOT NULL DEFAULT '',
    nif TEXT NOT NULL DEFAULT '',
    figura TEXT NOT NULL DEFAULT 'particular',
    comunidad_autonoma TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    numero_catalogo TEXT NOT NULL DEFAULT '',
    instrumento_gestion TEXT NOT NULL DEFAULT 'ninguno',
    referencia_instrumento TEXT NOT NULL DEFAULT '',
    fin_vigencia_instrumento_ms INTEGER,
    certificacion TEXT NOT NULL DEFAULT 'ninguna',
    codigo_certificado TEXT NOT NULL DEFAULT '',
    inicio_epoca_peligro_mes INTEGER,
    inicio_epoca_peligro_dia INTEGER,
    tecnico_forestal TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE rodales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL DEFAULT '',
    especie_principal_id TEXT NOT NULL,
    especies_secundarias TEXT NOT NULL DEFAULT '',
    anyo_origen INTEGER,
    estado_masa TEXT NOT NULL DEFAULT 'fustal',
    superficie_declarada_ha REAL,
    contorno TEXT NOT NULL DEFAULT '[]',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE actuaciones_plan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE RESTRICT,
    anyo_previsto INTEGER NOT NULL,
    tipo TEXT NOT NULL,
    superficie_prevista_ha REAL,
    volumen_previsto_m3 REAL,
    descripcion TEXT NOT NULL DEFAULT '',
    cancelada INTEGER NOT NULL DEFAULT 0
  )''',
  '''CREATE TABLE ejecuciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    actuacion_plan_id INTEGER
      REFERENCES actuaciones_plan(id) ON DELETE SET NULL,
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    tipo TEXT NOT NULL,
    superficie_ha REAL,
    ejecutor TEXT NOT NULL DEFAULT '',
    completa INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE aprovechamientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    campanya INTEGER NOT NULL,
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE RESTRICT,
    tipo TEXT NOT NULL,
    fecha_inicio_ms INTEGER NOT NULL,
    fecha_fin_ms INTEGER,
    cantidad_prevista REAL,
    cantidad REAL NOT NULL DEFAULT 0,
    unidad TEXT NOT NULL DEFAULT 'm3',
    modalidad TEXT NOT NULL DEFAULT 'uso_propio',
    adjudicatario TEXT NOT NULL DEFAULT '',
    tramite TEXT NOT NULL DEFAULT 'pendiente',
    referencia_tramite TEXT NOT NULL DEFAULT '',
    comercializado INTEGER NOT NULL DEFAULT 0,
    fecha_comunicacion_cuantia_ms INTEGER,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE sorteos_lena (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    campanya INTEGER NOT NULL,
    nombre TEXT NOT NULL DEFAULT '',
    participantes_json TEXT NOT NULL DEFAULT '[]',
    semilla TEXT NOT NULL DEFAULT '',
    origen_semilla TEXT NOT NULL DEFAULT '',
    fecha_cierre_lista_ms INTEGER,
    fecha_sorteo_ms INTEGER,
    huella_participantes TEXT NOT NULL DEFAULT '',
    realizado INTEGER NOT NULL DEFAULT 0,
    aprovechamiento_id INTEGER
      REFERENCES aprovechamientos(id) ON DELETE SET NULL,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE lotes_lena (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sorteo_id INTEGER NOT NULL REFERENCES sorteos_lena(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL,
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE RESTRICT,
    cantidad REAL,
    unidad TEXT NOT NULL DEFAULT 'estereos',
    descripcion TEXT NOT NULL DEFAULT '',
    adjudicatario TEXT NOT NULL DEFAULT '',
    UNIQUE (sorteo_id, numero)
  )''',
  '''CREATE TABLE infraestructuras_incendios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    latitud REAL,
    longitud REAL,
    traza TEXT NOT NULL DEFAULT '[]',
    longitud_m REAL,
    ancho_m REAL,
    capacidad_m3 REAL,
    activa INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE revisiones_incendios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    infraestructura_id INTEGER NOT NULL
      REFERENCES infraestructuras_incendios(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    estado TEXT NOT NULL DEFAULT 'correcto',
    trabajos_necesarios TEXT NOT NULL DEFAULT '',
    revisor TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE arboles_singulares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,
    tipo TEXT NOT NULL DEFAULT 'arbol_singular',
    especie_id TEXT NOT NULL DEFAULT '',
    nombre TEXT NOT NULL DEFAULT '',
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE SET NULL,
    latitud REAL,
    longitud REAL,
    perimetro_cm REAL,
    altura_m REAL,
    radio_parcela_m REAL,
    fecha_alta_ms INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE apuntes_economicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    es_ingreso INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    concepto TEXT NOT NULL,
    categoria TEXT NOT NULL,
    base_centimos INTEGER NOT NULL,
    tipo_iva_pct INTEGER NOT NULL DEFAULT 0,
    compensacion_reagp_pct REAL NOT NULL DEFAULT 0,
    rodal_id INTEGER REFERENCES rodales(id) ON DELETE SET NULL,
    aprovechamiento_id INTEGER
      REFERENCES aprovechamientos(id) ON DELETE SET NULL,
    tercero TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE configuraciones_fiscales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    regimen TEXT NOT NULL DEFAULT 'sin_elegir'
  )''',
  'CREATE INDEX idx_actuaciones_anyo ON actuaciones_plan(anyo_previsto)',
  'CREATE INDEX idx_ejecuciones_fecha ON ejecuciones(fecha_ms)',
  'CREATE INDEX idx_aprovechamientos_campanya '
      'ON aprovechamientos(campanya, fecha_inicio_ms)',
  'CREATE INDEX idx_revisiones_fecha '
      'ON revisiones_incendios(infraestructura_id, fecha_ms)',
  'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
];

/// Base de datos local de Larrea Monte. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplía durante la F1, antes de publicar nada.)
///
/// Integridad: un rodal con actuaciones, ejecuciones, aprovechamientos o
/// lotes **no se borra** (son registros del plan). Borrar un sorteo borra sus
/// lotes; uno ya realizado no se borra desde la app (ver pantallas).
class BaseDatosSoleraMonte extends BaseDatosSolera {
  static final BaseDatosSoleraMonte instancia = BaseDatosSoleraMonte._interno();
  factory BaseDatosSoleraMonte() => instancia;
  BaseDatosSoleraMonte._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosMonte;

  @override
  int get versionEsquema => versionEsquemaMonte;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaMonteV1) {
      await db.execute(sentencia);
    }
  }

  // ─── Utilidades ──────────────────────────────────────────────────

  /// Inserta si `id` es nulo, actualiza si no. Devuelve el id.
  Future<int> _guardar(String tabla, Map<String, Object?> mapa) async {
    final db = await basedatos;
    final id = mapa['id'] as int?;
    final sinId = Map<String, Object?>.of(mapa)..remove('id');
    if (id == null) return db.insert(tabla, sinId);
    await db.update(tabla, sinId, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  Future<List<Map<String, Object?>>> _listar(
    String tabla, {
    String? donde,
    List<Object?>? argumentos,
    String? orden,
  }) async {
    final db = await basedatos;
    return db.query(tabla, where: donde, whereArgs: argumentos, orderBy: orden);
  }

  Future<void> _borrar(String tabla, int id) async {
    final db = await basedatos;
    await db.delete(tabla, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Monte ───────────────────────────────────────────────────────

  Future<Monte> obtenerMonte() async {
    final filas = await _listar('montes', orden: 'id');
    return filas.isEmpty ? Monte() : Monte.fromMap(filas.first);
  }

  Future<void> guardarMonte(Monte monte) async {
    await guardarFilaUnica('montes', monte.toMap());
  }

  // ─── Rodales ─────────────────────────────────────────────────────

  /// Lanza si el código ya existe (UNIQUE).
  Future<int> guardarRodal(Rodal rodal) => _guardar('rodales', rodal.toMap());

  Future<List<Rodal>> listarRodales() async =>
      (await _listar('rodales', orden: 'codigo COLLATE NOCASE'))
          .map(Rodal.fromMap)
          .toList();

  /// Lanza si el rodal tiene registros del plan o aprovechamientos.
  Future<void> borrarRodal(int rodalId) => _borrar('rodales', rodalId);

  // ─── Plan de gestión ─────────────────────────────────────────────

  Future<int> guardarActuacion(ActuacionPlan actuacion) =>
      _guardar('actuaciones_plan', actuacion.toMap());

  Future<void> borrarActuacion(int actuacionId) =>
      _borrar('actuaciones_plan', actuacionId);

  Future<List<ActuacionPlan>> listarActuaciones(
      {int? desdeAnyo, int? hastaAnyo}) async {
    final condiciones = <String>[
      if (desdeAnyo != null) 'anyo_previsto >= ?',
      if (hastaAnyo != null) 'anyo_previsto <= ?',
    ];
    return (await _listar('actuaciones_plan',
            donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
            argumentos: [
              if (desdeAnyo != null) desdeAnyo,
              if (hastaAnyo != null) hastaAnyo,
            ],
            orden: 'anyo_previsto, id'))
        .map(ActuacionPlan.fromMap)
        .toList();
  }

  Future<int> guardarEjecucion(Ejecucion ejecucion) =>
      _guardar('ejecuciones', ejecucion.toMap());

  Future<void> borrarEjecucion(int ejecucionId) =>
      _borrar('ejecuciones', ejecucionId);

  Future<List<Ejecucion>> listarEjecuciones(
      {int? desdeMs, int? hastaMs}) async {
    final condiciones = <String>[
      if (desdeMs != null) 'fecha_ms >= ?',
      if (hastaMs != null) 'fecha_ms <= ?',
    ];
    return (await _listar('ejecuciones',
            donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
            argumentos: [
              if (desdeMs != null) desdeMs,
              if (hastaMs != null) hastaMs,
            ],
            orden: 'fecha_ms DESC, id DESC'))
        .map(Ejecucion.fromMap)
        .toList();
  }

  // ─── Aprovechamientos ────────────────────────────────────────────

  Future<int> guardarAprovechamiento(Aprovechamiento aprovechamiento) =>
      _guardar('aprovechamientos', aprovechamiento.toMap());

  Future<void> borrarAprovechamiento(int aprovechamientoId) =>
      _borrar('aprovechamientos', aprovechamientoId);

  Future<List<Aprovechamiento>> listarAprovechamientos({int? campanya}) async =>
      (await _listar('aprovechamientos',
              donde: campanya == null ? null : 'campanya = ?',
              argumentos: campanya == null ? null : [campanya],
              orden: 'campanya DESC, fecha_inicio_ms DESC, id DESC'))
          .map(Aprovechamiento.fromMap)
          .toList();

  // ─── Sorteos y lotes de leña ─────────────────────────────────────

  Future<int> guardarSorteo(SorteoLena sorteo) =>
      _guardar('sorteos_lena', sorteo.toMap());

  /// Borra el sorteo y sus lotes (CASCADE).
  Future<void> borrarSorteo(int sorteoId) => _borrar('sorteos_lena', sorteoId);

  Future<List<SorteoLena>> listarSorteos({int? campanya}) async =>
      (await _listar('sorteos_lena',
              donde: campanya == null ? null : 'campanya = ?',
              argumentos: campanya == null ? null : [campanya],
              orden: 'campanya DESC, id DESC'))
          .map(SorteoLena.fromMap)
          .toList();

  Future<SorteoLena?> obtenerSorteo(int sorteoId) async {
    final filas =
        await _listar('sorteos_lena', donde: 'id = ?', argumentos: [sorteoId]);
    return filas.isEmpty ? null : SorteoLena.fromMap(filas.first);
  }

  /// Lanza si el número ya existe en el sorteo (UNIQUE).
  Future<int> guardarLote(LoteLena lote) =>
      _guardar('lotes_lena', lote.toMap());

  Future<void> borrarLote(int loteId) => _borrar('lotes_lena', loteId);

  Future<List<LoteLena>> listarLotes({int? sorteoId}) async =>
      (await _listar('lotes_lena',
              donde: sorteoId == null ? null : 'sorteo_id = ?',
              argumentos: sorteoId == null ? null : [sorteoId],
              orden: 'sorteo_id, numero'))
          .map(LoteLena.fromMap)
          .toList();

  /// Guarda el resultado del sorteo y los adjudicatarios de los lotes en
  /// una sola transacción: o todo o nada.
  Future<void> guardarResultadoSorteo(
      SorteoLena sorteo, List<LoteLena> lotesAdjudicados) async {
    final db = await basedatos;
    await db.transaction((transaccion) async {
      final mapa = Map<String, Object?>.of(sorteo.toMap())..remove('id');
      await transaccion.update('sorteos_lena', mapa,
          where: 'id = ?', whereArgs: [sorteo.id]);
      for (final lote in lotesAdjudicados) {
        await transaccion.update(
            'lotes_lena', {'adjudicatario': lote.adjudicatario},
            where: 'id = ?', whereArgs: [lote.id]);
      }
    });
  }

  // ─── Incendios ───────────────────────────────────────────────────

  Future<int> guardarInfraestructura(
          InfraestructuraIncendios infraestructura) =>
      _guardar('infraestructuras_incendios', infraestructura.toMap());

  /// Lanza si tiene revisiones (RESTRICT): mejor marcarla inactiva.
  Future<void> borrarInfraestructura(int infraestructuraId) =>
      _borrar('infraestructuras_incendios', infraestructuraId);

  Future<List<InfraestructuraIncendios>> listarInfraestructuras(
          {bool soloActivas = false}) async =>
      (await _listar('infraestructuras_incendios',
              donde: soloActivas ? 'activa = 1' : null,
              orden: 'tipo, nombre COLLATE NOCASE'))
          .map(InfraestructuraIncendios.fromMap)
          .toList();

  Future<int> guardarRevision(RevisionIncendios revision) =>
      _guardar('revisiones_incendios', revision.toMap());

  Future<void> borrarRevision(int revisionId) =>
      _borrar('revisiones_incendios', revisionId);

  Future<List<RevisionIncendios>> listarRevisiones(
      {int? infraestructuraId, int? desdeMs, int? hastaMs}) async {
    final condiciones = <String>[
      if (infraestructuraId != null) 'infraestructura_id = ?',
      if (desdeMs != null) 'fecha_ms >= ?',
      if (hastaMs != null) 'fecha_ms <= ?',
    ];
    return (await _listar('revisiones_incendios',
            donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
            argumentos: [
              if (infraestructuraId != null) infraestructuraId,
              if (desdeMs != null) desdeMs,
              if (hastaMs != null) hastaMs,
            ],
            orden: 'fecha_ms DESC, id DESC'))
        .map(RevisionIncendios.fromMap)
        .toList();
  }

  // ─── Árboles singulares y parcelas de muestreo ───────────────────

  /// Lanza si el código ya existe (UNIQUE).
  Future<int> guardarArbol(ArbolSingular arbol) =>
      _guardar('arboles_singulares', arbol.toMap());

  Future<void> borrarArbol(int arbolId) =>
      _borrar('arboles_singulares', arbolId);

  Future<List<ArbolSingular>> listarArboles() async =>
      (await _listar('arboles_singulares', orden: 'codigo COLLATE NOCASE'))
          .map(ArbolSingular.fromMap)
          .toList();

  // ─── Economía ────────────────────────────────────────────────────

  /// Régimen guardado (uno de `regimenesFiscalesMonte`).
  Future<String> obtenerRegimenFiscal() async {
    final filas = await _listar('configuraciones_fiscales', orden: 'id');
    return filas.isEmpty
        ? 'sin_elegir'
        : (filas.first['regimen'] as String?) ?? 'sin_elegir';
  }

  Future<void> guardarRegimenFiscal(String regimen) async {
    await guardarFilaUnica('configuraciones_fiscales', {'regimen': regimen});
  }

  Future<int> guardarApunteEconomico(ApunteEconomico apunte) =>
      _guardar('apuntes_economicos', apunte.toMap());

  Future<void> borrarApunteEconomico(int apunteId) =>
      _borrar('apuntes_economicos', apunteId);

  Future<List<ApunteEconomico>> listarApuntesEconomicos(
          {required int desdeMs, required int hastaMs}) async =>
      (await _listar('apuntes_economicos',
              donde: 'fecha_ms >= ? AND fecha_ms <= ?',
              argumentos: [desdeMs, hastaMs],
              orden: 'fecha_ms DESC, id DESC'))
          .map(ApunteEconomico.fromMap)
          .toList();
}
