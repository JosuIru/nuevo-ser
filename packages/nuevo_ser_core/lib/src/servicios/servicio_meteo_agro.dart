// Subido al core el 2026-10-22: era idéntico en agro, solera-viticultura y
// solera-apicola (solera-aceitera tiene una variante propia).
import 'dart:convert';

import 'package:http/http.dart' as http;

class PrevisionAgro {
  final double latitud;
  final double longitud;
  final List<DiaMeteoAgro> dias;
  final DateTime actualizado;

  const PrevisionAgro({
    required this.latitud,
    required this.longitud,
    required this.dias,
    required this.actualizado,
  });

  DiaMeteoAgro? get hoy => dias.isEmpty ? null : dias.first;
}

class DiaMeteoAgro {
  final DateTime fecha;
  final double? tempMin;
  final double? tempMax;
  final double? lluviaMm;
  final double? probLluviaMax;
  final double? vientoMaxKmh;
  final double? rachaMaxKmh;
  final double? et0Mm;
  final double? humedadMedia;
  final double? deficitVaporMax;
  final double? sueloTemp6cmMedia;
  final double? sueloHumedad3a9Media;

  const DiaMeteoAgro({
    required this.fecha,
    this.tempMin,
    this.tempMax,
    this.lluviaMm,
    this.probLluviaMax,
    this.vientoMaxKmh,
    this.rachaMaxKmh,
    this.et0Mm,
    this.humedadMedia,
    this.deficitVaporMax,
    this.sueloTemp6cmMedia,
    this.sueloHumedad3a9Media,
  });

  bool get riesgoHelada => (tempMin ?? 99) <= 2;
  bool get malDiaTratamiento =>
      (vientoMaxKmh ?? 0) >= 18 ||
      (lluviaMm ?? 0) >= 1 ||
      (probLluviaMax ?? 0) >= 55;
  bool get estresHidrico =>
      (et0Mm ?? 0) >= 4.5 || (deficitVaporMax ?? 0) >= 1.6;
  bool get vueloAbejasLimitado =>
      (tempMax ?? 99) < 14 ||
      (vientoMaxKmh ?? 0) >= 25 ||
      (lluviaMm ?? 0) >= 1.5;
}

class ServicioMeteoAgro {
  static const _endpoint = 'https://api.open-meteo.com/v1/forecast';

  Future<PrevisionAgro> obtener({
    required double latitud,
    required double longitud,
  }) async {
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'latitude': latitud.toStringAsFixed(5),
        'longitude': longitud.toStringAsFixed(5),
        'timezone': 'auto',
        'forecast_days': '7',
        'daily': [
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_sum',
          'precipitation_probability_max',
          'wind_speed_10m_max',
          'wind_gusts_10m_max',
          'et0_fao_evapotranspiration',
        ].join(','),
        'hourly': [
          'relative_humidity_2m',
          'vapour_pressure_deficit',
          'soil_temperature_6cm',
          'soil_moisture_3_to_9cm',
        ].join(','),
        'wind_speed_unit': 'kmh',
        'precipitation_unit': 'mm',
      },
    );

    final respuesta = await http.get(uri).timeout(const Duration(seconds: 10));
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw EstadoMeteoException('Respuesta meteo ${respuesta.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>? ?? const {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? const {};
    final fechas = _lista<String>(daily['time']);
    final dias = <DiaMeteoAgro>[];
    for (var i = 0; i < fechas.length; i++) {
      final fecha = DateTime.parse(fechas[i]);
      final rangoHorario = _indicesDeDia(hourly['time'], fechas[i]);
      dias.add(
        DiaMeteoAgro(
          fecha: fecha,
          tempMax: _numEn(daily['temperature_2m_max'], i),
          tempMin: _numEn(daily['temperature_2m_min'], i),
          lluviaMm: _numEn(daily['precipitation_sum'], i),
          probLluviaMax: _numEn(daily['precipitation_probability_max'], i),
          vientoMaxKmh: _numEn(daily['wind_speed_10m_max'], i),
          rachaMaxKmh: _numEn(daily['wind_gusts_10m_max'], i),
          et0Mm: _numEn(daily['et0_fao_evapotranspiration'], i),
          humedadMedia: _media(hourly['relative_humidity_2m'], rangoHorario),
          deficitVaporMax: _maximo(
            hourly['vapour_pressure_deficit'],
            rangoHorario,
          ),
          sueloTemp6cmMedia: _media(
            hourly['soil_temperature_6cm'],
            rangoHorario,
          ),
          sueloHumedad3a9Media: _media(
            hourly['soil_moisture_3_to_9cm'],
            rangoHorario,
          ),
        ),
      );
    }

    return PrevisionAgro(
      latitud: latitud,
      longitud: longitud,
      dias: dias,
      actualizado: DateTime.now(),
    );
  }

  List<int> _indicesDeDia(Object? tiempos, String diaIso) {
    final lista = _lista<String>(tiempos);
    final indices = <int>[];
    for (var i = 0; i < lista.length; i++) {
      if (lista[i].startsWith(diaIso)) indices.add(i);
    }
    return indices;
  }

  static List<T> _lista<T>(Object? valor) {
    if (valor is List) return valor.whereType<T>().toList();
    return const [];
  }

  static double? _numEn(Object? valor, int indice) {
    if (valor is! List || indice < 0 || indice >= valor.length) return null;
    final v = valor[indice];
    return v is num ? v.toDouble() : null;
  }

  static double? _media(Object? valor, List<int> indices) {
    if (valor is! List || indices.isEmpty) return null;
    var suma = 0.0;
    var n = 0;
    for (final i in indices) {
      if (i >= 0 && i < valor.length && valor[i] is num) {
        suma += (valor[i] as num).toDouble();
        n++;
      }
    }
    return n == 0 ? null : suma / n;
  }

  static double? _maximo(Object? valor, List<int> indices) {
    if (valor is! List || indices.isEmpty) return null;
    double? maximo;
    for (final i in indices) {
      if (i >= 0 && i < valor.length && valor[i] is num) {
        final v = (valor[i] as num).toDouble();
        maximo = maximo == null || v > maximo ? v : maximo;
      }
    }
    return maximo;
  }
}

class EstadoMeteoException implements Exception {
  final String mensaje;
  const EstadoMeteoException(this.mensaje);

  @override
  String toString() => mensaje;
}
