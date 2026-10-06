import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../estado/idioma_app.dart';
import '../estado/sesion_espacio.dart';
import 'servicio_notificaciones.dart';
import 'servicio_sincronizacion.dart';

/// Sincronización con la app cerrada (solo Android): Android lanza cada
/// ~15 minutos, con conexión, una tarea que sincroniza en segundo plano y,
/// si llega algo nuevo (una alarma de otra persona, una petición), muestra
/// las mismas notificaciones que con la app abierta.
///
/// No es instantáneo: Android agrupa estas tareas para ahorrar batería y,
/// con el móvil en reposo, puede retrasarlas. Para avisos al instante haría
/// falta push (Firebase): decisión pendiente, ver BLOQUEOS 28.
const String _nombreTarea = 'zunbeltz.sincronizar';
const Duration _frecuencia = Duration(minutes: 15);

/// Si hubo una sincronización hace menos de esto (p. ej. con la app
/// abierta), la tarea en segundo plano no hace nada: así no se pisan.
const Duration margenEntreSincronizaciones = Duration(minutes: 5);

const String claveUltimaSincronizacion = 'zunbeltz.ultima_sync_ms';

/// Punto de entrada que Android llama en un proceso aparte.
@pragma('vm:entry-point')
void despachadorSegundoPlano() {
  Workmanager().executeTask((tarea, datos) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.reload();
      if (!tocaSincronizar(
          preferencias.getInt(claveUltimaSincronizacion), DateTime.now())) {
        return true;
      }
      await precargarIdiomaZunbeltz();
      await precargarSesionEspacio();
      await iniciarNotificaciones(pedirPermiso: false);
      await sincronizarEspacio();
    } catch (_) {
      // Sin cobertura o sin configurar: se reintenta en la próxima ronda.
    }
    return true;
  });
}

/// ¿Ha pasado el margen desde la última sincronización? Pura.
@visibleForTesting
bool tocaSincronizar(int? ultimaMs, DateTime ahora) =>
    ultimaMs == null ||
    ahora.difference(DateTime.fromMillisecondsSinceEpoch(ultimaMs)) >=
        margenEntreSincronizaciones;

/// Registra la tarea periódica (una sola vez; si ya existe, se conserva).
Future<void> programarSincronizacionSegundoPlano() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await Workmanager().initialize(despachadorSegundoPlano);
    await Workmanager().registerPeriodicTask(
      _nombreTarea,
      _nombreTarea,
      frequency: _frecuencia,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (_) {
    // Sin planificador en esta plataforma: queda la sincronización con la
    // app abierta.
  }
}
