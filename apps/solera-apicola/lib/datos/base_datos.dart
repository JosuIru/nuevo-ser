import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/apiario.dart';
import '../modelos/apicultor.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/colmena.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/cosecha_miel.dart';
import '../modelos/incidencia_apicola.dart';
import '../modelos/movimiento.dart';
import '../modelos/revision.dart';
import '../modelos/tercero.dart';
import '../modelos/tratamiento_varroa.dart';

/// Nombre del fichero de la base de datos (en la carpeta de documentos).
const String nombreFicheroBaseDatosApicola = 'solera_apicola.db';

/// Versión del esquema que abre la app (`version:` de openDatabase). La
/// usa también la copia de seguridad para rechazar copias más nuevas.
const int versionEsquemaBaseDatosApicola = 2;

/// Acceso a la base de datos local de Solera Apícola. Singleton con
/// inicialización perezosa: la primera lectura crea la BD.
///
/// Convención del monorepo: las migraciones nunca son destructivas.
/// Cualquier apicultor en campo lleva años de movimientos, cosechas y
/// tratamientos — perder un dato por una actualización es inaceptable.
///
/// v1 arranca con esquema completo (apiarios + colmenas + 5 eventos
/// + apicultor). Análisis acústico de colmena queda fuera de v0.1.
///
/// v2 añade el bloque de contabilidad (F1A-10): terceros (clientes
/// y proveedores con NIF), configuración fiscal del titular,
/// apuntes de ingreso y apuntes de gasto. La migración v1→v2 es
/// puramente aditiva — las tablas existentes no se tocan.
class BaseDatosSoleraApicola {
  static final BaseDatosSoleraApicola instancia = BaseDatosSoleraApicola._interno();
  factory BaseDatosSoleraApicola() => instancia;
  BaseDatosSoleraApicola._interno();

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, nombreFicheroBaseDatosApicola);
    _basedatos = await openDatabase(
      ruta,
      version: versionEsquemaBaseDatosApicola,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _crearEsquemaInicial(db);
        await _crearTablasContabilidadV2(db);
        await _crearTablasFacturasV3(db);
      },
      onUpgrade: (db, viejaVersion, nuevaVersion) async {
        if (viejaVersion < 2) {
          await _crearTablasContabilidadV2(db);
        }
        if (viejaVersion < 3) {
          await _crearTablasFacturasV3(db);
        }
      },
    );
    return _basedatos!;
  }

  // ─── Apiarios ───────────────────────────────────────────

  Future<int> guardarApiario(Apiario a) async {
    final db = await basedatos;
    return db.insert('apiarios', a.toMap()..remove('id'));
  }

  Future<void> actualizarApiario(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('apiarios', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Apiario>> listarApiarios() async {
    final db = await basedatos;
    final filas = await db.query('apiarios', orderBy: 'nombre ASC');
    return filas.map(Apiario.fromMap).toList();
  }

  Future<Apiario?> obtenerApiario(int id) async {
    final db = await basedatos;
    final filas = await db.query('apiarios', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Apiario.fromMap(filas.first);
  }

  Future<void> borrarApiario(int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.update('colmenas', {'apiario_id': null}, where: 'apiario_id = ?', whereArgs: [id]);
      await txn.delete('apiarios', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Colmenas ────────────────────────────────────────────

  Future<int> guardarColmena(Colmena c) async {
    final db = await basedatos;
    return db.insert('colmenas', c.toMap()..remove('id'));
  }

  Future<void> actualizarColmena(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('colmenas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Colmena>> listarColmenas({int? apiarioId}) async {
    final db = await basedatos;
    final filas = apiarioId == null
        ? await db.query('colmenas', orderBy: 'matricula ASC')
        : await db.query('colmenas', where: 'apiario_id = ?', whereArgs: [apiarioId], orderBy: 'matricula ASC');
    return filas.map(Colmena.fromMap).toList();
  }

  Future<List<Colmena>> listarColmenasPuntoSuelto() async {
    final db = await basedatos;
    final filas = await db.query('colmenas', where: 'apiario_id IS NULL', orderBy: 'matricula ASC');
    return filas.map(Colmena.fromMap).toList();
  }

  Future<Colmena?> obtenerColmena(int id) async {
    final db = await basedatos;
    final filas = await db.query('colmenas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Colmena.fromMap(filas.first);
  }

  Future<Colmena?> obtenerColmenaPorMatricula(String matricula) async {
    final db = await basedatos;
    final filas = await db.query('colmenas', where: 'matricula = ?', whereArgs: [matricula], limit: 1);
    if (filas.isEmpty) return null;
    return Colmena.fromMap(filas.first);
  }

  Future<void> borrarColmena(int id) async {
    final db = await basedatos;
    await db.delete('colmenas', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> contarColmenasPorEstado({int? apiarioId}) async {
    final db = await basedatos;
    final where = apiarioId == null ? null : 'apiario_id = ?';
    final args = apiarioId == null ? null : [apiarioId];
    final filas = await db.rawQuery(
      'SELECT estado, COUNT(*) AS n FROM colmenas'
      '${where != null ? ' WHERE $where' : ''}'
      ' GROUP BY estado',
      args,
    );
    return {for (final f in filas) (f['estado'] as String): (f['n'] as int)};
  }

  // ─── Revisiones ──────────────────────────────────────────

  Future<int> guardarRevision(Revision r) async {
    final db = await basedatos;
    return db.insert('revisiones', r.toMap()..remove('id'));
  }

  Future<void> actualizarRevision(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('revisiones', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Revision?> obtenerRevision(int id) async {
    final db = await basedatos;
    final filas = await db.query('revisiones', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Revision.fromMap(filas.first);
  }

  Future<List<Revision>> listarRevisionesDeColmena(int colmenaId) async {
    final db = await basedatos;
    final filas = await db.query('revisiones', where: 'colmena_id = ?', whereArgs: [colmenaId], orderBy: 'fecha_ms DESC');
    return filas.map(Revision.fromMap).toList();
  }

  Future<void> borrarRevision(int id) async {
    final db = await basedatos;
    await db.delete('revisiones', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Cosechas de miel ────────────────────────────────────

  Future<int> guardarCosechaMiel(CosechaMiel c) async {
    final db = await basedatos;
    return db.insert('cosechas_miel', c.toMap()..remove('id'));
  }

  Future<void> actualizarCosechaMiel(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('cosechas_miel', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<CosechaMiel?> obtenerCosechaMiel(int id) async {
    final db = await basedatos;
    final filas = await db.query('cosechas_miel', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return CosechaMiel.fromMap(filas.first);
  }

  Future<List<CosechaMiel>> listarCosechasDeColmena(int colmenaId) async {
    final db = await basedatos;
    final filas = await db.query('cosechas_miel', where: 'colmena_id = ?', whereArgs: [colmenaId], orderBy: 'fecha_ms DESC');
    return filas.map(CosechaMiel.fromMap).toList();
  }

  Future<void> borrarCosechaMiel(int id) async {
    final db = await basedatos;
    await db.delete('cosechas_miel', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Tratamientos varroa ─────────────────────────────────

  Future<int> guardarTratamientoVarroa(TratamientoVarroa t) async {
    final db = await basedatos;
    return db.insert('tratamientos_varroa', t.toMap()..remove('id'));
  }

  Future<void> actualizarTratamientoVarroa(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('tratamientos_varroa', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<TratamientoVarroa?> obtenerTratamientoVarroa(int id) async {
    final db = await basedatos;
    final filas = await db.query('tratamientos_varroa', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return TratamientoVarroa.fromMap(filas.first);
  }

  Future<List<TratamientoVarroa>> listarTratamientosDeColmena(int colmenaId) async {
    final db = await basedatos;
    final filas = await db.query('tratamientos_varroa', where: 'colmena_id = ?', whereArgs: [colmenaId], orderBy: 'fecha_aplicacion_ms DESC');
    return filas.map(TratamientoVarroa.fromMap).toList();
  }

  Future<void> borrarTratamientoVarroa(int id) async {
    final db = await basedatos;
    await db.delete('tratamientos_varroa', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TratamientoVarroa>> listarTratamientosPorApiarioYRango({
    required int? apiarioId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = apiarioId == null
        ? await db.rawQuery(
            'SELECT t.* FROM tratamientos_varroa t '
            'INNER JOIN colmenas c ON t.colmena_id = c.id '
            'WHERE c.apiario_id IS NULL AND t.fecha_aplicacion_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_aplicacion_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT t.* FROM tratamientos_varroa t '
            'INNER JOIN colmenas c ON t.colmena_id = c.id '
            'WHERE c.apiario_id = ? AND t.fecha_aplicacion_ms BETWEEN ? AND ? '
            'ORDER BY t.fecha_aplicacion_ms ASC',
            [apiarioId, desdeMs, hastaMs],
          );
    return filas.map(TratamientoVarroa.fromMap).toList();
  }

  // ─── Incidencias ─────────────────────────────────────────

  Future<int> guardarIncidencia(IncidenciaApicola i) async {
    final db = await basedatos;
    return db.insert('incidencias', i.toMap()..remove('id'));
  }

  Future<void> actualizarIncidencia(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('incidencias', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<IncidenciaApicola?> obtenerIncidencia(int id) async {
    final db = await basedatos;
    final filas = await db.query('incidencias', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return IncidenciaApicola.fromMap(filas.first);
  }

  Future<List<IncidenciaApicola>> listarIncidenciasDeColmena(int colmenaId) async {
    final db = await basedatos;
    final filas = await db.query('incidencias', where: 'colmena_id = ?', whereArgs: [colmenaId], orderBy: 'fecha_ms DESC');
    return filas.map(IncidenciaApicola.fromMap).toList();
  }

  Future<List<IncidenciaApicola>> listarIncidenciasPorApiarioYRango({
    required int? apiarioId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = apiarioId == null
        ? await db.rawQuery(
            'SELECT i.* FROM incidencias i '
            'INNER JOIN colmenas c ON i.colmena_id = c.id '
            'WHERE i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT i.* FROM incidencias i '
            'INNER JOIN colmenas c ON i.colmena_id = c.id '
            'WHERE c.apiario_id = ? AND i.fecha_ms BETWEEN ? AND ? '
            'ORDER BY i.fecha_ms ASC',
            [apiarioId, desdeMs, hastaMs],
          );
    return filas.map(IncidenciaApicola.fromMap).toList();
  }

  Future<List<CosechaMiel>> listarCosechasPorApiarioYRango({
    required int? apiarioId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = apiarioId == null
        ? await db.rawQuery(
            'SELECT cm.* FROM cosechas_miel cm '
            'INNER JOIN colmenas c ON cm.colmena_id = c.id '
            'WHERE cm.fecha_ms BETWEEN ? AND ? '
            'ORDER BY cm.fecha_ms ASC',
            [desdeMs, hastaMs],
          )
        : await db.rawQuery(
            'SELECT cm.* FROM cosechas_miel cm '
            'INNER JOIN colmenas c ON cm.colmena_id = c.id '
            'WHERE c.apiario_id = ? AND cm.fecha_ms BETWEEN ? AND ? '
            'ORDER BY cm.fecha_ms ASC',
            [apiarioId, desdeMs, hastaMs],
          );
    return filas.map(CosechaMiel.fromMap).toList();
  }

  Future<List<Movimiento>> listarMovimientosPorApiarioYRango({
    required int? apiarioId,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    if (apiarioId == null) {
      final filas = await db.query(
        'movimientos',
        where: 'fecha_movimiento_ms BETWEEN ? AND ?',
        whereArgs: [desdeMs, hastaMs],
        orderBy: 'fecha_movimiento_ms ASC',
      );
      return filas.map(Movimiento.fromMap).toList();
    }
    final filas = await db.query(
      'movimientos',
      where:
          '(apiario_origen_id = ? OR apiario_destino_id = ?) AND fecha_movimiento_ms BETWEEN ? AND ?',
      whereArgs: [apiarioId, apiarioId, desdeMs, hastaMs],
      orderBy: 'fecha_movimiento_ms ASC',
    );
    return filas.map(Movimiento.fromMap).toList();
  }

  Future<List<IncidenciaApicola>> listarIncidenciasAbiertas({int? apiarioId}) async {
    final db = await basedatos;
    const base =
        'SELECT i.* FROM incidencias i INNER JOIN colmenas c ON i.colmena_id = c.id WHERE i.resuelta = 0';
    final filas = apiarioId == null
        ? await db.rawQuery('$base ORDER BY i.fecha_ms DESC')
        : await db.rawQuery('$base AND c.apiario_id = ? ORDER BY i.fecha_ms DESC', [apiarioId]);
    return filas.map(IncidenciaApicola.fromMap).toList();
  }

  Future<void> borrarIncidencia(int id) async {
    final db = await basedatos;
    await db.delete('incidencias', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Movimientos (trashumancia) ──────────────────────────

  Future<int> guardarMovimiento(Movimiento m) async {
    final db = await basedatos;
    return db.insert('movimientos', m.toMap()..remove('id'));
  }

  Future<void> actualizarMovimiento(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('movimientos', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<Movimiento?> obtenerMovimiento(int id) async {
    final db = await basedatos;
    final filas = await db.query('movimientos', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Movimiento.fromMap(filas.first);
  }

  Future<List<Movimiento>> listarMovimientosDeColmena(int colmenaId) async {
    final db = await basedatos;
    final filas = await db.query('movimientos', where: 'colmena_id = ?', whereArgs: [colmenaId], orderBy: 'fecha_movimiento_ms DESC');
    return filas.map(Movimiento.fromMap).toList();
  }

  Future<List<Movimiento>> listarMovimientosPorRango({
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = await db.query(
      'movimientos',
      where: 'fecha_movimiento_ms BETWEEN ? AND ?',
      whereArgs: [desdeMs, hastaMs],
      orderBy: 'fecha_movimiento_ms ASC',
    );
    return filas.map(Movimiento.fromMap).toList();
  }

  Future<void> borrarMovimiento(int id) async {
    final db = await basedatos;
    await db.delete('movimientos', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Apicultor (single-row) ──────────────────────────────

  Future<Apicultor> obtenerApicultor() async {
    final db = await basedatos;
    final filas = await db.query('apicultores', limit: 1);
    if (filas.isEmpty) return Apicultor();
    return Apicultor.fromMap(filas.first);
  }

  Future<void> guardarApicultor(Apicultor a) async {
    final db = await basedatos;
    final actual = await obtenerApicultor();
    final mapa = a.toMap()..remove('id');
    if (actual.id != null) {
      await db.update('apicultores', mapa, where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('apicultores', mapa);
    }
  }

  // ─── Terceros (clientes y proveedores) ──────────────────

  Future<int> guardarTercero(Tercero t) async {
    final db = await basedatos;
    return db.insert('terceros', t.toMap()..remove('id'));
  }

  Future<void> actualizarTercero(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('terceros', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tercero>> listarTerceros({String? tipo}) async {
    final db = await basedatos;
    final filas = tipo == null
        ? await db.query('terceros', orderBy: 'nombre ASC')
        : await db.rawQuery(
            'SELECT * FROM terceros WHERE tipo = ? OR tipo = ? ORDER BY nombre ASC',
            [tipo, 'ambos'],
          );
    return filas.map(Tercero.fromMap).toList();
  }

  Future<Tercero?> obtenerTercero(int id) async {
    final db = await basedatos;
    final filas = await db.query('terceros', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Tercero.fromMap(filas.first);
  }

  Future<Tercero?> obtenerTerceroPorNif(String nif) async {
    final db = await basedatos;
    final filas = await db.query('terceros', where: 'nif = ?', whereArgs: [nif], limit: 1);
    if (filas.isEmpty) return null;
    return Tercero.fromMap(filas.first);
  }

  Future<void> borrarTercero(int id) async {
    final db = await basedatos;
    await db.delete('terceros', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Configuración fiscal (single-row) ──────────────────

  Future<ConfiguracionFiscal> obtenerConfiguracionFiscal() async {
    final db = await basedatos;
    final filas = await db.query('configuraciones_fiscales', limit: 1);
    if (filas.isEmpty) return ConfiguracionFiscal();
    return ConfiguracionFiscal.fromMap(filas.first);
  }

  Future<void> guardarConfiguracionFiscal(ConfiguracionFiscal cf) async {
    final db = await basedatos;
    final actual = await obtenerConfiguracionFiscal();
    final mapa = cf.toMap()..remove('id');
    if (actual.id != null) {
      await db.update('configuraciones_fiscales', mapa,
          where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('configuraciones_fiscales', mapa);
    }
  }

  // ─── Apuntes de ingreso ─────────────────────────────────

  Future<int> guardarApunteIngreso(ApunteIngreso a) async {
    final db = await basedatos;
    return db.insert('apuntes_ingreso', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteIngreso(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('apuntes_ingreso', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<ApunteIngreso?> obtenerApunteIngreso(int id) async {
    final db = await basedatos;
    final filas = await db.query('apuntes_ingreso', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ApunteIngreso.fromMap(filas.first);
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoPorRango({
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_ingreso',
      where: 'fecha_ms BETWEEN ? AND ?',
      whereArgs: [desdeMs, hastaMs],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteIngreso.fromMap).toList();
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoPorAno(int ano) async {
    final desdeMs = DateTime(ano, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(ano + 1, 1, 1).millisecondsSinceEpoch - 1;
    return listarApuntesIngresoPorRango(desdeMs: desdeMs, hastaMs: hastaMs);
  }

  Future<List<ApunteIngreso>> listarApuntesIngresoDeTercero(int terceroId) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_ingreso',
      where: 'tercero_id = ?',
      whereArgs: [terceroId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteIngreso.fromMap).toList();
  }

  Future<void> borrarApunteIngreso(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_ingreso', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Apuntes de gasto ────────────────────────────────────

  Future<int> guardarApunteGasto(ApunteGasto a) async {
    final db = await basedatos;
    return db.insert('apuntes_gasto', a.toMap()..remove('id'));
  }

  Future<void> actualizarApunteGasto(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('apuntes_gasto', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<ApunteGasto?> obtenerApunteGasto(int id) async {
    final db = await basedatos;
    final filas = await db.query('apuntes_gasto', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ApunteGasto.fromMap(filas.first);
  }

  Future<List<ApunteGasto>> listarApuntesGastoPorRango({
    required int desdeMs,
    required int hastaMs,
  }) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_gasto',
      where: 'fecha_ms BETWEEN ? AND ?',
      whereArgs: [desdeMs, hastaMs],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteGasto.fromMap).toList();
  }

  Future<List<ApunteGasto>> listarApuntesGastoPorAno(int ano) async {
    final desdeMs = DateTime(ano, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(ano + 1, 1, 1).millisecondsSinceEpoch - 1;
    return listarApuntesGastoPorRango(desdeMs: desdeMs, hastaMs: hastaMs);
  }

  Future<List<ApunteGasto>> listarApuntesGastoDeTercero(int terceroId) async {
    final db = await basedatos;
    final filas = await db.query(
      'apuntes_gasto',
      where: 'tercero_id = ?',
      whereArgs: [terceroId],
      orderBy: 'fecha_ms DESC',
    );
    return filas.map(ApunteGasto.fromMap).toList();
  }

  Future<void> borrarApunteGasto(int id) async {
    final db = await basedatos;
    await db.delete('apuntes_gasto', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cerrar() async {
    await _basedatos?.close();
    _basedatos = null;
  }

  Future<String> rutaBaseDatos() async {
    final db = await basedatos;
    return db.path;
  }

  Future<bool> estaVacia() async {
    final db = await basedatos;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hallazgos'));
    return (count ?? 0) == 0;
  }

  Future<void> reiniciar() async {
    await _basedatos?.close();
    _basedatos = null;
  }
}

// ─── Esquema inicial v1 ───────────────────────────────────

Future<void> _crearEsquemaInicial(Database db) async {
  await db.execute('''
    CREATE TABLE apiarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 12092683,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      codigo_sitran TEXT NOT NULL DEFAULT '',
      superficie_hectareas REAL
    )
  ''');

  await db.execute('''
    CREATE TABLE colmenas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      apiario_id INTEGER,
      matricula TEXT NOT NULL UNIQUE,
      tipo_colmena_id TEXT NOT NULL DEFAULT '',
      raza_id TEXT NOT NULL DEFAULT '',
      ano_reina INTEGER,
      estado TEXT NOT NULL DEFAULT 'viva',
      ultima_latitud REAL,
      ultima_longitud REAL,
      fecha_alta_ms INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (apiario_id) REFERENCES apiarios(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_colmenas_apiario ON colmenas (apiario_id)');
  await db.execute('CREATE INDEX idx_colmenas_estado ON colmenas (estado)');
  await db.execute('CREATE INDEX idx_colmenas_matricula ON colmenas (matricula)');

  await db.execute('''
    CREATE TABLE revisiones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      presencia_reina TEXT NOT NULL DEFAULT 'no_observada',
      nivel_postura INTEGER,
      nivel_cria_operculada INTEGER,
      nivel_miel INTEGER,
      nivel_polen INTEGER,
      varroa_caida_diaria INTEGER,
      etiquetas_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_revisiones_colmena_fecha ON revisiones (colmena_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE cosechas_miel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      kilos_miel REAL,
      kilos_cera REAL,
      kilos_polen REAL,
      kilos_propoleo REAL,
      kilos_jalea_real REAL,
      numero_alza INTEGER,
      calidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_cosechas_colmena_fecha ON cosechas_miel (colmena_id, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE tratamientos_varroa (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_aplicacion_ms INTEGER NOT NULL,
      fecha_retirada_ms INTEGER,
      tipo TEXT NOT NULL DEFAULT 'varroa',
      sustancia_activa_id TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      vehiculo TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      lote_producto TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      motivo TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_tratamientos_colmena_fecha ON tratamientos_varroa (colmena_id, fecha_aplicacion_ms DESC)');

  await db.execute('''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      diagnostico TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_incidencias_colmena_fecha ON incidencias (colmena_id, fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)');

  await db.execute('''
    CREATE TABLE movimientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER,
      apiario_origen_id INTEGER,
      apiario_destino_id INTEGER,
      fecha_movimiento_ms INTEGER NOT NULL,
      motivo TEXT NOT NULL DEFAULT 'otro',
      numero_colmenas INTEGER NOT NULL DEFAULT 1,
      latitud_origen REAL,
      longitud_origen REAL,
      latitud_destino REAL,
      longitud_destino REAL,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE SET NULL,
      FOREIGN KEY (apiario_origen_id) REFERENCES apiarios(id) ON DELETE SET NULL,
      FOREIGN KEY (apiario_destino_id) REFERENCES apiarios(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_movimientos_fecha ON movimientos (fecha_movimiento_ms DESC)');
  await db.execute('CREATE INDEX idx_movimientos_colmena ON movimientos (colmena_id)');

  await db.execute('''
    CREATE TABLE apicultores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      numero_rega TEXT NOT NULL DEFAULT '',
      numero_explotacion_apicola TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      nombre_veterinario TEXT NOT NULL DEFAULT '',
      nif_veterinario TEXT NOT NULL DEFAULT '',
      numero_colegiado_veterinario TEXT NOT NULL DEFAULT '',
      telefono_veterinario TEXT NOT NULL DEFAULT ''
    )
  ''');
}

// ─── Migración v2: contabilidad ───────────────────────────

Future<void> _crearTablasContabilidadV2(Database db) async {
  await db.execute('''
    CREATE TABLE terceros (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      tipo TEXT NOT NULL DEFAULT 'ambos',
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');
  await db.execute('CREATE INDEX idx_terceros_nif ON terceros (nif)');
  await db.execute('CREATE INDEX idx_terceros_tipo ON terceros (tipo)');

  await db.execute('''
    CREATE TABLE configuraciones_fiscales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      regimen_irpf TEXT NOT NULL DEFAULT 'sin_elegir',
      regimen_iva TEXT NOT NULL DEFAULT 'sin_elegir',
      ano_fiscal_activo INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE apuntes_ingreso (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      concepto TEXT NOT NULL DEFAULT '',
      tipo_ingreso TEXT NOT NULL DEFAULT 'otro',
      importe_base_centimos INTEGER NOT NULL DEFAULT 0,
      iva_repercutido_centimos INTEGER NOT NULL DEFAULT 0,
      compensacion_reagp_centimos INTEGER NOT NULL DEFAULT 0,
      cantidad REAL,
      unidad TEXT NOT NULL DEFAULT '',
      tercero_id INTEGER,
      apiario_id INTEGER,
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (apiario_id) REFERENCES apiarios(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_ingresos_fecha ON apuntes_ingreso (fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_ingresos_tipo ON apuntes_ingreso (tipo_ingreso)');
  await db.execute('CREATE INDEX idx_ingresos_tercero ON apuntes_ingreso (tercero_id)');

  await db.execute('''
    CREATE TABLE apuntes_gasto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      concepto TEXT NOT NULL DEFAULT '',
      tipo_gasto TEXT NOT NULL DEFAULT 'otro',
      importe_base_centimos INTEGER NOT NULL DEFAULT 0,
      iva_soportado_centimos INTEGER NOT NULL DEFAULT 0,
      imputacion TEXT NOT NULL DEFAULT 'general',
      apiario_id INTEGER,
      tercero_id INTEGER,
      ruta_foto_factura TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      tratamiento_varroa_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (apiario_id) REFERENCES apiarios(id) ON DELETE SET NULL,
      FOREIGN KEY (tercero_id) REFERENCES terceros(id) ON DELETE SET NULL,
      FOREIGN KEY (tratamiento_varroa_id) REFERENCES tratamientos_varroa(id) ON DELETE SET NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_gastos_fecha ON apuntes_gasto (fecha_ms DESC)');
  await db.execute('CREATE INDEX idx_gastos_tipo ON apuntes_gasto (tipo_gasto)');
  await db.execute('CREATE INDEX idx_gastos_tercero ON apuntes_gasto (tercero_id)');
}

/// Esquema v3 — tabla de facturas (aditivo).
Future<void> _crearTablasFacturasV3(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS facturas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numero_factura TEXT NOT NULL,
      fecha_emision_ms INTEGER NOT NULL,
      fecha_vencimiento_ms INTEGER,
      fecha_pago_ms INTEGER,
      cliente_nombre TEXT NOT NULL DEFAULT '',
      cliente_nif TEXT NOT NULL DEFAULT '',
      cliente_direccion TEXT NOT NULL DEFAULT '',
      lineas_json TEXT NOT NULL DEFAULT '[]',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 10,
      total REAL NOT NULL DEFAULT 0,
      estado TEXT NOT NULL DEFAULT 'emitida',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');
}
