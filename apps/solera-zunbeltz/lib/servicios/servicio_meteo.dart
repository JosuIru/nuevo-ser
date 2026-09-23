import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Previsión meteorológica sobre una finca, vía Open-Meteo (gratuito, sin
/// clave de API): condiciones actuales, próximas horas, 7 días de previsión
/// y la lluvia de los 7 días anteriores. Los avisos son meteorológicos y
/// orientativos: no sustituyen el criterio del ganadero ni del veterinario.
class PrevisionMeteo {
  const PrevisionMeteo({
    required this.latitud,
    required this.longitud,
    required this.actualizado,
    required this.todosLosDias,
    required this.horas,
    this.altitudM,
    this.actual,
  });

  /// Construye la previsión a partir de la respuesta JSON de Open-Meteo
  /// (la misma que se guarda en caché).
  factory PrevisionMeteo.desdeJson(
    Map<String, dynamic> json, {
    required DateTime actualizado,
  }) {
    final diario = json['daily'] as Map<String, dynamic>? ?? const {};
    final horario = json['hourly'] as Map<String, dynamic>? ?? const {};

    final horas = <HoraMeteo>[];
    final tiemposHorarios = _lista<String>(horario['time']);
    for (var i = 0; i < tiemposHorarios.length; i++) {
      horas.add(HoraMeteo(
        hora: DateTime.parse(tiemposHorarios[i]),
        temperatura: _numEn(horario['temperature_2m'], i),
        humedad: _numEn(horario['relative_humidity_2m'], i),
        probLluvia: _numEn(horario['precipitation_probability'], i),
        lluviaMm: _numEn(horario['precipitation'], i),
        codigoTiempo: _numEn(horario['weather_code'], i)?.round(),
        vientoKmh: _numEn(horario['wind_speed_10m'], i),
        rachaKmh: _numEn(horario['wind_gusts_10m'], i),
      ));
    }

    final dias = <DiaMeteo>[];
    final fechas = _lista<String>(diario['time']);
    for (var i = 0; i < fechas.length; i++) {
      final fecha = DateTime.parse(fechas[i]);
      final horasDelDia =
          horas.where((h) => _mismoDia(h.hora, fecha)).toList(growable: false);
      dias.add(DiaMeteo(
        fecha: fecha,
        codigoTiempo: _numEn(diario['weather_code'], i)?.round(),
        tempMax: _numEn(diario['temperature_2m_max'], i),
        tempMin: _numEn(diario['temperature_2m_min'], i),
        sensacionMin: _numEn(diario['apparent_temperature_min'], i),
        lluviaMm: _numEn(diario['precipitation_sum'], i),
        horasLluvia: _numEn(diario['precipitation_hours'], i),
        probLluviaMax: _numEn(diario['precipitation_probability_max'], i),
        nieveCm: _numEn(diario['snowfall_sum'], i),
        vientoMaxKmh: _numEn(diario['wind_speed_10m_max'], i),
        rachaMaxKmh: _numEn(diario['wind_gusts_10m_max'], i),
        direccionVientoGrados:
            _numEn(diario['wind_direction_10m_dominant'], i),
        amanecer: _fechaEn(diario['sunrise'], i),
        anochecer: _fechaEn(diario['sunset'], i),
        uvMax: _numEn(diario['uv_index_max'], i),
        evapotranspiracionMm: _numEn(diario['et0_fao_evapotranspiration'], i),
        humedadMedia: _media(horasDelDia.map((h) => h.humedad)),
        thiMax: _maximo(horasDelDia.map((h) => h.thi)),
      ));
    }

    final actualJson = json['current'] as Map<String, dynamic>?;
    return PrevisionMeteo(
      latitud: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitud: (json['longitude'] as num?)?.toDouble() ?? 0,
      altitudM: (json['elevation'] as num?)?.toDouble(),
      actualizado: actualizado,
      todosLosDias: dias,
      horas: horas,
      actual: actualJson == null ? null : CondicionActual._desdeJson(actualJson),
    );
  }

  final double latitud;
  final double longitud;

  /// Altitud del punto de la rejilla del modelo, en metros.
  final double? altitudM;
  final DateTime actualizado;
  final CondicionActual? actual;

  /// Días pasados (hasta 7) y futuros, en orden.
  final List<DiaMeteo> todosLosDias;
  final List<HoraMeteo> horas;

  /// Días de hoy en adelante.
  List<DiaMeteo> diasDesde(DateTime ahora) => todosLosDias
      .where((d) => !d.fecha.isBefore(_soloFecha(ahora)))
      .toList(growable: false);

  /// Las próximas [cuantas] horas a partir de la hora en curso.
  List<HoraMeteo> proximasHoras(DateTime ahora, {int cuantas = 24}) {
    final horaEnCurso = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour);
    return horas
        .where((h) => !h.hora.isBefore(horaEnCurso))
        .take(cuantas)
        .toList(growable: false);
  }

  /// Lluvia caída en los [dias] días anteriores a hoy. `null` si la
  /// respuesta no trae días pasados.
  double? lluviaDiasAnteriores(DateTime ahora, {int dias = 7}) {
    final hoy = _soloFecha(ahora);
    final desde = hoy.subtract(Duration(days: dias));
    final pasados = todosLosDias.where(
        (d) => d.fecha.isBefore(hoy) && !d.fecha.isBefore(desde));
    if (pasados.isEmpty) return null;
    return pasados.fold<double>(0, (suma, d) => suma + (d.lluviaMm ?? 0));
  }

  /// Lluvia prevista de hoy en adelante.
  double lluviaPrevista(DateTime ahora) =>
      diasDesde(ahora).fold<double>(0, (suma, d) => suma + (d.lluviaMm ?? 0));

  /// Evapotranspiración de referencia prevista de hoy en adelante: el agua
  /// que pierden suelo y pasto. Si supera a la lluvia, el pasto se seca.
  double evapotranspiracionPrevista(DateTime ahora) => diasDesde(ahora)
      .fold<double>(0, (suma, d) => suma + (d.evapotranspiracionMm ?? 0));
}

