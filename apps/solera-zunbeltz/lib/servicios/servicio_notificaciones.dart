import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as datos_zonas_horarias;
import 'package:timezone/timezone.dart' as zona_horaria;

import '../datos/base_datos.dart';
import '../estado/idioma_app.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import 'cliente_sync_zunbeltz.dart';
import 'resumen_notificaciones.dart';
import 'servicio_sincronizacion.dart';
import '../utiles/descripcion_actividad.dart';

/// Notificaciones del móvil:
///
/// - **Alarmas** de campo de otras personas, al llegar con la
///   sincronización (canal de alta importancia).
/// - **Peticiones** nuevas, para coordinación.
/// - **Cambios** de otras personas en el espacio, para coordinación («Ane ha
///   movido el punto "Corral móvil" en Zunbeltz»).
/// - **Tareas vencidas**: recordatorio diario a las 9:00, programado en el
///   sistema para que salte aunque la app esté cerrada, hasta que no quede
///   ninguna. Se reprograma al abrir la app y tras cada sincronización.
///
/// Con la app cerrada, en Android, la sincronización en segundo plano
/// (`sincronizacion_segundo_plano.dart`) trae las alarmas en unos 15
/// minutos. Sin push: nada es instantáneo (ver BLOQUEOS 28, Firebase).
/// En web no se usan.
final _plugin = FlutterLocalNotificationsPlugin();
bool _notificacionesListas = false;

const _idAlarmas = 1;
const _idPeticiones = 2;
const _idVencidas = 3;
const _idCambios = 4;
const _horaRecordatorio = 9;
const _claveYaNotificadas = 'zunbeltz.notificadas';

/// [pedirPermiso] es false en segundo plano: no hay pantalla para pedirlo.
Future<void> iniciarNotificaciones({bool pedirPermiso = true}) async {
  if (kIsWeb || _notificacionesListas) return;
  try {
    datos_zonas_horarias.initializeTimeZones();
    zona_horaria.setLocalLocation(zona_horaria.getLocation('Europe/Madrid'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
      ),
    );
    if (pedirPermiso) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _notificacionesListas = true;
    oyentesSincronizacion.add(_alSincronizar);
    await reprogramarRecordatorioVencidas();
  } catch (_) {
    // Plataforma sin notificaciones (tests, escritorio sin demonio…): la
    // app funciona igual.
  }
}

AppLocalizations _textos() {
  final elegido = localeAppZunbeltz.value;
  final delSistema = PlatformDispatcher.instance.locale;
  final idioma = elegido?.languageCode ??
      (localesSoportadosZunbeltz
              .any((locale) => locale.languageCode == delSistema.languageCode)
          ? delSistema.languageCode
          : 'es');
  return lookupAppLocalizations(Locale(idioma));
}

NotificationDetails _detalles({required bool alarma}) {
  final textos = _textos();
  return NotificationDetails(
    android: alarma
        ? AndroidNotificationDetails('alarmas', textos.notificacionCanalAlarmas,
            importance: Importance.high, priority: Priority.high)
        : AndroidNotificationDetails('avisos', textos.notificacionCanalAvisos),
    linux: const LinuxNotificationDetails(),
  );
}

Future<void> _alSincronizar(ResultadoSyncZunbeltz resultado) async {
  if (!_notificacionesListas) return;
  try {
    final preferencias = await SharedPreferences.getInstance();
    final yaNotificadas =
        (preferencias.getStringList(_claveYaNotificadas) ?? const []).toSet();
    final resumen = resumirParaNotificar(resultado, politicaEspacioActual,
        yaNotificadas: yaNotificadas);
    final textos = _textos();

    if (resumen.alarmas.isNotEmpty) {
      await _plugin.show(
        id: _idAlarmas,
        title: resumen.alarmas.length == 1
            ? textos.notificacionAlarma(resumen.alarmas.single)
            : textos.notificacionAlarmas(resumen.alarmas.length),
        body: resumen.alarmas.join(' · '),
        notificationDetails: _detalles(alarma: true),
      );
    }
    if (resumen.peticionesNuevas > 0) {
      await _plugin.show(
        id: _idPeticiones,
        title: textos.notificacionPeticiones(resumen.peticionesNuevas),
        notificationDetails: _detalles(alarma: false),
      );
    }
    if (resumen.actividadAjena.isNotEmpty) {
      final idioma = textos.localeName;
      await _plugin.show(
        id: _idCambios,
        title: textos.notificacionCambios(resumen.actividadAjena.length),
        body: resumen.actividadAjena.reversed
            .take(3)
            .map((entrada) => describirActividad(entrada, textos, idioma))
            .join('\n'),
        notificationDetails: _detalles(alarma: false),
      );
    }

    // Recordar solo lo reciente: la lista no crece sin fin.
    final todas = [...yaNotificadas, ...clavesNotificadas(resultado)];
    await preferencias.setStringList(_claveYaNotificadas,
        todas.skip(todas.length > 300 ? todas.length - 300 : 0).toList());
    await reprogramarRecordatorioVencidas();
  } catch (_) {
    // Una notificación que falla no debe romper la sincronización.
  }
}

/// Programa (o quita) el recordatorio diario de tareas vencidas con el
/// número de ahora.
Future<void> reprogramarRecordatorioVencidas() async {
  if (!_notificacionesListas) return;
  final vencidas = contarTareasVencidas(
    await BaseDatosSoleraZunbeltz().listarTareas(),
    DateTime.now(),
    politicaEspacioActual,
  );
  await _plugin.cancel(id: _idVencidas);
  if (vencidas == 0) return;
  final ahora = zona_horaria.TZDateTime.now(zona_horaria.local);
  var proxima = zona_horaria.TZDateTime(zona_horaria.local, ahora.year,
      ahora.month, ahora.day, _horaRecordatorio);
  if (!proxima.isAfter(ahora)) proxima = proxima.add(const Duration(days: 1));
  final textos = _textos();
  await _plugin.zonedSchedule(
    id: _idVencidas,
    scheduledDate: proxima,
    title: textos.notificacionVencidas(vencidas),
    body: textos.notificacionVencidasCuerpo,
    notificationDetails: _detalles(alarma: false),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
