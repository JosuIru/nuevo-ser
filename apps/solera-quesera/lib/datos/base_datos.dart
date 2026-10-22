import 'dart:convert';

import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/analitica.dart';
import '../modelos/control_limpieza.dart';
import '../modelos/control_plagas.dart';
import '../modelos/control_temperatura.dart';
import '../modelos/evento_curacion.dart';
import '../modelos/formacion.dart';
import '../modelos/incidencia.dart';
import '../modelos/lote_produccion.dart';
import '../modelos/partida_leche.dart';
import '../modelos/pieza.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/proveedor_leche.dart';
import '../modelos/queseria.dart';
import '../modelos/receta.dart';
import '../modelos/simulacion_trazabilidad.dart';
import '../modelos/tercero.dart';
import '../modelos/venta.dart';

/// Versión del esquema que abre la app (`version:` de openDatabase).
/// La copia de seguridad la usa para rechazar copias de un esquema más
/// nuevo: súbela aquí, nunca solo en openDatabase.
const int versionEsquemaSoleraQuesera = 4;

/// Nombre del fichero de la BD en la carpeta de documentos.
const String nombreFicheroBaseDatosSoleraQuesera = 'solera_quesera.db';

/// Acceso a la base de datos local de Solera Quesera. Singleton con
/// inicialización perezosa siguiendo el patrón de la suite Solera.
///
/// v1 arranca con esquema completo (15 tablas + FK + índices).
/// Migraciones nunca destructivas — una quesería en producción lleva
/// años de lotes, piezas y ventas.
class BaseDatosSoleraQuesera {
  static final BaseDatosSoleraQuesera instancia =
      BaseDatosSoleraQuesera._interno();
  factory BaseDatosSoleraQuesera() => instancia;
  BaseDatosSoleraQuesera._interno();

  Database? _basedatos;