class CondicionActual {
  const CondicionActual({
    this.temperatura,
    this.sensacion,
    this.humedad,
    this.lluviaMm,
    this.codigoTiempo,
    this.vientoKmh,
    this.rachaKmh,
    this.direccionVientoGrados,
    this.esDeDia = true,
  });

  factory CondicionActual._desdeJson(Map<String, dynamic> json) {
    double? n(String clave) => (json[clave] as num?)?.toDouble();
    return CondicionActual(
      temperatura: n('temperature_2m'),
      sensacion: n('apparent_temperature'),
      humedad: n('relative_humidity_2m'),
      lluviaMm: n('precipitation'),
      codigoTiempo: n('weather_code')?.round(),
      vientoKmh: n('wind_speed_10m'),
      rachaKmh: n('wind_gusts_10m'),
      direccionVientoGrados: n('wind_direction_10m'),
      esDeDia: (json['is_day'] as num?) != 0,
    );
  }

  final double? temperatura;
  final double? sensacion;
  final double? humedad;
  final double? lluviaMm;
  final int? codigoTiempo;
  final double? vientoKmh;
  final double? rachaKmh;
  final double? direccionVientoGrados;
  final bool esDeDia;
}

class HoraMeteo {
  const HoraMeteo({
    required this.hora,
    this.temperatura,
    this.humedad,
    this.probLluvia,
    this.lluviaMm,
    this.codigoTiempo,
    this.vientoKmh,
    this.rachaKmh,
  });

  final DateTime hora;
  final double? temperatura;
  final double? humedad;
  final double? probLluvia;
  final double? lluviaMm;
  final int? codigoTiempo;
  final double? vientoKmh;
  final double? rachaKmh;

  double? get thi => (temperatura == null || humedad == null)
      ? null
      : indiceTemperaturaHumedad(temperatura!, humedad!);
}

class DiaMeteo {
  const DiaMeteo({
    required this.fecha,
    this.codigoTiempo,
    this.tempMin,
    this.tempMax,
    this.sensacionMin,
    this.lluviaMm,
    this.horasLluvia,
    this.probLluviaMax,
    this.nieveCm,
    this.vientoMaxKmh,
    this.rachaMaxKmh,
    this.direccionVientoGrados,
    this.amanecer,
    this.anochecer,
    this.uvMax,
    this.evapotranspiracionMm,
    this.humedadMedia,
    this.thiMax,
  });

