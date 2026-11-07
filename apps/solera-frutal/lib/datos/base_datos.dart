import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/abonado.dart';
import '../modelos/contrato_polinizacion.dart';
import '../modelos/cosecha.dart';
import '../modelos/fila_arboles.dart';
import '../modelos/helada.dart';
import '../modelos/observacion_plaga.dart';
import '../modelos/parcela.dart';
import '../modelos/riego.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosFrutal = 'solera_frutal.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaFrutal = 1;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaFrutalV1 = [
  '''CREATE TABLE titulares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL DEFAULT '',
    nif TEXT NOT NULL DEFAULT '',
    registro_explotacion TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    asesor_nombre TEXT NOT NULL DEFAULT '',
    asesor_numero_ropo TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE parcelas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    especie_id TEXT NOT NULL,
    variedad_principal_id TEXT NOT NULL DEFAULT '',
    codigo_sigpac TEXT NOT NULL DEFAULT '',
    superficie_ha REAL NOT NULL DEFAULT 0,
    marco_plantacion TEXT NOT NULL DEFAULT '',
    anyo_plantacion INTEGER,
    regadio INTEGER NOT NULL DEFAULT 0,
    sistema_riego TEXT NOT NULL DEFAULT '',
    latitud REAL,
    longitud REAL,
    notas TEXT NOT NULL DEFAULT '',
    fecha_creacion_ms INTEGER NOT NULL DEFAULT 0
  )''',
  '''CREATE TABLE filas_arboles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE CASCADE,
    etiqueta TEXT NOT NULL,
    variedad_id TEXT NOT NULL DEFAULT '',
    numero_arboles INTEGER NOT NULL DEFAULT 0,
    es_polinizadora INTEGER NOT NULL DEFAULT 0,
    anyo_plantacion INTEGER,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE contratos_polinizacion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE CASCADE,
    campania INTEGER NOT NULL,
    apicultor_nombre TEXT NOT NULL,
    apicultor_codigo_rega TEXT NOT NULL DEFAULT '',
    numero_colmenas INTEGER NOT NULL DEFAULT 0,
    fecha_entrada_ms INTEGER,
    fecha_salida_ms INTEGER,
    precio_centimos_colmena INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE tratamientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    superficie_tratada_ha REAL NOT NULL DEFAULT 0,
    problema_fitosanitario TEXT NOT NULL DEFAULT '',
    sustancia_activa_id TEXT NOT NULL DEFAULT '',
    nombre_producto TEXT NOT NULL DEFAULT '',
    numero_registro_producto TEXT NOT NULL DEFAULT '',
    dosis_aplicada TEXT NOT NULL DEFAULT '',
    plazo_seguridad_dias INTEGER,
    aplicador_nombre TEXT NOT NULL DEFAULT '',
    carnet_aplicador TEXT NOT NULL DEFAULT '',
    equipo_aplicacion TEXT NOT NULL DEFAULT '',
    eficacia TEXT NOT NULL DEFAULT '',
    observaciones TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE abonados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    tipo_abono TEXT NOT NULL,
    riqueza_npk TEXT NOT NULL DEFAULT '',
    cantidad_kg_ha REAL NOT NULL DEFAULT 0,
    metodo TEXT NOT NULL DEFAULT 'fondo',
    superficie_ha REAL NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE riegos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    volumen_m3 REAL NOT NULL DEFAULT 0,
    horas REAL,
    origen_agua TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE cosechas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE RESTRICT,
    campania INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    kg_cascara REAL NOT NULL DEFAULT 0,
    rendimiento_grano_pct REAL,
    calibre TEXT NOT NULL DEFAULT '',
    humedad_pct REAL,
    destino TEXT NOT NULL DEFAULT '',
    numero_albaran TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE heladas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER REFERENCES parcelas(id) ON DELETE SET NULL,
    fecha_ms INTEGER NOT NULL,
    temperatura_minima_c REAL,
    estado_fenologico TEXT NOT NULL DEFAULT '',
    danio_estimado_pct REAL,
    es_pedrisco INTEGER NOT NULL DEFAULT 0,
    comunicada_seguro INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE observaciones_plaga (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE CASCADE,
    fecha_ms INTEGER NOT NULL,
    plaga_id TEXT NOT NULL,
    recuento REAL,
    supera_umbral INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  'CREATE INDEX idx_filas_parcela ON filas_arboles(parcela_id)',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  'CREATE INDEX idx_abonados_fecha ON abonados(fecha_ms)',
  'CREATE INDEX idx_riegos_fecha ON riegos(fecha_ms)',
  'CREATE INDEX idx_cosechas_campania ON cosechas(campania, parcela_id)',
  'CREATE INDEX idx_heladas_fecha ON heladas(fecha_ms)',
  'CREATE INDEX idx_observaciones_fecha ON observaciones_plaga(parcela_id, fecha_ms)',
];

/// Base de datos local de Larrea Frutal. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplía durante la F1, antes de publicar nada.)
///
/// Integridad: borrar una parcela se lleva sus filas, contratos y
/// observaciones, pero **no** se puede borrar si tiene tratamientos,
/// abonados, riegos o cosechas (son registros del cuaderno).
class BaseDatosSoleraFrutal extends BaseDatosSolera {
  static final BaseDatosSoleraFrutal instancia =
      BaseDatosSoleraFrutal._interno();
  factory BaseDatosSoleraFrutal() => instancia;
  BaseDatosSoleraFrutal._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosFrutal;

  @override
  int get versionEsquema => versionEsquemaFrutal;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaFrutalV1) {
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

  /// Filtro opcional por parcela y por intervalo de fechas.
  Future<List<Map<String, Object?>>> _listarRegistros(
    String tabla, {
    int? parcelaId,
    int? desdeMs,
    int? hastaMs,
  }) {
    final condiciones = <String>[
      if (parcelaId != null) 'parcela_id = ?',
      if (desdeMs != null) 'fecha_ms >= ?',
      if (hastaMs != null) 'fecha_ms <= ?',
    ];
    return _listar(tabla,
        donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
        argumentos: [
          if (parcelaId != null) parcelaId,
          if (desdeMs != null) desdeMs,
          if (hastaMs != null) hastaMs,
        ],
        orden: 'fecha_ms DESC, id DESC');
  }

  // ─── Titular ─────────────────────────────────────────────────────

  Future<Titular> obtenerTitular() async {
    final filas = await _listar('titulares', orden: 'id');
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }

  // ─── Parcelas y filas ────────────────────────────────────────────

  Future<int> guardarParcela(Parcela parcela) =>
      _guardar('parcelas', parcela.toMap());

  Future<List<Parcela>> listarParcelas() async =>
      (await _listar('parcelas', orden: 'nombre COLLATE NOCASE'))
          .map(Parcela.fromMap)
          .toList();

  Future<Parcela?> obtenerParcela(int parcelaId) async {
    final filas =
        await _listar('parcelas', donde: 'id = ?', argumentos: [parcelaId]);
    return filas.isEmpty ? null : Parcela.fromMap(filas.first);
  }

  /// Lanza si la parcela tiene registros del cuaderno (FK RESTRICT).
  Future<void> borrarParcela(int parcelaId) => _borrar('parcelas', parcelaId);

  Future<int> guardarFilaArboles(FilaArboles fila) =>
      _guardar('filas_arboles', fila.toMap());

  Future<void> borrarFilaArboles(int filaId) =>
      _borrar('filas_arboles', filaId);

  Future<List<FilaArboles>> listarFilasArboles({int? parcelaId}) async =>
      (await _listar('filas_arboles',
              donde: parcelaId == null ? null : 'parcela_id = ?',
              argumentos: parcelaId == null ? null : [parcelaId],
              orden: 'id'))
          .map(FilaArboles.fromMap)
          .toList();

  // ─── Polinización ────────────────────────────────────────────────

  Future<int> guardarContratoPolinizacion(ContratoPolinizacion contrato) =>
      _guardar('contratos_polinizacion', contrato.toMap());

  Future<void> borrarContratoPolinizacion(int contratoId) =>
      _borrar('contratos_polinizacion', contratoId);

  Future<List<ContratoPolinizacion>> listarContratosPolinizacion(
          {int? parcelaId, int? campania}) async =>
      (await _listar('contratos_polinizacion',
              donde: [
                if (parcelaId != null) 'parcela_id = ?',
                if (campania != null) 'campania = ?',
              ].join(' AND ').vacioComoNulo,
              argumentos: [
                if (parcelaId != null) parcelaId,
                if (campania != null) campania,
              ],
              orden: 'campania DESC, id DESC'))
          .map(ContratoPolinizacion.fromMap)
          .toList();

  // ─── Cuaderno: tratamientos, abonados, riegos ────────────────────

  Future<int> guardarTratamiento(Tratamiento tratamiento) =>
      _guardar('tratamientos', tratamiento.toMap());

  Future<void> borrarTratamiento(int tratamientoId) =>
      _borrar('tratamientos', tratamientoId);

  Future<List<Tratamiento>> listarTratamientos(
          {int? parcelaId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('tratamientos',
              parcelaId: parcelaId, desdeMs: desdeMs, hastaMs: hastaMs))
          .map(Tratamiento.fromMap)
          .toList();

  Future<int> guardarAbonado(Abonado abonado) =>
      _guardar('abonados', abonado.toMap());

  Future<void> borrarAbonado(int abonadoId) => _borrar('abonados', abonadoId);

  Future<List<Abonado>> listarAbonados(
          {int? parcelaId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('abonados',
              parcelaId: parcelaId, desdeMs: desdeMs, hastaMs: hastaMs))
          .map(Abonado.fromMap)
          .toList();

  Future<int> guardarRiego(Riego riego) => _guardar('riegos', riego.toMap());

  Future<void> borrarRiego(int riegoId) => _borrar('riegos', riegoId);

  Future<List<Riego>> listarRiegos(
          {int? parcelaId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('riegos',
              parcelaId: parcelaId, desdeMs: desdeMs, hastaMs: hastaMs))
          .map(Riego.fromMap)
          .toList();

  // ─── Cosecha ─────────────────────────────────────────────────────

  Future<int> guardarCosecha(Cosecha cosecha) =>
      _guardar('cosechas', cosecha.toMap());

  Future<void> borrarCosecha(int cosechaId) => _borrar('cosechas', cosechaId);

  Future<List<Cosecha>> listarCosechas({int? campania, int? parcelaId}) async =>
      (await _listar('cosechas',
              donde: [
                if (campania != null) 'campania = ?',
                if (parcelaId != null) 'parcela_id = ?',
              ].join(' AND ').vacioComoNulo,
              argumentos: [
                if (campania != null) campania,
                if (parcelaId != null) parcelaId,
              ],
              orden: 'fecha_ms DESC, id DESC'))
          .map(Cosecha.fromMap)
          .toList();

  /// Campañas con alguna cosecha, de la más reciente a la más antigua.
  Future<List<int>> campaniasConCosecha() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
        'SELECT DISTINCT campania FROM cosechas ORDER BY campania DESC');
    return filas.map((fila) => fila['campania'] as int).toList();
  }

  // ─── Heladas y seguimiento de plagas ─────────────────────────────

  Future<int> guardarHelada(Helada helada) =>
      _guardar('heladas', helada.toMap());

  Future<void> borrarHelada(int heladaId) => _borrar('heladas', heladaId);

  Future<List<Helada>> listarHeladas({int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('heladas', desdeMs: desdeMs, hastaMs: hastaMs))
          .map(Helada.fromMap)
          .toList();

  Future<int> guardarObservacionPlaga(ObservacionPlaga observacion) =>
      _guardar('observaciones_plaga', observacion.toMap());

  Future<void> borrarObservacionPlaga(int observacionId) =>
      _borrar('observaciones_plaga', observacionId);

  Future<List<ObservacionPlaga>> listarObservacionesPlaga(
          {int? parcelaId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('observaciones_plaga',
              parcelaId: parcelaId, desdeMs: desdeMs, hastaMs: hastaMs))
          .map(ObservacionPlaga.fromMap)
          .toList();
}

extension on String {
  /// Una condición WHERE vacía es «sin filtro».
  String? get vacioComoNulo => isEmpty ? null : this;
}
