import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/cosecha.dart';
import '../modelos/destilacion.dart';
import '../modelos/lote_producto.dart';
import '../modelos/parcela.dart';
import '../modelos/secado.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_recoleccion.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosAromaticas = 'solera_aromaticas.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaAromaticas = 1;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaAromaticasV1 = [
  '''CREATE TABLE titulares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL DEFAULT '',
    nif TEXT NOT NULL DEFAULT '',
    registro_explotacion TEXT NOT NULL DEFAULT '',
    registro_sanitario TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    comunidad_autonoma TEXT NOT NULL DEFAULT '',
    asesor_nombre TEXT NOT NULL DEFAULT '',
    asesor_numero_ropo TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE parcelas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    especie_id TEXT NOT NULL,
    codigo_sigpac TEXT NOT NULL DEFAULT '',
    superficie_ha REAL NOT NULL DEFAULT 0,
    anyo_plantacion INTEGER,
    ecologico INTEGER NOT NULL DEFAULT 0,
    regadio INTEGER NOT NULL DEFAULT 0,
    latitud REAL,
    longitud REAL,
    notas TEXT NOT NULL DEFAULT '',
    fecha_creacion_ms INTEGER NOT NULL DEFAULT 0
  )''',
  '''CREATE TABLE zonas_recoleccion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    comunidad_autonoma TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    tipo_terreno TEXT NOT NULL DEFAULT 'monte_publico',
    titular_terreno TEXT NOT NULL DEFAULT '',
    numero_permiso TEXT NOT NULL DEFAULT '',
    organismo_permiso TEXT NOT NULL DEFAULT '',
    inicio_vigencia_ms INTEGER,
    fin_vigencia_ms INTEGER,
    especies_permitidas TEXT NOT NULL DEFAULT '',
    limite_kg REAL,
    latitud REAL,
    longitud REAL,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE cosechas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER REFERENCES parcelas(id) ON DELETE RESTRICT,
    zona_recoleccion_id INTEGER
      REFERENCES zonas_recoleccion(id) ON DELETE RESTRICT,
    especie_id TEXT NOT NULL,
    fecha_ms INTEGER NOT NULL,
    kg_frescos REAL NOT NULL DEFAULT 0,
    estado_fenologico TEXT NOT NULL DEFAULT '',
    parte_recolectada TEXT NOT NULL DEFAULT '',
    recolector TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT '',
    CHECK ((parcela_id IS NULL) <> (zona_recoleccion_id IS NULL))
  )''',
  '''CREATE TABLE lotes_producto (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,
    tipo TEXT NOT NULL,
    especie_id TEXT NOT NULL,
    fecha_ms INTEGER NOT NULL,
    destino TEXT NOT NULL DEFAULT 'sin_decidir',
    cantidad REAL NOT NULL DEFAULT 0,
    cantidad_disponible REAL,
    envase TEXT NOT NULL DEFAULT '',
    fecha_consumo_preferente_ms INTEGER,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE secados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_inicio_ms INTEGER NOT NULL,
    especie_id TEXT NOT NULL,
    cosechas_usadas_json TEXT NOT NULL DEFAULT '[]',
    kg_frescos REAL NOT NULL DEFAULT 0,
    kg_secos REAL NOT NULL DEFAULT 0,
    dias INTEGER,
    metodo TEXT NOT NULL DEFAULT 'sombra_natural',
    temperatura_maxima_c REAL,
    lote_producto_id INTEGER
      REFERENCES lotes_producto(id) ON DELETE SET NULL,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE destilaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_ms INTEGER NOT NULL,
    especie_id TEXT NOT NULL,
    cosechas_usadas_json TEXT NOT NULL DEFAULT '[]',
    kg_planta REAL NOT NULL DEFAULT 0,
    estado_planta TEXT NOT NULL DEFAULT 'fresca',
    ml_aceite_esencial REAL NOT NULL DEFAULT 0,
    litros_hidrolato REAL NOT NULL DEFAULT 0,
    horas REAL,
    tipo_alambique TEXT NOT NULL DEFAULT 'arrastre_vapor',
    capacidad_alambique_l REAL,
    lote_aceite_id INTEGER REFERENCES lotes_producto(id) ON DELETE SET NULL,
    lote_hidrolato_id INTEGER
      REFERENCES lotes_producto(id) ON DELETE SET NULL,
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
  '''CREATE TABLE apuntes_economicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    es_ingreso INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    concepto TEXT NOT NULL,
    categoria TEXT NOT NULL,
    base_centimos INTEGER NOT NULL,
    tipo_iva_pct INTEGER NOT NULL DEFAULT 0,
    compensacion_reagp_pct REAL NOT NULL DEFAULT 0,
    parcela_id INTEGER REFERENCES parcelas(id) ON DELETE SET NULL,
    tercero TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE configuraciones_fiscales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    regimen_iva TEXT NOT NULL DEFAULT 'sin_elegir'
  )''',
  'CREATE INDEX idx_cosechas_fecha ON cosechas(fecha_ms)',
  'CREATE INDEX idx_cosechas_zona ON cosechas(zona_recoleccion_id, fecha_ms)',
  'CREATE INDEX idx_secados_fecha ON secados(fecha_inicio_ms)',
  'CREATE INDEX idx_destilaciones_fecha ON destilaciones(fecha_ms)',
  'CREATE INDEX idx_lotes_fecha ON lotes_producto(fecha_ms)',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
];

/// Base de datos local de Larrea Aromáticas. La apertura, el cerrojo, las
/// FK y las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplía durante la F1, antes de publicar nada.)
///
/// Integridad: una parcela o una zona con cosechas **no se puede borrar**
/// (son registros del cuaderno). Borrar un lote deja el secado o la
/// destilación sin lote (SET NULL), nunca al revés.
class BaseDatosSoleraAromaticas extends BaseDatosSolera {
  static final BaseDatosSoleraAromaticas instancia =
      BaseDatosSoleraAromaticas._interno();
  factory BaseDatosSoleraAromaticas() => instancia;
  BaseDatosSoleraAromaticas._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosAromaticas;

  @override
  int get versionEsquema => versionEsquemaAromaticas;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaAromaticasV1) {
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

  /// Filtro opcional por una columna igual a un valor y por fechas.
  Future<List<Map<String, Object?>>> _listarRegistros(
    String tabla, {
    String columnaFecha = 'fecha_ms',
    String? columnaFiltro,
    Object? valorFiltro,
    int? desdeMs,
    int? hastaMs,
  }) {
    final condiciones = <String>[
      if (valorFiltro != null) '$columnaFiltro = ?',
      if (desdeMs != null) '$columnaFecha >= ?',
      if (hastaMs != null) '$columnaFecha <= ?',
    ];
    return _listar(tabla,
        donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
        argumentos: [
          if (valorFiltro != null) valorFiltro,
          if (desdeMs != null) desdeMs,
          if (hastaMs != null) hastaMs,
        ],
        orden: '$columnaFecha DESC, id DESC');
  }

  // ─── Titular ─────────────────────────────────────────────────────

  Future<Titular> obtenerTitular() async {
    final filas = await _listar('titulares', orden: 'id');
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }

  // ─── Parcelas y zonas de recolección ─────────────────────────────

  Future<int> guardarParcela(Parcela parcela) =>
      _guardar('parcelas', parcela.toMap());

  Future<List<Parcela>> listarParcelas() async =>
      (await _listar('parcelas', orden: 'nombre COLLATE NOCASE'))
          .map(Parcela.fromMap)
          .toList();

  /// Lanza si la parcela tiene cosechas o tratamientos (FK RESTRICT).
  Future<void> borrarParcela(int parcelaId) => _borrar('parcelas', parcelaId);

  Future<int> guardarZonaRecoleccion(ZonaRecoleccion zona) =>
      _guardar('zonas_recoleccion', zona.toMap());

  Future<List<ZonaRecoleccion>> listarZonasRecoleccion() async =>
      (await _listar('zonas_recoleccion', orden: 'nombre COLLATE NOCASE'))
          .map(ZonaRecoleccion.fromMap)
          .toList();

  /// Lanza si la zona tiene recolecciones apuntadas (FK RESTRICT).
  Future<void> borrarZonaRecoleccion(int zonaId) =>
      _borrar('zonas_recoleccion', zonaId);

  // ─── Cosechas ────────────────────────────────────────────────────

  Future<int> guardarCosecha(Cosecha cosecha) =>
      _guardar('cosechas', cosecha.toMap());

  Future<void> borrarCosecha(int cosechaId) => _borrar('cosechas', cosechaId);

  Future<List<Cosecha>> listarCosechas(
      {int? parcelaId, int? zonaId, int? desdeMs, int? hastaMs}) async {
    final filas = zonaId != null
        ? await _listarRegistros('cosechas',
            columnaFiltro: 'zona_recoleccion_id',
            valorFiltro: zonaId,
            desdeMs: desdeMs,
            hastaMs: hastaMs)
        : await _listarRegistros('cosechas',
            columnaFiltro: 'parcela_id',
            valorFiltro: parcelaId,
            desdeMs: desdeMs,
            hastaMs: hastaMs);
    return filas.map(Cosecha.fromMap).toList();
  }

  // ─── Secado, destilación y lotes ─────────────────────────────────

  Future<int> guardarSecado(Secado secado) =>
      _guardar('secados', secado.toMap());

  Future<void> borrarSecado(int secadoId) => _borrar('secados', secadoId);

  Future<List<Secado>> listarSecados({int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('secados',
              columnaFecha: 'fecha_inicio_ms',
              desdeMs: desdeMs,
              hastaMs: hastaMs))
          .map(Secado.fromMap)
          .toList();

  Future<int> guardarDestilacion(Destilacion destilacion) =>
      _guardar('destilaciones', destilacion.toMap());

  Future<void> borrarDestilacion(int destilacionId) =>
      _borrar('destilaciones', destilacionId);

  Future<List<Destilacion>> listarDestilaciones(
          {int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('destilaciones',
              desdeMs: desdeMs, hastaMs: hastaMs))
          .map(Destilacion.fromMap)
          .toList();

  /// Lanza si el código ya existe (UNIQUE).
  Future<int> guardarLoteProducto(LoteProducto lote) =>
      _guardar('lotes_producto', lote.toMap());

  Future<void> borrarLoteProducto(int loteId) =>
      _borrar('lotes_producto', loteId);

  Future<List<LoteProducto>> listarLotesProducto(
          {int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('lotes_producto',
              desdeMs: desdeMs, hastaMs: hastaMs))
          .map(LoteProducto.fromMap)
          .toList();

  // ─── Tratamientos ────────────────────────────────────────────────

  Future<int> guardarTratamiento(Tratamiento tratamiento) =>
      _guardar('tratamientos', tratamiento.toMap());

  Future<void> borrarTratamiento(int tratamientoId) =>
      _borrar('tratamientos', tratamientoId);

  Future<List<Tratamiento>> listarTratamientos(
          {int? parcelaId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('tratamientos',
              columnaFiltro: 'parcela_id',
              valorFiltro: parcelaId,
              desdeMs: desdeMs,
              hastaMs: hastaMs))
          .map(Tratamiento.fromMap)
          .toList();

  // ─── Economía ────────────────────────────────────────────────────

  Future<ConfiguracionFiscal> obtenerConfiguracionFiscal() async {
    final filas = await _listar('configuraciones_fiscales', orden: 'id');
    return filas.isEmpty
        ? ConfiguracionFiscal()
        : ConfiguracionFiscal.fromMap(filas.first);
  }

  Future<void> guardarConfiguracionFiscal(
      ConfiguracionFiscal configuracion) async {
    await guardarFilaUnica('configuraciones_fiscales', configuracion.toMap());
  }

  Future<int> guardarApunteEconomico(ApunteEconomico apunte) =>
      _guardar('apuntes_economicos', apunte.toMap());

  Future<void> borrarApunteEconomico(int apunteId) =>
      _borrar('apuntes_economicos', apunteId);

  Future<List<ApunteEconomico>> listarApuntesEconomicos(
          {required int desdeMs, required int hastaMs}) async =>
      (await _listarRegistros('apuntes_economicos',
              desdeMs: desdeMs, hastaMs: hastaMs))
          .map(ApunteEconomico.fromMap)
          .toList();
}
