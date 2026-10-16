part of 'base_datos.dart';

/// Un lote con lo que hace falta para pintarlo: cabezas y dónde está.
class ResumenLote {
  const ResumenLote({
    required this.lote,
    required this.cabezas,
    this.ultimoMovimiento,
  });

  final LoteGanado lote;
  final int cabezas;
  final MovimientoGanado? ultimoMovimiento;

  /// Pieza en la que está (null: fuera del espacio o sin ubicar).
  int? get zonaId => ultimoMovimiento == null || ultimoMovimiento!.esSalida
      ? null
      : ultimoMovimiento!.zonaDestinoId;
}

/// El ganado: lotes, animales, movimientos y eventos de manejo. Ver
/// `modelos/ganado.dart`.
extension GanadoBaseDatos on BaseDatosSoleraZunbeltz {
  // ─── Lotes ───

  Future<int> guardarLote(LoteGanado lote) async {
    final db = await basedatos;
    return _insertarSincronizable(db, 'lotes_ganado', {
      ...lote.toMap()..remove('id'),
      if (lote.fechaCreacionMs == 0)
        'fecha_creacion_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> actualizarLote(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('lotes_ganado', id, cambios);

  /// Borra el lote con sus movimientos y eventos; sus animales se quedan
  /// sin lote.
  Future<void> borrarLote(int id) => _borrarSincronizable('lotes_ganado', id);

  Future<LoteGanado?> obtenerLote(int id) async {
    final db = await basedatos;
    final filas = await db.query('lotes_ganado',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : LoteGanado.fromMap(filas.first);
  }

  Future<List<LoteGanado>> listarLotes({bool soloActivos = false}) async {
    final db = await basedatos;
    final filas = await db.query('lotes_ganado',
        where: soloActivos ? 'estado != ?' : null,
        whereArgs: soloActivos ? [estadoLoteCerrado] : null,
        orderBy: 'nombre COLLATE NOCASE ASC');
    return filas.map(LoteGanado.fromMap).toList();
  }

  /// Los lotes con sus cabezas y su último movimiento.
  Future<List<ResumenLote>> listarResumenLotes(
      {bool soloActivos = true}) async {
    final lotes = await listarLotes(soloActivos: soloActivos);
    final animales = await listarAnimales(soloActivos: true);
    final movimientos = await listarMovimientos();
    return [
      for (final lote in lotes)
        ResumenLote(
          lote: lote,
          cabezas: cabezasDeLote(
              lote, animales.where((animal) => animal.loteId == lote.id)),
          ultimoMovimiento: ultimoMovimiento(
              movimientos.where((movimiento) => movimiento.loteId == lote.id)),
        ),
    ];
  }

  /// Los lotes activos que están ahora en cada pieza.
  Future<Map<int, List<ResumenLote>>> lotesPorZona() async {
    final porZona = <int, List<ResumenLote>>{};
    for (final resumen in await listarResumenLotes()) {
      final zonaId = resumen.zonaId;
      if (zonaId != null) (porZona[zonaId] ??= []).add(resumen);
    }
    return porZona;
  }

  // ─── Animales ───

  Future<int> guardarAnimal(Animal animal) async {
    final db = await basedatos;
    return _insertarSincronizable(db, 'animales', animal.toMap()..remove('id'));
  }

  Future<void> actualizarAnimal(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('animales', id, cambios);

  Future<void> borrarAnimal(int id) => _borrarSincronizable('animales', id);

  Future<Animal?> obtenerAnimal(int id) async {
    final db = await basedatos;
    final filas =
        await db.query('animales', where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : Animal.fromMap(filas.first);
  }

  Future<List<Animal>> listarAnimales(
      {int? loteId, bool soloActivos = false}) async {
    final db = await basedatos;
    final condiciones = <String>[
      if (loteId != null) 'lote_id = ?',
      if (soloActivos) 'estado = ?',
    ];
    final filas = await db.query('animales',
        where: condiciones.isEmpty ? null : condiciones.join(' AND '),
        whereArgs: [
          if (loteId != null) loteId,
          if (soloActivos) estadoAnimalActivo,
        ],
        orderBy: 'identificacion COLLATE NOCASE ASC');
    return filas.map(Animal.fromMap).toList();
  }

  // ─── Movimientos ───

  Future<int> guardarMovimiento(MovimientoGanado movimiento) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'movimientos_ganado', movimiento.toMap()..remove('id'));
  }

  /// Mueve el lote: apunta el movimiento desde donde está ahora, con las
  /// cabezas que tiene.
  Future<int> moverLote({
    required int loteId,
    required int fechaMs,
    required String tipo,
    int? zonaDestinoId,
    String destinoExterno = '',
    String guia = '',
    String notas = '',
    String autorUid = '',
  }) async {
    final lote = await obtenerLote(loteId);
    if (lote == null) throw StateError('No existe el lote $loteId');
    final movimientos = await listarMovimientos(loteId: loteId);
    final animales = await listarAnimales(loteId: loteId, soloActivos: true);
    return guardarMovimiento(MovimientoGanado(
      loteId: loteId,
      fechaMs: fechaMs,
      tipo: tipo,
      zonaOrigenId: zonaActualDeLote(movimientos),
      zonaDestinoId: tipo == tipoMovimientoSalida ? null : zonaDestinoId,
      destinoExterno: destinoExterno,
      cabezas: cabezasDeLote(lote, animales),
      guia: guia,
      notas: notas,
      autorUid: autorUid,
    ));
  }

  Future<void> borrarMovimiento(int id) =>
      _borrarSincronizable('movimientos_ganado', id);

  /// Los movimientos, del más reciente al más antiguo.
  Future<List<MovimientoGanado>> listarMovimientos({int? loteId}) async {
    final db = await basedatos;
    final filas = await db.query('movimientos_ganado',
        where: loteId == null ? null : 'lote_id = ?',
        whereArgs: loteId == null ? null : [loteId],
        orderBy: 'fecha_ms DESC, id DESC');
    return filas.map(MovimientoGanado.fromMap).toList();
  }

  // ─── Eventos de manejo ───

  Future<int> guardarEventoGanado(EventoGanado evento) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'eventos_ganado', evento.toMap()..remove('id'));
  }

  Future<void> borrarEventoGanado(int id) =>
      _borrarSincronizable('eventos_ganado', id);

  /// Los eventos de un animal (con los de su lote si se pasa [loteId]) o
  /// los de un lote, del más reciente al más antiguo.
  Future<List<EventoGanado>> listarEventosGanado(
      {int? animalId, int? loteId}) async {
    final db = await basedatos;
    final condiciones = <String>[
      if (animalId != null) 'animal_id = ?',
      if (loteId != null) '(lote_id = ? AND animal_id IS NULL)',
    ];
    final filas = await db.query('eventos_ganado',
        where: condiciones.isEmpty ? null : condiciones.join(' OR '),
        whereArgs: [
          if (animalId != null) animalId,
          if (loteId != null) loteId,
        ],
        orderBy: 'fecha_ms DESC, id DESC');
    return filas.map(EventoGanado.fromMap).toList();
  }
}
