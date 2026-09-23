import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../dominio/version_app.dart';

/// Información del último release publicado, si es **estrictamente
/// más reciente** que la versión instalada. `null` significa
/// "estás al día" o "no se pudo comprobar" — el call-site no
/// distingue: si no hay actualización para ofrecer, no se muestra
/// banner.
class NuevaVersionDisponible {
  const NuevaVersionDisponible({
    required this.versionRemota,
    required this.urlPaginaRelease,
    required this.urlApkDirecto,
  });

  final VersionApp versionRemota;

  /// URL de la página HTML del release en GitHub. Más amable para el
  /// usuario que el link directo al .apk porque muestra las notas de
  /// versión antes de descargar.
  final String urlPaginaRelease;

  /// URL directa al .apk para descarga inmediata. La usa el botón
  /// "DESCARGAR" del banner.
  final String urlApkDirecto;
}

/// Comprueba si hay una versión más reciente publicada en GitHub
/// Releases. Tolerante a fallos: red caída / timeout / JSON inesperado
/// / asset no encontrado → devuelve `null` sin lanzar. El banner del
/// mapa solo se monta si esto devuelve algo no-null.
///
/// `httpGet` y `obtenerVersionInstalada` se inyectan para tests
/// puros sin red y sin `PackageInfo` real. Los defaults usan
/// `http.get` y `PackageInfo.fromPlatform()`.
class BuscadorActualizacion {
  BuscadorActualizacion({
    Future<http.Response> Function(Uri)? httpGet,
    Future<VersionApp> Function()? obtenerVersionInstalada,
    this.urlApiReleaseLatest = _urlApiReleaseLatestPorDefecto,
    this.timeout = const Duration(seconds: 8),
  })  : _httpGet = httpGet ?? http.get,
        _obtenerVersionInstalada =
            obtenerVersionInstalada ?? _versionInstaladaPorDefecto;

  static const String _urlApiReleaseLatestPorDefecto =
      'https://api.github.com/repos/JosuIru/nuevo-ser/releases/latest';

  final String urlApiReleaseLatest;
  final Duration timeout;
  final Future<http.Response> Function(Uri) _httpGet;
  final Future<VersionApp> Function() _obtenerVersionInstalada;

  Future<NuevaVersionDisponible?> comprobar() async {
    try {
      final instalada = await _obtenerVersionInstalada();
      final respuesta = await _httpGet(Uri.parse(urlApiReleaseLatest))
          .timeout(timeout);
      if (respuesta.statusCode != 200) return null;
      final decodificado = jsonDecode(respuesta.body);
      if (decodificado is! Map<String, dynamic>) return null;
      final tag = decodificado['tag_name'];
      final urlPagina = decodificado['html_url'];
      final assets = decodificado['assets'];
      if (tag is! String || urlPagina is! String || assets is! List) {
        return null;
      }
      final versionRemota = VersionApp.parse(tag);
      if (versionRemota == null) return null;
      if (versionRemota <= instalada) return null;
      // Busca el primer asset .apk — el operador puede subir varios
      // assets (notas en PDF, source.zip generado por GitHub…) pero
      // solo el APK nos sirve aquí.
      final apkUrl = _primeraUrlApk(assets);
      if (apkUrl == null) return null;
      return NuevaVersionDisponible(
        versionRemota: versionRemota,
        urlPaginaRelease: urlPagina,
        urlApkDirecto: apkUrl,
      );
    } catch (e, traza) {
      debugPrint('BuscadorActualizacion fallo silencioso: $e');
      debugPrint(traza.toString());
      return null;
    }
  }

  String? _primeraUrlApk(List<dynamic> assets) {
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final nombre = asset['name'];
      final url = asset['browser_download_url'];
      if (nombre is String && url is String && nombre.endsWith('.apk')) {
        return url;
      }
    }
    return null;
  }
}

Future<VersionApp> _versionInstaladaPorDefecto() async {
  final info = await PackageInfo.fromPlatform();
  return VersionApp.deStrings(
    version: info.version,
    buildNumber: info.buildNumber,
  );
}
