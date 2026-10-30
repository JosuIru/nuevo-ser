// Subido al core el 2026-10-22: era idéntico en solera-apicola,
// solera-viticultura, fósiles y naturaleza.
import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

class AutoBackup {
  final String nombreApp;
  final Future<String> Function() obtenerRutaDb;
  final Future<bool> Function() estaVacia;
  final Future<void> Function() reiniciarBd;

  AutoBackup({
    required this.nombreApp,
    required this.obtenerRutaDb,
    required this.estaVacia,
    required this.reiniciarBd,
  });

  Future<Directory> _directorioBackup() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(path_lib.join(docs.path, 'backup_auto'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copias diarias con fecha que se conservan además de la última.
  static const diasConCopiaFechada = 5;

  Future<void> respaldarAhora({DateTime? ahora}) async {
    try {
      // Una BD vacía nunca pisa una copia: si la app arrancó sin datos
      // (reinstalación, fallo al abrir), la copia buena es lo único que queda.
      if (await estaVacia() && await existeRespaldo()) return;
      final rutaDb = await obtenerRutaDb();
      final dirBackup = await _directorioBackup();
      final ficheroDb = File(rutaDb);
      if (await ficheroDb.exists()) {
        await ficheroDb.copy(path_lib.join(dirBackup.path, '${nombreApp}_auto.db'));
        await _guardarCopiaFechada(ficheroDb, dirBackup, ahora ?? DateTime.now());
      }
      final docs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(path_lib.join(docs.path, 'fotos'));
      if (await dirFotos.exists()) {
        final dirFotosBackup = Directory(path_lib.join(dirBackup.path, 'fotos'));
        if (await dirFotosBackup.exists()) await dirFotosBackup.delete(recursive: true);
        await _copiarDirectorio(dirFotos, dirFotosBackup);
      }
    } catch (_) {}
  }

  /// Una copia por día (`<app>_auto_AAAA-MM-DD.db`); se borran las más
  /// antiguas para quedarse con [diasConCopiaFechada].
  Future<void> _guardarCopiaFechada(File ficheroDb, Directory dirBackup, DateTime ahora) async {
    final dia = '${ahora.year.toString().padLeft(4, '0')}-'
        '${ahora.month.toString().padLeft(2, '0')}-'
        '${ahora.day.toString().padLeft(2, '0')}';
    await ficheroDb.copy(path_lib.join(dirBackup.path, '${nombreApp}_auto_$dia.db'));
    final copiasFechadas = <File>[];
    final patronCopiaFechada = RegExp('^${RegExp.escape(nombreApp)}_auto_\\d{4}-\\d{2}-\\d{2}\\.db\$');
    await for (final entidad in dirBackup.list()) {
      if (entidad is File && patronCopiaFechada.hasMatch(path_lib.basename(entidad.path))) {
        copiasFechadas.add(entidad);
      }
    }
    copiasFechadas.sort((a, b) => b.path.compareTo(a.path));
    for (final copiaSobrante in copiasFechadas.skip(diasConCopiaFechada)) {
      try { await copiaSobrante.delete(); } catch (_) {}
    }
  }

  Future<bool> existeRespaldo() async {
    final dirBackup = await _directorioBackup();
    return await File(path_lib.join(dirBackup.path, '${nombreApp}_auto.db')).exists();
  }

  Future<bool> restaurarSiProcede() async {
    try {
      if (!await estaVacia()) return false;
      if (!await existeRespaldo()) return false;
      final rutaDb = await obtenerRutaDb();
      await reiniciarBd();
      final dirBackup = await _directorioBackup();
      await File(path_lib.join(dirBackup.path, '${nombreApp}_auto.db')).copy(rutaDb);
      final docs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(path_lib.join(docs.path, 'fotos'));
      if (await dirFotos.exists()) await dirFotos.delete(recursive: true);
      final dirFotosBackup = Directory(path_lib.join(dirBackup.path, 'fotos'));
      if (await dirFotosBackup.exists()) {
        await _copiarDirectorio(dirFotosBackup, dirFotos);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> exportarADownloads() async {
    try {
      final dirDescargas = Directory('/storage/emulated/0/Download');
      if (!await dirDescargas.exists()) return null;
      final dirBase = Directory(path_lib.join(dirDescargas.path, '${nombreApp}_backups'));
      if (!await dirBase.exists()) await dirBase.create(recursive: true);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final dirSesion = Directory(path_lib.join(dirBase.path, 'backup_$ts'));
      await dirSesion.create(recursive: true);
      final rutaDb = await obtenerRutaDb();
      await File(rutaDb).copy(path_lib.join(dirSesion.path, '${nombreApp}.db'));
      final docs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(path_lib.join(docs.path, 'fotos'));
      if (await dirFotos.exists()) {
        await _copiarDirectorio(dirFotos, Directory(path_lib.join(dirSesion.path, 'fotos')));
      }
      // Mantener solo 3 backups
      final dirs = <Directory>[];
      await for (final e in dirBase.list()) {
        if (e is Directory) dirs.add(e);
      }
      dirs.sort((a, b) => b.path.compareTo(a.path));
      for (var i = 3; i < dirs.length; i++) {
        try { await dirs[i].delete(recursive: true); } catch (_) {}
      }
      return dirSesion.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _copiarDirectorio(Directory origen, Directory destino) async {
    if (!await destino.exists()) await destino.create(recursive: true);
    await for (final entidad in origen.list()) {
      if (entidad is File) {
        await entidad.copy(path_lib.join(destino.path, path_lib.basename(entidad.path)));
      } else if (entidad is Directory) {
        await _copiarDirectorio(
          entidad, Directory(path_lib.join(destino.path, path_lib.basename(entidad.path))));
      }
    }
  }
}
