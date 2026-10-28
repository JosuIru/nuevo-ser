import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../utiles/fotos_sincronizadas.dart';
import 'cliente_sync_zunbeltz.dart';

/// Cuántas fotos se han movido en una vuelta (para registros y tests).
class ResumenFotosSync {
  const ResumenFotosSync(
      {this.preparadas = 0,
      this.subidas = 0,
      this.bajadas = 0,
      this.fallidas = 0,
      this.servidorSinFotos = false});

  final int preparadas;
  final int subidas;
  final int bajadas;
  final int fallidas;

  /// El plugin no tiene los endpoints de fotos: todo queda pendiente.
  final bool servidorSinFotos;
}

/// Lo que la sincronización pide a las fotos: en el móvil
/// [ServicioFotosSync] (ficheros); en el navegador `ServicioFotosWeb`
/// (`servicio_fotos_web.dart`, la BD).
abstract interface class SincronizadorFotos {
  /// Deja listas para subir las fotos nuevas. Devuelve cuántas.
  Future<int> prepararFotosLocales();

  /// Sube lo pendiente y baja lo que falta, hasta agotar [presupuesto].
  Future<ResumenFotosSync> transferir(
      {Duration presupuesto = const Duration(seconds: 90)});
}

/// Mueve las fotos entre este móvil y el WordPress de Zunbeltz (ver
/// `utiles/fotos_sincronizadas.dart`):
///
/// 1. **Preparar** (antes de cada sincronización, sin red): cada foto
///    hecha en este móvil se reduce (1600 px, JPEG 80) a una copia en
///    `<documentos>/fotos_sync/subir/` y se apunta su hash. Así las
///    entidades suben con hashes aunque la foto aún no haya viajado.
/// 2. **Transferir** (después, solo con wifi o cable): se suben las copias
///    pendientes y se bajan las fotos que alguna entidad referencia y este
///    móvil no tiene. Lo que falla se reintenta más tarde, cada vez más
///    espaciado; un plugin sin los endpoints deja todo pendiente sin error.
///
/// Nada de esto puede tumbar la sincronización de datos: quien llama lo
/// envuelve en try/catch.
class ServicioFotosSync implements SincronizadorFotos {
  ServicioFotosSync({
    required this.bd,
    required this.transporte,
    required this.directorioFotos,
    Future<Uint8List?> Function(Uint8List original)? reducir,
    DateTime Function()? reloj,
  })  : reducir = reducir ?? reducirFotoEnSegundoHilo,
        reloj = reloj ?? DateTime.now;

  final BaseDatosSoleraZunbeltz bd;
  final TransporteFotos transporte;

  /// Carpeta donde viven las copias por subir y las fotos bajadas.
  final Directory directorioFotos;
  final Future<Uint8List?> Function(Uint8List original) reducir;
  final DateTime Function() reloj;

  Directory get _carpetaSubida =>
      Directory(path_lib.join(directorioFotos.path, 'subir'));

  /// Prepara (reduce y calcula el hash de) las fotos de este móvil que aún
  /// no lo están. Devuelve cuántas.
  @override
  Future<int> prepararFotosLocales() async {
    var preparadas = 0;
    for (final ruta in await bd.rutasFotoSinPreparar()) {
      final fichero = File(ruta);
      if (!await fichero.exists()) continue;
      final Uint8List? reducida;
      try {
        reducida = await reducir(await fichero.readAsBytes());
      } catch (_) {
        continue;
      }
      if (reducida == null) continue;
      final hash = hashFoto(reducida);
      await _carpetaSubida.create(recursive: true);
      final rutaSubida = path_lib.join(_carpetaSubida.path, '$hash.jpg');
      if (!await File(rutaSubida).exists()) {
        await File(rutaSubida).writeAsBytes(reducida, flush: true);
      }
      await bd.registrarFotoPreparada(
          ruta: ruta, hash: hash, rutaSubida: rutaSubida);
      preparadas++;
    }
    return preparadas;
  }

