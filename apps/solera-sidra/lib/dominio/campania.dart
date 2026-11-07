/// Campaña del manzano de sidra: «desde el inicio de septiembre a finales de
/// agosto del año siguiente» (pliego de Euskal Sagardoa, jul-2024, ap. F.1).
/// Se nombra por el año en que empieza: la campaña 2026 va del 1-sep-2026 al
/// 31-ago-2027. La app usa la misma para el txakoli (vendimia en otoño).
int campaniaDe(DateTime fecha) =>
    fecha.month >= 9 ? fecha.year : fecha.year - 1;

/// Primer y último milisegundo de la campaña [anio].
({int desdeMs, int hastaMs}) rangoCampania(int anio) => (
      desdeMs: DateTime(anio, 9).millisecondsSinceEpoch,
      hastaMs: DateTime(anio + 1, 9).millisecondsSinceEpoch - 1,
    );

/// «2026-2027».
String nombreCampania(int anio) => '$anio-${anio + 1}';
