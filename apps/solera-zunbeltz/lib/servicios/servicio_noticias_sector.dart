import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../estado/ajustes_sincronizacion.dart';
import '../estado/version_demo.dart';
import '../modelos/noticia_sector.dart';

/// Lo que hay de noticias del sector en este dispositivo y cuándo se bajó.
class NoticiasSectorGuardadas {
  const NoticiasSectorGuardadas(this.noticias, {this.actualizadoMs = 0});

  static const vacias = NoticiasSectorGuardadas([]);

  final List<NoticiaSector> noticias;

  /// 0 si nunca se han bajado.
  final int actualizadoMs;
}

/// Noticias de los canales RSS que coordinación da de alta en el panel de
/// WordPress (`GET /solera-zunbeltz/v1/noticias`). La última lista se
/// guarda en `shared_preferences`, como la previsión del tiempo, para verla
/// sin cobertura. No genera notificaciones.
///
/// El endpoint es público: el token se manda si lo hay, pero no hace falta.
/// Así la demo web, que no tiene sesión, pide las noticias al servidor de
/// [servidorNoticiasDemo] (o al WordPress que la sirve en `/app/`).
class ServicioNoticiasSector {
  ServicioNoticiasSector({http.Client? cliente})
      : _cliente = cliente ?? _clienteCompartido;

  /// Uno para toda la app: cada pantalla crea su servicio.
  static final http.Client _clienteCompartido = http.Client();

  static const _claveCache = 'zunbeltz.noticias_sector';

  /// No se vuelve a preguntar al servidor antes de este tiempo salvo que se
  /// pida a mano (tirar hacia abajo): el servidor solo lee los canales
  /// cada tres horas.
  static const margenEntreDescargas = Duration(minutes: 30);

  final http.Client _cliente;

  /// Servidor del que la demo web toma las noticias:
  /// `--dart-define=SOLERA_DEMO_SERVIDOR=https://app.zunbeltz.com`.
  static const servidorNoticiasDemo =
      String.fromEnvironment('SOLERA_DEMO_SERVIDOR');

  /// Cambia cada vez que llegan noticias nuevas del servidor.
  static final ValueNotifier<NoticiasSectorGuardadas> actuales =
      ValueNotifier(NoticiasSectorGuardadas.vacias);

  /// Al cambiar de servidor, las noticias del anterior ya no valen.
  static Future<void> olvidarGuardadas() async {
    actuales.value = NoticiasSectorGuardadas.vacias;
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.remove(_claveCache);
    } catch (_) {}
  }

  Future<NoticiasSectorGuardadas> cargarGuardadas() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final guardado = preferencias.getString(_claveCache);
      if (guardado == null) return NoticiasSectorGuardadas.vacias;
      final datos = jsonDecode(guardado) as Map<String, dynamic>;
      final guardadas = NoticiasSectorGuardadas(
        noticiasDesdeRespuesta(datos),
        actualizadoMs: (datos['actualizado_ms'] as num?)?.toInt() ?? 0,
      );
      actuales.value = guardadas;
      return guardadas;
    } catch (_) {
      return NoticiasSectorGuardadas.vacias;
    }
  }

  /// Baja las noticias si hay servidor configurado y ha pasado
  /// [margenEntreDescargas] (o [forzar]). Devuelve las que quedan en el
  /// dispositivo; si falla la red, las guardadas.
  Future<NoticiasSectorGuardadas> actualizar({bool forzar = false}) async {
    final guardadas = await cargarGuardadas();
    final ahora = DateTime.now();
    if (!forzar &&
        ahora.millisecondsSinceEpoch - guardadas.actualizadoMs <
            margenEntreDescargas.inMilliseconds) {
      return guardadas;
    }
    var url = await AjustesSincronizacion.cargarUrl();
    if (url.trim().isEmpty && esVersionDemo) url = servidorNoticiasDemo;
    final token = await AjustesSincronizacion.cargarToken();
    if (url.trim().isEmpty) return guardadas;
    try {
      final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final respuesta = await _cliente.get(
        Uri.parse('$base/wp-json/solera-zunbeltz/v1/noticias'),
        headers: {if (token.isNotEmpty) 'X-Zunbeltz-Token': token},
      ).timeout(const Duration(seconds: 20));
      // 404: WordPress con un plugin anterior a las noticias del sector.
      if (respuesta.statusCode != 200) return guardadas;
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (datos is! Map) return guardadas;
      final nuevas = NoticiasSectorGuardadas(
        noticiasDesdeRespuesta(datos),
        actualizadoMs: ahora.millisecondsSinceEpoch,
      );
      await _guardar(nuevas);
      actuales.value = nuevas;
      return nuevas;
    } catch (_) {
      return guardadas;
    }
  }

  Future<void> _guardar(NoticiasSectorGuardadas guardadas) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(
          _claveCache,
          jsonEncode({
            'actualizado_ms': guardadas.actualizadoMs,
            'noticias': [
              for (final noticia in guardadas.noticias) noticia.aJson()
            ],
          }));
    } catch (_) {
      // La caché es una comodidad: si falla, las noticias se ven igual.
    }
  }

  /// Lee la lista `noticias` de una respuesta (o de la caché), saltándose
  /// lo que no sea una noticia válida.
  static List<NoticiaSector> noticiasDesdeRespuesta(
      Map<Object?, Object?> datos) {
    final lista = datos['noticias'];
    if (lista is! List) return const [];
    return [
      for (final item in lista)
        if (item is Map) NoticiaSector.desdeJson(item),
    ].whereType<NoticiaSector>().toList();
  }
}
