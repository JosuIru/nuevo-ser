// Previsión del tiempo para los avisos de Hoy. Usa `ServicioMeteoAgro` del
// core (Open-Meteo, 7 días, sin clave) y la guarda en memoria una hora por
// lugar: Hoy se recarga con cada cambio de datos y no hace falta pedirla
// otra vez. Sin red o con error devuelve null y la pantalla no enseña nada.

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PrevisionAgro, ServicioMeteoAgro;

import '../dominio/avisos_tiempo.dart';

typedef ObtenerPrevisionAgro = Future<PrevisionAgro> Function({
  required double latitud,
  required double longitud,
});

class TiempoHuerta {
  TiempoHuerta({
    ObtenerPrevisionAgro? obtener,
    this.vigencia = const Duration(hours: 1),
  }) : _obtener = obtener ?? ServicioMeteoAgro().obtener;

  /// La que usa la app; los tests la sustituyen.
  static TiempoHuerta instancia = TiempoHuerta();

  final ObtenerPrevisionAgro _obtener;
  final Duration vigencia;
  final Map<String, ({DateTime cuando, List<DiaPrevisto> dias})> _cache = {};

  /// Días previstos en [lugar] (null si no se pudo descargar).
  Future<List<DiaPrevisto>?> prevision(LatLng lugar, {DateTime? ahora}) async {
    final momento = ahora ?? DateTime.now();
    final clave = '${lugar.latitude.toStringAsFixed(2)},'
        '${lugar.longitude.toStringAsFixed(2)}';
    final guardada = _cache[clave];
    if (guardada != null && momento.difference(guardada.cuando) < vigencia) {
      return guardada.dias;
    }
    try {
      final descargada =
          await _obtener(latitud: lugar.latitude, longitud: lugar.longitude);
      final dias = [
        for (final dia in descargada.dias)
          (
            fecha: dia.fecha,
            minimaC: dia.tempMin,
            maximaC: dia.tempMax,
            lluviaMm: dia.lluviaMm,
          ),
      ];
      _cache[clave] = (cuando: momento, dias: dias);
      return dias;
    } catch (error) {
      debugPrint('Sin previsión del tiempo: $error');
      return null;
    }
  }
}
