part of 'base_datos.dart';

/// Una foto preparada en este móvil que el servidor aún no tiene.
class FotoPorSubir {
  const FotoPorSubir({
    required this.hash,
    required this.rutaSubida,
    this.intentos = 0,
    this.ultimoIntentoMs = 0,
  });

  final String hash;

  /// Copia reducida (JPEG) que se sube.
  final String rutaSubida;
  final int intentos;
  final int ultimoIntentoMs;
}

/// Una foto que alguna entidad de este móvil referencia (`foto:<hash>`)
/// y que no está en ningún fichero local.
class FotoPorBajar {
  const FotoPorBajar(
      {required this.hash, this.intentos = 0, this.ultimoIntentoMs = 0});

  final String hash;
  final int intentos;
  final int ultimoIntentoMs;
}

/// Correspondencia entre fotos (por hash) y ficheros de este móvil, y la
/// cola de lo que falta subir o bajar. Ver `utiles/fotos_sincronizadas.dart`
/// y `servicios/servicio_fotos_sync.dart`.
extension FotosBaseDatos on BaseDatosSoleraZunbeltz {
  /// Hash de cada fichero local conocido (fotos preparadas o bajadas).
  Future<Map<String, String>> _hashPorRutaFoto(DatabaseExecutor db) async {
    final filas = await db.query('rutas_fotos');
    return {
      for (final fila in filas) fila['ruta'] as String: fila['hash'] as String,
    };
  }

  /// Fichero que se ve en este móvil para cada hash que tenga uno.
  Future<Map<String, String>> _rutaLocalPorHashFoto(DatabaseExecutor db) async {
    final filas = await db.query('fotos_sync',
        columns: ['hash', 'ruta_local'], where: "ruta_local != ''");
    return {
      for (final fila in filas)
        fila['hash'] as String: fila['ruta_local'] as String,
    };
  }

  /// Hashes que viajan al servidor por la lista JSON [json] de una columna
  /// de fotos.
  Future<List<String>> hashesFotoDeColumna(String? json) async =>
      hashesDeEntradasFoto(GestorFotos.decodificar(json),
          await _hashPorRutaFoto(await basedatos));

  /// Lista JSON de entradas locales para los [hashes] recibidos, sin perder
  /// las fotos de [columnaActual] que nunca se pudieron subir
  /// (`combinarFotosRecibidas`).
  Future<String> columnaFotoDeHashes(Iterable<Object?> hashes,
          {String? columnaActual}) async =>
      _columnaFotoDeHashes(await basedatos, hashes, columnaActual);

  Future<String> _columnaFotoDeHashes(DatabaseExecutor db,
      Iterable<Object?> hashes, String? columnaActual) async {
    final recibidas =
        entradasFotoDeHashes(hashes, await _rutaLocalPorHashFoto(db));
    final actuales = GestorFotos.decodificar(columnaActual);
    if (actuales.isEmpty) return GestorFotos.codificar(recibidas);
    return GestorFotos.codificar(combinarFotosRecibidas(
        recibidas, actuales, (await _hashPorRutaFoto(db)).keys.toSet()));
  }

  /// Fichero de la foto [hash] en este móvil, o `null` si no lo tiene.
  Future<String?> rutaLocalDeFoto(String hash) async {
    final db = await basedatos;
    final filas = await db.query('fotos_sync',
        columns: ['ruta_local'],
        where: "hash = ? AND ruta_local != ''",
        whereArgs: [hash],
        limit: 1);
    return filas.isEmpty ? null : filas.first['ruta_local'] as String;
  }

  /// Todas las entradas de todas las columnas de fotos (rutas y
  /// referencias), sin repetir.
  Future<Set<String>> _entradasFotoGuardadas(DatabaseExecutor db) async {
    final entradas = <String>{};
    for (final MapEntry(key: tabla, value: columnas)
        in columnasFotosPorTabla.entries) {
      final filas = await db.query(tabla, columns: columnas);
      for (final fila in filas) {
        for (final columna in columnas) {
          entradas.addAll(GestorFotos.decodificar(fila[columna] as String?));
        }
      }
    }
    return entradas;
  }

  /// Rutas de fichero que alguna entidad usa y que aún no tienen hash (fotos
  /// hechas en este móvil sin preparar para subir).
  Future<List<String>> rutasFotoSinPreparar() async {
    final db = await basedatos;
    final conocidas = await _hashPorRutaFoto(db);
    return [
      for (final entrada in await _entradasFotoGuardadas(db))
        if (!esReferenciaFoto(entrada) &&
            entrada.isNotEmpty &&
            !conocidas.containsKey(entrada))
          entrada,
    ];
  }

