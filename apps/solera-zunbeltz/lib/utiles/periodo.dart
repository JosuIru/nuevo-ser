/// Periodos de análisis del seguimiento. El cálculo de la BD acepta un rango
/// `desdeMs`/`hastaMs`; aquí se traduce cada periodo a ese rango.
enum TipoPeriodo { todo, anio, trimestre, trimestreAnterior }

/// Rango temporal en milisegundos (null = sin límite por ese lado).
class RangoPeriodo {
  const RangoPeriodo(this.desdeMs, this.hastaMs);

  final int? desdeMs;
  final int? hastaMs;

  /// Días que cubre el rango (para extrapolar). Null si es abierto.
  int? get dias {
    if (desdeMs == null || hastaMs == null) return null;
    final d = ((hastaMs! - desdeMs!) / 86400000).round();
    return d > 0 ? d : null;
  }
}

/// Traduce un [TipoPeriodo] a su rango, relativo a [ahora].
RangoPeriodo rangoDePeriodo(TipoPeriodo tipo, DateTime ahora) {
  switch (tipo) {
    case TipoPeriodo.todo:
      return const RangoPeriodo(null, null);
    case TipoPeriodo.anio:
      final desde = DateTime(ahora.year, 1, 1);
      final hasta = DateTime(ahora.year + 1, 1, 1)
          .subtract(const Duration(milliseconds: 1));
      return RangoPeriodo(
          desde.millisecondsSinceEpoch, hasta.millisecondsSinceEpoch);
    case TipoPeriodo.trimestre:
      return _trimestre(ahora.year, (ahora.month - 1) ~/ 3);
    case TipoPeriodo.trimestreAnterior:
      var q = ((ahora.month - 1) ~/ 3) - 1;
      var anio = ahora.year;
      if (q < 0) {
        q = 3;
        anio -= 1;
      }
      return _trimestre(anio, q);
  }
}

RangoPeriodo _trimestre(int anio, int q) {
  final desde = DateTime(anio, q * 3 + 1, 1);
  final hasta =
      DateTime(anio, q * 3 + 4, 1).subtract(const Duration(milliseconds: 1));
  return RangoPeriodo(
      desde.millisecondsSinceEpoch, hasta.millisecondsSinceEpoch);
}

/// Días con datos para extrapolar a un año: desde el principio del periodo
/// (o el inicio del proyecto, si empezó después) hasta su final, pero nunca
/// más allá de hoy ni del fin del proyecto. Un trimestre en curso cuenta
/// los días que han pasado, no los 92 del trimestre: si no, el resultado
/// anual sale muy por debajo. `null` si no se sabe desde cuándo.
int? diasParaExtrapolar({
  required RangoPeriodo rango,
  int? inicioProyectoMs,
  int? finProyectoMs,
  required int ahoraMs,
}) {
  final candidatosDesde = [rango.desdeMs, inicioProyectoMs].whereType<int>();
  if (candidatosDesde.isEmpty) return null;
  final desde = candidatosDesde.reduce((a, b) => a > b ? a : b);
  final hasta = [rango.hastaMs, finProyectoMs, ahoraMs]
      .whereType<int>()
      .reduce((a, b) => a < b ? a : b);
  final dias = ((hasta - desde) / 86400000).ceil();
  return dias > 0 ? dias : null;
}
