/// Ficha técnica de un producto (pan, bollo, tarta, mermelada…).
class Receta {
  Receta({
    this.id,
    required this.nombre,
    this.denominacion = '',
    this.piezasPorMasa = 1,
    this.mermaCoccionPorcentaje = 0,
    this.esSubreceta = false,
    this.precioVentaCentimosPieza = 0,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Denominación del catálogo (`pan_comun`, `pan_integral`…); vacía si no
  /// es pan. Ver `content/obrador/denominaciones_pan.csv`.
  final String denominacion;

  /// Piezas que salen de una masa con las cantidades de sus líneas.
  final int piezasPorMasa;

  /// Agua que se pierde al cocer (% del peso de la masa).
  final double mermaCoccionPorcentaje;

  /// Masa base, relleno o cobertura que se usa dentro de otras recetas.
  final bool esSubreceta;
  final int precioVentaCentimosPieza;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'denominacion': denominacion,
        'piezas_por_masa': piezasPorMasa,
        'merma_coccion_pct': mermaCoccionPorcentaje,
        'es_subreceta': esSubreceta ? 1 : 0,
        'precio_venta_centimos_pieza': precioVentaCentimosPieza,
        'notas': notas,
      };

  factory Receta.fromMap(Map<String, Object?> mapa) => Receta(
        id: mapa['id'] as int?,
        nombre: mapa['nombre'] as String,
        denominacion: (mapa['denominacion'] as String?) ?? '',
        piezasPorMasa: (mapa['piezas_por_masa'] as int?) ?? 1,
        mermaCoccionPorcentaje:
            ((mapa['merma_coccion_pct'] as num?) ?? 0).toDouble(),
        esSubreceta: (mapa['es_subreceta'] as int?) == 1,
        precioVentaCentimosPieza:
            (mapa['precio_venta_centimos_pieza'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Línea de una receta: un ingrediente **o** una subreceta, en gramos.
class LineaReceta {
  LineaReceta({
    this.id,
    required this.recetaId,
    this.ingredienteId,
    this.subrecetaId,
    required this.gramos,
  }) : assert((ingredienteId == null) != (subrecetaId == null),
            'una línea es un ingrediente o una subreceta, no las dos');

  final int? id;
  final int recetaId;
  final int? ingredienteId;
  final int? subrecetaId;
  final double gramos;

  Map<String, Object?> toMap() => {
        'id': id,
        'receta_id': recetaId,
        'ingrediente_id': ingredienteId,
        'subreceta_id': subrecetaId,
        'gramos': gramos,
      };

  factory LineaReceta.fromMap(Map<String, Object?> mapa) => LineaReceta(
        id: mapa['id'] as int?,
        recetaId: mapa['receta_id'] as int,
        ingredienteId: mapa['ingrediente_id'] as int?,
        subrecetaId: mapa['subreceta_id'] as int?,
        gramos: (mapa['gramos'] as num).toDouble(),
      );
}
