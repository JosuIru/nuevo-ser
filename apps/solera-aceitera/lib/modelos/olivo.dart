/// Pie individual de olivo. Entidad análoga a Cepa/Colmena/Arbol en
/// las otras Larrea, pero su granularidad solo tiene sentido para
/// olivares **superintensivos** (donde cada pie produce kg medibles)
/// o para **olivos monumentales catalogados** (donde el pie es
/// patrimonio en sí). La mayoría de explotaciones trabajan a nivel de
/// parcela y nunca crearán filas en esta tabla.
class Olivo {
  final int? id;
  final int parcelaId; // FK Parcela
  /// Etiqueta humana opcional (p.ej. "Olivo de la Era" para los
  /// monumentales, "fila 7 col 12" para superintensivos).
  final String identificadorInterno;
  /// FK textual al catálogo `variedades_olivo`.
  final String variedadId;
  final int edadAnyos;
  /// Uno de: `productivo` / `en_formacion` / `arrancado` / `sustituido`.
  final String estado;
  final int? fechaPlantacionMs;
  final String notas;
  final int fechaCreacionMs;

  Olivo({
    this.id,
    required this.parcelaId,
    this.identificadorInterno = '',
    this.variedadId = '',
    this.edadAnyos = 0,
    this.estado = 'productivo',
    this.fechaPlantacionMs,
    this.notas = '',
    required this.fechaCreacionMs,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'identificador_interno': identificadorInterno,
        'variedad_id': variedadId,
        'edad_anyos': edadAnyos,
        'estado': estado,
        'fecha_plantacion_ms': fechaPlantacionMs,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Olivo.fromMap(Map<String, Object?> mapa) => Olivo(
        id: mapa['id'] as int?,
        parcelaId: (mapa['parcela_id'] as int?) ?? 0,
        identificadorInterno: (mapa['identificador_interno'] as String?) ?? '',
        variedadId: (mapa['variedad_id'] as String?) ?? '',
        edadAnyos: (mapa['edad_anyos'] as int?) ?? 0,
        estado: (mapa['estado'] as String?) ?? 'productivo',
        fechaPlantacionMs: mapa['fecha_plantacion_ms'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
