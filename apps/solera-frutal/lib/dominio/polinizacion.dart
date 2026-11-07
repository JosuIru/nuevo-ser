/// Épocas de floración en orden (la distancia entre dos indica si se
/// solapan). Identificadores del catálogo de variedades.
const List<String> epocasFloracion = [
  'muy_temprana',
  'temprana',
  'media',
  'tardia',
  'muy_tardia',
  'extra_tardia',
];

/// Lo que la lógica de polinización necesita saber de una variedad.
class DatosPolinizacionVariedad {
  const DatosPolinizacionVariedad({
    required this.id,
    required this.especieId,
    required this.autocompatible,
    this.grupoIncompatibilidad = '',
    this.floracion = '',
  });

  final String id;
  final String especieId;

  /// Null si no se sabe.
  final bool? autocompatible;

  /// Grupo de incompatibilidad (alelos S). Dos variedades del mismo grupo
  /// no se polinizan entre sí. Vacío si no se conoce.
  final String grupoIncompatibilidad;

  /// Uno de [epocasFloracion] o vacío.
  final String floracion;
}

enum EstadoPolinizacion {
  /// Se poliniza sola.
  autocompatible,

  /// Hay en la parcela otra variedad compatible que florece a la vez.
  cubierta,

  /// Hay otra variedad que florece a la vez, pero falta saber su grupo.
  porConfirmar,

  /// Necesita polinizadora y no hay ninguna adecuada en la parcela.
  sinPolinizadora,

  /// La variedad no está en el catálogo o le faltan datos.
  desconocida,
}

class ResultadoPolinizacion {
  const ResultadoPolinizacion(this.variedadId, this.estado,
      [this.polinizadoras = const []]);

  final String variedadId;
  final EstadoPolinizacion estado;

  /// Variedades de la parcela que pueden polinizarla (o por confirmar).
  final List<String> polinizadoras;

  bool get necesitaAtencion =>
      estado == EstadoPolinizacion.sinPolinizadora ||
      estado == EstadoPolinizacion.porConfirmar;
}

/// Las floraciones se solapan si están a un paso como mucho.
bool floracionesSolapan(String primera, String segunda) {
  final indicePrimera = epocasFloracion.indexOf(primera);
  final indiceSegunda = epocasFloracion.indexOf(segunda);
  if (indicePrimera < 0 || indiceSegunda < 0) return false;
  return (indicePrimera - indiceSegunda).abs() <= 1;
}

/// Evalúa cada variedad presente en una parcela. Es una **orientación**
/// a partir del catálogo: la compatibilidad real la confirma el vivero o
/// el técnico.
List<ResultadoPolinizacion> evaluarPolinizacion({
  required Iterable<String> variedadesEnParcela,
  required Map<String, DatosPolinizacionVariedad> catalogo,
}) {
  final presentes = variedadesEnParcela
      .map((variedad) => variedad.trim())
      .where((variedad) => variedad.isNotEmpty)
      .toSet()
      .toList();
  final resultados = <ResultadoPolinizacion>[];
  for (final variedadId in presentes) {
    final datos = catalogo[variedadId];
    if (datos == null || datos.autocompatible == null) {
      resultados.add(
          ResultadoPolinizacion(variedadId, EstadoPolinizacion.desconocida));
      continue;
    }
    if (datos.autocompatible!) {
      resultados.add(
          ResultadoPolinizacion(variedadId, EstadoPolinizacion.autocompatible));
      continue;
    }
    final compatibles = <String>[];
    final porConfirmar = <String>[];
    for (final otraId in presentes) {
      if (otraId == variedadId) continue;
      final otra = catalogo[otraId];
      if (otra == null || otra.especieId != datos.especieId) continue;
      if (!floracionesSolapan(datos.floracion, otra.floracion)) continue;
      if (datos.grupoIncompatibilidad.isEmpty ||
          otra.grupoIncompatibilidad.isEmpty) {
        porConfirmar.add(otraId);
      } else if (datos.grupoIncompatibilidad != otra.grupoIncompatibilidad) {
        compatibles.add(otraId);
      }
    }
    if (compatibles.isNotEmpty) {
      resultados.add(ResultadoPolinizacion(
          variedadId, EstadoPolinizacion.cubierta, compatibles));
    } else if (porConfirmar.isNotEmpty) {
      resultados.add(ResultadoPolinizacion(
          variedadId, EstadoPolinizacion.porConfirmar, porConfirmar));
    } else {
      resultados.add(ResultadoPolinizacion(
          variedadId, EstadoPolinizacion.sinPolinizadora));
    }
  }
  return resultados;
}
