import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../estado/ajustes_sincronizacion.dart';

/// Textos de la ayuda que coordinación ha cambiado en el panel de WordPress
/// (`GET /solera-zunbeltz/v1/ayuda`, público): solo las claves que difieren
/// de las de serie, por idioma. Se guardan en `shared_preferences`; sin
/// servidor, o hasta que conteste, la app enseña los suyos.
class ServicioTextosAyuda {
  ServicioTextosAyuda({http.Client? cliente})
      : _cliente = cliente ?? _clienteCompartido;

  static final http.Client _clienteCompartido = http.Client();

  static const _claveCache = 'zunbeltz.textos_ayuda';
  static const _claveCacheMomento = 'zunbeltz.textos_ayuda_ms';

  /// Cambian poco: no se pregunta más de una vez cada este tiempo salvo
  /// que se pida a mano.
  static const margenEntreDescargas = Duration(hours: 6);

  final http.Client _cliente;

  /// idioma → clave → texto, solo lo cambiado en el panel.
  static final ValueNotifier<Map<String, Map<String, String>>> actuales =
      ValueNotifier(const {});

  /// Al cambiar de servidor, los textos del anterior ya no valen.
  static Future<void> olvidarGuardados() async {
    actuales.value = const {};
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.remove(_claveCache);
      await preferencias.remove(_claveCacheMomento);
    } catch (_) {}
  }

  /// Carga lo guardado (si lo hay) y, si toca, lo del servidor.
  Future<Map<String, Map<String, String>>> actualizar(
      {bool forzar = false}) async {
    var momentoGuardadoMs = 0;
    try {
      final preferencias = await SharedPreferences.getInstance();
      final guardado = preferencias.getString(_claveCache);
      if (guardado != null) {
        actuales.value = textosDesdeRespuesta(jsonDecode(guardado));
        momentoGuardadoMs = preferencias.getInt(_claveCacheMomento) ?? 0;
      }
    } catch (_) {}

    final ahoraMs = DateTime.now().millisecondsSinceEpoch;
    if (!forzar &&
        ahoraMs - momentoGuardadoMs < margenEntreDescargas.inMilliseconds) {
      return actuales.value;
    }
    final url = await AjustesSincronizacion.cargarUrl();
    if (url.trim().isEmpty) return actuales.value;
    try {
      final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final respuesta = await _cliente
          .get(Uri.parse('$base/wp-json/solera-zunbeltz/v1/ayuda'))
          .timeout(const Duration(seconds: 20));
      // 404: WordPress con un plugin anterior a la 0.9.3.
      if (respuesta.statusCode != 200) return actuales.value;
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (datos is! Map || datos['textos'] is! Map) return actuales.value;
      final textos = textosDesdeRespuesta(datos);
      actuales.value = textos;
      try {
        final preferencias = await SharedPreferences.getInstance();
        await preferencias.setString(
            _claveCache, jsonEncode({'textos': textos}));
        await preferencias.setInt(_claveCacheMomento, ahoraMs);
      } catch (_) {}
      return textos;
    } catch (_) {
      return actuales.value;
    }
  }

  /// `{"textos": {"es": {clave: texto}, "eu": {…}}}` → mapa limpio: solo
  /// idiomas y textos que son cadenas no vacías.
  static Map<String, Map<String, String>> textosDesdeRespuesta(Object? datos) {
    if (datos is! Map) return const {};
    final porIdioma = datos['textos'];
    if (porIdioma is! Map) return const {};
    final limpio = <String, Map<String, String>>{};
    porIdioma.forEach((idioma, textos) {
      if (idioma is! String || textos is! Map) return;
      final del = <String, String>{};
      textos.forEach((clave, texto) {
        if (clave is String && texto is String && texto.trim().isNotEmpty) {
          del[clave] = texto;
        }
      });
      if (del.isNotEmpty) limpio[idioma] = del;
    });
    return limpio;
  }
}

/// El texto de una clave de ayuda: el del panel si coordinación lo cambió
/// para ese idioma, si no el de serie.
String textoAyuda(Map<String, Map<String, String>> cambiados, String idioma,
        Map<String, String> deSerie, String clave) =>
    cambiados[idioma]?[clave] ?? deSerie[clave] ?? '';
