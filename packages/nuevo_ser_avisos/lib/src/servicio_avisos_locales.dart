import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as datos_zonas_horarias;
import 'package:timezone/timezone.dart' as zona_horaria;

import 'servicio_avisos.dart';

/// Lo que cambia de una app a otra: el canal de Android (lo que la persona
/// ve en Ajustes → Notificaciones), el icono y si hacen falta alarmas
/// exactas.
class ConfiguracionAvisos {
  /// Id del canal de Android, estable (`obrador_avisos`). Cambiarlo crea un
  /// canal nuevo y deja el viejo en los ajustes del móvil.
  final String idCanal;
  final String nombreCanal;
  final String? descripcionCanal;

  /// Icono pequeño (recurso drawable o mipmap de Android). Android pinta solo
  /// su transparencia: una silueta se ve mejor que el logo en color.
  final String iconoAndroid;

  /// Zona horaria de [zona_horaria.local]. Los avisos se programan por el
  /// instante (la hora del `DateTime` que se pasa), así que la zona solo
  /// cuenta para los cambios de hora de verano.
  final String zonaHoraria;

  /// `false` (por defecto): alarmas inexactas que Android puede retrasar
  /// unos minutos para ahorrar batería; no necesitan permiso aparte. `true`:
  /// exactas si la persona lo ha concedido (`SCHEDULE_EXACT_ALARM` en el
  /// manifiesto y permiso en Ajustes); si no, inexactas igualmente.
  final bool alarmasExactas;

  const ConfiguracionAvisos({
    required this.idCanal,
    required this.nombreCanal,
    this.descripcionCanal,
    this.iconoAndroid = '@mipmap/ic_launcher',
    this.zonaHoraria = 'Europe/Madrid',
    this.alarmasExactas = false,
  });
}

/// Avisos con `flutter_local_notifications` (el patrón de Larrea Zunbeltz).
/// Cualquier fallo del plugin se traga: una notificación que no sale no
/// puede tumbar la pantalla que la pidió.
class ServicioAvisosLocales implements ServicioAvisos {
  final ConfiguracionAvisos configuracion;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _iniciado = false;
  bool? _exactasPermitidas;

  ServicioAvisosLocales(this.configuracion,
      {FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> inicializar() async {
    if (_iniciado || kIsWeb) return;
    try {
      datos_zonas_horarias.initializeTimeZones();
      zona_horaria.setLocalLocation(
          zona_horaria.getLocation(configuracion.zonaHoraria));
      await _plugin.initialize(
        settings: InitializationSettings(
          android: AndroidInitializationSettings(configuracion.iconoAndroid),
          iOS: const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: const LinuxInitializationSettings(defaultActionName: 'Abrir'),
        ),
      );
      _iniciado = true;
    } catch (_) {
      // Plataforma sin notificaciones (tests, escritorio sin demonio…).
    }
  }

  @override
  Future<bool> pedirPermiso() async {
    await inicializar();
    if (!_iniciado) return false;
    try {
      final android = _android;
      if (android != null) {
        final concedido =
            await android.requestNotificationsPermission() ?? false;
        if (configuracion.alarmasExactas) {
          _exactasPermitidas =
              await android.canScheduleExactNotifications() ?? false;
          if (_exactasPermitidas == false) {
            _exactasPermitidas =
                await android.requestExactAlarmsPermission() ?? false;
          }
        }
        return concedido;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> programar({
    required String clave,
    required DateTime cuando,
    required String titulo,
    String? cuerpo,
  }) async {
    if (!cuando.isAfter(DateTime.now())) return false;
    await inicializar();
    if (!_iniciado) return false;
    try {
      await _plugin.zonedSchedule(
        id: idDeClave(clave),
        scheduledDate: zona_horaria.TZDateTime.from(cuando, zona_horaria.local),
        title: titulo,
        body: cuerpo,
        payload: clave,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            configuracion.idCanal,
            configuracion.nombreCanal,
            channelDescription: configuracion.descripcionCanal,
            importance: Importance.high,
            priority: Priority.high,
            icon: configuracion.iconoAndroid,
          ),
          iOS: const DarwinNotificationDetails(),
          linux: const LinuxNotificationDetails(),
        ),
        androidScheduleMode: await _modoAndroid(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AndroidScheduleMode> _modoAndroid() async {
    if (!configuracion.alarmasExactas) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    try {
      _exactasPermitidas ??=
          await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      _exactasPermitidas = false;
    }
    return _exactasPermitidas == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  @override
  Future<void> cancelar(String clave) async {
    await inicializar();
    if (!_iniciado) return;
    try {
      await _plugin.cancel(id: idDeClave(clave));
    } catch (_) {}
  }

  @override
  Future<void> cancelarGrupo(String prefijo) async {
    for (final aviso in await pendientes()) {
      if (aviso.clave.startsWith(prefijo)) await cancelar(aviso.clave);
    }
  }

  @override
  Future<List<AvisoPendiente>> pendientes() async {
    await inicializar();
    if (!_iniciado) return const [];
    try {
      final peticiones = await _plugin.pendingNotificationRequests();
      return [
        for (final peticion in peticiones)
          // Sin payload no es de este paquete: no se toca.
          if (peticion.payload != null &&
              idDeClave(peticion.payload!) == peticion.id)
            AvisoPendiente(
              clave: peticion.payload!,
              titulo: peticion.title ?? '',
              cuerpo: peticion.body,
            ),
      ];
    } catch (_) {
      return const [];
    }
  }
}
