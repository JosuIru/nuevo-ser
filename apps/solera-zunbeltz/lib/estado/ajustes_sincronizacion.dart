import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuración de sincronización de tareas con el WordPress propio de
/// Zunbeltz Elkartea (plugin `solera-zunbeltz-sync`). Persistencia local
/// con prefijo `zunbeltz.*`, igual que `Coordinador`.
class AjustesSincronizacion {
  static const _claveUrl = 'zunbeltz.sync_url';
  static const _claveToken = 'zunbeltz.sync_token';

  /// La guardada en Ajustes o, en la app web servida por el plugin
  /// (`…/app/`), la del propio WordPress: así solo hay que poner el token.
  static Future<String> cargarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final guardada = prefs.getString(_claveUrl) ?? '';
    if (guardada.isNotEmpty || !kIsWeb) return guardada;
    return urlServidorDesdeAppWeb(Uri.base) ?? '';
  }

  static Future<void> guardarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUrl, url.trim());
  }

  static Future<String> cargarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveToken) ?? '';
  }

  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token.trim());
  }
}

/// Dirección del WordPress que sirve la app web en `<WordPress>/app/`, o
/// `null` si la app no se está sirviendo desde ahí.
String? urlServidorDesdeAppWeb(Uri direccionApp) {
  final segmentos = direccionApp.pathSegments;
  final posicion = segmentos.lastIndexOf('app');
  if (posicion == -1 || !direccionApp.hasScheme) return null;
  final ruta = segmentos.take(posicion).join('/');
  return '${direccionApp.origin}${ruta.isEmpty ? '' : '/$ruta'}';
}
