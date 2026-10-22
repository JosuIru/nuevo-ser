import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show EstadoMeteoException;

class PrevisionAceitera {
  final double latitud;
  final double longitud;
  final List<DiaMeteoOlivar> dias;
  final DateTime actualizado;

  const PrevisionAceitera({
    required this.latitud,
    required this.longitud,
    required this.dias,
    required this.actualizado,
  });

  DiaMeteoOlivar? get hoy => dias.isEmpty ? null : dias.first;
}

class DiaMeteoOlivar {
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

  const DiaMeteoOlivar({
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

  /// Helada con riesgo agronómico para olivar (≤-1 °C es ya daño en
  /// olivos jóvenes; <-7 °C provoca daño grave en adultos). Aviso
  /// preventivo desde 0 °C.
  bool get riesgoHelada => (tempMin ?? 99) <= 0;

  /// Día poco favorable para fitosanitarios. El umbral de viento es
  /// más estricto que la media porque el olivar suele tratarse con
  /// turboatomizador y la deriva sobre carretera/cultivos vecinos
  /// genera responsabilidad legal.
  bool get malDiaTratamiento =>
      (vientoMaxKmh ?? 0) >= 18 ||
      (lluviaMm ?? 0) >= 1 ||
      (probLluviaMax ?? 0) >= 55;

  /// Demanda hídrica alta — relevante sobre todo para olivar
  /// superintensivo o tradicional con riego de apoyo en goteo.
  bool get estresHidrico =>
      (et0Mm ?? 0) >= 5 || (deficitVaporMax ?? 0) >= 1.8;

  /// Ventana óptima para vuelos de mosca del olivo (Bactrocera oleae):
  /// el adulto está activo con temp media 22-30 °C y humedad
  /// relativa >60 %. Aviso pensado para julio-octubre cuando la
  /// aceituna ya es susceptible al picado.
  bool get vueloMoscaOlivoActivo {
    final tempMedia = ((tempMin ?? 0) + (tempMax ?? 0)) / 2;
    final mes = fecha.month;
    return mes >= 6 &&
        mes <= 11 &&
        tempMedia >= 22 &&
        tempMedia <= 32 &&
        (humedadMedia ?? 0) >= 60;
  }

  /// Golpe de calor en aceituna: temp máxima ≥38 °C en envero
  /// (típicamente julio-septiembre) provoca arrugado, mancha jabonosa
  /// y caída de fruto.
  bool get golpeCalorAceituna {
    final mes = fecha.month;
    return mes >= 7 && mes <= 9 && (tempMax ?? 0) >= 38;
  }

  /// Floración con humedad alta — si está lloviendo o hay >85 % HR
  /// durante mayo-junio el cuajado se ve perjudicado.
  bool get floracionEnRiesgo {
    final mes = fecha.month;
    return mes >= 4 &&
        mes <= 6 &&
        ((humedadMedia ?? 0) >= 85 || (lluviaMm ?? 0) >= 5);
  }

  /// Buen día para recolección manual o mecanizada — sin lluvia,
  /// viento moderado y temperatura razonable.
  bool get buenDiaRecoleccion =>
      (lluviaMm ?? 0) < 0.5 &&
      (vientoMaxKmh ?? 0) < 35 &&
      (tempMax ?? 0) >= 5;
}

class ServicioMeteoAceitera {
  static const _endpoint = 'https://api.open-meteo.com/v1/forecast';

  Future<PrevisionAceitera> obtener({
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
    final dias = <DiaMeteoOlivar>[];
    for (var i = 0; i < fechas.length; i++) {
      final fecha = DateTime.parse(fechas[i]);
      final rangoHorario = _indicesDeDia(hourly['time'], fechas[i]);
      dias.add(
        DiaMeteoOlivar(
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

    return PrevisionAceitera(
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
