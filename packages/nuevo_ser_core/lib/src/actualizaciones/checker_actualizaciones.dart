import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuración por app del checker. Cada app del monorepo
/// (naturaleza, fósiles, las-versiones…) instancia la suya con su
/// prefijo de tag en GitHub releases.
@immutable
class ConfigActualizaciones {
  /// Owner del repo en GitHub. Ej: `JosuIru`.
  final String repoOwner;

  /// Nombre del repo en GitHub. Ej: `cuadernos-de-campo`.
  final String repoName;

  /// Prefijo de los tags de release de ESTA app. Permite varias apps
  /// en un mismo repo: `naturaleza-v` filtra `naturaleza-v1.0.3` pero
  /// ignora `fosiles-v1.0.13`. Si en un repo sólo vive una app, dejar
  /// `v` o cadena vacía (en cuyo caso se acepta cualquier tag).
  final String prefijoTag;

  /// Patrón (subcadena) que debe contener el nombre del asset `.apk`
  /// para considerarlo descargable por esta app. Defensa contra
  /// releases que adjuntan varios APK (uno por app). Ejemplo:
  /// `naturaleza-` filtra `naturaleza-1.0.3+4.apk` pero no
  /// `fosiles-1.0.13+14.apk`.
  final String sufijoAsset;

  /// Clave única que identifica esta config para cachear el último
  /// resultado por separado. Por defecto se deriva de los otros campos.
  String get claveCache =>
      'nuevo_ser_core.actualizaciones.$repoOwner-$repoName-$prefijoTag';

  const ConfigActualizaciones({
    required this.repoOwner,
    required this.repoName,
    this.prefijoTag = '',
    this.sufijoAsset = '.apk',
  });
}

/// Resultado del checker cuando hay una versión nueva.
@immutable
class ActualizacionDisponible {
  final String versionInstalada;
  final String versionDisponible;
  final String tagRelease;
  final String urlAsset;
  final String notas;

  /// Milisegundos epoch en los que se publicó el release en GitHub.
  /// Útil para mostrar "publicada hace N días" en el banner.
  final int publicadoMs;

  const ActualizacionDisponible({
    required this.versionInstalada,
    required this.versionDisponible,
    required this.tagRelease,
    required this.urlAsset,
    required this.notas,
    required this.publicadoMs,
  });

  Map<String, dynamic> toJson() => {
        'version_instalada': versionInstalada,
        'version_disponible': versionDisponible,
        'tag_release': tagRelease,
        'url_asset': urlAsset,
        'notas': notas,
        'publicado_ms': publicadoMs,
      };

  factory ActualizacionDisponible.fromJson(Map<String, dynamic> json) =>
      ActualizacionDisponible(
        versionInstalada: json['version_instalada'] as String? ?? '',
        versionDisponible: json['version_disponible'] as String? ?? '',
        tagRelease: json['tag_release'] as String? ?? '',
        urlAsset: json['url_asset'] as String? ?? '',
        notas: json['notas'] as String? ?? '',
        publicadoMs: json['publicado_ms'] as int? ?? 0,
      );
}

/// Tiempo entre dos comprobaciones contra GitHub. 24h evita gastar la
/// cuota anónima (60 req/h por IP) y respeta al usuario en datos.
const Duration _ttlCache = Duration(hours: 24);

const String _claveTimestampPrefijo =
    'nuevo_ser_core.actualizaciones.ts.';
const String _claveResultadoPrefijo =
    'nuevo_ser_core.actualizaciones.last.';

