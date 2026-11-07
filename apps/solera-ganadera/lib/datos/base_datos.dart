import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/explotacion.dart';
import '../modelos/ganado.dart';
import '../modelos/pieza_pasto.dart';
import '../modelos/tarea_sanitaria.dart';
import '../modelos/titular.dart';
import '../modelos/visita.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosGanadera = 'solera_ganadera.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaGanadera = 1;

/// Tablas de la v1, en el orden en que se exportan.
const List<String> tablasGanadera = [
  'titulares',
  'explotaciones',
  'piezas_pasto',
  'lotes_ganado',
  'animales',
  'movimientos_ganado',
  'eventos_ganado',
  'visitas',
  'tareas_sanitarias',
  'apuntes_economicos',
];

/// Base de datos local de Larrea Ganadera. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplió en el bloque 2, antes de publicar nada.)
///
/// No es el modelo sincronizable de Zunbeltz: sin `uid` ni `actualizado_ms`.
/// Lo que el libro de registro debe conservar (movimientos, eventos) no se
/// borra en cascada: un rebaño con historia se cierra, no se borra.
class BaseDatosSoleraGanadera extends BaseDatosSolera {
  static final BaseDatosSoleraGanadera instancia =
      BaseDatosSoleraGanadera._interno();
  factory BaseDatosSoleraGanadera() => instancia;
  BaseDatosSoleraGanadera._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosGanadera;

