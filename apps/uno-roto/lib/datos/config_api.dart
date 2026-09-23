/// Configuración de conexión al backend Uno Roto.
///
/// Hay dos entornos:
///   - **Local WP** (Ubuntu): `http://127.0.0.1:10063` con cabecera
///     `Host: uno-roto.local`. Para que llegue desde un móvil físico hace
///     falta `adb reverse tcp:10063 tcp:10063`
///     (script: `scripts/dev/abrir_puente_wp.sh`).
///   - **Producción**: el sitio WordPress real con HTTPS y sin cabecera Host.
///
/// El interruptor [usarProduccion] decide cuál se usa. Los consumidores
/// deben leer [urlBase] y [hostOverride] en lugar de las constantes de
/// entorno directas.
import 'package:flutter/foundation.dart' show kIsWeb;

class ConfigApi {
  /// Local WP en Ubuntu: nginx escucha en 10063, exige cabecera Host.
  static const String urlBaseLocal = 'http://127.0.0.1:10063';
  static const String hostLocal = 'uno-roto.local';

  /// Producción: HTTPS, sin cabecera Host (la resuelve el DNS).
  static const String urlBaseProduccion = 'https://uno-roto.gailu.it';

  /// Si es `true`, la app habla con producción. Si es `false`, con Local WP.
  /// Cambiar este flag basta para alternar todo el cableado.
  static const bool usarProduccion = true;

  /// URL base activa según [usarProduccion]. En la versión web, el
  /// WordPress que sirve el juego (mismo origen: sin CORS y sin
  /// configurar nada; el navegador no deja forzar la cabecera `Host`).
  static String get urlBase => kIsWeb
      ? Uri.base.origin
      : (usarProduccion ? urlBaseProduccion : urlBaseLocal);

  /// Cabecera `Host` a forzar, o `null` si el entorno no la necesita.
  /// En producción y en web no se usa.
  static String? get hostOverride =>
      (kIsWeb || usarProduccion) ? null : hostLocal;
}
