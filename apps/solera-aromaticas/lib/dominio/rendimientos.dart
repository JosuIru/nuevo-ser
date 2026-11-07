// Rendimientos de secado y destilación. Lógica pura, sin Flutter.
//
// Son lo que decide si la campaña sale a cuenta, así que se calculan
// siempre igual en pantalla, en el libro de destilación y en los tests.

import '../modelos/destilacion.dart';
import '../modelos/secado.dart';

/// kg secos por cada 100 kg frescos; null si no hay kg frescos.
double? rendimientoSecadoPorcentaje(double kgFrescos, double kgSecos) =>
    kgFrescos <= 0 || kgSecos < 0 ? null : kgSecos / kgFrescos * 100;

/// Rendimiento en aceite esencial en % volumen/peso: ml de aceite por cada
/// 100 g de planta (1 kg = 1000 g ⇒ ml / (kg · 10)). Es la unidad en la que
/// suelen darse los rendimientos orientativos. Null si no hay planta.
double? rendimientoAceitePorcentaje(double kgPlanta, double mlAceite) =>
    kgPlanta <= 0 || mlAceite < 0 ? null : mlAceite / (kgPlanta * 10);

/// Litros de hidrolato por kg de planta; null si no hay planta.
double? hidrolatoPorKg(double kgPlanta, double litrosHidrolato) =>
    kgPlanta <= 0 || litrosHidrolato < 0 ? null : litrosHidrolato / kgPlanta;

extension RendimientoSecado on Secado {
  double? get rendimientoPorcentaje =>
      rendimientoSecadoPorcentaje(kgFrescos, kgSecos);
}

extension RendimientoDestilacion on Destilacion {
  double? get rendimientoAceite =>
      rendimientoAceitePorcentaje(kgPlanta, mlAceiteEsencial);
  double? get hidrolatoLitrosPorKg => hidrolatoPorKg(kgPlanta, litrosHidrolato);
}

/// Cómo queda un rendimiento frente al intervalo orientativo del catálogo.
enum ComparacionRendimiento { sinReferencia, porDebajo, dentro, porEncima }

/// Compara [valor] con [minimo]–[maximo] (de `rendimientos_orientativos.csv`).
/// Sin valor o sin intervalo completo, [ComparacionRendimiento.sinReferencia].
/// Es una orientación: la variedad, el clima y el alambique lo cambian mucho.
ComparacionRendimiento compararConOrientativo(
    double? valor, double? minimo, double? maximo) {
  if (valor == null || minimo == null || maximo == null || minimo > maximo) {
    return ComparacionRendimiento.sinReferencia;
  }
  if (valor < minimo) return ComparacionRendimiento.porDebajo;
  if (valor > maximo) return ComparacionRendimiento.porEncima;
  return ComparacionRendimiento.dentro;
}

/// Totales de destilación de una especie en un periodo.
class ResumenDestilacionEspecie {
  ResumenDestilacionEspecie(this.especieId);

  final String especieId;
  int numeroDestilaciones = 0;
  double kgPlanta = 0;
  double mlAceite = 0;
  double litrosHidrolato = 0;
  double horas = 0;

  /// Rendimiento medio ponderado por los kg (no la media de los porcentajes).
  double? get rendimientoAceiteMedio =>
      rendimientoAceitePorcentaje(kgPlanta, mlAceite);
  double? get hidrolatoMedioPorKg => hidrolatoPorKg(kgPlanta, litrosHidrolato);
}

/// Agrupa por especie y estado de la planta (fresca y seca no se mezclan:
/// sus rendimientos no son comparables). Clave «especie|estado».
Map<String, ResumenDestilacionEspecie> resumirDestilaciones(
    Iterable<Destilacion> destilaciones) {
  final resumen = <String, ResumenDestilacionEspecie>{};
  for (final destilacion in destilaciones) {
    final clave = '${destilacion.especieId}|${destilacion.estadoPlanta}';
    final total = resumen.putIfAbsent(
        clave, () => ResumenDestilacionEspecie(destilacion.especieId));
    total
      ..numeroDestilaciones += 1
      ..kgPlanta += destilacion.kgPlanta
      ..mlAceite += destilacion.mlAceiteEsencial
      ..litrosHidrolato += destilacion.litrosHidrolato
      ..horas += destilacion.horas ?? 0;
  }
  return resumen;
}
