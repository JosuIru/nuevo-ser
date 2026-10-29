import '../estado/ajustes_sincronizacion.dart';
import 'avisos_push_web_otras.dart'
    if (dart.library.js_interop) 'avisos_push_web_navegador.dart' as navegador;

/// Avisos al momento en la versión web (Web Push), con `web/avisos_push.js`
/// y el plugin (`includes/push-web.php`). En el móvil no hacen falta: la
/// app nativa avisa con sus notificaciones locales.
enum EstadoAvisosPush {
  activo,
  inactivo,

  /// El permiso se retiró: solo se cambia en los ajustes del navegador.
  denegado,

  /// iPhone o iPad sin la app añadida a la pantalla de inicio.
  instalar,
  noCompatible,
  error;

  static EstadoAvisosPush desdeTexto(String texto) => switch (texto) {
        'activo' => activo,
        'inactivo' => inactivo,
        'denegado' => denegado,
        'instalar' => instalar,
        'error' => error,
        _ => noCompatible,
      };
}

Future<EstadoAvisosPush> estadoAvisosPush() async =>
    EstadoAvisosPush.desdeTexto(await navegador.estadoAvisosPush());

/// Pide permiso y se suscribe. Llamarla en el mismo toque, sin esperar
/// nada antes: Safari solo pregunta en respuesta a un gesto.
Future<EstadoAvisosPush> activarAvisosPush(
        {required String url,
        required String token,
        required String idioma}) async =>
    EstadoAvisosPush.desdeTexto(
        await navegador.activarAvisosPush(_sinBarraFinal(url), token, idioma));

Future<EstadoAvisosPush> desactivarAvisosPush(
        {required String url, required String token}) async =>
    EstadoAvisosPush.desdeTexto(
        await navegador.desactivarAvisosPush(_sinBarraFinal(url), token));

/// Al abrir la app: si ya estaban activos, se vuelve a mandar la
/// suscripción (puede haber cambiado, o la persona de este navegador).
Future<void> renovarAvisosPush({required String idioma}) async {
  try {
    final url = await AjustesSincronizacion.cargarUrl();
    final token = await AjustesSincronizacion.cargarToken();
    if (url.trim().isEmpty || token.trim().isEmpty) return;
    await navegador.renovarAvisosPush(_sinBarraFinal(url), token, idioma);
  } catch (_) {
    // Nada de lo automático debe tumbar la app.
  }
}

String _sinBarraFinal(String url) {
  final limpia = url.trim();
  return limpia.endsWith('/') ? limpia.substring(0, limpia.length - 1) : limpia;
}
