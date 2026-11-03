import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../estado/ajustes_sincronizacion.dart';
import '../estado/idioma_app.dart';
import 'aviso_al_momento.dart';
import 'servicio_notificaciones.dart';
import 'servicio_sincronizacion.dart';

/// Avisos al momento en Android con Firebase Cloud Messaging (proyecto
/// «larrea-zunbeltz»). El servidor (`includes/push-fcm.php`) manda un
/// mensaje solo de datos con lo mismo que el Web Push: alarmas, peticiones
/// para coordinación y tareas asignadas. La app lo enseña con
/// [mostrarAvisoAlMomento], con la app abierta, en segundo plano o cerrada.
///
/// El token del móvil se registra en `POST /push/fcm` con el token de la
/// persona: al abrir la app, tras cada sincronización si ha cambiado algo
/// (persona, servidor, idioma) y cuando Firebase lo renueva. Si el servidor
/// no tiene la clave de Firebase puesta, no pasa nada: sigue la
/// sincronización de cada ~15 min. Con «Forzar detención» Android no
/// entrega nada hasta volver a abrir la app.
const _claveHuellaRegistro = 'zunbeltz.fcm_registrado';

bool _iniciado = false;

bool get _plataformaConFcm => !kIsWeb && Platform.isAndroid;

/// En `main()`, antes de `runApp`. Firebase lee `google-services.json`.
Future<void> prepararAvisosFcm() async {
  if (!_plataformaConFcm) return;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(recibirAvisoFcmEnSegundoPlano);
  } catch (_) {
    // Sin Firebase (build sin google-services.json, tests): la app va igual.
  }
}

/// Con la app ya en marcha: escucha mensajes y registra el móvil.
Future<void> iniciarAvisosFcm() async {
  if (!_plataformaConFcm || _iniciado || Firebase.apps.isEmpty) return;
  _iniciado = true;
  try {
    FirebaseMessaging.onMessage.listen((mensaje) async {
      final aviso = AvisoAlMomento.desdeDatos(mensaje.data);
      if (aviso == null) return;
      await mostrarAvisoAlMomento(aviso);
      // Con la app abierta, de paso se traen los datos nuevos.
      unawaited(sincronizarEspacioEnSilencio());
    });
    // Token clásico de FCM (el `token` de la API HTTP v1 del servidor). La
    // 17 lo marca como obsoleto en favor del FID de `register()`, pero el
    // envío al FID no está aún en el servidor: cambiar los dos a la vez.
    // ignore: deprecated_member_use
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => registrarMovilFcm(tokenFcm: token));
    oyentesSincronizacion.add((_) => registrarMovilFcm());
    await registrarMovilFcm();
  } catch (_) {
    // Sin Google Play Services, sin red…: queda la sincronización.
  }
}

/// Punto de entrada de Firebase con la app en segundo plano o cerrada
/// (isolate aparte).
@pragma('vm:entry-point')
Future<void> recibirAvisoFcmEnSegundoPlano(RemoteMessage mensaje) async {
  final aviso = AvisoAlMomento.desdeDatos(mensaje.data);
  if (aviso == null) return;
  await mostrarAvisoAlMomento(aviso);
}

/// Manda el token del móvil al servidor si no se ha mandado ya con esta
/// misma persona, servidor e idioma. Sin sesión, no hace nada.
Future<void> registrarMovilFcm({String? tokenFcm}) async {
  if (!_plataformaConFcm || Firebase.apps.isEmpty) return;
  try {
    final url = await AjustesSincronizacion.cargarUrl();
    final token = await AjustesSincronizacion.cargarToken();
    if (url.trim().isEmpty || token.trim().isEmpty) return;
    // ignore: deprecated_member_use
    final movil = tokenFcm ?? await FirebaseMessaging.instance.getToken();
    if (movil == null || movil.isEmpty) return;
    final idioma = localeAppZunbeltz.value?.languageCode == 'eu' ? 'eu' : 'es';
    final huella = huellaRegistroFcm(
        url: url, token: token, tokenFcm: movil, idioma: idioma);
    final preferencias = await SharedPreferences.getInstance();
    if (preferencias.getString(_claveHuellaRegistro) == huella) return;
    final respuesta = await http
        .post(
          Uri.parse(
              '${_sinBarraFinal(url)}/wp-json/solera-zunbeltz/v1/push/fcm'),
          headers: {
            // Sin `accept`, el ModSecurity del hosting responde 406.
            'accept': 'application/json',
            'content-type': 'application/json; charset=utf-8',
            'X-Zunbeltz-Token': token.trim(),
          },
          body: jsonEncode({'token': movil, 'idioma': idioma}),
        )
        .timeout(const Duration(seconds: 20));
    // 404: plugin anterior a FCM. Se reintenta en la próxima sincronización.
    if (respuesta.statusCode == 200) {
      await preferencias.setString(_claveHuellaRegistro, huella);
    }
  } catch (_) {
    // Sin red: se reintenta en la próxima sincronización.
  }
}

/// Qué combinación se registró por última vez (resumida: no se guarda otra
/// copia del token de la persona). Pura.
@visibleForTesting
String huellaRegistroFcm({
  required String url,
  required String token,
  required String tokenFcm,
  required String idioma,
}) =>
    sha256
        .convert(utf8.encode(
            [_sinBarraFinal(url), token.trim(), tokenFcm, idioma].join('\n')))
        .toString();

String _sinBarraFinal(String url) {
  final limpia = url.trim();
  return limpia.endsWith('/') ? limpia.substring(0, limpia.length - 1) : limpia;
}
