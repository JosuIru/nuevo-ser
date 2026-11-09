import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/embotellado.dart';
import '../modelos/kupela.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/pomarada.dart';
import '../modelos/prensado.dart';
import '../modelos/sagardotegi.dart';
import '../modelos/sesion_txotx.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosSidra = 'solera_sidra.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaSidra = 2;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaSidraV1 = [
  '''CREATE TABLE titulares (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      nif TEXT NOT NULL DEFAULT '',
      registro_sanitario TEXT NOT NULL DEFAULT '',
      inscripcion_dop TEXT NOT NULL DEFAULT '',
      registro_explotacion TEXT NOT NULL DEFAULT '',
      regimen_fiscal TEXT NOT NULL DEFAULT 'general'
    )''',
  '''CREATE TABLE sagardotegis (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      municipio TEXT NOT NULL DEFAULT '',
      territorio TEXT NOT NULL DEFAULT '',
      perfil TEXT NOT NULL DEFAULT 'sidra',
      dop_id TEXT NOT NULL DEFAULT '',
      abre_txotx INTEGER NOT NULL DEFAULT 1
    )''',
  '''CREATE TABLE pomaradas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      cultivo TEXT NOT NULL DEFAULT 'manzano',
      municipio TEXT NOT NULL DEFAULT '',
      poligono TEXT NOT NULL DEFAULT '',
      parcela TEXT NOT NULL DEFAULT '',
      recinto TEXT NOT NULL DEFAULT '',
      superficie_ha REAL NOT NULL DEFAULT 0,
      numero_arboles INTEGER NOT NULL DEFAULT 0,
      anio_plantacion INTEGER,
      variedades TEXT NOT NULL DEFAULT '',
      registrada_dop INTEGER NOT NULL DEFAULT 0,
      latitud REAL,
      longitud REAL,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE manzanos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pomarada_id INTEGER NOT NULL REFERENCES pomaradas(id) ON DELETE CASCADE,
      etiqueta TEXT NOT NULL,
      variedad_id TEXT NOT NULL DEFAULT '',
      anio_plantacion INTEGER,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pomarada_id INTEGER NOT NULL REFERENCES pomaradas(id) ON DELETE RESTRICT,
      fecha_ms INTEGER NOT NULL,
      sustancia_activa_id TEXT NOT NULL DEFAULT '',
      numero_registro_producto TEXT NOT NULL DEFAULT '',
      cantidad_aplicada TEXT NOT NULL DEFAULT '',
      plaga_objetivo_id TEXT NOT NULL DEFAULT '',
      superficie_tratada_ha REAL,
      aplicador TEXT NOT NULL DEFAULT '',
      carnet_aplicador TEXT NOT NULL DEFAULT '',
      asesor TEXT NOT NULL DEFAULT '',
      equipo_aplicacion TEXT NOT NULL DEFAULT '',
      eficacia TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE partidas_manzana (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_entrega_ms INTEGER NOT NULL,
      kilos REAL NOT NULL,
      fruta TEXT NOT NULL DEFAULT 'manzana',
      propia INTEGER NOT NULL DEFAULT 1,
      pomarada_id INTEGER REFERENCES pomaradas(id) ON DELETE RESTRICT,
      proveedor TEXT NOT NULL DEFAULT '',
      proveedor_registrado_dop INTEGER NOT NULL DEFAULT 0,
      procedencia TEXT NOT NULL DEFAULT '',
      variedades TEXT NOT NULL DEFAULT '',
      fecha_recoleccion_ms INTEGER,
      estado_fruta TEXT NOT NULL DEFAULT 'sana',
      documento_transporte TEXT NOT NULL DEFAULT '',
      precio_centimos_kg INTEGER NOT NULL DEFAULT 0,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE kupelas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      codigo TEXT NOT NULL UNIQUE,
      capacidad_litros REAL NOT NULL DEFAULT 0,
      nombre TEXT NOT NULL DEFAULT '',
      material TEXT NOT NULL DEFAULT 'madera',
      producto TEXT NOT NULL DEFAULT 'sidra',
      calificacion TEXT NOT NULL DEFAULT 'pendiente',
      producto_dop_id TEXT NOT NULL DEFAULT '',
      activa INTEGER NOT NULL DEFAULT 1,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE prensados (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      kupela_id INTEGER NOT NULL REFERENCES kupelas(id) ON DELETE RESTRICT,
      kilos_fruta REAL NOT NULL DEFAULT 0,
      litros_mosto REAL NOT NULL DEFAULT 0,
      presion_bar REAL,
      densidad_mosto REAL,
      temperatura_mosto_c REAL,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE prensados_partidas (
      prensado_id INTEGER NOT NULL REFERENCES prensados(id) ON DELETE CASCADE,
      partida_id INTEGER NOT NULL REFERENCES partidas_manzana(id) ON DELETE RESTRICT,
      PRIMARY KEY (prensado_id, partida_id)
    )''',
  '''CREATE TABLE mediciones_kupela (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kupela_id INTEGER NOT NULL REFERENCES kupelas(id) ON DELETE CASCADE,
      fecha_ms INTEGER NOT NULL,
      densidad REAL,
      temperatura_c REAL,
      acidez_volatil_g_l REAL,
      grado_alcoholico REAL,
      sulfuroso_total_mg_l REAL,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE trasiegos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      kupela_origen_id INTEGER NOT NULL REFERENCES kupelas(id) ON DELETE RESTRICT,
      kupela_destino_id INTEGER REFERENCES kupelas(id) ON DELETE RESTRICT,
      litros REAL NOT NULL,
      motivo TEXT NOT NULL DEFAULT '',
      CHECK (kupela_destino_id IS NULL OR kupela_destino_id <> kupela_origen_id)
    )''',
  '''CREATE TABLE sesiones_txotx (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      kupela_id INTEGER NOT NULL REFERENCES kupelas(id) ON DELETE RESTRICT,
      litros_servidos REAL NOT NULL DEFAULT 0,
      comensales INTEGER,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''CREATE TABLE embotellados (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      kupela_id INTEGER NOT NULL REFERENCES kupelas(id) ON DELETE RESTRICT,
      codigo_lote TEXT NOT NULL,
      botellas INTEGER NOT NULL,
      mililitros_botella INTEGER NOT NULL DEFAULT 750,
      con_dop INTEGER NOT NULL DEFAULT 0,
      fecha_etiquetado_ms INTEGER,
      etiqueta_desde INTEGER,
      etiqueta_hasta INTEGER,
      destino TEXT NOT NULL DEFAULT '',
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
      compensacion_reagp INTEGER NOT NULL DEFAULT 0,
      tercero TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )''',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  'CREATE INDEX idx_partidas_fecha ON partidas_manzana(fecha_entrega_ms)',
  'CREATE INDEX idx_prensados_fecha ON prensados(fecha_ms)',
  'CREATE INDEX idx_mediciones_kupela ON mediciones_kupela(kupela_id, fecha_ms)',
  'CREATE INDEX idx_txotx_fecha ON sesiones_txotx(fecha_ms)',
  'CREATE INDEX idx_embotellados_fecha ON embotellados(fecha_ms)',
  'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
];

