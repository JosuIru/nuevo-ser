// MARCADOR TEMPORAL: se sobrescribe con tool/compilar_catalogos.dart.

class CategoriaInsumoCatalogo {
  const CategoriaInsumoCatalogo({
    required this.id,
    required this.anexo,
    required this.tipo,
    required this.nombre,
    required this.condiciones,
    required this.revisadoPor,
  });

  final String id;
  final String anexo;
  final String tipo;
  final String nombre;
  final String condiciones;
  final String revisadoPor;
}

const List<CategoriaInsumoCatalogo> catalogoCategoriasInsumo = [];
