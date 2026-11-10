// Avisos del tiempo para la pantalla Hoy: helada, calor y días sin lluvia.
// Lógica pura, sin Flutter ni red: recibe la previsión ya descargada
// (`ServicioMeteoAgro` del core) y lo que hay plantado. Todo es
// ORIENTATIVO: la previsión es de un modelo y la temperatura es a 2 m.

import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show centroide;

import '../modelos/bancal.dart';
import '../modelos/cultivo.dart';
import '../modelos/parcela.dart';
import '../modelos/siembra.dart';
import 'catalogos.dart';

/// Mínima prevista (°C) a partir de la cual se avisa de helada. Es el mismo
/// umbral que `DiaMeteoAgro.riesgoHelada` del core y que Larrea Frutal: la
/// previsión es a 2 m del suelo y a ras de tierra hace más frío.
const double umbralHeladaC = 2;

/// Máxima prevista (°C) a partir de la cual se avisa de calor.
const double umbralCalorC = 35;

/// Días seguidos por encima de [umbralCalorC] para hablar de «ola de calor».
/// Criterio sencillo de la app, no la definición de AEMET (que depende de
/// la zona).
const int diasSeguidosOlaCalor = 3;

/// Lluvia diaria (mm) por debajo de la cual el día cuenta como «sin lluvia»:
/// menos de 1 mm no llega a la raíz.
const double lluviaUtilMm = 1;

/// Días seguidos sin lluvia en la previsión para recordar el riego.
const int diasSinLluviaAviso = 5;

/// Un día de la previsión con lo que usan los avisos.
typedef DiaPrevisto = ({
  DateTime fecha,
  double? minimaC,
  double? maximaC,
  double? lluviaMm,
});

/// Riesgo de helada en la madrugada de [fecha] (la mínima diaria cae al
/// amanecer). [cultivosSensibles]: nombres de lo que está en tierra fuera
/// de invernadero y el catálogo marca como sensible; vacío si nada.
class AvisoHeladaHuerta {
  const AvisoHeladaHuerta({
    required this.fecha,
    required this.minimaC,
    required this.diasDesdeHoy,
    required this.cultivosSensibles,
  });

  final DateTime fecha;
  final double minimaC;

  /// 0 = esta madrugada, 1 = esta noche (madrugada de mañana), 2+ = más
  /// adelante.
  final int diasDesdeHoy;
  final List<String> cultivosSensibles;
}

class AvisoCalorHuerta {
  const AvisoCalorHuerta({
    required this.fecha,
    required this.maximaC,
    required this.esOla,
  });

  /// Primer día que llega al umbral.
  final DateTime fecha;

  /// La máxima más alta de la previsión.
  final double maximaC;

  /// [diasSeguidosOlaCalor] o más días seguidos por encima del umbral.
  final bool esOla;
}

/// Avisos que salen de una previsión. Cada uno, null si no toca.
class AvisosTiempoHuerta {
  const AvisosTiempoHuerta({this.helada, this.calor, this.diasSinLluvia});

  static const AvisosTiempoHuerta ninguno = AvisosTiempoHuerta();

  final AvisoHeladaHuerta? helada;
  final AvisoCalorHuerta? calor;

  /// Días seguidos sin lluvia desde hoy (solo si llegan a
  /// [diasSinLluviaAviso]).
  final int? diasSinLluvia;

  bool get vacio => helada == null && calor == null && diasSinLluvia == null;
}

/// Lugar al que se pide la previsión: el punto de la parcela o, si solo
/// tiene área, su centro. Primero las parcelas con algo plantado.
LatLng? ubicacionParaElTiempo({
  required Iterable<Parcela> parcelas,
  Set<int> parcelasConSiembras = const {},
}) {
  final ordenadas = [
    ...parcelas.where((parcela) => parcelasConSiembras.contains(parcela.id)),
    ...parcelas.where((parcela) => !parcelasConSiembras.contains(parcela.id)),
  ];
  for (final parcela in ordenadas) {
    if (parcela.tieneUbicacion) {
      return LatLng(parcela.latitud!, parcela.longitud!);
    }
    final centro = centroide(parcela.vertices);
    if (centro != null) return centro;
  }
  return null;
}

/// Siembras hechas y sin levantar: lo que está en tierra ahora.
Iterable<Siembra> siembrasEnTierra(Iterable<Siembra> siembras) => siembras
    .where((siembra) => siembra.realizada && siembra.fechaLevantadaMs == null);