  /// Apunta que la foto [ruta] de este móvil tiene, reducida, el [hash] y
  /// que esa copia está en [rutaSubida], pendiente de subir.
  Future<void> registrarFotoPreparada(
      {required String ruta,
      required String hash,
      required String rutaSubida}) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      final existentes = await txn.query('fotos_sync',
          where: 'hash = ?', whereArgs: [hash], limit: 1);
      if (existentes.isEmpty) {
        await txn.insert('fotos_sync', {
          'hash': hash,
          'ruta_local': ruta,
          'ruta_subida': rutaSubida,
          'subida': 0,
        });
      } else if ((existentes.first['ruta_local'] as String).isEmpty) {
        // Ya la conocía por otra entidad (referencia sin bajar): ahora hay
        // fichero. Si el servidor aún no la tiene, se sube esta copia.
        await txn.update(
            'fotos_sync',
            {
              'ruta_local': ruta,
              if ((existentes.first['subida'] as int) == 0)
                'ruta_subida': rutaSubida,
            },
            where: 'hash = ?',
            whereArgs: [hash]);
      }
      await txn.insert('rutas_fotos', {'ruta': ruta, 'hash': hash},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<FotoPorSubir>> listarFotosPorSubir() async {
    final db = await basedatos;
    final filas = await db.query('fotos_sync',
        where: "subida = 0 AND ruta_subida != ''", orderBy: 'intentos ASC');
    return [
      for (final fila in filas)
        FotoPorSubir(
          hash: fila['hash'] as String,
          rutaSubida: fila['ruta_subida'] as String,
          intentos: fila['intentos'] as int,
          ultimoIntentoMs: fila['ultimo_intento_ms'] as int,
        ),
    ];
  }

  /// El servidor ya tiene la foto: deja de estar en la cola de subida.
  Future<void> marcarFotoSubida(String hash) async {
    final db = await basedatos;
    await db.update('fotos_sync',
        {'subida': 1, 'ruta_subida': '', 'intentos': 0, 'ultimo_intento_ms': 0},
        where: 'hash = ?', whereArgs: [hash]);
  }

  /// La copia por subir de [hash] se ha perdido: se olvida para que la
  /// próxima preparación la rehaga desde el original.
  Future<void> olvidarFotoPreparada(String hash) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.delete('fotos_sync',
          where: 'hash = ? AND subida = 0', whereArgs: [hash]);
      await txn.delete('rutas_fotos', where: 'hash = ?', whereArgs: [hash]);
    });
  }

  /// Referencias `foto:<hash>` sin fichero en este móvil.
  Future<List<FotoPorBajar>> listarFotosPorBajar() async {
    final db = await basedatos;
    final conFichero = await _rutaLocalPorHashFoto(db);
    final hashes = <String>{
      for (final entrada in await _entradasFotoGuardadas(db))
        if (hashDeReferencia(entrada) case final hash?)
          if (!conFichero.containsKey(hash)) hash,
    };
    if (hashes.isEmpty) return const [];
    final intentosPorHash = {
      for (final fila in await db.query('fotos_sync',
          columns: ['hash', 'intentos', 'ultimo_intento_ms'],
          where: "ruta_local = ''"))
        fila['hash'] as String: (
          fila['intentos'] as int,
          fila['ultimo_intento_ms'] as int
        ),
    };
    return [
      for (final hash in hashes)
        FotoPorBajar(
          hash: hash,
          intentos: intentosPorHash[hash]?.$1 ?? 0,
          ultimoIntentoMs: intentosPorHash[hash]?.$2 ?? 0,
        ),
    ];
  }

  /// La foto [hash] ya está en el fichero [ruta] de este móvil.
  Future<void> registrarFotoBajada(String hash, String ruta) async {
    final db = await basedatos;
    await db.transaction((txn) async {
      await txn.insert(
          'fotos_sync',
          {
            'hash': hash,
            'ruta_local': ruta,
            'ruta_subida': '',
            'subida': 1,
            'intentos': 0,
            'ultimo_intento_ms': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('rutas_fotos', {'ruta': ruta, 'hash': hash},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Un intento fallido de subir o bajar [hash]: la próxima vez se espera
  /// más (`esperaTrasFallosFoto`).
  Future<void> anotarFalloFoto(String hash, {int? ahoraMs}) async {
    final db = await basedatos;
    final momento = ahoraMs ?? DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final actualizadas = await txn.rawUpdate(
          'UPDATE fotos_sync SET intentos = intentos + 1, '
          'ultimo_intento_ms = ? WHERE hash = ?',
          [momento, hash]);
      if (actualizadas == 0) {
        // Una referencia sin bajar que aún no estaba en la tabla.
        await txn.insert('fotos_sync', {
          'hash': hash,
          'subida': 1,
          'intentos': 1,
          'ultimo_intento_ms': momento,
        });
      }
    });
  }
}
