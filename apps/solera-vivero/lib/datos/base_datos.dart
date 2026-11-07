import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/bandeja.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/inspeccion_plagas.dart';
import '../modelos/lote_material.dart';
import '../modelos/partida_planta.dart';
import '../modelos/pasaporte_emitido.dart';
import '../modelos/repicado.dart';
import '../modelos/salida.dart';
import '../modelos/siembra.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vivero.dart';
import '../modelos/zona_cultivo.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosVivero = 'solera_vivero.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaVivero = 1;

/// Sentencias del esquema v1. Públicas para los tests de contrato.
const List<String> sentenciasEsquemaViveroV1 = [
  '''CREATE TABLE viveros (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL DEFAULT '',
    nif TEXT NOT NULL DEFAULT '',
    codigo_ropveg TEXT NOT NULL DEFAULT '',
    autorizado_pasaporte INTEGER NOT NULL DEFAULT 0,
    comunidad_autonoma TEXT NOT NULL DEFAULT '',
    municipio TEXT NOT NULL DEFAULT '',
    persona_contacto_fitosanitaria TEXT NOT NULL DEFAULT '',
    registro_explotacion TEXT NOT NULL DEFAULT '',
    asesor_nombre TEXT NOT NULL DEFAULT '',
    asesor_numero_ropo TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE zonas_cultivo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'nave',
    superficie_m2 REAL,
    codigo_sigpac TEXT NOT NULL DEFAULT '',
    latitud REAL,
    longitud REAL,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE lotes_material (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,
    tipo TEXT NOT NULL DEFAULT 'semilla',
    especie_id TEXT NOT NULL,
    nombre_botanico TEXT NOT NULL DEFAULT '',
    variedad TEXT NOT NULL DEFAULT '',
    es_propio INTEGER NOT NULL DEFAULT 0,
    proveedor_nombre TEXT NOT NULL DEFAULT '',
    proveedor_codigo_ropveg TEXT NOT NULL DEFAULT '',
    pasaporte_recibido TEXT NOT NULL DEFAULT '',
    pais_origen TEXT NOT NULL DEFAULT 'ES',
    fecha_entrada_ms INTEGER NOT NULL,
    cantidad REAL NOT NULL DEFAULT 0,
    unidad TEXT NOT NULL DEFAULT 'uds',
    categoria_forestal TEXT NOT NULL DEFAULT '',
    region_procedencia TEXT NOT NULL DEFAULT '',
    certificado_patron TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE bandejas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo_qr TEXT NOT NULL UNIQUE,
    formato TEXT NOT NULL DEFAULT 'alveolo',
    numero_alveolos INTEGER NOT NULL DEFAULT 0,
    zona_id INTEGER REFERENCES zonas_cultivo(id) ON DELETE SET NULL,
    ubicacion TEXT NOT NULL DEFAULT '',
    activa INTEGER NOT NULL DEFAULT 1,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE siembras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lote_material_id INTEGER NOT NULL REFERENCES lotes_material(id) ON DELETE RESTRICT,
    bandeja_id INTEGER NOT NULL REFERENCES bandejas(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    metodo TEXT NOT NULL DEFAULT 'siembra',
    alveolos_ocupados INTEGER NOT NULL DEFAULT 0,
    unidades_por_alveolo INTEGER NOT NULL DEFAULT 1,
    cantidad_material_usada REAL NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE partidas_planta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,
    especie_id TEXT NOT NULL,
    nombre_botanico TEXT NOT NULL DEFAULT '',
    variedad TEXT NOT NULL DEFAULT '',
    formato TEXT NOT NULL DEFAULT 'alveolo',
    cantidad_inicial INTEGER NOT NULL DEFAULT 0,
    mermas INTEGER NOT NULL DEFAULT 0,
    siembra_id INTEGER REFERENCES siembras(id) ON DELETE RESTRICT,
    partida_origen_id INTEGER REFERENCES partidas_planta(id) ON DELETE RESTRICT,
    bandeja_id INTEGER REFERENCES bandejas(id) ON DELETE SET NULL,
    zona_id INTEGER REFERENCES zonas_cultivo(id) ON DELETE SET NULL,
    pais_origen TEXT NOT NULL DEFAULT 'ES',
    fecha_alta_ms INTEGER NOT NULL,
    lista_para_venta INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE repicados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    partida_origen_id INTEGER NOT NULL REFERENCES partidas_planta(id) ON DELETE RESTRICT,
    partida_destino_id INTEGER NOT NULL REFERENCES partidas_planta(id) ON DELETE CASCADE,
    fecha_ms INTEGER NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE salidas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    partida_id INTEGER NOT NULL REFERENCES partidas_planta(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 0,
    cliente_nombre TEXT NOT NULL DEFAULT '',
    cliente_nif TEXT NOT NULL DEFAULT '',
    cliente_codigo_ropveg TEXT NOT NULL DEFAULT '',
    es_usuario_final INTEGER NOT NULL DEFAULT 0,
    es_venta_a_distancia INTEGER NOT NULL DEFAULT 0,
    destino_zona_protegida INTEGER NOT NULL DEFAULT 0,
    es_traslado_propio_misma_comunidad INTEGER NOT NULL DEFAULT 0,
    codigo_trazabilidad TEXT NOT NULL DEFAULT '',
    importe_centimos INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE pasaportes_emitidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    salida_id INTEGER NOT NULL REFERENCES salidas(id) ON DELETE RESTRICT,
    fecha_ms INTEGER NOT NULL,
    es_zona_protegida INTEGER NOT NULL DEFAULT 0,
    nombre_botanico TEXT NOT NULL,
    variedad TEXT NOT NULL DEFAULT '',
    codigo_operador TEXT NOT NULL,
    codigo_trazabilidad TEXT NOT NULL,
    pais_origen TEXT NOT NULL,
    plagas_zona_protegida TEXT NOT NULL DEFAULT '',
    cantidad INTEGER NOT NULL DEFAULT 0,
    preparado_por TEXT NOT NULL DEFAULT '',
    es_borrador INTEGER NOT NULL DEFAULT 1,
    anulado INTEGER NOT NULL DEFAULT 0,
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE tratamientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_ms INTEGER NOT NULL,
    partida_id INTEGER REFERENCES partidas_planta(id) ON DELETE RESTRICT,
    zona_id INTEGER REFERENCES zonas_cultivo(id) ON DELETE RESTRICT,
    superficie_tratada_m2 REAL,
    problema_fitosanitario TEXT NOT NULL DEFAULT '',
    sustancia_activa_id TEXT NOT NULL DEFAULT '',
    nombre_producto TEXT NOT NULL DEFAULT '',
    numero_registro_producto TEXT NOT NULL DEFAULT '',
    dosis_aplicada TEXT NOT NULL DEFAULT '',
    cantidad_producto TEXT NOT NULL DEFAULT '',
    plazo_seguridad_dias INTEGER,
    aplicador_nombre TEXT NOT NULL DEFAULT '',
    carnet_aplicador TEXT NOT NULL DEFAULT '',
    equipo_aplicacion TEXT NOT NULL DEFAULT '',
    eficacia TEXT NOT NULL DEFAULT '',
    observaciones TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE inspecciones_plagas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_ms INTEGER NOT NULL,
    partida_id INTEGER REFERENCES partidas_planta(id) ON DELETE RESTRICT,
    zona_id INTEGER REFERENCES zonas_cultivo(id) ON DELETE RESTRICT,
    plaga_id TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'autoinspeccion',
    inspector_nombre TEXT NOT NULL DEFAULT '',
    resultado TEXT NOT NULL DEFAULT 'no_detectada',
    muestra_tomada INTEGER NOT NULL DEFAULT 0,
    notificada_autoridad INTEGER NOT NULL DEFAULT 0,
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
    tercero TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT ''
  )''',
  '''CREATE TABLE configuraciones_fiscales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    regimen_iva TEXT NOT NULL DEFAULT 'sin_elegir'
  )''',
  'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
  'CREATE INDEX idx_bandejas_qr ON bandejas(codigo_qr)',
  'CREATE INDEX idx_siembras_bandeja ON siembras(bandeja_id)',
  'CREATE INDEX idx_partidas_siembra ON partidas_planta(siembra_id)',
  'CREATE INDEX idx_repicados_origen ON repicados(partida_origen_id)',
  'CREATE INDEX idx_salidas_fecha ON salidas(fecha_ms)',
  'CREATE INDEX idx_salidas_partida ON salidas(partida_id)',
  'CREATE INDEX idx_pasaportes_fecha ON pasaportes_emitidos(fecha_ms)',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  'CREATE INDEX idx_inspecciones_fecha ON inspecciones_plagas(fecha_ms)',
];

