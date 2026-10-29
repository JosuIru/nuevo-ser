/// Registro de cosecha asociado a una cepa. En vid se mide casi
/// siempre en kilos (vendimia mecánica o manual a granel); las
/// unidades se mantienen como campo opcional por simetría con la
/// suite Larrea y por si algún operador las quiere usar (p. ej.
/// ensayos de cabezas/racimos por cepa).
///
/// `calidad` opcional 1..5 (libre interpretación por el operador —
/// catalogación de uva, sanidad, grado probable…).
class Cosecha {
  final int? id;
  final int cepaId;
  final int fechaMs;
  final double? kilos;
  final int? unidades;
  final int? calidad;
  final String rutasFotosJson;
  final String notas;

  Cosecha({
    this.id,
    required this.cepaId,
    required this.fechaMs,
    this.kilos,
    this.unidades,
    this.calidad,
    this.rutasFotosJson = '[]',
    this.notas = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'cepa_id': cepaId,
        'fecha_ms': fechaMs,
        'kilos': kilos,
        'unidades': unidades,
        'calidad': calidad,
        'rutas_fotos_json': rutasFotosJson,
        'notas': notas,
      };

  factory Cosecha.fromMap(Map<String, Object?> mapa) => Cosecha(
        id: mapa['id'] as int?,
        cepaId: mapa['cepa_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        kilos: (mapa['kilos'] as num?)?.toDouble(),
        unidades: mapa['unidades'] as int?,
        calidad: mapa['calidad'] as int?,
        rutasFotosJson: (mapa['rutas_fotos_json'] as String?) ?? '[]',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
