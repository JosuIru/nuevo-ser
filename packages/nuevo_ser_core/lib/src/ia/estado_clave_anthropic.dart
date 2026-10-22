import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia de la clave de Anthropic que pone la propia persona
/// (modelo «trae tu clave»). **Solo local**: se guarda en
/// `shared_preferences` del dispositivo y únicamente se envía a
/// `api.anthropic.com` al hacer una consulta; nunca a un servidor propio.
///
/// Cada app usa su propia clave de almacenamiento. Las versiones
/// anteriores de las apps guardaban la clave con el formato
/// `<prefijo>.anthropic.clave` (p. ej. `agro.anthropic.clave`,
/// `solera_apicola.anthropic.clave`); [EstadoClaveAnthropic.paraApp]
/// reproduce ese formato, así que las claves ya guardadas se leen tal cual,
/// sin migración.
class EstadoClaveAnthropic {
  EstadoClaveAnthropic({
    required this.claveAlmacenamiento,
    this.longitudMinima = 16,
  });

  /// Atajo para el formato de siempre: `<prefijoApp>.anthropic.clave`.
  factory EstadoClaveAnthropic.paraApp(String prefijoApp,
          {int longitudMinima = 16}) =>
      EstadoClaveAnthropic(
        claveAlmacenamiento: '$prefijoApp.anthropic.clave',
        longitudMinima: longitudMinima,
      );

  /// Clave de `shared_preferences` donde vive la clave de Anthropic.
  final String claveAlmacenamiento;

  /// Por debajo de esta longitud no se considera una clave válida.
  final int longitudMinima;

  /// Si hay una clave utilizable guardada. Se actualiza al [cargar],
  /// [guardar] y [borrar], para repintar con un `ValueListenableBuilder`.
  final ValueNotifier<bool> hayClave = ValueNotifier<bool>(false);

  /// Devuelve la clave guardada (sin espacios alrededor) o null si no hay.
  Future<String?> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final claveGuardada = preferencias.getString(claveAlmacenamiento)?.trim();
    final hayClaveGuardada = claveGuardada != null && claveGuardada.isNotEmpty;
    hayClave.value =
        hayClaveGuardada && claveGuardada.length >= longitudMinima;
    return hayClaveGuardada ? claveGuardada : null;
  }

  /// Guarda la clave. Una clave vacía equivale a [borrar].
  Future<void> guardar(String clave) async {
    final claveLimpia = clave.trim();
    if (claveLimpia.isEmpty) {
      await borrar();
      return;
    }
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(claveAlmacenamiento, claveLimpia);
    hayClave.value = claveLimpia.length >= longitudMinima;
  }

  Future<void> borrar() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(claveAlmacenamiento);
    hayClave.value = false;
  }

  /// Si hay una clave guardada con la longitud mínima.
  Future<bool> tieneClave() async {
    final clave = await cargar();
    return clave != null && clave.length >= longitudMinima;
  }

  /// Si [clave] tiene pinta de clave válida (solo longitud: el formato
  /// exacto lo decide Anthropic).
  bool pareceValida(String clave) => clave.trim().length >= longitudMinima;

  void dispose() => hayClave.dispose();
}