  Future<Database> get basedatos async {
    if (_basedatos != null) return _basedatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = path_lib.join(directorio.path, nombreFicheroBaseDatosSoleraQuesera);
    _basedatos = await openDatabase(
      ruta,
      version: versionEsquemaSoleraQuesera,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _crearEsquemaV1(db);
        await _crearEsquemaV2(db);
        await _crearEsquemaV3(db);
        await _crearEsquemaV4(db);
      },
      onUpgrade: (db, viejaVersion, nuevaVersion) async {
        if (viejaVersion < 2) {
          await _crearEsquemaV2(db);
        }
        if (viejaVersion < 3) {
          await _crearEsquemaV3(db);
        }
        if (viejaVersion < 4) {
          await _crearEsquemaV4(db);
        }
      },
    );
    return _basedatos!;
  }

  Future<void> cerrar() async {
    await _basedatos?.close();
    _basedatos = null;
  }

  // ─── Quesería (single-row) ──────────────────────────────

  Future<Queseria> obtenerQueseria() async {
    final db = await basedatos;
    final filas = await db.query('queserias', limit: 1);
    if (filas.isEmpty) return Queseria();
    return Queseria.fromMap(filas.first);
  }

  Future<void> guardarQueseria(Queseria q) async {
    final db = await basedatos;
    final actual = await obtenerQueseria();
    final mapa = q.toMap()..remove('id');
    if (actual.id != null) {
      await db.update('queserias', mapa, where: 'id = ?', whereArgs: [actual.id]);
    } else {
      await db.insert('queserias', mapa);
    }
  }

  // ─── Proveedores de leche ──────────────────────────────

  Future<int> guardarProveedor(ProveedorLeche p) async {
    final db = await basedatos;
    return db.insert('proveedores_leche', p.toMap()..remove('id'));
  }

  Future<List<ProveedorLeche>> listarProveedores() async {
    final db = await basedatos;
    final filas =
        await db.query('proveedores_leche', orderBy: 'nombre ASC');
    return filas.map(ProveedorLeche.fromMap).toList();
  }

  Future<List<ProveedorLeche>> listarProveedoresActivos() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      "SELECT DISTINCT pl.* FROM proveedores_leche pl "
      "INNER JOIN partidas_leche pa ON pl.id = pa.proveedor_id "
      "WHERE pa.fecha_ms > ? "
      "ORDER BY pl.nombre ASC",
      [DateTime.now().subtract(const Duration(days: 365)).millisecondsSinceEpoch],
    );
    return filas.map(ProveedorLeche.fromMap).toList();
  }

  Future<ProveedorLeche?> obtenerProveedor(int id) async {
    final db = await basedatos;
    final filas = await db.query('proveedores_leche',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return ProveedorLeche.fromMap(filas.first);
  }

  Future<void> borrarProveedor(int id) async {
    final db = await basedatos;
    await db.delete('proveedores_leche', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Partidas de leche ──────────────────────────────────

  Future<int> guardarPartidaLeche(PartidaLeche p) async {
    final db = await basedatos;
    return db.insert('partidas_leche', p.toMap()..remove('id'));
  }

  Future<List<PartidaLeche>> listarPartidasLeche({
    int? proveedorId,
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (proveedorId != null) {
      condiciones.add('proveedor_id = ?');
      args.add(proveedorId);
    }
    if (desdeMs != null) {
      condiciones.add('fecha_ms >= ?');
      args.add(desdeMs);
    }
    if (hastaMs != null) {
      condiciones.add('fecha_ms <= ?');
      args.add(hastaMs);
    }
    final where = condiciones.isEmpty ? null : condiciones.join(' AND ');
    final filas = await db.query('partidas_leche',
        where: where, whereArgs: args.isEmpty ? null : args, orderBy: 'fecha_ms DESC');
    return filas.map(PartidaLeche.fromMap).toList();
  }

  Future<PartidaLeche?> obtenerPartidaLeche(int id) async {
    final db = await basedatos;
    final filas = await db.query('partidas_leche',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return PartidaLeche.fromMap(filas.first);
  }

  Future<void> borrarPartidaLeche(int id) async {
    final db = await basedatos;
    await db.delete('partidas_leche', where: 'id = ?', whereArgs: [id]);
  }

  /// Volumen total de leche recibida en un período. Útil para informes.
  Future<double> totalLitrosEnPeriodo(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT COALESCE(SUM(volumen_litros), 0) AS total FROM partidas_leche '
      'WHERE fecha_ms BETWEEN ? AND ?',
      [desdeMs, hastaMs],
    );
    return (filas.first['total'] as num?)?.toDouble() ?? 0;
  }

  // ─── Recetas ────────────────────────────────────────────

  Future<int> guardarReceta(Receta r) async {
    final db = await basedatos;
    return db.insert('recetas', r.toMap()..remove('id'));
  }

  Future<void> actualizarReceta(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('recetas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Receta>> listarRecetas() async {
    final db = await basedatos;
    final filas = await db.query('recetas', orderBy: 'nombre ASC');
    return filas.map(Receta.fromMap).toList();
  }

  Future<Receta?> obtenerReceta(int id) async {
    final db = await basedatos;
    final filas =
        await db.query('recetas', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Receta.fromMap(filas.first);
  }

  Future<void> borrarReceta(int id) async {
    final db = await basedatos;
    await db.delete('recetas', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Lotes de producción ────────────────────────────────

  Future<int> guardarLote(LoteProduccion l) async {
    final db = await basedatos;
    return db.insert('lotes_produccion', l.toMap()..remove('id'));
  }

  Future<void> actualizarLote(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('lotes_produccion', cambios,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LoteProduccion>> listarLotes({String? estado}) async {
    final db = await basedatos;
    final filas = estado == null
        ? await db.query('lotes_produccion', orderBy: 'fecha_ms DESC')
        : await db.query('lotes_produccion',
            where: 'estado = ?', whereArgs: [estado], orderBy: 'fecha_ms DESC');
    return filas.map(LoteProduccion.fromMap).toList();
  }

  Future<LoteProduccion?> obtenerLote(int id) async {
    final db = await basedatos;
    final filas = await db.query('lotes_produccion',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return LoteProduccion.fromMap(filas.first);
  }

  Future<List<LoteProduccion>> listarLotesPorReceta(int recetaId) async {
    final db = await basedatos;
    final filas = await db.query('lotes_produccion',
        where: 'receta_id = ?', whereArgs: [recetaId], orderBy: 'fecha_ms DESC');
    return filas.map(LoteProduccion.fromMap).toList();
  }

  Future<void> borrarLote(int id) async {
    final db = await basedatos;
    await db.delete('lotes_produccion', where: 'id = ?', whereArgs: [id]);
  }

  /// Genera el siguiente número de lote secuencial para una fecha.
  /// Formato: AAAAMMDD-NNN (secuencia por día).
  Future<String> siguienteNumeroLote(DateTime fecha) async {
    final db = await basedatos;
    final prefijo =
        '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}';
    final filas = await db.rawQuery(
      "SELECT COUNT(*) AS n FROM lotes_produccion WHERE numero_lote LIKE ?",
      ['$prefijo-%'],
    );
    final n = (filas.first['n'] as int) + 1;
    return '$prefijo-${n.toString().padLeft(3, '0')}';
  }

  // ─── Piezas ─────────────────────────────────────────────

  Future<int> guardarPieza(Pieza p) async {
    final db = await basedatos;
    return db.insert('piezas', p.toMap()..remove('id'));
  }

  /// Inserta N piezas para un lote con numeración secuencial.
  Future<List<int>> generarPiezasParaLote(
      int loteId, String numeroLote, int cantidad, double pesoInicial) async {
    final db = await basedatos;
    final ids = <int>[];
    final ahora = DateTime.now().millisecondsSinceEpoch;
    for (int i = 1; i <= cantidad; i++) {
      final numPieza = '$numeroLote-${i.toString().padLeft(2, '0')}';
      final id = await db.insert('piezas', {
        'lote_produccion_id': loteId,
        'numero_pieza': numPieza,
        'peso_inicial': pesoInicial,
        'peso_actual': pesoInicial,
        'ubicacion_actual': 'Cava principal',
        'estado': 'afinando',
        'fecha_expedicion_ms': null,
        'notas': '',
        'fecha_creacion_ms': ahora,
      });
      ids.add(id);
    }
    return ids;
  }

  Future<List<Pieza>> listarPiezas({
    int? loteId,
    String? estado,
    String? ubicacion,
  }) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (loteId != null) {
      condiciones.add('lote_produccion_id = ?');
      args.add(loteId);
    }
    if (estado != null) {
      condiciones.add('estado = ?');
      args.add(estado);
    }
    if (ubicacion != null) {
      condiciones.add('ubicacion_actual = ?');
      args.add(ubicacion);
    }
    final where =
        condiciones.isEmpty ? null : condiciones.join(' AND ');
    final filas = await db.query('piezas',
        where: where,
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'numero_pieza ASC');
    return filas.map(Pieza.fromMap).toList();
  }

  Future<Pieza?> obtenerPieza(int id) async {
    final db = await basedatos;
    final filas = await db.query('piezas',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Pieza.fromMap(filas.first);
  }

  Future<void> actualizarPieza(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('piezas', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> borrarPieza(int id) async {
    final db = await basedatos;
    await db.delete('piezas', where: 'id = ?', whereArgs: [id]);
  }

  /// Recuento de piezas agrupadas por estado. Útil para el resumen
  /// de la cava y el dashboard.
  Future<Map<String, int>> contarPiezasPorEstado() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
        'SELECT estado, COUNT(*) AS n FROM piezas GROUP BY estado');
    return {for (final f in filas) (f['estado'] as String): (f['n'] as int)};
  }

  /// Piezas cuya fecha de curación mínima ya ha pasado y siguen en
  /// estado 'afinando' — están listas para comercializar.
  Future<List<Pieza>> piezasListasNoExpedidas(List<int> lotesIds) async {
    if (lotesIds.isEmpty) return [];
    final db = await basedatos;
    final placeholders = lotesIds.map((_) => '?').join(',');
    return (await db.rawQuery(
      "SELECT p.* FROM piezas p "
      "INNER JOIN lotes_produccion l ON p.lote_produccion_id = l.id "
      "INNER JOIN recetas r ON l.receta_id = r.id "
      "WHERE p.estado = 'afinando' AND p.lote_produccion_id IN ($placeholders) "
      "AND (CAST(strftime('%s', 'now') AS INTEGER) * 1000 - l.fecha_ms) "
      ">= (r.curacion_minima_dias * 86400000)",
      lotesIds,
    ))
        .map(Pieza.fromMap)
        .toList();
  }

  // ─── Eventos de curación ───────────────────────────────

  Future<int> guardarEventoCuracion(EventoCuracion e) async {
    final db = await basedatos;
    return db.insert('eventos_curacion', e.toMap()..remove('id'));
  }

  Future<List<EventoCuracion>> listarEventosDePieza(int piezaId) async {
    final db = await basedatos;
    final filas = await db.query('eventos_curacion',
        where: 'pieza_id = ?',
        whereArgs: [piezaId],
        orderBy: 'fecha_ms DESC');
    return filas.map(EventoCuracion.fromMap).toList();
  }

  /// Eventos de curación programados para hoy (volteos, controles).
  Future<List<EventoCuracion>> eventosPendientesHoy() async {
    final db = await basedatos;
    final inicioHoy = DateTime.now().subtract(const Duration(hours: 12));
    final finHoy = DateTime.now().add(const Duration(hours: 12));
    final filas = await db.query('eventos_curacion',
        where: 'fecha_ms BETWEEN ? AND ?',
        whereArgs: [inicioHoy.millisecondsSinceEpoch, finHoy.millisecondsSinceEpoch],
        orderBy: 'fecha_ms ASC');
    return filas.map(EventoCuracion.fromMap).toList();
  }

  // ─── Analíticas ─────────────────────────────────────────

  Future<int> guardarAnalitica(Analitica a) async {
    final db = await basedatos;
    return db.insert('analiticas', a.toMap()..remove('id'));
  }

  Future<List<Analitica>> listarAnaliticas({int? loteId}) async {
    final db = await basedatos;
    final filas = loteId == null
        ? await db.query('analiticas', orderBy: 'fecha_ms DESC')
        : await db.query('analiticas',
            where: 'lote_produccion_id = ?',
            whereArgs: [loteId],
            orderBy: 'fecha_ms DESC');
    return filas.map(Analitica.fromMap).toList();
  }

  // ─── Incidencias ────────────────────────────────────────

  Future<int> guardarIncidencia(Incidencia i) async {
    final db = await basedatos;
    return db.insert('incidencias', i.toMap()..remove('id'));
  }

  Future<void> actualizarIncidencia(int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('incidencias', cambios, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Incidencia>> listarIncidencias({bool? soloAbiertas}) async {
    final db = await basedatos;
    if (soloAbiertas == true) {
      final filas = await db
          .query('incidencias', where: 'cerrada = 0', orderBy: 'fecha_ms DESC');
      return filas.map(Incidencia.fromMap).toList();
    }
    final filas =
        await db.query('incidencias', orderBy: 'fecha_ms DESC');
    return filas.map(Incidencia.fromMap).toList();
  }

  // ─── Ventas ─────────────────────────────────────────────

  Future<int> guardarVenta(Venta v) async {
    final db = await basedatos;
    return db.insert('ventas', v.toMap()..remove('id'));
  }

  Future<List<Venta>> listarVentas({
    int? desdeMs,
    int? hastaMs,
  }) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (desdeMs != null) {
      condiciones.add('fecha_ms >= ?');
      args.add(desdeMs);
    }
    if (hastaMs != null) {
      condiciones.add('fecha_ms <= ?');
      args.add(hastaMs);
    }
    final where = condiciones.isEmpty ? null : condiciones.join(' AND ');
    final filas = await db.query('ventas',
        where: where,
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'fecha_ms DESC');
    return filas.map(Venta.fromMap).toList();
  }

  /// Ingresos totales por ventas en un período.
  Future<double> totalIngresos(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS total FROM ventas '
      'WHERE fecha_ms BETWEEN ? AND ?',
      [desdeMs, hastaMs],
    );
    return (filas.first['total'] as num?)?.toDouble() ?? 0;
  }

  // ─── Controles APPCC ────────────────────────────────────

  Future<int> guardarControlTemperatura(ControlTemperatura c) async {
    final db = await basedatos;
    return db.insert('controles_temperatura', c.toMap()..remove('id'));
  }

  Future<List<ControlTemperatura>> listarTemperaturasRecientes(
      {int limite = 30}) async {
    final db = await basedatos;
    final filas = await db.query('controles_temperatura',
        orderBy: 'fecha_ms DESC', limit: limite);
    return filas.map(ControlTemperatura.fromMap).toList();
  }

  /// Última lectura de temperatura por cava.
  Future<Map<String, ControlTemperatura>> ultimaTemperaturaPorCava() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      "SELECT c.* FROM controles_temperatura c "
      "INNER JOIN (SELECT cava_id, MAX(fecha_ms) AS max_fecha "
      "FROM controles_temperatura GROUP BY cava_id) ult "
      "ON c.cava_id = ult.cava_id AND c.fecha_ms = ult.max_fecha",
    );
    return {for (final f in filas) (f['cava_id'] as String): ControlTemperatura.fromMap(f)};
  }

  Future<int> guardarControlLimpieza(ControlLimpieza c) async {
    final db = await basedatos;
    return db.insert('controles_limpieza', c.toMap()..remove('id'));
  }

  Future<List<ControlLimpieza>> listarControlesLimpieza(
      {int limite = 50}) async {
    final db = await basedatos;
    final filas = await db.query('controles_limpieza',
        orderBy: 'fecha_ms DESC', limit: limite);
    return filas.map(ControlLimpieza.fromMap).toList();
  }

  Future<int> guardarControlPlagas(ControlPlagas c) async {
    final db = await basedatos;
    return db.insert('controles_plagas', c.toMap()..remove('id'));
  }

  Future<List<ControlPlagas>> listarControlesPlagas({int limite = 50}) async {
    final db = await basedatos;
    final filas = await db.query('controles_plagas',
        orderBy: 'fecha_ms DESC', limit: limite);
    return filas.map(ControlPlagas.fromMap).toList();
  }

  // ─── Formación ──────────────────────────────────────────

  Future<int> guardarFormacion(Formacion f) async {
    final db = await basedatos;
    return db.insert('formacion', f.toMap()..remove('id'));
  }

  Future<List<Formacion>> listarFormacion() async {
    final db = await basedatos;
    final filas =
        await db.query('formacion', orderBy: 'fecha_ms DESC');
    return filas.map(Formacion.fromMap).toList();
  }

  // ─── Trazabilidad — ejercicio de simulación ─────────────

  /// Simulación de trazabilidad hacia atrás: dado un ID de lote de
  /// producción, reconstruye las partidas de leche que lo componen.
  /// Devuelve un mapa descriptivo para el PDF de trazabilidad.
  Future<Map<String, Object?>> trazarAtras(int loteId) async {
    final lote = await obtenerLote(loteId);
    if (lote == null) return {'error': 'Lote no encontrado'};

    final partidasIds = (jsonDecode(lote.partidasLecheUsadasJson) as List<dynamic>)
        .cast<int>();
    final partidas = <Map<String, Object?>>[];
    for (final pid in partidasIds) {
      final p = await obtenerPartidaLeche(pid);
      if (p != null) {
        final prov = await obtenerProveedor(p.proveedorId);
        partidas.add({
          'partida_id': p.id,
          'fecha': DateTime.fromMillisecondsSinceEpoch(p.fechaMs).toIso8601String(),
          'volumen': p.volumenLitros,
          'proveedor': prov?.nombre ?? 'Desconocido',
        });
      }
    }

    final receta = await obtenerReceta(lote.recetaId);

    return {
      'lote': lote.numeroLote,
      'fecha': DateTime.fromMillisecondsSinceEpoch(lote.fechaMs).toIso8601String(),
      'tipo_queso': lote.tipoQuesoId,
      'receta': receta?.nombre ?? '',
      'partidas_leche': partidas,
      'fermento': '${lote.fermentoNombre} (lote ${lote.fermentoLoteComercial})',
      'cuajo': '${lote.cuajoTipo} (lote ${lote.cuajoLoteComercial})',
    };
  }

  /// Simulación de trazabilidad hacia adelante: dado un ID de proveedor
  /// o partida de leche, encuentra los lotes que la usaron y las ventas
  /// de esos lotes.
  Future<List<Map<String, Object?>>> trazarAdelante(int partidaId) async {
    final db = await basedatos;
    final busqueda = jsonEncode([partidaId]);
    final filas = await db.rawQuery(
      "SELECT * FROM lotes_produccion WHERE partidas_leche_usadas_json LIKE ?",
      ['%$busqueda%'],
    );
    final resultados = <Map<String, Object?>>[];
    for (final f in filas) {
      final l = LoteProduccion.fromMap(f);
      final ventas = await db.rawQuery(
        "SELECT * FROM ventas WHERE lineas_json LIKE ?",
        ['%"loteProduccionId":${l.id}%'],
      );
      resultados.add({
        'lote': l.numeroLote,
        'fecha': DateTime.fromMillisecondsSinceEpoch(l.fechaMs).toIso8601String(),
        'ventas': ventas.length,
      });
    }
    return resultados;
  }

  /// Trazabilidad completa: dado un lote, traza hacia atrás (materias
  /// primas) y hacia adelante (ventas) en una sola llamada.
  Future<Map<String, Object?>> trazarCompleta(int loteId) async {
    final atras = await trazarAtras(loteId);
    if (atras.containsKey('error')) return atras;

    // Piezas generadas
    final piezas = await listarPiezas(loteId: loteId);

    // Eventos de curación de todas las piezas del lote
    final todosEventos = <Map<String, Object?>>[];
    for (final p in piezas) {
      final eventos = await listarEventosDePieza(p.id!);
      for (final e in eventos) {
        todosEventos.add({
          'pieza': p.numeroPieza,
          'tipo': e.tipo,
          'fecha': DateTime.fromMillisecondsSinceEpoch(e.fechaMs)
              .toIso8601String(),
        });
      }
    }

    // Analíticas del lote
    final analiticas = await listarAnaliticas(loteId: loteId);

    // Incidencias asociadas
    final incs = await listarIncidencias();
    final incsLote = incs.where((i) => i.loteProduccionId == loteId).toList();

    // Ventas de las piezas de este lote
    final ventas = await listarVentas();
    final piezaIds = piezas.map((p) => p.id!).toSet();
    final ventasLote = ventas.where((v) {
      try {
        final lineas =
            jsonDecode(v.lineasJson) as List<dynamic>;
        return lineas.any((l) => piezaIds.contains(l['piezaId']));
      } catch (_) {
        return false;
      }
    }).toList();

    return {
      ...atras,
      'piezas': piezas.map((p) => {
        'numero': p.numeroPieza,
        'peso_inicial': p.pesoInicial,
        'peso_actual': p.pesoActual,
        'estado': p.estado,
        'ubicacion': p.ubicacionActual,
      }).toList(),
      'eventos_curacion': todosEventos,
      'analiticas': analiticas.map((a) => {
        'tipo': a.tipo,
        'conforme': a.conforme,
        'fecha': DateTime.fromMillisecondsSinceEpoch(a.fechaMs)
            .toIso8601String(),
      }).toList(),
      'incidencias': incsLote.map((i) => {
        'tipo': i.tipo,
        'descripcion': i.descripcion,
        'cerrada': i.cerrada,
      }).toList(),
      'ventas': ventasLote.map((v) => {
        'cliente': v.clienteNombre,
        'fecha': DateTime.fromMillisecondsSinceEpoch(v.fechaMs)
            .toIso8601String(),
        'total': v.total,
        'factura': v.numeroFactura,
      }).toList(),
      'completa': ventasLote.isNotEmpty,
    };
  }

  /// Selecciona un lote al azar entre los disponibles para hacer
  /// una simulación de trazabilidad no sesgada (como haría un
  /// inspector real).
  Future<LoteProduccion?> loteAleatorio() async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT * FROM lotes_produccion ORDER BY RANDOM() LIMIT 1',
    );
    if (filas.isEmpty) return null;
    return LoteProduccion.fromMap(filas.first);
  }

  // ─── Simulaciones de trazabilidad (v2) ─────────────

  Future<int> guardarSimulacion(SimulacionTrazabilidad s) async {
    final db = await basedatos;
    return db.insert('simulaciones_trazabilidad', s.toMap()..remove('id'));
  }

  Future<void> actualizarSimulacion(
      int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update('simulaciones_trazabilidad', cambios,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SimulacionTrazabilidad>> listarSimulaciones() async {
    final db = await basedatos;
    final filas = await db.query('simulaciones_trazabilidad',
        orderBy: 'fecha_ms DESC');
    return filas.map(SimulacionTrazabilidad.fromMap).toList();
  }

  Future<SimulacionTrazabilidad?> obtenerSimulacion(int id) async {
    final db = await basedatos;
    final filas = await db.query('simulaciones_trazabilidad',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return SimulacionTrazabilidad.fromMap(filas.first);
  }

  Future<void> borrarSimulacion(int id) async {
    final db = await basedatos;
    await db.delete('simulaciones_trazabilidad',
        where: 'id = ?', whereArgs: [id]);
  }

  /// Número de simulaciones realizadas en un período.
  Future<int> contarSimulaciones(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM simulaciones_trazabilidad '
      'WHERE fecha_ms BETWEEN ? AND ?',
      [desdeMs, hastaMs],
    );
    return (filas.first['n'] as int?) ?? 0;
  }

  Future<Tercero?> obtenerTercero(int id) async {
    final db = await basedatos;
    final filas = await db.query('terceros', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return Tercero.fromMap(filas.first);
  }

  Future<List<Tercero>> listarTerceros({String? tipo}) async {
    final db = await basedatos;
    final filas = tipo == null
        ? await db.query('terceros', orderBy: 'nombre ASC')
        : await db.rawQuery(
            'SELECT * FROM terceros WHERE tipo = ? OR tipo = ? ORDER BY nombre ASC',
            [tipo, 'ambos']);
    return filas.map(Tercero.fromMap).toList();
  }

  Future<int> guardarTercero(Tercero t) async {
    final db = await basedatos;
    return db.insert('terceros', t.toMap()..remove('id'));
  }

  Future<void> borrarTercero(int id) async {
    final db = await basedatos;
    await db.delete('terceros', where: 'id = ?', whereArgs: [id]);
  }

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

  Future<int> guardarIngreso(ApunteIngreso i) async {
    final db = await basedatos;
    return db.insert('apuntes_ingreso', i.toMap()..remove('id'));
  }

  Future<List<ApunteIngreso>> listarIngresos({int? desdeMs, int? hastaMs}) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (desdeMs != null) { condiciones.add('fecha_ms >= ?'); args.add(desdeMs); }
    if (hastaMs != null) { condiciones.add('fecha_ms <= ?'); args.add(hastaMs); }
    final where = condiciones.isEmpty ? null : condiciones.join(' AND ');
    final filas = await db.query('apuntes_ingreso',
        where: where, whereArgs: args.isEmpty ? null : args, orderBy: 'fecha_ms DESC');
    return filas.map(ApunteIngreso.fromMap).toList();
  }

  Future<double> totalIngresosPeriodo(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS t FROM apuntes_ingreso '
      'WHERE fecha_ms BETWEEN ? AND ?', [desdeMs, hastaMs]);
    return (filas.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<int> guardarGasto(ApunteGasto g) async {
    final db = await basedatos;
    return db.insert('apuntes_gasto', g.toMap()..remove('id'));
  }

  Future<List<ApunteGasto>> listarGastos({int? desdeMs, int? hastaMs}) async {
    final db = await basedatos;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (desdeMs != null) { condiciones.add('fecha_ms >= ?'); args.add(desdeMs); }
    if (hastaMs != null) { condiciones.add('fecha_ms <= ?'); args.add(hastaMs); }
    final where = condiciones.isEmpty ? null : condiciones.join(' AND ');
    final filas = await db.query('apuntes_gasto',
        where: where, whereArgs: args.isEmpty ? null : args, orderBy: 'fecha_ms DESC');
    return filas.map(ApunteGasto.fromMap).toList();
  }

  Future<double> totalGastosPeriodo(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS t FROM apuntes_gasto '
      'WHERE fecha_ms BETWEEN ? AND ?', [desdeMs, hastaMs]);
    return (filas.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<Map<String, double>> ingresosPorCategoria(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT categoria, COALESCE(SUM(total), 0) AS t FROM apuntes_ingreso '
      'WHERE fecha_ms BETWEEN ? AND ? GROUP BY categoria ORDER BY t DESC',
      [desdeMs, hastaMs]);
    return {for (final f in filas) (f['categoria'] as String): (f['t'] as num).toDouble()};
  }

  Future<Map<String, double>> gastosPorCategoria(int desdeMs, int hastaMs) async {
    final db = await basedatos;
    final filas = await db.rawQuery(
      'SELECT categoria, COALESCE(SUM(total), 0) AS t FROM apuntes_gasto '
      'WHERE fecha_ms BETWEEN ? AND ? GROUP BY categoria ORDER BY t DESC',
      [desdeMs, hastaMs]);
    return {for (final f in filas) (f['categoria'] as String): (f['t'] as num).toDouble()};
  }

}

// ═══════════════════════════════════════════════════════════
// ESQUEMA V1 — 15 tablas
// ═══════════════════════════════════════════════════════════

Future<void> _crearEsquemaV1(Database db) async {
  await db.execute('''
    CREATE TABLE queserias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      razon_social TEXT NOT NULL DEFAULT '',
      nif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      latitud REAL,
      longitud REAL,
      rgseaa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]'
    )
  ''');

  await db.execute('''
    CREATE TABLE proveedores_leche (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      nif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      explotacion_ganadera TEXT NOT NULL DEFAULT '',
      tipo_leche TEXT NOT NULL DEFAULT 'oveja',
      raza_id TEXT NOT NULL DEFAULT '',
      num_animales INTEGER,
      es_propio INTEGER NOT NULL DEFAULT 0,
      latitud REAL,
      longitud REAL,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE partidas_leche (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proveedor_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      volumen_litros REAL NOT NULL DEFAULT 0,
      temperatura_recepcion REAL,
      ph REAL,
      grasa REAL,
      proteina REAL,
      extracto_seco REAL,
      celulas_somaticas REAL,
      bacterias REAL,
      antibioticos_positivos INTEGER NOT NULL DEFAULT 0,
      incidencia TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (proveedor_id) REFERENCES proveedores_leche(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('''
    CREATE TABLE recetas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      tipo_queso_id TEXT NOT NULL DEFAULT '',
      do_id TEXT,
      tipo_leche TEXT NOT NULL DEFAULT 'oveja',
      fermento TEXT NOT NULL DEFAULT '',
      tipo_cuajo TEXT NOT NULL DEFAULT 'animal',
      temp_coagulacion REAL NOT NULL DEFAULT 30,
      tiempo_coag_minutos INTEGER NOT NULL DEFAULT 30,
      tam_cuajada TEXT NOT NULL DEFAULT 'medio',
      temp_cocion REAL,
      ph_salado REAL,
      rendimiento_esperado REAL NOT NULL DEFAULT 8,
      curacion_minima_dias INTEGER NOT NULL DEFAULT 60,
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');

  await db.execute('''
    CREATE TABLE lotes_produccion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numero_lote TEXT NOT NULL,
      fecha_ms INTEGER NOT NULL,
      receta_id INTEGER NOT NULL,
      tipo_queso_id TEXT NOT NULL DEFAULT '',
      do_id TEXT,
      partidas_leche_usadas_json TEXT NOT NULL DEFAULT '[]',
      volumen_leche_total REAL NOT NULL DEFAULT 0,
      peso_total_obtenido REAL NOT NULL DEFAULT 0,
      rendimiento_real REAL NOT NULL DEFAULT 0,
      num_piezas_producidas INTEGER NOT NULL DEFAULT 0,
      peso_medio_pieza REAL NOT NULL DEFAULT 0,
      fermento_nombre TEXT NOT NULL DEFAULT '',
      fermento_lote_comercial TEXT NOT NULL DEFAULT '',
      cuajo_tipo TEXT NOT NULL DEFAULT 'animal',
      cuajo_lote_comercial TEXT NOT NULL DEFAULT '',
      sal_lote TEXT NOT NULL DEFAULT '',
      temp_coagulacion REAL NOT NULL DEFAULT 30,
      tiempo_coag_minutos INTEGER NOT NULL DEFAULT 30,
      ph_cuajada REAL,
      estado TEXT NOT NULL DEFAULT 'fresca',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE RESTRICT
    )
  ''');

  await db.execute('''
    CREATE TABLE piezas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      lote_produccion_id INTEGER NOT NULL,
      numero_pieza TEXT NOT NULL,
      peso_inicial REAL NOT NULL DEFAULT 0,
      peso_actual REAL,
      ubicacion_actual TEXT NOT NULL DEFAULT '',
      estado TEXT NOT NULL DEFAULT 'afinando',
      fecha_expedicion_ms INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('''
    CREATE TABLE eventos_curacion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pieza_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL,
      peso_actual REAL,
      madera_ahumado TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (pieza_id) REFERENCES piezas(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('''
    CREATE TABLE analiticas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      laboratorio TEXT NOT NULL DEFAULT '',
      lote_produccion_id INTEGER,
      parametros_json TEXT NOT NULL DEFAULT '{}',
      conforme INTEGER NOT NULL DEFAULT 1,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE SET NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otra',
      lote_produccion_id INTEGER,
      pieza_id INTEGER,
      descripcion TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      causa TEXT NOT NULL DEFAULT '',
      accion_correctiva TEXT NOT NULL DEFAULT '',
      cerrada INTEGER NOT NULL DEFAULT 0,
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE SET NULL,
      FOREIGN KEY (pieza_id) REFERENCES piezas(id) ON DELETE SET NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE ventas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      cliente_nombre TEXT NOT NULL DEFAULT '',
      cliente_nif TEXT NOT NULL DEFAULT '',
      cliente_direccion TEXT NOT NULL DEFAULT '',
      tipo TEXT NOT NULL DEFAULT 'directa',
      lineas_json TEXT NOT NULL DEFAULT '[]',
      numero_factura TEXT NOT NULL DEFAULT '',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 10,
      total REAL NOT NULL DEFAULT 0,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE controles_temperatura (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      cava_id TEXT NOT NULL DEFAULT '',
      temperatura REAL NOT NULL DEFAULT 10,
      humedad_relativa REAL NOT NULL DEFAULT 85,
      responsable TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');

  await db.execute('''
    CREATE TABLE controles_limpieza (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      zona TEXT NOT NULL DEFAULT '',
      tarea TEXT NOT NULL DEFAULT '',
      producto_usado TEXT NOT NULL DEFAULT '',
      responsable TEXT NOT NULL DEFAULT '',
      verificado INTEGER NOT NULL DEFAULT 1,
      accion_correctiva TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');

  await db.execute('''
    CREATE TABLE controles_plagas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      medida TEXT NOT NULL DEFAULT '',
      responsable TEXT NOT NULL DEFAULT '',
      resultado TEXT NOT NULL DEFAULT '',
      proxima_revision_ms INTEGER,
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');

  await db.execute('''
    CREATE TABLE formacion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      empleado TEXT NOT NULL DEFAULT '',
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      impartido_por TEXT NOT NULL DEFAULT '',
      duracion_minutos INTEGER NOT NULL DEFAULT 0,
      documento TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )
  ''');

  // Índices para búsquedas frecuentes
  await db.execute(
      'CREATE INDEX idx_partidas_fecha ON partidas_leche(fecha_ms DESC)');
  await db.execute(
      'CREATE INDEX idx_partidas_proveedor ON partidas_leche(proveedor_id)');
  await db.execute(
      'CREATE INDEX idx_lotes_fecha ON lotes_produccion(fecha_ms DESC)');
  await db.execute(
      'CREATE INDEX idx_lotes_estado ON lotes_produccion(estado)');
  await db.execute(
      'CREATE INDEX idx_piezas_lote ON piezas(lote_produccion_id)');
  await db.execute('CREATE INDEX idx_piezas_estado ON piezas(estado)');
  await db.execute('CREATE INDEX idx_piezas_ubicacion ON piezas(ubicacion_actual)');
  await db.execute(
      'CREATE INDEX idx_eventos_pieza ON eventos_curacion(pieza_id)');
  await db.execute(
      'CREATE INDEX idx_ventas_fecha ON ventas(fecha_ms DESC)');
  await db.execute(
      'CREATE INDEX idx_temp_fecha ON controles_temperatura(fecha_ms DESC)');
  await db.execute(
      'CREATE INDEX idx_incidencias_abiertas ON incidencias(cerrada) WHERE cerrada = 0');
}


/// Esquema v2 — tabla de simulaciones de trazabilidad (aditivo, no destructivo).
Future<void> _crearEsquemaV2(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS simulaciones_trazabilidad (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      elemento_simulado TEXT NOT NULL DEFAULT '',
      aleatorio INTEGER NOT NULL DEFAULT 0,
      completa INTEGER NOT NULL DEFAULT 0,
      resumen TEXT NOT NULL DEFAULT '',
      resultado_json TEXT NOT NULL DEFAULT '{}',
      tiempo_segundos INTEGER NOT NULL DEFAULT 0,
      realizada_por TEXT NOT NULL DEFAULT '',
      firma_inspector TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_simulaciones_fecha '
      'ON simulaciones_trazabilidad(fecha_ms DESC)');
}

/// Esquema v3 — tablas de contabilidad fiscal (aditivo).
Future<void> _crearEsquemaV3(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS terceros (
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
  await db.execute('''
    CREATE TABLE IF NOT EXISTS configuraciones_fiscales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      regimen_iva TEXT NOT NULL DEFAULT 'reagp',
      regimen_irpf TEXT NOT NULL DEFAULT 'estimacion_directa_simplificada',
      compensacion_reagp INTEGER NOT NULL DEFAULT 1
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS apuntes_ingreso (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tercero_id INTEGER NOT NULL DEFAULT 0,
      categoria TEXT NOT NULL DEFAULT 'venta_queso',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 10,
      total REAL NOT NULL DEFAULT 0,
      numero_factura TEXT NOT NULL DEFAULT '',
      lote_referencia TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS apuntes_gasto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tercero_id INTEGER NOT NULL DEFAULT 0,
      categoria TEXT NOT NULL DEFAULT 'otros',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 21,
      total REAL NOT NULL DEFAULT 0,
      numero_factura TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )
  ''');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_ingresos_fecha ON apuntes_ingreso(fecha_ms DESC)');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_gastos_fecha ON apuntes_gasto(fecha_ms DESC)');
}

/// Esquema v4 — tabla de facturas (aditivo).
Future<void> _crearEsquemaV4(Database db) async {
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
  await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_facturas_fecha ON facturas(fecha_emision_ms DESC)');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_facturas_estado ON facturas(estado)');
}
