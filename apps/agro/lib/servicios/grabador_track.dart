import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../datos/base_datos.dart';
import '../modelos/track.dart';

/// Singleton que graba la posición GPS mientras el usuario recorre la
/// finca inspeccionando. Persistencia incremental: cada punto se
/// escribe inmediatamente al buffer en BD, así un crash o kill OS no
/// pierde la sesión. Al arrancar, `consolidarSesionesPendientes`
/// recupera tracks ≥2 puntos como "Track recuperado DD/MM HH:mm".
///
/// Patrón heredado de naturaleza (`apps/naturaleza/.../grabador_track`),
/// el campo de uso es prácticamente el mismo (caminar registrando
/// posición, parar y guardar). Diferencias para Larrea: el texto de la
/// notificación menciona Larrea en lugar de Naturaleza, todo lo demás
/// es código equivalente.
class GrabadorTrack {
  static final GrabadorTrack instancia = GrabadorTrack._interno();
  GrabadorTrack._interno();

  StreamSubscription<Position>? _suscripcion;
  final List<TrackPunto> _puntos = [];
  int? _inicioMs;
  final _streamCambios = StreamController<void>.broadcast();

  bool get grabando => _suscripcion != null;
  List<TrackPunto> get puntos => List.unmodifiable(_puntos);
  int? get inicioMs => _inicioMs;
  Stream<void> get cambios => _streamCambios.stream;

  void iniciar() {
    if (grabando) return;
    _puntos.clear();
    _inicioMs = DateTime.now().millisecondsSinceEpoch;
    final settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Grabando recorrido',
              notificationText: 'Larrea está registrando tu inspección',
              enableWakeLock: true,
              setOngoing: true,
            ),
          )
        : const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _suscripcion = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      final punto = TrackPunto(
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        latitud: pos.latitude,
        longitud: pos.longitude,
        altitud: pos.altitude,
        precision: pos.accuracy,
      );
      _puntos.add(punto);
      // Persistencia incremental — best-effort, no bloquea la grabación.
      final inicio = _inicioMs;
      if (inicio != null) {
        BaseDatosAgro.instancia
            .bufferarPuntoTrack(inicioMs: inicio, punto: punto)
            .catchError((_) {});
      }
      _streamCambios.add(null);
    });
    _streamCambios.add(null);
  }

  ({Track track, List<TrackPunto> puntos})? detener({String nombre = ''}) {
    if (!grabando) return null;
    _suscripcion?.cancel();
    _suscripcion = null;
    final inicio = _inicioMs;
    if (_puntos.isEmpty) {
      if (inicio != null) {
        BaseDatosAgro.instancia.vaciarBufferTrack(inicioMs: inicio).catchError((_) {});
      }
      _streamCambios.add(null);
      return null;
    }
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final track = Track(
      fechaMs: inicio ?? ahora,
      nombre: nombre,
      duracionMs: ahora - (inicio ?? ahora),
      distanciaMetros: _calcularDistancia(_puntos),
    );
    final puntos = List<TrackPunto>.from(_puntos);
    _puntos.clear();
    _inicioMs = null;
    _streamCambios.add(null);
    return (track: track, puntos: puntos);
  }

  /// Recupera tracks que quedaron grabándose si la app murió por
  /// crash o kill OS. Sesiones con ≥2 puntos se consolidan; con
  /// menos puntos se descartan. Devuelve cuántos tracks se recuperaron.
  Future<int> consolidarSesionesPendientes() async {
    final db = BaseDatosAgro.instancia;
    int recuperados = 0;
    try {
      final inicios = await db.sesionesPendientesEnBuffer();
      for (final inicioMs in inicios) {
        final puntos = await db.recuperarBufferTrack(inicioMs: inicioMs);
        if (puntos.length < 2) {
          await db.vaciarBufferTrack(inicioMs: inicioMs);
          continue;
        }
        final ultimo = puntos.last.fechaMs;
        final inicio = DateTime.fromMillisecondsSinceEpoch(inicioMs);
        final nombreAuto =
            'Recorrido recuperado ${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')} '
            '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}';
        final track = Track(
          fechaMs: inicioMs,
          nombre: nombreAuto,
          duracionMs: ultimo - inicioMs,
          distanciaMetros: _calcularDistancia(puntos),
        );
        await db.guardarTrack(track, puntos);
        await db.vaciarBufferTrack(inicioMs: inicioMs);
        recuperados++;
      }
    } catch (_) {}
    return recuperados;
  }

  Future<void> descartarBufferDeSesion(int inicioMs) async {
    try {
      await BaseDatosAgro.instancia.vaciarBufferTrack(inicioMs: inicioMs);
    } catch (_) {}
  }

  void cancelar() {
    _suscripcion?.cancel();
    _suscripcion = null;
    final inicio = _inicioMs;
    _puntos.clear();
    _inicioMs = null;
    if (inicio != null) {
      BaseDatosAgro.instancia.vaciarBufferTrack(inicioMs: inicio).catchError((_) {});
    }
    _streamCambios.add(null);
  }
}

double _calcularDistancia(List<TrackPunto> puntos) {
  double total = 0;
  for (var i = 1; i < puntos.length; i++) {
    total += _distanciaHaversine(puntos[i - 1].latitud, puntos[i - 1].longitud, puntos[i].latitud, puntos[i].longitud);
  }
  return total;
}

double _distanciaHaversine(double lat1, double lon1, double lat2, double lon2) {
  const radioTierra = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return radioTierra * c;
}

/// Genera un GPX 1.1 a partir del track y sus puntos.
String generarGpx(Track track, List<TrackPunto> puntos) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="solera-agro" xmlns="http://www.topografix.com/GPX/1/1">')
    ..writeln('  <trk>')
    ..writeln('    <name>${_escaparXml(track.nombre.isEmpty ? "Recorrido" : track.nombre)}</name>')
    ..writeln('    <trkseg>');
  for (final p in puntos) {
    buffer.write('      <trkpt lat="${p.latitud}" lon="${p.longitud}">');
    if (p.altitud != null) buffer.write('<ele>${p.altitud}</ele>');
    buffer.write('<time>${DateTime.fromMillisecondsSinceEpoch(p.fechaMs, isUtc: true).toIso8601String()}</time>');
    buffer.writeln('</trkpt>');
  }
  buffer
    ..writeln('    </trkseg>')
    ..writeln('  </trk>')
    ..writeln('</gpx>');
  return buffer.toString();
}

String _escaparXml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
