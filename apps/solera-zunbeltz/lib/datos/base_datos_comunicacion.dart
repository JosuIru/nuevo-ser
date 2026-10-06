part of 'base_datos.dart';

/// Peticiones de tarea y avisos de campo: lo que el equipo se cuenta.
extension ComunicacionBaseDatos on BaseDatosSoleraZunbeltz {
  // ─── Peticiones de tarea ───

  Future<int> guardarPeticion(PeticionTarea peticion) async {
    final db = await basedatos;
    return _insertarSincronizable(
        db, 'peticiones', peticion.toMap()..remove('id'));
  }

  Future<void> actualizarPeticion(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('peticiones', id, cambios);

  Future<void> borrarPeticion(int id) => _borrarSincronizable('peticiones', id);

  /// Pendientes primero (urgentes delante), luego las demás, recientes antes.
  Future<List<PeticionTarea>> listarPeticiones({String? estado}) async {
    final db = await basedatos;
    final filas = await db.query(
      'peticiones',
      where: estado == null ? null : 'estado = ?',
      whereArgs: estado == null ? null : [estado],
      orderBy:
          "estado = 'pendiente' DESC, urgente DESC, fecha_creacion_ms DESC",
    );
    return filas.map(PeticionTarea.fromMap).toList();
  }

  Future<int> contarPeticionesPendientes() async {
    final db = await basedatos;
    return Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM peticiones WHERE estado = 'pendiente'")) ??
        0;
  }

  /// Acepta la petición creando su tarea en la misma transacción.
  Future<void> aceptarPeticion(int peticionId, TareaMantenimiento tarea) async {
    final db = await basedatos;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.insert('tareas_mantenimiento', tarea.toMap()..remove('id'));
      await txn.update(
        'peticiones',
        {
          'estado': estadoPeticionAceptada,
          'tarea_uid': tarea.uid,
          'actualizado_ms': ahora,
        },
        where: 'id = ?',
        whereArgs: [peticionId],
      );
    });
  }

  // ─── Avisos de campo ───

  Future<int> guardarAviso(AvisoCampo aviso) async {
    final db = await basedatos;
    return _insertarSincronizable(db, 'avisos', aviso.toMap()..remove('id'));
  }

  Future<void> actualizarAviso(int id, Map<String, Object?> cambios) =>
      _actualizarSincronizable('avisos', id, cambios);

  Future<void> borrarAviso(int id) => _borrarSincronizable('avisos', id);

  /// Abiertos primero (alarmas delante), luego resueltos; recientes antes.
  Future<List<AvisoCampo>> listarAvisos(
      {String? categoria, bool soloAbiertos = false}) async {
    final db = await basedatos;
    final condiciones = <String>[
      if (categoria != null) 'categoria = ?',
      if (soloAbiertos) "estado = 'abierto'",
    ];
    final filas = await db.query(
      'avisos',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: categoria == null ? null : [categoria],
      orderBy:
          "estado = 'abierto' DESC, gravedad = 'alarma' DESC, fecha_ms DESC",
    );
    return filas.map(AvisoCampo.fromMap).toList();
  }
}
