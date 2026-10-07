part of 'base_datos.dart';

/// Agenda de contactos, rendimientos de referencia y escenarios de la
/// calculadora de transformación.
extension AgendaBaseDatos on BaseDatosSoleraZunbeltz {
  // ─── Contactos ───

  Future<int> guardarContacto(Contacto contacto) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'contactos', contacto.toMap()..remove('id'));
  }

  Future<void> actualizarContacto(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('contactos', id, cambios);

  Future<void> borrarContacto(int id) => _borrarSincronizable('contactos', id);

  Future<List<Contacto>> listarContactos({String? tipo}) async {
    final db = await basedatos;
    final filas = await db.query(
      'contactos',
      where: tipo == null ? null : 'tipo = ?',
      whereArgs: tipo == null ? null : [tipo],
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return filas.map(Contacto.fromMap).toList();
  }

  // ─── Rendimientos de referencia ───

  Future<int> guardarRendimiento(RendimientoReferencia rendimiento) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'rendimientos', rendimiento.toMap()..remove('id'));
  }

  Future<void> borrarRendimiento(int id) =>
      _borrarSincronizable('rendimientos', id);

  Future<List<RendimientoReferencia>> listarRendimientos() async {
    final db = await basedatos;
    final filas =
        await db.query('rendimientos', orderBy: 'nombre COLLATE NOCASE ASC');
    return filas.map(RendimientoReferencia.fromMap).toList();
  }

  // ─── Escenarios de transformación ───

  Future<int> guardarEscenario(EscenarioTransformacion escenario) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'escenarios_transformacion', escenario.toMap()..remove('id'));
  }

  Future<void> borrarEscenario(int id) =>
      _borrarSincronizable('escenarios_transformacion', id);

  Future<List<EscenarioTransformacion>> listarEscenarios(int proyectoId) async {
    final db = await basedatos;
    final filas = await db.query('escenarios_transformacion',
        where: 'proyecto_id = ?',
        whereArgs: [proyectoId],
        orderBy: 'fecha_ms DESC');
    return filas.map(EscenarioTransformacion.fromMap).toList();
  }
}