  @override
  int get versionEsquema => versionEsquemaGanadera;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    const sentencias = [
      '''CREATE TABLE titulares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        nif TEXT NOT NULL DEFAULT '',
        telefono TEXT NOT NULL DEFAULT '',
        correo TEXT NOT NULL DEFAULT '',
        direccion TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE explotaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_rega TEXT NOT NULL DEFAULT '',
        nombre TEXT NOT NULL DEFAULT '',
        direccion TEXT NOT NULL DEFAULT '',
        municipio TEXT NOT NULL DEFAULT '',
        provincia TEXT NOT NULL DEFAULT '',
        latitud REAL,
        longitud REAL,
        clasificacion TEXT NOT NULL DEFAULT '',
        capacidad_maxima INTEGER NOT NULL DEFAULT 0,
        especies TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE piezas_pasto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        recinto_sigpac TEXT NOT NULL DEFAULT '',
        superficie_ha REAL,
        tipo_pasto TEXT NOT NULL DEFAULT 'mediterraneo',
        titularidad TEXT NOT NULL DEFAULT 'propia',
        contorno TEXT NOT NULL DEFAULT '[]',
        activa INTEGER NOT NULL DEFAULT 1,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE lotes_ganado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        especie TEXT NOT NULL DEFAULT '',
        cabezas_sin_identificar INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'activo',
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        ecologico INTEGER NOT NULL DEFAULT 0,
        ciclo_corto INTEGER NOT NULL DEFAULT 0
      )''',
      '''CREATE TABLE animales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identificacion TEXT NOT NULL DEFAULT '',
        dispositivo TEXT NOT NULL DEFAULT 'crotal',
        nombre TEXT NOT NULL DEFAULT '',
        especie TEXT NOT NULL DEFAULT '',
        raza TEXT NOT NULL DEFAULT '',
        sexo TEXT NOT NULL DEFAULT '',
        fecha_nacimiento_ms INTEGER,
        madre TEXT NOT NULL DEFAULT '',
        lote_id INTEGER REFERENCES lotes_ganado(id) ON DELETE SET NULL,
        estado TEXT NOT NULL DEFAULT 'activo',
        fecha_baja_ms INTEGER,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE movimientos_ganado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER NOT NULL REFERENCES lotes_ganado(id) ON DELETE RESTRICT,
        fecha_ms INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        pieza_origen_id INTEGER REFERENCES piezas_pasto(id) ON DELETE RESTRICT,
        pieza_destino_id INTEGER REFERENCES piezas_pasto(id) ON DELETE RESTRICT,
        cabezas INTEGER NOT NULL DEFAULT 0,
        identificaciones TEXT NOT NULL DEFAULT '',
        explotacion_externa TEXT NOT NULL DEFAULT '',
        titular_externo TEXT NOT NULL DEFAULT '',
        municipio_externo TEXT NOT NULL DEFAULT '',
        provincia_externa TEXT NOT NULL DEFAULT '',
        codigo_remo TEXT NOT NULL DEFAULT '',
        fecha_llegada_prevista_ms INTEGER,
        codigo_transporte TEXT NOT NULL DEFAULT '',
        tipo_transporte TEXT NOT NULL DEFAULT '',
        autorizacion_transportista TEXT NOT NULL DEFAULT '',
        certificado_sanitario TEXT NOT NULL DEFAULT '',
        fecha_certificado_ms INTEGER,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE eventos_ganado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER REFERENCES animales(id) ON DELETE RESTRICT,
        lote_id INTEGER REFERENCES lotes_ganado(id) ON DELETE RESTRICT,
        fecha_ms INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL DEFAULT '',
        medicamento TEXT NOT NULL DEFAULT '',
        sustancia_activa TEXT NOT NULL DEFAULT '',
        clase_medicamento TEXT NOT NULL DEFAULT '',
        dosis TEXT NOT NULL DEFAULT '',
        duracion_dias INTEGER NOT NULL DEFAULT 0,
        plazo_supresion_carne_dias INTEGER NOT NULL DEFAULT 0,
        plazo_supresion_leche_dias INTEGER NOT NULL DEFAULT 0,
        veterinario TEXT NOT NULL DEFAULT '',
        receta TEXT NOT NULL DEFAULT '',
        proveedor TEXT NOT NULL DEFAULT '',
        prueba_compra TEXT NOT NULL DEFAULT '',
        peso_kg REAL,
        crias INTEGER NOT NULL DEFAULT 0,
        cabezas INTEGER NOT NULL DEFAULT 0,
        CHECK (animal_id IS NOT NULL OR lote_id IS NOT NULL)
      )''',
      '''CREATE TABLE visitas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_ms INTEGER NOT NULL,
        persona TEXT NOT NULL,
        motivo TEXT NOT NULL DEFAULT '',
        es_veterinaria INTEGER NOT NULL DEFAULT 0,
        vehiculo TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE tareas_sanitarias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'saneamiento',
        lote_id INTEGER REFERENCES lotes_ganado(id) ON DELETE SET NULL,
        fecha_prevista_ms INTEGER NOT NULL,
        hecha_ms INTEGER,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE apuntes_economicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        es_ingreso INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        concepto TEXT NOT NULL,
        categoria TEXT NOT NULL,
        base_centimos INTEGER NOT NULL,
        regimen TEXT NOT NULL DEFAULT 'iva',
        porcentaje REAL NOT NULL DEFAULT 0,
        tercero TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT ''
      )''',
      'CREATE INDEX idx_animales_lote ON animales(lote_id)',
      'CREATE INDEX idx_movimientos_lote ON movimientos_ganado(lote_id, fecha_ms)',
      'CREATE INDEX idx_eventos_fecha ON eventos_ganado(fecha_ms)',
      'CREATE INDEX idx_tareas_fecha ON tareas_sanitarias(fecha_prevista_ms)',
      'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
    ];
    for (final sentencia in sentencias) {
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

  // ─── Titular y explotación ───────────────────────────────────────

  Future<Titular> obtenerTitular() async {
    final filas = await _listar('titulares');
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }

  Future<Explotacion> obtenerExplotacion() async {
    final filas = await _listar('explotaciones');
    return filas.isEmpty ? Explotacion() : Explotacion.fromMap(filas.first);
  }

  Future<void> guardarExplotacion(Explotacion explotacion) async {
    await guardarFilaUnica('explotaciones', explotacion.toMap());
  }

  // ─── Piezas de pasto ─────────────────────────────────────────────

  Future<int> guardarPieza(PiezaPasto pieza) =>
      _guardar('piezas_pasto', pieza.toMap());

  Future<List<PiezaPasto>> listarPiezas({bool soloActivas = false}) async =>
      (await _listar('piezas_pasto',
              donde: soloActivas ? 'activa = 1' : null,
              orden: 'nombre COLLATE NOCASE'))
          .map(PiezaPasto.fromMap)
          .toList();

  /// Falla (FK) si algún movimiento la usa: entonces se desactiva.
  Future<void> borrarPieza(int piezaId) => _borrar('piezas_pasto', piezaId);

  // ─── Rebaños y animales ──────────────────────────────────────────

  Future<int> guardarLote(LoteGanado lote) =>
      _guardar('lotes_ganado', lote.toMap());

  Future<List<LoteGanado>> listarLotes({bool soloActivos = false}) async =>
      (await _listar('lotes_ganado',
              donde: soloActivos ? "estado != 'cerrado'" : null,
              orden: 'nombre COLLATE NOCASE'))
          .map(LoteGanado.fromMap)
          .toList();

  Future<int> guardarAnimal(Animal animal) =>
      _guardar('animales', animal.toMap());

  Future<List<Animal>> listarAnimales({int? loteId}) async =>
      (await _listar('animales',
              donde: loteId == null ? null : 'lote_id = ?',
              argumentos: loteId == null ? null : [loteId],
              orden: 'identificacion COLLATE NOCASE'))
          .map(Animal.fromMap)
          .toList();

  // ─── Movimientos y eventos ───────────────────────────────────────

  Future<int> guardarMovimiento(MovimientoGanado movimiento) =>
      _guardar('movimientos_ganado', movimiento.toMap());

  Future<void> borrarMovimiento(int movimientoId) =>
      _borrar('movimientos_ganado', movimientoId);

  Future<List<MovimientoGanado>> listarMovimientos(
          {int? loteId, int? desdeMs, int? hastaMs}) async =>
      (await _listar('movimientos_ganado',
              donde: [
                if (loteId != null) 'lote_id = ?',
                if (desdeMs != null) 'fecha_ms >= ?',
                if (hastaMs != null) 'fecha_ms <= ?',
              ].join(' AND ').nuloSiVacio,
              argumentos: [
                if (loteId != null) loteId,
                if (desdeMs != null) desdeMs,
                if (hastaMs != null) hastaMs,
              ],
              orden: 'fecha_ms ASC, id ASC'))
          .map(MovimientoGanado.fromMap)
          .toList();

  Future<int> guardarEvento(EventoGanado evento) =>
      _guardar('eventos_ganado', evento.toMap());

  Future<void> borrarEvento(int eventoId) =>
      _borrar('eventos_ganado', eventoId);

  /// Eventos de un animal y de su rebaño (o todos, sin filtros).
  Future<List<EventoGanado>> listarEventos({int? animalId, int? loteId}) async {
    final condiciones = [
      if (animalId != null) 'animal_id = ?',
      if (loteId != null) '(lote_id = ? AND animal_id IS NULL)',
    ];
    return (await _listar('eventos_ganado',
            donde: condiciones.isEmpty ? null : condiciones.join(' OR '),
            argumentos: [
              if (animalId != null) animalId,
              if (loteId != null) loteId,
            ],
            orden: 'fecha_ms DESC, id DESC'))
        .map(EventoGanado.fromMap)
        .toList();
  }

  // ─── Visitas y calendario sanitario ──────────────────────────────

  Future<int> guardarVisita(Visita visita) =>
      _guardar('visitas', visita.toMap());

  Future<List<Visita>> listarVisitas() async =>
      (await _listar('visitas', orden: 'fecha_ms DESC'))
          .map(Visita.fromMap)
          .toList();

  Future<int> guardarTareaSanitaria(TareaSanitaria tarea) =>
      _guardar('tareas_sanitarias', tarea.toMap());

  Future<void> borrarTareaSanitaria(int tareaId) =>
      _borrar('tareas_sanitarias', tareaId);

  Future<List<TareaSanitaria>> listarTareasSanitarias() async =>
      (await _listar('tareas_sanitarias', orden: 'fecha_prevista_ms ASC'))
          .map(TareaSanitaria.fromMap)
          .toList();

  // ─── Ingresos y gastos ───────────────────────────────────────────

  Future<int> guardarApunteEconomico(ApunteEconomico apunte) =>
      _guardar('apuntes_economicos', apunte.toMap());

  Future<void> borrarApunteEconomico(int apunteId) =>
      _borrar('apuntes_economicos', apunteId);

  Future<List<ApunteEconomico>> listarApuntesEconomicos({
    required int desdeMs,
    required int hastaMs,
  }) async =>
      (await _listar('apuntes_economicos',
              donde: 'fecha_ms >= ? AND fecha_ms <= ?',
              argumentos: [desdeMs, hastaMs],
              orden: 'fecha_ms DESC'))
          .map(ApunteEconomico.fromMap)
          .toList();

  // ─── Exportación completa ────────────────────────────────────────

  /// Todas las filas de todas las tablas (hard limit 4: los datos son del
  /// ganadero).
  Future<Map<String, List<Map<String, Object?>>>> volcarTodo() async => {
        for (final tabla in tablasGanadera)
          tabla: await _listar(tabla, orden: 'id'),
      };
}

extension on String {
  String? get nuloSiVacio => isEmpty ? null : this;
}