/// Nombres (sin repetir, en orden de aparición) de lo que está en tierra
/// al aire libre y el catálogo marca como sensible a la helada. Sin dato
/// en el catálogo (o especie libre) no se nombra.
List<String> cultivosSensiblesEnTierra({
  required Iterable<Siembra> siembras,
  required Map<int, Cultivo> cultivos,
  required Map<int, Bancal> bancales,
}) {
  final nombres = <String>[];
  for (final siembra in siembrasEnTierra(siembras)) {
    final bancal = bancales[siembra.bancalId];
    if (bancal == null || bancal.invernadero) continue;
    final cultivo = cultivos[siembra.cultivoId];
    if (cultivo == null) continue;
    if (especiePorId(cultivo.especieId)?.sensibleHelada != true) continue;
    final nombre = nombreEspecie(cultivo.especieId);
    if (!nombres.contains(nombre)) nombres.add(nombre);
  }
  return nombres;
}

/// Cruza la previsión con lo plantado. Sin nada en tierra o sin previsión,
/// ningún aviso. [ahora] decide si la mínima de hoy ya pasó (después de las
/// 6 de la mañana no se avisa de la helada de esta madrugada).
AvisosTiempoHuerta calcularAvisosTiempo({
  required List<DiaPrevisto> prevision,
  required Iterable<Siembra> siembras,
  required Map<int, Cultivo> cultivos,
  required Map<int, Bancal> bancales,
  required DateTime ahora,
}) {
  if (prevision.isEmpty || siembrasEnTierra(siembras).isEmpty) {
    return AvisosTiempoHuerta.ninguno;
  }
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  int diasDesdeHoy(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day).difference(hoy).inHours ~/
      24;
  final futuros = [
    for (final dia in prevision)
      if (diasDesdeHoy(dia.fecha) >= 0) dia,
  ]..sort((a, b) => a.fecha.compareTo(b.fecha));

  AvisoHeladaHuerta? helada;
  for (final dia in futuros) {
    final minima = dia.minimaC;
    final dias = diasDesdeHoy(dia.fecha);
    if (minima == null || minima > umbralHeladaC) continue;
    if (dias == 0 && ahora.hour >= 6) continue;
    helada = AvisoHeladaHuerta(
      fecha: dia.fecha,
      minimaC: minima,
      diasDesdeHoy: dias,
      cultivosSensibles: cultivosSensiblesEnTierra(
          siembras: siembras, cultivos: cultivos, bancales: bancales),
    );
    break;
  }

  AvisoCalorHuerta? calor;
  DateTime? primerDiaCalor;
  double? maximaMasAlta;
  var seguidos = 0;
  var masSeguidos = 0;
  for (final dia in futuros) {
    final maxima = dia.maximaC;
    if (maxima != null && maxima >= umbralCalorC) {
      primerDiaCalor ??= dia.fecha;
      maximaMasAlta = maximaMasAlta == null || maxima > maximaMasAlta
          ? maxima
          : maximaMasAlta;
      seguidos++;
      if (seguidos > masSeguidos) masSeguidos = seguidos;
    } else {
      seguidos = 0;
    }
  }
  if (primerDiaCalor != null) {
    calor = AvisoCalorHuerta(
      fecha: primerDiaCalor,
      maximaC: maximaMasAlta!,
      esOla: masSeguidos >= diasSeguidosOlaCalor,
    );
  }

  // Días seguidos sin lluvia desde hoy; un día sin dato corta la cuenta.
  var sinLluvia = 0;
  for (final dia in futuros) {
    final lluvia = dia.lluviaMm;
    if (lluvia == null || lluvia >= lluviaUtilMm) break;
    sinLluvia++;
  }

  return AvisosTiempoHuerta(
    helada: helada,
    calor: calor,
    diasSinLluvia: sinLluvia >= diasSinLluviaAviso ? sinLluvia : null,
  );
}

/// Momento del recordatorio de una helada: a las 20:00 de la víspera de
/// [fechaHelada]. Null si ya ha pasado (no se programa nada).
DateTime? momentoRecordatorioHelada(DateTime fechaHelada, DateTime ahora) {
  final vispera =
      DateTime(fechaHelada.year, fechaHelada.month, fechaHelada.day - 1, 20);
  return vispera.isAfter(ahora) ? vispera : null;
}