/// Comprueba si hay una versión nueva disponible.
///
/// - Cachea el resultado 24h en `SharedPreferences` (clave dependiente
///   de la config para que cada app tenga el suyo).
/// - Si la última comprobación es reciente, devuelve el resultado
///   cacheado sin tocar la red. `forzarRefresco: true` salta el caché.
/// - En caso de error de red, falla silencioso (devuelve null o el
///   último cacheado válido). El checker es best-effort.
///
/// Devuelve `null` si no hay actualización o si no se pudo determinar.
Future<ActualizacionDisponible?> comprobarActualizacionDisponible(
  ConfigActualizaciones config, {
  bool forzarRefresco = false,
  http.Client? clienteHttp,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final claveTs = _claveTimestampPrefijo + config.claveCache;
  final claveRes = _claveResultadoPrefijo + config.claveCache;
  final ahora = DateTime.now().millisecondsSinceEpoch;
  final ultimoCheckMs = prefs.getInt(claveTs) ?? 0;

  // Cache hit: devuelve la última respuesta (sea positiva o negativa).
  if (!forzarRefresco &&
      ahora - ultimoCheckMs < _ttlCache.inMilliseconds) {
    return _leerCache(prefs, claveRes);
  }

  final cliente = clienteHttp ?? http.Client();
  try {
    final url = Uri.parse(
        'https://api.github.com/repos/${config.repoOwner}/${config.repoName}/releases?per_page=100');
    final respuesta = await cliente
        .get(url, headers: const {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 10));
    if (respuesta.statusCode != 200) {
      // Marca el timestamp para no martillear si la API está caída,
      // pero conserva el último resultado positivo si lo había.
      await prefs.setInt(claveTs, ahora);
      return _leerCache(prefs, claveRes);
    }
    final lista = jsonDecode(respuesta.body) as List<dynamic>;
    final releaseValido = _elegirReleaseAplicable(lista, config);
    final paquete = await PackageInfo.fromPlatform();
    final versionInstalada = _formatearVersionInstalada(paquete);

    if (releaseValido == null) {
      await prefs.setInt(claveTs, ahora);
      await prefs.remove(claveRes);
      return null;
    }

    final tag = releaseValido['tag_name'] as String? ?? '';
    final versionDisponible = _extraerVersionDeTag(tag, config.prefijoTag);
    if (versionDisponible.isEmpty) {
      await prefs.setInt(claveTs, ahora);
      await prefs.remove(claveRes);
      return null;
    }

    if (compararVersiones(versionInstalada, versionDisponible) >= 0) {
      // Lo instalado es igual o más nuevo que lo publicado.
      await prefs.setInt(claveTs, ahora);
      await prefs.remove(claveRes);
      return null;
    }

    final assets = releaseValido['assets'] as List<dynamic>? ?? const [];
    final assetApk = _elegirAsset(assets, config.sufijoAsset);
    if (assetApk == null) {
      await prefs.setInt(claveTs, ahora);
      await prefs.remove(claveRes);
      return null;
    }

    final resultado = ActualizacionDisponible(
      versionInstalada: versionInstalada,
      versionDisponible: versionDisponible,
      tagRelease: tag,
      urlAsset: assetApk['browser_download_url'] as String? ?? '',
      notas: (releaseValido['body'] as String? ?? '').trim(),
      publicadoMs:
          DateTime.tryParse(releaseValido['published_at'] as String? ?? '')
                  ?.millisecondsSinceEpoch ??
              ahora,
    );

    await prefs.setInt(claveTs, ahora);
    await prefs.setString(claveRes, jsonEncode(resultado.toJson()));
    return resultado;
  } catch (_) {
    // Fallo de red / timeout / JSON inválido: no marcamos timestamp
    // (queremos reintentar en el próximo arranque), pero devolvemos
    // lo último que tuviéramos cacheado por si quedó positivo.
    return _leerCache(prefs, claveRes);
  } finally {
    if (clienteHttp == null) cliente.close();
  }
}

/// Estado completo para la pantalla de actualizaciones: lo instalado,
/// lo último publicado (aunque sea lo mismo) y si se pudo consultar.
@immutable
class EstadoActualizaciones {
  final String versionInstalada;

  /// Null si no hay ninguna release de esta app o no se pudo consultar.
  final String? versionPublicada;
  final String? urlAsset;
  final String notas;
  final int? publicadoMs;
  final int comprobadoMs;

  /// No se pudo hablar con GitHub (sin red, límite de la API…).
  final bool sinConexion;

  const EstadoActualizaciones({
    required this.versionInstalada,
    required this.comprobadoMs,
    this.versionPublicada,
    this.urlAsset,
    this.notas = '',
    this.publicadoMs,
    this.sinConexion = false,
  });

  bool get hayNueva =>
      versionPublicada != null &&
      urlAsset != null &&
      urlAsset!.isNotEmpty &&
      compararVersiones(versionInstalada, versionPublicada!) < 0;

  ActualizacionDisponible? get comoDisponible => hayNueva
      ? ActualizacionDisponible(
          versionInstalada: versionInstalada,
          versionDisponible: versionPublicada!,
          tagRelease: '',
          urlAsset: urlAsset!,
          notas: notas,
          publicadoMs: publicadoMs ?? comprobadoMs,
        )
      : null;
}

/// Consulta GitHub ahora mismo (sin caché) y devuelve el estado completo.
/// Nunca lanza: sin red devuelve `sinConexion: true`.
Future<EstadoActualizaciones> consultarEstadoActualizaciones(
  ConfigActualizaciones config, {
  http.Client? clienteHttp,
  Future<String> Function()? obtenerVersionInstalada,
}) async {
  final ahora = DateTime.now().millisecondsSinceEpoch;
  final versionInstalada = obtenerVersionInstalada != null
      ? await obtenerVersionInstalada()
      : _formatearVersionInstalada(await PackageInfo.fromPlatform());
  final cliente = clienteHttp ?? http.Client();
  try {
    final url = Uri.parse(
        'https://api.github.com/repos/${config.repoOwner}/${config.repoName}/releases?per_page=100');
    final respuesta = await cliente
        .get(url, headers: const {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 10));
    if (respuesta.statusCode != 200) {
      return EstadoActualizaciones(versionInstalada: versionInstalada, comprobadoMs: ahora, sinConexion: true);
    }
    final release = _elegirReleaseAplicable(jsonDecode(respuesta.body) as List<dynamic>, config);
    if (release == null) {
      return EstadoActualizaciones(versionInstalada: versionInstalada, comprobadoMs: ahora);
    }
    final version = _extraerVersionDeTag(release['tag_name'] as String? ?? '', config.prefijoTag);
    final asset = _elegirAsset(release['assets'] as List<dynamic>? ?? const [], config.sufijoAsset);
    return EstadoActualizaciones(
      versionInstalada: versionInstalada,
      comprobadoMs: ahora,
      versionPublicada: version.isEmpty ? null : version,
      urlAsset: asset?['browser_download_url'] as String?,
      notas: (release['body'] as String? ?? '').trim(),
      publicadoMs: DateTime.tryParse(release['published_at'] as String? ?? '')?.millisecondsSinceEpoch,
    );
  } catch (_) {
    return EstadoActualizaciones(versionInstalada: versionInstalada, comprobadoMs: ahora, sinConexion: true);
  } finally {
    if (clienteHttp == null) cliente.close();
  }
}

/// Config de una app del monorepo: releases en `JosuIru/nuevo-ser` con
/// tag `<app>-<versión>` y un APK `<app>-<versión>.apk`.
ConfigActualizaciones configActualizacionesMonorepo(String idApp) => ConfigActualizaciones(
      repoOwner: 'JosuIru',
      repoName: 'nuevo-ser',
      prefijoTag: '$idApp-',
      sufijoAsset: '$idApp-',
    );

/// Limpia la caché para esta config — útil al instalar manualmente
/// la nueva versión y querer que el banner desaparezca sin esperar al
/// siguiente ciclo.
Future<void> limpiarCacheActualizaciones(ConfigActualizaciones config) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_claveTimestampPrefijo + config.claveCache);
  await prefs.remove(_claveResultadoPrefijo + config.claveCache);
}

