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
}
