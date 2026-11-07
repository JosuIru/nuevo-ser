import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/apunte_economico.dart';
import '../modelos/hornada.dart';
import '../modelos/ingrediente.dart';
import '../modelos/lote_ingrediente.dart';
import '../modelos/masa_madre.dart';
import '../modelos/pedido_fijo.dart';
import '../modelos/receta.dart';
import '../modelos/registro_autocontrol.dart';
import '../modelos/titular.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatosObrador = 'solera_obrador.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquemaObrador = 1;

/// Base de datos local de Larrea Obrador. La apertura, el cerrojo, las FK y
/// las migraciones las pone BaseDatosSolera (core). **Migraciones
/// aditivas**: un cambio de esquema es un paso nuevo; nunca se edita lo
/// publicado. (La v1 se amplió en el bloque 2, antes de publicar nada.)
class BaseDatosSoleraObrador extends BaseDatosSolera {
  static final BaseDatosSoleraObrador instancia =
      BaseDatosSoleraObrador._interno();
  factory BaseDatosSoleraObrador() => instancia;
  BaseDatosSoleraObrador._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatosObrador;

  @override
  int get versionEsquema => versionEsquemaObrador;

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
        registro_sanitario TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE ingredientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        alergenos TEXT NOT NULL DEFAULT '',
        trazas TEXT NOT NULL DEFAULT '',
        proveedor TEXT NOT NULL DEFAULT '',
        precio_centimos_kg INTEGER NOT NULL DEFAULT 0,
        sal_g_100g REAL NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE lotes_ingrediente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingrediente_id INTEGER NOT NULL REFERENCES ingredientes(id) ON DELETE RESTRICT,
        codigo_lote TEXT NOT NULL,
        fecha_recepcion_ms INTEGER NOT NULL,
        consumo_preferente_ms INTEGER,
        cantidad_kg REAL NOT NULL DEFAULT 0,
        temperatura_recepcion_c REAL,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE recetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        denominacion TEXT NOT NULL DEFAULT '',
        piezas_por_masa INTEGER NOT NULL DEFAULT 1,
        merma_coccion_pct REAL NOT NULL DEFAULT 0,
        es_subreceta INTEGER NOT NULL DEFAULT 0,
        precio_venta_centimos_pieza INTEGER NOT NULL DEFAULT 0,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE lineas_receta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receta_id INTEGER NOT NULL REFERENCES recetas(id) ON DELETE CASCADE,
        ingrediente_id INTEGER REFERENCES ingredientes(id) ON DELETE RESTRICT,
        subreceta_id INTEGER REFERENCES recetas(id) ON DELETE RESTRICT,
        gramos REAL NOT NULL,
        CHECK ((ingrediente_id IS NULL) <> (subreceta_id IS NULL))
      )''',
      '''CREATE TABLE masas_madre (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        harina_base TEXT NOT NULL DEFAULT '',
        creada_ms INTEGER NOT NULL,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE refrescos_masa_madre (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        masa_madre_id INTEGER NOT NULL REFERENCES masas_madre(id) ON DELETE CASCADE,
        fecha_ms INTEGER NOT NULL,
        gramos_masa_madre REAL NOT NULL,
        gramos_harina REAL NOT NULL,
        gramos_agua REAL NOT NULL,
        temperatura_c REAL,
        horas_hasta_pico REAL,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE hornadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receta_id INTEGER NOT NULL REFERENCES recetas(id) ON DELETE RESTRICT,
        fecha_ms INTEGER NOT NULL,
        piezas INTEGER NOT NULL,
        codigo_lote TEXT NOT NULL,
        temperatura_horno_c REAL,
        minutos_horno INTEGER,
        responsable TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE hornadas_lotes (
        hornada_id INTEGER NOT NULL REFERENCES hornadas(id) ON DELETE CASCADE,
        lote_ingrediente_id INTEGER NOT NULL REFERENCES lotes_ingrediente(id) ON DELETE RESTRICT,
        PRIMARY KEY (hornada_id, lote_ingrediente_id)
      )''',
      '''CREATE TABLE pedidos_fijos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT NOT NULL,
        receta_id INTEGER NOT NULL REFERENCES recetas(id) ON DELETE CASCADE,
        piezas INTEGER NOT NULL,
        dias_semana TEXT NOT NULL DEFAULT '',
        activo INTEGER NOT NULL DEFAULT 1,
        notas TEXT NOT NULL DEFAULT ''
      )''',
      '''CREATE TABLE registros_autocontrol (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        fecha_ms INTEGER NOT NULL,
        elemento TEXT NOT NULL,
        valor REAL,
        correcto INTEGER NOT NULL DEFAULT 1,
        accion_correctora TEXT NOT NULL DEFAULT '',
        responsable TEXT NOT NULL DEFAULT '',
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
        tercero TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT ''
      )''',
      'CREATE INDEX idx_apuntes_fecha ON apuntes_economicos(fecha_ms)',
      'CREATE INDEX idx_lotes_ingrediente ON lotes_ingrediente(ingrediente_id)',
      'CREATE INDEX idx_lineas_receta ON lineas_receta(receta_id)',
      'CREATE INDEX idx_refrescos_fecha ON refrescos_masa_madre(masa_madre_id, fecha_ms)',
      'CREATE INDEX idx_hornadas_fecha ON hornadas(fecha_ms)',
      'CREATE INDEX idx_autocontrol_fecha ON registros_autocontrol(fecha_ms)',
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

  // ─── Titular ─────────────────────────────────────────────────────

  Future<Titular> obtenerTitular() async {
    final filas = await _listar('titulares');
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }

  // ─── Ingredientes y lotes ────────────────────────────────────────

  Future<int> guardarIngrediente(Ingrediente ingrediente) =>
      _guardar('ingredientes', ingrediente.toMap());

  Future<List<Ingrediente>> listarIngredientes() async =>
      (await _listar('ingredientes', orden: 'nombre COLLATE NOCASE'))
          .map(Ingrediente.fromMap)
          .toList();

  Future<int> guardarLoteIngrediente(LoteIngrediente lote) =>
      _guardar('lotes_ingrediente', lote.toMap());

  Future<List<LoteIngrediente>> listarLotesIngrediente(
          {int? ingredienteId}) async =>
      (await _listar('lotes_ingrediente',
              donde: ingredienteId == null ? null : 'ingrediente_id = ?',
              argumentos: ingredienteId == null ? null : [ingredienteId],
              orden: 'fecha_recepcion_ms DESC'))
          .map(LoteIngrediente.fromMap)
          .toList();

  // ─── Recetas ─────────────────────────────────────────────────────

  Future<int> guardarReceta(Receta receta) =>
      _guardar('recetas', receta.toMap());

  Future<List<Receta>> listarRecetas() async =>
      (await _listar('recetas', orden: 'nombre COLLATE NOCASE'))
          .map(Receta.fromMap)
          .toList();

  Future<void> borrarReceta(int recetaId) => _borrar('recetas', recetaId);

  /// Sustituye todas las líneas de la receta en una transacción.
  Future<void> guardarLineasReceta(
      int recetaId, List<LineaReceta> lineas) async {
    final db = await basedatos;
    await db.transaction((transaccion) async {
      await transaccion.delete('lineas_receta',
          where: 'receta_id = ?', whereArgs: [recetaId]);
      for (final linea in lineas) {
        await transaccion.insert(
            'lineas_receta',
            linea.toMap()
              ..remove('id')
              ..['receta_id'] = recetaId);
      }
    });
  }

  /// Todas las líneas, agrupadas por receta (para [ComposicionReceta]).
  Future<Map<int, List<LineaReceta>>> lineasPorReceta() async {
    final agrupadas = <int, List<LineaReceta>>{};
    for (final fila in await _listar('lineas_receta', orden: 'id')) {
      final linea = LineaReceta.fromMap(fila);
      agrupadas.putIfAbsent(linea.recetaId, () => []).add(linea);
    }
    return agrupadas;
  }

  // ─── Masa madre ──────────────────────────────────────────────────

  Future<int> guardarMasaMadre(MasaMadre masaMadre) =>
      _guardar('masas_madre', masaMadre.toMap());

  Future<List<MasaMadre>> listarMasasMadre() async =>
      (await _listar('masas_madre', orden: 'nombre COLLATE NOCASE'))
          .map(MasaMadre.fromMap)
          .toList();

  Future<int> guardarRefresco(RefrescoMasaMadre refresco) =>
      _guardar('refrescos_masa_madre', refresco.toMap());

  Future<List<RefrescoMasaMadre>> listarRefrescos(int masaMadreId) async =>
      (await _listar('refrescos_masa_madre',
              donde: 'masa_madre_id = ?',
              argumentos: [masaMadreId],
              orden: 'fecha_ms DESC'))
          .map(RefrescoMasaMadre.fromMap)
          .toList();

  // ─── Hornadas ────────────────────────────────────────────────────

  /// Guarda la hornada y los lotes de ingrediente usados, en una
  /// transacción (trazabilidad: qué lotes entraron en qué hornada).
  Future<int> guardarHornada(Hornada hornada,
      {List<int> lotesUsados = const []}) async {
    final db = await basedatos;
    return db.transaction((transaccion) async {
      final sinId = hornada.toMap()..remove('id');
      var id = hornada.id;
      if (id == null) {
        id = await transaccion.insert('hornadas', sinId);
      } else {
        await transaccion
            .update('hornadas', sinId, where: 'id = ?', whereArgs: [id]);
        await transaccion
            .delete('hornadas_lotes', where: 'hornada_id = ?', whereArgs: [id]);
      }
      for (final loteId in lotesUsados.toSet()) {
        await transaccion.insert('hornadas_lotes',
            {'hornada_id': id, 'lote_ingrediente_id': loteId});
      }
      return id;
    });
  }

  Future<List<Hornada>> listarHornadas({int? desdeMs, int? hastaMs}) async =>
      (await _listar('hornadas',
              donde: desdeMs == null ? null : 'fecha_ms >= ? AND fecha_ms <= ?',
              argumentos:
                  desdeMs == null ? null : [desdeMs, hastaMs ?? desdeMs],
              orden: 'fecha_ms DESC'))
          .map(Hornada.fromMap)
          .toList();

  Future<List<int>> lotesDeHornada(int hornadaId) async =>
      (await _listar('hornadas_lotes',
              donde: 'hornada_id = ?', argumentos: [hornadaId]))
          .map((fila) => fila['lote_ingrediente_id'] as int)
          .toList();

  /// Hornadas que usaron un lote (para retirar producto si el lote falla).
  Future<List<Hornada>> hornadasConLote(int loteIngredienteId) async {
    final db = await basedatos;
    final filas = await db.rawQuery('''
      SELECT h.* FROM hornadas h
      JOIN hornadas_lotes hl ON hl.hornada_id = h.id
      WHERE hl.lote_ingrediente_id = ?
      ORDER BY h.fecha_ms DESC
    ''', [loteIngredienteId]);
    return filas.map(Hornada.fromMap).toList();
  }

  // ─── Pedidos fijos ───────────────────────────────────────────────

  Future<int> guardarPedidoFijo(PedidoFijo pedido) =>
      _guardar('pedidos_fijos', pedido.toMap());

  Future<List<PedidoFijo>> listarPedidosFijos() async =>
      (await _listar('pedidos_fijos', orden: 'cliente COLLATE NOCASE'))
          .map(PedidoFijo.fromMap)
          .toList();

  // ─── Autocontrol ─────────────────────────────────────────────────

  Future<int> guardarRegistroAutocontrol(RegistroAutocontrol registro) =>
      _guardar('registros_autocontrol', registro.toMap());

  Future<List<RegistroAutocontrol>> listarRegistrosAutocontrol({
    required int desdeMs,
    required int hastaMs,
    String? tipo,
  }) async =>
      (await _listar('registros_autocontrol',
              donde:
                  'fecha_ms >= ? AND fecha_ms <= ?${tipo == null ? '' : ' AND tipo = ?'}',
              argumentos: [desdeMs, hastaMs, if (tipo != null) tipo],
              orden: 'fecha_ms ASC'))
          .map(RegistroAutocontrol.fromMap)
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
}
