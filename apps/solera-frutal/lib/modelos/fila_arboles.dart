/// Una fila (o un grupo de filas) de árboles de la misma variedad dentro de
/// una parcela. Es la unidad con identidad: dónde están las polinizadoras.
class FilaArboles {
  FilaArboles({
    this.id,
    required this.parcelaId,
    required this.etiqueta,
    required this.variedadId,
    this.numeroArboles = 0,
    this.esPolinizadora = false,
    this.anyoPlantacion,
    this.notas = '',
  });

  final int? id;
  final int parcelaId;

  /// Cómo la llama la persona: «Filas 1-4», «Lindero norte»…
  final String etiqueta;

  /// Id del catálogo de variedades o nombre libre.
  final String variedadId;
  final int numeroArboles;

  /// Plantada para polinizar a la variedad principal.
  final bool esPolinizadora;
  final int? anyoPlantacion;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'etiqueta': etiqueta,
        'variedad_id': variedadId,
        'numero_arboles': numeroArboles,
        'es_polinizadora': esPolinizadora ? 1 : 0,
        'anyo_plantacion': anyoPlantacion,
        'notas': notas,
      };

  factory FilaArboles.fromMap(Map<String, Object?> mapa) => FilaArboles(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        etiqueta: (mapa['etiqueta'] as String?) ?? '',
        variedadId: (mapa['variedad_id'] as String?) ?? '',
        numeroArboles: (mapa['numero_arboles'] as int?) ?? 0,
        esPolinizadora: (mapa['es_polinizadora'] as int?) == 1,
        anyoPlantacion: mapa['anyo_plantacion'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