  final DateTime fecha;
  final int? codigoTiempo;
  final double? tempMin;
  final double? tempMax;
  final double? sensacionMin;
  final double? lluviaMm;
  final double? horasLluvia;
  final double? probLluviaMax;
  final double? nieveCm;
  final double? vientoMaxKmh;
  final double? rachaMaxKmh;
  final double? direccionVientoGrados;
  final DateTime? amanecer;
  final DateTime? anochecer;
  final double? uvMax;
  final double? evapotranspiracionMm;
  final double? humedadMedia;

  /// Máximo horario del índice temperatura-humedad (ver
  /// [indiceTemperaturaHumedad]).
  final double? thiMax;

  Duration? get horasDeLuz => (amanecer == null || anochecer == null)
      ? null
      : anochecer!.difference(amanecer!);

  /// Riesgo de helada (aviso preventivo desde 0 °C): frío para el ganado
  /// en extensivo y para los abrevaderos/tuberías.
  bool get riesgoHelada => (tempMin ?? 99) <= 0;

  /// Lluvia relevante: dificulta el manejo, el desbroce y los traslados.
  bool get lluviaRelevante =>
      (lluviaMm ?? 0) >= 5 || (probLluviaMax ?? 0) >= 60;

  /// Viento fuerte: revisar cierres y refugios; cuidado con quemas.
  bool get vientoFuerte => (rachaMaxKmh ?? 0) >= 50;

  /// Calor intenso: vigilar sombra y agua para el ganado.
  bool get calorIntenso => (tempMax ?? 0) >= 34;

  /// Nieve prevista: accesos, agua helada y forraje de apoyo.
  bool get nieve => (nieveCm ?? 0) > 0;

  /// Tormenta (códigos WMO 95-99): riesgo de rayo para el ganado en monte
  /// abierto y para quien trabaja en él.
  bool get tormenta => (codigoTiempo ?? 0) >= 95;

  /// Estrés por calor según el índice temperatura-humedad. Umbral de
  /// «alerta» (75) del Livestock Weather Safety Index (LCI, 1970), pensado
  /// para ganado en general y no el 72 del vacuno lechero: **orientativo y
  /// PROVISIONAL** hasta que el veterinario asesor fije el de vacuno de carne
  /// y ovino en extensivo (ver BLOQUEOS-PENDIENTES).
  bool get estresCalor => (thiMax ?? 0) >= umbralThiEstresCalor;

  /// Día favorable para trabajos de campo (manejo, esquileo, desbroce):
  /// sin lluvia, nieve ni tormenta, viento moderado y temperatura razonable.
  bool get buenDiaManejo =>
      (lluviaMm ?? 0) < 1 &&
      !nieve &&
      !tormenta &&
      !estresCalor &&
      (rachaMaxKmh ?? 0) < 35 &&
      (tempMax ?? 0) >= 5 &&
      (tempMax ?? 0) <= 32;
}

/// Umbral de estrés por calor del THI (ver [DiaMeteo.estresCalor]).
const double umbralThiEstresCalor = 75;

/// Índice temperatura-humedad (THI) en la fórmula del NRC (1971), con la
/// temperatura en °C y la humedad relativa en %.
double indiceTemperaturaHumedad(double temperaturaC, double humedadRelativa) {
  final temperaturaF = 1.8 * temperaturaC + 32;
  return temperaturaF -
      (0.55 - 0.0055 * humedadRelativa) * (1.8 * temperaturaC - 26);
}

/// Resultado de pedir la previsión: si no hubo conexión, la última guardada.
typedef ResultadoMeteo = ({PrevisionMeteo prevision, bool desdeCache});