/// Base de datos local de Larrea Sagardoa. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplió en el bloque 2, antes de publicar nada.)
class BaseDatosSoleraSidra extends BaseDatosSolera {
  static final BaseDatosSoleraSidra instancia = BaseDatosSoleraSidra._interno();
  factory BaseDatosSoleraSidra() => instancia;
  BaseDatosSoleraSidra._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosSidra;

  @override
  int get versionEsquema => versionEsquemaSidra;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => {
        2: _anadirContornoPomaradasV2,
      };

  /// v2 (2026-11-09): área de la pomarada marcada en el mapa
  /// (nuevo_ser_mapa), JSON `[[lat,lng],…]`.
  static Future<void> _anadirContornoPomaradasV2(Database db) async {
    await db.execute(
        "ALTER TABLE pomaradas ADD COLUMN contorno TEXT NOT NULL DEFAULT '[]'");
  }

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaSidraV1) {
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

  /// Filtro de fecha opcional sobre [columna].
  ({String? donde, List<Object?>? argumentos}) _rango(
    String columna,
    int? desdeMs,
    int? hastaMs,
  ) =>
      desdeMs == null
          ? (donde: null, argumentos: null)
          : (
              donde: '$columna >= ? AND $columna <= ?',
              argumentos: [desdeMs, hastaMs ?? desdeMs],
            );

  // ─── Titular y sagardotegi ───────────────────────────────────────

  Future<Titular> obtenerTitular() async {
    final filas = await _listar('titulares');
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }

  Future<Sagardotegi> obtenerSagardotegi() async {
    final filas = await _listar('sagardotegis');
    return filas.isEmpty ? Sagardotegi() : Sagardotegi.fromMap(filas.first);
  }

  Future<void> guardarSagardotegi(Sagardotegi sagardotegi) async {
    await guardarFilaUnica('sagardotegis', sagardotegi.toMap());
  }

  // ─── Pomaradas, manzanos y tratamientos ──────────────────────────

  Future<int> guardarPomarada(Pomarada pomarada) =>
      _guardar('pomaradas', pomarada.toMap());

  Future<List<Pomarada>> listarPomaradas() async => (await _listar(
        'pomaradas',
        orden: 'nombre COLLATE NOCASE',
      ))
          .map(Pomarada.fromMap)
          .toList();

  Future<int> guardarManzano(Manzano manzano) =>
      _guardar('manzanos', manzano.toMap());

  Future<List<Manzano>> listarManzanos(int pomaradaId) async => (await _listar(
        'manzanos',
        donde: 'pomarada_id = ?',
        argumentos: [pomaradaId],
        orden: 'etiqueta COLLATE NOCASE',
      ))
          .map(Manzano.fromMap)
          .toList();

  Future<int> guardarTratamiento(Tratamiento tratamiento) =>
      _guardar('tratamientos', tratamiento.toMap());

  Future<void> borrarTratamiento(int tratamientoId) =>
      _borrar('tratamientos', tratamientoId);

  Future<List<Tratamiento>> listarTratamientos({
    int? pomaradaId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    final condiciones = [
      if (pomaradaId != null) 'pomarada_id = ?',
      if (rango.donde != null) rango.donde!,
    ];
    return (await _listar(
      'tratamientos',
      donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
      argumentos: [if (pomaradaId != null) pomaradaId, ...?rango.argumentos],
      orden: 'fecha_ms DESC',
    ))
        .map(Tratamiento.fromMap)
        .toList();
  }

  // ─── Partidas de fruta ───────────────────────────────────────────

  Future<int> guardarPartida(PartidaManzana partida) =>
      _guardar('partidas_manzana', partida.toMap());

  Future<List<PartidaManzana>> listarPartidas({
    int? desdeMs,
    int? hastaMs,
  }) async {
    final rango = _rango('fecha_entrega_ms', desdeMs, hastaMs);
    return (await _listar(
      'partidas_manzana',
      donde: rango.donde,
      argumentos: rango.argumentos,
      orden: 'fecha_entrega_ms DESC',
    ))
        .map(PartidaManzana.fromMap)
        .toList();
  }

  // ─── Kupelas ─────────────────────────────────────────────────────

  Future<int> guardarKupela(Kupela kupela) =>
      _guardar('kupelas', kupela.toMap());

  Future<List<Kupela>> listarKupelas({bool soloActivas = false}) async =>
      (await _listar(
        'kupelas',
        donde: soloActivas ? 'activa = 1' : null,
        orden: 'codigo COLLATE NOCASE',
      ))
          .map(Kupela.fromMap)
          .toList();

  Future<int> guardarMedicion(MedicionKupela medicion) =>
      _guardar('mediciones_kupela', medicion.toMap());

  Future<List<MedicionKupela>> listarMediciones({
    int? kupelaId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    final condiciones = [
      if (kupelaId != null) 'kupela_id = ?',
      if (rango.donde != null) rango.donde!,
    ];
    return (await _listar(
      'mediciones_kupela',
      donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
      argumentos: [if (kupelaId != null) kupelaId, ...?rango.argumentos],
      orden: 'fecha_ms DESC',
    ))
        .map(MedicionKupela.fromMap)
        .toList();
  }

  Future<int> guardarTrasiego(Trasiego trasiego) =>
      _guardar('trasiegos', trasiego.toMap());

  Future<List<Trasiego>> listarTrasiegos({int? desdeMs, int? hastaMs}) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    return (await _listar(
      'trasiegos',
      donde: rango.donde,
      argumentos: rango.argumentos,
      orden: 'fecha_ms DESC',
    ))
        .map(Trasiego.fromMap)
        .toList();
  }

  // ─── Prensados ───────────────────────────────────────────────────

  /// Guarda el prensado y las partidas que entraron, en una transacción
  /// (trazabilidad: qué fruta fue a qué kupela).
  Future<int> guardarPrensado(
    Prensado prensado, {
    List<int> partidas = const [],
  }) async {
    final db = await basedatos;
    return db.transaction((transaccion) async {
      final sinId = prensado.toMap()..remove('id');
      var id = prensado.id;
      if (id == null) {
        id = await transaccion.insert('prensados', sinId);
      } else {
        await transaccion.update(
          'prensados',
          sinId,
          where: 'id = ?',
          whereArgs: [id],
        );
        await transaccion.delete(
          'prensados_partidas',
          where: 'prensado_id = ?',
          whereArgs: [id],
        );
      }
      for (final partidaId in partidas.toSet()) {
        await transaccion.insert('prensados_partidas', {
          'prensado_id': id,
          'partida_id': partidaId,
        });
      }
      return id;
    });
  }

  Future<List<Prensado>> listarPrensados({int? desdeMs, int? hastaMs}) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    return (await _listar(
      'prensados',
      donde: rango.donde,
      argumentos: rango.argumentos,
      orden: 'fecha_ms DESC',
    ))
        .map(Prensado.fromMap)
        .toList();
  }

  /// Prensado → partidas que entraron.
  Future<Map<int, List<int>>> partidasPorPrensado() async {
    final agrupadas = <int, List<int>>{};
    for (final fila in await _listar('prensados_partidas')) {
      agrupadas
          .putIfAbsent(fila['prensado_id'] as int, () => [])
          .add(fila['partida_id'] as int);
    }
    return agrupadas;
  }

  /// Ids de las partidas ya prensadas.
  Future<Set<int>> partidasPrensadas() async => {
        for (final fila in await _listar('prensados_partidas'))
          fila['partida_id'] as int,
      };

  // ─── Txotx y embotellado ─────────────────────────────────────────

  Future<int> guardarSesionTxotx(SesionTxotx sesion) =>
      _guardar('sesiones_txotx', sesion.toMap());

  Future<void> borrarSesionTxotx(int sesionId) =>
      _borrar('sesiones_txotx', sesionId);

  Future<List<SesionTxotx>> listarSesionesTxotx({
    int? desdeMs,
    int? hastaMs,
  }) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    return (await _listar(
      'sesiones_txotx',
      donde: rango.donde,
      argumentos: rango.argumentos,
      orden: 'fecha_ms DESC',
    ))
        .map(SesionTxotx.fromMap)
        .toList();
  }

  Future<int> guardarEmbotellado(Embotellado embotellado) =>
      _guardar('embotellados', embotellado.toMap());

  Future<List<Embotellado>> listarEmbotellados({
    int? desdeMs,
    int? hastaMs,
  }) async {
    final rango = _rango('fecha_ms', desdeMs, hastaMs);
    return (await _listar(
      'embotellados',
      donde: rango.donde,
      argumentos: rango.argumentos,
      orden: 'fecha_ms DESC',
    ))
        .map(Embotellado.fromMap)
        .toList();
  }

  // ─── Ingresos y gastos ───────────────────────────────────────────

  Future<int> guardarApunteEconomico(ApunteEconomico apunte) =>
      _guardar('apuntes_economicos', apunte.toMap());

  Future<void> borrarApunteEconomico(int apunteId) =>
      _borrar('apuntes_economicos', apunteId);

  Future<List<ApunteEconomico>> listarApuntesEconomicos({
    required int desdeMs,
    required int hastaMs,
  }) async =>
      (await _listar(
        'apuntes_economicos',
        donde: 'fecha_ms >= ? AND fecha_ms <= ?',
        argumentos: [desdeMs, hastaMs],
        orden: 'fecha_ms DESC',
      ))
          .map(ApunteEconomico.fromMap)
          .toList();
}
