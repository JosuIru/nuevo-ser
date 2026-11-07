import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:permission_handler/permission_handler.dart';

/// Asegura que la ubicación esté habilitada y que el usuario haya
/// concedido el permiso. Devuelve `true` si se puede pedir posición.
///
/// Patrón compartido con el resto de la suite Larrea. Si el servicio
/// del dispositivo está apagado o el usuario deniega permanentemente
/// el permiso, el caller debe avisar y dejar que el operador rellene
/// las coordenadas a mano.
Future<bool> asegurarPermisoUbicacion() async {
  final servicioActivo = await Geolocator.isLocationServiceEnabled();
  if (!servicioActivo) return false;
  var permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
  }
  if (permiso == LocationPermission.denied ||
      permiso == LocationPermission.deniedForever) {
    return false;
  }
  return true;
}

Future<bool> asegurarPermisoNotificaciones() async {
  final estado = await Permission.notification.status;
  if (estado.isDenied) {
    final nuevo = await Permission.notification.request();
    return nuevo.isGranted;
  }
  return estado.isGranted;
}

/// Posición actual (latitud, longitud) para la ubicación de una parcela, o
/// null si no hay permiso o el GPS no responde; en ese caso avisa con un
/// mensaje y la parcela queda sin ubicación.
Future<(double, double)?> leerUbicacionActual(BuildContext context) async {
  final mensajero = ScaffoldMessenger.of(context);
  try {
    if (!await asegurarPermisoUbicacion()) {
      mensajero.showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('huer.gps_sin_permiso'))));
      return null;
    }
    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 30),
    );
    return (posicion.latitude, posicion.longitude);
  } catch (error) {
    debugPrint('GPS: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('huer.gps_error'))));
    return null;
  }
}
