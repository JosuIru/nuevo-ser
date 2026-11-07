import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/bancal.dart';
import '../modelos/cosecha.dart';
import '../modelos/cultivo.dart';
import '../modelos/insumo.dart';
import '../modelos/lote_semilla.dart';
import '../modelos/parcela.dart';
import '../modelos/siembra.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../provisional_core/venta_directa/cesta.dart';
import '../provisional_core/venta_directa/entrega.dart';
import '../provisional_core/venta_directa/socio.dart';
import '../provisional_core/venta_directa/suscripcion.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosHuerta = 'solera_huerta.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaHuerta = 1;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaHuertaV1 = [
  '''CREATE TABLE titulares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL DEFAULT '',
    nif TEXT NOT NULL DEFAULT '',
    nombre_huerta TEXT NOT NULL DEFAULT '',
    registro_explotacion TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    comunidad_autonoma TEXT NOT NULL DEFAULT '',
    organismo_control TEXT NOT NULL DEFAULT '',
    codigo_operador_ecologico TEXT NOT NULL DEFAULT '',
    asesor_nombre TEXT NOT NULL DEFAULT '',
    asesor_numero_ropo TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE parcelas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    codigo_sigpac TEXT NOT NULL DEFAULT '',
    superficie_ha REAL NOT NULL DEFAULT 0,
    estado_ecologico TEXT NOT NULL DEFAULT 'ecologica',
    fecha_inicio_conversion_ms INTEGER,
    regadio INTEGER NOT NULL DEFAULT 1,
    sistema_riego TEXT NOT NULL DEFAULT '',
    latitud REAL,
    longitud REAL,
    notas TEXT NOT NULL DEFAULT '',
    fecha_creacion_ms INTEGER NOT NULL DEFAULT 0
  )''',
  '''CREATE TABLE bancales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    largo_m REAL,
    ancho_m REAL,
    invernadero INTEGER NOT NULL DEFAULT 0,
    activo INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE cultivos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    especie_id TEXT NOT NULL,
    familia_id TEXT NOT NULL DEFAULT '',
    variedad TEXT NOT NULL DEFAULT '',
    variedad_local INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE lotes_semilla (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL,
    especie_id TEXT NOT NULL,
    variedad TEXT NOT NULL DEFAULT '',
    origen TEXT NOT NULL DEFAULT 'ecologica',
    proveedor TEXT NOT NULL DEFAULT '',
    anyo_obtencion INTEGER,
    cantidad TEXT NOT NULL DEFAULT '',
    germinacion_pct REAL,
    numero_autorizacion TEXT NOT NULL DEFAULT '',
    cosecha_origen_id INTEGER REFERENCES cosechas(id) ON DELETE SET NULL,
    fecha_ms INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE siembras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bancal_id INTEGER NOT NULL REFERENCES bancales(id) ON DELETE RESTRICT,
    cultivo_id INTEGER NOT NULL REFERENCES cultivos(id) ON DELETE RESTRICT,
    tipo TEXT NOT NULL DEFAULT 'siembra_directa',
    fecha_prevista_ms INTEGER NOT NULL,
    fecha_real_ms INTEGER,
    lote_semilla_id INTEGER REFERENCES lotes_semilla(id) ON DELETE RESTRICT,
    cantidad REAL,
    unidad TEXT NOT NULL DEFAULT 'plantas',
    superficie_m2 REAL,
    inicio_cosecha_prevista_ms INTEGER,
    kg_previstos REAL,
    fecha_levantada_ms INTEGER,
    serie_escalonada TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE cosechas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bancal_id INTEGER NOT NULL REFERENCES bancales(id) ON DELETE RESTRICT,
    cultivo_id INTEGER NOT NULL REFERENCES cultivos(id) ON DELETE RESTRICT,
    siembra_id INTEGER REFERENCES siembras(id) ON DELETE SET NULL,
    fecha_ms INTEGER NOT NULL,
    kg REAL NOT NULL DEFAULT 0,
    unidades INTEGER,
    destino TEXT NOT NULL DEFAULT 'cestas',
    lote_cosecha TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE insumos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'fertilizante',
    categoria_ecologica_id TEXT NOT NULL DEFAULT '',
    permitido_ecologico INTEGER NOT NULL DEFAULT 0,
    justificante_permitido TEXT NOT NULL DEFAULT '',
    numero_registro TEXT NOT NULL DEFAULT '',
    proveedor TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE tratamientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parcela_id INTEGER NOT NULL REFERENCES parcelas(id) ON DELETE RESTRICT,
    bancal_id INTEGER REFERENCES bancales(id) ON DELETE RESTRICT,
    insumo_id INTEGER NOT NULL REFERENCES insumos(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    superficie_tratada_m2 REAL,
    problema TEXT NOT NULL DEFAULT '',
    sustancia_activa_id TEXT NOT NULL DEFAULT '',
    dosis_aplicada TEXT NOT NULL DEFAULT '',
    cantidad_total TEXT NOT NULL DEFAULT '',
    plazo_seguridad_dias INTEGER,
    aplicador_nombre TEXT NOT NULL DEFAULT '',
    carnet_aplicador TEXT NOT NULL DEFAULT '',
    equipo_aplicacion TEXT NOT NULL DEFAULT '',
    eficacia TEXT NOT NULL DEFAULT '',
    observaciones TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE socios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    telefono TEXT NOT NULL DEFAULT '',
    correo TEXT NOT NULL DEFAULT '',
    grupo_consumo TEXT NOT NULL DEFAULT '',
    punto_entrega TEXT NOT NULL DEFAULT '',
    activo INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE suscripciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    socio_id INTEGER NOT NULL REFERENCES socios(id) ON DELETE RESTRICT,
    tamano TEXT NOT NULL DEFAULT 'mediana',
    frecuencia TEXT NOT NULL DEFAULT 'semanal',
    fecha_inicio_ms INTEGER NOT NULL,
    fecha_fin_ms INTEGER,
    precio_centimos_cesta INTEGER NOT NULL DEFAULT 0,
    activa INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE cestas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    suscripcion_id INTEGER NOT NULL REFERENCES suscripciones(id) ON DELETE RESTRICT,
    semana_lunes_ms INTEGER NOT NULL,
    estado TEXT NOT NULL DEFAULT 'prevista',
    notas TEXT NOT NULL DEFAULT '',
    UNIQUE (suscripcion_id, semana_lunes_ms)
  )''',
  '''CREATE TABLE lineas_cesta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cesta_id INTEGER NOT NULL REFERENCES cestas(id) ON DELETE CASCADE,
    cultivo_id INTEGER NOT NULL REFERENCES cultivos(id) ON DELETE RESTRICT,
    kg REAL NOT NULL DEFAULT 0,
    unidades INTEGER
  )''',
  '''CREATE TABLE entregas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cesta_id INTEGER NOT NULL REFERENCES cestas(id) ON DELETE CASCADE,
    fecha_ms INTEGER NOT NULL,
    resultado TEXT NOT NULL DEFAULT 'entregada',
    recogida_por TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  'CREATE INDEX idx_bancales_parcela ON bancales(parcela_id)',
  'CREATE INDEX idx_siembras_bancal ON siembras(bancal_id, fecha_prevista_ms)',
  'CREATE INDEX idx_cosechas_fecha ON cosechas(fecha_ms)',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  'CREATE INDEX idx_cestas_semana ON cestas(semana_lunes_ms)',
  'CREATE INDEX idx_lineas_cesta ON lineas_cesta(cesta_id)',
  'CREATE INDEX idx_entregas_cesta ON entregas(cesta_id)',
];

/// Base de datos local de Larrea Huerta. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplía durante la F1, antes de publicar nada.)
///
/// Integridad: los registros del cuaderno (siembras, cosechas,
/// tratamientos) y las cestas **impiden borrar** lo que citan (bancal,
/// cultivo, lote, insumo, suscripción): lo que deja de usarse se desactiva.
class BaseDatosSoleraHuerta extends BaseDatosSolera {
  static final BaseDatosSoleraHuerta instancia =
      BaseDatosSoleraHuerta._interno();
  factory BaseDatosSoleraHuerta() => instancia;
  BaseDatosSoleraHuerta._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosHuerta;

  @override
  int get versionEsquema => versionEsquemaHuerta;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaHuertaV1) {
      await db.execute(sentencia);
    }
  }

  // ─── Utilidades ──────────────────────────────────────────────────

  /// Inserta si `id` es nulo, actualiza si no. Devuelve el id.
  Future<int> _guardar(String tabla, Map<String, Object?> mapa,
      {DatabaseExecutor? ejecutor}) async {
    final db = ejecutor ?? await basedatos;
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

  /// Filtro opcional por una columna y por intervalo de [columnaFecha].
  Future<List<Map<String, Object?>>> _listarRegistros(
    String tabla, {
    String columnaFecha = 'fecha_ms',
    String? columnaFiltro,
    int? valorFiltro,
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

  // ─── Parcelas y bancales ─────────────────────────────────────────

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

  /// Se lleva sus bancales; lanza si algún bancal o la parcela tienen
  /// registros del cuaderno (FK RESTRICT).
  Future<void> borrarParcela(int parcelaId) => _borrar('parcelas', parcelaId);

  Future<int> guardarBancal(Bancal bancal) =>
      _guardar('bancales', bancal.toMap());

  /// Lanza si el bancal tiene siembras, cosechas o tratamientos.
  Future<void> borrarBancal(int bancalId) => _borrar('bancales', bancalId);

  Future<List<Bancal>> listarBancales(
          {int? parcelaId, bool soloActivos = false}) async =>
      (await _listar('bancales',
              donde: [
                if (parcelaId != null) 'parcela_id = ?',
                if (soloActivos) 'activo = 1',
              ].join(' AND ').vacioComoNulo,
              argumentos: [if (parcelaId != null) parcelaId],
              orden: 'parcela_id, nombre COLLATE NOCASE'))
          .map(Bancal.fromMap)
          .toList();

  // ─── Cultivos y semillas ─────────────────────────────────────────

  Future<int> guardarCultivo(Cultivo cultivo) =>
      _guardar('cultivos', cultivo.toMap());

  Future<void> borrarCultivo(int cultivoId) => _borrar('cultivos', cultivoId);

  Future<List<Cultivo>> listarCultivos() async =>
      (await _listar('cultivos', orden: 'especie_id, variedad COLLATE NOCASE'))
          .map(Cultivo.fromMap)
          .toList();

  Future<int> guardarLoteSemilla(LoteSemilla lote) =>
      _guardar('lotes_semilla', lote.toMap());

  Future<void> borrarLoteSemilla(int loteId) =>
      _borrar('lotes_semilla', loteId);

  Future<List<LoteSemilla>> listarLotesSemilla() async =>
      (await _listar('lotes_semilla', orden: 'fecha_ms DESC, id DESC'))
          .map(LoteSemilla.fromMap)
          .toList();

  // ─── Siembras y cosechas ─────────────────────────────────────────

  Future<int> guardarSiembra(Siembra siembra) =>
      _guardar('siembras', siembra.toMap());

  /// Guarda una serie escalonada entera en una transacción.
  Future<List<int>> guardarSiembras(List<Siembra> siembras) async {
    final db = await basedatos;
    return db.transaction((transaccion) async => [
          for (final siembra in siembras)
            await _guardar('siembras', siembra.toMap(), ejecutor: transaccion),
        ]);
  }

  Future<void> borrarSiembra(int siembraId) => _borrar('siembras', siembraId);

  Future<List<Siembra>> listarSiembras(
          {int? bancalId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('siembras',
              columnaFecha: 'fecha_prevista_ms',
              columnaFiltro: 'bancal_id',
              valorFiltro: bancalId,
              desdeMs: desdeMs,
              hastaMs: hastaMs))
          .map(Siembra.fromMap)
          .toList();

  Future<int> guardarCosecha(Cosecha cosecha) =>
      _guardar('cosechas', cosecha.toMap());

  Future<void> borrarCosecha(int cosechaId) => _borrar('cosechas', cosechaId);

  Future<List<Cosecha>> listarCosechas(
          {int? bancalId, int? desdeMs, int? hastaMs}) async =>
      (await _listarRegistros('cosechas',
              columnaFiltro: 'bancal_id',
              valorFiltro: bancalId,
              desdeMs: desdeMs,
              hastaMs: hastaMs))
          .map(Cosecha.fromMap)
          .toList();

  // ─── Insumos y tratamientos ──────────────────────────────────────

  Future<int> guardarInsumo(Insumo insumo) =>
      _guardar('insumos', insumo.toMap());

  Future<void> borrarInsumo(int insumoId) => _borrar('insumos', insumoId);

  Future<List<Insumo>> listarInsumos() async =>
      (await _listar('insumos', orden: 'nombre COLLATE NOCASE'))
          .map(Insumo.fromMap)
          .toList();

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

  // ─── Cestas (venta directa, provisional_core) ────────────────────

  Future<int> guardarSocio(Socio socio) => _guardar('socios', socio.toMap());

  /// Lanza si tiene suscripciones: un socio que se va se desactiva.
  Future<void> borrarSocio(int socioId) => _borrar('socios', socioId);

  Future<List<Socio>> listarSocios({bool soloActivos = false}) async =>
      (await _listar('socios',
              donde: soloActivos ? 'activo = 1' : null,
              orden: 'nombre COLLATE NOCASE'))
          .map(Socio.fromMap)
          .toList();

  Future<int> guardarSuscripcion(Suscripcion suscripcion) =>
      _guardar('suscripciones', suscripcion.toMap());

  Future<void> borrarSuscripcion(int suscripcionId) =>
      _borrar('suscripciones', suscripcionId);

  Future<List<Suscripcion>> listarSuscripciones({int? socioId}) async =>
      (await _listar('suscripciones',
              donde: socioId == null ? null : 'socio_id = ?',
              argumentos: socioId == null ? null : [socioId],
              orden: 'fecha_inicio_ms DESC, id DESC'))
          .map(Suscripcion.fromMap)
          .toList();

  Future<List<Cesta>> listarCestas(
          {int? semanaLunesMs, int? desdeMs, int? hastaMs}) async =>
      (await _listar('cestas',
              donde: [
                if (semanaLunesMs != null) 'semana_lunes_ms = ?',
                if (desdeMs != null) 'semana_lunes_ms >= ?',
                if (hastaMs != null) 'semana_lunes_ms <= ?',
              ].join(' AND ').vacioComoNulo,
              argumentos: [
                if (semanaLunesMs != null) semanaLunesMs,
                if (desdeMs != null) desdeMs,
                if (hastaMs != null) hastaMs,
              ],
              orden: 'semana_lunes_ms DESC, id'))
          .map(Cesta.fromMap)
          .toList();

  Future<int> guardarCesta(Cesta cesta) => _guardar('cestas', cesta.toMap());

  /// Guarda la cesta y **sustituye** todas sus líneas en una transacción.
  /// Si ya hay una cesta de esa suscripción y semana, la reutiliza.
  Future<int> guardarCestaConLineas(
      Cesta cesta, List<LineaCesta> lineas) async {
    final db = await basedatos;
    return db.transaction((transaccion) async {
      var cestaId = cesta.id;
      if (cestaId == null) {
        final existentes = await transaccion.query('cestas',
            columns: ['id'],
            where: 'suscripcion_id = ? AND semana_lunes_ms = ?',
            whereArgs: [cesta.suscripcionId, cesta.semanaLunesMs]);
        if (existentes.isNotEmpty) cestaId = existentes.first['id'] as int;
      }
      final mapa = cesta.toMap()..['id'] = cestaId;
      cestaId = await _guardar('cestas', mapa, ejecutor: transaccion);
      await transaccion
          .delete('lineas_cesta', where: 'cesta_id = ?', whereArgs: [cestaId]);
      for (final linea in lineas) {
        final mapaLinea = linea.toMap()
          ..remove('id')
          ..['cesta_id'] = cestaId;
        await transaccion.insert('lineas_cesta', mapaLinea);
      }
      return cestaId;
    });
  }

  /// Borra la cesta con sus líneas y entregas.
  Future<void> borrarCesta(int cestaId) => _borrar('cestas', cestaId);

  Future<List<LineaCesta>> listarLineasCesta({List<int>? cestaIds}) async {
    if (cestaIds != null && cestaIds.isEmpty) return const [];
    return (await _listar('lineas_cesta',
            donde: cestaIds == null
                ? null
                : 'cesta_id IN (${List.filled(cestaIds.length, '?').join(',')})',
            argumentos: cestaIds,
            orden: 'cesta_id, id'))
        .map(LineaCesta.fromMap)
        .toList();
  }

  Future<int> guardarEntrega(Entrega entrega) =>
      _guardar('entregas', entrega.toMap());

  Future<void> borrarEntrega(int entregaId) => _borrar('entregas', entregaId);

  Future<List<Entrega>> listarEntregas({List<int>? cestaIds}) async {
    if (cestaIds != null && cestaIds.isEmpty) return const [];
    return (await _listar('entregas',
            donde: cestaIds == null
                ? null
                : 'cesta_id IN (${List.filled(cestaIds.length, '?').join(',')})',
            argumentos: cestaIds,
            orden: 'fecha_ms DESC, id DESC'))
        .map(Entrega.fromMap)
        .toList();
  }
}

extension on String {
  /// Una condición WHERE vacía es «sin filtro».
  String? get vacioComoNulo => isEmpty ? null : this;
}
