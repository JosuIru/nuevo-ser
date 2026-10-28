import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show FuenteFoto;

import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../utiles/fotos_sincronizadas.dart';
import 'cliente_sync_zunbeltz.dart';
import 'servicio_fotos_sync.dart';

/// Fotos en la versión web (navegador, iPhone). No hay ficheros: cada foto,
/// ya reducida, se guarda en la BD (tabla `fotos_web`, que vive en
/// IndexedDB) con su hash, y las entidades la llevan como referencia
/// `foto:<hash>` desde el primer momento. Sube y baja por los mismos
/// `/fotos/<hash>` que el móvil (ver `servicio_fotos_sync.dart`).
class ServicioFotosWeb implements SincronizadorFotos {
  ServicioFotosWeb({
    required this.bd,
    required this.transporte,
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;

  final BaseDatosSoleraZunbeltz bd;
  final TransporteFotos transporte;
  final DateTime Function() reloj;

  /// Nada que preparar: se reducen y se guardan al elegirlas
  /// ([guardarFotoElegida]).
  @override
  Future<int> prepararFotosLocales() async => 0;

  @override
  Future<ResumenFotosSync> transferir(
      {Duration presupuesto = const Duration(seconds: 90)}) async {
    final inicio = reloj();
    bool quedaTiempo() => reloj().difference(inicio) < presupuesto;
    bool toca(int intentos, int ultimoIntentoMs) => tocaReintentarFoto(
        intentos, ultimoIntentoMs, reloj().millisecondsSinceEpoch);
    var subidas = 0, bajadas = 0, fallidas = 0;

    for (final foto in await bd.listarFotosWebPorSubir()) {
      if (!quedaTiempo()) break;
      if (!toca(foto.intentos, foto.ultimoIntentoMs)) continue;
      final bytes = await bd.bytesFotoWeb(foto.hash);
      if (bytes == null) continue;
      switch (await transporte.subirFoto(foto.hash, bytes)) {
        case ResultadoSubidaFoto.subida:
          await bd.marcarFotoWebSubida(foto.hash);
          subidas++;
        case ResultadoSubidaFoto.sinEndpoint:
          return ResumenFotosSync(
              subidas: subidas, fallidas: fallidas, servidorSinFotos: true);
        case ResultadoSubidaFoto.fallo:
          await bd.anotarFalloSubidaFotoWeb(foto.hash,
              ahoraMs: reloj().millisecondsSinceEpoch);
          fallidas++;
      }
    }

    for (final foto in await bd.listarFotosPorBajar()) {
      if (!quedaTiempo()) break;
      if (!toca(foto.intentos, foto.ultimoIntentoMs)) continue;
      final resultado = await transporte.bajarFoto(foto.hash);
      if (resultado.sinEndpoint) {
        return ResumenFotosSync(
            subidas: subidas,
            bajadas: bajadas,
            fallidas: fallidas,
            servidorSinFotos: true);
      }
      final bytes = resultado.bytes;
      if (bytes == null) {
        await bd.anotarFalloFoto(foto.hash,
            ahoraMs: reloj().millisecondsSinceEpoch);
        fallidas++;
        continue;
      }
      await bd.guardarFotoWeb(foto.hash, bytes, subida: true);
      bajadas++;
    }
    return ResumenFotosSync(
        subidas: subidas, bajadas: bajadas, fallidas: fallidas);
  }

  /// Baja [hash] ya (la persona ha pedido verla). Los bytes, o `null`.
  Future<Uint8List?> bajarAhora(String hash) async {
    final guardada = await bd.bytesFotoWeb(hash);
    if (guardada != null) return guardada;
    final resultado = await transporte.bajarFoto(hash);
    final bytes = resultado.bytes;
    if (bytes == null) {
      if (!resultado.sinEndpoint) {
        await bd.anotarFalloFoto(hash, ahoraMs: reloj().millisecondsSinceEpoch);
      }
      return null;
    }
    await bd.guardarFotoWeb(hash, bytes, subida: true);
    return Uint8List.fromList(bytes);
  }
}

/// Guarda una foto recién elegida en el navegador y devuelve su referencia
/// `foto:<hash>`, o `null` si no se puede leer. Si el navegador no la ha
/// dejado lista (ver [fotoWebListaParaSubir]) se reduce aquí, en el hilo
/// de la página: es lento, pero raro.
Future<String?> guardarFotoElegida(
    BaseDatosSoleraZunbeltz bd, Uint8List original) async {
  final bytes = fotoWebListaParaSubir(original)
      ? original
      : reducirFotoParaSubir(original);
  if (bytes == null) return null;
  final hash = hashFoto(bytes);
  await bd.guardarFotoWeb(hash, bytes);
  return referenciaFoto(hash);
}

/// Cámara o galería del navegador. Pide al navegador que las reduzca
/// (canvas: 1600 px, JPEG 80, sin EXIF) y las guarda en la BD. Devuelve las
/// referencias de las que se han podido guardar.
Future<List<String>> tomarFotosWeb(FuenteFoto fuente) async {
  final selector = ImagePicker();
  const lado = ladoMayorFotoSubida * 1.0;
  final elegidas = fuente == FuenteFoto.camara
      ? [
          if (await selector.pickImage(
                  source: ImageSource.camera,
                  maxWidth: lado,
                  maxHeight: lado,
                  imageQuality: calidadJpegFotoSubida)
              case final foto?)
            foto,
        ]
      : await selector.pickMultiImage(
          maxWidth: lado, maxHeight: lado, imageQuality: calidadJpegFotoSubida);
  final bd = BaseDatosSoleraZunbeltz();
  final referencias = <String>[];
  for (final foto in elegidas) {
    final referencia = await guardarFotoElegida(bd, await foto.readAsBytes());
    if (referencia != null) referencias.add(referencia);
  }
  return referencias;
}

/// Bytes de una foto para verla en el navegador: la guardada o, si no
/// está, `null` (ver [bajarFotoWebAhora]).
Future<Uint8List?> bytesFotoWebGuardada(String hash) async {
  try {
    return await BaseDatosSoleraZunbeltz().bytesFotoWeb(hash);
  } catch (_) {
    return null;
  }
}

/// Baja ya una foto que la persona quiere ver, si hay sincronización
/// configurada.
Future<Uint8List?> bajarFotoWebAhora(String hash) async {
  try {
    final url = await AjustesSincronizacion.cargarUrl();
    final token = await AjustesSincronizacion.cargarToken();
    if (url.isEmpty || token.isEmpty) return null;
    return await ServicioFotosWeb(
      bd: BaseDatosSoleraZunbeltz(),
      transporte: ClienteSyncZunbeltz(urlBase: url, token: token),
    ).bajarAhora(hash);
  } catch (_) {
    return null;
  }
}
