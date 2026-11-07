// Rotación de cultivos por familias botánicas en cada bancal. Lógica pura.
//
// Regla: una familia no vuelve al mismo bancal antes de N años (N sale del
// catálogo `rotacion.csv`). Es un **aviso** orientativo: la decisión es de
// quien cultiva y lo que vale ante el certificador es su plan de rotación.

/// Un cultivo que ha estado (o está planificado) en un bancal.
class PasoPorBancal {
  const PasoPorBancal({
    required this.bancalId,
    required this.familiaId,
    required this.fecha,
    this.siembraId,
  });

  final int bancalId;
  final String familiaId;

  /// Fecha de siembra o plantación (real o prevista).
  final DateTime fecha;
  final int? siembraId;
}

/// La familia vuelve al bancal antes de tiempo.
class AvisoRotacion {
  const AvisoRotacion({
    required this.familiaId,
    required this.aniosMinimos,
    required this.fechaAnterior,
    required this.fechaLibre,
    this.siembraAnteriorId,
  });

  final String familiaId;
  final int aniosMinimos;

  /// La siembra de la misma familia que choca (la más cercana).
  final DateTime fechaAnterior;
  final int? siembraAnteriorId;

  /// Desde cuándo podría volver sin aviso (si la que choca es anterior).
  final DateTime fechaLibre;
}

/// Suma [anios] años a [fecha] (el 29 de febrero pasa al 1 de marzo).
DateTime sumarAnios(DateTime fecha, int anios) =>
    DateTime(fecha.year + anios, fecha.month, fecha.day);

/// Familia normalizada para comparar: minúsculas, sin espacios a los lados.
String normalizarFamilia(String familiaId) => familiaId.trim().toLowerCase();

/// Comprueba si poner [familiaId] en [bancalId] en [fecha] respeta los años
/// mínimos de [aniosMinimosPorFamilia]. Devuelve null si no hay aviso, si la
/// familia no tiene regla (no se puede decir) o si su regla es 0 años.
///
/// Mira hacia atrás y hacia delante: una siembra planificada más adelante
/// de la misma familia también choca. [excluirSiembraId] deja fuera la
/// propia siembra cuando se edita.
AvisoRotacion? comprobarRotacion({
  required int bancalId,
  required String familiaId,
  required DateTime fecha,
  required List<PasoPorBancal> historial,
  required Map<String, int> aniosMinimosPorFamilia,
  int? excluirSiembraId,
}) {
  final familia = normalizarFamilia(familiaId);
  final anios = aniosMinimosPorFamilia[familia];
  if (familia.isEmpty || anios == null || anios <= 0) return null;
  AvisoRotacion? masCercano;
  Duration? distanciaMasCercana;
  for (final paso in historial) {
    if (paso.bancalId != bancalId) continue;
    if (excluirSiembraId != null && paso.siembraId == excluirSiembraId) {
      continue;
    }
    if (normalizarFamilia(paso.familiaId) != familia) continue;
    final (primera, segunda) =
        paso.fecha.isAfter(fecha) ? (fecha, paso.fecha) : (paso.fecha, fecha);
    if (!sumarAnios(primera, anios).isAfter(segunda)) continue;
    final distancia = segunda.difference(primera).abs();
    if (distanciaMasCercana == null || distancia < distanciaMasCercana) {
      distanciaMasCercana = distancia;
      masCercano = AvisoRotacion(
        familiaId: familia,
        aniosMinimos: anios,
        fechaAnterior: paso.fecha,
        siembraAnteriorId: paso.siembraId,
        fechaLibre: sumarAnios(paso.fecha, anios),
      );
    }
  }
  return masCercano;
}

/// Plan del bancal en [fecha]: para cada familia con regla que ha pasado por
/// él, desde cuándo puede volver. Solo las que aún no pueden (fecha libre
/// posterior a [fecha]), de la que antes se libera a la que más tarda.
List<({String familiaId, DateTime fechaLibre})> familiasBloqueadas({
  required int bancalId,
  required DateTime fecha,
  required List<PasoPorBancal> historial,
  required Map<String, int> aniosMinimosPorFamilia,
}) {
  final ultimaPorFamilia = <String, DateTime>{};
  for (final paso in historial) {
    if (paso.bancalId != bancalId || paso.fecha.isAfter(fecha)) continue;
    final familia = normalizarFamilia(paso.familiaId);
    final anterior = ultimaPorFamilia[familia];
    if (anterior == null || paso.fecha.isAfter(anterior)) {
      ultimaPorFamilia[familia] = paso.fecha;
    }
  }
  final bloqueadas = <({String familiaId, DateTime fechaLibre})>[];
  for (final entrada in ultimaPorFamilia.entries) {
    final anios = aniosMinimosPorFamilia[entrada.key];
    if (anios == null || anios <= 0) continue;
    final libre = sumarAnios(entrada.value, anios);
    if (libre.isAfter(fecha)) {
      bloqueadas.add((familiaId: entrada.key, fechaLibre: libre));
    }
  }
  bloqueadas.sort((a, b) => a.fechaLibre.compareTo(b.fechaLibre));
  return bloqueadas;
}

/// Id de la familia de las leguminosas en `rotacion.csv`.
const String familiaLeguminosas = 'fabaceas';

/// Si el bancal ha tenido leguminosas en los [anios] años anteriores a
/// [fecha]. El Reglamento (UE) 2018/848, anexo II, parte I, punto 1.9.2.a),
/// pide una rotación plurianual que incluya leguminosas (como cultivo
/// principal o de cobertura); la app solo lo recuerda, no lo evalúa.
bool tuvoLeguminosas({
  required int bancalId,
  required DateTime fecha,
  required List<PasoPorBancal> historial,
  int anios = 3,
}) {
  final desde = sumarAnios(fecha, -anios);
  return historial.any((paso) =>
      paso.bancalId == bancalId &&
      normalizarFamilia(paso.familiaId) == familiaLeguminosas &&
      !paso.fecha.isBefore(desde) &&
      !paso.fecha.isAfter(fecha));
}

/// Familias del historial de un bancal sin regla en el catálogo: la app no
/// puede avisar de ellas y lo dice.
Set<String> familiasSinRegla({
  required List<PasoPorBancal> historial,
  required Map<String, int> aniosMinimosPorFamilia,
}) =>
    {
      for (final paso in historial)
        if (!aniosMinimosPorFamilia
            .containsKey(normalizarFamilia(paso.familiaId)))
          normalizarFamilia(paso.familiaId),
    }..remove('');