/// Base de datos local de Larrea Vivero. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplía durante la F1, antes de publicar nada.)
///
/// Integridad (es la trazabilidad, que se guarda tres años): un lote con
/// siembras, una bandeja con siembras, una partida con salidas, repicados,
/// tratamientos o inspecciones, y una salida con pasaporte **no se pueden
/// borrar** (`ON DELETE RESTRICT`). Las bandejas se retiran (`activa`).
class BaseDatosSoleraVivero extends BaseDatosSolera {
  static final BaseDatosSoleraVivero instancia =
      BaseDatosSoleraVivero._interno();
  factory BaseDatosSoleraVivero() => instancia;
  BaseDatosSoleraVivero._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosVivero;

  @override
  int get versionEsquema => versionEsquemaVivero;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    for (final sentencia in sentenciasEsquemaViveroV1) {
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

  Future<Map<String, Object?>?> _porId(String tabla, int id) async {
    final filas = await _listar(tabla, donde: 'id = ?', argumentos: [id]);
    return filas.isEmpty ? null : filas.first;
  }

  Future<void> _borrar(String tabla, int id) async {
    final db = await basedatos;
    await db.delete(tabla, where: 'id = ?', whereArgs: [id]);
  }

  /// Filtro opcional por intervalo de fechas, del más reciente.
  Future<List<Map<String, Object?>>> _listarPorFecha(
    String tabla, {
    int? desdeMs,
    int? hastaMs,
    String? condicionExtra,
    List<Object?> argumentosExtra = const [],
  }) {
    final condiciones = <String>[
      if (condicionExtra != null) condicionExtra,
      if (desdeMs != null) 'fecha_ms >= ?',
      if (hastaMs != null) 'fecha_ms <= ?',
    ];
    return _listar(tabla,
        donde: condiciones.isEmpty ? null : condiciones.join(' AND '),
        argumentos: [
          ...argumentosExtra,
          if (desdeMs != null) desdeMs,
          if (hastaMs != null) hastaMs,
        ],
        orden: 'fecha_ms DESC, id DESC');
  }

  // ─── Vivero ──────────────────────────────────────────────────────

  Future<Vivero> obtenerVivero() async {
    final filas = await _listar('viveros', orden: 'id');
    return filas.isEmpty ? Vivero() : Vivero.fromMap(filas.first);
  }

  Future<void> guardarVivero(Vivero vivero) async {
    await guardarFilaUnica('viveros', vivero.toMap());
  }

  // ─── Zonas ───────────────────────────────────────────────────────

  Future<int> guardarZona(ZonaCultivo zona) =>
      _guardar('zonas_cultivo', zona.toMap());

  Future<List<ZonaCultivo>> listarZonas() async =>
      (await _listar('zonas_cultivo', orden: 'nombre COLLATE NOCASE'))
          .map(ZonaCultivo.fromMap)
          .toList();

  /// Lanza si la zona tiene tratamientos o inspecciones.
  Future<void> borrarZona(int zonaId) => _borrar('zonas_cultivo', zonaId);

  // ─── Lotes de material ───────────────────────────────────────────

  Future<int> guardarLoteMaterial(LoteMaterial lote) =>
      _guardar('lotes_material', lote.toMap());

  Future<List<LoteMaterial>> listarLotesMaterial() async =>
      (await _listar('lotes_material', orden: 'fecha_entrada_ms DESC, id DESC'))
          .map(LoteMaterial.fromMap)
          .toList();

  Future<LoteMaterial?> obtenerLoteMaterial(int loteId) async {
    final fila = await _porId('lotes_material', loteId);
    return fila == null ? null : LoteMaterial.fromMap(fila);
  }

  /// Lanza si el lote tiene siembras.
  Future<void> borrarLoteMaterial(int loteId) =>
      _borrar('lotes_material', loteId);

  // ─── Bandejas ────────────────────────────────────────────────────

  Future<int> guardarBandeja(Bandeja bandeja) =>
      _guardar('bandejas', bandeja.toMap());

  Future<List<Bandeja>> listarBandejas({bool soloActivas = false}) async =>
      (await _listar('bandejas',
              donde: soloActivas ? 'activa = 1' : null, orden: 'codigo_qr'))
          .map(Bandeja.fromMap)
          .toList();

  Future<Bandeja?> obtenerBandeja(int bandejaId) async {
    final fila = await _porId('bandejas', bandejaId);
    return fila == null ? null : Bandeja.fromMap(fila);
  }

  /// Búsqueda directa por el contenido del QR (patrón de Arbolado urbano).
  Future<Bandeja?> obtenerBandejaPorQr(String contenidoQr) async {
    final codigo = contenidoQr.trim();
    if (codigo.isEmpty) return null;
    final filas =
        await _listar('bandejas', donde: 'codigo_qr = ?', argumentos: [codigo]);
    return filas.isEmpty ? null : Bandeja.fromMap(filas.first);
  }

  /// Lanza si la bandeja tiene siembras (se retira con `activa = false`).
  Future<void> borrarBandeja(int bandejaId) => _borrar('bandejas', bandejaId);

  // ─── Siembras ────────────────────────────────────────────────────

  Future<int> guardarSiembra(Siembra siembra) =>
      _guardar('siembras', siembra.toMap());

  Future<List<Siembra>> listarSiembras(
          {int? bandejaId, int? loteMaterialId}) async =>
      (await _listarPorFecha('siembras',
              condicionExtra: bandejaId != null
                  ? 'bandeja_id = ?'
                  : loteMaterialId != null
                      ? 'lote_material_id = ?'
                      : null,
              argumentosExtra: [
            if (bandejaId != null)
              bandejaId
            else if (loteMaterialId != null)
              loteMaterialId,
          ]))
          .map(Siembra.fromMap)
          .toList();

  /// Siembra y su partida de planta en una transacción. Devuelve el id de
  /// la partida.
  Future<int> sembrar(Siembra siembra, PartidaPlanta partida) async {
    final db = await basedatos;
    return db.transaction((transaccion) async {
      final siembraId = await transaccion.insert(
          'siembras', Map<String, Object?>.of(siembra.toMap())..remove('id'));
      return transaccion.insert(
          'partidas_planta',
          Map<String, Object?>.of(partida.toMap())
            ..remove('id')
            ..['siembra_id'] = siembraId);
    });
  }

  /// Lanza si de la siembra ya salió una partida.
  Future<void> borrarSiembra(int siembraId) => _borrar('siembras', siembraId);

  // ─── Partidas, repicados y salidas ───────────────────────────────

  Future<int> guardarPartida(PartidaPlanta partida) =>
      _guardar('partidas_planta', partida.toMap());

  Future<List<PartidaPlanta>> listarPartidas({int? bandejaId}) async =>
      (await _listar('partidas_planta',
              donde: bandejaId == null ? null : 'bandeja_id = ?',
              argumentos: bandejaId == null ? null : [bandejaId],
              orden: 'fecha_alta_ms DESC, id DESC'))
          .map(PartidaPlanta.fromMap)
          .toList();

  Future<PartidaPlanta?> obtenerPartida(int partidaId) async {
    final fila = await _porId('partidas_planta', partidaId);
    return fila == null ? null : PartidaPlanta.fromMap(fila);
  }

  /// Lanza si la partida tiene salidas, repicados, tratamientos o
  /// inspecciones.
  Future<void> borrarPartida(int partidaId) =>
      _borrar('partidas_planta', partidaId);

  /// Repica: crea la partida de destino y el repicado en una transacción.
  /// Devuelve el id de la partida nueva.
  Future<int> repicar({
    required PartidaPlanta partidaDestino,
    required int partidaOrigenId,
    required int fechaMs,
    required int cantidad,
    String notas = '',
  }) async {
    final db = await basedatos;
    return db.transaction((transaccion) async {
      final destino = Map<String, Object?>.of(partidaDestino.toMap())
        ..remove('id')
        ..['partida_origen_id'] = partidaOrigenId;
      final destinoId = await transaccion.insert('partidas_planta', destino);
      await transaccion.insert(
          'repicados',
          Repicado(
                  partidaOrigenId: partidaOrigenId,
                  partidaDestinoId: destinoId,
                  fechaMs: fechaMs,
                  cantidad: cantidad,
                  notas: notas)
              .toMap()
            ..remove('id'));
      return destinoId;
    });
  }

  Future<List<Repicado>> listarRepicados() async =>
      (await _listarPorFecha('repicados')).map(Repicado.fromMap).toList();

  Future<int> guardarSalida(Salida salida) =>
      _guardar('salidas', salida.toMap());

  Future<List<Salida>> listarSalidas(
          {int? desdeMs, int? hastaMs, int? partidaId}) async =>
      (await _listarPorFecha('salidas',
              desdeMs: desdeMs,
              hastaMs: hastaMs,
              condicionExtra: partidaId == null ? null : 'partida_id = ?',
              argumentosExtra: [if (partidaId != null) partidaId]))
          .map(Salida.fromMap)
          .toList();

  Future<Salida?> obtenerSalida(int salidaId) async {
    final fila = await _porId('salidas', salidaId);
    return fila == null ? null : Salida.fromMap(fila);
  }

  /// Lanza si la salida tiene pasaporte registrado.
  Future<void> borrarSalida(int salidaId) => _borrar('salidas', salidaId);

  // ─── Pasaportes ──────────────────────────────────────────────────

  Future<int> guardarPasaporte(PasaporteEmitido pasaporte) =>
      _guardar('pasaportes_emitidos', pasaporte.toMap());

  Future<List<PasaporteEmitido>> listarPasaportes(
          {int? desdeMs, int? hastaMs, int? salidaId}) async =>
      (await _listarPorFecha('pasaportes_emitidos',
              desdeMs: desdeMs,
              hastaMs: hastaMs,
              condicionExtra: salidaId == null ? null : 'salida_id = ?',
              argumentosExtra: [if (salidaId != null) salidaId]))
          .map(PasaporteEmitido.fromMap)
          .toList();

  /// Un pasaporte no se borra nunca: se anula y se conserva.
  Future<void> anularPasaporte(PasaporteEmitido pasaporte) async {
    if (pasaporte.id == null) return;
    await _guardar('pasaportes_emitidos', pasaporte.copiarAnulado().toMap());
  }

  // ─── Tratamientos e inspecciones ─────────────────────────────────

  Future<int> guardarTratamiento(Tratamiento tratamiento) =>
      _guardar('tratamientos', tratamiento.toMap());

  Future<List<Tratamiento>> listarTratamientos(
          {int? desdeMs, int? hastaMs, int? partidaId}) async =>
      (await _listarPorFecha('tratamientos',
              desdeMs: desdeMs,
              hastaMs: hastaMs,
              condicionExtra: partidaId == null ? null : 'partida_id = ?',
              argumentosExtra: [if (partidaId != null) partidaId]))
          .map(Tratamiento.fromMap)
          .toList();

  Future<void> borrarTratamiento(int tratamientoId) =>
      _borrar('tratamientos', tratamientoId);

  Future<int> guardarInspeccion(InspeccionPlagas inspeccion) =>
      _guardar('inspecciones_plagas', inspeccion.toMap());

  Future<List<InspeccionPlagas>> listarInspecciones(
          {int? desdeMs, int? hastaMs, int? partidaId}) async =>
      (await _listarPorFecha('inspecciones_plagas',
              desdeMs: desdeMs,
              hastaMs: hastaMs,
              condicionExtra: partidaId == null ? null : 'partida_id = ?',
              argumentosExtra: [if (partidaId != null) partidaId]))
          .map(InspeccionPlagas.fromMap)
          .toList();

  Future<void> borrarInspeccion(int inspeccionId) =>
      _borrar('inspecciones_plagas', inspeccionId);

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
          {int? desdeMs, int? hastaMs}) async =>
      (await _listarPorFecha('apuntes_economicos',
              desdeMs: desdeMs, hastaMs: hastaMs))
          .map(ApunteEconomico.fromMap)
          .toList();
}
