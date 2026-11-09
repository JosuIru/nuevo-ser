// Permiso y lectura del GPS para la suite Larrea. Antes había una copia
// de `asegurarPermisoUbicacion` en cada app.

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Asegura que la ubicación esté encendida y con permiso. `false` si no se
/// puede pedir la posición: quien llama avisa y deja meterla a mano.
Future<bool> asegurarPermisoUbicacion() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  var permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
  }
  return permiso != LocationPermission.denied &&
      permiso != LocationPermission.deniedForever;
}

/// Una lectura del GPS con su precisión en metros.
typedef LecturaGps = ({LatLng posicion, double precisionMetros});

/// Posición actual con alta precisión, o null si no hay permiso, el GPS
/// está apagado o no responde en [limite].
Future<LecturaGps?> leerPosicionActual(
    {Duration limite = const Duration(seconds: 15)}) async {
  if (!await asegurarPermisoUbicacion()) return null;
  try {
    // geolocator 12.0.0 (fijado en toda la suite): API de parámetros
    // sueltos.
    final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, timeLimit: limite);
    return (
      posicion: LatLng(posicion.latitude, posicion.longitude),
      precisionMetros: posicion.accuracy,
    );
  } catch (_) {
    return null;
  }
}
