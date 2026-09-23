import 'package:shared_preferences/shared_preferences.dart';

/// Configuración de sincronización de tareas con el WordPress propio de
/// Zunbeltz Elkartea (plugin `solera-zunbeltz-sync`). Persistencia local
/// con prefijo `zunbeltz.*`, igual que `Coordinador`.
class AjustesSincronizacion {
  static const _claveUrl = 'zunbeltz.sync_url';
  static const _claveToken = 'zunbeltz.sync_token';

  static Future<String> cargarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveUrl) ?? '';
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
