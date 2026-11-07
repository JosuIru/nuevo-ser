// MARCADOR TEMPORAL: se sobrescribe con tool/compilar_catalogos.dart.

class CultivoCatalogo {
  const CultivoCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.familiaId,
    required this.cicloDias,
    required this.semanasCosecha,
    required this.marco,
    required this.porUnidades,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String familiaId;
  final int? cicloDias;
  final int? semanasCosecha;
  final String marco;
  final bool? porUnidades;
  final String revisadoPor;
}

const List<CultivoCatalogo> catalogoCultivos = [];
