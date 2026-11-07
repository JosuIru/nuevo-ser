// MARCADOR TEMPORAL: se sobrescribe con tool/compilar_catalogos.dart.

class FamiliaRotacionCatalogo {
  const FamiliaRotacionCatalogo({
    required this.familiaId,
    required this.nombre,
    required this.aniosMinimos,
    required this.ejemplos,
    required this.revisadoPor,
    required this.notas,
  });

  final String familiaId;
  final String nombre;
  final int? aniosMinimos;
  final String ejemplos;
  final String revisadoPor;
  final String notas;
}

const List<FamiliaRotacionCatalogo> catalogoRotacion = [];
