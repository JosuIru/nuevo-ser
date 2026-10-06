part of 'base_datos.dart';

/// Lápida de algo borrado en este móvil, pendiente de subir.
class BorradoPendiente {
  const BorradoPendiente(this.tipo, this.uid, {this.borradoMs = 0});
  final String tipo;
  final String uid;

  /// Cuándo se borró: viaja como `actualizado_ms` de la lápida.
  final int borradoMs;
}

/// Escritura con identidad de sincronización y la parte de la BD que usa
/// `ClienteSyncZunbeltz`: traducir filas al sobre del servidor y aplicar lo
/// que llega. Ver `esquema_sincronizable.dart`.
extension SincronizacionBaseDatos on BaseDatosSoleraZunbeltz {
  // ─── Escritura local (marca uid / actualizado_ms / lápidas) ───

  /// Inserta una fila de una tabla sincronizable con `uid` (el que traiga
  /// la fila, [uid], o uno nuevo) y la marca de tiempo de ahora.
  Future<int> _insertarSincronizable(
      DatabaseExecutor db, String tabla, Map<String, Object?> fila,
      {String? uid}) {
    final uidFila = uid ?? (fila['uid'] as String?);
    return db.insert(tabla, {
      ...fila,
      'uid': (uidFila == null || uidFila.isEmpty) ? generarUid() : uidFila,
      'actualizado_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _actualizarSincronizable(
      String tabla, int id, Map<String, Object?> cambios) async {
    final db = await basedatos;
    await db.update(
      tabla,
      {...cambios, 'actualizado_ms': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Borra una fila dejando lápida de ella y de todo lo que se lleva por
  /// delante (los puntos de una finca, los apuntes de un proyecto, las
  /// tareas de la finca…), para que el borrado llegue a los demás móviles.
  Future<void> _borrarSincronizable(String tabla, int id) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      final lapidas = <BorradoPendiente>[];
      await _borrarConLapidas(txn, tabla, id, lapidas);
      final ahora = DateTime.now().millisecondsSinceEpoch;
      for (final lapida in lapidas) {
        await txn.insert(
          'borrados_sync',
          {'tipo': lapida.tipo, 'uid': lapida.uid, 'borrado_ms': ahora},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Borra [id] de [tabla] y, a mano, lo que cuelga de ella; anota las
  /// lápidas en [lapidas]. Sin lápidas (lista `null`) sirve para aplicar un
  /// borrado que viene del servidor.
  Future<void> _borrarConLapidas(DatabaseExecutor txn, String tabla, int id,
      List<BorradoPendiente>? lapidas) async {
    final descriptor = tablaSincronizablePorNombre(tabla);
    if (descriptor == null) return;
    final uid = await _uidDeFilaEn(txn, tabla, id);
    if (uid != null && uid.isNotEmpty) {
      lapidas?.add(BorradoPendiente(descriptor.tipo, uid));
    }

    // Hijas en cascada (por referencia o por pertenencia al proyecto).
    for (final hija in tablasSincronizables) {
      final columnas = [
        for (final referencia in hija.referencias)
          if (referencia.tablaDestino == tabla &&
              referencia.alBorrar == AlBorrarReferencia.cascada)
            referencia.columna,
        if (tabla == 'proyectos_test' && hija.columnaProyecto != null)
          hija.columnaProyecto!,
      ];
      for (final columna in columnas) {
        final filas = await txn.query(hija.tabla,
            columns: ['id'], where: '$columna = ?', whereArgs: [id]);
        for (final fila in filas) {
          await _borrarConLapidas(txn, hija.tabla, fila['id'] as int, lapidas);
        }
      }
    }

    // Tareas: se borran con su finca; con su punto o zona se desanclan.
    if (tabla == 'fincas') {
      final tareas = await txn.query('tareas_mantenimiento',
          columns: ['uid'], where: 'finca_id = ?', whereArgs: [id]);
      for (final tarea in tareas) {
        lapidas?.add(BorradoPendiente('tarea', tarea['uid'] as String));
      }
      await txn.delete('tareas_mantenimiento',
          where: 'finca_id = ?', whereArgs: [id]);
    } else if (tabla == 'zonas_finca') {
      await txn.update('tareas_mantenimiento', {'zona_id': null},
          where: 'zona_id = ?', whereArgs: [id]);
    }
    await txn.delete(tabla, where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> _uidDeFilaEn(
      DatabaseExecutor db, String tabla, int id) async {
    final filas = await db.query(tabla,
        columns: ['uid'], where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : filas.first['uid'] as String?;
  }

  Future<int?> _idDeUidEn(DatabaseExecutor db, String tabla, String uid) async {
    if (uid.isEmpty) return null;
    final filas = await db.query(tabla,
        columns: ['id'], where: 'uid = ?', whereArgs: [uid], limit: 1);
    return filas.isEmpty ? null : filas.first['id'] as int;
  }

  // ─── Consultas de identidad ───

  Future<String?> uidDeFila(String tabla, int id) async =>
      _uidDeFilaEn(await basedatos, tabla, id);

  Future<int?> idDeUid(String tabla, String uid) async =>
      _idDeUidEn(await basedatos, tabla, uid);

  // ─── Lápidas y cursores ───

  Future<List<BorradoPendiente>> listarBorradosPendientes() async {
    final db = await basedatos;
    final filas = await db.query('borrados_sync', orderBy: 'borrado_ms ASC');
    return [
      for (final fila in filas)
        BorradoPendiente(fila['tipo'] as String, fila['uid'] as String,
            borradoMs: (fila['borrado_ms'] as num).toInt()),
    ];
  }

  Future<void> olvidarBorrados(Iterable<BorradoPendiente> borrados) async {
    final db = await basedatos;
    final lote = db.batch();
    for (final borrado in borrados) {
      lote.delete('borrados_sync',
          where: 'tipo = ? AND uid = ?',
          whereArgs: [borrado.tipo, borrado.uid]);
    }
    await lote.commit(noResult: true);
  }

  Future<int> leerEstadoSync(String clave) async {
    final db = await basedatos;
    final filas = await db.query('estado_sync',
        where: 'clave = ?', whereArgs: [clave], limit: 1);
    return filas.isEmpty ? 0 : (filas.first['valor'] as num).toInt();
  }

  Future<void> guardarEstadoSync(String clave, int valor) async {
    final db = await basedatos;
    await db.insert('estado_sync', {'clave': clave, 'valor': valor},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── Actividad del espacio ───

  Future<void> guardarActividadEspacio(List<EntradaActividad> entradas) async {
    final db = await basedatos;
    final lote = db.batch();
    for (final entrada in entradas) {
      lote.insert('actividad_espacio', entrada.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await lote.commit(noResult: true);
  }

  /// Lo más reciente primero.
  Future<List<EntradaActividad>> listarActividadEspacio(
      {int limite = 200}) async {
    final db = await basedatos;
    final filas = await db.query('actividad_espacio',
        orderBy: 'momento_ms DESC, id DESC', limit: limite);
    return filas.map(EntradaActividad.fromMap).toList();
  }

  // ─── Subida: filas → sobre del servidor ───

  /// Filas cambiadas en este móvil después de [desdeMs], ya en el formato
  /// del API, en orden de dependencias.
  Future<List<Map<String, Object?>>> entidadesPendientesDeSubir(
      int desdeMs) async {
    final db = await basedatos;
    final entidades = <Map<String, Object?>>[];
    for (final descriptor in tablasSincronizables) {
      final filas = await db.query(descriptor.tabla,
          where: 'actualizado_ms > ?', whereArgs: [desdeMs]);
      for (final fila in filas) {
        entidades.add(await _filaAEntidad(db, descriptor, fila));
      }
    }
    return entidades;
  }

  Future<Map<String, Object?>> _filaAEntidad(DatabaseExecutor db,
      TablaSincronizable descriptor, Map<String, Object?> fila) async {
    final datos = Map<String, Object?>.from(fila)
      ..remove('id')
      ..remove('uid')
      ..remove('actualizado_ms')
      ..remove('autor_uid');
    for (final columna in descriptor.columnasLocales) {
      datos.remove(columna);
    }
    for (final referencia in descriptor.referencias) {
      final idReferido = datos.remove(referencia.columna) as int?;
      datos[referencia.claveUid] = idReferido == null
          ? ''
          : (await _uidDeFilaEn(db, referencia.tablaDestino, idReferido)) ?? '';
    }
    var proyectoUid = '';
    if (descriptor.columnaProyecto != null) {
      final proyectoId = datos.remove(descriptor.columnaProyecto) as int?;
      if (proyectoId != null) {
        proyectoUid =
            (await _uidDeFilaEn(db, 'proyectos_test', proyectoId)) ?? '';
      }
    }
    return {
      'tipo': descriptor.tipo,
      'uid': fila['uid'],
      'actualizado_ms': fila['actualizado_ms'],
      'borrado': false,
      'proyecto_uid': proyectoUid,
      'autor_uid': (fila['autor_uid'] as String?) ?? '',
      'datos': datos,
    };
  }

  // ─── Bajada: sobre del servidor → filas ───

  /// Aplica una entidad recibida. Sin [forzar] respeta una versión local más
  /// reciente (last-write-wins). Devuelve `true` si cambió algo en local.
  /// Una entidad cuyas referencias obligatorias no existen en este móvil se
  /// descarta (devuelve `false`).
  Future<bool> aplicarEntidadRemota(Map<String, Object?> entidad,
      {bool forzar = false}) async {
    final descriptor =
        tablaSincronizablePorTipo((entidad['tipo'] as String?) ?? '');
    final uid = (entidad['uid'] as String?) ?? '';
    if (descriptor == null || uid.isEmpty) return false;
    final db = await basedatos;
    final existentes = await db.query(descriptor.tabla,
        where: 'uid = ?', whereArgs: [uid], limit: 1);
    final existente = existentes.isEmpty ? null : existentes.first;

    if (entidad['borrado'] == true) {
      if (existente == null) return false;
      await db.transaction((txn) => _borrarConLapidas(
          txn, descriptor.tabla, existente['id'] as int, null));
      return true;
    }

    final actualizadoMs = (entidad['actualizado_ms'] as num?)?.toInt() ?? 0;
    if (existente != null &&
        !forzar &&
        actualizadoMs <=
            ((existente['actualizado_ms'] as num?)?.toInt() ?? 0)) {
      return false;
    }

    final columnas = await _columnasDe(db, descriptor.tabla);
    final datos = Map<String, Object?>.from(
        (entidad['datos'] as Map?) ?? const <String, Object?>{});
    final fila = <String, Object?>{};
    for (final referencia in descriptor.referencias) {
      final uidReferido = (datos.remove(referencia.claveUid) as String?) ?? '';
      final idReferido =
          await _idDeUidEn(db, referencia.tablaDestino, uidReferido);
      if (idReferido == null && referencia.obligatoria) return false;
      fila[referencia.columna] = idReferido;
    }
    if (descriptor.columnaProyecto != null) {
      final proyectoId = await _idDeUidEn(
          db, 'proyectos_test', (entidad['proyecto_uid'] as String?) ?? '');
      if (proyectoId == null && descriptor.proyectoObligatorio) return false;
      fila[descriptor.columnaProyecto!] = proyectoId;
    }
    // Solo columnas que existen en esta versión de la app: un servidor o un
    // móvil más nuevos pueden mandar campos que aquí aún no hay.
    for (final entrada in datos.entries) {
      if (columnas.contains(entrada.key) &&
          !descriptor.columnasLocales.contains(entrada.key) &&
          entrada.key != 'id') {
        fila[entrada.key] = _valorSqlite(entrada.value);
      }
    }
    if (columnas.contains('autor_uid')) {
      fila['autor_uid'] = (entidad['autor_uid'] as String?) ?? '';
    }
    fila['actualizado_ms'] = actualizadoMs;

    if (existente == null) {
      await db.insert(descriptor.tabla, {...fila, 'uid': uid});
    } else {
      await db.update(descriptor.tabla, fila,
          where: 'id = ?', whereArgs: [existente['id']]);
    }
    return true;
  }

  /// Borra en local (sin lápida) lo que el servidor ha rechazado y no tiene.
  Future<void> borrarEntidadSinLapida(String tipo, String uid) async {
    final descriptor = tablaSincronizablePorTipo(tipo);
    if (descriptor == null) return;
    final db = await basedatos;
    final id = await _idDeUidEn(db, descriptor.tabla, uid);
    if (id == null) return;
    await db.transaction(
        (txn) => _borrarConLapidas(txn, descriptor.tabla, id, null));
  }

  /// Tras una sincronización completa: borra (sin lápida) lo que el
  /// servidor no ha mandado, porque esta persona ya no lo ve. Devuelve
  /// cuántas filas se retiraron.
  Future<int> retirarEntidadesNoRecibidas(
      Map<String, Set<String>> uidsRecibidosPorTipo) async {
    final db = await basedatos;
    var retiradas = 0;
    for (final descriptor in tablasSincronizables.reversed) {
      final recibidos = uidsRecibidosPorTipo[descriptor.tipo] ?? const {};
      final filas = await db.query(descriptor.tabla, columns: ['id', 'uid']);
      for (final fila in filas) {
        if (recibidos.contains(fila['uid'])) continue;
        // Puede haberse ido ya en cascada con su padre.
        if (await _uidDeFilaEn(db, descriptor.tabla, fila['id'] as int) ==
            null) {
          continue;
        }
        await db.transaction((txn) =>
            _borrarConLapidas(txn, descriptor.tabla, fila['id'] as int, null));
        retiradas++;
      }
    }
    return retiradas;
  }

  Future<Set<String>> _columnasDe(DatabaseExecutor db, String tabla) async {
    final filas = await db.rawQuery('PRAGMA table_info($tabla)');
    return {for (final fila in filas) fila['name'] as String};
  }

  /// SQLite no guarda booleanos: el JSON puede traer `true`/`false`.
  Object? _valorSqlite(Object? valor) => switch (valor) {
        true => 1,
        false => 0,
        _ => valor,
      };
}
