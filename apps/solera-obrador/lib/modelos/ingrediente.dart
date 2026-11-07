import 'alergenos.dart';

/// Materia prima del obrador (harina, levadura, mantequilla, sal…).
class Ingrediente {
  Ingrediente({
    this.id,
    required this.nombre,
    this.alergenos = const {},
    this.trazas = const {},
    this.proveedor = '',
    this.precioCentimosPorKg = 0,
    this.salGramosPor100g = 0,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Alérgenos que contiene (declaración del proveedor).
  final Set<String> alergenos;

  /// «Puede contener»: contaminación cruzada declarada por el proveedor.
  final Set<String> trazas;
  final String proveedor;
  final int precioCentimosPorKg;

  /// Sal del ingrediente (100 para la sal; 0 para la harina). Sirve para
  /// **estimar** la sal del producto, nunca para certificarla.
  final double salGramosPor100g;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'alergenos': codificarAlergenos(alergenos),
        'trazas': codificarAlergenos(trazas),
        'proveedor': proveedor,
        'precio_centimos_kg': precioCentimosPorKg,
        'sal_g_100g': salGramosPor100g,
        'notas': notas,
      };

  factory Ingrediente.fromMap(Map<String, Object?> mapa) => Ingrediente(
        id: mapa['id'] as int?,
        nombre: mapa['nombre'] as String,
        alergenos: decodificarAlergenos(mapa['alergenos'] as String?),
        trazas: decodificarAlergenos(mapa['trazas'] as String?),
        proveedor: (mapa['proveedor'] as String?) ?? '',
        precioCentimosPorKg: (mapa['precio_centimos_kg'] as int?) ?? 0,
        salGramosPor100g: ((mapa['sal_g_100g'] as num?) ?? 0).toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