  @override
  Future<ResumenFotosSync> transferir(
      {Duration presupuesto = const Duration(seconds: 90)}) async {
    final inicio = reloj();
    bool quedaTiempo() => reloj().difference(inicio) < presupuesto;
    var subidas = 0, bajadas = 0, fallidas = 0;

    for (final foto in await bd.listarFotosPorSubir()) {
      if (!quedaTiempo()) break;
      if (!tocaReintentarFoto(foto.intentos, foto.ultimoIntentoMs,
          reloj().millisecondsSinceEpoch)) {
        continue;
      }
      final fichero = File(foto.rutaSubida);
      if (!await fichero.exists()) {
        // Copia perdida (caché borrada): se vuelve a preparar desde el
        // original en la próxima sincronización.
        await bd.olvidarFotoPreparada(foto.hash);
        continue;
      }
      switch (
          await transporte.subirFoto(foto.hash, await fichero.readAsBytes())) {
        case ResultadoSubidaFoto.subida:
          await bd.marcarFotoSubida(foto.hash);
          await _borrarSinFallar(fichero);
          subidas++;
        case ResultadoSubidaFoto.sinEndpoint:
          return ResumenFotosSync(
              subidas: subidas, fallidas: fallidas, servidorSinFotos: true);
        case ResultadoSubidaFoto.fallo:
          await bd.anotarFalloFoto(foto.hash,
              ahoraMs: reloj().millisecondsSinceEpoch);
          fallidas++;
      }
    }

    for (final foto in await bd.listarFotosPorBajar()) {
      if (!quedaTiempo()) break;
      if (!tocaReintentarFoto(foto.intentos, foto.ultimoIntentoMs,
          reloj().millisecondsSinceEpoch)) {
        continue;
      }
      final resultado = await _bajar(foto.hash);
      if (resultado == null) {
        fallidas++;
      } else if (resultado.sinEndpoint) {
        return ResumenFotosSync(
            subidas: subidas,
            bajadas: bajadas,
            fallidas: fallidas,
            servidorSinFotos: true);
      } else {
        bajadas++;
      }
    }
    return ResumenFotosSync(
        subidas: subidas, bajadas: bajadas, fallidas: fallidas);
  }

  /// Baja [hash] ya, con la red que haya (la persona ha pedido verla).
  /// Devuelve la ruta del fichero, o `null` si no se ha podido.
  Future<String?> bajarAhora(String hash) async {
    final yaEsta = await bd.rutaLocalDeFoto(hash);
    if (yaEsta != null && await File(yaEsta).exists()) return yaEsta;
    final resultado = await _bajar(hash);
    return resultado?.ruta;
  }

  /// `null` si falla (y queda anotado); con `sinEndpoint` si el plugin no
  /// tiene fotos.
  Future<({String? ruta, bool sinEndpoint})?> _bajar(String hash) async {
    final respuesta = await transporte.bajarFoto(hash);
    if (respuesta.sinEndpoint) return (ruta: null, sinEndpoint: true);
    final bytes = respuesta.bytes;
    if (bytes == null) {
      await bd.anotarFalloFoto(hash, ahoraMs: reloj().millisecondsSinceEpoch);
      return null;
    }
    await directorioFotos.create(recursive: true);
    final extension = switch (tipoMimeDeImagen(bytes)) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final ruta = path_lib.join(directorioFotos.path, '$hash.$extension');
    await File(ruta).writeAsBytes(bytes, flush: true);
    await bd.registrarFotoBajada(hash, ruta);
    return (ruta: ruta, sinEndpoint: false);
  }

  static Future<void> _borrarSinFallar(File fichero) async {
    try {
      await fichero.delete();
    } catch (_) {}
  }
}

/// Reduce una foto en otro isolate para no congelar la interfaz.
Future<Uint8List?> reducirFotoEnSegundoHilo(Uint8List original) =>
    Isolate.run(() => reducirFotoParaSubir(original));

/// ¿La conexión actual es wifi o cable? Ante cualquier duda, no.
Future<bool> hayRedSinMedir() async {
  try {
    return redPermiteTransferirFotos(await Connectivity().checkConnectivity());
  } catch (_) {
    return false;
  }
}

/// Carpeta de fotos sincronizadas en el móvil.
Future<Directory> directorioFotosSync() async => Directory(path_lib.join(
    (await getApplicationDocumentsDirectory()).path, 'fotos_sync'));

/// El servicio con la sincronización configurada en Ajustes, o `null` en
/// web o sin configurar.
Future<ServicioFotosSync?> servicioFotosConfigurado() async {
  if (kIsWeb) return null;
  final url = await AjustesSincronizacion.cargarUrl();
  final token = await AjustesSincronizacion.cargarToken();
  if (url.isEmpty || token.isEmpty) return null;
  return ServicioFotosSync(
    bd: BaseDatosSoleraZunbeltz(),
    transporte: ClienteSyncZunbeltz(urlBase: url, token: token),
    directorioFotos: await directorioFotosSync(),
  );
}

/// Baja una foto que la persona quiere ver ahora (cualquier red).
Future<String?> bajarFotoAhora(String hash) async {
  try {
    return await (await servicioFotosConfigurado())?.bajarAhora(hash);
  } catch (_) {
    return null;
  }
}
