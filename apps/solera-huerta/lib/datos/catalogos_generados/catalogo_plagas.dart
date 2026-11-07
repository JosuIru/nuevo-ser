// MARCADOR TEMPORAL: se sobrescribe con tool/compilar_catalogos.dart.

class PlagaCatalogo {
  const PlagaCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.familias,
    required this.sintomas,
    required this.seguimiento,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final List<String> familias;
  final String sintomas;
  final String seguimiento;
  final String revisadoPor;
}

const List<PlagaCatalogo> catalogoPlagas = [];