ActualizacionDisponible? _leerCache(
    SharedPreferences prefs, String clave) {
  final json = prefs.getString(clave);
  if (json == null || json.isEmpty) return null;
  try {
    return ActualizacionDisponible.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _elegirReleaseAplicable(
    List<dynamic> lista, ConfigActualizaciones config) {
  for (final item in lista) {
    if (item is! Map<String, dynamic>) continue;
    if (item['draft'] == true) continue;
    if (item['prerelease'] == true) continue;
    final tag = item['tag_name'] as String? ?? '';
    if (config.prefijoTag.isNotEmpty &&
        !tag.startsWith(config.prefijoTag)) continue;
    return item;
  }
  return null;
}

Map<String, dynamic>? _elegirAsset(
    List<dynamic> assets, String sufijoAsset) {
  for (final asset in assets) {
    if (asset is! Map<String, dynamic>) continue;
    final nombre = asset['name'] as String? ?? '';
    if (nombre.contains(sufijoAsset)) return asset;
  }
  return null;
}

String _extraerVersionDeTag(String tag, String prefijoTag) {
  var version = tag;
  if (prefijoTag.isNotEmpty && version.startsWith(prefijoTag)) {
    version = version.substring(prefijoTag.length);
  }
  // Algunos releases usan `v1.0.3`, otros `1.0.3`. Quitamos la v
  // inicial si la hay.
  if (version.startsWith('v') || version.startsWith('V')) {
    version = version.substring(1);
  }
  return version.trim();
}

String _formatearVersionInstalada(PackageInfo info) {
  if (info.buildNumber.isEmpty) return info.version;
  return '${info.version}+${info.buildNumber}';
}

/// Compara dos versiones tipo `1.0.3+4` siguiendo la convención
/// Flutter (`major.minor.patch+build`). Devuelve:
///   - negativo si `a < b`,
///   - cero si son iguales,
///   - positivo si `a > b`.
///
/// El número de build (`+N`) desempata cuando major.minor.patch son
/// iguales: `1.0.3+5` > `1.0.3+4`. Sin la comparación numérica
/// componente a componente, `1.0.13` quedaría como menor que `1.0.2`
/// (orden lexicográfico) y el checker no detectaría el update.
int compararVersiones(String a, String b) {
  final partesA = _trocearVersion(a);
  final partesB = _trocearVersion(b);
  final longitudMax =
      partesA.length > partesB.length ? partesA.length : partesB.length;
  for (var i = 0; i < longitudMax; i++) {
    final piezaA = i < partesA.length ? partesA[i] : 0;
    final piezaB = i < partesB.length ? partesB[i] : 0;
    if (piezaA != piezaB) return piezaA - piezaB;
  }
  return 0;
}

List<int> _trocearVersion(String version) {
  // Separa primero por `+` (build); luego cada parte por `.`. Si una
  // pieza no es numérica (por ej. `1.0.3-rc1`), la pasamos a 0 — el
  // checker no soporta pre-release tags formalmente; los release del
  // monorepo siempre van con build numérico.
  final piezas = <int>[];
  final partes = version.split('+');
  for (final componenteMayor in partes[0].split('.')) {
    piezas.add(int.tryParse(componenteMayor) ?? 0);
  }
  if (partes.length > 1) {
    piezas.add(int.tryParse(partes[1]) ?? 0);
  }
  return piezas;
}
