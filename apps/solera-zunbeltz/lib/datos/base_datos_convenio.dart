part of 'base_datos.dart';

/// Lo que el convenio tester añade a un proyecto: presupuesto, fianza,
/// acompañamiento e incidencias de cumplimiento.
extension ConvenioBaseDatos on BaseDatosSoleraZunbeltz {
  Future<List<Map<String, Object?>>> _filasDeProyecto(
      String tabla, int proyectoId, String orden) async {
    final db = await basedatos;
    return db.query(tabla,
        where: 'proyecto_id = ?', whereArgs: [proyectoId], orderBy: orden);
  }

  Future<int> _guardarDeProyecto(
      String tabla, Map<String, Object?> fila) async {
    final db = await basedatos;
    return _insertarSincronizable(db, tabla, fila..remove('id'));
  }

  // ─── Presupuesto (anexo II) ───

  Future<int> guardarPartidaPresupuesto(PartidaPresupuesto partida) =>
      _guardarDeProyecto('partidas_presupuesto', partida.toMap());

  Future<List<PartidaPresupuesto>> listarPresupuesto(int proyectoId) async =>
      (await _filasDeProyecto(
              'partidas_presupuesto', proyectoId, 'categoria ASC'))
          .map(PartidaPresupuesto.fromMap)
          .toList();

  Future<void> borrarPartidaPresupuesto(int id) =>
      _borrarSincronizable('partidas_presupuesto', id);

  // ─── Fianza ───

  Future<int> guardarMovimientoFianza(MovimientoFianza movimiento) =>
      _guardarDeProyecto('movimientos_fianza', movimiento.toMap());

  Future<List<MovimientoFianza>> listarMovimientosFianza(
          int proyectoId) async =>
      (await _filasDeProyecto(
              'movimientos_fianza', proyectoId, 'fecha_ms DESC'))
          .map(MovimientoFianza.fromMap)
          .toList();

  Future<void> borrarMovimientoFianza(int id) =>
      _borrarSincronizable('movimientos_fianza', id);

  // ─── Acompañamiento (anexo IV) ───

  Future<int> guardarAcompanamiento(Acompanamiento acompanamiento) =>
      _guardarDeProyecto('acompanamientos', acompanamiento.toMap());

  Future<void> actualizarAcompanamiento(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('acompanamientos', id, cambios);

  Future<List<Acompanamiento>> listarAcompanamientos(int proyectoId) async =>
      (await _filasDeProyecto('acompanamientos', proyectoId, 'fecha_ms DESC'))
          .map(Acompanamiento.fromMap)
          .toList();

  Future<void> borrarAcompanamiento(int id) =>
      _borrarSincronizable('acompanamientos', id);

  // ─── Incidencias de cumplimiento (art. 8) ───

  Future<int> guardarIncidencia(IncidenciaCumplimiento incidencia) =>
      _guardarDeProyecto('incidencias_cumplimiento', incidencia.toMap());

  Future<List<IncidenciaCumplimiento>> listarIncidencias(
          int proyectoId) async =>
      (await _filasDeProyecto(
              'incidencias_cumplimiento', proyectoId, 'fecha_ms DESC'))
          .map(IncidenciaCumplimiento.fromMap)
          .toList();

  Future<void> borrarIncidencia(int id) =>
      _borrarSincronizable('incidencias_cumplimiento', id);

  // ─── Inventario de amortizaciones ───

  Future<int> guardarBien(BienAmortizable bien) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'bienes_amortizables', bien.toMap()..remove('id'));
  }

  Future<void> actualizarBien(BienAmortizable bien) => _actualizarSincronizable(
      'bienes_amortizables', bien.id!, bien.toMap()..remove('id'));

  Future<List<BienAmortizable>> listarBienes() async {
    final db = await basedatos;
    final filas = await db.query('bienes_amortizables',
        orderBy: 'grupo ASC, nombre COLLATE NOCASE ASC');
    return filas.map(BienAmortizable.fromMap).toList();
  }

  /// Borra el bien y, con él, su uso en los proyectos.
  Future<void> borrarBien(int id) =>
      _borrarSincronizable('bienes_amortizables', id);

  Future<int> guardarUsoBien(UsoBien uso) =>
      _guardarDeProyecto('usos_bienes', uso.toMap());

  Future<List<UsoBien>> listarUsosBienes(int proyectoId) async =>
      (await _filasDeProyecto('usos_bienes', proyectoId, 'id ASC'))
          .map(UsoBien.fromMap)
          .toList();

  Future<void> borrarUsoBien(int id) => _borrarSincronizable('usos_bienes', id);

  /// Cuotas de amortización del inventario para un proyecto, como apuntes
  /// del bloque VI (calculados, no guardados). Con periodo, la parte que
  /// cae en él.
  Future<List<ApunteEconomico>> amortizacionesDelInventario(
    ProyectoTest proyecto, {
    int? desdeMs,
    int? hastaMs,
  }) async {
    final usos = await listarUsosBienes(proyecto.id!);
    if (usos.isEmpty) return const [];
    final bienes = {
      for (final bien in await listarBienes()) bien.id!: bien,
    };
    return apuntesDeAmortizacion(
      proyecto: proyecto,
      usos: usos,
      bienesPorId: bienes,
      fincaId: proyecto.fincaId ?? 0,
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );
  }
}
