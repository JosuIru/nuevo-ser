import '../modelos/actuacion_plan.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/ejecucion.dart';

/// Situación de una actuación del plan.
enum EstadoActuacion { pendiente, enCurso, ejecutada, atrasada, cancelada }

/// Estado de [actuacion] con sus [ejecuciones] en el año [anyoActual]:
/// - cancelada si la junta la descartó;
/// - ejecutada si alguna ejecución suya está completa;
/// - en curso si solo hay ejecuciones parciales;
/// - atrasada si su año ya pasó sin ejecutarse;
/// - pendiente en el resto.
EstadoActuacion estadoActuacion(
    ActuacionPlan actuacion, List<Ejecucion> ejecuciones, int anyoActual) {
  if (actuacion.cancelada) return EstadoActuacion.cancelada;
  final suyas = ejecuciones
      .where((ejecucion) => ejecucion.actuacionPlanId == actuacion.id)
      .toList();
  if (suyas.any((ejecucion) => ejecucion.completa)) {
    return EstadoActuacion.ejecutada;
  }
  if (suyas.isNotEmpty) return EstadoActuacion.enCurso;
  if (actuacion.anyoPrevisto < anyoActual) return EstadoActuacion.atrasada;
  return EstadoActuacion.pendiente;
}

/// Previsto frente a ejecutado de un año del plan.
class ResumenAnyoPlan {
  const ResumenAnyoPlan({
    required this.anyo,
    required this.previstas,
    required this.ejecutadas,
    required this.enCurso,
    required this.atrasadas,
    required this.canceladas,
    required this.superficiePrevistaHa,
    required this.superficieEjecutadaHa,
  });

  final int anyo;

  /// Actuaciones previstas (sin las canceladas).
  final int previstas;
  final int ejecutadas;
  final int enCurso;
  final int atrasadas;
  final int canceladas;
  final double superficiePrevistaHa;

  /// Superficie de las ejecuciones de las actuaciones de ese año.
  final double superficieEjecutadaHa;

  /// Ejecutadas / previstas (0-1); null sin previstas.
  double? get grado => previstas == 0 ? null : ejecutadas / previstas;
}

/// Un resumen por año previsto, ordenado por año.
List<ResumenAnyoPlan> resumenPlanPorAnyo(List<ActuacionPlan> actuaciones,
    List<Ejecucion> ejecuciones, int anyoActual) {
  final anyos = actuaciones.map((a) => a.anyoPrevisto).toSet().toList()..sort();
  return [
    for (final anyo in anyos)
      () {
        final delAnyo =
            actuaciones.where((a) => a.anyoPrevisto == anyo).toList();
        final estados = {
          for (final actuacion in delAnyo)
            actuacion: estadoActuacion(actuacion, ejecuciones, anyoActual)
        };
        int contar(EstadoActuacion estado) =>
            estados.values.where((e) => e == estado).length;
        final vivas = delAnyo.where((a) => !a.cancelada).toList();
        final idsVivas = vivas.map((a) => a.id).toSet();
        return ResumenAnyoPlan(
          anyo: anyo,
          previstas: vivas.length,
          ejecutadas: contar(EstadoActuacion.ejecutada),
          enCurso: contar(EstadoActuacion.enCurso),
          atrasadas: contar(EstadoActuacion.atrasada),
          canceladas: contar(EstadoActuacion.cancelada),
          superficiePrevistaHa: vivas.fold(
              0.0, (suma, a) => suma + (a.superficiePrevistaHa ?? 0)),
          superficieEjecutadaHa: ejecuciones
              .where((e) =>
                  e.actuacionPlanId != null &&
                  idsVivas.contains(e.actuacionPlanId))
              .fold(0.0, (suma, e) => suma + (e.superficieHa ?? 0)),
        );
      }(),
  ];
}

/// Ejecuciones que no responden a ninguna actuación del plan.
List<Ejecucion> ejecucionesNoPrevistas(List<Ejecucion> ejecuciones) =>
    ejecuciones.where((e) => e.actuacionPlanId == null).toList();

/// Volumen en m³ de un aprovechamiento maderable o leñoso; null si su
/// unidad no es de volumen (toneladas, kg…) o no es maderable ni leñoso.
/// [m3PorEstereo] es la conversión orientativa del catálogo de unidades.
double? volumenM3(Aprovechamiento aprovechamiento,
    {required double m3PorEstereo, bool usarPrevisto = false}) {
  if (!aprovechamiento.esMaderableOLenoso) return null;
  final cantidad = usarPrevisto
      ? aprovechamiento.cantidadPrevista
      : aprovechamiento.cantidad;
  if (cantidad == null) return null;
  return switch (aprovechamiento.unidad) {
    'm3' => cantidad,
    'estereos' => cantidad * m3PorEstereo,
    _ => null,
  };
}

/// Volumen previsto en el plan frente a lo aprovechado en una campaña.
class ComparacionVolumen {
  const ComparacionVolumen({
    required this.campanya,
    required this.previstoPlanM3,
    required this.aprovechadoM3,
    required this.aprovechamientosSinVolumen,
  });

  final int campanya;

  /// Suma del volumen previsto de las actuaciones (no canceladas) del año.
  final double previstoPlanM3;

  /// Madera, leña y biomasa obtenidas en la campaña, pasadas a m³.
  final double aprovechadoM3;

  /// Maderables o leñosos que no se pueden pasar a m³ (en t o kg).
  final int aprovechamientosSinVolumen;

  /// aprovechado − previsto (positivo: se sacó más de lo previsto).
  double get diferenciaM3 => aprovechadoM3 - previstoPlanM3;

  /// aprovechado / previsto; null sin previsto.
  double? get proporcion =>
      previstoPlanM3 <= 0 ? null : aprovechadoM3 / previstoPlanM3;
}

ComparacionVolumen compararVolumen(
  int campanya, {
  required List<ActuacionPlan> actuaciones,
  required List<Aprovechamiento> aprovechamientos,
  required double m3PorEstereo,
}) {
  final previsto = actuaciones
      .where((a) => a.anyoPrevisto == campanya && !a.cancelada)
      .fold(0.0, (suma, a) => suma + (a.volumenPrevistoM3 ?? 0));
  var aprovechado = 0.0;
  var sinVolumen = 0;
  for (final aprovechamiento
      in aprovechamientos.where((a) => a.campanya == campanya)) {
    if (!aprovechamiento.esMaderableOLenoso) continue;
    final volumen = volumenM3(aprovechamiento, m3PorEstereo: m3PorEstereo);
    if (volumen == null) {
      sinVolumen++;
    } else {
      aprovechado += volumen;
    }
  }
  return ComparacionVolumen(
    campanya: campanya,
    previstoPlanM3: previsto,
    aprovechadoM3: aprovechado,
    aprovechamientosSinVolumen: sinVolumen,
  );
}
