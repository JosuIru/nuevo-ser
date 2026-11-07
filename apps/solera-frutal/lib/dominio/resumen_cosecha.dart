import '../modelos/cosecha.dart';
import '../modelos/tratamiento.dart';

/// Totales de una parcela en una campaña (parte de cosecha).
class ResumenCosechaParcela {
  ResumenCosechaParcela({required this.parcelaId, required this.campania});

  final int parcelaId;
  final int campania;
  int entregas = 0;
  double kgCascara = 0;

  /// Kilos de grano de las entregas con rendimiento conocido.
  double kgGrano = 0;

  /// Kilos en cáscara de esas mismas entregas (base del rendimiento medio).
  double kgCascaraConRendimiento = 0;
  double _humedadPorKilos = 0;
  double _kilosConHumedad = 0;

  /// Rendimiento medio ponderado por kilos, en %; null sin datos.
  double? get rendimientoMedioPorcentaje => kgCascaraConRendimiento <= 0
      ? null
      : kgGrano / kgCascaraConRendimiento * 100;

  /// Humedad media ponderada por kilos, en %; null sin datos.
  double? get humedadMediaPorcentaje =>
      _kilosConHumedad <= 0 ? null : _humedadPorKilos / _kilosConHumedad;

  /// Kilos en cáscara por hectárea; null sin superficie.
  double? kgCascaraPorHectarea(double superficieHa) =>
      superficieHa <= 0 ? null : kgCascara / superficieHa;

  void _sumar(Cosecha cosecha) {
    entregas++;
    kgCascara += cosecha.kgCascara;
    final grano = cosecha.kgGrano;
    if (grano != null) {
      kgGrano += grano;
      kgCascaraConRendimiento += cosecha.kgCascara;
    }
    final humedad = cosecha.humedadPorcentaje;
    if (humedad != null) {
      _humedadPorKilos += humedad * cosecha.kgCascara;
      _kilosConHumedad += cosecha.kgCascara;
    }
  }

  /// Agrupa por parcela y campaña, en el orden en que aparecen.
  static List<ResumenCosechaParcela> calcular(Iterable<Cosecha> cosechas) {
    final porClave = <(int, int), ResumenCosechaParcela>{};
    for (final cosecha in cosechas) {
      porClave.putIfAbsent(
          (cosecha.parcelaId, cosecha.campania),
          () => ResumenCosechaParcela(
              parcelaId: cosecha.parcelaId,
              campania: cosecha.campania))._sumar(cosecha);
    }
    return porClave.values.toList();
  }
}

/// Tratamientos de [parcelaId] cuyo plazo de seguridad apuntado aún no ha
/// terminado en [fecha]: cosechar ese día sería dentro del plazo.
List<Tratamiento> tratamientosConPlazoAbierto(
  Iterable<Tratamiento> tratamientos, {
  required int parcelaId,
  required DateTime fecha,
}) =>
    tratamientos.where((tratamiento) {
      final fin = tratamiento.finPlazoSeguridad;
      return tratamiento.parcelaId == parcelaId &&
          fin != null &&
          tratamiento.fechaMs <= fecha.millisecondsSinceEpoch &&
          fin.isAfter(fecha);
    }).toList();