class ServicioMeteo {
  ServicioMeteo({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  static const _endpoint = 'https://api.open-meteo.com/v1/forecast';
  static const _prefijoCache = 'zunbeltz.meteo.';

  static const _variablesActuales = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'is_day',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'wind_direction_10m',
    'wind_gusts_10m',
  ];
  static const _variablesDiarias = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'apparent_temperature_min',
    'precipitation_sum',
    'precipitation_hours',
    'precipitation_probability_max',
    'snowfall_sum',
    'wind_speed_10m_max',
    'wind_gusts_10m_max',
    'wind_direction_10m_dominant',
    'sunrise',
    'sunset',
    'uv_index_max',
    'et0_fao_evapotranspiration',
  ];
  static const _variablesHorarias = [
    'temperature_2m',
    'relative_humidity_2m',
    'precipitation_probability',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'wind_gusts_10m',
  ];

  /// Pide la previsión y la guarda. Sin conexión devuelve la última guardada
  /// para ese punto; si tampoco hay, lanza [MeteoException].
  Future<ResultadoMeteo> obtener({
    required double latitud,
    required double longitud,
  }) async {
    final claveCache =
        '$_prefijoCache${latitud.toStringAsFixed(3)},${longitud.toStringAsFixed(3)}';
    try {
      final cuerpo = await _descargar(latitud, longitud);
      final ahora = DateTime.now();
      final prevision = PrevisionMeteo.desdeJson(
          jsonDecode(cuerpo) as Map<String, dynamic>,
          actualizado: ahora);
      await _guardarCache(claveCache, cuerpo, ahora);
      return (prevision: prevision, desdeCache: false);
    } catch (error) {
      final guardada = await _leerCache(claveCache);
      if (guardada == null) {
        throw error is MeteoException ? error : MeteoException('$error');
      }
      return (prevision: guardada, desdeCache: true);
    }
  }

  Future<String> _descargar(double latitud, double longitud) async {
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'latitude': latitud.toStringAsFixed(5),
        'longitude': longitud.toStringAsFixed(5),
        'timezone': 'auto',
        'forecast_days': '7',
        'past_days': '7',
        'current': _variablesActuales.join(','),
        'daily': _variablesDiarias.join(','),
        'hourly': _variablesHorarias.join(','),
        'wind_speed_unit': 'kmh',
        'precipitation_unit': 'mm',
      },
    );
    final respuesta =
        await _cliente.get(uri).timeout(const Duration(seconds: 10));
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw MeteoException('Respuesta meteo ${respuesta.statusCode}');
    }
    return utf8.decode(respuesta.bodyBytes);
  }

  Future<void> _guardarCache(
      String clave, String cuerpo, DateTime actualizado) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(
          clave,
          jsonEncode({
            'actualizadoMs': actualizado.millisecondsSinceEpoch,
            'respuesta': cuerpo,
          }));
    } catch (_) {
      // La caché es una comodidad: si falla, la previsión se muestra igual.
    }
  }

  Future<PrevisionMeteo?> _leerCache(String clave) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final guardado = preferencias.getString(clave);
      if (guardado == null) return null;
      final datos = jsonDecode(guardado) as Map<String, dynamic>;
      return PrevisionMeteo.desdeJson(
        jsonDecode(datos['respuesta'] as String) as Map<String, dynamic>,
        actualizado: DateTime.fromMillisecondsSinceEpoch(
            datos['actualizadoMs'] as int),
      );
    } catch (_) {
      return null;
    }
  }
}

class MeteoException implements Exception {
  const MeteoException(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

DateTime _soloFecha(DateTime momento) =>
    DateTime(momento.year, momento.month, momento.day);

bool _mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<T> _lista<T>(Object? valor) {
  if (valor is List) return valor.whereType<T>().toList();
  return const [];
}

double? _numEn(Object? valor, int indice) {
  if (valor is! List || indice < 0 || indice >= valor.length) return null;
  final elemento = valor[indice];
  return elemento is num ? elemento.toDouble() : null;
}

DateTime? _fechaEn(Object? valor, int indice) {
  if (valor is! List || indice < 0 || indice >= valor.length) return null;
  final elemento = valor[indice];
  return elemento is String ? DateTime.tryParse(elemento) : null;
}

double? _media(Iterable<double?> valores) {
  final presentes = valores.whereType<double>().toList();
  if (presentes.isEmpty) return null;
  return presentes.reduce((a, b) => a + b) / presentes.length;
}

double? _maximo(Iterable<double?> valores) {
  final presentes = valores.whereType<double>();
  return presentes.isEmpty ? null : presentes.reduce(math.max);
}
