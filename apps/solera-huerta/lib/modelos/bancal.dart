/// Bancal (o tabla, era, banda) de una parcela: la unidad de la rotación.
class Bancal {
  Bancal({
    this.id,
    required this.parcelaId,
    required this.nombre,
    this.largoM,
    this.anchoM,
    this.invernadero = false,
    this.activo = true,
    this.notas = '',
  });

  final int? id;
  final int parcelaId;

  /// Etiqueta corta tal como se usa en la huerta: «B3», «Tabla del nogal».
  final String nombre;
  final double? largoM;
  final double? anchoM;

  /// Bajo cubierta (túnel o invernadero).
  final bool invernadero;

  /// Un bancal que ya no se cultiva se desactiva: su historial sigue.
  final bool activo;
  final String notas;

  /// Superficie en m², o null si falta alguna medida.
  double? get superficieM2 =>
      largoM == null || anchoM == null ? null : largoM! * anchoM!;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'nombre': nombre,
        'largo_m': largoM,
        'ancho_m': anchoM,
        'invernadero': invernadero ? 1 : 0,
        'activo': activo ? 1 : 0,
        'notas': notas,
      };

  factory Bancal.fromMap(Map<String, Object?> mapa) => Bancal(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        nombre: (mapa['nombre'] as String?) ?? '',
        largoM: (mapa['largo_m'] as num?)?.toDouble(),
        anchoM: (mapa['ancho_m'] as num?)?.toDouble(),
        invernadero: (mapa['invernadero'] as int?) == 1,
        activo: (mapa['activo'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
