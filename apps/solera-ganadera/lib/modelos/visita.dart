/// Registro de visitas y vehículos, incluidas las del veterinario
/// (RD 787/2023, anexo V punto 11; RD 666/2023, art. 41.3).
class Visita {
  Visita({
    this.id,
    required this.fechaMs,
    required this.persona,
    this.motivo = '',
    this.esVeterinaria = false,
    this.vehiculo = '',
    this.notas = '',
  });

  final int? id;
  final int fechaMs;
  final String persona;
  final String motivo;
  final bool esVeterinaria;

  /// Matrícula del vehículo que entra, si entra alguno.
  final String vehiculo;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'persona': persona,
        'motivo': motivo,
        'es_veterinaria': esVeterinaria ? 1 : 0,
        'vehiculo': vehiculo,
        'notas': notas,
      };

  factory Visita.fromMap(Map<String, Object?> mapa) => Visita(
        id: mapa['id'] as int?,
        fechaMs: (mapa['fecha_ms'] as num?)?.toInt() ?? 0,
        persona: (mapa['persona'] as String?) ?? '',
        motivo: (mapa['motivo'] as String?) ?? '',
        esVeterinaria: ((mapa['es_veterinaria'] as num?)?.toInt() ?? 0) != 0,
        vehiculo: (mapa['vehiculo'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
