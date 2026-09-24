import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resultado de intentar instalar una versión nueva.
enum ResultadoInstalacion {
  /// Se abrió el instalador de Android con el APK descargado.
  instaladorAbierto,

  /// Fuera de Android: se abrió el enlace de descarga en el navegador.
  enlaceAbierto,

  /// No se pudo descargar (sin red, enlace roto…).
  errorDescarga,

  /// Se descargó pero Android no dejó abrir el instalador (suele faltar
  /// el permiso «instalar apps desconocidas» para esta app).
  errorInstalador,
}

/// Descarga el APK de [urlAsset] a la caché de la app y abre el
/// instalador de Android. Android pide confirmación siempre: la app no
/// se instala sola. [alProgresar] recibe de 0 a 1 (o -1 si el servidor
/// no dice el tamaño). Fuera de Android abre el enlace.
Future<ResultadoInstalacion> instalarActualizacion(
  String urlAsset, {
  void Function(double progreso)? alProgresar,
  http.Client? clienteHttp,
}) async {
  final url = Uri.tryParse(urlAsset);
  if (url == null) return ResultadoInstalacion.errorDescarga;
  if (kIsWeb || !Platform.isAndroid) {
    final abierto = await launchUrl(url, mode: LaunchMode.externalApplication);
    return abierto ? ResultadoInstalacion.enlaceAbierto : ResultadoInstalacion.errorDescarga;
  }
  final cliente = clienteHttp ?? http.Client();
  final File fichero;
  try {
    final carpeta = Directory('${(await getTemporaryDirectory()).path}/actualizaciones');
    if (carpeta.existsSync()) carpeta.deleteSync(recursive: true);
    carpeta.createSync(recursive: true);
    fichero = File('${carpeta.path}/${url.pathSegments.isEmpty ? 'actualizacion.apk' : url.pathSegments.last}');
    final respuesta = await cliente.send(http.Request('GET', url));
    if (respuesta.statusCode != 200) return ResultadoInstalacion.errorDescarga;
    final total = respuesta.contentLength ?? 0;
    var recibido = 0;
    final salida = fichero.openWrite();
    await for (final trozo in respuesta.stream) {
      salida.add(trozo);
      recibido += trozo.length;
      alProgresar?.call(total > 0 ? recibido / total : -1);
    }
    await salida.close();
  } catch (_) {
    return ResultadoInstalacion.errorDescarga;
  } finally {
    if (clienteHttp == null) cliente.close();
  }
  final resultado = await OpenFilex.open(fichero.path, type: 'application/vnd.android.package-archive');
  return resultado.type == ResultType.done
      ? ResultadoInstalacion.instaladorAbierto
      : ResultadoInstalacion.errorInstalador;
}
