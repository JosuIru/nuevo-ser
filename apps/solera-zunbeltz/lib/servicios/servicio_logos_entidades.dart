import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../estado/ajustes_sincronizacion.dart';
import '../estado/version_demo.dart';
import '../logos_entidades.dart';
import '../modelos/entidad_colaboradora.dart';
import 'servicio_noticias_sector.dart';

/// Entidades y logos que coordinación mantiene en el panel de WordPress
/// (`GET /solera-zunbeltz/v1/entidades`, público). La última lista se
/// guarda en `shared_preferences`; sin servidor, o hasta que conteste, vale
/// la lista de partida que va dentro de la app ([entidadesDePartida]).
class ServicioLogosEntidades {
  ServicioLogosEntidades({http.Client? cliente})
      : _cliente = cliente ?? _clienteCompartido;

  static final http.Client _clienteCompartido = http.Client();

  static const _claveCache = 'zunbeltz.logos_entidades';
  static const _claveCacheMomento = 'zunbeltz.logos_entidades_ms';

  /// Cambian poco: no se pregunta más de una vez cada este tiempo salvo
  /// que se pida a mano.
  static const margenEntreDescargas = Duration(hours: 6);

  final http.Client _cliente;

  static final ValueNotifier<List<EntidadColaboradora>> actuales =
      ValueNotifier(entidadesDePartida);

  /// Al cambiar de servidor, la lista del anterior ya no vale.
  static Future<void> olvidarGuardadas() async {
    actuales.value = entidadesDePartida;
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.remove(_claveCache);
      await preferencias.remove(_claveCacheMomento);
    } catch (_) {}
  }

  /// Carga la guardada (si la hay) y, si toca, la del servidor.
  Future<List<EntidadColaboradora>> actualizar({bool forzar = false}) async {
    var momentoGuardadoMs = 0;
    try {
      final preferencias = await SharedPreferences.getInstance();
      final guardado = preferencias.getString(_claveCache);
      if (guardado != null) {
        actuales.value =
            entidadesDesdeRespuesta(jsonDecode(guardado) as Map<String, dynamic>);
        momentoGuardadoMs = preferencias.getInt(_claveCacheMomento) ?? 0;
      }
    } catch (_) {}

    final ahoraMs = DateTime.now().millisecondsSinceEpoch;
    if (!forzar &&
        ahoraMs - momentoGuardadoMs < margenEntreDescargas.inMilliseconds) {
      return actuales.value;
    }
    var url = await AjustesSincronizacion.cargarUrl();
    if (url.trim().isEmpty && esVersionDemo) {
      url = ServicioNoticiasSector.servidorNoticiasDemo;
    }
    if (url.trim().isEmpty) return actuales.value;
    try {
      final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final respuesta = await _cliente
          .get(Uri.parse('$base/wp-json/solera-zunbeltz/v1/entidades'))
          .timeout(const Duration(seconds: 20));
      // 404: WordPress con un plugin anterior a la 0.7.
      if (respuesta.statusCode != 200) return actuales.value;
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (datos is! Map || datos['entidades'] is! List) return actuales.value;
      final entidades = entidadesDesdeRespuesta(datos);
      actuales.value = entidades;
      try {
        final preferencias = await SharedPreferences.getInstance();
        await preferencias.setString(
            _claveCache,
            jsonEncode({
              'entidades': [for (final entidad in entidades) entidad.aJson()]
            }));
        await preferencias.setInt(_claveCacheMomento, ahoraMs);
      } catch (_) {}
      return entidades;
    } catch (_) {
      return actuales.value;
    }
  }

  static List<EntidadColaboradora> entidadesDesdeRespuesta(
      Map<Object?, Object?> datos) {
    final lista = datos['entidades'];
    if (lista is! List) return const [];
    return [
      for (final item in lista)
        if (item is Map) EntidadColaboradora.desdeJson(item),
    ].whereType<EntidadColaboradora>().toList();
  }
}
